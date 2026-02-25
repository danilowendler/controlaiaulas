-- Seed inicial dos planos (stripe_price_id preenchido posteriormente no Stripe)
INSERT INTO public.planos (nome, preco_mensal, max_usuarios, max_agentes, limite_mensagens_mes)
VALUES
  ('Free', 0, 3, 1, 100),
  ('Básico', 99.00, 10, 3, 500),
  ('Empresa', 299.00, 50, 10, 2000),
  ('Master', 0, 999999, 999999, 999999);
