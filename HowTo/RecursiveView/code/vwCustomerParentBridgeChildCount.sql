SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwCustomerParentBridgeChildCount]
AS
SELECT        ParentCustomerId AS CustomerId, COUNT(CustomerId) - 1 AS 'Children'
FROM            dbo.vwCustomerParentBridge
GROUP BY ParentCustomerId
GO

