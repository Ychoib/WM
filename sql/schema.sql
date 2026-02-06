IF DB_ID('wmdb') IS NULL
BEGIN
  CREATE DATABASE wmdb;
END
GO

USE wmdb;
GO

IF OBJECT_ID('dbo.assets', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.assets (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(200) NOT NULL,
    asset_type NVARCHAR(50) NOT NULL,
    expires_at DATE NOT NULL,
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

IF NOT EXISTS (SELECT 1 FROM dbo.assets)
BEGIN
  INSERT INTO dbo.assets (name, asset_type, expires_at, owner_team, owner_name, importance, notify_policy)
  VALUES
    ('Gateway SSL', 'SSL', DATEADD(day, 23, CAST(GETDATE() AS date)), '보안팀', '홍길동', 'High', 'D-90/60/30'),
    ('Analytics 라이선스', 'License', DATEADD(day, 34, CAST(GETDATE() AS date)), '플랫폼팀', '김지민', 'Medium', 'D-60/30/7'),
    ('corp.example.com', 'Domain', DATEADD(day, 43, CAST(GETDATE() AS date)), '인프라팀', '이수현', 'Medium', 'D-90/60/30'),
    ('ERP 유지보수', 'Contract', DATEADD(day, 9, CAST(GETDATE() AS date)), '운영팀', '박준호', 'High', 'D-14/7/3');
END
GO
