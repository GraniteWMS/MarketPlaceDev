CREATE PROCEDURE [dbo].[Prescript_CCF_PACKPALLET_Batch]
(
    @input dbo.ScriptInputParameters READONLY 
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Output TABLE
    (
        Name  varchar(max),
        Value varchar(max)
    );
    DECLARE @valid bit = 0;
    DECLARE @message varchar(MAX);
    DECLARE @stepInput varchar(MAX);
    DECLARE @site varchar(10) = 'CCF';
    DECLARE @MasterItem varchar(50) ='110028534'
    DECLARE @ShelfLife int
    DECLARE @ManufactureDate varchar(10)
    DECLARE @ExpiryDate varchar(10)
    DECLARE @Today date = CONVERT(date, GETDATE());
    DECLARE @Batch varchar(50);
    DECLARE @JulianDay int;
    DECLARE @EnteredYear int;
    DECLARE @EnteredDate date;
    DECLARE @DaysInYear int;
    DECLARE @CurrentJulianDateCode varchar(5);
    
    SELECT @stepInput = Value
    FROM @input
    WHERE Name = 'StepInput';
    SET @Batch = @stepInput;
    
    SET @CurrentJulianDateCode =
        RIGHT('000' + CONVERT(varchar(3), DATEPART(DAYOFYEAR, @Today)), 3)
        +
        RIGHT(CONVERT(varchar(4), YEAR(@Today)), 2);
    BEGIN TRY
        
        IF @Batch IS NULL
           OR DATALENGTH(@Batch) <> 9
        BEGIN
            RAISERROR(
                'Lot Number must be exactly 9 characters in the format DDDYY-CCF. Example: %s-CCF',
                16,
                1,
                @CurrentJulianDateCode
            );
        END;
        
        IF LEFT(@Batch, 5) LIKE '%[^0-9]%'
        BEGIN
            RAISERROR(
                'The first 5 characters must be numeric in the format DDDYY. Example: %s-CCF',
                16,
                1,
                @CurrentJulianDateCode
            );
        END;
        
        IF SUBSTRING(@Batch, 6, 4) <> '-' + @site
        BEGIN
            RAISERROR(
                'Lot Number must end in -CCF and be in the exact format DDDYY-CCF.',
                16,
                1
            );
        END;
        
        SET @JulianDay =
            CONVERT(int, SUBSTRING(@Batch, 1, 3));
        SET @EnteredYear =
            2000 + CONVERT(int, SUBSTRING(@Batch, 4, 2));
        
        SET @DaysInYear =
            DATEDIFF
            (
                DAY,
                DATEFROMPARTS(@EnteredYear, 1, 1),
                DATEFROMPARTS(@EnteredYear + 1, 1, 1)
            );
        
        IF @JulianDay < 1
           OR @JulianDay > @DaysInYear
        BEGIN
            RAISERROR(
                'Invalid Julian Date. Day %d is not valid for year %d.',
                16,
                1,
                @JulianDay,
                @EnteredYear
            );
        END;
        
        SET @EnteredDate =
            DATEADD
            (
                DAY,
                @JulianDay - 1,
                DATEFROMPARTS(@EnteredYear, 1, 1)
            );
        
        IF @EnteredDate > @Today
        BEGIN
            RAISERROR(
                'You cannot produce a pallet for a future Date Code. Today has date code %s.',
                16,
                1,
                @CurrentJulianDateCode
            );
        END;
        
        IF @EnteredDate < DATEADD(DAY, -30, @Today)
        BEGIN
            RAISERROR(
                'You cannot produce a pallet for a Date Code older than 30 days. Today has date code %s.',
                16,
                1,
                @CurrentJulianDateCode
            );
        END;
        
        SELECT
            @valid = 1,
            @message =
                CONCAT(
                    'Lot Number accepted as ',
                    @stepInput,
                    ' - Production Date ',
                    CONVERT(varchar(10), @EnteredDate, 120)
                );
	    SELECT @ManufactureDate = CONVERT(varchar(8), @EnteredDate, 112)
	    INSERT INTO @Output
	    SELECT 'ManufactureDate', @ManufactureDate
	    SELECT @ShelfLife = isnull(ShelfLife,0) FROM MasterItem WHERE Code = @MasterItem
	    IF @ShelfLife = 0 SET @ShelfLife = 30
	    SELECT @ExpiryDate = CONVERT(varchar(8), DATEADD(D,@ShelfLife,@EnteredDate),112)
	    INSERT INTO @Output
	    SELECT 'ExpiryDate', @ExpiryDate
    END TRY
    BEGIN CATCH
        SELECT
            @valid = 0,
            @message = ERROR_MESSAGE();
    END CATCH;
    
    INSERT INTO @Output
    SELECT 'Message', @message;
    INSERT INTO @Output
    SELECT 'Valid', @valid;
    INSERT INTO @Output
    SELECT 'StepInput', @stepInput;
    SELECT *
    FROM @Output;
END
