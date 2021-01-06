/**
* Helper SQL snippets
*
*/

CREATE TABLE [dbo].[FactTrade] (
    [FactKey]           INT             IDENTITY (1, 1) NOT NULL,
    [TradeCode]         INT             NOT NULL,
	[CustomerKey]       INT             NOT NULL,
    [TradeCount]        INT             NOT NULL,
    CONSTRAINT [PK_FactTrade] PRIMARY KEY CLUSTERED ([FactKey] ASC)
);

SELECT * FROM Client

SELECT * FROM DimClient
--FOR SYSTEM_TIME ALL
SELECT * FROM DimClient_History

EXEC [dbo].[_LoadDimClient]

SELECT 
--CONCAT(ClientKey, ClientSCDIndex),
* FROM DimClient
--FOR SYSTEM_TIME ALL
ORDER BY ClientKey

SELECT * FROM DimClient_History

UPDATE dbo.Client
SET 
--Town = 'Stourbridge',
--County = 'Worcs'
--Address1 = '124 Northflood St'
--ClientType = 'Corporate'
ClientActive = 'Moribund'
WHERE 
--ClientType  = 'Business'
ClientCode = 20013

SELECT * FROM dbo.Client

EXEC [dbo].[_LoadFactClient]

ALTER TABLE [dbo].[DimClient] SET (SYSTEM_VERSIONING = OFF)
ALTER TABLE [dbo].[DimClient] SET (SYSTEM_VERSIONING = ON)

TRUNCATE TABLE DimClient_History
TRUNCATE TABLE DimClient

UPDATE DimDate
SET CurrentEOD = 1
WHERE FullDate = '2020-12-11'

SELECT * FROM DimDate WHERE CurrentEOD = 1




/*	
    --TRUNCATE TABLE factClient
	SELECT * FROM factClient
exec [dbo].[_LoadFactClient]

SELECT * INTO DimClientHisttmp 
FROM DimClient_History
FOR SYSTEM_TIME ALL


DECLARE @EODDate Date = (SELECT FullDate FROM DimDate WHERE CurrentEOD = 1 ),
@DefaultTime time(7) = '23:59:59.9999999'


SET @EODDate = (SELECT CAST(CONCAT(@EODDate, ' ', @DefaultTime) AS DATETIME2(7)))
SELECT @EODDate 

*/
