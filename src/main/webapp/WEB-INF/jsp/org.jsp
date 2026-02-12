<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<!doctype html>
<html lang="ko">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>조직도 관리</title>
    <link rel="stylesheet" href="/css/common.css" />
    <style>
      .org-wrap { display: grid; grid-template-columns: 2.2fr 1fr; gap: 16px; }

      .org-viewport {
        border: 1px dashed var(--stroke);
        border-radius: 14px;
        min-height: 560px;
        overflow: hidden;
        background: radial-gradient(1200px 360px at 50% 0%, rgba(42, 107, 255, 0.08), transparent 70%);
        position: relative;
        cursor: grab;
      }
      .org-viewport.panning { cursor: grabbing; }

      .org-stage {
        position: absolute;
        left: 0;
        top: 0;
        transform-origin: top left;
      }

      #org-lines {
        position: absolute;
        left: 0;
        top: 0;
        width: 100%;
        height: 100%;
        pointer-events: none;
      }

      #org-nodes {
        position: absolute;
        left: 0;
        top: 0;
        width: 100%;
        height: 100%;
      }

      .org-node {
        position: absolute;
        width: 220px;
        min-height: 100px;
        border: 1px solid var(--stroke);
        border-radius: 14px;
        padding: 10px;
        background: linear-gradient(180deg, rgba(255,255,255,0.05), rgba(255,255,255,0.01));
        box-shadow: 0 10px 20px rgba(3, 8, 20, 0.35);
        cursor: grab;
        user-select: none;
      }

      .org-node.dragging {
        cursor: grabbing;
        border-color: var(--accent);
        box-shadow: 0 0 0 2px rgba(57, 194, 255, 0.25) inset;
      }

      .org-node.root {
        border-color: rgba(57, 194, 255, 0.6);
        background: linear-gradient(180deg, rgba(57,194,255,0.18), rgba(255,255,255,0.02));
      }

      .org-title { font-weight: 700; font-size: 14px; line-height: 1.3; }
      .org-role { color: var(--muted); font-size: 12px; margin-top: 4px; min-height: 16px; white-space: pre-line; }
      .org-actions {
        margin-top: 10px;
        display: flex;
        gap: 6px;
        flex-wrap: wrap;
      }

      .btn.small { padding: 5px 8px; font-size: 11px; }
      .guide { color: var(--muted); font-size: 12px; margin-top: 8px; }

      @media (max-width: 980px) {
        .org-wrap { grid-template-columns: 1fr; }
      }
    </style>
  </head>
  <body>
    <div class="page">
      <div class="topbar">
        <div class="brand">
          <div class="logo" aria-hidden="true"></div>
          <div>
            <h1>조직도 관리</h1>
            <div class="subtitle">노드를 드래그해서 놓은 위치를 그대로 저장합니다.</div>
          </div>
        </div>
        <div class="cta">
          <a class="btn" href="/">메인</a>
          <a class="btn" href="/docs">파트 문서</a>
          <a class="btn" href="/parts">파트 관리</a>
          <a class="btn primary" href="/org">조직도 관리</a>
        </div>
      </div>

      <div class="org-wrap">
        <div class="card">
          <div class="section-title">
            <h2>회사 조직도</h2>
            <span class="tag" id="org-count">0개</span>
          </div>
          <div class="org-viewport" id="org-viewport">
            <div class="org-stage" id="org-stage">
              <svg id="org-lines"></svg>
              <div id="org-nodes"></div>
            </div>
          </div>
          <div class="guide">팀장 노드가 루트이며, 선은 부모-자식 관계를 기준으로 자동 연결됩니다.</div>
        </div>

        <div class="card">
          <div class="section-title">
            <h2>빠른 작업</h2>
          </div>
          <div class="form">
            <button class="btn" type="button" id="btn-add-root">최상위 조직 추가</button>
            <button class="btn" type="button" id="btn-refresh">새로고침</button>
          </div>
          <p class="hint" style="margin-top: 12px;">
            드래그: 위치 변경 저장<br />
            이름변경: 조직명/직책 수정<br />
            하위추가: 선택 노드 아래 추가
          </p>
        </div>
      </div>
    </div>

    <script src="/js/common.js"></script>
    <script>
      const CARD_W = 220;
      const CARD_H = 112;
      const PAD = 80;

      const state = {
        nodes: [],
        parts: [],
        partMembersByPartId: {},
        scale: 1,
        baseScale: 1,
        zoomFactor: 1,
        stageW: 1800,
        stageH: 900,
        drag: null,
        panOffsetX: 0,
        panOffsetY: 0,
        pan: null
      };

      const escapeHtml = (value) => String(value ?? '')
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');

      const getPartMembersText = (partId) => {
        const items = state.partMembersByPartId[String(partId)] || [];
        if (!items.length) return '구성원 없음';
        return items
          .map(m => `${m.memberName || ''}${m.memberTitle ? ` ${m.memberTitle}` : ''}`.trim())
          .filter(Boolean)
          .join('\n');
      };

      const mapById = () => new Map((state.nodes || []).map(n => [n.id, n]));

      const fallbackLayout = () => {
        const byParent = new Map();
        state.nodes.forEach(node => {
          const key = node.parentId == null ? 'root' : String(node.parentId);
          if (!byParent.has(key)) byParent.set(key, []);
          byParent.get(key).push(node);
        });
        byParent.forEach(list => list.sort((a, b) => (a.sortOrder - b.sortOrder) || (a.id - b.id)));

        const levelMap = new Map();
        const walk = (parentId, level) => {
          const key = parentId == null ? 'root' : String(parentId);
          const list = byParent.get(key) || [];
          list.forEach((n, idx) => {
            if (n.posX == null || n.posY == null) {
              const x = 240 + idx * 260;
              const y = 70 + level * 190;
              n.posX = x;
              n.posY = y;
            }
            levelMap.set(n.id, level);
            walk(n.id, level + 1);
          });
        };
        walk(null, 0);
      };

      const computeStageSize = () => {
        if (!state.nodes.length) {
          state.stageW = 1400;
          state.stageH = 700;
          return;
        }
        let maxX = 0;
        let maxY = 0;
        state.nodes.forEach(n => {
          const x = n.posX ?? 0;
          const y = n.posY ?? 0;
          maxX = Math.max(maxX, x + CARD_W);
          maxY = Math.max(maxY, y + CARD_H);
        });
        state.stageW = Math.max(1400, maxX + PAD);
        state.stageH = Math.max(700, maxY + PAD);
      };

      const getBaseOffsets = () => {
        const viewport = byId('org-viewport');
        if (!viewport) return { x: 0, y: 8 };
        const availW = Math.max(320, viewport.clientWidth - 14);
        return {
          x: Math.max(0, (availW - state.stageW * state.scale) / 2),
          y: 8
        };
      };

      const fitStage = () => {
        const viewport = byId('org-viewport');
        const stage = byId('org-stage');
        if (!viewport || !stage) return;

        const availW = Math.max(320, viewport.clientWidth - 14);
        const availH = Math.max(340, viewport.clientHeight - 14);
        const scale = Math.min(1, availW / state.stageW, availH / state.stageH);
        state.baseScale = Math.max(0.55, scale);
        const next = state.baseScale * state.zoomFactor;
        state.scale = Math.max(0.35, Math.min(2, next));

        stage.style.width = `${state.stageW}px`;
        stage.style.height = `${state.stageH}px`;
        stage.style.transform = `scale(${state.scale})`;

        const offsetX = Math.max(0, (availW - state.stageW * state.scale) / 2);
        const offsetY = 8;
        stage.style.left = `${offsetX + state.panOffsetX}px`;
        stage.style.top = `${offsetY + state.panOffsetY}px`;
      };

      const drawLines = () => {
        const svg = byId('org-lines');
        if (!svg) return;
        svg.setAttribute('viewBox', `0 0 ${state.stageW} ${state.stageH}`);

        const map = mapById();
        const paths = [];
        state.nodes.forEach(node => {
          if (node.parentId == null) return;
          const parent = map.get(node.parentId);
          if (!parent) return;

          const x1 = (parent.posX ?? 0) + CARD_W / 2;
          const y1 = (parent.posY ?? 0) + CARD_H;
          const x2 = (node.posX ?? 0) + CARD_W / 2;
          const y2 = (node.posY ?? 0);
          const mid = Math.round((y1 + y2) / 2);
          const d = `M ${x1} ${y1} V ${mid} H ${x2} V ${y2}`;
          paths.push(`<path d="${d}" stroke="rgba(167,176,214,0.78)" stroke-width="2" fill="none" />`);
        });

        svg.innerHTML = paths.join('');
      };

      const renderNodes = () => {
        if (!state.nodes.length) {
          setHtml('org-nodes', '<div class="empty" style="position:absolute;left:20px;top:20px;">등록된 조직이 없습니다.</div>');
          return;
        }

        const html = state.nodes.map(n => {
          const linkedPart = state.parts.find(p => p.id === n.partId);
          const title = linkedPart ? linkedPart.name : n.name;
          const roleText = linkedPart ? getPartMembersText(linkedPart.id) : (n.roleName || '');
          return `
          <div class="org-node ${n.parentId == null ? 'root' : ''}" data-id="${n.id}" style="left:${n.posX}px; top:${n.posY}px;">
            <div class="org-title">${escapeHtml(title)}</div>
            <div class="org-role">${escapeHtml(roleText)}</div>
            <div class="org-actions">
              <button class="btn small btn-rename" type="button" data-id="${n.id}">이름변경</button>
              <button class="btn small btn-add-child" type="button" data-id="${n.id}">하위추가</button>
              <button class="btn small btn-delete" type="button" data-id="${n.id}">삭제</button>
            </div>
          </div>
        `;
        }).join('');

        setHtml('org-nodes', html);
      };

      const render = () => {
        fallbackLayout();
        computeStageSize();
        renderNodes();
        drawLines();
        fitStage();
        bindActions();
        setText('org-count', `${state.nodes.length}개`, '0개');
      };

      const loadPartsAndMembers = async () => {
        const parts = await getJson('/api/parts?activeOnly=true');
        state.parts = (parts || []).sort((a, b) => (a.displayOrder - b.displayOrder) || a.name.localeCompare(b.name, 'ko'));

        const memberResults = await Promise.all(
          state.parts.map(async (part) => {
            try {
              const members = await getJson(`/api/parts/${part.id}/members?activeOnly=true`);
              return [String(part.id), members || []];
            } catch (error) {
              return [String(part.id), []];
            }
          })
        );
        state.partMembersByPartId = Object.fromEntries(memberResults);
      };

      const load = async () => {
        try {
          const [nodes] = await Promise.all([
            getJson('/api/org/units?activeOnly=true'),
            loadPartsAndMembers()
          ]);
          state.nodes = nodes || [];
          render();
        } catch (error) {
          setHtml('org-nodes', `<div class="empty" style="position:absolute;left:20px;top:20px;">조회 실패: ${error.message}</div>`);
        }
      };

      const persistPosition = async (id, x, y) => {
        await putJson(`/api/org/units/${id}/position`, { posX: Math.round(x), posY: Math.round(y) });
      };

      const createUnit = async (parentId) => {
        const pickPart = async () => new Promise((resolve) => {
          const ui = createModal({ title: '파트 선택', message: '하위 조직에 연결할 파트를 선택하세요.' });
          const field = document.createElement('div');
          field.className = 'ui-modal-field';
          const options = state.parts.map(p => `<option value="${p.id}">${escapeHtml(p.name)} (${escapeHtml(p.code)})</option>`).join('');
          field.innerHTML = `<label>파트</label><select id="org-part-select">${options}</select>`;
          ui.body.appendChild(field);

          const cancelBtn = document.createElement('button');
          cancelBtn.className = 'btn';
          cancelBtn.type = 'button';
          cancelBtn.textContent = '취소';
          cancelBtn.addEventListener('click', () => {
            ui.close();
            resolve(null);
          });

          const okBtn = document.createElement('button');
          okBtn.className = 'btn primary';
          okBtn.type = 'button';
          okBtn.textContent = '선택';
          okBtn.addEventListener('click', () => {
            const selected = ui.body.querySelector('#org-part-select');
            const value = Number(selected?.value || 0);
            ui.close();
            resolve(value || null);
          });
          ui.actions.append(cancelBtn, okBtn);
          okBtn.focus();
        });

        let name = '신규 조직';
        let roleName = '';
        let partId = null;

        if (parentId == null) {
          const rootName = await uiPrompt({ title: '조직 추가', label: '조직명', defaultValue: '신규 조직' });
          if (rootName === null || !rootName.trim()) return;
          const roleNameInput = await uiPrompt({ title: '조직 추가', label: '직책/담당자 (선택)', defaultValue: '' });
          if (roleNameInput === null) return;
          name = rootName.trim();
          roleName = roleNameInput.trim();
        } else {
          if (!state.parts.length) {
            await uiAlert('활성 파트가 없어 하위 조직을 추가할 수 없습니다.');
            return;
          }
          partId = await pickPart();
          if (!partId) return;
          const selectedPart = state.parts.find(p => p.id === partId);
          if (!selectedPart) {
            await uiAlert('선택한 파트를 찾을 수 없습니다.');
            return;
          }
          name = selectedPart.name;
        }

        let x = 120;
        let y = 120;
        if (parentId != null) {
          const parent = state.nodes.find(n => n.id === parentId);
          const siblings = state.nodes.filter(n => n.parentId === parentId).length;
          if (parent) {
            x = (parent.posX ?? 120) + siblings * 240 - 120;
            y = (parent.posY ?? 120) + 180;
          }
        }

        try {
          await postJson('/api/org/units', {
            parentId,
            partId,
            name: name.trim(),
            roleName: roleName.trim(),
            posX: x,
            posY: y,
            sortOrder: 0
          });
          await load();
        } catch (error) {
          await uiAlert('추가 실패: ' + error.message);
        }
      };

      const renameUnit = async (id) => {
        const current = state.nodes.find(n => n.id === id);
        if (!current) return;

        const name = await uiPrompt({ title: '이름 변경', label: '조직명', defaultValue: current.name });
        if (name === null || !name.trim()) return;
        const roleName = await uiPrompt({ title: '이름 변경', label: '직책/담당자', defaultValue: current.roleName || '' });
        if (roleName === null) return;

        try {
          await putJson(`/api/org/units/${id}`, {
            parentId: current.parentId,
            partId: current.partId ?? null,
            name: name.trim(),
            roleName: roleName.trim(),
            posX: current.posX,
            posY: current.posY,
            sortOrder: current.sortOrder
          });
          await load();
        } catch (error) {
          await uiAlert('수정 실패: ' + error.message);
        }
      };

      const deleteUnit = async (id) => {
        if (!await uiConfirm('선택한 조직을 삭제(비활성)하시겠습니까?')) return;
        try {
          await jsonRequest(`/api/org/units/${id}`, { method: 'DELETE' });
          await load();
        } catch (error) {
          await uiAlert('삭제 실패: ' + error.message);
        }
      };

      const startDrag = (event, nodeEl) => {
        if (event.target.closest('button')) return;
        const id = Number(nodeEl.dataset.id);
        const node = state.nodes.find(n => n.id === id);
        if (!node) return;

        const viewport = byId('org-viewport');
        const rect = viewport.getBoundingClientRect();
        const stage = byId('org-stage');
        const stageLeft = parseFloat(stage.style.left || '0');
        const stageTop = parseFloat(stage.style.top || '0');

        const worldX = (event.clientX - rect.left - stageLeft) / state.scale;
        const worldY = (event.clientY - rect.top - stageTop) / state.scale;

        state.drag = {
          id,
          offsetX: worldX - (node.posX ?? 0),
          offsetY: worldY - (node.posY ?? 0)
        };
        nodeEl.classList.add('dragging');
      };

      const moveDrag = (event) => {
        if (!state.drag) return;
        const viewport = byId('org-viewport');
        const rect = viewport.getBoundingClientRect();
        const stage = byId('org-stage');
        const stageLeft = parseFloat(stage.style.left || '0');
        const stageTop = parseFloat(stage.style.top || '0');

        const worldX = (event.clientX - rect.left - stageLeft) / state.scale;
        const worldY = (event.clientY - rect.top - stageTop) / state.scale;

        const node = state.nodes.find(n => n.id === state.drag.id);
        if (!node) return;

        const nx = Math.max(10, Math.min(state.stageW - CARD_W - 10, Math.round(worldX - state.drag.offsetX)));
        const ny = Math.max(10, Math.min(state.stageH - CARD_H - 10, Math.round(worldY - state.drag.offsetY)));
        node.posX = nx;
        node.posY = ny;

        const el = document.querySelector(`.org-node[data-id="${node.id}"]`);
        if (el) {
          el.style.left = `${nx}px`;
          el.style.top = `${ny}px`;
        }
        drawLines();
      };

      const endDrag = async () => {
        if (!state.drag) return;
        const dragId = state.drag.id;
        state.drag = null;

        const el = document.querySelector(`.org-node[data-id="${dragId}"]`);
        if (el) el.classList.remove('dragging');

        const node = state.nodes.find(n => n.id === dragId);
        if (!node) return;

        try {
          await persistPosition(dragId, node.posX, node.posY);
        } catch (error) {
          await uiAlert('위치 저장 실패: ' + error.message);
        }
      };

      const bindActions = () => {
        document.querySelectorAll('.org-node').forEach(el => {
          el.addEventListener('mousedown', (event) => startDrag(event, el));
        });

        document.querySelectorAll('.btn-add-child').forEach(btn => {
          btn.addEventListener('click', () => createUnit(Number(btn.dataset.id)));
        });

        document.querySelectorAll('.btn-rename').forEach(btn => {
          btn.addEventListener('click', () => renameUnit(Number(btn.dataset.id)));
        });

        document.querySelectorAll('.btn-delete').forEach(btn => {
          btn.addEventListener('click', () => deleteUnit(Number(btn.dataset.id)));
        });
      };

      const startPan = (event) => {
        if (event.button !== 0) return;
        if (event.target.closest('.org-node')) return;
        if (state.drag) return;

        const stage = byId('org-stage');
        const viewport = byId('org-viewport');
        state.pan = {
          startX: event.clientX,
          startY: event.clientY,
          startLeft: parseFloat(stage.style.left || '0'),
          startTop: parseFloat(stage.style.top || '0')
        };
        if (viewport) viewport.classList.add('panning');
      };

      const movePan = (event) => {
        if (!state.pan || state.drag) return;
        const stage = byId('org-stage');
        const viewport = byId('org-viewport');
        if (!stage || !viewport) return;

        const dx = event.clientX - state.pan.startX;
        const dy = event.clientY - state.pan.startY;
        const nextLeft = state.pan.startLeft + dx;
        const nextTop = state.pan.startTop + dy;

        const availW = Math.max(320, viewport.clientWidth - 14);
        const centerX = Math.max(0, (availW - state.stageW * state.scale) / 2);
        const baseY = 8;
        state.panOffsetX = nextLeft - centerX;
        state.panOffsetY = nextTop - baseY;

        stage.style.left = `${nextLeft}px`;
        stage.style.top = `${nextTop}px`;
      };

      const endPan = () => {
        if (!state.pan) return;
        state.pan = null;
        const viewport = byId('org-viewport');
        if (viewport) viewport.classList.remove('panning');
      };

      window.addEventListener('mousemove', (event) => {
        moveDrag(event);
        movePan(event);
      });
      window.addEventListener('mouseup', () => {
        endDrag();
        endPan();
      });
      window.addEventListener('resize', fitStage);

      byId('org-viewport').addEventListener('mousedown', startPan);
      byId('org-viewport').addEventListener('wheel', (event) => {
        event.preventDefault();

        const viewport = byId('org-viewport');
        const stage = byId('org-stage');
        if (!viewport || !stage) return;

        const baseBefore = getBaseOffsets();
        const rect = viewport.getBoundingClientRect();
        const relX = event.clientX - rect.left;
        const relY = event.clientY - rect.top;
        const worldX = (relX - (baseBefore.x + state.panOffsetX)) / state.scale;
        const worldY = (relY - (baseBefore.y + state.panOffsetY)) / state.scale;

        const delta = event.deltaY < 0 ? 0.08 : -0.08;
        state.zoomFactor = Math.max(0.7, Math.min(2.6, state.zoomFactor + delta));
        fitStage();

        const baseAfter = getBaseOffsets();
        state.panOffsetX = relX - baseAfter.x - worldX * state.scale;
        state.panOffsetY = relY - baseAfter.y - worldY * state.scale;

        // Keep panning in a sane range while preserving pointer-centric zoom.
        state.panOffsetX = Math.max(-state.stageW, Math.min(state.stageW, state.panOffsetX));
        state.panOffsetY = Math.max(-state.stageH, Math.min(state.stageH, state.panOffsetY));

        stage.style.left = `${baseAfter.x + state.panOffsetX}px`;
        stage.style.top = `${baseAfter.y + state.panOffsetY}px`;
      }, { passive: false });

      byId('btn-add-root').addEventListener('click', () => createUnit(null));
      byId('btn-refresh').addEventListener('click', load);

      load();
    </script>
  </body>
</html>
