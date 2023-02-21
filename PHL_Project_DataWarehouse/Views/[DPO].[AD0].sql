USE [PowerBI]
GO

/****** Object:  View [DPO].[AD0]    Script Date: 30/09/2022 16:26:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
CREATE   VIEW [DPO].[AD0] AS
WITH G AS (
SELECT [AD_Code]
      ,[Grade]
	  ,[AD_Parent_Code]
      ,[ExplodedDate]
  FROM [PowerBI].[DPO].[AD_STRUCTURE_Exploded]
  WHERE [AD_Code] IS NOT NULL
)
,Temp1 AS (
SELECT 
	A.AD_Code
	, A.Grade AS AD_Grade
	--IIF(A.[AD_Parent_Code] IS NULL,'', A.[AD_Parent_Code]) AS [AD_Parent_Code]
	 ,IIF(A.[Territory_Code] IS NULL, 'PHL', A.[Territory_Code]) AS [Territory_Code]
	--,IIF(A.[Office_Code] IS NULL, 'PHL', A.[Office_Code]) AS [Office_Code]
	,A.[ExplodedDate]
	,[Start_date]
    ,[End_Date]
    ,[Status]
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

FROM [PowerBI].[DPO].[AD_STRUCTURE_Exploded] AS A
LEFT JOIN G AS G1 ON A.[AD_Parent_Code] = G1.AD_Code AND A.ExplodedDate = G1.ExplodedDate
LEFT JOIN G AS G2 ON G1.AD_Parent_Code = G2.AD_Code AND A.ExplodedDate = G2.ExplodedDate
LEFT JOIN G AS G3 ON G2.AD_Parent_Code = G3.AD_Code AND A.ExplodedDate = G3.ExplodedDate
LEFT JOIN G AS G4 ON G3.AD_Parent_Code = G4.AD_Code AND A.ExplodedDate = G4.ExplodedDate
LEFT JOIN G AS G5 ON G4.AD_Parent_Code = G5.AD_Code AND A.ExplodedDate = G5.ExplodedDate
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
SELECT Temp2.AD_Code + REPLACE(CAST(Temp2.ExplodedDate AS date), '-', '') AS ID
	,Temp2.AD_Code
	,Temp2.AD_Grade
	,Temp2.Territory_Code
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
	,N0.AD_Name AS ADName
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

WHERE Temp2.AD_Code IS NOT NULL
--ORDER BY Temp2.[ExplodedDate]
GO


