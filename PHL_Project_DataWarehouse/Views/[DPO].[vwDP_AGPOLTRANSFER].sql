USE [PowerBI]
GO

/****** Object:  View [DPO].[vwDP_AGPOLTRANSFER]    Script Date: 30/09/2022 16:45:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [DPO].[vwDP_AGPOLTRANSFER] AS
SELECT [CHDRNUM]
      ,[Old Agent]
      ,[Old Agent Effect From ] AS [Old Agent Effect From]
      ,[Current Agent]
      ,[Current Agent Effect From]
      ,[User]
      ,[Old Agent Name]
      ,[Current Agent Name]
  FROM [PowerBI].[DPO].[DP_AGPOLTRANSFER]
GO


