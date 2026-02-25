# Arquitetura ControlAI

## Visão Geral

O ControlAI é um SaaS multi-tenant construído com Vite/React, Supabase, Stripe e Brevo. Este documento descreve o mapa de módulos, fluxos críticos e diretrizes de implementação.

---

## Mapa de Módulos

```
src/
├── lib/                    # Lógica de baixo nível e utilitários
│   ├── supabase/
│   │   └── client.ts       # Cliente Supabase (ambientes dev/prod)
│   └── utils.ts
├── components/             # Componentes reutilizáveis
│   ├── ui/                 # Shadcn UI
│   ├── auth/               # Login, Register, ProtectedRoute
│   ├── layout/             # AppSidebar, AppHeader
│   ├── dashboard/          # Master e Tenant dashboards
│   ├── tenant/             # Settings, agents, billing
│   └── chat/               # Workspace de chat
├── pages/                  # Páginas/rotas
│   ├── auth/
│   ├── dashboard/
│   └── Landing.tsx
├── contexts/               # Providers (Auth, Tenant)
├── hooks/                  # useProfile, useAuth, etc.
└── routes/                 # ProtectedRoute, RoleGuard

supabase/
├── migrations/             # Schema e RLS
├── functions/              # Edge Functions (operações sensíveis)
│   ├── provision-tenant
│   ├── stripe-webhooks
│   ├── store-byok-key
│   ├── invoke-llm
│   └── ...
└── config.toml
```

---

## Guidelines

1. **Banco de dados**: Acesse o Supabase via `src/lib/supabase/client.ts`. Nunca exponha `service_role` no frontend.
2. **Operações sensíveis**: Chaves BYOK, Stripe webhooks, provisionamento de tenant → usar Edge Functions.
3. **RLS**: Todas as tabelas com `empresa_id` têm RLS habilitado. Nunca desabilite.
4. **Validação**: Usar zod em formulários e em Edge Functions.
5. **Tipos**: Gerar tipos com `supabase gen types typescript` e manter em `src/lib/supabase/database.types.ts` (opcional).

---

## Fluxo BYOK (Bring Your Own Key)

O cliente (tenant) fornece sua própria chave API de LLM (OpenAI/Claude). A plataforma cobra taxa de serviço; os custos de token ficam com o cliente.

```mermaid
flowchart LR
    subgraph AdminTenant [Admin Tenant]
        A1[Formulário BYOK]
    end
    subgraph EdgeFn [Edge Functions]
        E1[store-byok-key]
        E2[invoke-llm]
    end
    subgraph DB [(Supabase)]
        T1[empresas.chave_api_llm]
    end
    subgraph External [Externo]
        OAI[OpenAI/Claude API]
    end
    A1 -->|"Chave em texto (HTTPS)"| E1
    E1 -->|"Criptografa via pgcrypto"| T1
    E2 -->|"Lê chave (service_role)"| T1
    E2 -->|"Chama LLM"| OAI
```

**Regras de segurança:**
- Chave nunca trafega no frontend após o envio (formulário → Edge Function).
- Chave nunca retornada em SELECT; descriptografada apenas em runtime server-side.
- Armazenamento: `pgcrypto` ou Supabase Vault.

---

## Políticas RLS

Todas as tabelas multi-tenant devem isolar dados por `empresa_id`. O perfil do usuário (`perfis`) contém `empresa_id` e `role` (master, admin, user).

### Funções auxiliares

```sql
-- Retorna empresa_id do usuário logado (via perfis)
get_user_empresa_id() → bigint

-- Retorna role do usuário logado
get_user_role() → text
```

### Matriz de acesso

| Tabela       | user (colaborador) | admin (tenant) | master       |
|--------------|--------------------|----------------|--------------|
| planos       | SELECT             | SELECT         | SELECT       |
| empresas     | SELECT (própria)   | SELECT/UPDATE (própria) | SELECT/UPDATE (todas) |
| perfis       | SELECT (mesma empresa) | CRUD (mesma empresa) | SELECT (todas) |
| agentes_ia   | SELECT (mesma empresa) | CRUD (mesma empresa) | SELECT (todas) |
| conversas    | SELECT/INSERT (próprias) | SELECT (empresa) | SELECT (todas) |
| uso_recursos | SELECT (empresa)   | SELECT (empresa) | SELECT (todas) |
| auditoria    | -                  | SELECT (empresa) | SELECT (todas) |

### Regras gerais

- **empresas**: `empresa_id = get_user_empresa_id()` ou `get_user_role() = 'master'`
- **perfis, agentes_ia, conversas, uso_recursos**: `empresa_id = get_user_empresa_id()` ou master
- **auditoria**: Inserção via triggers/funções; leitura restrita a admin/master

---

## Variáveis de Ambiente

| Variável               | Onde              | Descrição                    |
|------------------------|-------------------|------------------------------|
| VITE_SUPABASE_URL      | Frontend          | URL do projeto Supabase      |
| VITE_SUPABASE_ANON_KEY | Frontend          | Chave anon (pública)         |
| STRIPE_SECRET_KEY      | Edge Functions    | Chave secreta Stripe         |
| STRIPE_WEBHOOK_SECRET  | Edge Functions    | Assinatura do webhook        |
| BREVO_API_KEY          | Edge Functions    | API Brevo para e-mails       |
