// =========================================================
// AUTENTICAZIONE STAFF (Supabase Auth)
// Crea gli utenti staff da: Supabase Dashboard > Authentication > Users
// =========================================================
const loginScreen = document.getElementById('login-screen');
const adminApp = document.getElementById('admin-app');

async function checkSession() {
  const { data: { session } } = await supabaseClient.auth.getSession();
  if (session) {
    loginScreen.style.display = 'none';
    adminApp.style.display = 'flex';
    initAdmin();
  } else {
    loginScreen.style.display = 'flex';
    adminApp.style.display = 'none';
  }
}

document.getElementById('login-form').addEventListener('submit', async (e) => {
  e.preventDefault();
  const email = e.target.email.value.trim();
  const password = e.target.password.value;
  const errEl = document.getElementById('login-error');
  errEl.textContent = '';
  const { error } = await supabaseClient.auth.signInWithPassword({ email, password });
  if (error) { errEl.textContent = 'Credenziali non valide.'; return; }
  checkSession();
});

document.getElementById('logout-btn')?.addEventListener('click', async () => {
  await supabaseClient.auth.signOut();
  checkSession();
});

checkSession();

// =========================================================
// NAVIGAZIONE SIDEBAR (SPA semplice, senza router)
// =========================================================
function initAdmin() {
  document.querySelectorAll('.nav-item[data-view]').forEach(item => {
    item.addEventListener('click', () => switchView(item.dataset.view));
  });
  switchView('iscrizioni');
}

function switchView(viewId) {
  document.querySelectorAll('.view').forEach(v => v.classList.remove('active'));
  document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
  document.getElementById('view-' + viewId).classList.add('active');
  document.querySelector(`.nav-item[data-view="${viewId}"]`).classList.add('active');
  document.getElementById('topbar-title').textContent = document.querySelector(`.nav-item[data-view="${viewId}"]`).textContent.trim();

  const loaders = {
    dashboard: loadDashboard,
    iscrizioni: loadIscrizioni,
    noleggio: loadNoleggio
  };
  if (loaders[viewId]) loaders[viewId]();
}

// =========================================================
// DASHBOARD
// =========================================================
async function loadDashboard() {
  const el = document.getElementById('dashboard-stats');
  el.innerHTML = '<p>Caricamento...</p>';
  const [iscrizioni, noleggio] = await Promise.all([
    supabaseClient.from('iscrizioni').select('id, stato', { count: 'exact' }),
    supabaseClient.from('richieste_noleggio').select('id', { count: 'exact' })
  ]);
  const totale = iscrizioni.count ?? (iscrizioni.data?.length || 0);
  const confermate = (iscrizioni.data || []).filter(i => i.stato === 'confermata').length;
  const richiesteNoleggio = noleggio.count ?? (noleggio.data?.length || 0);

  el.innerHTML = `
    <div class="stat-cards">
      <div class="stat-card"><div class="num">${totale}</div><div class="lbl">Iscrizioni totali</div></div>
      <div class="stat-card"><div class="num">${confermate}</div><div class="lbl">Iscrizioni confermate</div></div>
      <div class="stat-card"><div class="num">${richiesteNoleggio}</div><div class="lbl">Richieste noleggio</div></div>
    </div>`;
}

// =========================================================
// ISCRIZIONI
// =========================================================
async function loadIscrizioni() {
  const tbody = document.getElementById('iscrizioni-tbody');
  tbody.innerHTML = '<tr><td colspan="7">Caricamento...</td></tr>';
  const { data, error } = await supabaseClient.from('iscrizioni').select('*').order('creato_il', { ascending: false });
  if (error) { tbody.innerHTML = `<tr><td colspan="7">Errore: ${error.message}</td></tr>`; return; }
  if (!data.length) { tbody.innerHTML = '<tr><td colspan="7">Nessuna iscrizione ancora.</td></tr>'; return; }

  tbody.innerHTML = data.map(row => `
    <tr>
      <td>${row.nome} ${row.cognome}</td>
      <td>${row.email}<br><span style="color:var(--stone)">${row.telefono}</span></td>
      <td>${row.citta}</td>
      <td>${row.ha_bici_cargo ? 'Propria' : 'Noleggio'}</td>
      <td><span class="badge ${row.stato}">${row.stato.replace('_',' ')}</span></td>
      <td>
        <select class="status-select" onchange="updateIscrizioneStato('${row.id}', this.value)">
          <option value="in_attesa" ${row.stato==='in_attesa'?'selected':''}>In attesa</option>
          <option value="confermata" ${row.stato==='confermata'?'selected':''}>Confermata</option>
          <option value="annullata" ${row.stato==='annullata'?'selected':''}>Annullata</option>
        </select>
      </td>
      <td>${new Date(row.creato_il).toLocaleDateString('it-IT')}</td>
    </tr>
  `).join('');
}

async function updateIscrizioneStato(id, stato) {
  await supabaseClient.from('iscrizioni').update({ stato }).eq('id', id);
  loadDashboard();
}

// =========================================================
// NOLEGGIO
// =========================================================
async function loadNoleggio() {
  const tbody = document.getElementById('noleggio-tbody');
  tbody.innerHTML = '<tr><td colspan="5">Caricamento...</td></tr>';
  const { data, error } = await supabaseClient.from('richieste_noleggio').select('*').order('creato_il', { ascending: false });
  if (error) { tbody.innerHTML = `<tr><td colspan="5">Errore: ${error.message}</td></tr>`; return; }
  if (!data.length) { tbody.innerHTML = '<tr><td colspan="5">Nessuna richiesta ancora.</td></tr>'; return; }
  tbody.innerHTML = data.map(row => `
    <tr>
      <td>${row.nome} ${row.cognome}</td>
      <td>${row.email}<br><span style="color:var(--stone)">${row.telefono}</span></td>
      <td>${row.modello_bici}</td>
      <td>${row.tipo_noleggio === 'rent_and_buy' ? 'Rent & Buy' : 'Classico'}</td>
      <td><span class="badge ${row.stato}">${row.stato.replace('_',' ')}</span></td>
    </tr>
  `).join('');
}
