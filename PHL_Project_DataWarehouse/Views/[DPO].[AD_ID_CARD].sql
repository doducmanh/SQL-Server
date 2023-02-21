USE [PowerBI]
GO

/****** Object:  View [DPO].[AD_ID_CARD]    Script Date: 30/09/2022 16:22:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [DPO].[AD_ID_CARD] AS

SELECT [AD_Code] AS [Agent_Number]
      ,[ADName] AS [AD Name]
      ,[AD_Grade] AS [Grade]
      ,[Appointed_Date] AS [Date_Appointed]
      ,[Terminated_Date] AS [Terminated_date]
      ,[Last_Status] AS [Status]
	  ,[ID Number] AS [ID_Card]
  FROM [PowerBI].[DPO].[DimAD] A
 LEFT JOIN [PowerBI].[DPO].[AD Info] B ON A.[AD_Code] = B.[AD Code];
GO


