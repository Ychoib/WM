<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<!doctype html>
<html lang="ko">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>파트 문서</title>
    <link rel="stylesheet" href="/css/common.css" />
    <style>
      .part-card {
        cursor: pointer;
        transition: border-color .16s ease, transform .16s ease, box-shadow .16s ease;
      }
      .part-card:hover {
        transform: translateY(-1px);
        border-color: rgba(57, 194, 255, 0.45);
      }
      .part-card.active {
        border-color: rgba(57, 194, 255, 0.75);
        box-shadow: 0 0 0 2px rgba(57, 194, 255, 0.18) inset;
      }
      .doc-row {
        cursor: pointer;
      }
      .doc-row:hover {
        background: rgba(57, 194, 255, 0.08);
      }
      .doc-row.active {
        background: rgba(57, 194, 255, 0.13);
      }
      .upload-grid {
        display: grid;
        grid-template-columns: 1.1fr 1.2fr 1.8fr 1fr;
        gap: 10px;
      }
      .preview-box {
        margin-top: 12px;
        border: 1px solid var(--stroke);
        border-radius: 12px;
        padding: 12px;
        background: rgba(255, 255, 255, 0.02);
      }
      .preview-title {
        font-size: 14px;
        font-weight: 700;
      }
      .preview-meta {
        color: var(--muted);
        font-size: 12px;
        margin-top: 4px;
      }
      .preview-frame {
        margin-top: 10px;
        width: 100%;
        height: 540px;
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-radius: 10px;
        background: #0d1324;
      }
      .preview-img-wrap {
        margin-top: 10px;
        text-align: center;
      }
      .preview-img {
        max-width: 100%;
        max-height: 520px;
        border-radius: 10px;
        border: 1px solid rgba(255, 255, 255, 0.1);
      }
      @media (max-width: 980px) {
        .upload-grid { grid-template-columns: 1fr; }
        .preview-frame { height: 420px; }
      }
    </style>
  </head>
  <body>
    <div class="page">
      <div class="topbar">
        <div class="brand">
          <div class="logo" aria-hidden="true"></div>
          <div>
            <h1>파트 문서</h1>
            <div class="subtitle">파트별 문서를 업로드하고 미리보기로 확인합니다.</div>
          </div>
        </div>
        <div class="cta">
          <a class="btn" href="/">메인</a>
          <a class="btn" href="/parts">파트 관리</a>
          <a class="btn" href="/org">조직도 관리</a>
          <a class="btn primary" href="/docs">파트 문서</a>
        </div>
      </div>

      <div class="grid cols-12">
        <div class="card" style="grid-column: span 12;">
          <div class="section-title">
            <h2>파트 선택</h2>
            <span class="tag">마스터 연동</span>
          </div>
          <div class="mini-grid" id="part-grid">
            <div class="cell">
              <div class="label">로딩 중...</div>
              <div class="value">-</div>
            </div>
          </div>
        </div>

        <div class="card" style="grid-column: span 12;">
          <div class="section-title">
            <h2>선택된 파트 문서</h2>
            <span class="tag" id="selected-part-tag">미선택</span>
          </div>

          <form class="form" id="upload-form">
            <div class="upload-grid">
              <div>
                <label for="docType">문서 유형</label>
                <select id="docType" required>
                  <option>인수인계서</option>
                  <option>운영 매뉴얼</option>
                  <option>장애 대응</option>
                  <option>기타</option>
                </select>
              </div>
              <div>
                <label for="docTitle">문서명</label>
                <input id="docTitle" placeholder="비워두면 파일명 사용" />
              </div>
              <div>
                <label for="docFile">문서 파일</label>
                <input id="docFile" type="file" accept=".pdf,.txt,.md,.jpg,.jpeg,.png,.webp" required />
              </div>
              <div class="actions" style="margin-top: 22px;">
                <button class="btn primary" type="submit">업로드</button>
              </div>
            </div>
            <div class="hint">허용 형식: pdf, txt, md, jpg, jpeg, png, webp</div>
          </form>

          <table class="table">
            <thead>
              <tr>
                <th>문서 유형</th>
                <th>문서명</th>
                <th>파일명</th>
                <th>업로드일</th>
              </tr>
            </thead>
            <tbody id="docs-body">
              <tr>
                <td colspan="4" class="empty">파트를 선택해주세요.</td>
              </tr>
            </tbody>
          </table>

          <div class="preview-box" id="doc-preview">
            <div class="preview-title">미리보기</div>
            <div class="preview-meta">문서를 선택해주세요.</div>
            <div class="preview-body"></div>
          </div>
        </div>
      </div>
    </div>

    <script src="/js/common.js"></script>
    <script>
      const state = {
        parts: [],
        docs: [],
        selectedPartId: null,
        selectedDocId: null
      };

      const escapeHtml = (value) => String(value ?? '')
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');

      const getExt = (name) => {
        const fileName = String(name || '');
        const idx = fileName.lastIndexOf('.');
        if (idx < 0 || idx === fileName.length - 1) return '';
        return fileName.substring(idx + 1).toLowerCase();
      };

      const isPreviewable = (ext) => ['pdf', 'txt', 'md', 'jpg', 'jpeg', 'png', 'webp'].includes(ext);

      const renderPreview = () => {
        const selectedPart = state.parts.find(p => p.id === state.selectedPartId);
        const doc = state.docs.find(d => d.id === state.selectedDocId);
        const preview = byId('doc-preview');
        if (!preview) return;
        if (!selectedPart || !doc) {
          preview.innerHTML = `
            <div class="preview-title">미리보기</div>
            <div class="preview-meta">문서를 선택해주세요.</div>
            <div class="preview-body"></div>
          `;
          return;
        }
        const ext = (doc.fileExt || getExt(doc.originalFileName)).toLowerCase();
        const src = `/api/part-docs/${doc.id}/content`;
        const previewBody = (() => {
          if (!isPreviewable(ext)) {
            return `<div class="preview-body">미리보기를 지원하지 않는 형식입니다.</div>`;
          }
          if (['jpg', 'jpeg', 'png', 'webp'].includes(ext)) {
            return `<div class="preview-img-wrap"><img class="preview-img" src="${src}" alt="${escapeHtml(doc.title)}" /></div>`;
          }
          return `<iframe class="preview-frame" src="${src}" title="문서 미리보기"></iframe>`;
        })();

        preview.innerHTML = `
          <div class="preview-title">${escapeHtml(selectedPart.name)} - ${escapeHtml(doc.title)}</div>
          <div class="preview-meta">${escapeHtml(doc.docType)} · ${escapeHtml(doc.createdAt || '-')}</div>
          <div class="cta" style="margin-top: 8px;">
            <a class="btn" href="${src}" target="_blank">새 창으로 열기</a>
          </div>
          ${previewBody}
        `;
      };

      const bindDocActions = () => {
        document.querySelectorAll('.doc-row').forEach(row => {
          row.addEventListener('click', () => {
            state.selectedDocId = Number(row.dataset.id || 0) || null;
            renderDocs();
            renderPreview();
          });
        });
      };

      const loadDocs = async () => {
        if (!state.selectedPartId) {
          state.docs = [];
          renderDocs();
          return;
        }
        try {
          const data = await getJson(`/api/part-docs?partId=${state.selectedPartId}`);
          state.docs = data || [];
          state.selectedDocId = state.docs[0]?.id || null;
          renderDocs();
        } catch (error) {
          state.docs = [];
          state.selectedDocId = null;
          setHtml('docs-body', `<tr><td colspan="4" class="empty">조회 실패: ${escapeHtml(error.message)}</td></tr>`);
          renderPreview();
        }
      };

      const renderDocs = () => {
        const selected = state.parts.find(p => p.id === state.selectedPartId);
        if (!selected) {
          setText('selected-part-tag', '미선택', '미선택');
          setHtml('docs-body', '<tr><td colspan="4" class="empty">파트를 선택해주세요.</td></tr>');
          renderPreview();
          return;
        }

        setText('selected-part-tag', selected.name, '미선택');
        if (!state.docs.length) {
          setHtml('docs-body', '<tr><td colspan="4" class="empty">업로드된 문서가 없습니다.</td></tr>');
          renderPreview();
          return;
        }

        const rows = state.docs.map((item) => `
          <tr class="doc-row ${item.id === state.selectedDocId ? 'active' : ''}" data-id="${item.id}">
            <td>${escapeHtml(item.docType)}</td>
            <td>${escapeHtml(item.title)}</td>
            <td>${escapeHtml(item.originalFileName)}</td>
            <td>${escapeHtml(item.createdAt || '-')}</td>
          </tr>
        `).join('');

        setHtml('docs-body', rows);
        bindDocActions();
        renderPreview();
      };

      const bindPartActions = () => {
        document.querySelectorAll('.part-card').forEach(card => {
          card.addEventListener('click', async () => {
            state.selectedPartId = Number(card.dataset.id || 0) || null;
            state.selectedDocId = null;
            renderParts();
            await loadDocs();
          });
        });
      };

      const renderParts = () => {
        if (!state.parts || state.parts.length === 0) {
          setHtml('part-grid', '<div class="cell"><div class="label">등록된 파트 없음</div><div class="value">0</div></div>');
          return;
        }

        const cards = state.parts.map(part => {
          const selected = part.id === state.selectedPartId;
          return `
            <div class="cell part-card ${selected ? 'active' : ''}" data-id="${part.id}">
              <div class="label">${selected ? '선택됨' : '클릭해서 선택'}</div>
              <div class="value" style="font-size: 16px;">${escapeHtml(part.name)}</div>
            </div>
          `;
        }).join('');

        setHtml('part-grid', cards);
        bindPartActions();
      };

      byId('upload-form').addEventListener('submit', async (event) => {
        event.preventDefault();
        if (!state.selectedPartId) {
          await uiAlert('파트를 먼저 선택해주세요.');
          return;
        }

        const fileEl = byId('docFile');
        const file = fileEl?.files?.[0];
        if (!file) {
          await uiAlert('업로드할 파일을 선택해주세요.');
          return;
        }

        const ext = getExt(file.name);
        if (!isPreviewable(ext)) {
          await uiAlert('허용되지 않은 파일 형식입니다. (pdf, txt, md, jpg, jpeg, png, webp)');
          return;
        }

        const formData = new FormData();
        formData.append('partId', String(state.selectedPartId));
        formData.append('docType', byId('docType').value || '기타');
        formData.append('title', (byId('docTitle').value || '').trim());
        formData.append('file', file);

        try {
          const res = await fetch('/api/part-docs/upload', { method: 'POST', body: formData });
          if (!res.ok) {
            const text = await res.text();
            throw new Error(text || '업로드 실패');
          }
          await uiAlert('업로드 완료');
          byId('upload-form').reset();
          await loadDocs();
        } catch (error) {
          await uiAlert('업로드 실패: ' + error.message);
        }
      });

      const loadParts = async () => {
        try {
          const data = await getJson('/api/parts?activeOnly=true');
          state.parts = data || [];
          state.selectedPartId = state.parts[0]?.id || null;
          renderParts();
          await loadDocs();
        } catch (error) {
          state.parts = [];
          state.selectedPartId = null;
          renderParts();
          renderDocs();
        }
      };

      loadParts();
    </script>
  </body>
</html>