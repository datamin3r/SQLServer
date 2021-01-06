SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vwCustomer]
AS
SELECT        dbo.Customer.CustomerId, dbo.Customer.CustomerName, dbo.Customer.CustomerCode, 
                         dbo.Customer.ParentCustomerId, dbo.vwCustomerParentBridgeChildCount.Children
                         
FROM            dbo.Customer LEFT OUTER JOIN
                         dbo.vwCustomerParentBridgeChildCount ON dbo.Customer.CustomerId = dbo.vwCustomerParentBridgeChildCount.CustomerId

GO


