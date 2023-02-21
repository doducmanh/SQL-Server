USE [PowerBI]
GO

/****** Object:  View [DPO].[vwCLAIM_PREMIUM_RATE]    Script Date: 30/09/2022 16:45:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [DPO].[vwCLAIM_PREMIUM_RATE] AS
SELECT [ALB]
      ,[Sex]
      ,[Class]
      ,[Premium_Rate]
      ,[Claim_Type]
      ,[Female_Early]
      ,[Female_Recover]
  FROM [PowerBI].[DPO].[CLAIM_PREMIUM_RATE]
GO


