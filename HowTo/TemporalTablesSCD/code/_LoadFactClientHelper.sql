ALTER PROCEDURE [dbo].[_LoadFactClient]
AS

BEGIN

	DECLARE	@EODDateId INT,
			@ClientCount INT
	-- date parms are using a simple current date from a statndard date dimension
	-- and using that to form a datetime that will constrain History rows
	DECLARE @EODDate Date = (SELECT FullDate FROM dbo.DimDate WHERE CurrentEOD = 1 ),
			@DefaultTime time(7) = '23:59:59.9999999'

	SET @EODDate = (SELECT CAST(CONCAT(@EODDate, ' ', @DefaultTime) AS DATETIME2(7)))

	SET @ClientCount = 0
					
	-- To identify CurrentEOD fact rows 
	SET @EODDateId = (SELECT TOP(1) DateId FROM dbo.DimDate WHERE CurrentEOD = 1)

	BEGIN TRANSACTION;
		
		--Upsert
		MERGE INTO dbo.factClient AS TRG
		USING dbo.DimClient AS SRC
		ON (SRC.ClientKey = TRG.ClientKey)
		-- Insert new fact row
		WHEN NOT MATCHED THEN 
		INSERT (DateKey,
		ClientKey,
		ClientCode,
		ClientCount)
		VALUES (@EODDateId,
		SRC.ClientKey,
		SRC.ClientCode,
		@ClientCount + 1)

		/**
		 * Update fact row if change detected 
		 * for this factless fact table there are no measures 
		 * or surrogate keys to update 
		 */
		WHEN MATCHED 
		AND ISNULL(TRG.ClientCode,'') <> ISNULL(SRC.ClientCode,'') -- for example if the Client code changed 
		-- OR (ISNULL(TRG.otherFactcols,'') <> ISNULL(SRC.otherDimcols,''))

		-- Update the measures and surrogate keys
		THEN UPDATE 
		SET TRG.ClientCode = SRC.ClientCode; -- for example if the Client code changed 

		-- Insert History rows
		INSERT factClient 
		(
			
			DateKey,
			ClientKey,
			ClientCode,
			ClientHistoryKey,
			ClientCount		
		)	
		SELECT 
			DateKey =  dd.DateId,
			ClientKey = ClientKey,
			ClientCode = ClientCode,
			ClientHistoryKey = ClientSCDIndex,
			ClientCount = 0
		FROM dbo.DimClient_History H
		INNER JOIN DimDate dd on dd.FullDate = CONVERT(DATE,H.SysEndTime, 23)
		WHERE CONVERT(DATE,H.SysEndTime, 23) = @EODDate 
		AND
		H.ClientSCDIndex NOT IN (SELECT ClientHistoryKey FROM dbo.factClient)

		
	COMMIT TRANSACTION;

END
