/* ============================================================
   NowNow Courier – Client-side JavaScript
   Features:
     - Driver registration field toggle
     - Registration form password confirmation
     - Live price estimate calculator
     - Auto-dismiss alerts
     - Navigation active-link highlight
   ============================================================ */

(function () {
    'use strict';

    // ── Driver fields toggle ───────────────────────────────────
    const driverRadio   = document.getElementById('driverRadio');
    const driverFields  = document.getElementById('driverFields');
    const roleRadios    = document.querySelectorAll('input[name="role"]');

    if (roleRadios.length > 0 && driverFields) {
        roleRadios.forEach(function (radio) {
            radio.addEventListener('change', function () {
                driverFields.style.display =
                    (this.value === 'DRIVER') ? 'block' : 'none';
            });
        });
    }

    // ── Registration password confirmation ─────────────────────
    const registerForm   = document.getElementById('registerForm');
    const pwdInput       = document.getElementById('password');
    const confirmPwdInput = document.getElementById('confirmPassword');

    if (registerForm && confirmPwdInput) {
        registerForm.addEventListener('submit', function (e) {
            if (pwdInput.value !== confirmPwdInput.value) {
                e.preventDefault();
                showInlineError(confirmPwdInput, 'Passwords do not match.');
            }
        });

        confirmPwdInput.addEventListener('input', function () {
            if (pwdInput.value !== this.value) {
                this.setCustomValidity('Passwords do not match.');
            } else {
                this.setCustomValidity('');
                clearInlineError(confirmPwdInput);
            }
        });
    }

    // ── Login form submission (AJAX) ───────────────────────────
    const loginForm = document.getElementById('loginForm');
    const loginError = document.getElementById('loginError');

    if (loginForm) {
        loginForm.addEventListener('submit', function (e) {
            if (!window.fetch) {
                return;
            }
            e.preventDefault();
            if (loginError) {
                loginError.textContent = '';
                loginError.hidden = true;
            }

            const formData = new FormData(loginForm);
            fetch(loginForm.action, {
                method: 'POST',
                body: formData,
                headers: {
                    'Accept': 'application/json',
                    'X-Requested-With': 'XMLHttpRequest'
                }
            })
                .then(function (response) {
                    return response.json()
                        .catch(function (err) {
                            console.warn('Login response was not JSON.', err);
                            return null;
                        })
                        .then(function (data) {
                            if (response.ok) {
                                if (data && data.redirectUrl) {
                                    window.location.assign(data.redirectUrl);
                                } else {
                                    window.location.reload();
                                }
                                return;
                            }
                            showLoginError(loginError, data && data.error
                                ? data.error
                                : 'Login failed. Please try again.');
                        });
                })
                .catch(function () {
                    showLoginError(loginError, 'Login failed. Please try again.');
                });
        });
    }

    // ── Live price estimate on new-package form ────────────────
    const weightInput  = document.getElementById('weight');
    const priceDisplay = document.getElementById('priceDisplay');

    if (weightInput && priceDisplay) {
        function updatePrice() {
            var weight = parseFloat(weightInput.value) || 0;
            var price  = 5.0 + weight * 3.5;
            priceDisplay.textContent = 'R' + price.toFixed(2);
        }
        weightInput.addEventListener('input', updatePrice);
        updatePrice();
    }

    // ── Auto-dismiss alerts after 6 seconds ───────────────────
    document.querySelectorAll('.alert').forEach(function (el) {
        setTimeout(function () {
            el.style.transition = 'opacity 0.6s';
            el.style.opacity    = '0';
            setTimeout(function () { el.remove(); }, 700);
        }, 6000);
    });

    // ── Active nav-link highlight ──────────────────────────────
    var currentPath = window.location.pathname;
    document.querySelectorAll('.nav-links a').forEach(function (link) {
        if (link.href && link.pathname === currentPath) {
            link.style.color = 'var(--color-primary)';
            link.style.fontWeight = '700';
        }
    });

    // ── Confirm before delivery status change ──────────────────
    document.querySelectorAll('.inline-form button').forEach(function (btn) {
        btn.addEventListener('click', function (e) {
            var action = btn.closest('form').querySelector('input[name="action"]');
            if (action && action.value === 'fail') {
                if (!confirm('Mark this delivery as FAILED? This cannot be undone.')) {
                    e.preventDefault();
                }
            }
        });
    });

    // ── Helpers ───────────────────────────────────────────────
    function showInlineError(input, message) {
        clearInlineError(input);
        var err = document.createElement('span');
        err.className = 'field-error';
        err.style.cssText = 'color:#c0392b;font-size:0.82rem;margin-top:2px';
        err.textContent = message;
        input.parentNode.appendChild(err);
        input.style.borderColor = '#c0392b';
    }

    function clearInlineError(input) {
        var existing = input.parentNode.querySelector('.field-error');
        if (existing) existing.remove();
        input.style.borderColor = '';
    }

    function showLoginError(container, message) {
        if (!container) return;
        container.textContent = message;
        container.hidden = false;
    }

})();
