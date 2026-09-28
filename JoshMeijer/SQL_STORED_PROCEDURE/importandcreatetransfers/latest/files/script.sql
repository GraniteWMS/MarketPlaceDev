CREATE PROCEDURE [dbo].[ImportAndCreateTransfers]
    @MasterDocumentNumber  varchar(40),
    @FromERPLocation       int,               
    @filename              nvarchar(4000)     
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    
    BEGIN TRY
        TRUNCATE TABLE dbo.Import_Distribution_Raw;
        
        DECLARE @stamp nvarchar(30) =
            REPLACE(REPLACE(REPLACE(CONVERT(nvarchar(30), SYSDATETIME(), 126), ':','-'),'.','-'),'T','_');
        DECLARE @badfile nvarchar(4000) = CONCAT(
            CAST(@filename AS nvarchar(4000)) COLLATE DATABASE_DEFAULT,
            N'.',
            CAST(@stamp AS nvarchar(30)) COLLATE DATABASE_DEFAULT,
            N'.bad'
        );
        
        DECLARE @bulk_csv_default nvarchar(max) = N'
BULK INSERT dbo.Import_Distribution_Raw
FROM ''' + REPLACE(@filename,'''','''''') + N'''
WITH (
    FORMAT = ''CSV'',
    FIRSTROW = 2,
    CODEPAGE = ''65001'',
    FIELDQUOTE = ''"'',
    TABLOCK,
    ERRORFILE = ''' + REPLACE(@badfile,'''','''''') + N''',
    MAXERRORS = 1
);';
        
        DECLARE @bulk_csv_lf nvarchar(max) = N'
BULK INSERT dbo.Import_Distribution_Raw
FROM ''' + REPLACE(@filename,'''','''''') + N'''
WITH (
    FORMAT = ''CSV'',
    FIRSTROW = 2,
    CODEPAGE = ''65001'',
    FIELDQUOTE = ''"'',
    ROWTERMINATOR = ''0x0a'',
    TABLOCK,
    ERRORFILE = ''' + REPLACE(@badfile,'''','''''') + N''',
    MAXERRORS = 1
);';
        
        DECLARE @bulk_classic_default nvarchar(max) = N'
BULK INSERT dbo.Import_Distribution_Raw
FROM ''' + REPLACE(@filename,'''','''''') + N'''
WITH (
    DATAFILETYPE = ''char'',
    CODEPAGE = ''65001'',
    FIRSTROW = 2,
    FIELDTERMINATOR = '','',
    TABLOCK,
    ERRORFILE = ''' + REPLACE(@badfile,'''','''''') + N''',
    MAXERRORS = 1
);';
        
        DECLARE @bulk_classic_lf nvarchar(max) = N'
BULK INSERT dbo.Import_Distribution_Raw
FROM ''' + REPLACE(@filename,'''','''''') + N'''
WITH (
    DATAFILETYPE = ''char'',
    CODEPAGE = ''65001'',
    FIRSTROW = 2,
    FIELDTERMINATOR = '','',
    ROWTERMINATOR = ''0x0a'',
    TABLOCK,
    ERRORFILE = ''' + REPLACE(@badfile,'''','''''') + N''',
    MAXERRORS = 1
);';
        BEGIN TRY
            EXEC sys.sp_executesql @bulk_csv_default;
        END TRY
        BEGIN CATCH
            IF ERROR_MESSAGE() LIKE '%IID_IColumnsInfo%'
            BEGIN
                TRUNCATE TABLE dbo.Import_Distribution_Raw;
                BEGIN TRY
                    EXEC sys.sp_executesql @bulk_classic_default;
                END TRY
                BEGIN CATCH
                    IF ERROR_MESSAGE() LIKE '%Cannot fetch a row from OLE DB provider "BULK"%'
                    BEGIN
                        TRUNCATE TABLE dbo.Import_Distribution_Raw;
                        EXEC sys.sp_executesql @bulk_classic_lf;
                    END
                    ELSE THROW;
                END CATCH
            END
            ELSE IF ERROR_MESSAGE() LIKE '%Cannot fetch a row from OLE DB provider "BULK"%'
            BEGIN
                TRUNCATE TABLE dbo.Import_Distribution_Raw;
                EXEC sys.sp_executesql @bulk_csv_lf;
            END
            ELSE THROW;
        END CATCH
    END TRY
    BEGIN CATCH
        DECLARE @msgBulk nvarchar(4000) = ERROR_MESSAGE();
        RAISERROR(N'BULK import failed: %s. Check error files starting with: %s', 16, 1, @msgBulk, @badfile);
        RETURN;
    END CATCH
    
    BEGIN TRY
        BEGIN TRAN;
        
        IF OBJECT_ID('tempdb..#staging') IS NOT NULL DROP TABLE #staging;
        CREATE TABLE #staging (
            MasterDocumentNumber  varchar(40)  NOT NULL,
            [System ID]           varchar(40)  NOT NULL,
            [Manufact. SKU]       varchar(80)  NULL,
            [Item]                varchar(200) NULL,
            [Order Qty.]          decimal(18,3) NULL,
            WH_ALP                decimal(18,3) NULL,
            WH_BAT                decimal(18,3) NULL,
            WH_BH                 decimal(18,3) NULL,
            WH_EC                 decimal(18,3) NULL,
            WH_FOR                decimal(18,3) NULL,
            WH_MID                decimal(18,3) NULL,
            WH_PTC                decimal(18,3) NULL,
            WH_UGA                decimal(18,3) NULL,
            BACKSTOCK             decimal(18,3) NULL
        );
        INSERT INTO #staging (
            MasterDocumentNumber, [System ID], [Manufact. SKU], [Item], [Order Qty.],
            WH_ALP, WH_BAT, WH_BH, WH_EC, WH_FOR, WH_MID, WH_PTC, WH_UGA, BACKSTOCK
        )
        SELECT
            @MasterDocumentNumber,
            r.[System ID], r.[Manufact. SKU], r.[Item], r.[Order Qty.],
            r.WH_ALP, r.WH_BAT, r.WH_BH, r.WH_EC, r.WH_FOR, r.WH_MID, r.WH_PTC, r.WH_UGA,
            r.BACKSTOCK
        FROM dbo.Import_Distribution_Raw r;
        
        IF OBJECT_ID('tempdb..#Resolved') IS NOT NULL DROP TABLE #Resolved;
        SELECT
            s.MasterDocumentNumber,
            ItemCode   = s.[System ID],
            DestWH     = v.WHCode,
            Qty        = v.Qty,
            mi.ID      AS Item_id,
            mi.UOM     AS ItemUOM,
            ToLocation = CAST(ssd.[Value] AS int)
        INTO #Resolved
        FROM #staging s
        CROSS APPLY (VALUES
            ('ALP', s.WH_ALP),
            ('BAT', s.WH_BAT),
            ('BH' , s.WH_BH ),
            ('EC' , s.WH_EC ),
            ('FOR', s.WH_FOR),
            ('MID', s.WH_MID),
            ('PTC', s.WH_PTC),
            ('UGA', s.WH_UGA)
        ) v(WHCode, Qty)
        LEFT JOIN dbo.MasterItem mi
               ON mi.Code COLLATE DATABASE_DEFAULT = s.[System ID] COLLATE DATABASE_DEFAULT
        LEFT JOIN dbo.SystemStaticData ssd
               ON ssd.[Group] COLLATE DATABASE_DEFAULT = 'StoreCode' COLLATE DATABASE_DEFAULT
              AND ssd.[Key]   COLLATE DATABASE_DEFAULT = v.WHCode   COLLATE DATABASE_DEFAULT
        WHERE v.Qty IS NOT NULL AND v.Qty <> 0;
        
        IF EXISTS (SELECT 1 FROM #Resolved WHERE Item_id IS NULL OR ToLocation IS NULL)
        BEGIN
            DECLARE @example nvarchar(4000) =
            (
                SELECT TOP 1 CONCAT(
                    CAST('ItemCode='   AS nvarchar(50)) COLLATE DATABASE_DEFAULT, CAST(ItemCode AS nvarchar(200)) COLLATE DATABASE_DEFAULT,
                    CAST(', DestWH='   AS nvarchar(50)) COLLATE DATABASE_DEFAULT, CAST(DestWH   AS nvarchar(50))  COLLATE DATABASE_DEFAULT,
                    CAST(', Qty='      AS nvarchar(50)) COLLATE DATABASE_DEFAULT, CAST(Qty      AS nvarchar(50))  COLLATE DATABASE_DEFAULT,
                    CAST(', Item_id='  AS nvarchar(50)) COLLATE DATABASE_DEFAULT, CAST(ISNULL(CAST(Item_id AS nvarchar(20)),N'NULL') AS nvarchar(20)) COLLATE DATABASE_DEFAULT,
                    CAST(', ToLocation=' AS nvarchar(50)) COLLATE DATABASE_DEFAULT, CAST(ISNULL(CAST(ToLocation AS nvarchar(20)),N'NULL') AS nvarchar(20)) COLLATE DATABASE_DEFAULT
                )
                FROM #Resolved
                WHERE Item_id IS NULL OR ToLocation IS NULL
            );
            RAISERROR(N'Import aborted: Missing MasterItem or StoreCode mapping. Example: %s',16,1,@example);
        END
        
        DECLARE @LineIsNumeric bit =
        CASE WHEN EXISTS (
            SELECT 1
            FROM sys.columns c
            JOIN sys.types   t ON c.user_type_id = t.user_type_id
            WHERE c.object_id = OBJECT_ID('dbo.DocumentDetail')
              AND c.name = 'LineNumber'
              AND t.name IN ('int','bigint','smallint','tinyint','numeric','decimal')
        ) THEN 1 ELSE 0 END;
        
        ;WITH DocTargets AS (
            SELECT DISTINCT
                DocNumber = CONCAT(
                    CAST(s.MasterDocumentNumber AS nvarchar(200)) COLLATE DATABASE_DEFAULT,
                    N'_',
                    CAST(s.DestWH AS nvarchar(50)) COLLATE DATABASE_DEFAULT
                ),
                TradingPartnerCode = s.DestWH
            FROM #Resolved s
        )
        INSERT INTO dbo.[Document]
            (Number, [Type], [Status], TradingPartnerCode, [Description],
             CreateDate, IsActive, ERPLocation, ERPSyncFailed, AuditDate,AuditUser)
        SELECT
            dt.DocNumber,
            'TRANSFER',
            'ENTERED',
            dt.TradingPartnerCode,
            CONCAT(
                CAST(N'Transfer from WH for PO:' AS nvarchar(200)) COLLATE DATABASE_DEFAULT,
                CAST(@MasterDocumentNumber AS nvarchar(100)) COLLATE DATABASE_DEFAULT
            ),
            GETDATE(), 1, @FromERPLocation, 0, getdate(), 'INTEGRATION'
        FROM DocTargets dt
        WHERE NOT EXISTS (
            SELECT 1 FROM dbo.[Document] d
            WHERE d.Number COLLATE DATABASE_DEFAULT = dt.DocNumber COLLATE DATABASE_DEFAULT
        );
        
        DECLARE @DocIds TABLE (DocNumber nvarchar(250) PRIMARY KEY, Document_id bigint);
        INSERT @DocIds (DocNumber, Document_id)
        SELECT d.Number, d.ID
        FROM dbo.[Document] d
        JOIN (
            SELECT DISTINCT
                CONCAT(
                    CAST(s.MasterDocumentNumber AS nvarchar(200)) COLLATE DATABASE_DEFAULT,
                    N'_',
                    CAST(s.DestWH AS nvarchar(50)) COLLATE DATABASE_DEFAULT
                ) AS DocNumber
            FROM #Resolved s
        ) x
          ON d.Number COLLATE DATABASE_DEFAULT = x.DocNumber COLLATE DATABASE_DEFAULT;
        
        ;WITH LineAgg AS (
            SELECT
                DocNumber = CONCAT(
                    CAST(r.MasterDocumentNumber AS nvarchar(200)) COLLATE DATABASE_DEFAULT,
                    N'_',
                    CAST(r.DestWH AS nvarchar(50)) COLLATE DATABASE_DEFAULT
                ),
                r.Item_id,
                r.ItemUOM,
                ToLocation = r.ToLocation,
                Qty        = SUM(r.Qty)
            FROM #Resolved r
            GROUP BY r.MasterDocumentNumber, r.DestWH, r.Item_id, r.ItemUOM, r.ToLocation
        ),
        Numbered AS (
            SELECT
                la.DocNumber,
                la.Item_id,
                la.ItemUOM,
                la.ToLocation,
                la.Qty,
                Seq = ROW_NUMBER() OVER (PARTITION BY la.DocNumber ORDER BY la.Item_id)
            FROM LineAgg la
        )
        MERGE dbo.DocumentDetail AS tgt
        USING (
            SELECT
                di.Document_id,
                n.Item_id,
                n.ItemUOM,
                n.ToLocation,
                n.Qty,
                LineNumberOut =
                    CASE WHEN @LineIsNumeric = 1
                         THEN CAST(n.Seq * 10 AS sql_variant)
                         ELSE CAST(RIGHT(REPLICATE('0',5) + CAST(n.Seq * 10 AS varchar(10)),5) AS sql_variant)
                    END
            FROM Numbered n
            JOIN @DocIds di
              ON di.DocNumber COLLATE DATABASE_DEFAULT = n.DocNumber COLLATE DATABASE_DEFAULT
        ) AS src
        ON  tgt.Document_id = src.Document_id
        AND tgt.Item_id      = src.Item_id
        WHEN MATCHED THEN
            UPDATE SET
                tgt.Qty           = src.Qty,
                tgt.UOM           = src.ItemUOM,
                tgt.FromLocation  = @FromERPLocation,
                tgt.ToLocation    = src.ToLocation,
                tgt.Completed     = 0,
                tgt.ERPSyncFailed = 0
        WHEN NOT MATCHED THEN
            INSERT (Document_id, Item_id, LineNumber, Qty, UOM, FromLocation, ToLocation, Completed, ERPSyncFailed)
            VALUES (src.Document_id, src.Item_id, CAST(src.LineNumberOut AS varchar(20)), src.Qty, src.ItemUOM,
                    @FromERPLocation, src.ToLocation, 0, 0);
        COMMIT;
        
        BEGIN TRY
            DECLARE @mvSrc nvarchar(4000) = @filename;
            
            DECLARE @mvRev nvarchar(4000) = REVERSE(@mvSrc);
            DECLARE @mvIdx int = CHARINDEX('\', @mvRev);
            DECLARE @mvFile nvarchar(4000) = RIGHT(@mvSrc, @mvIdx - 1);
            DECLARE @mvFolder nvarchar(4000)   = LEFT(@mvSrc, LEN(@mvSrc) - @mvIdx);
            
            DECLARE @mvArchiveFolder nvarchar(4000) = CONCAT(@mvFolder, N'\Archive');
            DECLARE @mvDest nvarchar(4000) = CONCAT(@mvArchiveFolder, N'\', @mvFile);
            
            DECLARE @mvFS int, @mvRC int, @mvHR int;
            EXEC @mvHR = sp_OACreate 'Scripting.FileSystemObject', @mvFS OUT;
            IF @mvHR <> 0
            BEGIN
                RAISERROR(N'Archive move: failed to create FileSystemObject (hr=0x%x).', 10, 1, @mvHR);
                GOTO _ArchiveCleanup_mv;
            END
            
            EXEC @mvHR = sp_OAMethod @mvFS, 'FolderExists', @mvRC OUT, @mvArchiveFolder;
            IF @mvHR = 0 AND @mvRC = 0
            BEGIN
                EXEC @mvHR = sp_OAMethod @mvFS, 'CreateFolder', NULL, @mvArchiveFolder;
                IF @mvHR <> 0
                BEGIN
                    RAISERROR(N'Archive move: failed to create folder %s (hr=0x%x).', 10, 1, @mvArchiveFolder, @mvHR);
                    GOTO _ArchiveCleanup_mv;
                END
            END
            
            EXEC @mvHR = sp_OAMethod @mvFS, 'FileExists', @mvRC OUT, @mvDest;
            IF @mvHR = 0 AND @mvRC = 1
            BEGIN
                DECLARE @mvDot int = LEN(@mvFile) - CHARINDEX('.', REVERSE(@mvFile)) + 1;
                DECLARE @mvNameOnly nvarchar(4000) =
                    CASE WHEN @mvDot > 0 THEN LEFT(@mvFile, @mvDot - 1) ELSE @mvFile END;
                DECLARE @mvExt nvarchar(50) =
                    CASE WHEN @mvDot > 0 THEN SUBSTRING(@mvFile, @mvDot, LEN(@mvFile)) ELSE N'' END;
                DECLARE @mvTs nvarchar(30) =
                    REPLACE(REPLACE(REPLACE(CONVERT(nvarchar(30), SYSDATETIME(), 126), ':','-'),'.','-'),'T','_');
                SET @mvDest = CONCAT(@mvArchiveFolder, N'\', @mvNameOnly, N'.', @mvTs, @mvExt);
            END
            
            EXEC @mvHR = sp_OAMethod @mvFS, 'MoveFile', NULL, @mvSrc, @mvDest;
            IF @mvHR <> 0
                RAISERROR(N'Archive move: failed moving %s -> %s (hr=0x%x).', 10, 1, @mvSrc, @mvDest, @mvHR);
            ELSE
                RAISERROR(N'Archive move: moved %s -> %s', 10, 1, @mvSrc, @mvDest);
_ArchiveCleanup_mv:
            IF @mvFS IS NOT NULL EXEC sp_OADestroy @mvFS;
        END TRY
        BEGIN CATCH
            
            DECLARE @moveErr nvarchar(4000) = ERROR_MESSAGE();
            RAISERROR(N'Archive move: %s', 10, 1, @moveErr);
        END CATCH
        
        SELECT d.Number, d.ID, d.TradingPartnerCode, COUNT(dd.ID) AS LineCount
        FROM dbo.[Document] d
        JOIN @DocIds di ON di.Document_id = d.ID
        LEFT JOIN dbo.DocumentDetail dd ON dd.Document_id = d.ID
        GROUP BY d.Number, d.ID, d.TradingPartnerCode
        ORDER BY d.Number;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        DECLARE @msg nvarchar(4000) = ERROR_MESSAGE();
        DECLARE @sev int = ERROR_SEVERITY();
        DECLARE @st  int = ERROR_STATE();
        RAISERROR(@msg, @sev, @st);
    END CATCH
END
