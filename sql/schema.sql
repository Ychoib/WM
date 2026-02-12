IF DB_ID('wmdb') IS NULL
BEGIN
  CREATE DATABASE wmdb;
END
GO

USE wmdb;
GO

-- 1) 파트 마스터: 재실행 시에도 안전하게 먼저 보장
IF OBJECT_ID('dbo.parts', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.parts (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    part_code NVARCHAR(50) NOT NULL UNIQUE,
    part_name NVARCHAR(100) NOT NULL,
    is_active BIT NOT NULL DEFAULT 1,
    display_order INT NOT NULL DEFAULT 100,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.parts)
BEGIN
  INSERT INTO dbo.parts (part_code, part_name, is_active, display_order)
  VALUES
    ('INFRA', N'인프라', 1, 10),
    ('PLATFORM', N'플랫폼', 1, 20),
    ('SERVICE', N'서비스', 1, 30);
END
GO

IF OBJECT_ID('dbo.part_documents', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.part_documents (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    part_id BIGINT NOT NULL,
    doc_type NVARCHAR(50) NOT NULL,
    doc_title NVARCHAR(200) NOT NULL,
    original_file_name NVARCHAR(260) NOT NULL,
    stored_path NVARCHAR(500) NOT NULL,
    file_ext NVARCHAR(20) NOT NULL,
    content_type NVARCHAR(120) NULL,
    file_size BIGINT NOT NULL,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
  );
END
GO

IF NOT EXISTS (
  SELECT 1
  FROM sys.foreign_keys
  WHERE name = 'FK_part_documents_part_id'
    AND parent_object_id = OBJECT_ID('dbo.part_documents')
)
BEGIN
  ALTER TABLE dbo.part_documents
  ADD CONSTRAINT FK_part_documents_part_id
    FOREIGN KEY (part_id) REFERENCES dbo.parts(id);
END
GO

IF NOT EXISTS (
  SELECT 1
  FROM sys.indexes
  WHERE name = 'IX_part_documents_part_id_created_at'
    AND object_id = OBJECT_ID('dbo.part_documents')
)
BEGIN
  CREATE INDEX IX_part_documents_part_id_created_at
    ON dbo.part_documents(part_id, created_at DESC);
END
GO

IF OBJECT_ID('dbo.members', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.members (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    emp_no NVARCHAR(50) NULL,
    member_name NVARCHAR(100) NOT NULL,
    title NVARCHAR(100) NULL,
    phone NVARCHAR(50) NULL,
    email NVARCHAR(100) NULL,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
  );
END
GO

IF NOT EXISTS (
  SELECT 1
  FROM sys.indexes
  WHERE name = 'UX_members_emp_no_not_null'
    AND object_id = OBJECT_ID('dbo.members')
)
BEGIN
  IF NOT EXISTS (
    SELECT emp_no
    FROM dbo.members
    WHERE emp_no IS NOT NULL
      AND emp_no <> N''
    GROUP BY emp_no
    HAVING COUNT(1) > 1
  )
  BEGIN
    CREATE UNIQUE INDEX UX_members_emp_no_not_null
      ON dbo.members(emp_no)
      WHERE emp_no IS NOT NULL
        AND emp_no <> N'';
  END
END
GO

IF OBJECT_ID('dbo.part_members', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.part_members (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    part_id BIGINT NOT NULL,
    member_id BIGINT NOT NULL,
    role_in_part NVARCHAR(100) NULL,
    sort_order INT NOT NULL DEFAULT 100,
    is_primary BIT NOT NULL DEFAULT 0,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.members)
BEGIN
  INSERT INTO dbo.members (emp_no, member_name, title, phone, email, is_active)
  VALUES
    (N'E1001', N'김학선', N'팀장', N'010-0000-0001', N'hakseon.kim@grs.local', 1),
    (N'E1002', N'김성환', N'매니저', N'010-0000-0002', N'seonghwan.kim@grs.local', 1),
    (N'E1003', N'오영진', N'매니저', N'010-0000-0003', N'youngjin.oh@grs.local', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.part_members)
BEGIN
  DECLARE @infraPartId BIGINT;
  DECLARE @platformPartId BIGINT;
  DECLARE @servicePartId BIGINT;
  DECLARE @kimSeonghwanId BIGINT;
  DECLARE @ohYoungjinId BIGINT;

  SELECT @infraPartId = id FROM dbo.parts WHERE part_code = 'INFRA';
  SELECT @platformPartId = id FROM dbo.parts WHERE part_code = 'PLATFORM';
  SELECT @servicePartId = id FROM dbo.parts WHERE part_code = 'SERVICE';
  SELECT @kimSeonghwanId = id FROM dbo.members WHERE member_name = N'김성환';
  SELECT @ohYoungjinId = id FROM dbo.members WHERE member_name = N'오영진';

  IF @infraPartId IS NOT NULL AND @ohYoungjinId IS NOT NULL
    INSERT INTO dbo.part_members (part_id, member_id, role_in_part, sort_order, is_primary, is_active)
    VALUES (@infraPartId, @ohYoungjinId, N'파트 담당', 10, 1, 1);

  IF @platformPartId IS NOT NULL AND @kimSeonghwanId IS NOT NULL
    INSERT INTO dbo.part_members (part_id, member_id, role_in_part, sort_order, is_primary, is_active)
    VALUES (@platformPartId, @kimSeonghwanId, N'파트 담당', 10, 1, 1);

  IF @servicePartId IS NOT NULL AND @kimSeonghwanId IS NOT NULL
    INSERT INTO dbo.part_members (part_id, member_id, role_in_part, sort_order, is_primary, is_active)
    VALUES (@servicePartId, @kimSeonghwanId, N'파트 담당', 10, 1, 1);
END
GO

IF OBJECT_ID('dbo.org_units', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.org_units (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    parent_id BIGINT NULL,
    part_id BIGINT NULL,
    unit_name NVARCHAR(100) NOT NULL,
    role_name NVARCHAR(100) NULL,
    pos_x INT NULL,
    pos_y INT NULL,
    is_active BIT NOT NULL DEFAULT 1,
    sort_order INT NOT NULL DEFAULT 100,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
  );
END
GO

IF COL_LENGTH('dbo.org_units', 'part_id') IS NULL
BEGIN
  ALTER TABLE dbo.org_units ADD part_id BIGINT NULL;
END
GO

IF NOT EXISTS (
  SELECT 1
  FROM sys.foreign_keys
  WHERE name = 'FK_org_units_part_id'
    AND parent_object_id = OBJECT_ID('dbo.org_units')
)
BEGIN
  ALTER TABLE dbo.org_units
  ADD CONSTRAINT FK_org_units_part_id
    FOREIGN KEY (part_id) REFERENCES dbo.parts(id);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.org_units)
BEGIN
  DECLARE @rootId BIGINT;
  DECLARE @salesId BIGINT;
  DECLARE @supportId BIGINT;

  INSERT INTO dbo.org_units (parent_id, unit_name, role_name, is_active, sort_order)
  VALUES (NULL, N'GRS IS팀', N'팀장 김학선', 1, 10);
  SET @rootId = SCOPE_IDENTITY();

  INSERT INTO dbo.org_units (parent_id, unit_name, role_name, is_active, sort_order)
  VALUES (@rootId, N'영업담당', N'김성환 매니저', 1, 10);
  SET @salesId = SCOPE_IDENTITY();

  INSERT INTO dbo.org_units (parent_id, unit_name, role_name, is_active, sort_order)
  VALUES (@rootId, N'지원담당', N'오영진 매니저', 1, 20);
  SET @supportId = SCOPE_IDENTITY();

  INSERT INTO dbo.org_units (parent_id, unit_name, role_name, is_active, sort_order)
  VALUES
    (@salesId, N'회계', NULL, 1, 10),
    (@salesId, N'SAP', NULL, 1, 20),
    (@salesId, N'WEB', NULL, 1, 30),
    (@salesId, N'개발/시공', NULL, 1, 40),
    (@supportId, N'인사', NULL, 1, 10),
    (@supportId, N'인프라', NULL, 1, 20),
    (@supportId, N'보안', NULL, 1, 30),
    (@supportId, N'POS', NULL, 1, 40);

  UPDATE dbo.org_units
  SET pos_x = 860, pos_y = 90
  WHERE id = @rootId;

  UPDATE dbo.org_units
  SET pos_x = 580, pos_y = 300
  WHERE id = @salesId;

  UPDATE dbo.org_units
  SET pos_x = 1140, pos_y = 300
  WHERE id = @supportId;

  UPDATE dbo.org_units
  SET pos_x = CASE unit_name
        WHEN N'회계' THEN 250
        WHEN N'SAP' THEN 470
        WHEN N'WEB' THEN 690
        WHEN N'개발/시공' THEN 910
        WHEN N'인사' THEN 1030
        WHEN N'인프라' THEN 1250
        WHEN N'보안' THEN 1470
        WHEN N'POS' THEN 1690
      END,
      pos_y = 520
  WHERE parent_id IN (@salesId, @supportId);
END
GO

IF COL_LENGTH('dbo.org_units', 'pos_x') IS NULL
BEGIN
  ALTER TABLE dbo.org_units ADD pos_x INT NULL;
END
GO

IF COL_LENGTH('dbo.org_units', 'pos_y') IS NULL
BEGIN
  ALTER TABLE dbo.org_units ADD pos_y INT NULL;
END
GO

-- 2) 기존 자산/정책 객체
IF OBJECT_ID('dbo.assets', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.assets (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(200) NOT NULL,
    asset_type NVARCHAR(50) NOT NULL,
    expires_at DATE NOT NULL,
    part_id BIGINT NULL,
    owner_team NVARCHAR(100) NULL,
    owner_name NVARCHAR(100) NULL,
    importance NVARCHAR(20) NULL,
    notify_policy NVARCHAR(50) NULL,
    related_services NVARCHAR(200) NULL,
    memo NVARCHAR(1000) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
  );
END
GO

IF OBJECT_ID('dbo.policies', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.policies (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(50) NOT NULL UNIQUE,
    schedule NVARCHAR(200) NOT NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.policies)
BEGIN
  INSERT INTO dbo.policies (name, schedule)
  VALUES
    ('D-90/60/30', '90,60,30'),
    ('D-60/30/7', '60,30,7');
END
GO

IF COL_LENGTH('dbo.assets', 'related_services') IS NULL
BEGIN
  ALTER TABLE dbo.assets ADD related_services NVARCHAR(200) NULL;
END
GO

IF COL_LENGTH('dbo.assets', 'memo') IS NULL
BEGIN
  ALTER TABLE dbo.assets ADD memo NVARCHAR(1000) NULL;
END
GO

IF COL_LENGTH('dbo.assets', 'updated_at') IS NULL
BEGIN
  ALTER TABLE dbo.assets ADD updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME();
END
GO

IF COL_LENGTH('dbo.assets', 'part_id') IS NULL
BEGIN
  ALTER TABLE dbo.assets ADD part_id BIGINT NULL;
END
GO

IF EXISTS (
  SELECT 1
  FROM sys.foreign_keys
  WHERE name = 'FK_assets_part_id'
    AND parent_object_id = OBJECT_ID('dbo.assets')
)
BEGIN
  ALTER TABLE dbo.assets DROP CONSTRAINT FK_assets_part_id;
END
GO

IF EXISTS (
  SELECT 1
  FROM sys.columns
  WHERE object_id = OBJECT_ID('dbo.assets')
    AND name = 'part_id'
)
BEGIN
  ALTER TABLE dbo.assets
  ADD CONSTRAINT FK_assets_part_id
    FOREIGN KEY (part_id) REFERENCES dbo.parts(id);
END
GO

UPDATE a
SET a.part_id = p.id
FROM dbo.assets a
JOIN dbo.parts p ON p.part_name = a.owner_team
WHERE a.part_id IS NULL
  AND a.owner_team IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.assets)
BEGIN
  INSERT INTO dbo.assets (name, asset_type, expires_at, part_id, owner_team, owner_name, importance, notify_policy)
  VALUES
    ('Gateway SSL', 'SSL', DATEADD(day, 23, CAST(GETDATE() AS date)), (SELECT TOP 1 id FROM dbo.parts WHERE part_code = 'INFRA'), N'보안팀', N'홍길동', 'High', 'D-90/60/30'),
    ('Analytics 라이선스', 'License', DATEADD(day, 34, CAST(GETDATE() AS date)), (SELECT TOP 1 id FROM dbo.parts WHERE part_code = 'PLATFORM'), N'플랫폼팀', N'김지민', 'Medium', 'D-60/30/7'),
    ('corp.example.com', 'Domain', DATEADD(day, 43, CAST(GETDATE() AS date)), (SELECT TOP 1 id FROM dbo.parts WHERE part_code = 'INFRA'), N'인프라팀', N'이수민', 'Medium', 'D-90/60/30'),
    ('ERP 유지보수', 'Contract', DATEADD(day, 9, CAST(GETDATE() AS date)), (SELECT TOP 1 id FROM dbo.parts WHERE part_code = 'SERVICE'), N'운영팀', N'박준호', 'High', 'D-14/7/3');
END
GO
