-- Tabela uso_recursos: controle de limites por empresa/mês
CREATE TABLE public.uso_recursos (
  id BIGSERIAL PRIMARY KEY,
  empresa_id BIGINT NOT NULL REFERENCES public.empresas(id) ON DELETE CASCADE,
  mes_referencia DATE NOT NULL,
  mensagens_enviadas INTEGER NOT NULL DEFAULT 0,
  tokens_consumidos INTEGER NOT NULL DEFAULT 0,
  agentes_ativos INTEGER DEFAULT 0,
  usuarios_ativos INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(empresa_id, mes_referencia)
);

CREATE INDEX idx_uso_recursos_empresa_mes ON public.uso_recursos(empresa_id, mes_referencia);
