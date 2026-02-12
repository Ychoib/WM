<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<!doctype html>
<html lang="ko">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>공용 파일 탐색기</title>
    <link rel="stylesheet" href="/css/common.css" />
    <style>
      .row-actions {
        display: flex;
        gap: 6px;
        flex-wrap: wrap;
      }

      .btn-compact {
        padding: 5px 8px;
        font-size: 11px;
        border-radius: 8px;
      }

      .toast {
        position: fixed;
        right: 18px;
        bottom: 18px;
        max-width: 320px;
        padding: 8px 10px;
        border-radius: 10px;
        border: 1px solid var(--stroke);
        background: rgba(19, 26, 46, 0.96);
        color: var(--text);
        font-size: 12px;
        opacity: 0;
        transform: translateY(8px);
        pointer-events: none;
        transition: opacity 0.18s ease, transform 0.18s ease;
        z-index: 9999;
      }

      .toast.show {
        opacity: 1;
        transform: translateY(0);
      }
    </style>
  </head>
  <body>
    <div class="page">
      <div class="topbar">
        <div class="brand">
          <div class="logo" aria-hidden="true"></div>
          <div>
            <h1>공용 파일 탐색기</h1>
            <div class="subtitle">테스트 경로: D:\Study</div>
          </div>
        </div>
        <div class="cta">
          <a class="btn" href="/">메인</a>
          <a class="btn" href="/docs">파트 문서</a>
          <button class="btn" id="btn-refresh" type="button">새로고침</button>
        </div>
      </div>

      <div class="grid cols-12">
        <div class="card full-table">
          <div class="section-title">
            <h2>파일 목록</h2>
            <span class="tag" id="current-path">/</span>
          </div>
          <div class="cta" style="margin-bottom: 12px;">
            <input id="search-keyword" placeholder="파일명 검색" style="max-width: 240px;" />
            <button class="btn" id="btn-search" type="button">검색</button>
            <button class="btn" id="btn-up" type="button">상위 폴더</button>
            <button class="btn" id="btn-open-current" type="button">현재 폴더 열기</button>
            <button class="btn" id="btn-copy-current" type="button">현재 경로 복사</button>
          </div>
          <table class="table">
            <thead>
              <tr>
                <th class="sortable" data-sort-field="name" title="더블클릭으로 정렬">이름</th>
                <th class="sortable" data-sort-field="type" title="더블클릭으로 정렬">종류</th>
                <th class="sortable" data-sort-field="size" title="더블클릭으로 정렬">크기</th>
                <th class="sortable" data-sort-field="modifiedAt" title="더블클릭으로 정렬">수정일</th>
                <th>작업</th>
              </tr>
            </thead>
            <tbody id="file-body">
              <tr>
                <td colspan="5" class="empty">목록을 불러오는 중...</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    <div id="toast" class="toast" role="status" aria-live="polite"></div>

    <script src="/js/common.js"></script>
    <script>
      const state = {
        rootPath: "",
        currentPath: "",
        parentPath: null,
        keyword: "",
        sortField: "",
        sortOrder: "",
        entries: []
      };

      const SORT_NONE = "";
      const SORT_ASC = "asc";
      const SORT_DESC = "desc";
      let toastTimer = null;

      const showToast = (message) => {
        const toast = byId("toast");
        if (!toast) return;
        toast.textContent = message;
        toast.classList.add("show");
        if (toastTimer) {
          clearTimeout(toastTimer);
        }
        toastTimer = setTimeout(() => {
          toast.classList.remove("show");
        }, 1500);
      };

      const copyUsingExecCommand = (text) => {
        const textarea = document.createElement("textarea");
        textarea.value = text;
        textarea.setAttribute("readonly", "");
        textarea.style.position = "fixed";
        textarea.style.top = "-9999px";
        document.body.appendChild(textarea);
        textarea.select();
        const ok = document.execCommand("copy");
        document.body.removeChild(textarea);
        return ok;
      };

      const formatBytes = (bytes) => {
        if (!bytes) return "-";
        const units = ["B", "KB", "MB", "GB", "TB"];
        let size = bytes;
        let unit = 0;
        while (size >= 1024 && unit < units.length - 1) {
          size /= 1024;
          unit += 1;
        }
        return `${size.toFixed(size >= 10 ? 0 : 1)} ${units[unit]}`;
      };

      const toWindowsPath = (relativePath = "") => {
        const root = (state.rootPath || "").replace(/[\\/]+$/, "");
        if (!relativePath) return root;
        return `${root}\\${relativePath.replaceAll("/", "\\")}`;
      };

      const toFileUrl = (windowsPath) => {
        const normalized = (windowsPath || "").replaceAll("\\", "/");
        if (normalized.startsWith("//")) {
          return encodeURI(`file:${normalized}`);
        }
        return encodeURI(`file:///${normalized}`);
      };

      const openPath = (windowsPath) => {
        if (!windowsPath) return;
        window.open(toFileUrl(windowsPath), "_blank");
      };

      // 복사 성공/실패 모두 토스트로만 안내하고, alert/prompt는 사용하지 않는다.
      const copyText = async (text) => {
        if (!text) return;
        try {
          await navigator.clipboard.writeText(text);
          showToast("경로를 복사했습니다.");
        } catch (error) {
          const fallbackOk = copyUsingExecCommand(text);
          showToast(fallbackOk ? "경로를 복사했습니다." : "경로 복사에 실패했습니다.");
        }
      };

      const cycleSort = (field) => {
        if (state.sortField !== field) {
          state.sortField = field;
          state.sortOrder = SORT_ASC;
          return;
        }
        if (state.sortOrder === SORT_NONE) {
          state.sortOrder = SORT_ASC;
          return;
        }
        if (state.sortOrder === SORT_ASC) {
          state.sortOrder = SORT_DESC;
          return;
        }
        state.sortField = "";
        state.sortOrder = SORT_NONE;
      };

      const compareEntries = (a, b) => {
        let result = 0;
        switch (state.sortField) {
          case "type":
            result = (a.directory === b.directory) ? 0 : (a.directory ? -1 : 1);
            break;
          case "size":
            result = (a.size ?? 0) - (b.size ?? 0);
            break;
          case "modifiedAt":
            result = (a.modifiedAt ?? "").localeCompare(b.modifiedAt ?? "");
            break;
          case "name":
            result = (a.name ?? "").localeCompare(b.name ?? "", "ko", { sensitivity: "base" });
            break;
          default:
            result = 0;
            break;
        }
        return state.sortOrder === SORT_DESC ? -result : result;
      };

      const sortLabelMap = {
        name: "이름",
        type: "종류",
        size: "크기",
        modifiedAt: "수정일"
      };

      const renderSortHeaders = () => {
        document.querySelectorAll("th.sortable").forEach((th) => {
          const baseLabel = sortLabelMap[th.dataset.sortField] || "";
          if (th.dataset.sortField !== state.sortField || state.sortOrder === SORT_NONE) {
            th.textContent = baseLabel;
            return;
          }
          th.textContent = state.sortOrder === SORT_ASC ? `${baseLabel} ▲` : `${baseLabel} ▼`;
        });
      };

      const bindRowActions = () => {
        document.querySelectorAll(".folder-link").forEach((link) => {
          link.addEventListener("click", (event) => {
            event.preventDefault();
            loadFiles(link.dataset.path || "");
          });
        });

        document.querySelectorAll(".btn-open-path").forEach((button) => {
          button.addEventListener("click", () => openPath(button.dataset.path || ""));
        });

        document.querySelectorAll(".btn-copy-path").forEach((button) => {
          button.addEventListener("click", () => copyText(button.dataset.path || ""));
        });
      };

      const renderRows = (entries) => {
        if (!entries || entries.length === 0) {
          setHtml("file-body", '<tr><td colspan="5" class="empty">파일이 없습니다.</td></tr>');
          return;
        }

        const sorted = state.sortOrder === SORT_NONE ? [...entries] : [...entries].sort(compareEntries);
        const rows = sorted.map((entry) => {
          const absolutePath = toWindowsPath(entry.relativePath);
          const openFolderPath = entry.directory ? absolutePath : toWindowsPath(state.currentPath);
          return `
            <tr>
              <td>
                ${entry.directory
                  ? `<a href="#" data-path="${entry.relativePath}" class="folder-link" style="color: inherit; text-decoration: none;"><span class="name-cell">&#128193; ${entry.name}</span></a>`
                  : `<span class="name-cell">&#128196; ${entry.name}</span>`
                }
              </td>
              <td>${entry.directory ? "폴더" : "파일"}</td>
              <td>${entry.directory ? "-" : formatBytes(entry.size)}</td>
              <td>${entry.modifiedAt ?? "-"}</td>
              <td>
                <div class="row-actions">
                  <button class="btn btn-compact btn-open-path" type="button" data-path="${openFolderPath}">폴더 열기</button>
                  <button class="btn btn-compact btn-copy-path" type="button" data-path="${absolutePath}">경로 복사</button>
                </div>
              </td>
            </tr>
          `;
        }).join("");

        setHtml("file-body", rows);
        bindRowActions();
      };

      const loadFiles = async (path = "") => {
        try {
          const data = await getJson(
            `/api/files?path=${encodeURIComponent(path)}&keyword=${encodeURIComponent(state.keyword)}`
          );
          state.rootPath = data.rootPath ?? "";
          state.currentPath = data.currentPath ?? "";
          state.parentPath = data.parentPath;
          state.entries = data.entries || [];
          setText("current-path", state.currentPath ? `/${state.currentPath}` : "/");
          renderSortHeaders();
          renderRows(state.entries);
        } catch (error) {
          setHtml("file-body", `<tr><td colspan="5" class="empty">조회 실패: ${error.message}</td></tr>`);
        }
      };

      byId("btn-refresh").addEventListener("click", () => loadFiles(state.currentPath));
      byId("btn-up").addEventListener("click", () => loadFiles(state.parentPath || ""));
      byId("btn-open-current").addEventListener("click", () => openPath(toWindowsPath(state.currentPath)));
      byId("btn-copy-current").addEventListener("click", () => copyText(toWindowsPath(state.currentPath)));

      byId("btn-search").addEventListener("click", () => {
        state.keyword = (byId("search-keyword").value || "").trim();
        loadFiles(state.currentPath);
      });
      byId("search-keyword").addEventListener("keydown", (event) => {
        if (event.key !== "Enter") return;
        event.preventDefault();
        byId("btn-search").click();
      });

      document.querySelectorAll("th.sortable").forEach((th) => {
        th.addEventListener("dblclick", () => {
          cycleSort(th.dataset.sortField);
          renderSortHeaders();
          renderRows(state.entries);
        });
      });

      renderSortHeaders();
      loadFiles("");
    </script>
  </body>
</html>
