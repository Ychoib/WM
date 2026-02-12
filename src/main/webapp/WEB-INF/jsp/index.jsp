<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<!doctype html>
<html lang="ko">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>GRS IT 서비스 대시보드</title>
    <link rel="stylesheet" href="/css/common.css" />
    <style>
      .hero {
        grid-template-columns: 1fr;
      }
      .quick-actions.only-buttons {
        display: grid;
        grid-template-columns: repeat(3, minmax(0, 1fr));
        gap: 10px;
      }
      .quick-actions.only-buttons .action-item {
        padding: 12px;
        border-radius: 12px;
        border: 1px solid var(--stroke);
        background: rgba(255, 255, 255, 0.02);
      }
      .quick-actions.only-buttons .btn {
        justify-content: center;
        font-weight: 600;
        width: 100%;
        font-size: 14px;
        padding: 12px 14px;
        border-radius: 11px;
      }
      .quick-actions.only-buttons .action-help {
        margin: 8px 2px 0;
        font-size: 12px;
        color: var(--muted);
        line-height: 1.4;
      }
      .btn.tone-expiry { background: linear-gradient(135deg, #ff7a59, #ffb36a); color: #2b1400; border-color: transparent; }
      .btn.tone-add { background: linear-gradient(135deg, #45c4ff, #73e1ff); color: #032231; border-color: transparent; }
      .btn.tone-parts { background: linear-gradient(135deg, #67d98b, #9be15d); color: #10280d; border-color: transparent; }
      .btn.tone-policy { background: linear-gradient(135deg, #f7a7ff, #caa6ff); color: #280f3b; border-color: transparent; }
      .btn.tone-org { background: linear-gradient(135deg, #ffd166, #ffe08a); color: #2e2200; border-color: transparent; }
      .btn.tone-files { background: linear-gradient(135deg, #8ea2ff, #b0bfff); color: #12183d; border-color: transparent; }
      .btn.tone-docs { background: linear-gradient(135deg, #66e0c2, #8cf5d2); color: #05261f; border-color: transparent; }
      @media (max-width: 980px) {
        .quick-actions.only-buttons { grid-template-columns: repeat(2, minmax(0, 1fr)); }
      }
      @media (max-width: 640px) {
        .quick-actions.only-buttons { grid-template-columns: 1fr; }
      }
    </style>
  </head>
  <body>
    <div class="page">
      <div class="topbar">
        <div class="brand">
          <div class="logo" aria-hidden="true"></div>
          <div>
            <h1>GRS IT 서비스 대시보드</h1>
            <div class="subtitle">만료 리스크, 공용 파일, 파트 문서를 한 화면에서 확인합니다.</div>
          </div>
        </div>
      </div>

      <div class="grid cols-12">
        <div class="card hero">
          <div class="quick-actions only-buttons">
            <div class="action-item">
              <a class="btn tone-expiry" href="/expiry">만료 리스크 대시보드</a>
              <p class="action-help">파트별 만료 임박 자산과 리스크 현황을 확인합니다.</p>
            </div>
            <div class="action-item">
              <a class="btn tone-add" href="/add">자산 등록</a>
              <p class="action-help">새 자산을 등록하고 파트 및 만료일을 지정합니다.</p>
            </div>
            <div class="action-item">
              <a class="btn tone-parts" href="/parts">파트/구성원 마스터</a>
              <p class="action-help">파트와 구성원 정보를 등록하고 정렬/상태를 관리합니다.</p>
            </div>
            <div class="action-item">
              <a class="btn tone-policy" href="/policy">알림 정책</a>
              <p class="action-help">만료 사전 알림 기준(D-90/30 등) 정책을 관리합니다.</p>
            </div>
            <div class="action-item">
              <a class="btn tone-org" href="/org">조직도 관리</a>
              <p class="action-help">조직도를 편집하고 파트와 연결된 구조를 정리합니다.</p>
            </div>
            <div class="action-item">
              <a class="btn tone-files" href="/files">파일 탐색기</a>
              <p class="action-help">공용 파일을 검색하고 경로를 빠르게 찾습니다.</p>
            </div>
            <div class="action-item">
              <a class="btn tone-docs" href="/docs">파트 문서</a>
              <p class="action-help">파트별 운영 문서를 조회하고 이동합니다.</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </body>
</html>
