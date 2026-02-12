const byId = (id) => document.getElementById(id);

const setText = (id, value, fallback = '-') => {
  const el = byId(id);
  if (!el) return;
  if (value === null || value === undefined || value === '') {
    el.textContent = fallback;
  } else {
    el.textContent = value;
  }
};

const setHtml = (id, html) => {
  const el = byId(id);
  if (el) el.innerHTML = html;
};

const jsonRequest = async (url, options = {}) => {
  const res = await fetch(url, {
    headers: { 'Content-Type': 'application/json', ...(options.headers || {}) },
    ...options
  });

  if (!res.ok) {
    const text = await res.text();
    const error = new Error(text || res.statusText || '요청 실패');
    error.status = res.status;
    throw error;
  }

  if (res.status === 204) return null;
  const contentType = res.headers.get('content-type') || '';
  if (contentType.includes('application/json')) {
    return res.json();
  }
  return res.text();
};

const getJson = (url) => jsonRequest(url, { method: 'GET' });
const postJson = (url, payload) => jsonRequest(url, { method: 'POST', body: JSON.stringify(payload) });
const putJson = (url, payload) => jsonRequest(url, { method: 'PUT', body: JSON.stringify(payload) });

const startOfDay = (date) => new Date(date.getFullYear(), date.getMonth(), date.getDate());

const calcDaysLeft = (dateStr) => {
  if (!dateStr) return null;
  const expires = new Date(dateStr);
  if (Number.isNaN(expires.getTime())) return null;
  return Math.floor((startOfDay(expires) - startOfDay(new Date())) / 86400000);
};

const createModal = ({ title = '', message = '' }) => {
  const backdrop = document.createElement('div');
  backdrop.className = 'ui-modal-backdrop';
  backdrop.innerHTML = `
    <div class="ui-modal" role="dialog" aria-modal="true">
      <div class="ui-modal-title">${title}</div>
      <div class="ui-modal-message">${message}</div>
      <div class="ui-modal-body"></div>
      <div class="ui-modal-actions"></div>
    </div>
  `;
  document.body.appendChild(backdrop);
  return {
    backdrop,
    modal: backdrop.querySelector('.ui-modal'),
    body: backdrop.querySelector('.ui-modal-body'),
    actions: backdrop.querySelector('.ui-modal-actions'),
    close: () => backdrop.remove()
  };
};

const uiAlert = (message, options = {}) => new Promise((resolve) => {
  const ui = createModal({ title: options.title || '알림', message });
  const okBtn = document.createElement('button');
  okBtn.className = 'btn primary';
  okBtn.type = 'button';
  okBtn.textContent = options.okText || '확인';
  okBtn.addEventListener('click', () => {
    ui.close();
    resolve();
  });
  ui.actions.appendChild(okBtn);
  okBtn.focus();
});

const uiConfirm = (message, options = {}) => new Promise((resolve) => {
  const ui = createModal({ title: options.title || '확인', message });
  const cancelBtn = document.createElement('button');
  cancelBtn.className = 'btn';
  cancelBtn.type = 'button';
  cancelBtn.textContent = options.cancelText || '취소';
  cancelBtn.addEventListener('click', () => {
    ui.close();
    resolve(false);
  });

  const okBtn = document.createElement('button');
  okBtn.className = 'btn primary';
  okBtn.type = 'button';
  okBtn.textContent = options.okText || '확인';
  okBtn.addEventListener('click', () => {
    ui.close();
    resolve(true);
  });

  ui.actions.append(cancelBtn, okBtn);
  okBtn.focus();
});

const uiPrompt = (options = {}) => new Promise((resolve) => {
  const ui = createModal({
    title: options.title || '입력',
    message: options.message || ''
  });

  const wrapper = document.createElement('div');
  wrapper.className = 'ui-modal-field';
  wrapper.innerHTML = `
    ${options.label ? `<label>${options.label}</label>` : ''}
    <input type="text" />
  `;
  const input = wrapper.querySelector('input');
  input.value = options.defaultValue || '';
  if (options.placeholder) input.placeholder = options.placeholder;
  ui.body.appendChild(wrapper);

  const cancelBtn = document.createElement('button');
  cancelBtn.className = 'btn';
  cancelBtn.type = 'button';
  cancelBtn.textContent = options.cancelText || '취소';
  cancelBtn.addEventListener('click', () => {
    ui.close();
    resolve(null);
  });

  const okBtn = document.createElement('button');
  okBtn.className = 'btn primary';
  okBtn.type = 'button';
  okBtn.textContent = options.okText || '확인';
  okBtn.addEventListener('click', () => {
    const value = (input.value || '').trim();
    ui.close();
    resolve(value);
  });

  input.addEventListener('keydown', (event) => {
    if (event.key !== 'Enter') return;
    event.preventDefault();
    okBtn.click();
  });

  ui.actions.append(cancelBtn, okBtn);
  input.focus();
});
