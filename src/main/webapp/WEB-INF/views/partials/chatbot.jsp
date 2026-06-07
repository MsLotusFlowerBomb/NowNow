<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%-- NowNow AI Chat Widget — include this in footer.jsp --%>

<div id="nn-chat-root">

  <%-- Chat panel (hidden by default) --%>
  <div id="nn-chat-panel" aria-live="polite" aria-label="NowNow AI Assistant">
    <div id="nn-chat-header">
      <div id="nn-chat-header-info">
        <span id="nn-chat-avatar">🤖</span>
        <div>
          <div id="nn-chat-title">NowNow Assistant</div>
          <div id="nn-chat-status">● Online</div>
        </div>
      </div>
      <button id="nn-chat-close" aria-label="Close chat">✕</button>
    </div>

    <div id="nn-chat-messages">
      <div class="nn-msg nn-bot">
        <div class="nn-bubble">
          👋 Hi! I'm the NowNow assistant.<br>
          Ask me about your packages, statuses, or how to use the platform.
        </div>
      </div>
    </div>

    <div id="nn-chat-footer">
      <textarea id="nn-chat-input"
                placeholder="Type a message…"
                rows="1"
                aria-label="Chat message input"></textarea>
      <button id="nn-chat-send" aria-label="Send message">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
             stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
          <line x1="22" y1="2" x2="11" y2="13"/>
          <polygon points="22 2 15 22 11 13 2 9 22 2"/>
        </svg>
      </button>
    </div>
  </div>

  <%-- Floating toggle button --%>
  <button id="nn-chat-fab" aria-label="Open AI assistant" title="NowNow Assistant">
    <span id="nn-fab-open">🤖</span>
    <span id="nn-fab-close" style="display:none">✕</span>
  </button>

</div>

<style>
/* ── Root / positioning ───────────────────────────────────────── */
#nn-chat-root {
  position: fixed;
  bottom: 1.75rem;
  right: 1.75rem;
  z-index: 10000;
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: .75rem;
  font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
}

/* ── FAB button ───────────────────────────────────────────────── */
#nn-chat-fab {
  width: 58px; height: 58px;
  border-radius: 50%;
  background: #FF6B35;
  color: #fff;
  border: none;
  font-size: 1.45rem;
  cursor: pointer;
  box-shadow: 0 6px 24px rgba(255,107,53,.45);
  transition: transform .2s ease, background .2s ease, box-shadow .2s ease;
  display: flex; align-items: center; justify-content: center;
}
#nn-chat-fab:hover {
  background: #E55C28;
  transform: scale(1.08);
  box-shadow: 0 8px 28px rgba(255,107,53,.55);
}
#nn-chat-fab:active { transform: scale(.97); }

/* ── Panel ────────────────────────────────────────────────────── */
#nn-chat-panel {
  width: 340px;
  max-height: 480px;
  background: #fff;
  border-radius: 16px;
  box-shadow: 0 12px 48px rgba(0,0,0,.18);
  border: 1px solid #e0e0e0;
  display: none;           /* toggled via JS */
  flex-direction: column;
  overflow: hidden;
  transform-origin: bottom right;
  animation: nn-pop-in .22s ease;
}
@keyframes nn-pop-in {
  from { opacity:0; transform: scale(.88) translateY(8px); }
  to   { opacity:1; transform: scale(1)  translateY(0); }
}

/* ── Header ───────────────────────────────────────────────────── */
#nn-chat-header {
  background: #2C3E50;
  padding: .8rem 1rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-shrink: 0;
}
#nn-chat-header-info { display: flex; align-items: center; gap: .65rem; }
#nn-chat-avatar {
  font-size: 1.5rem;
  width: 36px; height: 36px;
  background: rgba(255,255,255,.1);
  border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
}
#nn-chat-title { color: #fff; font-weight: 700; font-size: .9rem; }
#nn-chat-status { color: #4CAF50; font-size: .72rem; margin-top: 1px; }
#nn-chat-close {
  background: none; border: none;
  color: rgba(255,255,255,.6); cursor: pointer;
  font-size: 1rem; line-height: 1; padding: 4px;
  border-radius: 4px; transition: color .15s, background .15s;
}
#nn-chat-close:hover { color: #fff; background: rgba(255,255,255,.1); }

/* ── Messages area ────────────────────────────────────────────── */
#nn-chat-messages {
  flex: 1;
  overflow-y: auto;
  padding: .9rem;
  display: flex;
  flex-direction: column;
  gap: .55rem;
  scroll-behavior: smooth;
}
#nn-chat-messages::-webkit-scrollbar { width: 4px; }
#nn-chat-messages::-webkit-scrollbar-thumb { background: #e0e0e0; border-radius: 4px; }

/* ── Message rows ─────────────────────────────────────────────── */
.nn-msg { display: flex; max-width: 100%; }
.nn-bot  { justify-content: flex-start; }
.nn-user { justify-content: flex-end; }

.nn-bubble {
  max-width: 82%;
  padding: .55rem .85rem;
  border-radius: 14px;
  font-size: .86rem;
  line-height: 1.55;
  white-space: pre-wrap;
  word-break: break-word;
}
.nn-bot  .nn-bubble {
  background: #F0F2F5;
  color: #2C3E50;
  border-bottom-left-radius: 4px;
}
.nn-user .nn-bubble {
  background: #FF6B35;
  color: #fff;
  border-bottom-right-radius: 4px;
}

/* ── Typing indicator ─────────────────────────────────────────── */
.nn-typing-bubble {
  display: inline-flex; align-items: center; gap: 4px;
  padding: .6rem .9rem;
  background: #F0F2F5;
  border-radius: 14px;
  border-bottom-left-radius: 4px;
}
.nn-dot {
  width: 7px; height: 7px;
  background: #ADB5BD;
  border-radius: 50%;
  animation: nn-bounce .9s infinite ease-in-out;
}
.nn-dot:nth-child(2) { animation-delay: .18s; }
.nn-dot:nth-child(3) { animation-delay: .36s; }
@keyframes nn-bounce {
  0%,60%,100% { transform: translateY(0); }
  30%          { transform: translateY(-5px); }
}

/* ── Footer / input ───────────────────────────────────────────── */
#nn-chat-footer {
  display: flex;
  align-items: flex-end;
  gap: .45rem;
  padding: .65rem .75rem;
  border-top: 1px solid #E9ECEF;
  flex-shrink: 0;
}
#nn-chat-input {
  flex: 1;
  padding: .55rem .75rem;
  border: 1.5px solid #E0E0E0;
  border-radius: 10px;
  font-size: .88rem;
  font-family: inherit;
  resize: none;
  outline: none;
  max-height: 100px;
  overflow-y: auto;
  line-height: 1.4;
  transition: border-color .2s, box-shadow .2s;
}
#nn-chat-input:focus {
  border-color: #FF6B35;
  box-shadow: 0 0 0 3px rgba(255,107,53,.15);
}
#nn-chat-send {
  width: 36px; height: 36px; min-width: 36px;
  background: #FF6B35;
  color: #fff;
  border: none;
  border-radius: 10px;
  cursor: pointer;
  display: flex; align-items: center; justify-content: center;
  transition: background .2s, transform .1s;
  flex-shrink: 0;
}
#nn-chat-send:hover  { background: #E55C28; }
#nn-chat-send:active { transform: scale(.93); }
#nn-chat-send:disabled { background: #ADB5BD; cursor: not-allowed; }

/* ── Responsive: shrink on small screens ──────────────────────── */
@media (max-width: 420px) {
  #nn-chat-root { bottom: 1rem; right: 1rem; }
  #nn-chat-panel { width: calc(100vw - 2rem); max-height: 420px; }
}
</style>

<script>
(function () {
  'use strict';

  var panel    = document.getElementById('nn-chat-panel');
  var fab      = document.getElementById('nn-chat-fab');
  var fabOpen  = document.getElementById('nn-fab-open');
  var fabClose = document.getElementById('nn-fab-close');
  var closeBtn = document.getElementById('nn-chat-close');
  var input    = document.getElementById('nn-chat-input');
  var sendBtn  = document.getElementById('nn-chat-send');
  var msgArea  = document.getElementById('nn-chat-messages');
  var ctx      = '${pageContext.request.contextPath}';

  // Conversation history sent to the server for context
  var history  = [];

  // ── Open / close ────────────────────────────────────────────
  function openPanel() {
    panel.style.display = 'flex';
    fabOpen.style.display  = 'none';
    fabClose.style.display = '';
    input.focus();
  }
  function closePanel() {
    panel.style.display = 'none';
    fabOpen.style.display  = '';
    fabClose.style.display = 'none';
  }

  fab.addEventListener('click', function () {
    panel.style.display === 'none' ? openPanel() : closePanel();
  });
  closeBtn.addEventListener('click', closePanel);

  // ── Auto-resize textarea ─────────────────────────────────────
  input.addEventListener('input', function () {
    this.style.height = 'auto';
    this.style.height = Math.min(this.scrollHeight, 100) + 'px';
  });

  // ── Send on Enter (Shift+Enter = newline) ────────────────────
  input.addEventListener('keydown', function (e) {
    if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); sendMessage(); }
  });
  sendBtn.addEventListener('click', sendMessage);

// ── Add a message bubble ─────────────────────────────────────
  function addBubble(text, who) {
    var row = document.createElement('div');
    row.className = 'nn-msg nn-' + who;
    var bubble = document.createElement('div');
    bubble.className = 'nn-bubble';
    
    // 1. Escape HTML to prevent XSS attacks (security first)
    var safeText = text.replace(/</g, "&lt;").replace(/>/g, "&gt;");
    
    // 2. Parse Markdown Bold (**text** becomes <strong>text</strong>)
    safeText = safeText.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
    
    // 3. Parse Markdown Italics (*text* or _text_ becomes <em>text</em>)
    safeText = safeText.replace(/(?:^|[^\w])(?:[*_])(.*?)(?:[*_])(?:$|[^\w])/g, ' <em>$1</em> ');
    
    // 4. Parse your custom /login and /register links
    safeText = safeText.replace(/(\/login|\/register)/g, '<a href="' + ctx + '$1" style="color:inherit; text-decoration:underline; font-weight:bold;">$1</a>');
    
    // Inject the formatted HTML into the bubble
    bubble.innerHTML = safeText; 
    
    row.appendChild(bubble);
    msgArea.appendChild(row);
    
    // Auto-scroll to the bottom
    msgArea.scrollTop = msgArea.scrollHeight;
    
    return row;
  }

  // ── Typing indicator ─────────────────────────────────────────
  function addTyping() {
    var row = document.createElement('div');
    row.className = 'nn-msg nn-bot';
    row.innerHTML =
      '<div class="nn-typing-bubble">' +
        '<span class="nn-dot"></span>' +
        '<span class="nn-dot"></span>' +
        '<span class="nn-dot"></span>' +
      '</div>';
    msgArea.appendChild(row);
    msgArea.scrollTop = msgArea.scrollHeight;
    return row;
  }

  // ── Main send flow ────────────────────────────────────────────
  function sendMessage() {
    var text = input.value.trim();
    if (!text || sendBtn.disabled) return;

    // Reset input
    input.value = '';
    input.style.height = 'auto';
    sendBtn.disabled = true;

    // Show user bubble
    addBubble(text, 'user');

    // Push to history BEFORE sending (server needs previous turns, not current)
    var historySnapshot = history.slice();   // copy for this request
    history.push({ role: 'user', content: text });

    var typingEl = addTyping();

    fetch(ctx + '/chatbot', {
      method:  'POST',
      headers: { 'Content-Type': 'application/json' },
      body:    JSON.stringify({ message: text, history: historySnapshot })
    })
    .then(function (r) { return r.json(); })
    .then(function (data) {
      typingEl.remove();
      if (data.reply) {
        addBubble(data.reply, 'bot');
        history.push({ role: 'assistant', content: data.reply });
      } else {
        addBubble(data.error || 'Something went wrong. Please try again.', 'bot');
        history.pop(); // remove the unanswered user message
      }
    })
    .catch(function () {
      typingEl.remove();
      addBubble('Connection error. Check your network and try again.', 'bot');
      history.pop();
    })
    .finally(function () {
      sendBtn.disabled = false;
      input.focus();
    });
  }

})();
</script>
