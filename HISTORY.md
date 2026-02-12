# HISTORY

## 2026-02-12

### 파트 문서 업로드/미리보기 기능 구현
- 파트 문서 업로드/조회/미리보기 API 추가
  - `src/main/java/com/example/wm/doc/PartDocumentController.java`
  - `src/main/java/com/example/wm/doc/PartDocumentRepository.java`
  - `src/main/java/com/example/wm/doc/PartDocumentItem.java`
  - `src/main/java/com/example/wm/doc/PartDocumentStoredItem.java`
  - `src/main/java/com/example/wm/doc/PartDocumentCreateRequest.java`
- 업로드 허용 형식 제한 적용 (`pdf`, `txt`, `md`, `jpg`, `jpeg`, `png`, `webp`)
  - 프론트 `accept` + 백엔드 확장자 검증 이중 적용
- 파트 문서 화면을 실제 데이터 연동형으로 개편
  - 파트 카드 선택
  - 문서 업로드 폼
  - 문서 목록
  - 파일 형식별 미리보기(iframe/image)
  - `src/main/webapp/WEB-INF/jsp/docs.jsp`
- 문서 저장 경로 설정 추가
  - `src/main/resources/application.properties`
  - `wm.docs.root-path=D:\\Study\\wm-docs`
- 문서 메타데이터 테이블/인덱스/FK 추가 (재실행 안전)
  - `sql/schema.sql`
## 2026-02-13

### 파트 문서 화면 목업 추가
- 페이지 라우트 추가: `/docs`
  - `src/main/java/com/example/wm/HomeController.java`
- 파트 문서 화면 추가 (인수인계서/운영 매뉴얼/장애 대응 카드 + 최근 문서 테이블 목업)
  - `src/main/webapp/WEB-INF/jsp/docs.jsp`
- 주요 화면 상단에 `파트 문서` 이동 메뉴 추가
  - `src/main/webapp/WEB-INF/jsp/index.jsp`
  - `src/main/webapp/WEB-INF/jsp/expiry.jsp`
  - `src/main/webapp/WEB-INF/jsp/policy.jsp`
  - `src/main/webapp/WEB-INF/jsp/files.jsp`
  - `src/main/webapp/WEB-INF/jsp/add.jsp`
  - `src/main/webapp/WEB-INF/jsp/edit.jsp`

### 한글 깨짐(인코딩 손상) 복구
- 손상된 JSP의 텍스트/태그/스크립트 문자열을 UTF-8 기준으로 복구
  - `src/main/webapp/WEB-INF/jsp/index.jsp`
  - `src/main/webapp/WEB-INF/jsp/expiry.jsp`
  - `src/main/webapp/WEB-INF/jsp/policy.jsp`
  - `src/main/webapp/WEB-INF/jsp/add.jsp`
  - `src/main/webapp/WEB-INF/jsp/edit.jsp`

### 운영 기록
- 서버 재기동 후 `http://localhost:8080` HTTP 200 응답 확인.
- `/expiry`, `/policy`, `/add` 화면의 한글 렌더링 정상 표시 확인.

### 파트 마스터 관리 기능 추가
- 파트 마스터 API 추가 (`조회/생성/수정/비활성`)
  - `src/main/java/com/example/wm/part/PartController.java`
  - `src/main/java/com/example/wm/part/PartRepository.java`
  - `src/main/java/com/example/wm/part/PartCreateRequest.java`
  - `src/main/java/com/example/wm/part/PartUpdateRequest.java`
  - `src/main/java/com/example/wm/part/PartItem.java`
- 파트 관리 화면 추가: `/parts`
  - `src/main/webapp/WEB-INF/jsp/parts.jsp`
  - `src/main/java/com/example/wm/HomeController.java`
- 파트 문서 화면을 파트 마스터 연동 방식으로 개편
  - `src/main/webapp/WEB-INF/jsp/docs.jsp`

### 조직도 마스터/편집 화면 추가
- 조직도 트리 테이블 및 초기 데이터(seed) 추가
  - `sql/schema.sql`
- 조직도 API 추가 (`조회/생성/수정/비활성/재정렬`)
  - `src/main/java/com/example/wm/org/OrgUnitController.java`
  - `src/main/java/com/example/wm/org/OrgUnitRepository.java`
  - `src/main/java/com/example/wm/org/OrgUnitItem.java`
  - `src/main/java/com/example/wm/org/OrgUnitCreateRequest.java`
  - `src/main/java/com/example/wm/org/OrgUnitUpdateRequest.java`
  - `src/main/java/com/example/wm/org/OrgUnitMoveItem.java`
  - `src/main/java/com/example/wm/org/OrgUnitReorderRequest.java`
- 조직도 관리 화면 추가: `/org` (드래그 이동, 이름/직책 변경, 하위 조직 추가, 삭제)
  - `src/main/webapp/WEB-INF/jsp/org.jsp`
  - `src/main/java/com/example/wm/HomeController.java`
- 메인 화면에 조직도 관리 진입 버튼 추가
  - `src/main/webapp/WEB-INF/jsp/index.jsp`
## 2026-02-12

### 파일 탐색기 초기 추가 (테스트 루트: `D:\Study`)
- 페이지 라우트 추가: `/files`
  - `src/main/java/com/example/wm/HomeController.java`
- 파일 목록 조회 API 추가: `/api/files?path=...`
  - `src/main/java/com/example/wm/file/FileController.java`
- 응답 모델 추가
  - `src/main/java/com/example/wm/file/FileEntry.java`
  - `src/main/java/com/example/wm/file/FileListResponse.java`
- 파일 탐색기 화면 추가 (목록 조회, 폴더 진입, 상위 이동, 새로고침)
  - `src/main/webapp/WEB-INF/jsp/files.jsp`
- 메인 화면에 파일 탐색기 진입 링크 추가
  - `src/main/webapp/WEB-INF/jsp/index.jsp`
- 파일 루트 설정값 추가
  - `src/main/resources/application.properties`
  - `wm.file.root-path=D:\\Study`

### 파일 탐색기 UI/동작 개선
- `[DIR]`, `[FILE]` 텍스트 대신 아이콘 표시로 변경
  - 폴더: `📁`
  - 파일: `📄`
  - `src/main/webapp/WEB-INF/jsp/files.jsp`
- 파일명 검색 입력창 + 검색 버튼 추가
  - API `keyword` 파라미터로 서버 측 파일명 필터링 지원
  - `src/main/java/com/example/wm/file/FileController.java`
  - `src/main/webapp/WEB-INF/jsp/files.jsp`
- 정렬 필터 UI 제거 후 헤더 더블클릭 정렬로 변경
  - 대상 컬럼: 이름, 종류, 크기, 수정일
  - 정렬 순환: 기본 -> 오름차순 -> 내림차순 -> 기본
  - 헤더 상태 표시: `▲` / `▼`
  - `src/main/webapp/WEB-INF/jsp/files.jsp`
- 폴더 열기 + 경로 복사 기능 추가
  - 상단: 현재 폴더 열기, 현재 경로 복사
  - 목록 행: 폴더 열기, 경로 복사
  - 폴더 열기는 `file://` URL 방식으로 동작
  - 경로 복사는 클립보드 API 사용(미지원 시 `prompt` 백업)
  - `src/main/webapp/WEB-INF/jsp/files.jsp`
- 작업 컬럼 버튼 크기 축소
  - 목록 행 버튼을 소형 스타일(`btn-compact`)로 변경해 세로 간격 축소
  - `src/main/webapp/WEB-INF/jsp/files.jsp`
- 경로 복사 알림 방식 변경
  - `alert` 대신 우하단 토스트 메시지(1.5초 후 자동 사라짐)로 변경
  - `src/main/webapp/WEB-INF/jsp/files.jsp`
- 경로 복사 팝업 완전 제거
  - 복사 실패 시에도 `prompt`를 띄우지 않고 토스트로만 성공/실패 안내
  - `src/main/webapp/WEB-INF/jsp/files.jsp`

### 운영 기록
- 변경 적용 후 로컬 서버 재기동 및 `http://localhost:8080` HTTP 200 응답 확인.

### 운영 경로 전환 예정
- 설정값만 변경하면 공용 서버 경로로 전환 가능
  - `wm.file.root-path=\\\\10.66.2.200\\`


## 2026-02-13

### 만료 리스크를 파트 기준으로 전환
- 만료 자산 등록/수정 요청 모델을 `partId` 필수 구조로 변경
  - `src/main/java/com/example/wm/asset/AssetCreateRequest.java`
  - `src/main/java/com/example/wm/asset/AssetUpdateRequest.java`
  - `src/main/java/com/example/wm/asset/AssetController.java`
- 자산 상세/목록 응답을 `partId`, `partName` 중심으로 변경
  - `src/main/java/com/example/wm/asset/AssetDetail.java`
  - `src/main/java/com/example/wm/asset/AssetRepository.java`
- 대시보드 집계/목록/최근변경을 `owner_team` 기반에서 `part` 기반으로 전환
  - `src/main/java/com/example/wm/dashboard/DashboardRepository.java`
  - `src/main/java/com/example/wm/dashboard/DashboardItem.java`
  - `src/main/java/com/example/wm/dashboard/RecentChange.java`
  - `src/main/java/com/example/wm/dashboard/TeamRisk.java`
- 스키마에 `assets.part_id` 추가, FK 설정, 기존 데이터 백필(owner_team -> part_name 매핑)
  - `sql/schema.sql`
- UI 문구/필터를 담당 -> 파트로 전환
  - `src/main/webapp/WEB-INF/jsp/expiry.jsp`
  - `src/main/webapp/WEB-INF/jsp/add.jsp`
  - `src/main/webapp/WEB-INF/jsp/edit.jsp`

### 파트/구성원 마스터 목록 UX 개선
- `파트 목록`, `구성원 마스터 목록`에 전체 건수 태그 추가
- `파트 목록`에 컬럼 정렬(코드/파트명/정렬순서/상태) 추가
  - `src/main/webapp/WEB-INF/jsp/parts.jsp`

### 메인 대시보드 버튼 재정리
- 메인(`/`)을 버튼 중심 레이아웃으로 정리하고 기능 진입 동선 재배치
- 빠른 이동 텍스트 영역 제거, 액션 버튼만 노출
- 버튼 크기 확대 및 버튼별 설명 텍스트 추가(색상은 기능별 유지)
  - `src/main/webapp/WEB-INF/jsp/index.jsp`

### 운영 확인
- 애플리케이션 재기동 후 `http://localhost:8080` HTTP 200 응답 확인