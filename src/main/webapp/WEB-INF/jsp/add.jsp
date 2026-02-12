<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<!doctype html>
<html lang="ko">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>자산 등록</title>
    <link rel="stylesheet" href="/css/common.css" />
  </head>
  <body>
    <div class="page">
      <div class="topbar">
        <div class="brand">
          <div class="logo" aria-hidden="true"></div>
          <div>
            <h1>자산 등록</h1>
            <div class="subtitle">만료일이 있는 자산을 등록하고 리스크를 관리합니다.</div>
          </div>
        </div>
        <div class="cta">
          <a class="btn" href="/">메인</a>
          <a class="btn" href="/expiry">만료 리스크</a>
          <a class="btn" href="/docs">파트 문서</a>
        </div>
      </div>

      <div class="grid cols-2-1">
        <div class="card">
          <div class="section-title">
            <h2>기본 정보</h2>
            <span class="tag warning">필수</span>
          </div>
          <form class="form" id="asset-form">
            <div>
              <label for="assetName">자산명</label>
              <input id="assetName" name="assetName" placeholder="예: Gateway SSL" required />
            </div>
            <div class="row">
              <div>
                <label for="assetType">유형</label>
                <select id="assetType" name="assetType">
                  <option>SSL</option>
                  <option>License</option>
                  <option>Domain</option>
                  <option>Contract</option>
                  <option>Other</option>
                </select>
              </div>
              <div>
                <label for="expireDate">만료일</label>
                <input id="expireDate" name="expireDate" type="date" required />
              </div>
            </div>
            <div class="row">
              <div>
                <label for="partId">파트</label>
                <select id="partId" name="partId"></select>
              </div>
              <div></div>
            </div>
            <div class="row">
              <div>
                <label for="importance">중요도</label>
                <select id="importance" name="importance">
                  <option>High</option>
                  <option>Medium</option>
                  <option>Low</option>
                </select>
              </div>
              <div>
                <label for="notifyPolicy">알림 정책</label>
                <select id="notifyPolicy" name="notifyPolicy"></select>
              </div>
            </div>
            <div>
              <label for="related">연결 서비스</label>
              <input id="related" name="related" placeholder="예: ERP, Gateway, Billing" />
            </div>
            <div>
              <label for="memo">메모</label>
              <textarea id="memo" name="memo" placeholder="갱신 조건, 구매처, 비용 등"></textarea>
            </div>
            <div class="actions">
              <button class="btn" type="reset">초기화</button>
              <button class="btn primary" type="submit">등록</button>
            </div>
          </form>
        </div>

        <div class="card">
          <div class="section-title">
            <h2>최근 등록</h2>
            <span class="tag good">신규</span>
          </div>
          <div class="side-list" id="recent-list">
            <div class="side-item">
              <div class="title">로딩 중...</div>
              <div class="meta">-</div>
            </div>
          </div>
          <p class="hint" style="margin-top: 14px;">최근 등록된 자산을 표시합니다.</p>
        </div>
      </div>
    </div>

    <script src="/js/common.js"></script>
    <script>
      const form = byId('asset-form');
      form.addEventListener('submit', async (event) => {
        event.preventDefault();
        const payload = {
          name: byId('assetName').value.trim(),
          type: byId('assetType').value,
          expiresAt: byId('expireDate').value,
          partId: Number(byId('partId').value || 0),
          importance: byId('importance').value,
          notifyPolicy: byId('notifyPolicy').value,
          relatedServices: byId('related').value.trim(),
          memo: byId('memo').value.trim()
        };
        if (!payload.partId) {
          await uiAlert('파트를 선택해주세요.');
          return;
        }

        try {
          const data = await postJson('/api/assets', payload);
          const id = data?.id;
          if (id) {
            window.location.href = `/edit?id=${id}`;
          } else {
            form.reset();
            await uiAlert('등록 완료');
          }
        } catch (error) {
          await uiAlert('등록 실패: ' + error.message);
        }
      });

      const renderRecent = (items) => {
        if (!items || items.length === 0) {
          setHtml('recent-list', '<div class="side-item"><div class="title">등록된 자산 없음</div><div class="meta">-</div></div>');
          return;
        }
        const rows = items.map(item => `
          <div class="side-item">
            <div class="title"><a href="/edit?id=${item.id}" style="color: inherit; text-decoration: none;">${item.name}</a></div>
            <div class="meta">${item.type} · 만료 ${item.expiresAt}</div>
          </div>
        `).join('');
        setHtml('recent-list', rows);
      };

      getJson('/api/assets/recent?limit=3')
        .then(data => renderRecent(data))
        .catch(() => renderRecent([]));

      const partSelect = byId('partId');
      const renderParts = (items) => {
        const activeParts = (items || []).filter(p => p.active);
        if (!activeParts.length) {
          partSelect.innerHTML = '<option value="">등록된 활성 파트 없음</option>';
          partSelect.disabled = true;
          return;
        }
        partSelect.disabled = false;
        partSelect.innerHTML = activeParts
          .map(p => `<option value="${p.id}">${p.name} (${p.code})</option>`)
          .join('');
      };

      getJson('/api/parts?activeOnly=true')
        .then(data => renderParts(data))
        .catch(() => renderParts([]));

      const policySelect = byId('notifyPolicy');
      const renderPolicies = (items) => {
        const options = ['미설정', ...(items || []).map(p => p.name)];
        policySelect.innerHTML = options.map(name => `<option>${name}</option>`).join('');
      };

      getJson('/api/policies')
        .then(data => renderPolicies(data))
        .catch(() => renderPolicies([]));
    </script>
  </body>
</html>
