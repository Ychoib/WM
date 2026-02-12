<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<!doctype html>
<html lang="ko">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>알림 정책 관리</title>
    <link rel="stylesheet" href="/css/common.css" />
  </head>
  <body>
    <div class="page">
      <div class="topbar">
        <div class="brand">
          <div class="logo" aria-hidden="true"></div>
          <div>
            <h1>알림 정책 관리</h1>
            <div class="subtitle">정책 이름과 알림 주기를 관리합니다.</div>
          </div>
        </div>
        <div class="cta">
          <a class="btn" href="/">메인</a>
          <a class="btn" href="/expiry">만료 리스크</a>
          <a class="btn" href="/docs">파트 문서</a>
        </div>
      </div>

      <div class="grid cols-1-1">
        <div class="card">
          <div class="section-title">
            <h2>정책 추가</h2>
          </div>
          <form class="form" id="policy-form">
            <div>
              <label for="policyName">정책 이름</label>
              <input id="policyName" placeholder="예: D-90/60/30" required />
            </div>
            <div>
              <label for="policySchedule">알림 주기</label>
              <input id="policySchedule" placeholder="예: 90,60,30" required />
            </div>
            <div class="actions">
              <button class="btn primary" type="submit">추가</button>
            </div>
          </form>
        </div>

        <div class="card">
          <div class="section-title">
            <h2>정책 목록</h2>
          </div>
          <div class="policy-list" id="policy-list">
            <div class="policy-item"><span>로딩 중...</span><span>-</span></div>
          </div>
        </div>
      </div>
    </div>

    <script src="/js/common.js"></script>
    <script>
      const listEl = byId('policy-list');
      const form = byId('policy-form');

      const renderList = (items) => {
        if (!items || items.length === 0) {
          listEl.innerHTML = '<div class="policy-item"><span>등록된 정책이 없습니다</span><span>-</span></div>';
          return;
        }
        listEl.innerHTML = items.map(p => `
          <div class="policy-item">
            <span>${p.name}</span>
            <span>${p.schedule}</span>
          </div>
        `).join('');
      };

      const load = () => getJson('/api/policies')
        .then(data => renderList(data))
        .catch(() => renderList([]));

      form.addEventListener('submit', async (event) => {
        event.preventDefault();
        const payload = {
          name: byId('policyName').value.trim(),
          schedule: byId('policySchedule').value.trim()
        };
        try {
          await postJson('/api/policies', payload);
          form.reset();
          load();
        } catch (error) {
          await uiAlert('추가 실패: ' + error.message);
        }
      });

      load();
    </script>
  </body>
</html>
