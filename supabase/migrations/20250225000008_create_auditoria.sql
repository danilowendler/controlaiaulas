-- Tabela auditoria: logs de ações administrativas
CREATE TABLE public.auditoria (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  acao TEXT NOT NULL,
  entidade_tipo TEXT NOT NULL,
  entidade_id BIGINT,
  empresa_id BIGINT REFERENCES public.empresas(id) ON DELETE SET NULL,
  detalhes JSONB,
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_auditoria_empresa_id ON public.auditoria(empresa_id);
CREATE INDEX idx_auditoria_created_at ON public.auditoria(created_at DESC);
CREATE INDEX idx_auditoria_user_id ON public.auditoria(user_id);
