USE [PowerBI]
GO

/****** Object:  View [DPO].[DW_AD_DailyPolicy]    Script Date: 30/09/2022 16:32:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE   VIEW [DPO].[DW_AD_DailyPolicy] AS
WITH DateType2 AS (
SELECT	*
FROM 
(SELECT [Policy No]
      ,MIN([Issued Date]) AS FirstDate
	  ,MAX([Collected Date]) AS LastDate
      ,[Policy Status]
      ,[Issuing Agent]
  FROM [PowerBI].[DPO].[view_premium]
  WHERE [Policy Status] != 'PS_NNB' AND [Issued Date] IS NOT NULL
  GROUP BY [Policy No],[Policy Status],[Issued Date],[Issuing Agent]
  ) AS DateType
  UNPIVOT(
		DateActive
		FOR DateType 
		IN (FirstDate, LastDate)) UNPVT
)
,Temp AS (
SELECT	[Issuing Agent]
		,AG.Date_Appointed
		,[Policy No]
		,DateActive
		,CountPolicy
		,AG.AD_Code
		,AG.AD_Code + CONVERT(CHAR(8),[DateActive],112) AS ID
		,DATEDIFF(DAY,AG.Date_Appointed,DateActive) AS DateDif
FROM (
SELECT [Policy No],[Issuing Agent],DateActive,
	CASE 
	WHEN DateType = 'FirstDate' THEN 1
	WHEN [Policy Status] IN ('FL', 'PO', 'DC', 'WD', 'NT', 'CF') THEN -1
	ELSE 0 END AS CountPolicy
FROM DateType2
) AS DS
LEFT JOIN DW_Agent AG
ON DS.[Issuing Agent] = AG.Code
WHERE CountPolicy != 0
)

SELECT *

--CASE
--    WHEN condition1 THEN result1
--    WHEN condition2 THEN result2
--    WHEN conditionN THEN resultN
--    ELSE result
--END;

,CASE
	WHEN Temp.DateActive < '2022/01/01'THEN CONVERT(CHAR(6),Temp.[DateActive],112)
	WHEN Temp.DateActive <= '2022/01/27'THEN 202201
	WHEN Temp.DateActive <= '2022/02/28'THEN 202202
	WHEN Temp.DateActive <= '2022/03/29'THEN 202203
	WHEN Temp.DateActive <= '2022/04/29'THEN 202204
	WHEN Temp.DateActive <= '2022/05/31'THEN 202205
	WHEN Temp.DateActive <= '2022/06/30'THEN 202206
	WHEN Temp.DateActive <= '2022/07/31'THEN 202207
	WHEN Temp.DateActive <= '2022/08/31'THEN 202208
	WHEN Temp.DateActive <= '2022/09/30'THEN 202209
	WHEN Temp.DateActive <= '2022/10/31'THEN 202210
	WHEN Temp.DateActive <= '2022/11/30'THEN 202211
	WHEN Temp.DateActive <= '2022/12/31'THEN 202212
	ELSE CONVERT(CHAR(6),Temp.[DateActive],112) END AS Cutoff_Month


FROM Temp
--WHERE [Issuing Agent] = '60055055'
GO


