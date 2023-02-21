USE [PowerBI]
GO

/****** Object:  View [DPO].[AGENCY_STRUCTURE_Exploded]    Script Date: 16/12/2022 17:06:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER   VIEW [DPO].[AGENCY_STRUCTURE_Exploded] AS
WITH E00(N) AS (SELECT 1 UNION ALL SELECT 1)
    ,E02(N) AS (SELECT 1 FROM E00 a, E00 b)
    ,E04(N) AS (SELECT 1 FROM E02 a, E02 b)
    ,E08(N) AS (SELECT 1 FROM E04 a, E04 b)
    ,E16(N) AS (SELECT 1 FROM E08 a, E08 b)
    ,E32(N) AS (SELECT 1 FROM E16 a, E16 b)
    ,cteTally(N) AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E32)
    ,DateRange AS
(
    SELECT ExplodedDate = DATEADD(MONTH,N - 1,'2013-01-01')
    FROM cteTally
    WHERE N <= 240
)
--SELECT DateRange.*
--FROM DateRange
, Month_Exploded AS (
  SELECT  
		 [Area_Name] AS AD_Office
        ,[Sales_Unit_Code] AS AD_Code
        ,[Agent_Number]
	    ,CAST(d.ExplodedDate AS DATE) AS ExplodedDate
	  	--,d.ExplodedDate  AS ExplodedDate
	  --,CAST(B.CURRFROM AS DATE) AS [Date_Appointed]
	  --,CAST(eh.[Appointed_TAPSU] AS DATE) AS [Last_Date_Appointed]
	  --,CAST(eh.[Terminated_date] AS DATE) AS [Terminated_date]
	  --,[Supervisor_Code]
      --,[Agent_Name]
	  --,[Grade]
	  --,[Agent_Status]
  FROM [PowerBI].[DPO].[Main_AGENT_INFO_DA] eh
		LEFT JOIN [PowerBI].[DPO].[Main_AGENT_HISTORY] B ON eh.Agent_Number = B.[AGENT CODE] AND B.STATUS = 'A'
        LEFT JOIN DateRange d ON DATEADD(MONTH,1,d.ExplodedDate) >= B.CURRFROM AND d.ExplodedDate < EOMONTH(GETDATE())--IIF(eh.[Terminated_date] IS NULL, '2099-12-31',DATEADD(MONTH, 24, eh.[Terminated_date]))    
	  --ORDER BY [Agent_Number], [Date_Appointed], [ExplodedDate]
	  --WHERE eh.[Agent_Number] = '60015807'
	--WHERE [ExplodedDate] >= '2020-01-01'

)
, Temp1 AS (
SELECT [AGENT CODE]
      --,[STATUS]
      ----,[OLD GRADE]
      --,[GRADE] 
      ,(DATEADD(DAY,-DAY([CURRFROM])+1, [CURRFROM]))AS [new CURRFROM]
	  ,IIF(CURRTO IS NULL, '2099-12-31',IIF(CURRTO IS NULL, '2099-12-30',CURRTO)) AS [new CURRTO]
      ,[CURRFROM]
	  ,[CURRTO]
      ,[New Leader Code]
	  ,[GRADE]
      --,[Old Leader Code]
      --,[NOTE]
      --,[CLUB CLASS]
      --,[EFFECTIVE DATE CLUB CLASS]
      --,[Reason mark club class]
      --,[EXPIRED_LICENSE_DATE]
        ,MAX([RN]) AS [RN]
  FROM [PowerBI].[DPO].[Main_AGENT_HISTORY]
  WHERE CURRFROM <> IIF(CURRTO IS NULL, '2099-12-31',CURRTO)
  GROUP BY [AGENT CODE]
      ,[GRADE]  
      ,(DATEADD(DAY,-DAY([CURRFROM])+1, [CURRFROM]))
	  ,(DATEADD(DAY,-DAY([CURRTO]), [CURRTO]))
      ,[CURRFROM]
	  ,[CURRTO]
      ,[New Leader Code]
-- ORDER BY MAX([RN])
)
,Temp2 AS (
SELECT A.[AGENT CODE]
	  ,A.[new CURRFROM]
	  ,MAX(A.[RN]) AS RN
FROM Temp1 AS A
--WHERE [AGENT CODE] = '60020543'
GROUP BY A.[AGENT CODE]
	  ,A.[new CURRFROM]
)
,Temp3 AS (
SELECT Temp1.[AGENT CODE]
	--, Temp1.CURRFROM
	--, Temp1.CURRTO
	, Temp1.GRADE
	, Temp1.[new CURRFROM]
	--, Temp1.[new CURRTO]
	, Temp1.[New Leader Code]
	--, Temp1.RN
	, LEAD(Temp1.[new CURRFROM]) OVER (PARTITION BY Temp1.[AGENT CODE] ORDER BY Temp1.RN) AS [LEAD CURRTO]
FROM Temp1
JOIN Temp2
ON Temp1.[AGENT CODE] = Temp2.[AGENT CODE]
AND Temp1.RN = Temp2.RN
--WHERE Temp1.[AGENT CODE] = '60020543'
)
, Temp4 AS (
SELECT  
	   A.AD_Code, A.AD_Office, 
	   A.Agent_Number, A.ExplodedDate
	  ,B.[GRADE]
	  ,IIF(B.[New Leader Code] <> '', B.[New Leader Code], NULL) AS Supervisor_Code
	  --, CONCAT(A.[Agent_Number],A.ExplodedDate) AS ID_AGENT
	  --, CONCAT(A.AD_Code,A.ExplodedDate) AS ID_AD
	  --,CONCAT(B.[New Leader Code],A.[ExplodedDate])  AS IDSup
	  --, A.[Agent_Number] + FORMAT( A.ExplodedDate, 'yyyyMM') AS ID_AGENT
	  --, A.AD_Code + FORMAT( A.ExplodedDate, 'yyyyMM') AS ID_AD
	  --, IIF(B.[New Leader Code] <> '',B.[New Leader Code] + FORMAT( A.[ExplodedDate], 'yyyyMM'),NULL)  AS IDSup
	  --,CONCAT(B.[New Leader Code], FORMAT( A.[ExplodedDate], 'yyyyMM') ) AS IDSup
FROM Month_Exploded AS A
LEFT JOIN Temp3 AS B
ON A.[Agent_Number] = B.[AGENT CODE]
AND B.[new CURRFROM] <= A.[ExplodedDate]
AND IIF(B.[LEAD CURRTO] IS NULL, '2099-12-31',B.[LEAD CURRTO]) > A.[ExplodedDate]

)

SELECT Temp4.*

FROM Temp4
WHERE Temp4.ExplodedDate >= '2019-01-01'
--WHERE A.[Agent_Number] = '60000002'
--ORDER BY A.[ExplodedDate]
GO


