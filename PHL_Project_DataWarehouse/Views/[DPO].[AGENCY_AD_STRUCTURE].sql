USE [PowerBI]
GO

/****** Object:  View [DPO].[AGENCY_AD_STRUCTURE]    Script Date: 30/09/2022 16:27:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE   VIEW [DPO].[AGENCY_AD_STRUCTURE] AS
WITH A AS (
SELECT  [ExplodedDate]
      ,[ID]
      ,[ID_AD]
      ,[AD_Office]
      ,[AD_Code]
      ,[RM]
      ,[DM]
      ,[FM]
      ,[Agent_Number]
      ,[GRADE]
      ,[SFC]
      ,[Date_Appointed]
      ,[Terminated_date]
  FROM [PowerBI].[DPO].[Agency_Structure]
  )

  , B AS (
  /****** Script for SelectTopNRows command from SSMS  ******/
SELECT  [ID]
      ,[ExplodedDate]
      --,[Structure]
      ,[Territory_Code]
      ,[TD]
      ,[TDName]
      ,[SRD]
      ,[SRDName]
      ,[RD]
      ,[RDName]
      ,[SZD]
      ,[SZDName]
      --,[ZDSZD]
      --,[ZDSZDName]
      ,[AD_Code]
      ,[ADName]
      ,[AD_Grade]
      ,[Appointed_Date]
      ,[Terminated_Date]
      ,[Last_Status]
      ,[Last_Status_Date]
      ,[DemotePromote_Date]
  FROM [PowerBI].[DPO].[AD00]
  )
  SELECT  B.[ID] AS ID_AD
      ,B.[ExplodedDate]
      --,B.[Structure]
      ,B.[Territory_Code]
      ,B.[TD]
      ,B.[TDName]
      ,B.[SRD]
      ,B.[SRDName]
      ,B.[RD]
      ,B.[RDName]
      ,B.[SZD]
      ,B.[SZDName]
      --,[ZDSZD]
      --,[ZDSZDName]
      ,B.[AD_Code]
      ,B.[ADName]
      ,B.[AD_Grade]
      ,B.[Appointed_Date]
      ,B.[Terminated_Date]
      ,B.[Last_Status]
      ,B.[Last_Status_Date]
      ,B.[DemotePromote_Date]
	  --, A.[ExplodedDate]
      ,A.[ID] AS ID_AGENT
      --,[ID_AD]
      ,A.[AD_Office]
      --,A.[AD_Code]
      ,A.[RM]
      ,A.[DM]
      ,A.[FM]
      ,A.[Agent_Number]
      ,A.[GRADE]
      ,A.[SFC]
      ,A.[Date_Appointed] AS AGENCY_Date_Appointed
      ,A.[Terminated_date] AS AGENCY_Terminated_Date

  FROM A
  LEFT JOIN B
  ON A.ID_AD = B.ID
GO


