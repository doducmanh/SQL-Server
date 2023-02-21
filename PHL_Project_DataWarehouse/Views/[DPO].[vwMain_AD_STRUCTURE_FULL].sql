USE [PowerBI]
GO

/****** Object:  View [DPO].[vwMain_AD_STRUCTURE_FULL]    Script Date: 30/09/2022 16:46:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [DPO].[vwMain_AD_STRUCTURE_FULL] AS
SELECT [ID]
      ,[ExplodedDate]
      ,[CDOIndex]
      ,[L1new]
      ,[L2new]
      ,[L3new]
      ,[L4new]
      ,[L5new]
      ,[L1]
      ,[L2]
      ,[L3]
      ,[L4]
      ,[L5]
      ,[L1Name]
      ,[L2Name]
      ,[L3Name]
      ,[L4Name]
      ,[L5Name]
      ,[Structure]
      ,[L1NP]
      ,[L2NP]
      ,[L3NP]
      ,[L4NP]
      ,[L5NP]
      ,[L1NPG]
      ,[L2NPG]
      ,[L3NPG]
      ,[L4NPG]
      ,[L5NPG]
      ,[Territory_Code]
      ,[TD]
      ,[TDName]
      ,[SRD]
      ,[SRDName]
      ,[RD]
      ,[RDName]
      ,[SZD]
      ,[SZDName]
      ,[ZDSZD]
      ,[ZDSZDName]
      ,[AD_Code]
      ,[ADName]
      ,[AD_Grade]
      ,[Appointed_Date]
      ,[Terminated_Date]
      ,[Last_Status]
      ,[Last_Status_Date]
      ,[DemotePromote_Date]
  FROM [PowerBI].[DPO].[Main_AD_STRUCTURE_FULL]
GO


