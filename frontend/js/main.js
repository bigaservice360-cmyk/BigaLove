// =========================================================
// NAV MOBILE
// =========================================================
const navToggle = document.querySelector('.nav-toggle');
const navLinks = document.querySelector('.nav-links');
if (navToggle) {
  navToggle.addEventListener('click', () => navLinks.classList.toggle('open'));
}

// =========================================================
// FAQ ACCORDION
// =========================================================
function initFaqAccordion() {
  document.querySelectorAll('.faq-item .faq-q').forEach(btn => {
    btn.addEventListener('click', () => {
      const item = btn.closest('.faq-item');
      const answer = item.querySelector('.faq-a');
      const isOpen = item.classList.contains('open');
      document.querySelectorAll('.faq-item.open').forEach(i => {
        i.classList.remove('open');
        i.querySelector('.faq-a').style.maxHeight = null;
      });
      if (!isOpen) {
        item.classList.add('open');
        answer.style.maxHeight = answer.scrollHeight + 'px';
      }
    });
  });
}
initFaqAccordion();

// =========================================================
// SCORRIMENTO AUTOMATICO CAROSELLI (marquee da destra a sinistra)
// Duplica le immagini una volta per ottenere un loop continuo senza
// scatti, e mette in pausa l'animazione al passaggio del mouse.
// =========================================================
function setupCarouselMarquee() {
  document.querySelectorAll('.carousel').forEach(track => {
    if (track.classList.contains('marquee')) return;
    const items = Array.from(track.children);
    items.forEach(item => track.appendChild(item.cloneNode(true)));
    track.classList.add('marquee');
  });
}
setupCarouselMarquee();

// =========================================================
// LIGHTBOX GALLERIA — click su una foto per ingrandirla
// e scorrere le altre (frecce, tasti freccia, Escape).
// =========================================================
let lightboxEl = null;

function buildLightbox() {
  lightboxEl = document.createElement('div');
  lightboxEl.className = 'lightbox';
  lightboxEl.innerHTML = `
    <button class="lightbox-close" aria-label="Chiudi">&times;</button>
    <button class="lightbox-prev" aria-label="Foto precedente">&#8249;</button>
    <img class="lightbox-img" src="" alt="">
    <button class="lightbox-next" aria-label="Foto successiva">&#8250;</button>
    <span class="lightbox-counter"></span>
  `;
  document.body.appendChild(lightboxEl);

  lightboxEl.querySelector('.lightbox-close').addEventListener('click', closeLightbox);
  lightboxEl.addEventListener('click', (e) => { if (e.target === lightboxEl) closeLightbox(); });
  lightboxEl.querySelector('.lightbox-prev').addEventListener('click', () => navigateLightbox(-1));
  lightboxEl.querySelector('.lightbox-next').addEventListener('click', () => navigateLightbox(1));

  document.addEventListener('keydown', (e) => {
    if (!lightboxEl.classList.contains('open')) return;
    if (e.key === 'Escape') closeLightbox();
    if (e.key === 'ArrowLeft') navigateLightbox(-1);
    if (e.key === 'ArrowRight') navigateLightbox(1);
  });
}

function updateLightboxImage() {
  const img = lightboxEl.currentImgs[lightboxEl.currentIndex];
  lightboxEl.querySelector('.lightbox-img').src = img.src;
  lightboxEl.querySelector('.lightbox-img').alt = img.alt;
  lightboxEl.querySelector('.lightbox-counter').textContent =
    `${lightboxEl.currentIndex + 1} / ${lightboxEl.currentImgs.length}`;
}

function navigateLightbox(direction) {
  const total = lightboxEl.currentImgs.length;
  lightboxEl.currentIndex = (lightboxEl.currentIndex + direction + total) % total;
  updateLightboxImage();
}

function openLightbox(imgs, index) {
  if (!lightboxEl) buildLightbox();
  lightboxEl.currentImgs = imgs;
  lightboxEl.currentIndex = index;
  updateLightboxImage();
  lightboxEl.classList.add('open');
  document.body.style.overflow = 'hidden';
}

function closeLightbox() {
  lightboxEl.classList.remove('open');
  document.body.style.overflow = '';
}

function initGalleryLightbox() {
  document.querySelectorAll('.edizione-gallery').forEach(gallery => {
    const imgs = Array.from(gallery.querySelectorAll('img'));
    imgs.forEach((img, index) => {
      img.addEventListener('click', () => openLightbox(imgs, index));
    });
  });
}
initGalleryLightbox();

// =========================================================
// MAPPA (Leaflet)
// Traccia reale (andata/sosta/ritorno) esportata in
// /assets/gpx/percorso-ride.json, generata dal file KMZ
// "Indicazioni stradali da Canottieri San Cristoforo a Canottieri
// San Cristoforo". Il file KMZ originale resta in /assets/gpx/
// come riferimento.
// =========================================================
const RIDE_PUNTI_INTERESSE = [
  { nome: "Partenza / Ritorno — Canottieri San Cristoforo", lat: 45.4481782, lng: 9.1557252 },
  { nome: "Sosta — Lago Mezzetta (Bene Privato a vocazione Bene Comune)", lat: 45.4326784, lng: 9.066187 }
];

async function initGpxMap() {
  const mapEl = document.getElementById('gpx-map');
  if (!mapEl || typeof L === 'undefined') return;

  const map = L.map('gpx-map', { scrollWheelZoom: false });
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; OpenStreetMap contributors'
  }).addTo(map);

  const punti = RIDE_PUNTI_INTERESSE.map(p => L.marker([p.lat, p.lng]).addTo(map).bindPopup(p.nome));
  let tracciato = null;

  try {
    const res = await fetch('assets/gpx/percorso-ride.json');
    if (res.ok) {
      const percorso = await res.json();
      tracciato = L.polyline(percorso, { color: '#c4457a', weight: 4 }).addTo(map);
    }
  } catch (err) {
    console.error('Traccia percorso non disponibile:', err);
  }

  if (tracciato) {
    map.fitBounds(tracciato.getBounds(), { padding: [40, 40] });
  } else if (punti.length) {
    const gruppo = L.featureGroup(punti);
    map.fitBounds(gruppo.getBounds(), { padding: [40, 40] });
  } else {
    map.setView([45.4642, 9.1900], 12); // Milano
  }
}
initGpxMap();

// =========================================================
// FORM ISCRIZIONE (usato in iscriviti.html)
// =========================================================
async function handleIscrizioneSubmit(e) {
  e.preventDefault();
  const form = e.target;
  const msg = document.getElementById('form-msg');
  const submitBtn = form.querySelector('button[type=submit]');

  const payload = {
    nome: form.nome.value.trim(),
    cognome: form.cognome.value.trim(),
    email: form.email.value.trim(),
    telefono: form.telefono.value.trim(),
    citta: form.citta.value.trim(),
    codice_fiscale: form.codice_fiscale.value.trim().toUpperCase(),
    ha_bici_cargo: form.ha_bici_cargo.value === 'si',
    richiede_noleggio: form.ha_bici_cargo.value !== 'si',
    marchio_bici: form.marchio_bici && form.ha_bici_cargo.value === 'si' ? form.marchio_bici.value.trim() : null,
    modello_bici: form.modello_bici && form.ha_bici_cargo.value === 'si' ? form.modello_bici.value.trim() : null,
    privacy_accettata: form.privacy.checked
  };

  if (!payload.privacy_accettata) {
    msg.textContent = 'Devi accettare la privacy policy per iscriverti.';
    msg.className = 'form-msg err';
    return;
  }

  submitBtn.disabled = true;
  submitBtn.textContent = 'Invio in corso...';

  try {
    if (typeof supabaseClient === 'undefined') throw new Error('Supabase non configurato');
    const { error } = await supabaseClient.from('iscrizioni').insert([payload]);
    if (error) throw error;

    if (payload.richiede_noleggio) {
      const { error: erroreNoleggio } = await supabaseClient.from('richieste_noleggio').insert([{
        nome: payload.nome,
        cognome: payload.cognome,
        email: payload.email,
        telefono: payload.telefono
      }]);
      if (erroreNoleggio) throw erroreNoleggio;
    }

    msg.textContent = payload.richiede_noleggio
      ? 'Richiesta ricevuta! Ti ricontatteremo noi per parlare di modello e disponibilità della cargo bike.'
      : 'Iscrizione ricevuta! Controlla la tua email per i prossimi passi.';
    msg.className = 'form-msg ok';
    form.reset();
    form.ha_bici_cargo.dispatchEvent(new Event('change'));
  } catch (err) {
    console.error(err);
    msg.textContent = 'Qualcosa è andato storto. Riprova tra poco o scrivici via email.';
    msg.className = 'form-msg err';
    submitBtn.textContent = payload.richiede_noleggio ? 'Richiedi noleggio' : 'Conferma iscrizione';
  } finally {
    submitBtn.disabled = false;
  }
}

const iscrizioneForm = document.getElementById('iscrizione-form');
if (iscrizioneForm) iscrizioneForm.addEventListener('submit', handleIscrizioneSubmit);

// =========================================================
// ACCESSO NASCOSTO AL PANNELLO ADMIN
// 3 click ravvicinati sul copyright nel footer aprono il pannello.
// Non è una vera misura di sicurezza (quella la fa il login Supabase Auth
// + le policy RLS): serve solo a non esporre un link visibile nel sito.
// =========================================================
const ADMIN_PANEL_URL = "/admin/"; // sostituisci con l'URL reale del pannello una volta pubblicato

(function initSecretAdminTrigger() {
  const trigger = document.getElementById('secret-trigger');
  if (!trigger) return;

  let clickCount = 0;
  let resetTimer = null;
  const FINESTRA_MS = 1200; // tempo massimo tra un click e l'altro

  trigger.addEventListener('click', () => {
    clickCount += 1;
    clearTimeout(resetTimer);
    resetTimer = setTimeout(() => { clickCount = 0; }, FINESTRA_MS);

    if (clickCount >= 3) {
      clickCount = 0;
      clearTimeout(resetTimer);
      window.location.href = ADMIN_PANEL_URL;
    }
  });
})();
