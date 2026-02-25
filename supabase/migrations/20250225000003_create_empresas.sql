-- Tabela empresas (tenants): empresas clientes do SaaS
CREATE TABLE public.empresas (
  id BIGSERIAL PRIMARY KEY,
  nome TEXT NOT NULL,
  plano_id BIGINT NOT NULL REFERENCES public.planos(id) ON DELETE RESTRICT,
  chave_api_llm BYTEA,
  contexto_ia JSONB DEFAULT '{}',
  stripe_customer_id TEXT UNIQUE,
  email TEXT,
  telefone TEXT,
  endereco TEXT,
  status TEXT NOT NULL DEFAULT 'ativo',
  data_adesao DATE DEFAULT CURRENT_DATE,
  proxima_cobranca DATE,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_empresas_plano_id ON public.empresas(plano_id);
CREATE INDEX idx_empresas_stripe_customer_id ON public.empresas(stripe_customer_id) WHERE stripe_customer_id IS NOT NULL;
