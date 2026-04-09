/* ============================================================
   NowNow Courier – Prototype JavaScript
   Simulates navigation and interactions without a server.
   ============================================================ */

// Simple in-memory state for the prototype
const PROTOTYPE_STATE = {
    currentUser: null,
    packages: [
        { id: 1, tracking: 'NN-20240001', recipient: 'Bob Recipient', destination: '55 Park Ave, NY', status: 'DELIVERED',  date: '10 Mar 2024' },
        { id: 2, tracking: 'NN-20240002', recipient: 'Sara Smith',     destination: '120 Wall St, NY',  status: 'IN_TRANSIT', date: '12 Mar 2024' },
        { id: 3, tracking: 'NN-20240003', recipient: 'Legal Dept',     destination: '5 Times Sq, NY',   status: 'PENDING',    date: '13 Mar 2024' },
    ],
    drivers: [
        { id: 1, name: 'Dan Deliverer', vehicle: 'MOTORBIKE', status: 'AVAILABLE', rating: 4.85, deliveries: 127 },
        { id: 2, name: 'Eve Express',   vehicle: 'CAR',       status: 'OFFLINE',   rating: 4.92, deliveries:  89 },
    ],
};

// ── Page-specific init functions ───────────────────────────
function initPage(page) {
    switch (page) {
        case 'register': initRegister(); break;
        case 'new-package': initNewPackage(); break;
    }
    initAlerts();
    initNavHighlight();
}

// ── Register: toggle driver fields, confirm password ───────
function initRegister() {
    const roles     = document.querySelectorAll('input[name="role"]');
    const driverDiv = document.getElementById('driverFields');
    const form      = document.getElementById('registerForm');
    const pwd       = document.getElementById('password');
    const confirm   = document.getElementById('confirmPassword');

    roles.forEach(r => r.addEventListener('change', () => {
        if (driverDiv) driverDiv.style.display = r.value === 'DRIVER' ? 'block' : 'none';
    }));

    if (form) {
        form.addEventListener('submit', e => {
            if (pwd && confirm && pwd.value !== confirm.value) {
                e.preventDefault();
                alert('Passwords do not match!');
            }
        });
    }
}

// ── New package: live price estimate ───────────────────────
function initNewPackage() {
    const w = document.getElementById('weight');
    const p = document.getElementById('priceDisplay');
    if (w && p) {
        w.addEventListener('input', () => {
            const kg = parseFloat(w.value) || 0;
            p.textContent = '$' + (5 + kg * 3.5).toFixed(2);
        });
    }
}

// ── Alert auto-dismiss ─────────────────────────────────────
function initAlerts() {
    document.querySelectorAll('.alert').forEach(el => {
        setTimeout(() => {
            el.style.transition = 'opacity 0.6s';
            el.style.opacity    = '0';
            setTimeout(() => el.remove(), 700);
        }, 5000);
    });
}

// ── Highlight active nav link ──────────────────────────────
function initNavHighlight() {
    const path = location.pathname.split('/').pop();
    document.querySelectorAll('.nav-links a').forEach(a => {
        if (a.href.endsWith(path)) a.classList.add('active');
    });
}

// ── Prototype status-update simulation ────────────────────
function simulateStatusUpdate(selectId, badgeId) {
    const sel   = document.getElementById(selectId);
    const badge = document.getElementById(badgeId);
    if (sel && badge) {
        sel.addEventListener('change', () => {
            badge.textContent = sel.value;
            badge.className   = 'badge badge-' + sel.value.toLowerCase().replace(' ', '_');
        });
    }
}
