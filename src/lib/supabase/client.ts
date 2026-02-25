import { createClient, type SupabaseClient } from "@supabase/supabase-js";

/**
 * Ambiente de execução do app.
 * Em Vite: import.meta.env.MODE = 'development' | 'production'
 */
const isDev = import.meta.env.MODE === "development";

/**
 * Valida presença das variáveis de ambiente obrigatórias.
 * Secrets são carregados via .env.local (dev) ou variáveis do Netlify (prod).
 */
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  const missing = [
    !supabaseUrl && "VITE_SUPABASE_URL",
    !supabaseAnonKey && "VITE_SUPABASE_ANON_KEY",
  ]
    .filter(Boolean)
    .join(", ");
  throw new Error(
    `Variáveis Supabase ausentes (${missing}). Configure em .env.local ou nas variáveis de ambiente.`
  );
}

/**
 * Cliente Supabase para uso no frontend (client-side).
 * Usa a chave anon ( pública ), segura para o browser.
 * RLS garante o isolamento de dados por tenant.
 */
export const supabase: SupabaseClient = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true,
  },
  global: {
    fetch: (...args) => {
      if (isDev) {
        console.debug("[Supabase] Request:", args[0]);
      }
      return fetch(...args);
    },
  },
});

/**
 * Indica se está em ambiente de desenvolvimento.
 * Útil para logs condicionais e feature flags.
 */
export const isDevelopment = isDev;
