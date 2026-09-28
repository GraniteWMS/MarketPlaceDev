/*
    Granite Courier Packing Deployment
    -----------------------------------
    Purpose:
      - Creates the custom Courier Packing tables when they do not exist.
      - Adds missing defaults, keys, foreign keys and supporting indexes.
      - Creates or updates the Courier Packing report views.
      - Seeds/updates the standard courier box types.
      - Inserts or updates the Granite DataGrid definitions.

    Important:
      - Select the correct Granite database before executing this script.
      - This script does NOT create or alter Granite's standard dbo.DataGrid table.
      - This script does NOT insert test boxes, documents or TrackingEntities.
      - Designed for SQL Server 2008 and newer.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    ---------------------------------------------------------------------------
    -- Pre-deployment validation
    ---------------------------------------------------------------------------
    IF OBJECT_ID(N'dbo.Document', N'U') IS NULL
       OR OBJECT_ID(N'dbo.TrackingEntity', N'U') IS NULL
       OR OBJECT_ID(N'dbo.MasterItem', N'U') IS NULL
       OR OBJECT_ID(N'dbo.[Transaction]', N'U') IS NULL
       OR OBJECT_ID(N'dbo.DataGrid', N'U') IS NULL
    BEGIN
        RAISERROR(
            'The selected database is not a valid Granite database. Required standard tables are missing.',
            16,
            1
        );
        RETURN;
    END;

    IF COL_LENGTH(N'dbo.DataGrid', N'Group') IS NULL
       OR COL_LENGTH(N'dbo.DataGrid', N'Name') IS NULL
       OR COL_LENGTH(N'dbo.DataGrid', N'SQLView') IS NULL
       OR COL_LENGTH(N'dbo.DataGrid', N'GridDefinition') IS NULL
       OR COL_LENGTH(N'dbo.DataGrid', N'RowStyleRules') IS NULL
       OR COL_LENGTH(N'dbo.DataGrid', N'PageSize') IS NULL
       OR COL_LENGTH(N'dbo.DataGrid', N'UserGroup_id') IS NULL
       OR COL_LENGTH(N'dbo.DataGrid', N'isApplicationGrid') IS NULL
       OR COL_LENGTH(N'dbo.DataGrid', N'isCustomGrid') IS NULL
       OR COL_LENGTH(N'dbo.DataGrid', N'User_id') IS NULL
       OR COL_LENGTH(N'dbo.DataGrid', N'AuditDate') IS NULL
       OR COL_LENGTH(N'dbo.DataGrid', N'AuditUser') IS NULL
       OR COL_LENGTH(N'dbo.DataGrid', N'Version') IS NULL
    BEGIN
        RAISERROR(
            'dbo.DataGrid does not contain the expected Granite columns. Deployment stopped without changes.',
            16,
            1
        );
        RETURN;
    END;

    BEGIN TRANSACTION;

    ---------------------------------------------------------------------------
    -- Custom tables
    ---------------------------------------------------------------------------
    IF OBJECT_ID(N'dbo.Custom_CourierBoxType', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Custom_CourierBoxType
        (
            ID              BIGINT IDENTITY(1,1) NOT NULL,
            Code            VARCHAR(50) NOT NULL,
            Description     VARCHAR(150) NOT NULL,
            [Length]        DECIMAL(19,6) NOT NULL,
            [Width]         DECIMAL(19,6) NOT NULL,
            [Height]        DECIMAL(19,6) NOT NULL,
            DimensionUOM    VARCHAR(10) NOT NULL,
            MaxWeight       DECIMAL(19,6) NULL,
            WeightUOM       VARCHAR(10) NULL,
            IsActive        BIT NOT NULL,
            AuditDate       DATETIME NULL,
            AuditUser       VARCHAR(50) NULL,
            [Version]       SMALLINT NULL,
            CONSTRAINT PK_Custom_CourierBoxType
                PRIMARY KEY CLUSTERED (ID)
        );
    END;

    IF OBJECT_ID(N'dbo.Custom_CourierBox', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Custom_CourierBox
        (
            ID                  BIGINT IDENTITY(1,1) NOT NULL,
            CourierBoxType_id   BIGINT NULL,
            BoxBarcode          VARCHAR(100) NOT NULL,
            [Weight]            DECIMAL(19,6) NULL,
            WeightUOM           VARCHAR(10) NULL,
            VolumetricWeight    DECIMAL(19,6) NULL,
            ScanDate            DATETIME NULL,
            ScannedUser         VARCHAR(50) NULL,
            IsFinalised         BIT NOT NULL,
            FinalisedDate       DATETIME NULL,
            FinalisedUser       VARCHAR(50) NULL,
            Comment             VARCHAR(250) NULL,
            AuditDate           DATETIME NULL,
            AuditUser           VARCHAR(50) NULL,
            [Version]           SMALLINT NULL,
            CONSTRAINT PK_Custom_CourierBox
                PRIMARY KEY CLUSTERED (ID)
        );
    END;

    IF OBJECT_ID(N'dbo.Custom_CourierBoxDocument', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Custom_CourierBoxDocument
        (
            ID              BIGINT IDENTITY(1,1) NOT NULL,
            CourierBox_id   BIGINT NOT NULL,
            Document_id     BIGINT NOT NULL,
            ScanDate        DATETIME NOT NULL,
            ScannedUser     VARCHAR(50) NULL,
            AuditDate       DATETIME NULL,
            AuditUser       VARCHAR(50) NULL,
            [Version]       SMALLINT NULL,
            CONSTRAINT PK_Custom_CourierBoxDocument
                PRIMARY KEY CLUSTERED (ID)
        );
    END;

    IF OBJECT_ID(N'dbo.Custom_CourierBoxTrackingEntity', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Custom_CourierBoxTrackingEntity
        (
            ID                  BIGINT IDENTITY(1,1) NOT NULL,
            CourierBox_id       BIGINT NOT NULL,
            TrackingEntity_id   BIGINT NOT NULL,
            ScanDate            DATETIME NOT NULL,
            ScannedUser         VARCHAR(50) NULL,
            AuditDate           DATETIME NULL,
            AuditUser           VARCHAR(50) NULL,
            [Version]           SMALLINT NULL,
            CONSTRAINT PK_Custom_CourierBoxTrackingEntity
                PRIMARY KEY CLUSTERED (ID)
        );
    END;

    ---------------------------------------------------------------------------
    -- Validate existing custom-table structures before continuing
    ---------------------------------------------------------------------------
    IF COL_LENGTH(N'dbo.Custom_CourierBoxType', N'ID') IS NULL
       OR COL_LENGTH(N'dbo.Custom_CourierBoxType', N'Code') IS NULL
       OR COL_LENGTH(N'dbo.Custom_CourierBoxType', N'Description') IS NULL
       OR COL_LENGTH(N'dbo.Custom_CourierBoxType', N'Length') IS NULL
       OR COL_LENGTH(N'dbo.Custom_CourierBoxType', N'Width') IS NULL
       OR COL_LENGTH(N'dbo.Custom_CourierBoxType', N'Height') IS NULL
       OR COL_LENGTH(N'dbo.Custom_CourierBoxType', N'DimensionUOM') IS NULL
       OR COL_LENGTH(N'dbo.Custom_CourierBoxType', N'MaxWeight') IS NULL
       OR COL_LENGTH(N'dbo.Custom_CourierBoxType', N'WeightUOM') IS NULL
       OR COL_LENGTH(N'dbo.Custom_CourierBoxType', N'IsActive') IS NULL
       OR COL_LENGTH(N'dbo.Custom_CourierBox', N'ID') IS NULL
       OR COL_LENGTH(N'dbo.Custom_CourierBox', N'CourierBoxType_id') IS NULL
       OR COL_LENGTH(N'dbo.Custom_CourierBox', N'BoxBarcode') IS NULL
       OR COL_LENGTH(N'dbo.Custom_CourierBox', N'Weight') IS NULL
       OR COL_LENGTH(N'dbo.Custom_CourierBox', N'WeightUOM') IS NULL
       OR COL_LENGTH(N'dbo.Custom_CourierBox', N'IsFinalised') IS NULL
       OR COL_LENGTH(N'dbo.Custom_CourierBoxDocument', N'CourierBox_id') IS NULL
       OR COL_LENGTH(N'dbo.Custom_CourierBoxDocument', N'Document_id') IS NULL
       OR COL_LENGTH(N'dbo.Custom_CourierBoxTrackingEntity', N'CourierBox_id') IS NULL
       OR COL_LENGTH(N'dbo.Custom_CourierBoxTrackingEntity', N'TrackingEntity_id') IS NULL
    BEGIN
        RAISERROR(
            'One or more existing Courier Packing tables have an incompatible structure.',
            16,
            1
        );
    END;

    ---------------------------------------------------------------------------
    -- Defaults
    ---------------------------------------------------------------------------
    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.default_constraints DC
        INNER JOIN sys.columns C
            ON C.object_id = DC.parent_object_id
           AND C.column_id = DC.parent_column_id
        WHERE DC.parent_object_id = OBJECT_ID(N'dbo.Custom_CourierBox')
          AND C.name = N'WeightUOM'
    )
        ALTER TABLE dbo.Custom_CourierBox
        ADD CONSTRAINT DF_Custom_CourierBox_WeightUOM DEFAULT ('KG') FOR WeightUOM;

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.default_constraints DC
        INNER JOIN sys.columns C
            ON C.object_id = DC.parent_object_id
           AND C.column_id = DC.parent_column_id
        WHERE DC.parent_object_id = OBJECT_ID(N'dbo.Custom_CourierBox')
          AND C.name = N'ScanDate'
    )
        ALTER TABLE dbo.Custom_CourierBox
        ADD CONSTRAINT DF_Custom_CourierBox_ScanDate DEFAULT (GETDATE()) FOR ScanDate;

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.default_constraints DC
        INNER JOIN sys.columns C
            ON C.object_id = DC.parent_object_id
           AND C.column_id = DC.parent_column_id
        WHERE DC.parent_object_id = OBJECT_ID(N'dbo.Custom_CourierBox')
          AND C.name = N'IsFinalised'
    )
        ALTER TABLE dbo.Custom_CourierBox
        ADD CONSTRAINT DF_Custom_CourierBox_IsFinalised DEFAULT ((0)) FOR IsFinalised;

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.default_constraints DC
        INNER JOIN sys.columns C
            ON C.object_id = DC.parent_object_id
           AND C.column_id = DC.parent_column_id
        WHERE DC.parent_object_id = OBJECT_ID(N'dbo.Custom_CourierBox')
          AND C.name = N'AuditDate'
    )
        ALTER TABLE dbo.Custom_CourierBox
        ADD CONSTRAINT DF_Custom_CourierBox_AuditDate DEFAULT (GETDATE()) FOR AuditDate;

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.default_constraints DC
        INNER JOIN sys.columns C
            ON C.object_id = DC.parent_object_id
           AND C.column_id = DC.parent_column_id
        WHERE DC.parent_object_id = OBJECT_ID(N'dbo.Custom_CourierBox')
          AND C.name = N'Version'
    )
        ALTER TABLE dbo.Custom_CourierBox
        ADD CONSTRAINT DF_Custom_CourierBox_Version DEFAULT ((1)) FOR [Version];

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.default_constraints DC
        INNER JOIN sys.columns C
            ON C.object_id = DC.parent_object_id
           AND C.column_id = DC.parent_column_id
        WHERE DC.parent_object_id = OBJECT_ID(N'dbo.Custom_CourierBoxDocument')
          AND C.name = N'ScanDate'
    )
        ALTER TABLE dbo.Custom_CourierBoxDocument
        ADD CONSTRAINT DF_Custom_CourierBoxDocument_ScanDate DEFAULT (GETDATE()) FOR ScanDate;

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.default_constraints DC
        INNER JOIN sys.columns C
            ON C.object_id = DC.parent_object_id
           AND C.column_id = DC.parent_column_id
        WHERE DC.parent_object_id = OBJECT_ID(N'dbo.Custom_CourierBoxDocument')
          AND C.name = N'AuditDate'
    )
        ALTER TABLE dbo.Custom_CourierBoxDocument
        ADD CONSTRAINT DF_Custom_CourierBoxDocument_AuditDate DEFAULT (GETDATE()) FOR AuditDate;

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.default_constraints DC
        INNER JOIN sys.columns C
            ON C.object_id = DC.parent_object_id
           AND C.column_id = DC.parent_column_id
        WHERE DC.parent_object_id = OBJECT_ID(N'dbo.Custom_CourierBoxDocument')
          AND C.name = N'Version'
    )
        ALTER TABLE dbo.Custom_CourierBoxDocument
        ADD CONSTRAINT DF_Custom_CourierBoxDocument_Version DEFAULT ((1)) FOR [Version];

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.default_constraints DC
        INNER JOIN sys.columns C
            ON C.object_id = DC.parent_object_id
           AND C.column_id = DC.parent_column_id
        WHERE DC.parent_object_id = OBJECT_ID(N'dbo.Custom_CourierBoxTrackingEntity')
          AND C.name = N'ScanDate'
    )
        ALTER TABLE dbo.Custom_CourierBoxTrackingEntity
        ADD CONSTRAINT DF_Custom_CourierBoxTrackingEntity_ScanDate DEFAULT (GETDATE()) FOR ScanDate;

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.default_constraints DC
        INNER JOIN sys.columns C
            ON C.object_id = DC.parent_object_id
           AND C.column_id = DC.parent_column_id
        WHERE DC.parent_object_id = OBJECT_ID(N'dbo.Custom_CourierBoxTrackingEntity')
          AND C.name = N'AuditDate'
    )
        ALTER TABLE dbo.Custom_CourierBoxTrackingEntity
        ADD CONSTRAINT DF_Custom_CourierBoxTrackingEntity_AuditDate DEFAULT (GETDATE()) FOR AuditDate;

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.default_constraints DC
        INNER JOIN sys.columns C
            ON C.object_id = DC.parent_object_id
           AND C.column_id = DC.parent_column_id
        WHERE DC.parent_object_id = OBJECT_ID(N'dbo.Custom_CourierBoxTrackingEntity')
          AND C.name = N'Version'
    )
        ALTER TABLE dbo.Custom_CourierBoxTrackingEntity
        ADD CONSTRAINT DF_Custom_CourierBoxTrackingEntity_Version DEFAULT ((1)) FOR [Version];

    ---------------------------------------------------------------------------
    -- Duplicate validation before unique constraints are added
    ---------------------------------------------------------------------------
    IF EXISTS
    (
        SELECT BoxBarcode
        FROM dbo.Custom_CourierBox
        GROUP BY BoxBarcode
        HAVING COUNT(*) > 1
    )
        RAISERROR('Duplicate BoxBarcode values exist in dbo.Custom_CourierBox.', 16, 1);

    IF EXISTS
    (
        SELECT Code
        FROM dbo.Custom_CourierBoxType
        GROUP BY Code
        HAVING COUNT(*) > 1
    )
        RAISERROR('Duplicate Code values exist in dbo.Custom_CourierBoxType.', 16, 1);

    IF EXISTS
    (
        SELECT CourierBox_id, Document_id
        FROM dbo.Custom_CourierBoxDocument
        GROUP BY CourierBox_id, Document_id
        HAVING COUNT(*) > 1
    )
        RAISERROR('Duplicate box/document links exist in dbo.Custom_CourierBoxDocument.', 16, 1);

    IF EXISTS
    (
        SELECT CourierBox_id, TrackingEntity_id
        FROM dbo.Custom_CourierBoxTrackingEntity
        GROUP BY CourierBox_id, TrackingEntity_id
        HAVING COUNT(*) > 1
    )
        RAISERROR('Duplicate box/barcode links exist in dbo.Custom_CourierBoxTrackingEntity.', 16, 1);

    ---------------------------------------------------------------------------
    -- Unique constraints
    ---------------------------------------------------------------------------
    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.indexes
        WHERE object_id = OBJECT_ID(N'dbo.Custom_CourierBox')
          AND name = N'UQ_Custom_CourierBox_BoxBarcode'
    )
        ALTER TABLE dbo.Custom_CourierBox
        ADD CONSTRAINT UQ_Custom_CourierBox_BoxBarcode UNIQUE NONCLUSTERED (BoxBarcode);

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.indexes
        WHERE object_id = OBJECT_ID(N'dbo.Custom_CourierBoxType')
          AND name = N'UQ_Custom_CourierBoxType_Code'
    )
        ALTER TABLE dbo.Custom_CourierBoxType
        ADD CONSTRAINT UQ_Custom_CourierBoxType_Code UNIQUE NONCLUSTERED (Code);

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.indexes
        WHERE object_id = OBJECT_ID(N'dbo.Custom_CourierBoxDocument')
          AND name = N'UQ_Custom_CourierBoxDocument_Box_Document'
    )
        ALTER TABLE dbo.Custom_CourierBoxDocument
        ADD CONSTRAINT UQ_Custom_CourierBoxDocument_Box_Document
            UNIQUE NONCLUSTERED (CourierBox_id, Document_id);

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.indexes
        WHERE object_id = OBJECT_ID(N'dbo.Custom_CourierBoxTrackingEntity')
          AND name = N'UQ_Custom_CourierBoxTrackingEntity_Box_TrackingEntity'
    )
        ALTER TABLE dbo.Custom_CourierBoxTrackingEntity
        ADD CONSTRAINT UQ_Custom_CourierBoxTrackingEntity_Box_TrackingEntity
            UNIQUE NONCLUSTERED (CourierBox_id, TrackingEntity_id);

    ---------------------------------------------------------------------------
    -- Foreign keys
    ---------------------------------------------------------------------------
    IF OBJECT_ID(N'dbo.FK_Custom_CourierBox_CourierBoxType', N'F') IS NULL
    BEGIN
        ALTER TABLE dbo.Custom_CourierBox WITH CHECK
        ADD CONSTRAINT FK_Custom_CourierBox_CourierBoxType
            FOREIGN KEY (CourierBoxType_id)
            REFERENCES dbo.Custom_CourierBoxType (ID);

        ALTER TABLE dbo.Custom_CourierBox
            CHECK CONSTRAINT FK_Custom_CourierBox_CourierBoxType;
    END;

    IF OBJECT_ID(N'dbo.FK_Custom_CourierBoxDocument_CourierBox', N'F') IS NULL
    BEGIN
        ALTER TABLE dbo.Custom_CourierBoxDocument WITH CHECK
        ADD CONSTRAINT FK_Custom_CourierBoxDocument_CourierBox
            FOREIGN KEY (CourierBox_id)
            REFERENCES dbo.Custom_CourierBox (ID);

        ALTER TABLE dbo.Custom_CourierBoxDocument
            CHECK CONSTRAINT FK_Custom_CourierBoxDocument_CourierBox;
    END;

    IF OBJECT_ID(N'dbo.FK_Custom_CourierBoxDocument_Document', N'F') IS NULL
    BEGIN
        ALTER TABLE dbo.Custom_CourierBoxDocument WITH CHECK
        ADD CONSTRAINT FK_Custom_CourierBoxDocument_Document
            FOREIGN KEY (Document_id)
            REFERENCES dbo.Document (ID);

        ALTER TABLE dbo.Custom_CourierBoxDocument
            CHECK CONSTRAINT FK_Custom_CourierBoxDocument_Document;
    END;

    IF OBJECT_ID(N'dbo.FK_Custom_CourierBoxTrackingEntity_CourierBox', N'F') IS NULL
    BEGIN
        ALTER TABLE dbo.Custom_CourierBoxTrackingEntity WITH CHECK
        ADD CONSTRAINT FK_Custom_CourierBoxTrackingEntity_CourierBox
            FOREIGN KEY (CourierBox_id)
            REFERENCES dbo.Custom_CourierBox (ID);

        ALTER TABLE dbo.Custom_CourierBoxTrackingEntity
            CHECK CONSTRAINT FK_Custom_CourierBoxTrackingEntity_CourierBox;
    END;

    IF OBJECT_ID(N'dbo.FK_Custom_CourierBoxTrackingEntity_TrackingEntity', N'F') IS NULL
    BEGIN
        ALTER TABLE dbo.Custom_CourierBoxTrackingEntity WITH CHECK
        ADD CONSTRAINT FK_Custom_CourierBoxTrackingEntity_TrackingEntity
            FOREIGN KEY (TrackingEntity_id)
            REFERENCES dbo.TrackingEntity (ID);

        ALTER TABLE dbo.Custom_CourierBoxTrackingEntity
            CHECK CONSTRAINT FK_Custom_CourierBoxTrackingEntity_TrackingEntity;
    END;

    ---------------------------------------------------------------------------
    -- Supporting indexes
    ---------------------------------------------------------------------------
    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.indexes
        WHERE object_id = OBJECT_ID(N'dbo.Custom_CourierBox')
          AND name = N'IX_Custom_CourierBox_CourierBoxType'
    )
        CREATE NONCLUSTERED INDEX IX_Custom_CourierBox_CourierBoxType
            ON dbo.Custom_CourierBox (CourierBoxType_id);

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.indexes
        WHERE object_id = OBJECT_ID(N'dbo.Custom_CourierBoxDocument')
          AND name = N'IX_Custom_CourierBoxDocument_Document'
    )
        CREATE NONCLUSTERED INDEX IX_Custom_CourierBoxDocument_Document
            ON dbo.Custom_CourierBoxDocument (Document_id, CourierBox_id);

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.indexes
        WHERE object_id = OBJECT_ID(N'dbo.Custom_CourierBoxTrackingEntity')
          AND name = N'IX_Custom_CourierBoxTrackingEntity_TrackingEntity'
    )
        CREATE NONCLUSTERED INDEX IX_Custom_CourierBoxTrackingEntity_TrackingEntity
            ON dbo.Custom_CourierBoxTrackingEntity (TrackingEntity_id, CourierBox_id);

    ---------------------------------------------------------------------------
    -- Standard courier box types: update existing rows and insert missing rows
    ---------------------------------------------------------------------------
    UPDATE dbo.Custom_CourierBoxType
       SET Description  = 'Extra small box',
           [Length]     = 20.000000,
           [Width]      = 15.000000,
           [Height]     = 10.000000,
           DimensionUOM = 'CM',
           MaxWeight    = 20.000000,
           WeightUOM    = 'KG',
           IsActive     = 1,
           AuditDate    = GETDATE(),
           AuditUser    = 'SYSTEM',
           [Version]    = ISNULL([Version], 0) + 1
     WHERE Code = 'BOX_XS';

    IF @@ROWCOUNT = 0
        ;

    UPDATE dbo.Custom_CourierBoxType
       SET Description  = 'Small box',
           [Length]     = 30.000000,
           [Width]      = 20.000000,
           [Height]     = 15.000000,
           DimensionUOM = 'CM',
           MaxWeight    = 50.000000,
           WeightUOM    = 'KG',
           IsActive     = 1,
           AuditDate    = GETDATE(),
           AuditUser    = 'SYSTEM',
           [Version]    = ISNULL([Version], 0) + 1
     WHERE Code = 'BOX_SMALL';

    IF @@ROWCOUNT = 0
        ;

    UPDATE dbo.Custom_CourierBoxType
       SET Description  = 'Medium box',
           [Length]     = 40.000000,
           [Width]      = 30.000000,
           [Height]     = 25.000000,
           DimensionUOM = 'CM',
           MaxWeight    = 100.000000,
           WeightUOM    = 'KG',
           IsActive     = 1,
           AuditDate    = GETDATE(),
           AuditUser    = 'SYSTEM',
           [Version]    = ISNULL([Version], 0) + 1
     WHERE Code = 'BOX_MEDIUM';

    IF @@ROWCOUNT = 0
        ;

    UPDATE dbo.Custom_CourierBoxType
       SET Description  = 'Large box',
           [Length]     = 50.000000,
           [Width]      = 40.000000,
           [Height]     = 35.000000,
           DimensionUOM = 'CM',
           MaxWeight    = 150.000000,
           WeightUOM    = 'KG',
           IsActive     = 1,
           AuditDate    = GETDATE(),
           AuditUser    = 'SYSTEM',
           [Version]    = ISNULL([Version], 0) + 1
     WHERE Code = 'BOX_LARGE';

    IF @@ROWCOUNT = 0
        ;

    UPDATE dbo.Custom_CourierBoxType
       SET Description  = 'Extra large box',
           [Length]     = 60.000000,
           [Width]      = 45.000000,
           [Height]     = 45.000000,
           DimensionUOM = 'CM',
           MaxWeight    = 200.000000,
           WeightUOM    = 'KG',
           IsActive     = 1,
           AuditDate    = GETDATE(),
           AuditUser    = 'SYSTEM',
           [Version]    = ISNULL([Version], 0) + 1
     WHERE Code = 'BOX_XL';

    IF @@ROWCOUNT = 0
        ;

    ---------------------------------------------------------------------------
    -- Report views
    -- Dynamic SQL is used so CREATE/ALTER VIEW remains the first statement
    -- in its own compiled batch and works on older SQL Server versions.
    ---------------------------------------------------------------------------
    DECLARE @ViewAction VARCHAR(10);
    DECLARE @SQL NVARCHAR(MAX);

    SET @ViewAction = CASE
                        WHEN OBJECT_ID(N'dbo.Custom_DG_CourierPackingBoxSummaryReport', N'V') IS NULL
                            THEN 'CREATE'
                        ELSE 'ALTER'
                      END;

    SET @SQL = N'
' + @ViewAction + N' VIEW dbo.Custom_DG_CourierPackingBoxSummaryReport
AS
WITH OrderAgg AS
(
    SELECT
          CourierBox_id
        , COUNT(DISTINCT Document_id) AS LinkedOrderCount
        , MIN(ScanDate) AS FirstOrderLinkedDate
        , MAX(ScanDate) AS LastOrderLinkedDate
    FROM dbo.Custom_CourierBoxDocument
    GROUP BY CourierBox_id
),
BarcodeAgg AS
(
    SELECT
          CourierBox_id
        , COUNT(DISTINCT TrackingEntity_id) AS BarcodeCount
        , MIN(ScanDate) AS FirstBarcodeScanDate
        , MAX(ScanDate) AS LastBarcodeScanDate
    FROM dbo.Custom_CourierBoxTrackingEntity
    GROUP BY CourierBox_id
)
SELECT
      CB.BoxBarcode
    , CBT.Code AS BoxTypeCode
    , CBT.Description AS BoxTypeDescription
    , CBT.[Length]
    , CBT.[Width]
    , CBT.[Height]
    , CBT.DimensionUOM
    , CASE
        WHEN CBT.ID IS NULL THEN NULL
        ELSE
              CONVERT(VARCHAR(30), CAST(CBT.[Length] AS DECIMAL(19,2)))
            + '' x ''
            + CONVERT(VARCHAR(30), CAST(CBT.[Width] AS DECIMAL(19,2)))
            + '' x ''
            + CONVERT(VARCHAR(30), CAST(CBT.[Height] AS DECIMAL(19,2)))
            + CASE
                WHEN ISNULL(CBT.DimensionUOM, '''') = '''' THEN ''''
                ELSE '' '' + CBT.DimensionUOM
              END
      END AS BoxDimensions
    , CBT.MaxWeight
    , CB.[Weight]
    , CB.WeightUOM
    , CB.VolumetricWeight
    , CASE
        WHEN CB.[Weight] IS NULL OR CB.[Weight] <= 0 THEN ''Missing Weight''
        WHEN CBT.MaxWeight IS NOT NULL AND CB.[Weight] > CBT.MaxWeight THEN ''Over Max Weight''
        ELSE ''OK''
      END AS WeightStatus
    , ISNULL(OA.LinkedOrderCount, 0) AS LinkedOrderCount
    , ISNULL(BA.BarcodeCount, 0) AS BarcodeCount
    , CB.ScanDate AS BoxScanDate
    , CB.ScannedUser AS BoxScannedUser
    , CASE WHEN ISNULL(CB.IsFinalised, 0) = 1 THEN ''Yes'' ELSE ''No'' END AS IsFinalised
    , CASE WHEN ISNULL(CB.IsFinalised, 0) = 1 THEN ''Finalised'' ELSE ''Open'' END AS BoxStatus
    , CB.FinalisedDate
    , CB.FinalisedUser
    , OA.FirstOrderLinkedDate
    , OA.LastOrderLinkedDate
    , BA.FirstBarcodeScanDate
    , BA.LastBarcodeScanDate
    , CB.Comment
    , CB.AuditDate
    , CB.AuditUser
FROM dbo.Custom_CourierBox CB
LEFT JOIN dbo.Custom_CourierBoxType CBT
    ON CBT.ID = CB.CourierBoxType_id
LEFT JOIN OrderAgg OA
    ON OA.CourierBox_id = CB.ID
LEFT JOIN BarcodeAgg BA
    ON BA.CourierBox_id = CB.ID;';

    EXEC sys.sp_executesql @SQL;

    SET @ViewAction = CASE
                        WHEN OBJECT_ID(N'dbo.Custom_DG_CourierPackingBoxOrderReport', N'V') IS NULL
                            THEN 'CREATE'
                        ELSE 'ALTER'
                      END;

    SET @SQL = N'
' + @ViewAction + N' VIEW dbo.Custom_DG_CourierPackingBoxOrderReport
AS
WITH PickBarcodeAgg AS
(
    SELECT
          CBTE.CourierBox_id
        , T.Document_id
        , COUNT(DISTINCT CBTE.TrackingEntity_id) AS BarcodeCountInBox
    FROM dbo.Custom_CourierBoxTrackingEntity CBTE
    INNER JOIN dbo.[Transaction] T
        ON T.TrackingEntity_id = CBTE.TrackingEntity_id
       AND UPPER(T.[Type]) = ''PICK''
       AND ISNULL(T.ReversalTransaction_id, 0) = 0
       AND ISNULL(T.ActionQty, 0) > 0
    GROUP BY
          CBTE.CourierBox_id
        , T.Document_id
)
SELECT
      CB.BoxBarcode
    , D.Number AS SalesOrder
    , D.TradingPartnerCode
    , D.TradingPartnerDescription
    , D.CreateDate AS DocumentCreateDate
    , D.[Status] AS DocumentStatus
    , ISNULL(PBA.BarcodeCountInBox, 0) AS BarcodeCountInBox
    , CBD.ScanDate AS OrderLinkedDate
    , CBD.ScannedUser AS OrderLinkedUser
    , CASE WHEN ISNULL(CB.IsFinalised, 0) = 1 THEN ''Yes'' ELSE ''No'' END AS IsFinalised
    , CASE WHEN ISNULL(CB.IsFinalised, 0) = 1 THEN ''Finalised'' ELSE ''Open'' END AS BoxStatus
    , CB.[Weight]
    , CB.WeightUOM
    , CB.FinalisedDate
    , CB.FinalisedUser
FROM dbo.Custom_CourierBox CB
INNER JOIN dbo.Custom_CourierBoxDocument CBD
    ON CBD.CourierBox_id = CB.ID
INNER JOIN dbo.Document D
    ON D.ID = CBD.Document_id
LEFT JOIN PickBarcodeAgg PBA
    ON PBA.CourierBox_id = CB.ID
   AND PBA.Document_id = D.ID;';

    EXEC sys.sp_executesql @SQL;

    SET @ViewAction = CASE
                        WHEN OBJECT_ID(N'dbo.Custom_DG_CourierPackingBoxBarcodeReport', N'V') IS NULL
                            THEN 'CREATE'
                        ELSE 'ALTER'
                      END;

    SET @SQL = N'
' + @ViewAction + N' VIEW dbo.Custom_DG_CourierPackingBoxBarcodeReport
AS
WITH PickAgg AS
(
    SELECT
          T.Document_id
        , T.TrackingEntity_id
        , T.FromMasterItem_id
        , SUM(ISNULL(T.ActionQty, 0)) AS PickedQty
    FROM dbo.[Transaction] T
    WHERE UPPER(T.[Type]) = ''PICK''
      AND ISNULL(T.ReversalTransaction_id, 0) = 0
      AND ISNULL(T.ActionQty, 0) > 0
    GROUP BY
          T.Document_id
        , T.TrackingEntity_id
        , T.FromMasterItem_id
)
SELECT
      CB.BoxBarcode
    , CBT.Code AS BoxTypeCode
    , CBT.Description AS BoxTypeDescription
    , TE.Barcode AS TrackingEntityBarcode
    , D.Number AS SalesOrder
    , D.TradingPartnerCode
    , D.TradingPartnerDescription
    , MI.Code AS ItemCode
    , MI.Description AS ItemDescription
    , PA.PickedQty
    , CASE
        WHEN PA.Document_id IS NULL THEN ''No PICK transaction found''
        WHEN CBD.ID IS NULL THEN ''PICK order not linked to box''
        ELSE ''OK''
      END AS BarcodeOrderStatus
    , CBTE.ScanDate AS BarcodeScanDate
    , CBTE.ScannedUser AS BarcodeScannedUser
    , CB.[Weight]
    , CB.WeightUOM
    , CASE WHEN ISNULL(CB.IsFinalised, 0) = 1 THEN ''Yes'' ELSE ''No'' END AS IsFinalised
    , CASE WHEN ISNULL(CB.IsFinalised, 0) = 1 THEN ''Finalised'' ELSE ''Open'' END AS BoxStatus
    , CB.FinalisedDate
    , CB.FinalisedUser
FROM dbo.Custom_CourierBox CB
INNER JOIN dbo.Custom_CourierBoxTrackingEntity CBTE
    ON CBTE.CourierBox_id = CB.ID
INNER JOIN dbo.TrackingEntity TE
    ON TE.ID = CBTE.TrackingEntity_id
LEFT JOIN dbo.Custom_CourierBoxType CBT
    ON CBT.ID = CB.CourierBoxType_id
LEFT JOIN PickAgg PA
    ON PA.TrackingEntity_id = CBTE.TrackingEntity_id
LEFT JOIN dbo.Custom_CourierBoxDocument CBD
    ON CBD.CourierBox_id = CB.ID
   AND CBD.Document_id = PA.Document_id
LEFT JOIN dbo.Document D
    ON D.ID = PA.Document_id
LEFT JOIN dbo.MasterItem MI
    ON MI.ID = ISNULL(PA.FromMasterItem_id, TE.MasterItem_id);';

    EXEC sys.sp_executesql @SQL;

    SET @ViewAction = CASE
                        WHEN OBJECT_ID(N'dbo.Custom_DG_CourierPackingBoxExceptionReport', N'V') IS NULL
                            THEN 'CREATE'
                        ELSE 'ALTER'
                      END;

    SET @SQL = N'
' + @ViewAction + N' VIEW dbo.Custom_DG_CourierPackingBoxExceptionReport
AS
SELECT
      CB.BoxBarcode
    , ''Missing Box Type'' AS ExceptionType
    , ''Box has no box type selected.'' AS ExceptionMessage
    , CASE WHEN ISNULL(CB.IsFinalised, 0) = 1 THEN ''Yes'' ELSE ''No'' END AS IsFinalised
    , CB.ScanDate
    , CB.ScannedUser
FROM dbo.Custom_CourierBox CB
WHERE CB.CourierBoxType_id IS NULL

UNION ALL

SELECT
      CB.BoxBarcode
    , ''No Orders Linked'' AS ExceptionType
    , ''Box has no linked Sales Orders.'' AS ExceptionMessage
    , CASE WHEN ISNULL(CB.IsFinalised, 0) = 1 THEN ''Yes'' ELSE ''No'' END AS IsFinalised
    , CB.ScanDate
    , CB.ScannedUser
FROM dbo.Custom_CourierBox CB
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.Custom_CourierBoxDocument CBD
    WHERE CBD.CourierBox_id = CB.ID
)

UNION ALL

SELECT
      CB.BoxBarcode
    , ''No Barcodes Scanned'' AS ExceptionType
    , ''Box has no TrackingEntity barcodes scanned.'' AS ExceptionMessage
    , CASE WHEN ISNULL(CB.IsFinalised, 0) = 1 THEN ''Yes'' ELSE ''No'' END AS IsFinalised
    , CB.ScanDate
    , CB.ScannedUser
FROM dbo.Custom_CourierBox CB
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.Custom_CourierBoxTrackingEntity CBTE
    WHERE CBTE.CourierBox_id = CB.ID
)

UNION ALL

SELECT
      CB.BoxBarcode
    , ''Missing Weight'' AS ExceptionType
    , ''Box has no valid final weight captured.'' AS ExceptionMessage
    , CASE WHEN ISNULL(CB.IsFinalised, 0) = 1 THEN ''Yes'' ELSE ''No'' END AS IsFinalised
    , CB.ScanDate
    , CB.ScannedUser
FROM dbo.Custom_CourierBox CB
WHERE ISNULL(CB.[Weight], 0) <= 0

UNION ALL

SELECT
      CB.BoxBarcode
    , ''Over Max Weight'' AS ExceptionType
    , ''The captured box weight exceeds the selected box type maximum weight.'' AS ExceptionMessage
    , CASE WHEN ISNULL(CB.IsFinalised, 0) = 1 THEN ''Yes'' ELSE ''No'' END AS IsFinalised
    , CB.ScanDate
    , CB.ScannedUser
FROM dbo.Custom_CourierBox CB
INNER JOIN dbo.Custom_CourierBoxType CBT
    ON CBT.ID = CB.CourierBoxType_id
WHERE CBT.MaxWeight IS NOT NULL
  AND CB.[Weight] IS NOT NULL
  AND CB.[Weight] > CBT.MaxWeight

UNION ALL

SELECT
      CB.BoxBarcode
    , ''Barcode Not Linked To Box Order'' AS ExceptionType
    , ''A scanned barcode has no matching PICK transaction for an order linked to this box.'' AS ExceptionMessage
    , CASE WHEN ISNULL(CB.IsFinalised, 0) = 1 THEN ''Yes'' ELSE ''No'' END AS IsFinalised
    , CB.ScanDate
    , CB.ScannedUser
FROM dbo.Custom_CourierBox CB
INNER JOIN dbo.Custom_CourierBoxTrackingEntity CBTE
    ON CBTE.CourierBox_id = CB.ID
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.Custom_CourierBoxDocument CBD
    INNER JOIN dbo.[Transaction] T
        ON T.Document_id = CBD.Document_id
       AND T.TrackingEntity_id = CBTE.TrackingEntity_id
       AND UPPER(T.[Type]) = ''PICK''
       AND ISNULL(T.ReversalTransaction_id, 0) = 0
       AND ISNULL(T.ActionQty, 0) > 0
    WHERE CBD.CourierBox_id = CB.ID
);';

    EXEC sys.sp_executesql @SQL;

    ---------------------------------------------------------------------------
    -- Granite DataGrid definitions
    -- Existing rows are updated by Name. Missing rows are inserted without
    -- fixed identity values.
    ---------------------------------------------------------------------------
    DECLARE @GridDefinition NVARCHAR(MAX);

    SET @GridDefinition = N'[
  { "headerName": "Box Barcode", "field": "BoxBarcode", "width": 180, "filter": "agTextColumnFilter" },
  { "headerName": "Box Type Code", "field": "BoxTypeCode", "width": 150, "filter": "agTextColumnFilter" },
  { "headerName": "Box Type Description", "field": "BoxTypeDescription", "width": 220, "filter": "agTextColumnFilter" },
  { "headerName": "Length", "field": "Length", "width": 110, "filter": "agNumberColumnFilter" },
  { "headerName": "Width", "field": "Width", "width": 110, "filter": "agNumberColumnFilter" },
  { "headerName": "Height", "field": "Height", "width": 110, "filter": "agNumberColumnFilter" },
  { "headerName": "Dimension UOM", "field": "DimensionUOM", "width": 130, "filter": "agTextColumnFilter" },
  { "headerName": "Box Dimensions", "field": "BoxDimensions", "width": 200, "filter": "agTextColumnFilter" },
  { "headerName": "Max Weight", "field": "MaxWeight", "width": 130, "filter": "agNumberColumnFilter" },
  { "headerName": "Weight", "field": "Weight", "width": 120, "filter": "agNumberColumnFilter" },
  { "headerName": "Weight UOM", "field": "WeightUOM", "width": 120, "filter": "agTextColumnFilter" },
  { "headerName": "Volumetric Weight", "field": "VolumetricWeight", "width": 170, "filter": "agNumberColumnFilter" },
  { "headerName": "Weight Status", "field": "WeightStatus", "width": 160, "filter": "agSetColumnFilter" },
  { "headerName": "Linked Order Count", "field": "LinkedOrderCount", "width": 170, "filter": "agNumberColumnFilter" },
  { "headerName": "Barcode Count", "field": "BarcodeCount", "width": 150, "filter": "agNumberColumnFilter" },
  { "headerName": "Box Scan Date", "field": "BoxScanDate", "width": 170, "filter": "agDateColumnFilter" },
  { "headerName": "Box Scanned User", "field": "BoxScannedUser", "width": 170, "filter": "agTextColumnFilter" },
  { "headerName": "Is Finalised", "field": "IsFinalised", "width": 130, "filter": "agSetColumnFilter" },
  { "headerName": "Box Status", "field": "BoxStatus", "width": 130, "filter": "agSetColumnFilter" },
  { "headerName": "Finalised Date", "field": "FinalisedDate", "width": 170, "filter": "agDateColumnFilter" },
  { "headerName": "Finalised User", "field": "FinalisedUser", "width": 160, "filter": "agTextColumnFilter" },
  { "headerName": "First Order Linked Date", "field": "FirstOrderLinkedDate", "width": 200, "filter": "agDateColumnFilter" },
  { "headerName": "Last Order Linked Date", "field": "LastOrderLinkedDate", "width": 200, "filter": "agDateColumnFilter" },
  { "headerName": "First Barcode Scan Date", "field": "FirstBarcodeScanDate", "width": 200, "filter": "agDateColumnFilter" },
  { "headerName": "Last Barcode Scan Date", "field": "LastBarcodeScanDate", "width": 200, "filter": "agDateColumnFilter" },
  { "headerName": "Comment", "field": "Comment", "width": 220, "filter": "agTextColumnFilter" },
  { "headerName": "Audit Date", "field": "AuditDate", "width": 170, "filter": "agDateColumnFilter" },
  { "headerName": "Audit User", "field": "AuditUser", "width": 150, "filter": "agTextColumnFilter" }
]';

    UPDATE dbo.DataGrid
       SET [Group] = 'Courier',
           SQLView = 'Custom_DG_CourierPackingBoxSummaryReport',
           GridDefinition = @GridDefinition,
           RowStyleRules = NULL,
           PageSize = 100000,
           isApplicationGrid = 0,
           isCustomGrid = 1,
           AuditDate = GETDATE(),
           AuditUser = 'SYSTEM',
           [Version] = ISNULL([Version], 0) + 1
     WHERE [Name] = 'Courier Box Summary';

    IF @@ROWCOUNT = 0
        ;

    SET @GridDefinition = N'[
  { "headerName": "Box Barcode", "field": "BoxBarcode", "width": 180, "filter": "agTextColumnFilter" },
  { "headerName": "Sales Order", "field": "SalesOrder", "width": 160, "filter": "agTextColumnFilter" },
  { "headerName": "Trading Partner Code", "field": "TradingPartnerCode", "width": 180, "filter": "agTextColumnFilter" },
  { "headerName": "Trading Partner Description", "field": "TradingPartnerDescription", "width": 260, "filter": "agTextColumnFilter" },
  { "headerName": "Document Create Date", "field": "DocumentCreateDate", "width": 190, "filter": "agDateColumnFilter" },
  { "headerName": "Document Status", "field": "DocumentStatus", "width": 160, "filter": "agSetColumnFilter" },
  { "headerName": "Barcode Count In Box", "field": "BarcodeCountInBox", "width": 190, "filter": "agNumberColumnFilter" },
  { "headerName": "Order Linked Date", "field": "OrderLinkedDate", "width": 180, "filter": "agDateColumnFilter" },
  { "headerName": "Order Linked User", "field": "OrderLinkedUser", "width": 170, "filter": "agTextColumnFilter" },
  { "headerName": "Is Finalised", "field": "IsFinalised", "width": 130, "filter": "agSetColumnFilter" },
  { "headerName": "Box Status", "field": "BoxStatus", "width": 130, "filter": "agSetColumnFilter" },
  { "headerName": "Weight", "field": "Weight", "width": 120, "filter": "agNumberColumnFilter" },
  { "headerName": "Weight UOM", "field": "WeightUOM", "width": 120, "filter": "agTextColumnFilter" },
  { "headerName": "Finalised Date", "field": "FinalisedDate", "width": 170, "filter": "agDateColumnFilter" },
  { "headerName": "Finalised User", "field": "FinalisedUser", "width": 160, "filter": "agTextColumnFilter" }
]';

    UPDATE dbo.DataGrid
       SET [Group] = 'Courier',
           SQLView = 'Custom_DG_CourierPackingBoxOrderReport',
           GridDefinition = @GridDefinition,
           RowStyleRules = NULL,
           PageSize = 100000,
           isApplicationGrid = 0,
           isCustomGrid = 1,
           AuditDate = GETDATE(),
           AuditUser = 'SYSTEM',
           [Version] = ISNULL([Version], 0) + 1
     WHERE [Name] = 'Courier Box Orders';

    IF @@ROWCOUNT = 0
        ;

    SET @GridDefinition = N'[
  { "headerName": "Box Barcode", "field": "BoxBarcode", "width": 180, "filter": "agTextColumnFilter" },
  { "headerName": "Box Type Code", "field": "BoxTypeCode", "width": 150, "filter": "agTextColumnFilter" },
  { "headerName": "Box Type Description", "field": "BoxTypeDescription", "width": 220, "filter": "agTextColumnFilter" },
  { "headerName": "Tracking Entity Barcode", "field": "TrackingEntityBarcode", "width": 220, "filter": "agTextColumnFilter" },
  { "headerName": "Sales Order", "field": "SalesOrder", "width": 160, "filter": "agTextColumnFilter" },
  { "headerName": "Trading Partner Code", "field": "TradingPartnerCode", "width": 180, "filter": "agTextColumnFilter" },
  { "headerName": "Trading Partner Description", "field": "TradingPartnerDescription", "width": 260, "filter": "agTextColumnFilter" },
  { "headerName": "Item Code", "field": "ItemCode", "width": 160, "filter": "agTextColumnFilter" },
  { "headerName": "Item Description", "field": "ItemDescription", "width": 260, "filter": "agTextColumnFilter" },
  { "headerName": "Picked Qty", "field": "PickedQty", "width": 130, "filter": "agNumberColumnFilter" },
  { "headerName": "Barcode Order Status", "field": "BarcodeOrderStatus", "width": 220, "filter": "agSetColumnFilter" },
  { "headerName": "Barcode Scan Date", "field": "BarcodeScanDate", "width": 180, "filter": "agDateColumnFilter" },
  { "headerName": "Barcode Scanned User", "field": "BarcodeScannedUser", "width": 190, "filter": "agTextColumnFilter" },
  { "headerName": "Weight", "field": "Weight", "width": 120, "filter": "agNumberColumnFilter" },
  { "headerName": "Weight UOM", "field": "WeightUOM", "width": 120, "filter": "agTextColumnFilter" },
  { "headerName": "Is Finalised", "field": "IsFinalised", "width": 130, "filter": "agSetColumnFilter" },
  { "headerName": "Box Status", "field": "BoxStatus", "width": 130, "filter": "agSetColumnFilter" },
  { "headerName": "Finalised Date", "field": "FinalisedDate", "width": 170, "filter": "agDateColumnFilter" },
  { "headerName": "Finalised User", "field": "FinalisedUser", "width": 160, "filter": "agTextColumnFilter" }
]';

    UPDATE dbo.DataGrid
       SET [Group] = 'Courier',
           SQLView = 'Custom_DG_CourierPackingBoxBarcodeReport',
           GridDefinition = @GridDefinition,
           RowStyleRules = NULL,
           PageSize = 100000,
           isApplicationGrid = 0,
           isCustomGrid = 1,
           AuditDate = GETDATE(),
           AuditUser = 'SYSTEM',
           [Version] = ISNULL([Version], 0) + 1
     WHERE [Name] = 'Courier Box Barcodes';

    IF @@ROWCOUNT = 0
        ;

    SET @GridDefinition = N'[
  { "headerName": "Box Barcode", "field": "BoxBarcode", "width": 180, "filter": "agTextColumnFilter" },
  { "headerName": "Exception Type", "field": "ExceptionType", "width": 230, "filter": "agSetColumnFilter" },
  { "headerName": "Exception Message", "field": "ExceptionMessage", "width": 380, "filter": "agTextColumnFilter" },
  { "headerName": "Is Finalised", "field": "IsFinalised", "width": 130, "filter": "agSetColumnFilter" },
  { "headerName": "Scan Date", "field": "ScanDate", "width": 170, "filter": "agDateColumnFilter" },
  { "headerName": "Scanned User", "field": "ScannedUser", "width": 160, "filter": "agTextColumnFilter" }
]';

    UPDATE dbo.DataGrid
       SET [Group] = 'Courier',
           SQLView = 'Custom_DG_CourierPackingBoxExceptionReport',
           GridDefinition = @GridDefinition,
           RowStyleRules = NULL,
           PageSize = 100000,
           isApplicationGrid = 0,
           isCustomGrid = 1,
           AuditDate = GETDATE(),
           AuditUser = 'SYSTEM',
           [Version] = ISNULL([Version], 0) + 1
     WHERE [Name] = 'Courier Box Exceptions';

    IF @@ROWCOUNT = 0
        ;

    COMMIT TRANSACTION;

    PRINT 'Courier Packing deployment completed successfully.';
    PRINT 'No test courier boxes, document links or TrackingEntity links were inserted.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT
          @ErrorMessage = ERROR_MESSAGE()
        , @ErrorSeverity = ERROR_SEVERITY()
        , @ErrorState = ERROR_STATE();

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH;
