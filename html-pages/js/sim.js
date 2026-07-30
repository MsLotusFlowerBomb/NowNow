/* ============================================================
   NowNow Courier – Prototype Simulation Script
   Handles form redirects and interactive demo behaviour so
   the standalone HTML pages work without a Java server.
   ============================================================ */

// ── Sample tracking data ──────────────────────────────────────
var SAMPLE_PACKAGES = {
    'NN-20240001': {
        tracking:     'NN-20240001',
        recipient:    'Bob Recipient',
        from:         '10 Broad St, New York, NY 10004',
        to:           '55 Park Ave, New York, NY 10016',
        status:       'delivered',
        statusLabel:  'DELIVERED',
        events: [
            { status: 'DELIVERED',  desc: 'Package delivered to recipient.',       time: '10 Mar 2024, 14:32', current: true  },
            { status: 'IN_TRANSIT', desc: 'Package is on its way.',               time: '10 Mar 2024, 11:05', current: false },
            { status: 'PICKED_UP',  desc: 'Driver picked up the package.',        time: '10 Mar 2024, 09:48', current: false },
            { status: 'ASSIGNED',   desc: 'Driver Dan Deliverer was assigned.',   time: '10 Mar 2024, 09:10', current: false },
            { status: 'PENDING',    desc: 'Package request submitted.',           time: '09 Mar 2024, 17:00', current: false },
        ]
    },
    'NN-20240002': {
        tracking:     'NN-20240002',
        recipient:    'Sara Smith',
        from:         '10 Broad St, New York, NY 10004',
        to:           '120 Wall St, New York, NY 10005',
        status:       'in_transit',
        statusLabel:  'IN TRANSIT',
        events: [
            { status: 'IN_TRANSIT', desc: 'Package is on its way.',               time: '12 Mar 2024, 10:20', current: true  },
            { status: 'PICKED_UP',  desc: 'Driver picked up the package.',        time: '12 Mar 2024, 09:55', current: false },
            { status: 'ASSIGNED',   desc: 'Driver Eve Express was assigned.',     time: '12 Mar 2024, 09:00', current: false },
            { status: 'PENDING',    desc: 'Package request submitted.',           time: '11 Mar 2024, 16:30', current: false },
        ]
    },
    'NN-20240003': {
        tracking:     'NN-20240003',
        recipient:    'Legal Dept',
        from:         '10 Broad St, New York, NY 10004',
        to:           '5 Times Sq, New York, NY 10036',
        status:       'pending',
        statusLabel:  'PENDING',
        events: [
            { status: 'PENDING', desc: 'Package request submitted. Awaiting driver assignment.', time: '13 Mar 2024, 08:45', current: true },
        ]
    }
};

// ── Login form ────────────────────────────────────────────────
(function attachLogin() {
    var form = document.getElementById('loginForm');
    if (!form) return;

    var routes = {
        'admin@nownow.com':  'admin-dashboard.html',
        'dan@nownow.com':    'driver-dashboard.html',
        'eve@nownow.com':    'driver-dashboard.html',
        'carol@example.com': 'customer-dashboard.html',
        'frank@example.com': 'customer-dashboard.html'
    };

    form.addEventListener('submit', function (e) {
        e.preventDefault();
        var email  = document.getElementById('email').value.trim().toLowerCase();
        var errDiv = document.getElementById('loginError');

        if (routes[email]) {
            window.location.href = routes[email];
        } else {
            if (errDiv) {
                errDiv.style.display = 'block';
                errDiv.textContent   = 'Invalid email or password. Try a demo account above.';
            }
        }
    });
}());

// ── Register form ─────────────────────────────────────────────
(function attachRegister() {
    var form = document.getElementById('registerForm');
    if (!form) return;

    form.addEventListener('submit', function (e) {
        e.preventDefault();
        var role = document.querySelector('input[name="role"]:checked');
        if (role && role.value === 'DRIVER') {
            window.location.href = 'driver-dashboard.html';
        } else {
            window.location.href = 'customer-dashboard.html';
        }
    });
}());

// ── Track form ────────────────────────────────────────────────
(function attachTrack() {
    var form   = document.getElementById('trackForm');
    var result = document.getElementById('trackResult');
    var notFound = document.getElementById('trackNotFound');
    if (!form || !result) return;

    // Pre-fill number from query string if present
    var params = new URLSearchParams(window.location.search);
    var preNum = params.get('number');
    if (preNum) {
        var inp = form.querySelector('input[name="number"]');
        if (inp) inp.value = preNum;
        doTrack(preNum);
    }

    form.addEventListener('submit', function (e) {
        e.preventDefault();
        var num = form.querySelector('input[name="number"]').value.trim().toUpperCase();
        doTrack(num);
    });

    function doTrack(num) {
        var pkg = SAMPLE_PACKAGES[num];
        result.innerHTML   = '';
        if (notFound) notFound.style.display = 'none';

        if (!pkg) {
            if (notFound) {
                notFound.style.display = 'block';
                var strong = notFound.querySelector('strong');
                if (strong) strong.textContent = num;
            }
            return;
        }

        // Build timeline HTML
        var eventsHtml = pkg.events.map(function (ev) {
            return '<div class="timeline-item' + (ev.current ? ' timeline-current' : '') + '">' +
                       '<div class="timeline-dot"></div>' +
                       '<div class="timeline-content">' +
                           '<span class="timeline-status">' + ev.status + '</span>' +
                           '<p class="timeline-desc">' + ev.desc + '</p>' +
                           '<time class="timeline-time">' + ev.time + '</time>' +
                       '</div>' +
                   '</div>';
        }).join('');

        result.innerHTML =
            '<div class="tracking-card">' +
                '<div class="tracking-header">' +
                    '<div>' +
                        '<h2>' + pkg.tracking + '</h2>' +
                        '<p class="tracking-sub">Recipient: <strong>' + pkg.recipient + '</strong></p>' +
                    '</div>' +
                    '<span class="status-badge status-' + pkg.status + '">' + pkg.statusLabel + '</span>' +
                '</div>' +
                '<div class="tracking-addresses">' +
                    '<div class="address-item"><span class="address-label">📦 From</span><span>' + pkg.from + '</span></div>' +
                    '<div class="address-arrow">→</div>' +
                    '<div class="address-item"><span class="address-label">🏠 To</span><span>' + pkg.to + '</span></div>' +
                '</div>' +
                '<h3 class="timeline-title">Tracking History</h3>' +
                '<div class="timeline">' + eventsHtml + '</div>' +
            '</div>';
    }
}());

// ── New-package form ──────────────────────────────────────────
(function attachNewPackage() {
    var form = document.getElementById('newPackageForm');
    if (!form) return;

    form.addEventListener('submit', function (e) {
        e.preventDefault();
        // Generate a fake tracking number and redirect
        var rand = Math.random().toString(36).substr(2, 8).toUpperCase();
        window.location.href = 'customer-dashboard.html?created=NN-' + rand;
    });
}());

// ── Customer dashboard: show created-package notice ───────────
(function showCreatedNotice() {
    var notice = document.getElementById('createdAlert');
    var tn     = document.getElementById('createdTracking');
    if (!notice) return;
    var params = new URLSearchParams(window.location.search);
    if (params.get('created')) {
        notice.style.display = 'block';
        if (tn) tn.textContent = params.get('created');
    }
}());
