USE [PowerBI]
GO

/****** Object:  View [DPO].[vPS_PY2]    Script Date: 30/09/2022 16:43:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [DPO].[vPS_PY2] AS

SELECT
	CAST([Due] AS date) AS Due
	,[Sales_Unit_Code] AS [AD Code]
	,[Sales Unit] AS [AD Name]
	,SUM([Collected]) AS [Actual Premium]
	,SUM([Original Pre]) [Expected Premium]
FROM [DPO].[PS_PY2]
GROUP BY 
	[Due]
	,[Sales_Unit_Code]
	,[Sales Unit]
GO


