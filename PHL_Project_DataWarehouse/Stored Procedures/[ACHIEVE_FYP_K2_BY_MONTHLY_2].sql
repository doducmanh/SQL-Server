USE [DP_Manh]
GO

/****** Object:  StoredProcedure [dbo].[ACHIEVE_FYP_K2_BY_MONTHLY_2]    Script Date: 12/01/2023 13:25:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [dbo].[ACHIEVE_FYP_K2_BY_MONTHLY_2] (@varREPORT_MONTH nvarchar(4000)) 
AS 
BEGIN
WITH
---PREPARING DATA
PREMIUM_CUTOFF AS (
	SELECT *
	FROM [dbo].[T_DP_TAGENTPREMIUM_TEST_CUTOFF]
	WHERE [CUTOFF] = FORMAT(EOMONTH(@varREPORT_MONTH), 'yyyyMMdd')
)
, AGENT_INFO_CUTOFF AS (
	SELECT *
	FROM [dbo].[T_Main_AGENT_INFO_DA_CUTOFF]
	WHERE [CUTOFF] = FORMAT(EOMONTH(@varREPORT_MONTH), 'yyyyMMdd')
)
, AGENT_HISTORY_CUTOFF AS (
	SELECT *
	FROM [dbo].[T_Main_AGENT_HISTORY_CUTOFF]
	WHERE [CUTOFF] = FORMAT(EOMONTH(@varREPORT_MONTH), 'yyyyMMdd')
)
, AD_STRUCTURE AS (
	SELECT 
		AD_STRUCTURE2.[TERRITORY],
		AD_STRUCTURE1.*
	FROM (SELECT *
		  FROM [SQL_SV65].[PowerBI].[DPO].[Main_AD_STRUCTURE_FULL]
		  WHERE [ExplodedDate]  = @varREPORT_MONTH) AS AD_STRUCTURE1
	LEFT JOIN [dbo].[T_Main_TERRITORIES] AS AD_STRUCTURE2
	ON AD_STRUCTURE1.[Territory_Code] = AD_STRUCTURE2.[CODE]
)
, K2_CUTOFF AS (
	SELECT *
	FROM [dbo].[T_DP_K2_CUTOFF]
	WHERE [CUTOFF] = FORMAT(EOMONTH(@varREPORT_MONTH), 'yyyyMMdd')
)
, DAILYSALES_CO AS (
	SELECT *
	FROM [dbo].[T_DP_TDAILYSALES_DA_CUTOFF]
	WHERE [CUTOFF] = FORMAT(EOMONTH(@varREPORT_MONTH), 'yyyyMMdd')
)
, AD_TARGET_FYP AS (
	SELECT [AD Code], [AD Name], unpvt.[Grade], YearTarget, CAST(MonthTarget AS INT) AS MonthTarget, TargetFYP
	FROM   (SELECT [AD Code], [AD Name], [Grade], [Year]  AS YearTarget
	, IIF([1] IS NULL, 0, [1]) AS [1]
	, IIF([2] IS NULL, 0, [2]) AS [2]
	, IIF([3] IS NULL, 0, [3]) AS [3]
	, IIF([4] IS NULL, 0, [4]) AS [4]
	, IIF([5] IS NULL, 0, [5]) AS [5]
	, IIF([6] IS NULL, 0, [6]) AS [6]
	, IIF([7] IS NULL, 0, [7]) AS [7]
	, IIF([8] IS NULL, 0, [8]) AS [8]
	, IIF([9] IS NULL, 0, [9]) AS [9]
	, IIF([10] IS NULL, 0, [10]) AS [10]
	, IIF([11] IS NULL, 0, [11]) AS [11]
	, IIF([12] IS NULL, 0, [12]) AS [12]
			FROM [SQL_SV65].[PowerBI].[DPO].[DP_AD_TARGET]
		) p UNPIVOT (TargetFYP FOR MonthTarget IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])) AS unpvt
)
----LOC DANH SACH SFC HIEN TAI
, A AS (
	SELECT DISTINCT
		[Policy No],
		[Issuing Agent],
		[Policy Status],
		[Issued Date]
	FROM PREMIUM_CUTOFF
	WHERE [Policy Status] = 'IF'
) 
, A1 AS (
	SELECT
		*,
		LEAD([Issued Date]) OVER (PARTITION BY [Issuing Agent] ORDER BY [Issued Date]) AS Next_Issued_Date
	FROM A
)
, A2 AS (
	SELECT A21.*
		,A22.[Area_Name]
		,A22.[Agent_Name]
		,A22.[Grade] AS SA_Grade
		,A22.[Sales_Unit_Code]
		,A22.Date_Appointed AS SA_Appointed
		,A22.[Appointed_TAPSU] AS SA_Appointed_TAPSU
		,A22.[Terminated_date] AS SA_Terminated_date
		,A22.[ID_Card] AS SA_ID_Card
		,A22.[Agent_Status]
		,A1.[Issued Date] AS SA_Last_Issued_Date
		,A1.[Next_Issued_Date] AS SA_Next_Issued_Date
		--RULE DUNG THEO BAO CAO TEAM PHUONG
		,IIF(((A1.[Issued Date] IS NOT NULL 
		AND DATEDIFF(MONTH,
		IIF(A22.Date_Appointed > A1.[Issued Date], A22.Date_Appointed,A1.[Issued Date]),A21.[Collected Date]) > IIF(A21.[Collected Date] >='2021-12-01',9,6 ))  
			OR (A1.[Issued Date] IS NULL AND DATEDIFF(MONTH, A22.Date_Appointed, A21.[Collected Date]) > IIF(A21.[Collected Date] >='2021-12-01',9,6 )) ) 
		AND A21.[Collected Date] >='2021-01-01' 
		AND A23.GRADE = 'IC'
		AND DATEDIFF(MONTH,A21.[Issued Date], A21.[Collected Date]) > IIF(A21.[Collected Date] >='2021-12-01',9,6 )
		AND EOMONTH(IIF(A1.[Next_Issued_Date] IS NULL, '2099-12-31',A1.[Next_Issued_Date])) <> EOMONTH(A21.[Collected Date])
		, 'S','' ) AS SFC

	FROM PREMIUM_CUTOFF AS A21
	LEFT JOIN AGENT_INFO_CUTOFF AS A22
	ON A21.[Servicing Agent] = A22.Agent_Number

	LEFT JOIN A1
	ON A21.[Servicing Agent] = A1.[Issuing Agent]
	AND A21.[Collected Date] >= A1.[Issued Date]
	AND A21.[Collected Date] < IIF(A1.[Next_Issued_Date] IS NULL, '2099-12-31',A1.[Next_Issued_Date])

	LEFT JOIN AGENT_HISTORY_CUTOFF AS A23
	ON A21.[Servicing Agent] = A23.[AGENT CODE]
	AND A21.[Collected Date] >= A23.CURRFROM
	AND A21.[Collected Date] < IIF(A23.CURRTO IS NULL, '2099-12-31',A23.CURRTO)
)

----TINH FYP
, A3 AS (
	SELECT
		[Policy No],
		[Collected Date],
		SUM(FYP) AS FYP,
		SUM([Topup Premium]) AS [Topup Premium],
		[Policy Status],
		[Issued Date],
		[Servicing Agent],
		[Issuing Agent],
		Sales_Unit_Code,
		SFC
	FROM A2
	GROUP BY [Policy No], [Collected Date], [Policy Status], [Issued Date], [Servicing Agent],
			[Issuing Agent], Sales_Unit_Code, SFC
)
, A5 AS (
	SELECT
		A51.[Policy No],
		A51.[Collected Date],
		A51.FYP,
		A51.[Topup Premium],
		A52.[Collected Date] AS [Collected Date PAYIN_TOPUP],
		ROW_NUMBER() OVER(PARTITION BY A51.[Policy No], A51.[Collected Date], A51.[Servicing Agent]
					ORDER BY A52.[Collected Date] DESC) AS Match_val,
		A51.[Policy Status],
		A51.[Issued Date],
		A51.[Servicing Agent],
		A51.[Issuing Agent],
		A51.Sales_Unit_Code,
		A51.SFC
	FROM A3 AS A51 LEFT JOIN A3 AS A52
	ON A51.[Policy No] = A52.[Policy No]
	AND DATEADD(month, -6, A51.[Collected Date]) >= A52.[Collected Date]
	AND A51.[Servicing Agent] = A52.[Servicing Agent]
)
, A6 AS (
	SELECT
		[Policy No],
		[Collected Date],
		FYP,
		[Topup Premium],
		ISNULL([Collected Date PAYIN_TOPUP], '2000-01-01') AS MAX_PAYIN_TOPUP_DATE_6M,
		(DATEADD(month, 6, ISNULL([Collected Date PAYIN_TOPUP], '2000-01-01'))) AS WITHRAW_TOPUP_DATE_NO_COUNT,
		[Policy Status],
		[Issued Date],
		[Servicing Agent],
		[Issuing Agent],
		Sales_Unit_Code,
		SFC
	FROM A5 
	WHERE Match_val = 1
)
, A7 AS (
	SELECT DISTINCT
		A71.[Policy No],
		A71.[Collected Date],
		A72.[Collected Date] AS [Collected Date 2],
		A71.FYP,
		A71.[Topup Premium],
		A72.[Topup Premium] AS [Topup Premium 2],
		A71.MAX_PAYIN_TOPUP_DATE_6M,
		A71.WITHRAW_TOPUP_DATE_NO_COUNT,
		A71.[Policy Status],
		A71.[Issued Date],
		A71.[Servicing Agent],
		A71.[Issuing Agent],
		A71.Sales_Unit_Code,
		A71.SFC
	FROM A6 AS A71 LEFT JOIN A6 AS A72
	ON A71.[Policy No] = A72.[Policy No]
	AND A71.[Servicing Agent] = A72.[Servicing Agent]
)
, A8 AS (
	SELECT
		[Policy No],
		[Collected Date],
		FYP,
		[Topup Premium],
		MAX_PAYIN_TOPUP_DATE_6M,
		SUM(CASE
				WHEN [Collected Date 2] <= MAX_PAYIN_TOPUP_DATE_6M THEN [Topup Premium 2]
				ELSE 0
			END) AS [Topup_PAYIN_BEFORE_6M],
		WITHRAW_TOPUP_DATE_NO_COUNT,
		SUM (CASE
				WHEN ([Topup Premium 2] < 0 
						AND ([Collected Date 2] > WITHRAW_TOPUP_DATE_NO_COUNT)
						AND([Collected Date 2] < [Collected Date])) THEN [Topup Premium 2]
				ELSE 0
			 END) AS [Topup_PAYOUT_AFTER_6M],
		[Policy Status],
		[Issued Date],
		[Servicing Agent],
		[Issuing Agent],
		Sales_Unit_Code,
		SFC
	FROM A7
	GROUP BY [Policy No], [Collected Date], FYP, MAX_PAYIN_TOPUP_DATE_6M, [Topup Premium],
		WITHRAW_TOPUP_DATE_NO_COUNT, [Policy Status], [Issued Date],
		[Servicing Agent], [Issuing Agent], Sales_Unit_Code, SFC
)
, A9 AS (
	SELECT
		[Policy No],
		[Collected Date],
		FYP,
		[Topup Premium],
		CASE
			WHEN ([Topup Premium] >= 0 OR ([Topup Premium] < 0 AND [Collected Date] < '2021-12-15')) 
				THEN [Topup Premium]
			ELSE
				CASE
					WHEN ([Topup_PAYIN_BEFORE_6M] + [Topup_PAYOUT_AFTER_6M] > 0) 
					AND ([Topup Premium] + ([Topup_PAYIN_BEFORE_6M] + [Topup_PAYOUT_AFTER_6M])) >= 0 
						THEN 0
					WHEN ([Topup_PAYIN_BEFORE_6M] + [Topup_PAYOUT_AFTER_6M] > 0) 
					AND ([Topup Premium] + ([Topup_PAYIN_BEFORE_6M] + [Topup_PAYOUT_AFTER_6M])) < 0 
						THEN ([Topup Premium] + ([Topup_PAYIN_BEFORE_6M] + [Topup_PAYOUT_AFTER_6M]))
					ELSE [Topup Premium]
				END
		END AS [Topup Premium REVISED6M],
		MAX_PAYIN_TOPUP_DATE_6M,
		[Topup_PAYIN_BEFORE_6M],
		WITHRAW_TOPUP_DATE_NO_COUNT,
		[Topup_PAYOUT_AFTER_6M],
		[Policy Status],
		[Issued Date],
		[Servicing Agent],
		[Issuing Agent],
		Sales_Unit_Code,
		SFC
	FROM A8
)

, B AS (
	SELECT
		[Sales_Unit_Code],
		[Servicing Agent],
		SUM([FYP] + [Topup Premium REVISED6M] * 0.1) AS FYPincTopup
	FROM A9
	WHERE [Collected Date] BETWEEN @varREPORT_MONTH AND EOMONTH(@varREPORT_MONTH)
	AND SFC <> 'S'
	AND [Servicing Agent] NOT LIKE '6999%'
	GROUP BY [Sales_Unit_Code], [Servicing Agent]
)

, B2 AS (
	SELECT
		Sales_Unit_Code,
		SUM(FYPincTopup) AS FYPincTopup
	FROM B
	GROUP BY Sales_Unit_Code
)
----TINH K2
, C AS (
	SELECT
		[AGENT NO],
		SUM([Y2 ACTUAL PREM]) AS Y2_ACTUAL_PREM,
		SUM([Y2 EXPECTED PREM]) AS Y2_EXPECTED_PREM
	FROM K2_CUTOFF
	GROUP BY [AGENT NO]
)
, C1 AS (
	SELECT
		C12.Sales_Unit_Code,
		C11.[AGENT NO],
		C11.Y2_ACTUAL_PREM,
		C11.Y2_EXPECTED_PREM
	FROM C AS C11 LEFT JOIN AGENT_INFO_CUTOFF AS C12
	ON C11.[AGENT NO] = C12.Agent_Number
	WHERE C12.SFC <> 'S'
)
, C2 AS (
	SELECT
		Sales_Unit_Code,
		SUM(Y2_ACTUAL_PREM) AS SUM_Y2_ACTUAL_PREM,
		SUM(Y2_EXPECTED_PREM) AS SUM_Y2_EXPECTED_PREM
	FROM C1
	GROUP BY Sales_Unit_Code
)
----TARGET FYP
, D1 AS (
	SELECT
		[AD Code],
		TargetFYP
	FROM AD_TARGET_FYP
	WHERE [YearTarget] = YEAR(@varREPORT_MONTH) AND [MonthTarget] = MONTH(@varREPORT_MONTH) 
)
----NOI KET QUA VAO AD STRUCTURE
, E AS (
	SELECT
		E1.*,
		E2.FYPincTopup,
		E3.SUM_Y2_ACTUAL_PREM,
		E3.SUM_Y2_EXPECTED_PREM
	FROM AD_STRUCTURE AS E1 LEFT JOIN B2 AS E2 ON E1.[AD_Code] = E2.Sales_Unit_Code
	LEFT JOIN C2 AS E3 ON E1.[AD_Code] = E3.Sales_Unit_Code
)
, E1 AS (
	SELECT 
		ZD AS AD_CODE_FINAL,
		ZDName AS AD_NAME_FINAL,
		SUM(FYPincTopup) AS FYPincTopup,
		SUM(SUM_Y2_ACTUAL_PREM) AS SUM_Y2_ACTUAL_PREM,
		SUM(SUM_Y2_EXPECTED_PREM) AS SUM_Y2_EXPECTED_PREM
	FROM E
	WHERE ZD IS NOT NULL
	GROUP BY ZD, ZDName
	UNION
	SELECT 
		SZD AS AD_CODE_FINAL,
		SZDName AS AD_NAME_FINAL,
		SUM(FYPincTopup) AS FYPincTopup,
		SUM(SUM_Y2_ACTUAL_PREM) AS SUM_Y2_ACTUAL_PREM,
		SUM(SUM_Y2_EXPECTED_PREM) AS SUM_Y2_EXPECTED_PREM
	FROM E
	WHERE SZD IS NOT NULL
	GROUP BY SZD, SZDName
	UNION
	SELECT 
		RAD AS AD_CODE_FINAL,
		RADName AS AD_NAME_FINAL,
		SUM(FYPincTopup) AS FYPincTopup,
		SUM(SUM_Y2_ACTUAL_PREM) AS SUM_Y2_ACTUAL_PREM,
		SUM(SUM_Y2_EXPECTED_PREM) AS SUM_Y2_EXPECTED_PREM
	FROM E
	WHERE RAD IS NOT NULL
	GROUP BY RAD, RADName
	UNION
	SELECT 
		RD AS AD_CODE_FINAL,
		RDName AS AD_NAME_FINAL,
		SUM(FYPincTopup) AS FYPincTopup,
		SUM(SUM_Y2_ACTUAL_PREM) AS SUM_Y2_ACTUAL_PREM,
		SUM(SUM_Y2_EXPECTED_PREM) AS SUM_Y2_EXPECTED_PREM
	FROM E
	WHERE RD IS NOT NULL
	GROUP BY RD, RDName
	UNION
	SELECT 
		SRD AS AD_CODE_FINAL,
		SRDName AS AD_NAME_FINAL,
		SUM(FYPincTopup) AS FYPincTopup,
		SUM(SUM_Y2_ACTUAL_PREM) AS SUM_Y2_ACTUAL_PREM,
		SUM(SUM_Y2_EXPECTED_PREM) AS SUM_Y2_EXPECTED_PREM
	FROM E
	WHERE SRD IS NOT NULL
	GROUP BY SRD, SRDName
	UNION
	SELECT 
		TAD AS AD_CODE_FINAL,
		TADName AS AD_NAME_FINAL,
		SUM(FYPincTopup) AS FYPincTopup,
		SUM(SUM_Y2_ACTUAL_PREM) AS SUM_Y2_ACTUAL_PREM,
		SUM(SUM_Y2_EXPECTED_PREM) AS SUM_Y2_EXPECTED_PREM
	FROM E
	WHERE TAD IS NOT NULL
	GROUP BY TAD, TADName
	UNION
	SELECT 
		TD AS AD_CODE_FINAL,
		TDName AS AD_NAME_FINAL,
		SUM(FYPincTopup) AS FYPincTopup,
		SUM(SUM_Y2_ACTUAL_PREM) AS SUM_Y2_ACTUAL_PREM,
		SUM(SUM_Y2_EXPECTED_PREM) AS SUM_Y2_EXPECTED_PREM
	FROM E
	WHERE TD IS NOT NULL
	GROUP BY TD, TDName
)
, E2 AS (
	SELECT
		AD_CODE_FINAL,
		AD_NAME_FINAL,
		SUM(FYPincTopup) AS FYPincTopup,
		SUM(SUM_Y2_ACTUAL_PREM) AS SUM_Y2_ACTUAL_PREM,
		SUM(SUM_Y2_EXPECTED_PREM) AS SUM_Y2_EXPECTED_PREM
	FROM E1
	GROUP BY AD_CODE_FINAL, AD_NAME_FINAL
)
----FINAL
, F AS (
	SELECT
		F1.TERRITORY,
		F1.TD,
		F1.[TDName],
		F1.TAD,
		F1.[TADName],
		F1.[SRD],
		F1.[SRDName],
		F1.[RD],
		F1.[RDName],
		F1.[RAD],
		F1.[RADName],
		F1.[AD_Code],
		F1.[ADName],
		F1.[AD_Grade],
		(F3.TargetFYP * 1000000) AS TargetFYP,
		F2.FYPincTopup,
		(F2.FYPincTopup/ NULLIF((F3.TargetFYP * 1000000), 0)) AS ACHIEVED_TARGET_FYP,
		F2.SUM_Y2_ACTUAL_PREM,
		F2.SUM_Y2_EXPECTED_PREM,
		(F2.SUM_Y2_ACTUAL_PREM/ NULLIF(F2.SUM_Y2_EXPECTED_PREM, 0)) AS K2,
		FORMAT(CAST(@varREPORT_MONTH AS date), 'yyyyMM') AS REPORT_MONTH
	FROM AD_STRUCTURE AS F1 LEFT JOIN E2 AS F2 ON F1.[AD_Code] = F2.AD_CODE_FINAL
	LEFT JOIN D1 AS F3 ON F1.[AD_Code] = F3.[AD Code]
)
----
	SELECT *
	FROM F
END;
GO


