-- Tabela conversas: histórico de chats
CREATE TABLE public.conversas (
  id BIGSERIAL PRIMARY KEY,
  conversation_uuid UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  empresa_id BIGINT NOT NULL REFERENCES public.empresas(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  agente_id BIGINT REFERENCES public.agentes_ia(id) ON DELETE SET NULL,
  mensagens JSONB DEFAULT '[]',
  titulo TEXT DEFAULT 'Nova conversa',
  tokens_usados INTEGER DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'ativa',
  contexto_atual JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_conversas_empresa_id ON public.conversas(empresa_id);
CREATE INDEX idx_conversas_user_id ON public.conversas(user_id);
CREATE INDEX idx_conversas_created_at ON public.conversas(created_at DESC);
