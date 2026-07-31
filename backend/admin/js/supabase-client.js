// Stesso progetto Supabase usato dal frontend pubblico.
// L'accesso a INSERT/UPDATE/DELETE sulle tabelle di contenuto e iscrizioni
// è protetto da RLS: solo utenti autenticati (staff) possono scrivere.
const SUPABASE_URL = "https://rasqhhcohliipcyuggve.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJhc3FoaGNvaGxpaXBjeXVnZ3ZlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU0Nzk0NzUsImV4cCI6MjEwMTA1NTQ3NX0.4Xiw9OVYPKCk9SikzKNlp54Tp6rr9KyEs5QPMfV1tJM";
const supabaseClient = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
