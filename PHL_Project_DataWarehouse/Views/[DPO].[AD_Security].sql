USE [PowerBI]
GO

/****** Object:  View [DPO].[AD_Security]    Script Date: 30/09/2022 16:22:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [DPO].[AD_Security] AS 
SELECT DISTINCT
	[AD Code] AS AD_Code
	,[AD Name] AS AD_Name
	,[User] AS ADUsername
FROM [PowerBI].[DPO].[AD Info]
GO


