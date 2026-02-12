<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<!doctype html>
<html lang="ko">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>만료 리스크 대시보드</title>
    <link rel="stylesheet" href="/css/common.css" />
    <style>
      .name-cell-wrap {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 10px;
      }
      .row-tools {
        display: inline-flex;
        gap: 6px;
      }
      .btn.xs {
        padding: 4px 8px;
        font-size: 11px;
      }
      .modal-grid {
        display: grid;
        gap: 10px;
      }
      .modal-row {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 10px;
      }
      @media (max-width: 640px) {
        .modal-row { grid-template-columns: 1fr; }
      }
    </style>
  </head>
  <body>
    <div class="page">
      <div class="topbar">
        <div class="brand">
          <div class="logo" aria-hidden="true"></div>
          <div>
            <h1>만료 리스크 대시보드</h1>
            <div class="subtitle">라이선스 · SSL · 도메인 · 계약 갱신 상태 요약</div>
          </div>
        </div>
        <div class="cta">
          <a class="btn" href="/">메인</a>
          <a class="btn" href="/policy">알림 정책</a>
          <a class="btn" href="/docs">파트 문서</a>
          <a class="btn primary" href="/add">자산 추가</a>
        </div>
      </div>

      <div class="grid cols-12">
        <div class="kpis">
          <div class="kpi">
            <div class="label">D-90 이내 만료</div>
            <div class="value warning" id="kpi-d90">-</div>
            <div class="trend" id="kpi-d90-trend">지난 7일 신규 +0</div>
          </div>
          <div class="kpi">
            <div class="label">D-30 이내 만료</div>
            <div class="value danger" id="kpi-d30">-</div>
            <div class="trend" id="kpi-d30-trend">지난 7일 신규 +0</div>
          </div>
          <div class="kpi">
            <div class="label">정상 수량</div>
            <div class="value good" id="kpi-healthy">-</div>
            <div class="trend" id="kpi-healthy-trend">지난 7일 신규 +0</div>
          </div>
          <div class="kpi">
            <div class="label">알림 미설정</div>
            <div class="value" id="kpi-no-policy">-</div>
            <div class="trend" id="kpi-no-policy-trend">지난 7일 신규 +0</div>
          </div>
        </div>

        <div class="card list">
          <div class="section-title">
            <h2>임박 만료 목록</h2>
            <span class="tag warning">D-30</span>
          </div>
          <table class="table">
            <thead>
              <tr>
                <th>자산명</th>
                <th>유형</th>
                <th>만료일</th>
                <th>파트</th>
                <th>상태</th>
              </tr>
            </thead>
            <tbody id="expiry-body">
              <tr><td colspan="5" class="empty">데이터를 불러오는 중...</td></tr>
            </tbody>
          </table>
        </div>

        <div class="card heatmap">
          <div class="section-title">
            <h2>파트별 리스크 분포</h2>
            <span class="tag">최근 90일</span>
          </div>
          <div class="mini-grid" id="team-risk">
            <div class="cell"><div class="label">로딩 중...</div><div class="value">-</div></div>
          </div>
        </div>

        <div class="card foot">
          <div>
            <div class="section-title">
              <h2>최근 변경 이력</h2>
              <span class="tag">최근 등록 기준</span>
            </div>
            <div class="timeline" id="recent-changes">
              <div class="event"><div class="dot"></div><div>데이터를 불러오는 중...</div></div>
            </div>
          </div>
          <div>
            <div class="section-title"><h2>알림 정책</h2></div>
            <div class="policy-list" id="policy-list">
              <div class="policy-item"><span>로딩 중...</span><span>-</span></div>
            </div>
          </div>
        </div>

        <div class="card full-table">
          <div class="section-title">
            <h2>전체 만료 현황</h2>
            <span class="tag">모든 리소스</span>
          </div>
          <div class="filters">
            <input id="filter-text" placeholder="자산명 검색" />
            <select id="filter-type"><option value="">유형 전체</option></select>
            <input id="filter-part" placeholder="파트 검색" />
            <select id="filter-policy"><option value="">정책 전체</option></select>
            <select id="filter-range">
              <option value="">기간 전체</option>
              <option value="expired">만료됨</option>
              <option value="30">D-30 이내</option>
              <option value="90">D-90 이내</option>
            </select>
          </div>
          <table class="table">
            <thead>
              <tr>
                <th>자산명</th>
                <th>유형</th>
                <th>만료일</th>
                <th>파트</th>
                <th>정책</th>
              </tr>
            </thead>
            <tbody id="all-expiry-body">
              <tr><td colspan="5" class="empty">데이터를 불러오는 중...</td></tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <script src="/js/common.js"></script>
    <script>
      const state = {
        allAssets: [],
        parts: [],
        policies: []
      };

      const assetTypes = ['SSL', 'License', 'Domain', 'Contract', 'Other'];
      const importanceOptions = ['High', 'Medium', 'Low'];

      const fmtStatus = (daysLeft) => {
        if (daysLeft <= 7) return { cls: 'danger', label: `D-${daysLeft}` };
        if (daysLeft <= 30) return { cls: 'warning', label: `D-${daysLeft}` };
        return { cls: 'good', label: `D-${daysLeft}` };
      };

      const escapeHtml = (value) => String(value ?? '')
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');

      const renderItems = (items) => {
        if (!items || items.length === 0) {
          setHtml('expiry-body', '<tr><td colspan="5" class="empty">임박 만료 항목이 없습니다.</td></tr>');
          return;
        }
        const rows = items.map(item => {
          const status = fmtStatus(item.daysLeft);
          const alert = item.daysLeft <= 7;
          return `
            <tr>
              <td>
                <div class="name-cell-wrap">
                  <div class="name-cell">
                    ${alert ? '<span class="alert-dot" title="임박 만료"></span>' : ''}
                    <span>${escapeHtml(item.name)}</span>
                  </div>
                  <div class="row-tools">
                    <button class="btn xs btn-edit-asset" type="button" data-id="${item.id}">수정</button>
                  </div>
                </div>
              </td>
              <td>${escapeHtml(item.type)}</td>
              <td>${escapeHtml(item.expiresAt)}</td>
              <td>${escapeHtml(item.partName ?? '-')}</td>
              <td><span class="tag ${status.cls}">${status.label}</span></td>
            </tr>
          `;
        }).join('');
        setHtml('expiry-body', rows);
        bindEditButtons();
      };

      const renderCounts = (counts) => {
        setText('kpi-d90', counts?.d90);
        setText('kpi-d30', counts?.d30);
        setText('kpi-healthy', counts?.healthy);
        setText('kpi-no-policy', counts?.noPolicy);
        setText('kpi-d90-trend', `지난 7일 신규 +${counts?.d90New ?? 0}`);
        setText('kpi-d30-trend', `지난 7일 신규 +${counts?.d30New ?? 0}`);
        setText('kpi-healthy-trend', `지난 7일 신규 +${counts?.healthyNew ?? 0}`);
        setText('kpi-no-policy-trend', `지난 7일 신규 +${counts?.noPolicyNew ?? 0}`);
      };

      const renderPartRisk = (parts) => {
        if (!parts || parts.length === 0) {
          setHtml('team-risk', '<div class="cell"><div class="label">데이터 없음</div><div class="value">-</div></div>');
          return;
        }
        const cells = parts.map(part => `
          <div class="cell">
            <div class="label">${escapeHtml(part.part ?? '미지정')}</div>
            <div class="value">${part.count}건</div>
          </div>
        `).join('');
        setHtml('team-risk', cells);
      };

      const renderPolicies = (policies) => {
        if (!policies || policies.length === 0) {
          setHtml('policy-list', '<div class="policy-item"><span>미설정</span><span>0</span></div>');
          return;
        }
        const rows = policies.map(policy => `
          <div class="policy-item"><span>${escapeHtml(policy.policy)}</span><span>${policy.count}</span></div>
        `).join('');
        setHtml('policy-list', rows);
      };

      const renderRecent = (items) => {
        if (!items || items.length === 0) {
          setHtml('recent-changes', '<div class="event"><div class="dot"></div><div>최근 등록 이력이 없습니다.</div></div>');
          return;
        }
        const rows = items.map(item => `
          <div class="event"><div class="dot"></div><div>${escapeHtml(item.name)} · ${escapeHtml(item.type)} · ${escapeHtml(item.partName ?? '미지정')} · ${escapeHtml(item.createdAt)}</div></div>
        `).join('');
        setHtml('recent-changes', rows);
      };

      const renderAllExpiry = (items) => {
        if (!items || items.length === 0) {
          setHtml('all-expiry-body', '<tr><td colspan="5" class="empty">데이터가 없습니다.</td></tr>');
          return;
        }
        const rows = items.map(item => {
          const alert = (item.daysLeft ?? 9999) <= 7;
          return `
            <tr>
              <td>
                <div class="name-cell-wrap">
                  <div class="name-cell">
                    ${alert ? '<span class="alert-dot" title="임박 만료"></span>' : ''}
                    <span>${escapeHtml(item.name)}</span>
                  </div>
                  <div class="row-tools">
                    <button class="btn xs btn-edit-asset" type="button" data-id="${item.id}">수정</button>
                  </div>
                </div>
              </td>
              <td>${escapeHtml(item.type)}</td>
              <td>${escapeHtml(item.expiresAt)}</td>
              <td>${escapeHtml(item.partName ?? '-')}</td>
              <td>${escapeHtml(item.notifyPolicy ?? '미설정')}</td>
            </tr>
          `;
        }).join('');
        setHtml('all-expiry-body', rows);
        bindEditButtons();
      };

      const populateFilters = (items) => {
        const typeSet = new Set();
        const policySet = new Set();
        items.forEach(item => {
          if (item.type) typeSet.add(item.type);
          policySet.add(item.notifyPolicy ?? '미설정');
        });

        byId('filter-type').innerHTML = '<option value="">유형 전체</option>' +
          [...typeSet].sort().map(t => `<option value="${escapeHtml(t)}">${escapeHtml(t)}</option>`).join('');
        byId('filter-policy').innerHTML = '<option value="">정책 전체</option>' +
          [...policySet].sort().map(p => `<option value="${escapeHtml(p)}">${escapeHtml(p)}</option>`).join('');
      };

      const applyFilters = () => {
        const text = (byId('filter-text').value || '').trim().toLowerCase();
        const type = byId('filter-type').value;
        const part = (byId('filter-part').value || '').trim().toLowerCase();
        const policy = byId('filter-policy').value;
        const range = byId('filter-range').value;

        const filtered = (state.allAssets || []).filter(item => {
          if (text && !String(item.name || '').toLowerCase().includes(text)) return false;
          if (type && item.type !== type) return false;
          if (part && !String(item.partName || '').toLowerCase().includes(part)) return false;
          if (policy && (item.notifyPolicy ?? '미설정') !== policy) return false;

          if (range) {
            const daysLeft = item.daysLeft ?? null;
            if (range === 'expired' && (daysLeft === null || daysLeft >= 0)) return false;
            if (range === '30' && (daysLeft === null || daysLeft > 30 || daysLeft < 0)) return false;
            if (range === '90' && (daysLeft === null || daysLeft > 90 || daysLeft < 0)) return false;
          }
          return true;
        });

        renderAllExpiry(filtered);
      };

      const loadDashboard = async () => {
        try {
          const data = await getJson('/api/dashboard');
          renderCounts(data.counts);
          renderItems(data.items);
          renderPartRisk(data.teamRisks);
          renderPolicies(data.policyCounts);
          renderRecent(data.recentChanges);
        } catch (error) {
          renderCounts(null);
          renderItems([]);
          renderPartRisk([]);
          renderPolicies([]);
          renderRecent([]);
        }
      };

      const loadAssets = async () => {
        try {
          const data = await getJson('/api/assets');
          state.allAssets = (data || []).map(item => ({ ...item, daysLeft: calcDaysLeft(item.expiresAt) }));
          populateFilters(state.allAssets);
          applyFilters();
        } catch (error) {
          state.allAssets = [];
          renderAllExpiry([]);
        }
      };

      const loadParts = async () => {
        try {
          const data = await getJson('/api/parts?activeOnly=true');
          state.parts = data || [];
        } catch (error) {
          state.parts = [];
        }
      };

      const loadPolicyMaster = async () => {
        try {
          const data = await getJson('/api/policies');
          state.policies = data || [];
        } catch (error) {
          state.policies = [];
        }
      };

      const refreshAll = async () => {
        await Promise.all([loadDashboard(), loadAssets(), loadParts(), loadPolicyMaster()]);
      };

      const openEditModal = async (assetId) => {
        try {
          const asset = await getJson(`/api/assets/${assetId}`);

          const ui = createModal({ title: '자산 수정', message: '필수값을 입력 후 저장하세요.' });
          const partOptions = state.parts.map(p =>
            `<option value="${p.id}" ${asset.partId === p.id ? 'selected' : ''}>${escapeHtml(p.name)}</option>`
          ).join('');
          const policyNames = ['미설정', ...state.policies.map(p => p.name)];

          ui.body.innerHTML = `
            <div class="modal-grid">
              <div>
                <label for="edit-name">자산명</label>
                <input id="edit-name" value="${escapeHtml(asset.name)}" />
              </div>
              <div class="modal-row">
                <div>
                  <label for="edit-type">유형</label>
                  <select id="edit-type">
                    ${assetTypes.map(t => `<option value="${t}" ${asset.type === t ? 'selected' : ''}>${t}</option>`).join('')}
                  </select>
                </div>
                <div>
                  <label for="edit-expire">만료일</label>
                  <input id="edit-expire" type="date" value="${escapeHtml(asset.expiresAt)}" />
                </div>
              </div>
              <div class="modal-row">
                <div>
                  <label for="edit-part">파트</label>
                  <select id="edit-part">${partOptions}</select>
                </div>
                <div>
                  <label for="edit-importance">중요도</label>
                  <select id="edit-importance">
                    ${importanceOptions.map(v => `<option value="${v}" ${asset.importance === v ? 'selected' : ''}>${v}</option>`).join('')}
                  </select>
                </div>
              </div>
              <div>
                <label for="edit-policy">알림 정책</label>
                <select id="edit-policy">
                  ${policyNames.map(p => `<option value="${escapeHtml(p)}" ${(asset.notifyPolicy ?? '미설정') === p ? 'selected' : ''}>${escapeHtml(p)}</option>`).join('')}
                </select>
              </div>
              <div>
                <label for="edit-related">연결 서비스</label>
                <input id="edit-related" value="${escapeHtml(asset.relatedServices ?? '')}" />
              </div>
              <div>
                <label for="edit-memo">메모</label>
                <textarea id="edit-memo">${escapeHtml(asset.memo ?? '')}</textarea>
              </div>
            </div>
          `;

          const cancelBtn = document.createElement('button');
          cancelBtn.className = 'btn';
          cancelBtn.type = 'button';
          cancelBtn.textContent = '취소';
          cancelBtn.addEventListener('click', () => ui.close());

          const saveBtn = document.createElement('button');
          saveBtn.className = 'btn primary';
          saveBtn.type = 'button';
          saveBtn.textContent = '저장';
          saveBtn.addEventListener('click', async () => {
            const payload = {
              name: (byId('edit-name').value || '').trim(),
              type: byId('edit-type').value,
              expiresAt: byId('edit-expire').value,
              partId: Number(byId('edit-part').value || 0),
              importance: byId('edit-importance').value,
              notifyPolicy: byId('edit-policy').value || '미설정',
              relatedServices: (byId('edit-related').value || '').trim(),
              memo: (byId('edit-memo').value || '').trim()
            };

            if (!payload.name || !payload.type || !payload.expiresAt || !payload.partId) {
              await uiAlert('자산명, 유형, 만료일, 파트는 필수입니다.');
              return;
            }

            try {
              await putJson(`/api/assets/${assetId}`, payload);
              ui.close();
              await uiAlert('저장 완료');
              await Promise.all([loadDashboard(), loadAssets()]);
            } catch (error) {
              await uiAlert('저장 실패: ' + error.message);
            }
          });

          ui.actions.append(cancelBtn, saveBtn);
        } catch (error) {
          await uiAlert('자산 정보를 불러오지 못했습니다: ' + error.message);
        }
      };

      const bindEditButtons = () => {
        document.querySelectorAll('.btn-edit-asset').forEach(btn => {
          btn.addEventListener('click', () => openEditModal(Number(btn.dataset.id)));
        });
      };

      ['filter-text', 'filter-type', 'filter-part', 'filter-policy', 'filter-range'].forEach(id => {
        const el = byId(id);
        el.addEventListener('input', applyFilters);
        el.addEventListener('change', applyFilters);
      });

      refreshAll();
    </script>
  </body>
</html>