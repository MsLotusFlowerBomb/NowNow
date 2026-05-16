<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<footer class="footer">
    <div class="footer-content">

        <div class="footer-brand">
            <span class="brand-icon">🚀</span> NowNow Courier
            <p>Fast, reliable same-day package delivery.</p>
            <!-- Social media links -->
            <div class="footer-social">
                <a href="https://www.facebook.com" target="_blank" rel="noopener" title="Facebook">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                        <path d="M18 2h-3a5 5 0 0 0-5 5v3H7v4h3v8h4v-8h3l1-4h-4V7a1 1 0 0 1 1-1h3z"/>
                    </svg>
                </a>
                <a href="https://www.twitter.com" target="_blank" rel="noopener" title="Twitter / X">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                        <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/>
                    </svg>
                </a>
                <a href="https://www.instagram.com" target="_blank" rel="noopener" title="Instagram">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <rect x="2" y="2" width="20" height="20" rx="5" ry="5"/>
                        <path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z"/>
                        <line x1="17.5" y1="6.5" x2="17.51" y2="6.5"/>
                    </svg>
                </a>
                <a href="https://www.linkedin.com" target="_blank" rel="noopener" title="LinkedIn">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                        <path d="M16 8a6 6 0 0 1 6 6v7h-4v-7a2 2 0 0 0-2-2 2 2 0 0 0-2 2v7h-4v-7a6 6 0 0 1 6-6z"/>
                        <rect x="2" y="9" width="4" height="12"/>
                        <circle cx="4" cy="4" r="2"/>
                    </svg>
                </a>
                <a href="https://www.whatsapp.com" target="_blank" rel="noopener" title="WhatsApp">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                        <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347z"/>
                        <path d="M12 0C5.373 0 0 5.373 0 12c0 2.119.554 4.107 1.523 5.837L0 24l6.335-1.502A11.956 11.956 0 0 0 12 24c6.627 0 12-5.373 12-12S18.627 0 12 0zm0 21.818a9.818 9.818 0 0 1-5.007-1.371l-.36-.214-3.727.883.936-3.618-.235-.372A9.818 9.818 0 1 1 12 21.818z"/>
                    </svg>
                </a>
            </div>
        </div>

        <div class="footer-links">
            <h4>Platform</h4>
            <a href="${pageContext.request.contextPath}/">Home</a>
            <a href="${pageContext.request.contextPath}/track">Track Package</a>
            <a href="${pageContext.request.contextPath}/register">Sign Up</a>
        </div>

        <div class="footer-links">
            <h4>Project</h4>
            <a href="#">Documentation</a>
            <a href="https://github.com/MsLotusFlowerBomb/NowNow" target="_blank" rel="noopener">GitHub</a>
        </div>

        <div class="footer-links">
            <h4>Contact</h4>
            <a href="mailto:support@nownow.com">support@nownow.com</a>
            <a href="tel:+27110001111">+27 11 000 1111</a>
            <a href="https://www.google.com/maps" target="_blank" rel="noopener">Find Us</a>
        </div>

    </div>
    <div class="footer-bottom">
        <p>&copy; 2024 NowNow Courier &mdash; University Computer Science Project</p>
    </div>
</footer>

<style>
    .footer-social {
        display: flex;
        gap: 0.8rem;
        margin-top: 1rem;
    }
    .footer-social a {
        color: rgba(255, 255, 255, 0.7);
        display: flex;
        align-items: center;
        justify-content: center;
        width: 36px;
        height: 36px;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.1);
        transition: background 0.2s, color 0.2s;
        text-decoration: none;
    }
    .footer-social a:hover {
        background: #FF6B35;
        color: #fff;
    }
</style>
