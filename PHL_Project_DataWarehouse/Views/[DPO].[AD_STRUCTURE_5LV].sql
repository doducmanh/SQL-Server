USE [PowerBI]
GO

/****** Object:  View [DPO].[AD_STRUCTURE_5LV]    Script Date: 30/09/2022 16:23:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [DPO].[AD_STRUCTURE_5LV] AS
WITH G AS (
SELECT [AD_Code]
      ,[Grade]
	  ,[AD_Parent_Code]
      ,[ExplodedDate]
	  --,[Territory_Code]
	  ,IIF([Territory_Code] IS NULL, 'PHL', [Territory_Code]) AS [Territory_Code]
	  ,[Start_date]
      ,[End_Date]
	  ,[Status]
	  ,CONCAT([AD_Code],[ExplodedDate]) AS ID
	  ,IIF([AD_Parent_Code] <> '',CONCAT([AD_Parent_Code],[ExplodedDate]),NULL)  AS IDSup
  FROM [PowerBI].[DPO].[AD_STRUCTURE_Exploded0]
  --WHERE [AD_Code] IS NOT NULL
)
,Temp1 AS (
SELECT 
	A.AD_Code
	, A.Grade AS AD_Grade
	, A.ID
	--IIF(A.[AD_Parent_Code] IS NULL,'', A.[AD_Parent_Code]) AS [AD_Parent_Code]
	 ,A.[Territory_Code]
	--,IIF(A.[Office_Code] IS NULL, 'PHL', A.[Office_Code]) AS [Office_Code]
	,A.[ExplodedDate]
	,A.[Start_date]
    ,A.[End_Date]
    ,A.[Status]
	--, A.AD_Code AS AD_Code
	--, A.Grade AS AD_Grade
	, G1.AD_Code AS L1F
	, G1.Grade AS L1FG
	, G2.AD_Code AS L2F
	, G2.Grade AS L2FG
	, G3.AD_Code AS L3F
	, G3.Grade AS L3FG
	, G4.AD_Code AS L4F
	, G4.Grade AS L4FG
	, G5.AD_Code AS L5F
	, G5.Grade AS L5FG
	, CASE
		WHEN G1.Grade = 'CDO' THEN 1
		WHEN G2.Grade = 'CDO' THEN 2
		WHEN G3.Grade = 'CDO' THEN 3
		WHEN G4.Grade = 'CDO' THEN 4
		WHEN G5.Grade = 'CDO' THEN 5
		ELSE 0
	END AS CDOIndex

FROM G AS A

LEFT JOIN G AS G1 ON A.IDSup IS NOT NULL AND A.IDSup = G1.ID 
LEFT JOIN G AS G2 ON G1.IDSup IS NOT NULL AND G1.IDSup = G2.ID 
LEFT JOIN G AS G3 ON G2.IDSup IS NOT NULL AND G2.IDSup = G3.ID 
LEFT JOIN G AS G4 ON G3.IDSup IS NOT NULL AND G3.IDSup = G4.ID 
LEFT JOIN G AS G5 ON G4.IDSup IS NOT NULL AND G4.IDSup = G5.ID 

--LEFT JOIN G AS G1 ON A.[AD_Parent_Code] = G1.AD_Code AND A.ExplodedDate = G1.ExplodedDate
--LEFT JOIN G AS G2 ON G1.AD_Parent_Code = G2.AD_Code AND A.ExplodedDate = G2.ExplodedDate
--LEFT JOIN G AS G3 ON G2.AD_Parent_Code = G3.AD_Code AND A.ExplodedDate = G3.ExplodedDate
--LEFT JOIN G AS G4 ON G3.AD_Parent_Code = G4.AD_Code AND A.ExplodedDate = G4.ExplodedDate
--LEFT JOIN G AS G5 ON G4.AD_Parent_Code = G5.AD_Code AND A.ExplodedDate = G5.ExplodedDate
)
,Temp2 AS (
SELECT Temp1.*
	,CASE
		WHEN CDOIndex = 5 THEN L4F
		WHEN CDOIndex = 4 THEN L3F
		WHEN CDOIndex = 3 THEN L2F
		WHEN CDOIndex = 2 THEN L1F
		WHEN CDOIndex = 1 THEN AD_Code
		--WHEN CDOIndex = 0 THEN ''
		--ELSE ''
	END AS L1new
	,CASE
		WHEN CDOIndex = 5 THEN L3F
		WHEN CDOIndex = 4 THEN L2F
		WHEN CDOIndex = 3 THEN L1F
		WHEN CDOIndex = 2 THEN AD_Code
		WHEN CDOIndex = 1 THEN AD_Code + 'P'
		--WHEN CDOIndex = 0 THEN ''
		--ELSE ''
	END AS L2new
	,CASE
		WHEN CDOIndex = 5 THEN L2F
		WHEN CDOIndex = 4 THEN L1F
		WHEN CDOIndex = 3 THEN AD_Code
		WHEN CDOIndex = 2 THEN AD_Code + 'P'
		WHEN CDOIndex = 1 THEN AD_Code + 'P'
		--WHEN CDOIndex = 0 THEN ''
		--ELSE ''
	END AS L3new
	,CASE
		WHEN CDOIndex = 5 THEN L1F
		WHEN CDOIndex = 4 THEN AD_Code
		WHEN CDOIndex = 3 THEN AD_Code + 'P'
		WHEN CDOIndex = 2 THEN AD_Code + 'P'
		WHEN CDOIndex = 1 THEN AD_Code + 'P'
		--WHEN CDOIndex = 0 THEN ''
		--ELSE ''
	END AS L4new
	,CASE
		WHEN CDOIndex = 5 THEN AD_Code
		WHEN CDOIndex = 4 THEN AD_Code + 'P'
		WHEN CDOIndex = 3 THEN AD_Code + 'P'
		WHEN CDOIndex = 2 THEN AD_Code + 'P'
		WHEN CDOIndex = 1 THEN AD_Code + 'P'
		WHEN CDOIndex = 0 THEN AD_Code
		--ELSE ''
	END AS L5new
		,CASE
		WHEN CDOIndex = 5 THEN L4F
		WHEN CDOIndex = 4 THEN L3F
		WHEN CDOIndex = 3 THEN L2F
		WHEN CDOIndex = 2 THEN L1F
		WHEN CDOIndex = 1 THEN AD_Code
		--WHEN CDOIndex = 0 THEN ''
		--ELSE ''
	END AS L1
	,CASE
		WHEN CDOIndex = 5 THEN L3F
		WHEN CDOIndex = 4 THEN L2F
		WHEN CDOIndex = 3 THEN L1F
		WHEN CDOIndex = 2 THEN AD_Code
		WHEN CDOIndex = 1 THEN AD_Code
		--WHEN CDOIndex = 0 THEN ''
		--ELSE ''
	END AS L2
	,CASE
		WHEN CDOIndex = 5 THEN L2F
		WHEN CDOIndex = 4 THEN L1F
		WHEN CDOIndex = 3 THEN AD_Code
		WHEN CDOIndex = 2 THEN AD_Code
		WHEN CDOIndex = 1 THEN AD_Code
		--WHEN CDOIndex = 0 THEN ''
		--ELSE ''
	END AS L3
	,CASE
		WHEN CDOIndex = 5 THEN L1F
		WHEN CDOIndex = 4 THEN AD_Code
		WHEN CDOIndex = 3 THEN AD_Code
		WHEN CDOIndex = 2 THEN AD_Code
		WHEN CDOIndex = 1 THEN AD_Code
		--WHEN CDOIndex = 0 THEN ''
		--ELSE ''
	END AS L4
	,CASE
		WHEN CDOIndex = 5 THEN AD_Code
		WHEN CDOIndex = 4 THEN AD_Code
		WHEN CDOIndex = 3 THEN AD_Code
		WHEN CDOIndex = 2 THEN AD_Code
		WHEN CDOIndex = 1 THEN AD_Code
		WHEN CDOIndex = 0 THEN AD_Code
		--ELSE ''
	END AS L5
	,CASE
		WHEN CDOIndex = 5 THEN L4F
		WHEN CDOIndex = 4 THEN L3F
		WHEN CDOIndex = 3 THEN L2F
		WHEN CDOIndex = 2 THEN L1F
		WHEN CDOIndex = 1 THEN AD_Code
		--WHEN CDOIndex = 0 THEN ''
		--ELSE ''
	END AS L1NP
	,CASE
		WHEN CDOIndex = 5 THEN L3F
		WHEN CDOIndex = 4 THEN L2F
		WHEN CDOIndex = 3 THEN L1F
		WHEN CDOIndex = 2 THEN AD_Code
		--WHEN CDOIndex = 1 THEN AD_Code
		--WHEN CDOIndex = 0 THEN ''
		--ELSE ''
	END AS L2NP
	,CASE
		WHEN CDOIndex = 5 THEN L2F
		WHEN CDOIndex = 4 THEN L1F
		WHEN CDOIndex = 3 THEN AD_Code
		--WHEN CDOIndex = 2 THEN AD_Code
		--WHEN CDOIndex = 1 THEN AD_Code
		--WHEN CDOIndex = 0 THEN ''
		--ELSE ''
	END AS L3NP
	,CASE
		WHEN CDOIndex = 5 THEN L1F
		WHEN CDOIndex = 4 THEN AD_Code
		--WHEN CDOIndex = 3 THEN AD_Code
		--WHEN CDOIndex = 2 THEN AD_Code
		--WHEN CDOIndex = 1 THEN AD_Code
		--WHEN CDOIndex = 0 THEN ''
		--ELSE ''
	END AS L4NP
	,CASE
		WHEN CDOIndex = 5 THEN AD_Code
		--WHEN CDOIndex = 4 THEN AD_Code
		--WHEN CDOIndex = 3 THEN AD_Code
		--WHEN CDOIndex = 2 THEN AD_Code
		--WHEN CDOIndex = 1 THEN AD_Code
		--WHEN CDOIndex = 0 THEN AD_Code
		--ELSE ''
	END AS L5NP
		,CASE
		WHEN CDOIndex = 5 THEN L4FG
		WHEN CDOIndex = 4 THEN L3FG
		WHEN CDOIndex = 3 THEN L2FG
		WHEN CDOIndex = 2 THEN L1FG
		WHEN CDOIndex = 1 THEN AD_Grade
		--WHEN CDOIndex = 0 THEN ''
		--ELSE ''
	END AS L1NPG
	,CASE
		WHEN CDOIndex = 5 THEN L3FG
		WHEN CDOIndex = 4 THEN L2FG
		WHEN CDOIndex = 3 THEN L1FG
		WHEN CDOIndex = 2 THEN AD_Grade
		--WHEN CDOIndex = 1 THEN AD_Code
		--WHEN CDOIndex = 0 THEN ''
		--ELSE ''
	END AS L2NPG
	,CASE
		WHEN CDOIndex = 5 THEN L2FG
		WHEN CDOIndex = 4 THEN L1FG
		WHEN CDOIndex = 3 THEN AD_Grade
		--WHEN CDOIndex = 2 THEN AD_Code
		--WHEN CDOIndex = 1 THEN AD_Code
		--WHEN CDOIndex = 0 THEN ''
		--ELSE ''
	END AS L3NPG
	,CASE
		WHEN CDOIndex = 5 THEN L1FG
		WHEN CDOIndex = 4 THEN AD_Grade
		--WHEN CDOIndex = 3 THEN AD_Code
		--WHEN CDOIndex = 2 THEN AD_Code
		--WHEN CDOIndex = 1 THEN AD_Code
		--WHEN CDOIndex = 0 THEN ''
		--ELSE ''
	END AS L4NPG
	,CASE
		WHEN CDOIndex = 5 THEN AD_Grade
		--WHEN CDOIndex = 4 THEN AD_Code
		--WHEN CDOIndex = 3 THEN AD_Code
		--WHEN CDOIndex = 2 THEN AD_Code
		--WHEN CDOIndex = 1 THEN AD_Code
		--WHEN CDOIndex = 0 THEN AD_Code
		--ELSE ''
	END AS L5NPG
FROM Temp1
WHERE Temp1.ExplodedDate IS NOT NULL
)
SELECT --Temp2.ID
	CONCAT(Temp2.AD_Code,CONVERT(CHAR(6), Temp2.ExplodedDate, 112)) AS ID
	,Temp2.ExplodedDate
	,Temp2.CDOIndex
	,Temp2.L1new
	,Temp2.L2new
	,Temp2.L3new
	,Temp2.L4new
	,Temp2.L5new
	,Temp2.L1
	,Temp2.L2
	,Temp2.L3
	,Temp2.L4
	,Temp2.L5
	,IIF(RIGHT(Temp2.L1new,1) = 'P', N1.AD_Name + '-P',N1.AD_Name) AS L1Name
	,IIF(RIGHT(Temp2.L2new,1) = 'P', N2.AD_Name + '-P',N2.AD_Name) AS L2Name
	,IIF(RIGHT(Temp2.L3new,1) = 'P', N3.AD_Name + '-P',N3.AD_Name) AS L3Name
	,IIF(RIGHT(Temp2.L4new,1) = 'P', N4.AD_Name + '-P',N4.AD_Name) AS L4Name
	,IIF(RIGHT(Temp2.L5new,1) = 'P', N5.AD_Name + '-P',N5.AD_Name) AS L5Name
	,CONCAT( Temp2.L1 + '|', Temp2.L2 +'|', Temp2.L3 + '|', Temp2.L4 + '|', Temp2.L5) AS Structure
	,Temp2.L1NP
	,Temp2.L2NP
	,Temp2.L3NP
	,Temp2.L4NP
	,Temp2.L5NP
	,Temp2.L1NPG
	,Temp2.L2NPG
	,Temp2.L3NPG
	,Temp2.L4NPG
	,Temp2.L5NPG
	,Temp2.Territory_Code
	,CASE 
		WHEN Temp2.L1NPG LIKE '%TD' THEN Temp2.L1NP
		WHEN Temp2.L2NPG LIKE '%TD' THEN Temp2.L2NP
		WHEN Temp2.L3NPG LIKE '%TD' THEN Temp2.L3NP
		WHEN Temp2.L4NPG LIKE '%TD' THEN Temp2.L4NP
		WHEN Temp2.L5NPG LIKE '%TD' THEN Temp2.L5NP
	END AS TD
	,CASE 
		WHEN Temp2.L1NPG LIKE '%TD' THEN N1.AD_Name
		WHEN Temp2.L2NPG LIKE '%TD' THEN N2.AD_Name
		WHEN Temp2.L3NPG LIKE '%TD' THEN N3.AD_Name
		WHEN Temp2.L4NPG LIKE '%TD' THEN N4.AD_Name
		WHEN Temp2.L5NPG LIKE '%TD' THEN N5.AD_Name
	END AS TDName
	,CASE 
		WHEN Temp2.L1NPG LIKE '%SRD' THEN Temp2.L1NP
		WHEN Temp2.L2NPG LIKE '%SRD' THEN Temp2.L2NP
		WHEN Temp2.L3NPG LIKE '%SRD' THEN Temp2.L3NP
		WHEN Temp2.L4NPG LIKE '%SRD' THEN Temp2.L4NP
		WHEN Temp2.L5NPG LIKE '%SRD' THEN Temp2.L5NP
	END AS SRD
	,CASE 
		WHEN Temp2.L1NPG LIKE '%SRD' THEN N1.AD_Name
		WHEN Temp2.L2NPG LIKE '%SRD' THEN N2.AD_Name
		WHEN Temp2.L3NPG LIKE '%SRD' THEN N3.AD_Name
		WHEN Temp2.L4NPG LIKE '%SRD' THEN N4.AD_Name
		WHEN Temp2.L5NPG LIKE '%SRD' THEN N5.AD_Name
	END AS SRDName
	,CASE 
		WHEN Temp2.L1NPG IN ('RD', 'ARD', 'RAD') THEN Temp2.L1NP
		WHEN Temp2.L2NPG IN ('RD', 'ARD', 'RAD') THEN Temp2.L2NP
		WHEN Temp2.L3NPG IN ('RD', 'ARD', 'RAD') THEN Temp2.L3NP
		WHEN Temp2.L4NPG IN ('RD', 'ARD', 'RAD') THEN Temp2.L4NP
		WHEN Temp2.L5NPG IN ('RD', 'ARD', 'RAD') THEN Temp2.L5NP
	END AS RD
	,CASE 
		WHEN Temp2.L1NPG IN ('RD', 'ARD', 'RAD') THEN N1.AD_Name
		WHEN Temp2.L2NPG IN ('RD', 'ARD', 'RAD') THEN N2.AD_Name
		WHEN Temp2.L3NPG IN ('RD', 'ARD', 'RAD') THEN N3.AD_Name
		WHEN Temp2.L4NPG IN ('RD', 'ARD', 'RAD') THEN N4.AD_Name
		WHEN Temp2.L5NPG IN ('RD', 'ARD', 'RAD') THEN N5.AD_Name
	END AS RDName
	,CASE 
		WHEN Temp2.L1NPG LIKE '%SZD' THEN Temp2.L1NP
		WHEN Temp2.L2NPG LIKE '%SZD' THEN Temp2.L2NP
		WHEN Temp2.L3NPG LIKE '%SZD' THEN Temp2.L3NP
		WHEN Temp2.L4NPG LIKE '%SZD' THEN Temp2.L4NP
		WHEN Temp2.L5NPG LIKE '%SZD' THEN Temp2.L5NP
	END AS SZD
	,CASE 
		WHEN Temp2.L1NPG LIKE '%SZD' THEN N1.AD_Name
		WHEN Temp2.L2NPG LIKE '%SZD' THEN N2.AD_Name
		WHEN Temp2.L3NPG LIKE '%SZD' THEN N3.AD_Name
		WHEN Temp2.L4NPG LIKE '%SZD' THEN N4.AD_Name
		WHEN Temp2.L5NPG LIKE '%SZD' THEN N5.AD_Name
	END AS SZDName
	,CASE 
		WHEN Temp2.L1NPG IN ('ZD','SZD', 'AZD') THEN Temp2.L1NP
		WHEN Temp2.L2NPG IN ('ZD','SZD', 'AZD') THEN Temp2.L2NP
		WHEN Temp2.L3NPG IN ('ZD','SZD', 'AZD') THEN Temp2.L3NP
		WHEN Temp2.L4NPG IN ('ZD','SZD', 'AZD') THEN Temp2.L4NP
		WHEN Temp2.L5NPG IN ('ZD','SZD', 'AZD') THEN Temp2.L5NP
	END AS ZDSZD
	,CASE 
		WHEN Temp2.L1NPG IN ('ZD','SZD', 'AZD') THEN N1.AD_Name
		WHEN Temp2.L2NPG IN ('ZD','SZD', 'AZD') THEN N2.AD_Name
		WHEN Temp2.L3NPG IN ('ZD','SZD', 'AZD') THEN N3.AD_Name
		WHEN Temp2.L4NPG IN ('ZD','SZD', 'AZD') THEN N4.AD_Name
		WHEN Temp2.L5NPG IN ('ZD','SZD', 'AZD') THEN N5.AD_Name
	END AS ZDSZDName
	,Temp2.AD_Code
	,N0.AD_Name AS ADName
	,Temp2.AD_Grade
	,LS.Appointed_Date
	,LS.Terminated_Date
	,LS.[Last_Status]
	,LS.[Last_Status_Date]
	,LS.DemotePromote_Date

FROM Temp2

LEFT JOIN [DPO].[DW_AD] AS N0
ON N0.AD_Code = Temp2.AD_Code

LEFT JOIN [DPO].[DW_AD] AS N1
ON N1.AD_Code = Temp2.L1

LEFT JOIN [DPO].[DW_AD] AS N2
ON N2.AD_Code = Temp2.L2

LEFT JOIN [DPO].[DW_AD] AS N3
ON N3.AD_Code = Temp2.L3

LEFT JOIN [DPO].[DW_AD] AS N4
ON N4.AD_Code = Temp2.L4

LEFT JOIN [DPO].[DW_AD] AS N5
ON N5.AD_Code = Temp2.L5

LEFT JOIN [PowerBI].[DPO].[DW_AD] AS LS
ON Temp2.AD_Code = LS.[AD_Code]

--WHERE Temp1.AD_Code = 'AD138'
--ORDER BY Temp2.[ExplodedDate]
GO


