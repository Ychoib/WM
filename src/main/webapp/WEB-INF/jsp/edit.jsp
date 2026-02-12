<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<!doctype html>
<html lang="ko">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>자산 수정</title>
    <link rel="stylesheet" href="/css/common.css" />
  </head>
  <body>
    <div class="page">
      <div class="topbar">
        <div class="brand">
          <div class="logo" aria-hidden="true"></div>
          <div>
            <h1>자산 수정</h1>
            <div class="subtitle" id="asset-title">자산 정보를 수정하세요</div>
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
            <span class="tag good">수정</span>
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
              <button class="btn" type="button" id="cancel-btn">취소</button>
              <button class="btn primary" type="submit">저장</button>
            </div>
          </form>
        </div>

        <div class="card">
          <div class="section-title">
            <h2>안내</h2>
          </div>
          <div class="side-list">
            <div class="side-item">
              <div class="title">수정 이력</div>
              <div class="meta">현재 화면은 최신 등록 기준으로 표시됩니다.</div>
            </div>
            <div class="side-item">
              <div class="title">알림 정책</div>
              <div class="meta">정책이 미설정이면 대시보드에서 경고로 표시됩니다.</div>
            </div>
          </div>
          <p class="hint" style="margin-top: 14px;">이 화면은 `/edit?id=자산ID` 형태로 접근합니다.</p>
        </div>
      </div>
    </div>

    <script src="/js/common.js"></script>
    <script>
      const params = new URLSearchParams(window.location.search);
      const assetId = params.get('id');
      const form = byId('asset-form');
      const title = byId('asset-title');

      const setValue = (id, value) => {
        const el = byId(id);
        if (el) el.value = value ?? '';
      };

      const loadAsset = async () => {
        if (!assetId) {
          await uiAlert('자산 ID가 없습니다.');
          window.location.href = '/expiry';
          return;
        }
        try {
          const data = await getJson(`/api/assets/${assetId}`);
          title.textContent = `${data.name} · ${data.type}`;
          setValue('assetName', data.name);
          setValue('assetType', data.type);
          setValue('expireDate', data.expiresAt);
          setValue('partId', data.partId);
          setValue('importance', data.importance ?? 'Medium');
          setValue('notifyPolicy', data.notifyPolicy ?? '미설정');
          setValue('related', data.relatedServices);
          setValue('memo', data.memo);
        } catch (error) {
          await uiAlert('자산을 불러오지 못했습니다.');
          window.location.href = '/expiry';
        }
      };

      const policySelect = byId('notifyPolicy');
      const renderPolicies = (items) => {
        const options = ['미설정', ...(items || []).map(p => p.name)];
        policySelect.innerHTML = options.map(name => `<option>${name}</option>`).join('');
      };

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

      Promise.all([
        getJson('/api/policies').then(data => renderPolicies(data)).catch(() => renderPolicies([])),
        getJson('/api/parts?activeOnly=true').then(data => renderParts(data)).catch(() => renderParts([]))
      ]).finally(loadAsset);

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
          await putJson(`/api/assets/${assetId}`, payload);
          await uiAlert('저장 완료');
        } catch (error) {
          await uiAlert('저장 실패: ' + error.message);
        }
      });

      byId('cancel-btn').addEventListener('click', () => {
        window.location.href = '/expiry';
      });
    </script>
  </body>
</html>
