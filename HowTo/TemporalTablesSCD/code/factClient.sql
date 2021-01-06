
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[factClient](
	[FactKey] [int] IDENTITY(1,1) NOT NULL,
	[DateKey] [int] NOT NULL,
	[ClientKey] [int] NOT NULL,
	[ClientCode] [int] NOT NULL,
	[ClientHistoryKey] [int] NOT NULL,
	[ClientCount] [int] NOT NULL,
 CONSTRAINT [PK_factClient] PRIMARY KEY CLUSTERED 
(
	[FactKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[factClient] ADD  CONSTRAINT [DF_factClient_ClientHistoryKey]  DEFAULT ((0)) FOR [ClientHistoryKey]
GO
