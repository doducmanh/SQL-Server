USE [DP_Manh]
GO

/****** Object:  StoredProcedure [dbo].[ACHIEVE_FYP_K2_BY_MONTHLY]    Script Date: 16/01/2023 14:43:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








ALTER PROCEDURE [dbo].[ACHIEVE_FYP_K2_BY_MONTHLY] (@varREPORT_MONTH nvarchar(4000)) 
AS 
BEGIN
WITH
---PREPARING DATA
PREMIUM_CUTOFF AS (
	SELECT *
	FROM [dbo].[T_DP_TAGENTPREMIUM_TEST_CUTOFF]
	WHERE [CUTOFF] = FORMAT(EOMONTH(@varREPORT_MONTH), 'yyyyMMdd')
)
, TOPUP_REVISE AS (
	SELECT	*
	FROM [dbo].[T_TOPUP_REVISED]
	WHERE [REPORT_MONTH] = FORMAT(EOMONTH(@varREPORT_MONTH), 'yyyyMM')
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
, B00 AS (
	SELECT
		[Sales_Unit_Code],
		[Servicing Agent],
		SUM([FYP] + [Topup Premium] * 0.1) AS FYPincTopup
	FROM A2
	WHERE [Collected Date] BETWEEN @varREPORT_MONTH AND EOMONTH(@varREPORT_MONTH)
	AND SFC <> 'S'
	AND [Servicing Agent] NOT LIKE '6999%'
	GROUP BY [Sales_Unit_Code], [Servicing Agent]
)
, B01 AS (
	SELECT
		[AD_CODE],
		[Servicing Agent],
		SUM([FYP_Difference]) AS FYP_ADDING
	FROM TOPUP_REVISE
	GROUP BY [AD_CODE], [Servicing Agent]
)
, B02 AS (
	SELECT
		B021.Sales_Unit_Code,
		B021.[Servicing Agent],
		B021.FYPincTopup,
		B022.FYP_ADDING,
		(B021.FYPincTopup + ISNULL(B022.FYP_ADDING, 0)) AS FYPincTopup2
	FROM B00 AS B021 LEFT JOIN B01 AS B022
	ON B021.Sales_Unit_Code = B022.AD_CODE AND B021.[Servicing Agent] = B022.[Servicing Agent]
)
, B2 AS (
	SELECT
		Sales_Unit_Code,
		SUM(FYPincTopup2) AS FYPincTopup
	FROM B02
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
		F1.[SZD],
		F1.[SZDName],
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


