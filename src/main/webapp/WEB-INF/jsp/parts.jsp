<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<!doctype html>
<html lang="ko">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>파트/구성원 마스터 관리</title>
    <link rel="stylesheet" href="/css/common.css" />
    <style>
      .parts-grid {
        display: grid;
        grid-template-columns: 1fr 1.35fr;
        gap: 18px;
      }
      .parts-section { margin-top: 18px; }
      .th-sort {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        border: 0;
        background: transparent;
        color: inherit;
        padding: 0;
        cursor: pointer;
        font: inherit;
      }
      .th-sort .sort-indicator {
        color: var(--muted);
        font-size: 11px;
      }
      @media (max-width: 980px) {
        .parts-grid { grid-template-columns: 1fr; }
      }
    </style>
  </head>
  <body>
    <div class="page">
      <div class="topbar">
        <div class="brand">
          <div class="logo" aria-hidden="true"></div>
          <div>
            <h1>파트/구성원 마스터 관리</h1>
            <div class="subtitle">파트, 구성원, 파트 내 구성원을 함께 관리합니다.</div>
          </div>
        </div>
        <div class="cta">
          <a class="btn" href="/">메인</a>
          <a class="btn" href="/docs">파트 문서</a>
          <a class="btn" href="/org">조직도 관리</a>
          <a class="btn primary" href="/parts">파트 관리</a>
        </div>
      </div>

      <div class="parts-grid">
        <div class="card">
          <div class="section-title">
            <h2>파트 추가</h2>
          </div>
          <form class="form" id="part-form">
            <div class="row">
              <div>
                <label for="partCode">파트 코드</label>
                <input id="partCode" placeholder="예: SALES" required />
              </div>
              <div>
                <label for="partName">파트명</label>
                <input id="partName" placeholder="예: 영업담당" required />
              </div>
            </div>
            <div class="row">
              <div>
                <label for="displayOrder">정렬순서</label>
                <input id="displayOrder" type="number" value="0" />
              </div>
              <div>
                <label for="activeYn">활성여부</label>
                <select id="activeYn">
                  <option value="true">활성</option>
                  <option value="false">비활성</option>
                </select>
              </div>
            </div>
            <div class="actions">
              <button class="btn primary" type="submit">저장</button>
            </div>
          </form>
        </div>

        <div class="card">
          <div class="section-title">
            <h2>파트 목록</h2>
            <span class="tag" id="part-total-count">전체 0건</span>
          </div>
          <table class="table">
            <thead>
              <tr>
                <th><button class="th-sort" type="button" data-part-sort="code">코드 <span class="sort-indicator" id="part-sort-code">-</span></button></th>
                <th><button class="th-sort" type="button" data-part-sort="name">파트명 <span class="sort-indicator" id="part-sort-name">-</span></button></th>
                <th><button class="th-sort" type="button" data-part-sort="displayOrder">정렬순서 <span class="sort-indicator" id="part-sort-displayOrder">-</span></button></th>
                <th><button class="th-sort" type="button" data-part-sort="active">상태 <span class="sort-indicator" id="part-sort-active">-</span></button></th>
                <th>작업</th>
              </tr>
            </thead>
            <tbody id="part-body">
              <tr><td colspan="5" class="empty">로딩 중...</td></tr>
            </tbody>
          </table>
        </div>
      </div>

      <div class="parts-grid parts-section">
        <div class="card">
          <div class="section-title">
            <h2>구성원 마스터 추가</h2>
          </div>
          <form class="form" id="member-form">
            <div class="row">
              <div>
                <label for="memberEmpNo">사번</label>
                <input id="memberEmpNo" placeholder="예: E1101" />
              </div>
              <div>
                <label for="memberName">이름</label>
                <input id="memberName" placeholder="예: 홍길동" required />
              </div>
            </div>
            <div class="row">
              <div>
                <label for="memberTitle">직책</label>
                <input id="memberTitle" placeholder="예: 매니저" />
              </div>
              <div>
                <label for="memberActiveYn">활성여부</label>
                <select id="memberActiveYn">
                  <option value="true">활성</option>
                  <option value="false">비활성</option>
                </select>
              </div>
            </div>
            <div class="actions">
              <button class="btn primary" type="submit">저장</button>
            </div>
          </form>
        </div>

        <div class="card">
          <div class="section-title">
            <h2>구성원 마스터 목록</h2>
            <span class="tag" id="member-total-count">전체 0건</span>
          </div>
          <table class="table">
            <thead>
              <tr>
                <th><button class="th-sort" type="button" data-member-sort="empNo">사번 <span class="sort-indicator" id="member-sort-empNo">-</span></button></th>
                <th><button class="th-sort" type="button" data-member-sort="name">이름 <span class="sort-indicator" id="member-sort-name">-</span></button></th>
                <th><button class="th-sort" type="button" data-member-sort="title">직책 <span class="sort-indicator" id="member-sort-title">-</span></button></th>
                <th><button class="th-sort" type="button" data-member-sort="active">상태 <span class="sort-indicator" id="member-sort-active">-</span></button></th>
                <th>작업</th>
              </tr>
            </thead>
            <tbody id="member-body">
              <tr><td colspan="5" class="empty">로딩 중...</td></tr>
            </tbody>
          </table>
        </div>
      </div>

      <div class="card parts-section">
        <div class="section-title">
          <h2>파트 내 구성원 관리</h2>
          <span class="tag" id="selected-part-label">파트 미선택</span>
        </div>

        <form class="form" id="part-member-form">
          <div class="row">
            <div>
              <label for="pmPart">파트</label>
              <select id="pmPart"></select>
            </div>
            <div>
              <label for="pmMember">구성원</label>
              <select id="pmMember"></select>
            </div>
          </div>
          <div class="row">
            <div>
              <label for="pmRole">파트 내 역할</label>
              <input id="pmRole" placeholder="예: 파트 담당" />
            </div>
            <div>
              <label for="pmOrder">정렬순서</label>
              <input id="pmOrder" type="number" value="0" />
            </div>
          </div>
          <div class="row">
            <div>
              <label for="pmPrimary">대표 여부</label>
              <select id="pmPrimary">
                <option value="false">일반</option>
                <option value="true">대표</option>
              </select>
            </div>
            <div>
              <label for="pmActive">활성여부</label>
              <select id="pmActive">
                <option value="true">활성</option>
                <option value="false">비활성</option>
              </select>
            </div>
          </div>
          <div class="actions">
            <button class="btn primary" type="submit">파트 구성원 저장</button>
          </div>
        </form>

        <table class="table" style="margin-top:12px;">
          <thead>
            <tr>
              <th>이름</th>
              <th>직책</th>
              <th>파트 역할</th>
              <th>대표</th>
              <th>정렬</th>
              <th>상태</th>
              <th>작업</th>
            </tr>
          </thead>
          <tbody id="part-member-body">
            <tr><td colspan="7" class="empty">파트를 선택하면 표시됩니다.</td></tr>
          </tbody>
        </table>
      </div>
    </div>

    <script src="/js/common.js"></script>
    <script>
      const state = {
        parts: [],
        members: [],
        selectedPartId: null,
        partSort: {
          key: 'displayOrder',
          direction: 'asc'
        },
        memberSort: {
          key: 'empNo',
          direction: 'asc'
        }
      };

      const compareText = (a, b) => String(a || '').localeCompare(String(b || ''), 'ko', { sensitivity: 'base' });

      const sortParts = (items) => {
        const key = state.partSort.key;
        const dir = state.partSort.direction === 'asc' ? 1 : -1;
        return [...items].sort((a, b) => {
          let compared = 0;
          if (key === 'displayOrder') {
            compared = Number(a.displayOrder || 0) - Number(b.displayOrder || 0);
          } else if (key === 'active') {
            compared = Number(Boolean(a.active)) - Number(Boolean(b.active));
          } else if (key === 'code') {
            compared = compareText(a.code || '', b.code || '');
          } else if (key === 'name') {
            compared = compareText(a.name || '', b.name || '');
          }
          if (compared === 0) compared = compareText(a.name || '', b.name || '');
          if (compared === 0) compared = compareText(a.code || '', b.code || '');
          return compared * dir;
        });
      };

      const renderPartSortIndicators = () => {
        const keys = ['code', 'name', 'displayOrder', 'active'];
        keys.forEach(key => {
          const el = byId(`part-sort-${key}`);
          if (!el) return;
          if (state.partSort.key !== key) {
            el.textContent = '-';
            return;
          }
          el.textContent = state.partSort.direction === 'asc' ? '▲' : '▼';
        });
      };

      const sortMembers = (items) => {
        const key = state.memberSort.key;
        const dir = state.memberSort.direction === 'asc' ? 1 : -1;
        return [...items].sort((a, b) => {
          let compared = 0;
          if (key === 'active') {
            compared = Number(Boolean(a.active)) - Number(Boolean(b.active));
          } else if (key === 'empNo') {
            compared = compareText(a.empNo || '', b.empNo || '');
          } else if (key === 'name') {
            compared = compareText(a.name || '', b.name || '');
          } else if (key === 'title') {
            compared = compareText(a.title || '', b.title || '');
          }
          if (compared === 0) compared = compareText(a.name || '', b.name || '');
          return compared * dir;
        });
      };

      const renderMemberSortIndicators = () => {
        const keys = ['empNo', 'name', 'title', 'active'];
        keys.forEach(key => {
          const el = byId(`member-sort-${key}`);
          if (!el) return;
          if (state.memberSort.key !== key) {
            el.textContent = '-';
            return;
          }
          el.textContent = state.memberSort.direction === 'asc' ? '▲' : '▼';
        });
      };

      const loadParts = () => {
        return getJson('/api/parts')
          .then(items => {
            state.parts = items || [];
            if (!state.selectedPartId && state.parts.length > 0) {
              state.selectedPartId = state.parts[0].id;
            }
            renderPartTable();
            renderPartSelect();
          })
          .catch(error => {
            setHtml('part-body', `<tr><td colspan="5" class="empty">조회 실패: ${error.message}</td></tr>`);
            state.parts = [];
            setText('part-total-count', '전체 0건', '전체 0건');
            renderPartSelect();
          });
      };

      const loadMembers = () => {
        return getJson('/api/members')
          .then(items => {
            state.members = items || [];
            renderMemberTable();
            renderMemberSelect();
          })
          .catch(error => {
            setHtml('member-body', `<tr><td colspan="5" class="empty">조회 실패: ${error.message}</td></tr>`);
            state.members = [];
            setText('member-total-count', '전체 0건', '전체 0건');
            renderMemberSelect();
          });
      };

      const renderPartSelect = () => {
        const select = byId('pmPart');
        if (!state.parts.length) {
          select.innerHTML = '<option value="">등록된 파트 없음</option>';
          setText('selected-part-label', '파트 미선택', '파트 미선택');
          return;
        }
        select.innerHTML = state.parts.map(p => `<option value="${p.id}">${p.name} (${p.code})</option>`).join('');
        if (state.selectedPartId) select.value = String(state.selectedPartId);
        const selected = state.parts.find(p => p.id === Number(select.value));
        setText('selected-part-label', selected ? `${selected.name} (${selected.code})` : '파트 미선택', '파트 미선택');
      };

      const renderMemberSelect = () => {
        const select = byId('pmMember');
        const activeMembers = state.members.filter(m => m.active);
        if (!activeMembers.length) {
          select.innerHTML = '<option value="">활성 구성원 없음</option>';
          return;
        }
        select.innerHTML = activeMembers.map(m => `<option value="${m.id}">${m.name}${m.title ? ' / ' + m.title : ''}</option>`).join('');
      };

      const renderPartTable = () => {
        renderPartSortIndicators();
        setText('part-total-count', `전체 ${state.parts.length}건`, '전체 0건');
        if (!state.parts.length) {
          setHtml('part-body', '<tr><td colspan="5" class="empty">등록된 파트가 없습니다.</td></tr>');
          return;
        }

        const rows = sortParts(state.parts).map(item => `
          <tr>
            <td>${item.code}</td>
            <td>${item.name}</td>
            <td>${item.displayOrder}</td>
            <td>${item.active ? '활성' : '비활성'}</td>
                <td>
                  <div class="cta">
                    <button class="btn btn-part-select" type="button" data-id="${item.id}">구성원관리</button>
                    <button class="btn btn-edit" type="button" data-id="${item.id}">수정</button>
                    <button class="btn btn-part-toggle-active" type="button" data-id="${item.id}" data-active="${item.active}">${item.active ? '비활성' : '활성화'}</button>
                    <button class="btn btn-part-delete" type="button" data-id="${item.id}">삭제</button>
                  </div>
                </td>
              </tr>
            `).join('');

        setHtml('part-body', rows);

        document.querySelectorAll('.btn-part-select').forEach(btn => {
          btn.addEventListener('click', () => {
            state.selectedPartId = Number(btn.dataset.id);
            renderPartSelect();
            loadPartMembers();
          });
        });

        document.querySelectorAll('.btn-edit').forEach(btn => {
          btn.addEventListener('click', async () => {
            const id = Number(btn.dataset.id);
            const current = state.parts.find(i => i.id === id);
            if (!current) return;

            const name = await uiPrompt({ title: '파트 수정', label: '파트명', defaultValue: current.name });
            if (name === null) return;
            const orderRaw = await uiPrompt({ title: '파트 수정', label: '정렬순서', defaultValue: String(current.displayOrder) });
            if (orderRaw === null) return;
            const order = Number(orderRaw);
            if (Number.isNaN(order)) {
              await uiAlert('정렬순서는 숫자여야 합니다.');
              return;
            }

            try {
              await putJson(`/api/parts/${id}`, {
                code: current.code,
                name: name.trim(),
                displayOrder: order,
                active: current.active
              });
              await loadParts();
            } catch (error) {
              await uiAlert('수정 실패: ' + error.message);
            }
          });
        });

        document.querySelectorAll('.btn-part-toggle-active').forEach(btn => {
          btn.addEventListener('click', async () => {
            const id = Number(btn.dataset.id);
            const current = state.parts.find(i => i.id === id);
            if (!current) return;
            const nextActive = !current.active;
            const confirmMsg = nextActive ? '활성화 처리하시겠습니까?' : '비활성 처리하시겠습니까?';
            if (!await uiConfirm(confirmMsg)) return;
            try {
              await putJson(`/api/parts/${id}`, {
                code: current.code,
                name: current.name,
                displayOrder: current.displayOrder,
                active: nextActive
              });
              await loadParts();
              await loadPartMembers();
            } catch (error) {
              await uiAlert('상태 변경 실패: ' + error.message);
            }
          });
        });

        document.querySelectorAll('.btn-part-delete').forEach(btn => {
          btn.addEventListener('click', async () => {
            const id = Number(btn.dataset.id);
            if (!await uiConfirm('정말 삭제하시겠습니까? 파트와 매핑된 파트 구성원도 함께 삭제됩니다.')) return;
            try {
              await jsonRequest(`/api/parts/${id}/hard`, { method: 'DELETE' });
              if (state.selectedPartId === id) state.selectedPartId = null;
              await loadParts();
              await loadPartMembers();
            } catch (error) {
              await uiAlert('삭제 실패: ' + error.message);
            }
          });
        });
      };

      const renderMemberTable = () => {
        renderMemberSortIndicators();
        setText('member-total-count', `전체 ${state.members.length}건`, '전체 0건');
        if (!state.members.length) {
          setHtml('member-body', '<tr><td colspan="5" class="empty">등록된 구성원이 없습니다.</td></tr>');
          return;
        }

        const rows = sortMembers(state.members).map(item => `
          <tr>
            <td>${item.empNo ?? '-'}</td>
            <td>${item.name}</td>
            <td>${item.title ?? '-'}</td>
            <td>${item.active ? '활성' : '비활성'}</td>
                <td>
                  <div class="cta">
                    <button class="btn btn-member-edit" type="button" data-id="${item.id}">수정</button>
                    <button class="btn btn-member-toggle-active" type="button" data-id="${item.id}" data-active="${item.active}">${item.active ? '비활성' : '활성화'}</button>
                    <button class="btn btn-member-delete" type="button" data-id="${item.id}">삭제</button>
                  </div>
                </td>
              </tr>
            `).join('');

        setHtml('member-body', rows);

        document.querySelectorAll('.btn-member-edit').forEach(btn => {
          btn.addEventListener('click', async () => {
            const id = Number(btn.dataset.id);
            const current = state.members.find(i => i.id === id);
            if (!current) return;

            const title = await uiPrompt({ title: '구성원 수정', label: '직책', defaultValue: current.title || '' });
            if (title === null) return;

            try {
              await putJson(`/api/members/${id}`, {
                empNo: current.empNo,
                name: current.name,
                title: title.trim(),
                phone: current.phone,
                email: current.email,
                active: current.active
              });
              await loadMembers();
            } catch (error) {
              await uiAlert('수정 실패: ' + error.message);
            }
          });
        });

        document.querySelectorAll('.btn-member-toggle-active').forEach(btn => {
          btn.addEventListener('click', async () => {
            const id = Number(btn.dataset.id);
            const current = state.members.find(i => i.id === id);
            if (!current) return;
            const nextActive = !current.active;
            const confirmMsg = nextActive ? '활성화 처리하시겠습니까?' : '비활성 처리하시겠습니까?';
            if (!await uiConfirm(confirmMsg)) return;
            try {
              await putJson(`/api/members/${id}`, {
                empNo: current.empNo,
                name: current.name,
                title: current.title,
                phone: current.phone,
                email: current.email,
                active: nextActive
              });
              await loadMembers();
              await loadPartMembers();
            } catch (error) {
              await uiAlert('상태 변경 실패: ' + error.message);
            }
          });
        });

        document.querySelectorAll('.btn-member-delete').forEach(btn => {
          btn.addEventListener('click', async () => {
            const id = Number(btn.dataset.id);
            if (!await uiConfirm('정말 삭제하시겠습니까? 파트 구성원 매핑도 함께 삭제됩니다.')) return;
            try {
              await jsonRequest(`/api/members/${id}/hard`, { method: 'DELETE' });
              await loadMembers();
              await loadPartMembers();
            } catch (error) {
              await uiAlert('삭제 실패: ' + error.message);
            }
          });
        });
      };

      const loadPartMembers = async () => {
        const partId = Number(byId('pmPart').value || state.selectedPartId || 0);
        if (!partId) {
          setHtml('part-member-body', '<tr><td colspan="7" class="empty">파트를 선택해주세요.</td></tr>');
          return;
        }

        state.selectedPartId = partId;
        renderPartSelect();

        try {
          const items = await getJson(`/api/parts/${partId}/members?activeOnly=false`);
          if (!items || items.length === 0) {
            setHtml('part-member-body', '<tr><td colspan="7" class="empty">등록된 파트 구성원이 없습니다.</td></tr>');
            return;
          }

          const rows = items.map(item => `
            <tr>
              <td>${item.memberName ?? '-'}</td>
              <td>${item.memberTitle ?? '-'}</td>
              <td>${item.roleInPart ?? '-'}</td>
              <td>${item.primary ? '대표' : '-'}</td>
              <td>${item.sortOrder}</td>
              <td>${item.active ? '활성' : '비활성'}</td>
              <td>
                <div class="cta">
                  <button class="btn btn-pm-edit" type="button" data-id="${item.id}" data-part-id="${item.partId}" data-member-id="${item.memberId}" data-role="${item.roleInPart ?? ''}" data-order="${item.sortOrder}" data-primary="${item.primary}" data-active="${item.active}">수정</button>
                  <button class="btn btn-pm-off" type="button" data-id="${item.id}" data-part-id="${item.partId}">비활성</button>
                  <button class="btn btn-pm-delete" type="button" data-id="${item.id}" data-part-id="${item.partId}">삭제</button>
                </div>
              </td>
            </tr>
          `).join('');

          setHtml('part-member-body', rows);

          document.querySelectorAll('.btn-pm-edit').forEach(btn => {
            btn.addEventListener('click', async () => {
              const mappingId = Number(btn.dataset.id);
              const currentPartId = Number(btn.dataset.partId);
              const role = await uiPrompt({ title: '파트 구성원 수정', label: '파트 역할', defaultValue: btn.dataset.role || '' });
              if (role === null) return;
              const orderRaw = await uiPrompt({ title: '파트 구성원 수정', label: '정렬순서', defaultValue: btn.dataset.order || '0' });
              if (orderRaw === null) return;
              const order = Number(orderRaw);
              if (Number.isNaN(order)) {
                await uiAlert('정렬순서는 숫자여야 합니다.');
                return;
              }

              try {
                await putJson(`/api/parts/${currentPartId}/members/${mappingId}`, {
                  memberId: Number(btn.dataset.memberId),
                  roleInPart: role.trim(),
                  sortOrder: order,
                  primary: btn.dataset.primary === 'true',
                  active: btn.dataset.active === 'true'
                });
                loadPartMembers();
              } catch (error) {
                await uiAlert('수정 실패: ' + error.message);
              }
            });
          });

          document.querySelectorAll('.btn-pm-off').forEach(btn => {
            btn.addEventListener('click', async () => {
              const mappingId = Number(btn.dataset.id);
              const currentPartId = Number(btn.dataset.partId);
              if (!await uiConfirm('비활성 처리하시겠습니까?')) return;
              try {
                await jsonRequest(`/api/parts/${currentPartId}/members/${mappingId}`, { method: 'DELETE' });
                loadPartMembers();
              } catch (error) {
                await uiAlert('비활성 처리 실패: ' + error.message);
              }
            });
          });

          document.querySelectorAll('.btn-pm-delete').forEach(btn => {
            btn.addEventListener('click', async () => {
              const mappingId = Number(btn.dataset.id);
              const currentPartId = Number(btn.dataset.partId);
              if (!await uiConfirm('이 파트 구성원을 삭제하시겠습니까?')) return;
              try {
                await jsonRequest(`/api/parts/${currentPartId}/members/${mappingId}/hard`, { method: 'DELETE' });
                loadPartMembers();
              } catch (error) {
                await uiAlert('삭제 실패: ' + error.message);
              }
            });
          });
        } catch (error) {
          setHtml('part-member-body', `<tr><td colspan="7" class="empty">조회 실패: ${error.message}</td></tr>`);
        }
      };

      byId('part-form').addEventListener('submit', async (event) => {
        event.preventDefault();
        const payload = {
          code: (byId('partCode').value || '').trim(),
          name: (byId('partName').value || '').trim(),
          displayOrder: Number(byId('displayOrder').value || 0),
          active: byId('activeYn').value === 'true'
        };

        try {
          await postJson('/api/parts', payload);
          event.target.reset();
          byId('displayOrder').value = 0;
          byId('activeYn').value = 'true';
          await loadParts();
          loadPartMembers();
        } catch (error) {
          await uiAlert('저장 실패: ' + error.message);
        }
      });

      byId('member-form').addEventListener('submit', async (event) => {
        event.preventDefault();
        const empNo = (byId('memberEmpNo').value || '').trim();
        if (empNo && state.members.some(m => (m.empNo || '').trim() === empNo)) {
          await uiAlert('이미 사용 중인 사번입니다.');
          return;
        }
        const payload = {
          empNo: empNo || null,
          name: (byId('memberName').value || '').trim(),
          title: (byId('memberTitle').value || '').trim() || null,
          phone: null,
          email: null,
          active: byId('memberActiveYn').value === 'true'
        };

        try {
          await postJson('/api/members', payload);
          event.target.reset();
          byId('memberActiveYn').value = 'true';
          await loadMembers();
        } catch (error) {
          await uiAlert('저장 실패: ' + error.message);
        }
      });

      byId('pmPart').addEventListener('change', () => {
        state.selectedPartId = Number(byId('pmPart').value || 0) || null;
        loadPartMembers();
      });

      byId('part-member-form').addEventListener('submit', async (event) => {
        event.preventDefault();
        const partId = Number(byId('pmPart').value || state.selectedPartId || 0);
        if (!partId) {
          await uiAlert('파트를 먼저 선택해주세요.');
          return;
        }

        const payload = {
          memberId: Number(byId('pmMember').value || 0),
          roleInPart: (byId('pmRole').value || '').trim() || null,
          sortOrder: Number(byId('pmOrder').value || 0),
          primary: byId('pmPrimary').value === 'true',
          active: byId('pmActive').value === 'true'
        };

        if (!payload.memberId) {
          await uiAlert('구성원을 선택해주세요.');
          return;
        }

        try {
          await postJson(`/api/parts/${partId}/members`, payload);
          byId('pmRole').value = '';
          byId('pmOrder').value = 0;
          byId('pmPrimary').value = 'false';
          byId('pmActive').value = 'true';
          loadPartMembers();
        } catch (error) {
          await uiAlert('저장 실패: ' + error.message);
        }
      });

      document.querySelectorAll('[data-member-sort]').forEach(btn => {
        btn.addEventListener('click', () => {
          const key = btn.dataset.memberSort;
          if (!key) return;
          if (state.memberSort.key === key) {
            state.memberSort.direction = state.memberSort.direction === 'asc' ? 'desc' : 'asc';
          } else {
            state.memberSort.key = key;
            state.memberSort.direction = 'asc';
          }
          renderMemberTable();
        });
      });

      document.querySelectorAll('[data-part-sort]').forEach(btn => {
        btn.addEventListener('click', () => {
          const key = btn.dataset.partSort;
          if (!key) return;
          if (state.partSort.key === key) {
            state.partSort.direction = state.partSort.direction === 'asc' ? 'desc' : 'asc';
          } else {
            state.partSort.key = key;
            state.partSort.direction = 'asc';
          }
          renderPartTable();
        });
      });

      Promise.all([loadParts(), loadMembers()]).then(() => loadPartMembers());
    </script>
  </body>
</html>
