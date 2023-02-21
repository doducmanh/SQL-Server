USE [PowerBI]
GO

/****** Object:  View [DPO].[Agency_Structure_Current]    Script Date: 30/09/2022 16:29:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/

CREATE VIEW [DPO].[Agency_Structure_Current] AS
WITH AGENT_STRUCTURE_CURRENT AS (
SELECT  [ID_AD_Current]
      ,[AD_Code_Current]
      ,[AD_Office_Current]
      ,[ID_AD]
      ,[AD_Code]
      ,[AD_Office]
      ,[ExplodedDate]
      ,[ID]
      ,[RM]
      ,[DM]
      ,[FM]
      ,[Agent_Number]
      ,[GRADE]
      ,[L1]
      ,[L1G]
      ,[L2]
      ,[L2G]
      ,[L3]
      ,[L3G]
      ,[L4]
      ,[L4G]
      ,[L5]
      ,[L5G]
      ,[L6]
      ,[L6G]
      ,[L7]
      ,[L7G]
      ,[L8]
      ,[L8G]
      ,[L9]
      ,[L9G]
      ,[L10]
      ,[L10G]
      ,[L0R]
      ,[INDEX_LEADER]
      ,[L1 Direct]
      ,[L2 Direct]
      ,[L3 Direct]
      ,[L4 Direct]
      ,[L5 Direct]
      ,[L6 Direct]
      ,[L7 Direct]
      ,[L8 Direct]
      ,[L9 Direct]
      ,[L10 Direct]
      ,[SFC]
      ,[SFC_MARK_IT]
      ,[Date_Appointed]
      ,[Terminated_date]
      ,[RM_Date_Appointed]
      ,[DM_Date_Appointed]
      ,[FM_Date_Appointed]
      ,[Agent_Name]
      ,[Agent_Status]
      ,[GM]
      ,[GM_Agent_Name]
      ,[GM_Date_Appointed]
      ,[GM_Agent_Status]
      ,[RM_Agent_Name]
      ,[RM_Agent_Status]
      ,[DM_Agent_Name]
      ,[DM_Agent_Status]
      ,[FM_Agent_Name]
      ,[FM_Agent_Status]
  FROM [PowerBI].[DPO].[Main_AGENCY_STRUCTURE]
  WHERE [ExplodedDate] = CONVERT(CHAR(6),GETDATE(),112)
)

, AD_STRUCTURE_CURRENT AS (
SELECT  [ID]
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
  WHERE EOMONTH([ExplodedDate],0) = EOMONTH(GETDATE())

  )

  SELECT 
		B.[Agent_Number] AS ID
        ,B.[ExplodedDate]
		--,B.[ID_AD]
        --,B.[ID]
	  ,A.Territory_Code
	  ,C.Territory
      ,B.[AD_Code]
	  ,A.ADName
	  ,A.AD_Grade
	  ,A.Appointed_Date AS AD_Date_Appointed
	  ,A.Terminated_Date AS AD_Terminated_Date
	  ,A.Last_Status AS AD_Last_Status
	  ,A.TD
	  ,A.TDName
	  ,A.SRD
	  ,A.SRDName
	  ,A.RD
	  ,A.RDName
	  ,A.SZD
	  ,A.SZDName
	  ,A.ZDSZD
	  ,A.ZDSZDName
      ,B.[AD_Office]
      ,B.[Agent_Number]
      ,B.[Agent_Name]      
	  ,B.[GRADE]
      ,B.[Agent_Status]      
	  ,B.[SFC]
      ,B.[SFC_MARK_IT]
      ,B.[Date_Appointed]
      ,B.[Terminated_date]
	  ,B.[GM]
      ,B.[RM]
      ,B.[DM]
      ,B.[FM]
      ,B.[GM_Agent_Name]
      ,B.[RM_Agent_Name]
      ,B.[DM_Agent_Name]
      ,B.[FM_Agent_Name]
      ,B.[GM_Date_Appointed]
      ,B.[RM_Date_Appointed]
      ,B.[DM_Date_Appointed]
      ,B.[FM_Date_Appointed]
      ,B.[GM_Agent_Status]     
      ,B.[RM_Agent_Status]	
      ,B.[DM_Agent_Status]	  
      ,B.[FM_Agent_Status]

  FROM AD_STRUCTURE_CURRENT AS A

  RIGHT JOIN AGENT_STRUCTURE_CURRENT AS B
  ON A.ID = B.ID_AD

  LEFT JOIN  [PowerBI].[DPO].[DW_Territory] AS C
  ON A.Territory_Code = C.Code


  --SELECT TOP (1000) [Code]
  --    ,[Territory]
  --FROM [PowerBI].[DPO].[DW_Territory]
GO


