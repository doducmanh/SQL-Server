USE [PowerBI]
GO

/****** Object:  View [DPO].[AD_STRUCTURE]    Script Date: 30/09/2022 16:22:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER VIEW [DPO].[AD_STRUCTURE] AS

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
	, G6.AD_Code AS L6F
	, G6.Grade AS L6FG
	, G7.AD_Code AS L7F
	, G7.Grade AS L7FG
	, G8.AD_Code AS L8F
	, G8.Grade AS L8FG
	, CASE
		WHEN G1.Grade = 'CDO' THEN 1
		WHEN G2.Grade = 'CDO' THEN 2
		WHEN G3.Grade = 'CDO' THEN 3
		WHEN G4.Grade = 'CDO' THEN 4
		WHEN G5.Grade = 'CDO' THEN 5
		WHEN G6.Grade = 'CDO' THEN 6
		WHEN G7.Grade = 'CDO' THEN 7
		WHEN G8.Grade = 'CDO' THEN 8
		ELSE 0
	END AS CDOIndex

FROM G AS A

LEFT JOIN G AS G1 ON A.IDSup IS NOT NULL AND A.IDSup = G1.ID 
LEFT JOIN G AS G2 ON G1.IDSup IS NOT NULL AND G1.IDSup = G2.ID 
LEFT JOIN G AS G3 ON G2.IDSup IS NOT NULL AND G2.IDSup = G3.ID 
LEFT JOIN G AS G4 ON G3.IDSup IS NOT NULL AND G3.IDSup = G4.ID 
LEFT JOIN G AS G5 ON G4.IDSup IS NOT NULL AND G4.IDSup = G5.ID 
LEFT JOIN G AS G6 ON G5.IDSup IS NOT NULL AND G5.IDSup = G6.ID 
LEFT JOIN G AS G7 ON G6.IDSup IS NOT NULL AND G6.IDSup = G7.ID 
LEFT JOIN G AS G8 ON G7.IDSup IS NOT NULL AND G7.IDSup = G8.ID 
)
,Temp2 AS (
SELECT Temp1.*
	,CASE
		WHEN CDOIndex = 8 THEN L7F
		WHEN CDOIndex = 7 THEN L6F
		WHEN CDOIndex = 6 THEN L5F
		WHEN CDOIndex = 5 THEN L4F
		WHEN CDOIndex = 4 THEN L3F
		WHEN CDOIndex = 3 THEN L2F
		WHEN CDOIndex = 2 THEN L1F
		WHEN CDOIndex = 1 THEN AD_Code
	END AS L1new
	,CASE
		WHEN CDOIndex = 8 THEN L6F
		WHEN CDOIndex = 7 THEN L5F
		WHEN CDOIndex = 6 THEN L4F
		WHEN CDOIndex = 5 THEN L3F
		WHEN CDOIndex = 4 THEN L2F
		WHEN CDOIndex = 3 THEN L1F
		WHEN CDOIndex = 2 THEN AD_Code
		WHEN CDOIndex = 1 THEN AD_Code + 'P'
	END AS L2new
	,CASE
		WHEN CDOIndex = 8 THEN L5F
		WHEN CDOIndex = 7 THEN L4F
		WHEN CDOIndex = 6 THEN L3F
		WHEN CDOIndex = 5 THEN L2F
		WHEN CDOIndex = 4 THEN L1F
		WHEN CDOIndex = 3 THEN AD_Code
		WHEN CDOIndex = 2 THEN AD_Code + 'P'
		WHEN CDOIndex = 1 THEN AD_Code + 'P'
	END AS L3new
	,CASE
		WHEN CDOIndex = 8 THEN L4F
		WHEN CDOIndex = 7 THEN L3F
		WHEN CDOIndex = 6 THEN L2F
		WHEN CDOIndex = 5 THEN L1F
		WHEN CDOIndex = 4 THEN AD_Code
		WHEN CDOIndex = 3 THEN AD_Code + 'P'
		WHEN CDOIndex = 2 THEN AD_Code + 'P'
		WHEN CDOIndex = 1 THEN AD_Code + 'P'
	END AS L4new
	,CASE
		WHEN CDOIndex = 8 THEN L3F
		WHEN CDOIndex = 7 THEN L2F
		WHEN CDOIndex = 6 THEN L1F
		WHEN CDOIndex = 5 THEN AD_Code
		WHEN CDOIndex = 4 THEN AD_Code + 'P'
		WHEN CDOIndex = 3 THEN AD_Code + 'P'
		WHEN CDOIndex = 2 THEN AD_Code + 'P'
		WHEN CDOIndex = 1 THEN AD_Code + 'P'
		--WHEN CDOIndex = 0 THEN AD_Code
	END AS L5new
	,CASE
		WHEN CDOIndex = 8 THEN L2F
		WHEN CDOIndex = 7 THEN L1F
		WHEN CDOIndex = 6 THEN AD_Code
		WHEN CDOIndex = 5 THEN AD_Code + 'P'
		WHEN CDOIndex = 4 THEN AD_Code + 'P'
		WHEN CDOIndex = 3 THEN AD_Code + 'P'
		WHEN CDOIndex = 2 THEN AD_Code + 'P'
		WHEN CDOIndex = 1 THEN AD_Code + 'P'
	END AS L6new
	,CASE
		WHEN CDOIndex = 8 THEN L1F
		WHEN CDOIndex = 7 THEN AD_Code
		WHEN CDOIndex = 6 THEN AD_Code + 'P'
		WHEN CDOIndex = 5 THEN AD_Code + 'P'
		WHEN CDOIndex = 4 THEN AD_Code + 'P'
		WHEN CDOIndex = 3 THEN AD_Code + 'P'
		WHEN CDOIndex = 2 THEN AD_Code + 'P'
		WHEN CDOIndex = 1 THEN AD_Code + 'P'
	END AS L7new
	,CASE
		WHEN CDOIndex = 8 THEN AD_Code
		WHEN CDOIndex = 7 THEN AD_Code + 'P'
		WHEN CDOIndex = 6 THEN AD_Code + 'P'
		WHEN CDOIndex = 5 THEN AD_Code + 'P'
		WHEN CDOIndex = 4 THEN AD_Code + 'P'
		WHEN CDOIndex = 3 THEN AD_Code + 'P'
		WHEN CDOIndex = 2 THEN AD_Code + 'P'
		WHEN CDOIndex = 1 THEN AD_Code + 'P'
		WHEN CDOIndex = 0 THEN AD_Code
	END AS L8new

		,CASE
		WHEN CDOIndex = 8 THEN L7F
		WHEN CDOIndex = 7 THEN L6F
		WHEN CDOIndex = 6 THEN L5F
		WHEN CDOIndex = 5 THEN L4F
		WHEN CDOIndex = 4 THEN L3F
		WHEN CDOIndex = 3 THEN L2F
		WHEN CDOIndex = 2 THEN L1F
		WHEN CDOIndex = 1 THEN AD_Code
	END AS L1
	,CASE
		WHEN CDOIndex = 8 THEN L6F
		WHEN CDOIndex = 7 THEN L5F
		WHEN CDOIndex = 6 THEN L4F
		WHEN CDOIndex = 5 THEN L3F
		WHEN CDOIndex = 4 THEN L2F
		WHEN CDOIndex = 3 THEN L1F
		WHEN CDOIndex = 2 THEN AD_Code
		WHEN CDOIndex = 1 THEN AD_Code
	END AS L2
	,CASE
		WHEN CDOIndex = 8 THEN L5F
		WHEN CDOIndex = 7 THEN L4F
		WHEN CDOIndex = 6 THEN L3F
		WHEN CDOIndex = 5 THEN L2F
		WHEN CDOIndex = 4 THEN L1F
		WHEN CDOIndex = 3 THEN AD_Code
		WHEN CDOIndex = 2 THEN AD_Code
		WHEN CDOIndex = 1 THEN AD_Code
	END AS L3
	,CASE
		WHEN CDOIndex = 8 THEN L4F
		WHEN CDOIndex = 7 THEN L3F
		WHEN CDOIndex = 6 THEN L2F
		WHEN CDOIndex = 5 THEN L1F
		WHEN CDOIndex = 4 THEN AD_Code
		WHEN CDOIndex = 3 THEN AD_Code
		WHEN CDOIndex = 2 THEN AD_Code
		WHEN CDOIndex = 1 THEN AD_Code
	END AS L4
	,CASE
		WHEN CDOIndex = 8 THEN L3F
		WHEN CDOIndex = 7 THEN L2F
		WHEN CDOIndex = 6 THEN L1F
		WHEN CDOIndex = 5 THEN AD_Code
		WHEN CDOIndex = 4 THEN AD_Code
		WHEN CDOIndex = 3 THEN AD_Code
		WHEN CDOIndex = 2 THEN AD_Code
		WHEN CDOIndex = 1 THEN AD_Code
		--WHEN CDOIndex = 0 THEN AD_Code
	END AS L5
	,CASE
		WHEN CDOIndex = 8 THEN L2F
		WHEN CDOIndex = 7 THEN L1F
		WHEN CDOIndex = 6 THEN AD_Code
		WHEN CDOIndex = 5 THEN AD_Code
		WHEN CDOIndex = 4 THEN AD_Code
		WHEN CDOIndex = 3 THEN AD_Code
		WHEN CDOIndex = 2 THEN AD_Code
		WHEN CDOIndex = 1 THEN AD_Code
	END AS L6
	,CASE
		WHEN CDOIndex = 8 THEN L1F
		WHEN CDOIndex = 7 THEN AD_Code
		WHEN CDOIndex = 6 THEN AD_Code
		WHEN CDOIndex = 5 THEN AD_Code
		WHEN CDOIndex = 4 THEN AD_Code
		WHEN CDOIndex = 3 THEN AD_Code
		WHEN CDOIndex = 2 THEN AD_Code
		WHEN CDOIndex = 1 THEN AD_Code
	END AS L7
	,CASE
		WHEN CDOIndex = 8 THEN AD_Code
		WHEN CDOIndex = 7 THEN AD_Code
		WHEN CDOIndex = 6 THEN AD_Code
		WHEN CDOIndex = 5 THEN AD_Code
		WHEN CDOIndex = 4 THEN AD_Code
		WHEN CDOIndex = 3 THEN AD_Code
		WHEN CDOIndex = 2 THEN AD_Code
		WHEN CDOIndex = 1 THEN AD_Code
		WHEN CDOIndex = 0 THEN AD_Code
	END AS L8

	,CASE
		WHEN CDOIndex = 8 THEN L7F
		WHEN CDOIndex = 7 THEN L6F
		WHEN CDOIndex = 6 THEN L5F
		WHEN CDOIndex = 5 THEN L4F
		WHEN CDOIndex = 4 THEN L3F
		WHEN CDOIndex = 3 THEN L2F
		WHEN CDOIndex = 2 THEN L1F
		WHEN CDOIndex = 1 THEN AD_Code
	END AS L1NP
	,CASE
		WHEN CDOIndex = 8 THEN L6F
		WHEN CDOIndex = 7 THEN L5F
		WHEN CDOIndex = 6 THEN L4F
		WHEN CDOIndex = 5 THEN L3F
		WHEN CDOIndex = 4 THEN L2F
		WHEN CDOIndex = 3 THEN L1F
		WHEN CDOIndex = 2 THEN AD_Code
	END AS L2NP
	,CASE
		WHEN CDOIndex = 8 THEN L5F
		WHEN CDOIndex = 7 THEN L4F
		WHEN CDOIndex = 6 THEN L3F
		WHEN CDOIndex = 5 THEN L2F
		WHEN CDOIndex = 4 THEN L1F
		WHEN CDOIndex = 3 THEN AD_Code
	END AS L3NP
	,CASE
		WHEN CDOIndex = 8 THEN L4F
		WHEN CDOIndex = 7 THEN L3F
		WHEN CDOIndex = 6 THEN L2F
		WHEN CDOIndex = 5 THEN L1F
		WHEN CDOIndex = 4 THEN AD_Code
	END AS L4NP
	,CASE
		WHEN CDOIndex = 8 THEN L3F
		WHEN CDOIndex = 7 THEN L2F
		WHEN CDOIndex = 6 THEN L1F
		WHEN CDOIndex = 5 THEN AD_Code
	END AS L5NP
	,CASE
		WHEN CDOIndex = 8 THEN L2F
		WHEN CDOIndex = 7 THEN L1F
		WHEN CDOIndex = 6 THEN AD_Code
	END AS L6NP
	,CASE
		WHEN CDOIndex = 8 THEN L1F
		WHEN CDOIndex = 7 THEN AD_Code
	END AS L7NP
	,CASE
		WHEN CDOIndex = 8 THEN AD_Code
	END AS L8NP
---------------------------------------------------------------------------
		,CASE
		WHEN CDOIndex = 8 THEN L7FG
		WHEN CDOIndex = 7 THEN L6FG
		WHEN CDOIndex = 6 THEN L5FG
		WHEN CDOIndex = 5 THEN L4FG
		WHEN CDOIndex = 4 THEN L3FG
		WHEN CDOIndex = 3 THEN L2FG
		WHEN CDOIndex = 2 THEN L1FG
		WHEN CDOIndex = 1 THEN AD_Grade
	END AS L1NPG
	,CASE
		WHEN CDOIndex = 8 THEN L6FG
		WHEN CDOIndex = 7 THEN L5FG
		WHEN CDOIndex = 6 THEN L4FG
		WHEN CDOIndex = 5 THEN L3FG
		WHEN CDOIndex = 4 THEN L2FG
		WHEN CDOIndex = 3 THEN L1FG
		WHEN CDOIndex = 2 THEN AD_Grade
	END AS L2NPG
	,CASE
		WHEN CDOIndex = 8 THEN L5FG
		WHEN CDOIndex = 7 THEN L4FG
		WHEN CDOIndex = 6 THEN L3FG
		WHEN CDOIndex = 5 THEN L2FG
		WHEN CDOIndex = 4 THEN L1FG
		WHEN CDOIndex = 3 THEN AD_Grade
	END AS L3NPG
	,CASE
		WHEN CDOIndex = 8 THEN L4FG
		WHEN CDOIndex = 7 THEN L3FG
		WHEN CDOIndex = 6 THEN L2FG
		WHEN CDOIndex = 5 THEN L1FG
		WHEN CDOIndex = 4 THEN AD_Grade
	END AS L4NPG
	,CASE
		WHEN CDOIndex = 8 THEN L3FG
		WHEN CDOIndex = 7 THEN L2FG
		WHEN CDOIndex = 6 THEN L1FG
		WHEN CDOIndex = 5 THEN AD_Grade
	END AS L5NPG
	,CASE
		WHEN CDOIndex = 8 THEN L2FG
		WHEN CDOIndex = 7 THEN L1FG
		WHEN CDOIndex = 6 THEN AD_Grade
	END AS L6NPG
	,CASE
		WHEN CDOIndex = 8 THEN L1FG
		WHEN CDOIndex = 7 THEN AD_Grade
	END AS L7NPG
	,CASE
		WHEN CDOIndex = 8 THEN AD_Grade
	END AS L8NPG

FROM Temp1
WHERE Temp1.ExplodedDate IS NOT NULL
)
----------------------FINAL-------------------------------
SELECT 
	CONCAT(Temp2.AD_Code,CONVERT(CHAR(6), Temp2.ExplodedDate, 112)) AS ID
	,Temp2.ExplodedDate
	,Temp2.CDOIndex
	,Temp2.L1new
	,Temp2.L2new
	,Temp2.L3new
	,Temp2.L4new
	,Temp2.L5new
	,Temp2.L6new
	,Temp2.L7new
	,Temp2.L8new

	,Temp2.L1
	,Temp2.L2
	,Temp2.L3
	,Temp2.L4
	,Temp2.L5
	,Temp2.L6
	,Temp2.L7
	,Temp2.L8

	,IIF(RIGHT(Temp2.L1new,1) = 'P', N1.AD_Name + '-P',N1.AD_Name) AS L1Name
	,IIF(RIGHT(Temp2.L2new,1) = 'P', N2.AD_Name + '-P',N2.AD_Name) AS L2Name
	,IIF(RIGHT(Temp2.L3new,1) = 'P', N3.AD_Name + '-P',N3.AD_Name) AS L3Name
	,IIF(RIGHT(Temp2.L4new,1) = 'P', N4.AD_Name + '-P',N4.AD_Name) AS L4Name
	,IIF(RIGHT(Temp2.L5new,1) = 'P', N5.AD_Name + '-P',N5.AD_Name) AS L5Name
	,IIF(RIGHT(Temp2.L6new,1) = 'P', N6.AD_Name + '-P',N6.AD_Name) AS L6Name
	,IIF(RIGHT(Temp2.L7new,1) = 'P', N7.AD_Name + '-P',N7.AD_Name) AS L7Name
	,IIF(RIGHT(Temp2.L8new,1) = 'P', N8.AD_Name + '-P',N8.AD_Name) AS L8Name

	,CONCAT( Temp2.L1 + '|', Temp2.L2 +'|', Temp2.L3 + '|', Temp2.L4 + '|', Temp2.L5 + '|', Temp2.L6 + '|', Temp2.L7 + '|', Temp2.L8) AS Structure


	,Temp2.L1NP
	,Temp2.L2NP
	,Temp2.L3NP
	,Temp2.L4NP
	,Temp2.L5NP
	,Temp2.L6NP
	,Temp2.L7NP
	,Temp2.L8NP

	,Temp2.L1NPG
	,Temp2.L2NPG
	,Temp2.L3NPG
	,Temp2.L4NPG
	,Temp2.L5NPG
	,Temp2.L6NPG
	,Temp2.L7NPG
	,Temp2.L8NPG

	,Temp2.Territory_Code
	,CASE
		WHEN Temp2.L1NPG IN ('STD', 'ASTD', '%STD') THEN Temp2.L1NP
		WHEN Temp2.L2NPG IN ('STD', 'ASTD', '%STD') THEN Temp2.L2NP
		WHEN Temp2.L3NPG IN ('STD', 'ASTD', '%STD') THEN Temp2.L3NP
		WHEN Temp2.L4NPG IN ('STD', 'ASTD', '%STD') THEN Temp2.L4NP
		WHEN Temp2.L5NPG IN ('STD', 'ASTD', '%STD') THEN Temp2.L5NP
		WHEN Temp2.L6NPG IN ('STD', 'ASTD', '%STD') THEN Temp2.L6NP
		WHEN Temp2.L7NPG IN ('STD', 'ASTD', '%STD') THEN Temp2.L7NP
		WHEN Temp2.L8NPG IN ('STD', 'ASTD', '%STD') THEN Temp2.L8NP
	END AS STD
	,CASE 
		WHEN Temp2.L1NPG IN ('STD', 'ASTD', '%STD') THEN N1.AD_Name
		WHEN Temp2.L2NPG IN ('STD', 'ASTD', '%STD') THEN N2.AD_Name
		WHEN Temp2.L3NPG IN ('STD', 'ASTD', '%STD') THEN N3.AD_Name
		WHEN Temp2.L4NPG IN ('STD', 'ASTD', '%STD') THEN N4.AD_Name
		WHEN Temp2.L5NPG IN ('STD', 'ASTD', '%STD') THEN N5.AD_Name
		WHEN Temp2.L6NPG IN ('STD', 'ASTD', '%STD') THEN N6.AD_Name
		WHEN Temp2.L7NPG IN ('STD', 'ASTD', '%STD') THEN N7.AD_Name
		WHEN Temp2.L8NPG IN ('STD', 'ASTD', '%STD') THEN N8.AD_Name
	END AS STDName

	,CASE
		WHEN Temp2.L1NPG IN ('TD', 'ATD', 'SETD') THEN Temp2.L1NP
		WHEN Temp2.L2NPG IN ('TD', 'ATD', 'SETD') THEN Temp2.L2NP
		WHEN Temp2.L3NPG IN ('TD', 'ATD', 'SETD') THEN Temp2.L3NP
		WHEN Temp2.L4NPG IN ('TD', 'ATD', 'SETD') THEN Temp2.L4NP
		WHEN Temp2.L5NPG IN ('TD', 'ATD', 'SETD') THEN Temp2.L5NP
		WHEN Temp2.L6NPG IN ('TD', 'ATD', 'SETD') THEN Temp2.L6NP
		WHEN Temp2.L7NPG IN ('TD', 'ATD', 'SETD') THEN Temp2.L7NP
		WHEN Temp2.L8NPG IN ('TD', 'ATD', 'SETD') THEN Temp2.L8NP
	END AS TD
	,CASE 
		WHEN Temp2.L1NPG IN ('TD', 'ATD', 'SETD') THEN N1.AD_Name
		WHEN Temp2.L2NPG IN ('TD', 'ATD', 'SETD') THEN N2.AD_Name
		WHEN Temp2.L3NPG IN ('TD', 'ATD', 'SETD') THEN N3.AD_Name
		WHEN Temp2.L4NPG IN ('TD', 'ATD', 'SETD') THEN N4.AD_Name
		WHEN Temp2.L5NPG IN ('TD', 'ATD', 'SETD') THEN N5.AD_Name
		WHEN Temp2.L6NPG IN ('TD', 'ATD', 'SETD') THEN N6.AD_Name
		WHEN Temp2.L7NPG IN ('TD', 'ATD', 'SETD') THEN N7.AD_Name
		WHEN Temp2.L8NPG IN ('TD', 'ATD', 'SETD') THEN N8.AD_Name
	END AS TDName

	,CASE
		WHEN Temp2.L1NPG IN ('TAD', 'ATAD') THEN Temp2.L1NP
		WHEN Temp2.L2NPG IN ('TAD', 'ATAD') THEN Temp2.L2NP
		WHEN Temp2.L3NPG IN ('TAD', 'ATAD') THEN Temp2.L3NP
		WHEN Temp2.L4NPG IN ('TAD', 'ATAD') THEN Temp2.L4NP
		WHEN Temp2.L5NPG IN ('TAD', 'ATAD') THEN Temp2.L5NP
		WHEN Temp2.L6NPG IN ('TAD', 'ATAD') THEN Temp2.L6NP
		WHEN Temp2.L7NPG IN ('TAD', 'ATAD') THEN Temp2.L7NP
		WHEN Temp2.L8NPG IN ('TAD', 'ATAD') THEN Temp2.L8NP
	END AS TAD
	,CASE 
		WHEN Temp2.L1NPG IN ('TAD', 'ATAD') THEN N1.AD_Name
		WHEN Temp2.L2NPG IN ('TAD', 'ATAD') THEN N2.AD_Name
		WHEN Temp2.L3NPG IN ('TAD', 'ATAD') THEN N3.AD_Name
		WHEN Temp2.L4NPG IN ('TAD', 'ATAD') THEN N4.AD_Name
		WHEN Temp2.L5NPG IN ('TAD', 'ATAD') THEN N5.AD_Name
		WHEN Temp2.L6NPG IN ('TAD', 'ATAD') THEN N6.AD_Name
		WHEN Temp2.L7NPG IN ('TAD', 'ATAD') THEN N7.AD_Name
		WHEN Temp2.L8NPG IN ('TAD', 'ATAD') THEN N8.AD_Name
	END AS TADName

	,CASE 
		WHEN Temp2.L1NPG LIKE '%SRD' THEN Temp2.L1NP
		WHEN Temp2.L2NPG LIKE '%SRD' THEN Temp2.L2NP
		WHEN Temp2.L3NPG LIKE '%SRD' THEN Temp2.L3NP
		WHEN Temp2.L4NPG LIKE '%SRD' THEN Temp2.L4NP
		WHEN Temp2.L5NPG LIKE '%SRD' THEN Temp2.L5NP
		WHEN Temp2.L6NPG LIKE '%SRD' THEN Temp2.L6NP
		WHEN Temp2.L7NPG LIKE '%SRD' THEN Temp2.L7NP
		WHEN Temp2.L8NPG LIKE '%SRD' THEN Temp2.L8NP
	END AS SRD
	,CASE 
		WHEN Temp2.L1NPG LIKE '%SRD' THEN N1.AD_Name
		WHEN Temp2.L2NPG LIKE '%SRD' THEN N2.AD_Name
		WHEN Temp2.L3NPG LIKE '%SRD' THEN N3.AD_Name
		WHEN Temp2.L4NPG LIKE '%SRD' THEN N4.AD_Name
		WHEN Temp2.L5NPG LIKE '%SRD' THEN N5.AD_Name
		WHEN Temp2.L6NPG LIKE '%SRD' THEN N6.AD_Name
		WHEN Temp2.L7NPG LIKE '%SRD' THEN N7.AD_Name
		WHEN Temp2.L8NPG LIKE '%SRD' THEN N8.AD_Name
	END AS SRDName

	,CASE 
		WHEN Temp2.L1NPG IN ('RD', 'ARD') THEN Temp2.L1NP
		WHEN Temp2.L2NPG IN ('RD', 'ARD') THEN Temp2.L2NP
		WHEN Temp2.L3NPG IN ('RD', 'ARD') THEN Temp2.L3NP
		WHEN Temp2.L4NPG IN ('RD', 'ARD') THEN Temp2.L4NP
		WHEN Temp2.L5NPG IN ('RD', 'ARD') THEN Temp2.L5NP
		WHEN Temp2.L6NPG IN ('RD', 'ARD') THEN Temp2.L6NP
		WHEN Temp2.L7NPG IN ('RD', 'ARD') THEN Temp2.L7NP
		WHEN Temp2.L8NPG IN ('RD', 'ARD') THEN Temp2.L8NP
	END AS RD
	,CASE 
		WHEN Temp2.L1NPG IN ('RD', 'ARD') THEN N1.AD_Name
		WHEN Temp2.L2NPG IN ('RD', 'ARD') THEN N2.AD_Name
		WHEN Temp2.L3NPG IN ('RD', 'ARD') THEN N3.AD_Name
		WHEN Temp2.L4NPG IN ('RD', 'ARD') THEN N4.AD_Name
		WHEN Temp2.L5NPG IN ('RD', 'ARD') THEN N5.AD_Name
		WHEN Temp2.L6NPG IN ('RD', 'ARD') THEN N6.AD_Name
		WHEN Temp2.L7NPG IN ('RD', 'ARD') THEN N7.AD_Name
		WHEN Temp2.L8NPG IN ('RD', 'ARD') THEN N8.AD_Name
	END AS RDName

	,CASE 
		WHEN Temp2.L1NPG IN ('RAD', 'ARAD') THEN Temp2.L1NP
		WHEN Temp2.L2NPG IN ('RAD', 'ARAD') THEN Temp2.L2NP
		WHEN Temp2.L3NPG IN ('RAD', 'ARAD') THEN Temp2.L3NP
		WHEN Temp2.L4NPG IN ('RAD', 'ARAD') THEN Temp2.L4NP
		WHEN Temp2.L5NPG IN ('RAD', 'ARAD') THEN Temp2.L5NP
		WHEN Temp2.L6NPG IN ('RAD', 'ARAD') THEN Temp2.L6NP
		WHEN Temp2.L7NPG IN ('RAD', 'ARAD') THEN Temp2.L7NP
		WHEN Temp2.L8NPG IN ('RAD', 'ARAD') THEN Temp2.L8NP
	END AS RAD
	,CASE 
		WHEN Temp2.L1NPG IN ('RAD', 'ARAD') THEN N1.AD_Name
		WHEN Temp2.L2NPG IN ('RAD', 'ARAD') THEN N2.AD_Name
		WHEN Temp2.L3NPG IN ('RAD', 'ARAD') THEN N3.AD_Name
		WHEN Temp2.L4NPG IN ('RAD', 'ARAD') THEN N4.AD_Name
		WHEN Temp2.L5NPG IN ('RAD', 'ARAD') THEN N5.AD_Name
		WHEN Temp2.L6NPG IN ('RAD', 'ARAD') THEN N6.AD_Name
		WHEN Temp2.L7NPG IN ('RAD', 'ARAD') THEN N7.AD_Name
		WHEN Temp2.L8NPG IN ('RAD', 'ARAD') THEN N8.AD_Name
	END AS RADName

	,CASE 
		WHEN Temp2.L1NPG LIKE '%SZD' THEN Temp2.L1NP
		WHEN Temp2.L2NPG LIKE '%SZD' THEN Temp2.L2NP
		WHEN Temp2.L3NPG LIKE '%SZD' THEN Temp2.L3NP
		WHEN Temp2.L4NPG LIKE '%SZD' THEN Temp2.L4NP
		WHEN Temp2.L5NPG LIKE '%SZD' THEN Temp2.L5NP
		WHEN Temp2.L6NPG LIKE '%SZD' THEN Temp2.L6NP
		WHEN Temp2.L7NPG LIKE '%SZD' THEN Temp2.L7NP
		WHEN Temp2.L8NPG LIKE '%SZD' THEN Temp2.L8NP
	END AS SZD
	,CASE 
		WHEN Temp2.L1NPG LIKE '%SZD' THEN N1.AD_Name
		WHEN Temp2.L2NPG LIKE '%SZD' THEN N2.AD_Name
		WHEN Temp2.L3NPG LIKE '%SZD' THEN N3.AD_Name
		WHEN Temp2.L4NPG LIKE '%SZD' THEN N4.AD_Name
		WHEN Temp2.L5NPG LIKE '%SZD' THEN N5.AD_Name
		WHEN Temp2.L6NPG LIKE '%SZD' THEN N6.AD_Name
		WHEN Temp2.L7NPG LIKE '%SZD' THEN N7.AD_Name
		WHEN Temp2.L8NPG LIKE '%SZD' THEN N8.AD_Name
	END AS SZDName
	,CASE 
		WHEN Temp2.L1NPG IN ('ZD', 'AZD') THEN Temp2.L1NP
		WHEN Temp2.L2NPG IN ('ZD', 'AZD') THEN Temp2.L2NP
		WHEN Temp2.L3NPG IN ('ZD', 'AZD') THEN Temp2.L3NP
		WHEN Temp2.L4NPG IN ('ZD', 'AZD') THEN Temp2.L4NP
		WHEN Temp2.L5NPG IN ('ZD', 'AZD') THEN Temp2.L5NP
		WHEN Temp2.L6NPG IN ('ZD', 'AZD') THEN Temp2.L6NP
		WHEN Temp2.L7NPG IN ('ZD', 'AZD') THEN Temp2.L7NP
		WHEN Temp2.L8NPG IN ('ZD', 'AZD') THEN Temp2.L8NP
	END AS ZD
	,CASE 
		WHEN Temp2.L1NPG IN ('ZD', 'AZD') THEN N1.AD_Name
		WHEN Temp2.L2NPG IN ('ZD', 'AZD') THEN N2.AD_Name
		WHEN Temp2.L3NPG IN ('ZD', 'AZD') THEN N3.AD_Name
		WHEN Temp2.L4NPG IN ('ZD', 'AZD') THEN N4.AD_Name
		WHEN Temp2.L5NPG IN ('ZD', 'AZD') THEN N5.AD_Name
		WHEN Temp2.L6NPG IN ('ZD', 'AZD') THEN N6.AD_Name
		WHEN Temp2.L7NPG IN ('ZD', 'AZD') THEN N7.AD_Name
		WHEN Temp2.L8NPG IN ('ZD', 'AZD') THEN N8.AD_Name
	END AS ZDName

	,CASE 
		WHEN Temp2.L1NPG IN ('ZD','SZD', 'AZD') THEN Temp2.L1NP
		WHEN Temp2.L2NPG IN ('ZD','SZD', 'AZD') THEN Temp2.L2NP
		WHEN Temp2.L3NPG IN ('ZD','SZD', 'AZD') THEN Temp2.L3NP
		WHEN Temp2.L4NPG IN ('ZD','SZD', 'AZD') THEN Temp2.L4NP
		WHEN Temp2.L5NPG IN ('ZD','SZD', 'AZD') THEN Temp2.L5NP
		WHEN Temp2.L6NPG IN ('ZD','SZD', 'AZD') THEN Temp2.L6NP
		WHEN Temp2.L7NPG IN ('ZD','SZD', 'AZD') THEN Temp2.L7NP
		WHEN Temp2.L8NPG IN ('ZD','SZD', 'AZD') THEN Temp2.L8NP
	END AS ZDSZD
	,CASE 
		WHEN Temp2.L1NPG IN ('ZD','SZD', 'AZD') THEN N1.AD_Name
		WHEN Temp2.L2NPG IN ('ZD','SZD', 'AZD') THEN N2.AD_Name
		WHEN Temp2.L3NPG IN ('ZD','SZD', 'AZD') THEN N3.AD_Name
		WHEN Temp2.L4NPG IN ('ZD','SZD', 'AZD') THEN N4.AD_Name
		WHEN Temp2.L5NPG IN ('ZD','SZD', 'AZD') THEN N5.AD_Name
		WHEN Temp2.L6NPG IN ('ZD','SZD', 'AZD') THEN N6.AD_Name
		WHEN Temp2.L7NPG IN ('ZD','SZD', 'AZD') THEN N7.AD_Name
		WHEN Temp2.L8NPG IN ('ZD','SZD', 'AZD') THEN N8.AD_Name
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

LEFT JOIN [DPO].[DW_AD] AS N6
ON N6.AD_Code = Temp2.L6

LEFT JOIN [DPO].[DW_AD] AS N7
ON N7.AD_Code = Temp2.L7

LEFT JOIN [DPO].[DW_AD] AS N8
ON N8.AD_Code = Temp2.L8

LEFT JOIN [PowerBI].[DPO].[DW_AD] AS LS
ON Temp2.AD_Code = LS.[AD_Code]

--WHERE Temp2.[ExplodedDate] = '2022-07-01'
GO


