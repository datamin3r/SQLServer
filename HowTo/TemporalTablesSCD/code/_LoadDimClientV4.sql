USE [Outline]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[_LoadDimClient]

AS
BEGIN

	DECLARE @ClientSCDIndex INT

	SET @ClientSCDIndex = (SELECT MAX(ClientSCDIndex) FROM DimClient)	

	-- Initial Dim Load
	IF (SELECT COUNT(ClientKey) FROM DimClient) = 0
	BEGIN
		--If table is system-versioned, SYSTEM_VERSIONING must be set to OFF first 
		IF ((SELECT temporal_type FROM sys.tables WHERE object_id = OBJECT_ID('dbo.DimClient', 'U')) = 2)
		BEGIN
		    ALTER TABLE [dbo].[DimClient] SET (SYSTEM_VERSIONING = OFF)
		END

		INSERT [dbo].[DimClient] (
			ClientCode
		   ,ClientName
		   ,Address1
		   ,Address2
		   ,Town
		   ,County
		   ,Country
		   ,ClientType
		   ,ClientActive
		  )

		SELECT SRC.ClientCode
			 ,SRC.ClientName
			 ,Address1
			 ,Address2
			 ,SRC.Town
			 ,SRC.County
			 ,SRC.Country
			 ,ClientType
			 ,ClientActive
		FROM dbo.Client AS SRC

		-- set ClientSCDIndex to have unique keys 
		UPDATE [dbo].[DimClient] 
		SET ClientSCDIndex = ClientKey
		FROM [dbo].[DimClient]  

		--Set SYSTEM_VERSIONING to ON and provide reference to HISTORY_TABLE. 
		ALTER TABLE [dbo].[DimClient] 
		SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[DimClient_History]));
		
	END

	--Dim UPSERT
	BEGIN TRANSACTION;

		-- Update
		;WITH cte AS
		(
		SELECT ClientKey
			  ,TRG.ClientName
			  ,TRG.Country
			  ,TRG.Town
			  ,TRG.County
			  ,TRG.Address1
			  ,TRG.Address2
			  ,TRG.ClientType
			  ,TRG.ClientActive
			  ,TRG.ClientSCDIndex, ROW_NUMBER() OVER (ORDER BY ClientKey) RowNo
		FROM [dbo].[DimClient]  AS TRG
		INNER JOIN [dbo].[Client] AS SRC ON (TRG.ClientCode = SRC.ClientCode)
		WHERE (		ISNULL(TRG.ClientName,'') <> ISNULL(SRC.ClientName,'') 
				 OR ISNULL(TRG.Address1,'') <> ISNULL(SRC.Address1,'')
				 OR ISNULL(TRG.Address2,'') <> ISNULL(SRC.Address2,'')
				 OR ISNULL(TRG.Town,'') <> ISNULL(SRC.Town,'')
				 OR ISNULL(TRG.County,'') <> ISNULL(SRC.County,'') 
				 OR ISNULL(TRG.Country,'') <> ISNULL(SRC.Country,'') 
				 OR ISNULL(TRG.ClientType,'') <> ISNULL(SRC.ClientType,'')
				 OR ISNULL(TRG.ClientActive,'') <> ISNULL(SRC.ClientActive,'')
			  )
		)

		UPDATE TRG WITH (UPDLOCK, SERIALIZABLE) 
		SET TRG.ClientName = SRC.ClientName,
			TRG.Address1 = SRC.Address1,
			TRG.Address2 = SRC.Address2,
			TRG.Town = SRC.Town,
			TRG.County = SRC.County,
			TRG.Country = SRC.Country,
			TRG.ClientType = SRC.ClientType,
			TRG.ClientActive = SRC.ClientActive,
			TRG.ClientSCDIndex = @ClientSCDIndex + RowNo
		FROM [dbo].[DimClient]  AS TRG
		INNER JOIN cte ON cte.ClientKey = TRG.ClientKey
		INNER JOIN dbo.Client SRC ON TRG.ClientCode = SRC.ClientCode
	
		-- Insert  
		INSERT [dbo].[DimClient] (
			     ClientCode
				,ClientName
				,Address1
				,Address2
				,Town
				,County
				,Country
				,ClientType
				,ClientActive
				,ClientSCDIndex
				)
		SELECT SRC.ClientCode
			  ,SRC.ClientName
			  ,SRC.Address1
			  ,SRC.Address2
			  ,SRC.Town
			  ,SRC.County
			  ,SRC.Country
			  ,SRC.ClientType
			  ,SRC.ClientActive
			  ,@ClientSCDIndex + 1
		FROM [dbo].[Client] SRC
		WHERE NOT EXISTS (SELECT 1 FROM DimClient WHERE ClientCode = SRC.ClientCode);

	COMMIT TRANSACTION;

END