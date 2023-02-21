USE [PowerBI]
GO

/****** Object:  View [DPO].[AD_STRUCTURE0]    Script Date: 30/09/2022 16:25:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   VIEW [DPO].[AD_STRUCTURE0] AS
WITH A AS (
SELECT DISTINCT 
      [ID]
	  ,[AD_Code]
      ,[Grade]
      ,[AD_Parent_Code]
      ,[Territory_Code]
      ,Status_date
	  --,FORMAT(Status_date, 'yyyyMM') AS Status_Month
	  ,Status_date AS Status_Month
      ,[Status]
FROM [PowerBI].[DPO].[Main_AD_STRUCTURE]
--ORDER BY AD_Code, Status_date
)
, B AS (
SELECT
	 MAX(A.ID) AS ID
	,A.AD_Code
	--,A.Status_Month
	--,MAX(A.Status_date) AS Status_date
	,A.Status_Month
--	,A.Status
FROM A
GROUP BY 	
	A.AD_Code
	,A.Status_Month

--ORDER BY A.AD_Code, A.Status_Month
)
, C AS (
SELECT A.AD_Code, A.Grade, A.AD_Parent_Code, A.Territory_Code, A.Status_date, A.Status_Month, A.Status
     , CONCAT(A.AD_Code, A.Status_Month) AS ID

FROM B LEFT JOIN A
ON B.AD_Code = A.AD_Code AND B.ID = A.ID
--ORDER BY A.AD_Code, A.Status_Month
)

--
--SPECIAL CASES FROM CS DATA FILL IN PSEUDO STRUCTURE
--

,Temp0 AS (
SELECT --DISTINCT 
	  [AD_CODE]
      --,[AD_NAME]
	  ,MIN([TRANS_DATE]) AS Start_Date1
	  ,MAX([TRANS_DATE]) AS End_Date1
FROM [PowerBI].[DPO].[CS_APPLICATION_PREMIUM]
GROUP BY [AD_CODE]
      --,[AD_NAME]
)
, Temp1 AS (
			SELECT --DISTINCT 
				Temp.[AD_Code]
			  --,Temp.[AD_Name]
			  ,MAX(Temp.[Status_date]) AS Last_Date
			FROM [PowerBI].[DPO].[Main_AD_STRUCTURE] AS Temp
			GROUP BY Temp.[AD_Code]
			  --,Temp.[AD_Name]
)
,Temp2 AS (
			SELECT DISTINCT Temp1.AD_Code
			--, Temp1.AD_Name
			, K.Status AS Last_Status
			FROM Temp1
			LEFT JOIN  [PowerBI].[DPO].[Main_AD_STRUCTURE] AS K
			ON Temp1.AD_Code = K.AD_Code
			AND Temp1.Last_Date = K.Status_date
),
Temp3 AS (
SELECT DISTINCT B0.[AD_Code]
      --, B0.[AD_Name]
	  , MIN(B0.[Status_date]) AS Start_Date2
	  , MAX(B0.[Status_date]) AS End_Date2
  FROM [PowerBI].[DPO].[Main_AD_STRUCTURE] AS B0
  GROUP BY [AD_CODE]
      --,[AD_NAME]
)
,Temp4 AS (
SELECT DISTINCT Temp3.[AD_Code]
      --, Temp3.[AD_Name]
	  , Temp3.Start_Date2
	  , B0.Grade
	  , B0.AD_Parent_Code AS AD_Parent_Code
	  , B0.Territory_Code AS Territory_Code
  FROM Temp3
  LEFT JOIN [PowerBI].[DPO].[Main_AD_STRUCTURE] AS B0
  ON Temp3.AD_Code = B0.AD_Code AND Temp3.Start_Date2 = B0.Status_date
)
,Temp5 AS (
  SELECT Temp3.AD_Code
  --, Temp3.AD_Name
  , Temp3.Start_Date2, Temp3.End_Date2, Temp2.Last_Status
  FROM Temp3
  RIGHT JOIN Temp2
  ON Temp2.[AD_Code] = Temp3.[AD_Code]

)
,Temp6 AS (
SELECT A.[AD_CODE]
		--, B.[Start_Date2]
		--, B.[End_Date2]
		--, B.Last_Status
		, CASE
			WHEN B.Last_Status IS NULL THEN A.Start_Date1
			--WHEN B.Last_Status = 'Terminated' AND A.End_Date1 > B.End_Date2 THEN A.End_Date1
			WHEN B.Last_Status <> 'Terminated' AND A.Start_Date1 < B.Start_Date2 THEN A.Start_Date1
		END AS Special_Adjustment
		, CASE
			WHEN B.Last_Status IS NULL THEN 'Sale'
			--WHEN B.Last_Status = 'Terminated' AND A.End_Date1 > B.End_Date2 THEN 'Sale after Ter'
			WHEN B.Last_Status <> 'Terminated' AND A.Start_Date1 < B.Start_Date2 
			--AND DateDiff(day, A.Start_Date1, B.Start_Date2) < = 30 
			THEN 'Sale before Appointed'
			--WHEN B.Last_Status <> 'Terminated' AND A.Start_Date1 < B.Start_Date2 AND DateDiff(day,A.Start_Date1, B.Start_Date2) > 30 THEN 'PHL'
		END AS Note

FROM Temp0 AS A LEFT JOIN Temp5 AS B
ON A.[AD_Code] = B.[AD_Code]
)
,Temp7 AS (
SELECT C.*
FROM Temp6 AS C
WHERE Special_Adjustment IS NOT NULL
)
, Temp8 AS (
SELECT distinct D.AD_CODE
		, IIF(Temp4.Grade IS NOT NULL, Temp4.Grade, 'ZD') AS Grade
		, IIF(Temp4.AD_Parent_Code IS NOT NULL AND D.Note <> 'PHL', Temp4.AD_Parent_Code, 'PHL') AS AD_Parent_Code
		, IIF(Temp4.Territory_Code IS NOT NULL, Temp4.Territory_Code, 'PHL') AS Territory_Code
		, D.Special_Adjustment AS [Status_date]
		, EOMONTH(D.Special_Adjustment) AS Status_Month
		--, FORMAT(D.Special_Adjustment, 'yyyyMM') AS Status_Month
		,'Special_Adjustment' AS Status

		--, D.Note
FROM Temp7 AS D
LEFT JOIN Temp4 ON D.AD_CODE = Temp4.AD_Code
)
, Special_Cases AS (
SELECT Temp8.AD_CODE
	, Temp8.Grade
	,Temp8.AD_Parent_Code
	,Temp8.Territory_Code
	,Temp8.Status_date
	,Temp8.Status_Month
	,Temp8.Status
	,CONCAT(Temp8.AD_CODE ,Temp8.Status_Month) AS ID
FROM Temp8
WHERE  CONCAT(Temp8.AD_CODE ,Temp8.Status_Month) NOT IN (SELECT C.ID FROM C)
)

--
--END / SPECIAL CASES FROM CS DATA FILL IN PSEUDO STRUCTURE
--


--, C AS (
SELECT C.AD_Code, C.Grade, C.AD_Parent_Code, C.Territory_Code, C.Status_date, C.Status_Month, C.Status
    -- , C.ID

FROM C


UNION

   SELECT distinct [Sales_Unit_Code]
   , 'ZD' AS Grade
   , 'PHL' AS AD_Parent_Code
   , 'PHL' AS Territory_Code
   , EOMONTH(DATEADD(month, -1, getdate())) AS [Status_date] 
   , EOMONTH(DATEADD(month, -1, getdate())) AS Status_Month
   --,FORMAT(DATEADD(month, -1, getdate()),'yyyyMM') AS Status_Month
   ,'Appointed' AS Status
 
  FROM [PowerBI].[DPO].[Main_AGENT_INFO_DA]
  WHERE  [Sales_Unit_Code] NOT IN (SELECT [AD_Code] FROM [PowerBI].[DPO].[Main_AD_STRUCTURE])
	AND [Sales_Unit_Code] NOT IN (SELECT Special_Cases.[AD_Code] FROM Special_Cases)

UNION

SELECT 
	S.AD_CODE
	, S.Grade
	,S.AD_Parent_Code
	,S.Territory_Code
	,S.Status_date
	,S.Status_Month
	,S.Status

FROM Special_Cases AS S
GO


