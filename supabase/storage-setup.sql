<!DOCTYPE html>
<html lang="it">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="robots" content="noindex, nofollow">
<title>BigaLove Ride — Pannello di gestione</title>
<link rel="stylesheet" href="css/admin.css">
</head>
<body>

<!-- LOGIN -->
<div id="login-screen" class="login-screen">
  <div class="login-card">
    <h2>♥ BigaLove Admin</h2>
    <p style="font-size:13px;color:var(--stone);">Accedi con le credenziali staff per gestire il sito.</p>
    <form id="login-form">
      <label for="email">Email</label>
      <input type="email" id="email" name="email" required style="margin-bottom:12px;">
      <label for="password">Password</label>
      <input type="password" id="password" name="password" required style="margin-bottom:12px;">
      <button type="submit" class="btn">Accedi</button>
      <p id="login-error" style="color:var(--danger); font-size:13px; margin-top:10px;"></p>
    </form>
    <p class="hint">Gli account staff si creano da Supabase Dashboard → Authentication → Users. Nessuna auto-registrazione pubblica.</p>
  </div>
</div>

<!-- APP ADMIN -->
<div id="admin-app" style="display:none; width:100%;">
  <aside class="admin-sidebar">
    <div class="admin-logo"><span class="heart">♥</span> BigaLove Admin</div>

    <div class="nav-item active" data-view="dashboard"><span class="dot"></span> Dashboard</div>

    <div class="sidebar-section-label">Iscrizioni</div>
    <div class="nav-item" data-view="iscrizioni"><span class="dot"></span> Iscrizioni ride</div>
    <div class="nav-item" data-view="noleggio"><span class="dot"></span> Richieste noleggio</div>

    <div class="sidebar-section-label">Contenuti sito</div>
    <div class="nav-item" data-view="contenuti"><span class="dot"></span> Homepage (drag&nbsp;&amp;&nbsp;drop)</div>
    <div class="nav-item" data-view="galleria"><span class="dot"></span> Galleria immagini</div>
    <div class="nav-item" data-view="edizioni"><span class="dot"></span> Edizioni precedenti</div>
    <div class="nav-item" data-view="faq"><span class="dot"></span> FAQ</div>

    <div style="margin-top:auto; padding-top:20px;">
      <div class="nav-item" id="logout-btn"><span class="dot"></span> Esci</div>
    </div>
  </aside>

  <main class="admin-main">
    <div class="admin-topbar"><h1 id="topbar-title">Dashboard</h1></div>
    <div class="admin-content">

      <!-- DASHBOARD -->
      <section id="view-dashboard" class="view active">
        <div id="dashboard-stats"></div>
        <div class="card">
          <h3>Come funziona questo pannello</h3>
          <p style="font-size:13px;color:var(--stone);">
            Ogni sezione a sinistra corrisponde a una parte del sito pubblico. In "Homepage" puoi riordinare
            i blocchi della pagina trascinandoli (drag&nbsp;&amp;&nbsp;drop) e modificarne il contenuto: il sito
            pubblico si aggiorna automaticamente perché legge gli stessi dati da Supabase.
          </p>
        </div>
      </section>

      <!-- ISCRIZIONI -->
      <section id="view-iscrizioni" class="view">
        <div class="card">
          <div class="card-head"><h3>Iscrizioni alla ride</h3></div>
          <table>
            <thead><tr><th>Nome</th><th>Contatti</th><th>Città</th><th>Bici</th><th>Stato</th><th>Aggiorna</th><th>Data</th></tr></thead>
            <tbody id="iscrizioni-tbody"></tbody>
          </table>
        </div>
      </section>

      <!-- NOLEGGIO -->
      <section id="view-noleggio" class="view">
        <div class="card">
          <div class="card-head"><h3>Richieste di noleggio</h3></div>
          <table>
            <thead><tr><th>Nome</th><th>Contatti</th><th>Modello</th><th>Tipo</th><th>Stato</th></tr></thead>
            <tbody id="noleggio-tbody"></tbody>
          </table>
        </div>
      </section>

      <!-- CONTENUTI HOME — DRAG & DROP -->
      <section id="view-contenuti" class="view">
        <div class="card">
          <div class="card-head">
            <h3>Blocchi della Homepage</h3>
            <span style="font-size:12px;color:var(--stone);">Trascina per riordinare</span>
          </div>
          <div id="block-list" class="block-list"></div>
        </div>
        <div class="card">
          <h3>Aggiungi un blocco</h3>
          <p style="font-size:13px;color:var(--stone);">Scegli un modello preimpostato: verrà aggiunto in fondo alla pagina, pronto da modificare.</p>
          <div id="template-picker" class="template-picker"></div>
        </div>
      </section>

      <!-- GALLERIA -->
      <section id="view-galleria" class="view">
        <div class="card">
          <h3>Aggiungi immagine</h3>
          <form id="galleria-form">
            <div class="form-grid">
              <div>
                <label for="g-categoria">Categoria</label>
                <select id="g-categoria" name="categoria">
                  <option value="home">Carosello home</option>
                  <option value="edizione_precedente">Edizione precedente</option>
                </select>
              </div>
              <div>
                <label for="g-url">URL immagine</label>
                <input type="text" id="g-url" name="url_immagine" required placeholder="https://...">
                <label for="g-file" class="upload-btn" style="margin-top:6px;">
                  <span>Oppure carica un file dal computer</span>
                </label>
                <input type="file" id="g-file" accept="image/*" style="display:none">
              </div>
            </div>
            <div class="form-grid full" style="margin-top:14px;">
              <div>
                <label for="g-didascalia">Didascalia (alt text)</label>
                <input type="text" id="g-didascalia" name="didascalia">
              </div>
            </div>
            <button type="submit" class="btn" style="margin-top:14px;">Aggiungi alla galleria</button>
          </form>
        </div>
        <div class="card">
          <h3>Immagini caricate</h3>
          <table>
            <thead><tr><th>Anteprima</th><th>Categoria</th><th>Didascalia</th><th></th></tr></thead>
            <tbody id="galleria-tbody"></tbody>
          </table>
        </div>
      </section>

      <!-- EDIZIONI PRECEDENTI -->
      <section id="view-edizioni" class="view">
        <div class="card">
          <h3>Aggiungi edizione</h3>
          <form id="edizioni-form">
            <div class="form-grid">
              <div><label for="e-anno">Anno</label><input type="number" id="e-anno" name="anno" required></div>
              <div><label for="e-titolo">Titolo</label><input type="text" id="e-titolo" name="titolo" required></div>
            </div>
            <div class="form-grid" style="margin-top:14px;">
              <div><label for="e-partecipanti">Partecipanti</label><input type="number" id="e-partecipanti" name="partecipanti"></div>
              <div><label for="e-km">Km percorsi</label><input type="number" step="0.1" id="e-km" name="km_percorsi"></div>
            </div>
            <div class="form-grid full" style="margin-top:14px;">
              <div><label for="e-copertina">URL copertina</label><input type="text" id="e-copertina" name="copertina_url" placeholder="https://..."></div>
            </div>
            <div class="form-grid full" style="margin-top:14px;">
              <div><label for="e-descrizione">Descrizione</label><textarea id="e-descrizione" name="descrizione" rows="3"></textarea></div>
            </div>
            <button type="submit" class="btn" style="margin-top:14px;">Aggiungi edizione</button>
          </form>
        </div>
        <div class="card">
          <h3>Edizioni pubblicate</h3>
          <table>
            <thead><tr><th>Anno</th><th>Titolo</th><th>Partecipanti</th><th>Km</th><th></th></tr></thead>
            <tbody id="edizioni-tbody"></tbody>
          </table>
        </div>
      </section>

      <!-- FAQ -->
      <section id="view-faq" class="view">
        <div class="card">
          <h3>Aggiungi FAQ</h3>
          <form id="faq-form">
            <div class="form-grid full">
              <div><label for="f-domanda">Domanda</label><input type="text" id="f-domanda" name="domanda" required></div>
            </div>
            <div class="form-grid full" style="margin-top:14px;">
              <div><label for="f-risposta">Risposta</label><textarea id="f-risposta" name="risposta" rows="3" required></textarea></div>
            </div>
            <button type="submit" class="btn" style="margin-top:14px;">Aggiungi FAQ</button>
          </form>
        </div>
        <div class="card">
          <h3>FAQ pubblicate</h3>
          <table>
            <thead><tr><th>Domanda</th><th>Risposta</th><th></th></tr></thead>
            <tbody id="faq-tbody"></tbody>
          </table>
        </div>
      </section>

    </div>
  </main>
</div>

<script src="https://unpkg.com/@supabase/supabase-js@2"></script>
<script src="https://cdn.jsdelivr.net/npm/sortablejs@1.15.0/Sortable.min.js"></script>
<script src="js/supabase-client.js"></script>
<script src="js/admin.js"></script>
</body>
</html>