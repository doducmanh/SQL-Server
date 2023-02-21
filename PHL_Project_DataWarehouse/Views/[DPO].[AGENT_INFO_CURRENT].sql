USE [PowerBI]
GO

/****** Object:  View [DPO].[AGENT_INFO_CURRENT]    Script Date: 30/09/2022 16:29:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/

CREATE VIEW [DPO].[AGENT_INFO_CURRENT] AS
WITH A AS (
SELECT 
	   A.[Agent_Number] + CONVERT(CHAR(6), GETDATE(), 112) AS ID
	  ,[Area_Name]
      ,[Sales_Unit]
      ,[Sales_Unit_Code]
      ,[Parent_Supervisor_Code]
      ,[Parent_Supervisor_Name]
      ,[Supervisor_Code]
      ,[Supervisor_Name]
      ,[Agent_Number]
      ,[Agent_Name]
      ,[Gender]
      ,[Grade]
      ,[Club_Class]
      ,[Agent_Status]
      ,[Birthday]
      ,[BirthPlace]
      ,[ID_Card]
      ,[Issued Date]
      ,[Issued Place]
      ,[Marriage]
      ,[Age]
      ,[Client_Code]
      ,[Client_Name]
      ,[Email]
      ,[Telephone]
      ,[Hand_Phone]
      ,[Contact Address]
      ,[Contact2]
      ,[Contact3]
      ,[Contact4]
      ,[Contact5]
      ,[Alternate_Address]
      ,[Alternate2]
      ,[Alternate3]
      ,[Alternate4]
      ,[Alternate5]
      ,[Date_Appointed]
      ,[Terminated_date]
      ,[Reason Terminated]
      ,[Recovered Date]
      ,[Client Number of Introducer]
      ,[Client Name of Introducer]
      ,[Client ID number of Introducer]
      ,[Agent Numer of Introducer]
      ,[Agent_Bank_Account]
      ,[Bank_Code]
      ,[Bank Name]
      ,[Bank_Address]
      ,[Bank_Address2]
      ,[Bank_Address3]
      ,[Bank_Address4]
      ,[License_No]
      ,[Tax Code]
      ,[Tax Office]
      ,[Previous Insurance]
      ,[Experience in the insurance]
      ,[Agent Classification]
      ,[Promote_Date]
      ,[Demote_Date]
      ,[Effective_Date_Club_Class]
      ,[Bank_Number]
      ,[Leader]
      ,[SFC]
      ,[Leader_count]
      ,[Appointed_TAPSU]
  FROM [PowerBI].[DPO].[Main_AGENT_INFO_DA] AS A

)
,HISTORY AS (
	SELECT  [AGENT CODE]
	,MAX([CURRFROM]) AS DATE_TITLE

	FROM [PowerBI].[DPO].[Main_AGENT_HISTORY]
  
	WHERE [STATUS] IN ('A','D','P','R') --AND [AGENT CODE] =  '60016025'
	GROUP BY [AGENT CODE]
)


SELECT 
	   C.[Territory_Code]
      ,C.[TD]
      ,C.[TDName]
      ,C.[SRD]
      ,C.[SRDName]
      ,C.[RD]
      ,C.[RDName]
      ,C.[SZD]
      ,C.[SZDName]
      ,C.[ZDSZD]
      ,C.[ZDSZDName]
      ,C.[AD_Code]
      ,C.[ADName]
      ,C.[AD_Grade]
	   --B.[AD_Code]
      ,B.[AD_Office]
      ,B.[RM]
	  ,RM.Agent_Name AS RM_Agent_Name
      ,B.[DM]
	  ,DM.Agent_Name AS DM_Agent_Name
      ,B.[FM]
	  ,FM.Agent_Name AS FM_Agent_Name
	  ,A.[Agent_Number]
      ,A.[Agent_Name]
	  ,A.[Grade]
      ,A.[Agent_Status]
	  ,A.[Date_Appointed]
	  ,HISTORY.DATE_TITLE
	  ,A.Demote_Date
	  ,A.Promote_Date
      ,A.[Terminated_date]
	  ,A.[Recovered Date]
	  ,A.[License_No]
      ,A.[Appointed_TAPSU]
      --,B.[GRADE]
      --,B.[Date_Appointed]
      --,B.[Terminated_date]
      ,RM.Agent_Status AS RM_Agent_Status
	  ,B.[RM_Date_Appointed]
	  ,DM.Agent_Status AS DM_Agent_Status
      ,B.[DM_Date_Appointed]
	  ,FM.Agent_Status AS FM_Agent_Status
      ,B.[FM_Date_Appointed]
	  ,B.[SFC]
      ,B.[SFC_MARK_IT]
      ,C.[Appointed_Date] AS AD_Date_Appointed
      ,C.[Terminated_Date] AS AD_Date_Terminated
      --,C.[Last_Status] AS AD_Last_Status
      --,C.[Last_Status_Date] AS AD_Last_Status_Date
      --,C.[DemotePromote_Date] AS AD_DemotePromote_Date

FROM A
LEFT JOIN [DPO].[Main_AGENCY_STRUCTURE] B
ON A.ID = B.ID

LEFT JOIN [DPO].[Main_AD_STRUCTURE_FULL] C
ON B.ID_AD_Current = C.ID


LEFT JOIN A AS RM
ON B.RM = RM.Agent_Number

LEFT JOIN A AS DM
ON B.DM = DM.Agent_Number

LEFT JOIN A AS FM
ON B.FM = FM.Agent_Number

LEFT JOIN HISTORY
ON A.Agent_Number = HISTORY.[AGENT CODE]


--WHERE A.Agent_Number = '60039464'
GO


