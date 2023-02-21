USE [PowerBI]
GO

/****** Object:  View [DPO].[Cal_Active_Agent_by_Month_MANH]    Script Date: 30/09/2022 16:30:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [DPO].[Cal_Active_Agent_by_Month_MANH]
AS
WITH DateType2
AS (
	SELECT *
	FROM (
		SELECT [Policy No]
			,MIN([Issued Date]) AS FirstDate
			,MAX([Collected Date]) AS LastDate
			,[Policy Status]
			,[Issuing Agent]
		FROM [PowerBI].[DPO].[view_premium]
		WHERE [Policy Status] != 'PS_NNB' --AND [Issued Date] IS NOT NULL
		GROUP BY [Policy No]
			,[Policy Status]
			,[Issued Date]
			,[Issuing Agent]
		) AS DateType
	UNPIVOT(DateActive FOR DateType IN (
				FirstDate
				,LastDate
				)) UNPVT
	)
	,TEMP
AS (
	SELECT [Issuing Agent]
		,AG.Date_Appointed
		,[Policy No]
		,DateActive
		,CountPolicy
		,AG.AD_Code
		,AG.AD_Code + CONVERT(CHAR(8), [DateActive], 112) AS ID
		,DATEDIFF(DAY, AG.Date_Appointed, DateActive) AS DateDif
	FROM (
		SELECT [Policy No]
			,[Issuing Agent]
			,DateActive
			,CASE 
				WHEN DateType = 'FirstDate'
					THEN 1
				WHEN [Policy Status] IN (
						'FL'
						,'PO'
						,'DC'
						,'WD'
						,'NT'
						,'CF'
						)
					THEN - 1
				ELSE 0
				END AS CountPolicy
		FROM DateType2
		) AS DS
	LEFT JOIN [DPO].[DW_Agent] AG ON DS.[Issuing Agent] = AG.Code
	WHERE CountPolicy != 0
	)
	,Manh_DW_AD_DailyPolicy
AS (
	SELECT *
		--CASE
		--    WHEN condition1 THEN result1
		--    WHEN condition2 THEN result2
		--    WHEN conditionN THEN resultN
		--    ELSE result
		--END;
		,CASE 
			WHEN TEMP.DateActive < '2022/01/01'
				THEN CONVERT(CHAR(6), TEMP.[DateActive], 112)
			WHEN TEMP.DateActive <= '2022/01/27'
				THEN 202201
			WHEN TEMP.DateActive <= '2022/02/28'
				THEN 202202
			WHEN TEMP.DateActive <= '2022/03/29'
				THEN 202203
			WHEN TEMP.DateActive <= '2022/04/29'
				THEN 202204
			WHEN TEMP.DateActive <= '2022/05/31'
				THEN 202205
			WHEN TEMP.DateActive <= '2022/06/30'
				THEN 202206
			WHEN TEMP.DateActive <= '2022/07/31'
				THEN 202207
			WHEN TEMP.DateActive <= '2022/08/31'
				THEN 202208
			WHEN TEMP.DateActive <= '2022/09/30'
				THEN 202209
			WHEN TEMP.DateActive <= '2022/10/31'
				THEN 202210
			WHEN TEMP.DateActive <= '2022/11/30'
				THEN 202211
			WHEN TEMP.DateActive <= '2022/12/31'
				THEN 202212
			ELSE CONVERT(CHAR(6), TEMP.[DateActive], 112)
			END AS Cutoff_Month
	FROM TEMP
	)
	,Temp1
AS (
	SELECT [Issuing Agent]
		--,[Date_Appointed]
		,[Policy No]
		--,MONTH([DateActive]) AS MONTH_ACTIVE
		,Cutoff_Month AS MONTH_ACTIVE
		,SUM(CountPolicy) AS NET_CC
	--,[AD_Code]
	--,[ID]
	--,[DateDif]
	FROM Manh_DW_AD_DailyPolicy
	GROUP BY [AD_Code]
		,Cutoff_Month
		--,MONTH([DateActive])
		--,YEAR([DateActive])
		,[Policy No]
		,[Issuing Agent]
	HAVING SUM(CountPolicy) <> 0
	)
	,Temp2
AS (
	SELECT CONCAT (
			Temp1.[Issuing Agent]
			,Temp1.MONTH_ACTIVE
			) AS ID
		,Temp1.[Issuing Agent]
		,Temp1.MONTH_ACTIVE
		,SUM(NET_CC) AS CASE_COUNT
		,IIF(SUM(NET_CC) > 0, 1, 0) AS Active_Agent
	FROM Temp1
	GROUP BY Temp1.[Issuing Agent]
		,Temp1.MONTH_ACTIVE
		--ORDER BY Temp1.[Issuing Agent] DESC
	)
SELECT Temp2.ID
	,DATEFROMPARTS(Temp2.MONTH_ACTIVE / 100, Temp2.MONTH_ACTIVE % 100, '01') AS ID_DATE
	,Temp2.[Issuing Agent]
	,Temp2.MONTH_ACTIVE
	,Temp2.CASE_COUNT
	,Temp2.Active_Agent
FROM Temp2
	--WHERE [Issuing Agent] = '60057112'
GO


