-- =========================================================
-- BIGALOVE RIDE — SCHEMA SUPABASE
-- Da eseguire in: Supabase Dashboard > SQL Editor > New query
-- =========================================================

-- Estensione per UUID
create extension if not exists "uuid-ossp";

-- ---------------------------------------------------------
-- 1. ISCRIZIONI ALLA RIDE
-- ---------------------------------------------------------
create table if not exists public.iscrizioni (
  id uuid primary key default uuid_generate_v4(),
  nome text not null,
  cognome text not null,
  email text not null,
  telefono text not null,
  citta text not null,
  codice_fiscale text not null,
  ha_bici_cargo boolean default true,
  richiede_noleggio boolean default false,
  taglia_maglia text,
  note text,
  stato text not null default 'in_attesa' check (stato in ('in_attesa','confermata','annullata')),
  caparra_pagata boolean default false,
  privacy_accettata boolean not null default false,
  creato_il timestamptz not null default now()
);

comment on table public.iscrizioni is 'Iscrizioni raccolte dal form pubblico Iscriviti';

-- ---------------------------------------------------------
-- 2. RICHIESTE DI NOLEGGIO CARGO BIKE
-- ---------------------------------------------------------
create table if not exists public.richieste_noleggio (
  id uuid primary key default uuid_generate_v4(),
  iscrizione_id uuid references public.iscrizioni(id) on delete set null,
  nome text not null,
  cognome text not null,
  email text not null,
  telefono text not null,
  modello_bici text not null,
  tipo_noleggio text not null default 'classico' check (tipo_noleggio in ('classico','rent_and_buy')),
  scadenza_prenotazione date,
  stato text not null default 'in_attesa' check (stato in ('in_attesa','confermata','annullata')),
  note text,
  creato_il timestamptz not null default now()
);

-- ---------------------------------------------------------
-- 3. PAGINE E BLOCCHI DI CONTENUTO (drag & drop dal backend)
-- Ogni riga è un "blocco" di una pagina, con un ordine (position)
-- che il pannello admin può riordinare via drag & drop.
-- ---------------------------------------------------------
create table if not exists public.pagine (
  slug text primary key,          -- es. 'home', 'noleggio', 'edizioni-precedenti', 'cosa-e-bigalove'
  titolo text not null,
  pubblicata boolean default true,
  aggiornato_il timestamptz not null default now()
);

create table if not exists public.blocchi_contenuto (
  id uuid primary key default uuid_generate_v4(),
  pagina_slug text not null references public.pagine(slug) on delete cascade,
  tipo text not null check (tipo in (
    'hero','carosello','statistiche','mappa_gpx','testo_immagine',
    'faq','call_to_action','galleria','edizioni_grid'
  )),
  posizione int not null default 0,   -- ordine drag & drop
  visibile boolean default true,
  contenuto jsonb not null default '{}'::jsonb,  -- testo, immagini, link... a struttura libera
  aggiornato_il timestamptz not null default now()
);

create index if not exists idx_blocchi_pagina on public.blocchi_contenuto(pagina_slug, posizione);

-- ---------------------------------------------------------
-- 4. GALLERIA IMMAGINI (carosello / edizioni precedenti)
-- ---------------------------------------------------------
create table if not exists public.galleria (
  id uuid primary key default uuid_generate_v4(),
  categoria text not null default 'home' check (categoria in ('home','edizione_precedente')),
  anno int,
  url_immagine text not null,
  didascalia text,
  posizione int not null default 0,
  creato_il timestamptz not null default now()
);

-- ---------------------------------------------------------
-- 5. EDIZIONI PRECEDENTI
-- ---------------------------------------------------------
create table if not exists public.edizioni_precedenti (
  id uuid primary key default uuid_generate_v4(),
  anno int not null unique,
  titolo text not null,
  partecipanti int,
  km_percorsi numeric,
  descrizione text,
  copertina_url text,
  posizione int not null default 0
);

-- ---------------------------------------------------------
-- 6. FAQ
-- ---------------------------------------------------------
create table if not exists public.faq (
  id uuid primary key default uuid_generate_v4(),
  domanda text not null,
  risposta text not null,
  categoria text default 'generale',
  posizione int not null default 0,
  pubblicata boolean default true
);

-- ---------------------------------------------------------
-- 7. TRACCIA GPX DELLA RIDE
-- ---------------------------------------------------------
create table if not exists public.tracce_gpx (
  id uuid primary key default uuid_generate_v4(),
  nome text not null,
  anno int,
  url_file_gpx text not null,        -- link al file .gpx caricato su Supabase Storage
  km_totali numeric,
  dislivello_metri numeric,
  tempo_medio text,
  attiva boolean default true,
  creato_il timestamptz not null default now()
);

-- =========================================================
-- ROW LEVEL SECURITY
-- Regola: lettura pubblica sui contenuti, scrittura solo autenticati
-- (il pannello admin deve fare login con Supabase Auth)
-- =========================================================
alter table public.iscrizioni enable row level security;
alter table public.richieste_noleggio enable row level security;
alter table public.pagine enable row level security;
alter table public.blocchi_contenuto enable row level security;
alter table public.galleria enable row level security;
alter table public.edizioni_precedenti enable row level security;
alter table public.faq enable row level security;
alter table public.tracce_gpx enable row level security;

-- Chiunque (anche anonimo) può INSERIRE una nuova iscrizione dal form pubblico
create policy "chiunque_puo_iscriversi"
  on public.iscrizioni for insert
  to anon
  with check (true);

-- Solo utenti autenticati (staff nel backend) possono leggere/modificare le iscrizioni
create policy "staff_legge_iscrizioni"
  on public.iscrizioni for select
  to authenticated
  using (true);

create policy "staff_modifica_iscrizioni"
  on public.iscrizioni for update
  to authenticated
  using (true);

-- Stesso schema per le richieste di noleggio
create policy "chiunque_puo_richiedere_noleggio"
  on public.richieste_noleggio for insert
  to anon
  with check (true);

create policy "staff_gestisce_noleggio"
  on public.richieste_noleggio for all
  to authenticated
  using (true);

-- Contenuti (pagine, blocchi, galleria, edizioni, faq, gpx): lettura pubblica, scrittura solo staff
create policy "lettura_pubblica_pagine" on public.pagine for select to anon, authenticated using (true);
create policy "staff_scrive_pagine" on public.pagine for all to authenticated using (true);

create policy "lettura_pubblica_blocchi" on public.blocchi_contenuto for select to anon, authenticated using (true);
create policy "staff_scrive_blocchi" on public.blocchi_contenuto for all to authenticated using (true);

create policy "lettura_pubblica_galleria" on public.galleria for select to anon, authenticated using (true);
create policy "staff_scrive_galleria" on public.galleria for all to authenticated using (true);

create policy "lettura_pubblica_edizioni" on public.edizioni_precedenti for select to anon, authenticated using (true);
create policy "staff_scrive_edizioni" on public.edizioni_precedenti for all to authenticated using (true);

create policy "lettura_pubblica_faq" on public.faq for select to anon, authenticated using (true);
create policy "staff_scrive_faq" on public.faq for all to authenticated using (true);

create policy "lettura_pubblica_gpx" on public.tracce_gpx for select to anon, authenticated using (true);
create policy "staff_scrive_gpx" on public.tracce_gpx for all to authenticated using (true);

-- =========================================================
-- DATI DI ESEMPIO (per popolare subito il sito)
-- =========================================================
insert into public.pagine (slug, titolo) values
  ('home', 'Home'),
  ('noleggio', 'Noleggio'),
  ('edizioni-precedenti', 'Edizioni precedenti'),
  ('cosa-e-bigalove', 'Cos''è BigaLove')
on conflict (slug) do nothing;

insert into public.blocchi_contenuto (pagina_slug, tipo, posizione, contenuto) values
('home','hero',0,'{
  "titolo": "BigaLove Ride",
  "sottotitolo": "Una salita, un cuore, mille motivi per pedalare insieme",
  "immagine_sfondo": "https://picsum.photos/seed/bigalove-hero/1600/900",
  "testo_bottone": "Riserva il mio posto per la ride",
  "link_bottone": "iscriviti.html"
}'),
('home','statistiche',1,'{
  "titolo": "La ride",
  "voci": [
    {"etichetta": "Distanza", "valore": "62", "unita": "km"},
    {"etichetta": "Dislivello", "valore": "1480", "unita": "m D+"},
    {"etichetta": "Tempo medio", "valore": "5h 30", "unita": ""},
    {"etichetta": "Partenza", "valore": "08:00", "unita": ""}
  ]
}'),
('home','mappa_gpx',2,'{
  "titolo": "Il percorso",
  "descrizione": "Traccia ufficiale della BigaLove Ride, dal fondovalle al passo.",
  "url_gpx": "/assets/gpx/bigalove-ride.gpx"
}'),
('home','call_to_action',3,'{
  "titolo": "Non pensarci troppo",
  "testo": "L''iscrizione è gratuita, basta una piccola caparra restituita a chi partecipa.",
  "testo_bottone": "Iscriviti ora",
  "link_bottone": "iscriviti.html"
}')
on conflict do nothing;

insert into public.faq (domanda, risposta, posizione) values
('Devo avere per forza una cargo bike?', 'No. BigaLove Ride nasce per le cargo bike, ma se non ne hai una scrivici: troviamo insieme una soluzione tra noleggio, prestito o condivisione.', 0),
('Quanto costa iscriversi?', 'La ride è gratuita. Chiediamo solo una caparra, che viene restituita a chi partecipa.', 1),
('Cosa succede dopo l''iscrizione?', 'L''iscrizione è confermata solo dopo il pagamento della caparra. Riceverai una email di conferma con tutti i dettagli.', 2),
('C''è un servizio di noleggio bici?', 'Sì, trovi tutte le informazioni nella pagina Noleggio: prenota entro la data indicata per garantirti modello e colore.', 3)
on conflict do nothing;

insert into public.edizioni_precedenti (anno, titolo, partecipanti, km_percorsi, descrizione, copertina_url, posizione) values
(2025, 'BigaLove Ride 2025', 180, 58, 'La prima edizione, tra sterrati e risate.', 'https://picsum.photos/seed/bigalove-2025/800/600', 0)
on conflict (anno) do nothing;
