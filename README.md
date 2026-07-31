# BigaLove Ride — Sito Web

Progetto diviso in:
- `frontend/` — sito pubblico (HTML/CSS/JS puro, nessuna build richiesta)
- `backend/admin/` — pannello di gestione contenuti e iscrizioni, stile Shopify
- `supabase/schema.sql` — schema database da eseguire su Supabase

## 1. Setup Supabase (5 minuti)

1. Vai su [supabase.com](https://supabase.com) e crea un nuovo progetto (gratuito).
2. Apri **SQL Editor > New query**, incolla tutto il contenuto di `supabase/schema.sql` ed esegui (▶). Questo crea tutte le tabelle, le policy di sicurezza (RLS) e alcuni dati di esempio.
3. Vai su **Project Settings > API** e copia:
   - `Project URL`
   - `anon public key`
4. Incollali in **due file**:
   - `frontend/js/supabase-client.js`
   - `backend/admin/js/supabase-client.js`

   ```js
   const SUPABASE_URL = "https://xxxxx.supabase.co";
   const SUPABASE_ANON_KEY = "eyJhbGciOi...";
   ```

5. Crea l'utente staff per accedere al pannello admin: **Authentication > Users > Add user**, inserisci email e password. Con quelle credenziali farai login su `backend/admin/index.html`.

## 2. Aprire il progetto in VS Code

```bash
cd bigalove-ride
code .
```

Installa l'estensione **Live Server** per VS Code, poi:
- tasto destro su `frontend/index.html` → "Open with Live Server" per vedere il sito pubblico
- tasto destro su `backend/admin/index.html` → "Open with Live Server" per il pannello admin

Non serve npm, non serve build: è HTML/CSS/JS che chiama direttamente le API di Supabase dal browser.

## 3. Struttura del frontend

| File | Contenuto |
|---|---|
| `index.html` | Home: hero, carosello, statistiche (Km/tempi/orari), mappa GPX, carosello, anteprima iscrizione, FAQ |
| `iscriviti.html` | Form completo: nome, cognome, email, telefono, città, codice fiscale |
| `noleggio.html` | Info + form richiesta noleggio cargo bike |
| `edizioni-precedenti.html` | Griglia edizioni passate (caricata da Supabase) |
| `cosa-e-bigalove.html` | Pagina "chi siamo" |

Tutte le pagine leggono da Supabase quando possibile (FAQ, galleria, edizioni) e ricadono su contenuto statico se Supabase non è ancora configurato — così il sito funziona anche prima di collegare il database.

## 4. Traccia GPX

Metti il tuo file `.gpx` in `frontend/assets/gpx/bigalove-ride.gpx` (crea la cartella), oppure caricalo su **Supabase Storage** (crea un bucket pubblico `tracce-gpx`) e aggiorna l'attributo `data-gpx-url` nell'elemento `#gpx-map` di `index.html` con l'URL pubblico del file.

## 5. Pannello backend (drag & drop)

In "Homepage" puoi:
- **trascinare** i blocchi per cambiarne l'ordine (si salva subito su Supabase)
- **modificare il contenuto** di ogni blocco editando il JSON nella casella di testo
- **aggiungere nuovi blocchi** scegliendo un modello (hero, carosello, statistiche, mappa GPX, testo+immagine, call to action, FAQ, galleria, griglia edizioni)
- **nascondere** o **eliminare** un blocco

> Nota: per rendere la Home 100% pilotata dai blocchi del pannello (invece dell'HTML statico attuale), il prossimo passo è far leggere a `frontend/index.html` la tabella `blocchi_contenuto` e generare le sezioni dinamicamente, nello stesso modo in cui già fa per FAQ, galleria ed edizioni. L'HTML statico che hai ora è pensato per essere subito online e già bello da vedere; il collegamento dinamico completo è un'estensione naturale una volta che i contenuti reali sono pronti.

## 6. Accesso nascosto al pannello admin

Non c'è nessun link visibile al pannello nel sito pubblico. L'accesso avviene con **3 click ravvicinati** (entro poco più di un secondo) sul testo del copyright nel footer di ogni pagina ("© 2026 BigaLove Ride") — al terzo click si viene reindirizzati al pannello.

Per configurarlo:
1. Apri `frontend/js/main.js` e cerca la costante `ADMIN_PANEL_URL` in fondo al file.
2. Sostituiscila con l'indirizzo reale del pannello una volta pubblicato, es. `https://staff.bigaloveride.it` oppure `/admin/` se lo metti in una sottocartella dello stesso dominio.

Importante: questo è solo un modo per **non esporre un link evidente**, non è una misura di sicurezza. La sicurezza vera resta il login Supabase Auth del pannello e le policy RLS del database — anche chi scopre l'URL non può leggere o modificare nulla senza credenziali staff valide.

Per nasconderlo ulteriormente ai motori di ricerca, aggiungi nella cartella del pannello un `robots.txt` con `Disallow: /` e un meta tag `<meta name="robots" content="noindex, nofollow">` nell'head di `backend/admin/index.html`.

## 7. Cosa devi ancora fare tu

- [ ] Sostituire le immagini placeholder (`picsum.photos`) con foto reali dell'evento
- [ ] Caricare il file GPX reale del percorso
- [ ] Scrivere la privacy policy e collegarla al link nel form di iscrizione
- [ ] Decidere se/come gestire il pagamento della caparra (es. Stripe, bonifico, PayPal) — non incluso in questa versione
- [ ] Personalizzare colori/font in `frontend/css/style.css` se vuoi cambiare l'identità visiva
