-- Tabela planos: planos de assinatura do SaaS
CREATE TABLE public.planos (
  id BIGSERIAL PRIMARY KEY,
  nome TEXT NOT NULL,
  preco_mensal DECIMAL(10, 2) NOT NULL DEFAULT 0,
  max_usuarios INTEGER NOT NULL DEFAULT 3,
  max_agentes INTEGER NOT NULL DEFAULT 1,
  limite_mensagens_mes INTEGER NOT NULL DEFAULT 100,
  stripe_price_id TEXT UNIQUE,
  features JSONB DEFAULT '[]',
  is_active BOOLEAN NOT NULL DEFAULT true,
  cor TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Índice para busca por stripe_price_id
CREATE INDEX idx_planos_stripe_price_id ON public.planos(stripe_price_id) WHERE stripe_price_id IS NOT NULL;
