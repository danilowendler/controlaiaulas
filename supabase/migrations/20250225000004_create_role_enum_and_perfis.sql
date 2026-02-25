-- Enum para roles dos colaboradores
CREATE TYPE public.user_role AS ENUM ('master', 'admin', 'user');

-- Tabela perfis: colaboradores/usuários vinculados a auth.users
-- id = auth.users.id (UUID do Supabase Auth)
CREATE TABLE public.perfis (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  empresa_id BIGINT NOT NULL REFERENCES public.empresas(id) ON DELETE CASCADE,
  role public.user_role NOT NULL DEFAULT 'user',
  email TEXT NOT NULL,
  nome_completo TEXT,
  telefone TEXT,
  cargo TEXT,
  status TEXT NOT NULL DEFAULT 'ativo',
  ultimo_acesso TIMESTAMPTZ,
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_perfis_empresa_id ON public.perfis(empresa_id);
CREATE INDEX idx_perfis_role ON public.perfis(role);
