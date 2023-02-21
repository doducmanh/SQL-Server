USE [PowerBI]
GO

/****** Object:  View [DPO].[AD_FYP]    Script Date: 30/09/2022 16:21:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [DPO].[AD_FYP] AS

SELECT 
      [AD_Code]
      ,SUBSTRING([ID], 1, len([ID])-2) AS [ID]
      ,SUM([FYP]) AS FYP
      ,SUM([RYP]) AS RYP
      ,SUM([Topup]) AS Topup
	  ,SUM([FYP]) + SUM([Topup]) * 0.1 AS FYPinclTopup

  FROM [PowerBI].[DPO].[Cal_AD_Premium]
  WHERE ID IS NOT NULL
  GROUP BY       [AD_Code]
      ,SUBSTRING([ID], 1, len([ID])-2)
	  --order by [ID]
GO


