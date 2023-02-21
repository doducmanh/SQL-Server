USE [PowerBI]
GO

/****** Object:  View [DPO].[view_Area_AD_Agent]    Script Date: 30/09/2022 16:39:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- view danh sách Agent_Number of Sales_Unit

CREATE    VIEW [DPO].[view_Area_AD_Agent] AS
	SELECT [Area_Name],[Sales_Unit],[Sales_Unit_Code],[Agent_Number]
	FROM [PowerBI].[DPO].[Main_AGENT_INFO_DA]
GO


