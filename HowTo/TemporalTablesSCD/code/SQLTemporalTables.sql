USE [Outline]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[_CreateTemporalClientTables]

AS
BEGIN 

	BEGIN
		IF  NOT EXISTS (SELECT 1 FROM sys.tables  WHERE name = 'DimClient_History') 
	
			CREATE TABLE [dbo].[DimClient_History](
				[ClientKey] [int] NOT NULL,
				[ClientCode] [int] NOT NULL,
				[ClientName] [nvarchar](150) NULL,
				[Address1] [nvarchar](50) NULL,
				[Address2] [nvarchar](50) NULL,
				[Town] [nvarchar](50) NULL,
				[County] [nvarchar](50) NULL,
				[Country] [nvarchar](50) NULL,
				[ClientType] [nvarchar](20) NULL,
				[ClientActive] [nvarchar](10) NULL,
				[ClientSCDIndex] [int] NOT NULL,
				[SysStartTime] [datetime2](7) NOT NULL,
				[SysEndTime] [datetime2](7) NOT NULL
			) ON [PRIMARY]
		
	END
	
	BEGIN
	    --If table is system-versioned, SYSTEM_VERSIONING must be set to OFF first 
	    IF ((SELECT temporal_type FROM sys.tables WHERE object_id = OBJECT_ID('dbo.DimClient', 'U')) = 2)
	    BEGIN
	        ALTER TABLE [dbo].[DimClient] SET (SYSTEM_VERSIONING = OFF)
	    END
	    DROP TABLE IF EXISTS [dbo].[DimClient]
	END


	--Create system-versioned temporal table. It must have primary key and two datetime2 columns that are part of SYSTEM_TIME period definition
	CREATE TABLE [dbo].[DimClient]
	(
	    ClientKey [int] IDENTITY(1,1) NOT NULL,
		[ClientCode] [int] NOT NULL,
		[ClientName] [nvarchar](150) NULL,
		[Address1] [nvarchar](50) NULL,
		[Address2] [nvarchar](50) NULL,
		[Town] [nvarchar](50) NULL,
		[County] [nvarchar](50) NULL,
		[Country] [nvarchar](50) NULL,
		[ClientType] [nvarchar](20) NULL,
		[ClientActive] [nvarchar](10) NULL,
		[ClientSCDIndex] INT NOT NULL DEFAULT (0),
	
	    --Period columns and PERIOD FOR SYSTEM_TIME definition
	    SysStartTime datetime2(7) GENERATED ALWAYS AS ROW START  NOT NULL ,
	    SysEndTime datetime2(7) GENERATED ALWAYS AS ROW END  NOT NULL ,
	    PERIOD FOR SYSTEM_TIME(SysStartTime,SysEndTime),
	
	    --Primary key definition
	    CONSTRAINT PK_DimClient PRIMARY KEY (ClientKey)
	)
	WITH
	(
	    --Set SYSTEM_VERSIONING to ON and provide reference to HISTORY_TABLE. 
	    SYSTEM_VERSIONING = ON 
	    (
	        --If HISTORY_TABLE does not exists, default table will be created.
	        HISTORY_TABLE = [dbo].[DimClient_History],
	        --Specifies whether data consistency check will be performed across current and history tables (default is ON)
	        DATA_CONSISTENCY_CHECK = ON
	    )
	)
	
END


