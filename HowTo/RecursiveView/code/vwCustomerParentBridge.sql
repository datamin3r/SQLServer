SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwCustomerParentBridge] AS 
  	-- Get parent and children from customer table 
	WITH CTE ([CustomerLevel]
			,[RootId]
			,[CustomerId]
			,[CustomerName]
			,[CustomerCode]
			,[ParentCustomerId]
			,[ParentName]
		)
	AS (
		SELECT 
			CAST(1 AS TINYINT) AS CustomerLevel
			,[CustomerId] AS RootId
			,[CustomerId]
			,[CustomerName]
			,[CustomerCode]
			,[ParentCustomerId]
			,[CustomerName] AS ParentName
	    FROM [dbo].[Customer]
	    WHERE ParentCustomerId IS NULL  

		UNION ALL

	    SELECT 
			CAST(CTE.CustomerLevel + 1 AS tinyint) AS CustomerLevel
			,bs.[CustomerId] AS RootId
			,bs.[CustomerId]
			,bs.[CustomerName] AS ChildName
			,bs.[CustomerCode] AS ChildCode
			,bs.[ParentCustomerId]
			,CTE.[ParentName]
	    FROM [dbo].[Customer] bs 
		INNER JOIN CTE ON bs.ParentCustomerId= CTE.CustomerId 
	   )
	
	SELECT
		[CustomerLevel]
		,[CustomerId]
		,[ParentName] AS CustomerName
		,[ChildCustomerId] = CASE WHEN CustomerName = ParentName THEN NULL ELSE RootId END
		,[ChildCustomerName] = CASE WHEN CustomerName = ParentName THEN NULL ELSE CustomerName END
		,[CustomerCode]
		,COALESCE(ParentCustomerId, CustomerId) AS ParentCustomerId
	FROM CTE