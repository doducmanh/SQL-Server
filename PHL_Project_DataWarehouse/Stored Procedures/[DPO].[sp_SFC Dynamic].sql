USE [PowerBI]
GO

/****** Object:  StoredProcedure [DPO].[sp_SFC Dynamic]    Script Date: 30/09/2022 16:50:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [DPO].[sp_SFC Dynamic] AS
BEGIN

	--SELECT column_name FROM INFORMATION_SCHEMA.COLUMNS  
	--WHERE TABLE_NAME = 'AD Info'


	--SELECT name
	--FROM   tempdb.sys.columns
	--WHERE  object_id = Object_id('tempdb..#Col_Last') 
	SET NOCOUNT ON
	SELECT 
		[Issuing Agent]
		,[Issued Date]
	INTO #Issue_His
	FROM [DPO].[DP_TAGENTPREMIUM_TEST] A
	GROUP BY

		[Issuing Agent]
		,[Issued Date]



	SELECT 
		*
		,LAG(A.[Issued Date]) OVER (PARTITION BY A.[Issuing Agent] ORDER BY A.[Issued Date]) AS [Last Issued Date]
	INTO #Issue_His2
	FROM #Issue_His A



	CREATE TABLE #Col_Last
	(
		[Servicing Agent] VARCHAR(8)
		,[Collected Date] DATE
		,[Max Issued Date] DATE
		,[No Months] FLOAT
		,[Min_96] INT
		,SFC CHAR
	)

	INSERT INTO #Col_Last
	(
		[Servicing Agent]
		,[Collected Date]
	)
	SELECT DISTINCT
		A.[Servicing Agent]
		,A.[Collected Date]
	FROM [DPO].[DP_TAGENTPREMIUM_TEST] A

	UPDATE #Col_Last
	SET	[Max Issued Date] = B.[Issued Date]
	FROM #Col_Last A
	LEFT JOIN #Issue_His2 B
	ON A.[Servicing Agent] = B.[Issuing Agent]
	WHERE B.[Issued Date] = (
		SELECT MAX(C.[Issued Date])
		FROM #Issue_His2 C
		WHERE C.[Issuing Agent] = A.[Servicing Agent]
		AND C.[Issued Date] <= A.[Collected Date]
		)
	UPDATE #Col_Last
	SET [No Months] = DPO.udfMonthDiff([Max Issued Date], [Collected Date])
	UPDATE #Col_Last
	SET [Min_96] = IIF([Collected Date] >='2021-12-01', 9, 6)
	UPDATE #Col_Last
	SET [SFC] = 'S'
	WHERE [No Months] >= [Min_96]




	SELECT A.*
	INTO #Col_Last_IC
	FROM #Col_Last A
	INNER JOIN [DPO].[Main_AGENT_HISTORY] AS C
	ON A.[Servicing Agent] = C.[AGENT CODE]

	WHERE C.GRADE = 'IC'
		AND A.[Collected Date] >= C.CURRFROM
		AND A.[Collected Date] < IIF(C.CURRTO IS NULL, '9999-12-31',C.CURRTO)
		AND EXISTS(
			SELECT 1
			FROM [DPO].[DP_TAGENTPREMIUM_TEST] D
			WHERE D.[Servicing Agent] = A.[Servicing Agent]
			AND D.[Policy Status] = 'IF'
			AND D.[Collected Date] >= C.CURRFROM
			AND D.[Collected Date] < IIF(C.CURRTO IS NULL, '9999-12-31',C.CURRTO) 
		)

	
	IF object_id('DPO.SFC_Dynamic') IS NOT NULL
		DROP TABLE DPO.SFC_Dynamic

	SELECT 
			A.*
			,B.SFC
	INTO DPO.SFC_Dynamic
	FROM [DPO].[DP_TAGENTPREMIUM_TEST] A
	LEFT JOIN #Col_Last_IC B
	ON A.[Servicing Agent] = B.[Servicing Agent]
	AND A.[Collected Date] = B.[Collected Date]	

	DROP TABLE IF EXISTS #Issue_His
	DROP TABLE IF EXISTS #Issue_His2
	DROP TABLE IF EXISTS #Col_Last
	DROP TABLE IF EXISTS #Col_Last_IC
	--DROP TABLE IF EXISTS #Agent_Prem

	RETURN
END
GO


