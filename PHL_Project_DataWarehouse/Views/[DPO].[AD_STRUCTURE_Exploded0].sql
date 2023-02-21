USE [PowerBI]
GO

/****** Object:  View [DPO].[AD_STRUCTURE_Exploded0]    Script Date: 30/09/2022 16:24:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [DPO].[AD_STRUCTURE_Exploded0] AS
WITH E00(N) AS (SELECT 1 UNION ALL SELECT 1)
    ,E02(N) AS (SELECT 1 FROM E00 a, E00 b)
    ,E04(N) AS (SELECT 1 FROM E02 a, E02 b)
    ,E08(N) AS (SELECT 1 FROM E04 a, E04 b)
    --,E16(N) AS (SELECT 1 FROM E08 a, E08 b)
    --,E32(N) AS (SELECT 1 FROM E16 a, E16 b)
    ,cteTally(N) AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E08)
    ,DateRange AS
(
    SELECT ExplodedDate = DATEADD(MONTH,N - 1,'2014-01-01')
    FROM cteTally
    WHERE N <= 120
)

--SELECT A.*
--FROM DateRange AS A

,Q AS (
SELECT [AD_Code]
      --,[AD_Name]
      ,[Grade]
      ,[AD_Parent_Code]
      --,[AD_Parent]
      --,[Territory]
      ,[Territory_Code]
      --,[Office]
      --,[Office_Code]
      ,[Status_Month] AS Start_date
      ,[Status] 
	  --,[Update_Time]
  FROM [DPO].[AD_STRUCTURE0]
  --WHERE [Status] <> 'Office / Territory' 
  GROUP BY [AD_Code]
      --,[AD_Name]
      ,[Grade]
      ,[AD_Parent_Code]
      --,[AD_Parent]
      --,[Territory]
      ,[Territory_Code]
      --,[Office]
      --,[Office_Code]
      ,[Status_Month]
      ,[Status] 
)
,F AS (
SELECT Q.[AD_Code] 
      --,Q.[AD_Name]
      ,Q.[Grade]
      ,Q.[AD_Parent_Code]
      --,Q.[AD_Parent]
      --,[Territory]
      ,[Territory_Code]
      --,[Office]
      --,[Office_Code]
      ,Q.[Start_date]
	  ,LEAD([Start_date]) OVER (PARTITION BY AD_Code ORDER BY [Start_date]) AS End_Date
	  ,[Status] 

FROM Q
--WHERE Q.[AD_Code] = 'AD174'
)


SELECT eh.[AD_Code], eh.[Grade]
	 , IIF(eh.[AD_Parent_Code] IS NULL,'',eh.[AD_Parent_Code]) AS [AD_Parent_Code]
	 ,IIF(eh.[Territory_Code] IS NULL,'PHL',eh.[Territory_Code]) AS [Territory_Code]
	 , eh.[Start_date]
	 , eh.[End_Date]
	 , eh.[Status]
	 , CAST(d.ExplodedDate AS DATE) AS ExplodedDate
FROM    F AS eh 
LEFT JOIN DateRange d 
ON EOMONTH(d.ExplodedDate) >= eh.[Start_Date] 
AND EOMONTH(d.ExplodedDate) < IIF(eh.[End_Date] IS NULL, '2099-12-31',eh.[End_Date])
	  --ORDER BY [AD_Code], [Start_date], [ExplodedDate]
WHERE eh.[AD_Code] IS NOT NULL --AND eh.[AD_Code] = 'AD312'
GO


