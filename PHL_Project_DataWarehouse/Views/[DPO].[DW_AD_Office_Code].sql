USE [PowerBI]
GO

/****** Object:  View [DPO].[DW_AD_Office_Code]    Script Date: 30/09/2022 16:32:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
CREATE    VIEW [DPO].[DW_AD_Office_Code] AS
SELECT DISTINCT [Sales_Unit_Code]
      ,[Sales_Unit]
	  ,[Area_Name]
FROM [PowerBI].[DPO].[Main_AGENT_INFO_DA]
--ORDER BY Sales_Unit_Code
GO


