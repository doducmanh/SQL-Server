USE [PowerBI]
GO

/****** Object:  View [DPO].[SFC Dynamic_bak]    Script Date: 30/09/2022 16:36:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [DPO].[SFC Dynamic_bak]
AS
--Link: https://sqlhints.com/2015/07/10/how-to-get-difference-between-two-dates-in-years-months-and-days-in-sql-server/
--Difference between two dates in Y Months
--DECLARE @FromDate DATETIME = '2010-01-01 23:59:59.000', 
--        @ToDate   DATETIME = '2015-01-02 00:00:00.000',
--        @Years INT, @Months INT, @Days INT, @tmpFromDate DATETIME
--SET @Years = DATEDIFF(YEAR, @FromDate, @ToDate)
-- - (CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, @FromDate, @ToDate),
--          @FromDate) > @ToDate THEN 1 ELSE 0 END) 
--SET @tmpFromDate = DATEADD(YEAR, @Years , @FromDate)
--SET @Months =  DATEDIFF(MONTH, @tmpFromDate, @ToDate)
-- - (CASE WHEN DATEADD(MONTH,DATEDIFF(MONTH, @tmpFromDate, @ToDate),
--          @tmpFromDate) > @ToDate THEN 1 ELSE 0 END) 
--SET @tmpFromDate = DATEADD(MONTH, @Months , @tmpFromDate)
--SET @Days =  DATEDIFF(DAY, @tmpFromDate, @ToDate)
-- - (CASE WHEN DATEADD(DAY, DATEDIFF(DAY, @tmpFromDate, @ToDate),
--          @tmpFromDate) > @ToDate THEN 1 ELSE 0 END) 
--SELECT @FromDate FromDate, @ToDate ToDate, 
--       (@Years*12 + @Months + @Days/30) Months
--Function calculate # months between 2 dates
--CREATE FUNCTION DPO.DateDiffInMonth
--(
--   @FromDate DATETIME, @ToDate DATETIME
--)
--RETURNS DECIMAL
--AS
--BEGIN
--    DECLARE @Years INT, @Months INT, @Days INT, @tmpFromDate DATETIME
--    SET @Years = DATEDIFF(YEAR, @FromDate, @ToDate)
--     - (CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, @FromDate, @ToDate),
--              @FromDate) > @ToDate THEN 1 ELSE 0 END) 
--    SET @tmpFromDate = DATEADD(YEAR, @Years , @FromDate)
--    SET @Months =  DATEDIFF(MONTH, @tmpFromDate, @ToDate)
--     - (CASE WHEN DATEADD(MONTH,DATEDIFF(MONTH, @tmpFromDate, @ToDate),
--              @tmpFromDate) > @ToDate THEN 1 ELSE 0 END) 
--    SET @tmpFromDate = DATEADD(MONTH, @Months , @tmpFromDate)
--    SET @Days =  DATEDIFF(DAY, @tmpFromDate, @ToDate)
--     - (CASE WHEN DATEADD(DAY, DATEDIFF(DAY, @tmpFromDate, @ToDate),
--              @tmpFromDate) > @ToDate THEN 1 ELSE 0 END) 
--    RETURN @Years*12 + @Months + @Days/30
--END
--GO
--Test
--DECLARE @FromDate DATETIME = '2010-01-01 23:59:59.000', 
--        @ToDate   DATETIME = '2015-01-02 00:00:00.000'
--SELECT DPO.DateDiffInMonth(@FromDate,@ToDate) 'Months'
--GO
WITH Temp1
AS (
	SELECT A.[Policy No]
		,A.[Issuing Agent]
		,A.[Policy Status]
		,C.Date_Appointed AS IA_Appointed
		,A.[Issued Date]
	--,LEAD(A.[Issued Date]) OVER (PARTITION BY A.[Issuing Agent] ORDER BY A.[Issued Date]) AS Next_Issued_Date
	FROM [PowerBI].[DPO].[DP_TAGENTPREMIUM_TEST] AS A
	LEFT JOIN [DPO].[Main_AGENT_INFO_DA] AS C ON A.[Issuing Agent] = C.Agent_Number
	WHERE A.[Policy Status] = 'IF'
	GROUP BY A.[Policy No]
		,A.[Issued Date]
		,A.[Issuing Agent]
		,A.[Policy Status]
		,C.Date_Appointed
	)
	,Temp2
AS (
	SELECT Temp1.*
		,LEAD(Temp1.[Issued Date]) OVER (
			PARTITION BY Temp1.[Issuing Agent] ORDER BY Temp1.[Issued Date]
			) AS Next_Issued_Date
	FROM Temp1
		--WHERE Temp1.[Issuing Agent] = '60015683'
		--ORDER BY Temp1.[Issued Date]
	)
--,Temp3 AS (
SELECT A.*
	--A.[Policy No]    
	--      --,A.[Issued Date]
	--      ,A.[Servicing Agent]
	--      --,A.[Issuing Agent]
	--	  ,A.[Policy Status]
	,B.Date_Appointed AS SA_Appointed
	--,A.[Collected Date]
	,Temp2.[Issued Date] AS SA_Last_Issued_Date
	,Temp2.[Next_Issued_Date] AS SA_Next_Issued_Date
	,IIF((
			(
				Temp2.[Issued Date] IS NOT NULL
				AND DATEDIFF(MONTH, IIF(B.Date_Appointed > Temp2.[Issued Date], B.Date_Appointed, Temp2.[Issued Date]), A.[Collected Date]) > IIF(A.[Collected Date] >= '2021-12-01', 9, 6)
				)
			--AND DATEDIFF(MONTH,IIF(Temp2.[Next_Issued_Date] IS NOT NULL,Temp2.[Next_Issued_Date],Temp2.[Issued Date]) ,A.[Collected Date]) > 0
			OR (
				Temp2.[Issued Date] IS NULL
				AND DATEDIFF(MONTH, B.Date_Appointed, A.[Collected Date]) > IIF(A.[Collected Date] >= '2021-12-01', 9, 6)
				)
			)
		AND A.[Collected Date] >= '2021-01-01'
		AND C.GRADE = 'IC'
		AND DATEDIFF(MONTH, A.[Issued Date], A.[Collected Date]) > IIF(A.[Collected Date] >= '2021-12-01', 9, 6)
		AND EOMONTH(IIF(Temp2.[Next_Issued_Date] IS NULL, '2099-12-31', Temp2.[Next_Issued_Date])) <> EOMONTH(A.[Collected Date]), 'S', '') AS SFC
	,C.GRADE AS SA_Grade
FROM [PowerBI].[DPO].[DP_TAGENTPREMIUM_TEST] AS A
LEFT JOIN [DPO].[Main_AGENT_INFO_DA] AS B ON A.[Servicing Agent] = B.Agent_Number
LEFT JOIN Temp2 ON A.[Servicing Agent] = Temp2.[Issuing Agent]
	AND A.[Collected Date] >= Temp2.[Issued Date]
	AND A.[Collected Date] < IIF(Temp2.[Next_Issued_Date] IS NULL, '2099-12-31', Temp2.[Next_Issued_Date])
LEFT JOIN [DPO].[Main_AGENT_HISTORY] AS C ON A.[Servicing Agent] = C.[AGENT CODE]
	AND A.[Collected Date] >= C.CURRFROM
	AND A.[Collected Date] < IIF(C.CURRTO IS NULL, '2099-12-31', C.CURRTO)
	--WHERE SFC   = 'S'
	--ORDER BY A.[Collected Date]
	--)
	--WHERE a.[Policy No] = '80044835'
GO


