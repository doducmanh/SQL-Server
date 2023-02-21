USE [PowerBI]
GO

/****** Object:  View [DPO].[Fact_CSStaff]    Script Date: 30/09/2022 16:34:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [DPO].[Fact_CSStaff] AS
SELECT [user_name]
FROM [PowerBI].[DPO].[CS_COMPLAINT_DATA]
UNION
SELECT [name]
FROM [PowerBI].[DPO].[CS_WELCOME_DATA]
GO


