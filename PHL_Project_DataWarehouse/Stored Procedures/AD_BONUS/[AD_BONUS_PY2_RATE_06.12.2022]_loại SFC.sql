USE [DP_Manh]
GO

/****** Object:  StoredProcedure [dbo].[AD_BONUS_PY2_RATE]    Script Date: 06/12/2022 08:58:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [dbo].[AD_BONUS_PY2_RATE] (@varREPORT_MONTH nvarchar(4000)) 
AS 
BEGIN
----PREPARING DATA
WITH AD_STRUCTURE AS (
	SELECT 
		AD_STRUCTURE2.[TERRITORY],
		AD_STRUCTURE1.*
	FROM (SELECT *
		  FROM [SQL_SV65].[PowerBI].[DPO].[Main_AD_STRUCTURE_FULL]
		  ) AS AD_STRUCTURE1
	LEFT JOIN [dbo].[T_Main_TERRITORIES] AS AD_STRUCTURE2
	ON AD_STRUCTURE1.[Territory_Code] = AD_STRUCTURE2.[CODE]
)
, POLICY_STATUS_CO AS (
	SELECT DISTINCT
		[Policy No],
		[Policy Status],
		[CUTOFF]
	FROM [DP_Manh].[dbo].[T_DP_TAGENTPREMIUM_TEST_CUTOFF]
)
, PY2_DATA AS (
	SELECT
		Z1.[Sales_Unit_Code],
		Z1.[Sales Unit],
		Z1.[GM_CODE],
		Z1.[GM_NAME],
		Z1.[RM_CODE],
		Z1.[RM_NAME],
		Z1.[DM-code],
		Z1.[DM-name],
		Z1.[FM_CODE],
		Z1.[FM_NAME],
		Z1.[Agent Number],
		Z1.[Agent Name],
		Z1.[Grade],
		Z1.[Policy No],
		Z1.[RISK_COMMENCE_DATE],
		Z1.[Current Due Date],
		Z1.[Payment Frequency],
		Z1.[Original Pre],
		Z1.[Collected],
		Z1.[Collection status],
		Z1.[Policy year],
		Z1.[Due month],
		Z1.[Report month],
		Z2.[Policy Status]
	FROM [dbo].[T_PY2_DATA_PS] AS  Z1 LEFT JOIN POLICY_STATUS_CO AS Z2
	ON Z1.[Policy No] = Z2.[Policy No] 
	AND FORMAT(CAST(Z1.[Report month] AS date), 'yyyyMM') = FORMAT(CAST(Z2.CUTOFF AS date), 'yyyyMM')
)
, AGENT_INFO_CUTOFF AS (
	SELECT *
	FROM [dbo].[T_Main_AGENT_INFO_DA_CUTOFF]
	WHERE [CUTOFF] = FORMAT(EOMONTH(@varREPORT_MONTH), 'yyyyMMdd')
)
----
, Z0 AS (
	SELECT
		Z01.*,
		Z02.SFC
	FROM PY2_DATA AS Z01 LEFT JOIN AGENT_INFO_CUTOFF AS Z02
	ON Z01.[Agent Number] = Z02.Agent_Number
)
, A AS (
	SELECT
		 CAST([Report month] AS date) AS REPORT_MONTH
		,[Sales_Unit_Code] AS [AD Code]
		,[Sales Unit] AS [AD Name]
		,SUM([Collected]) AS [Actual Premium]
		,SUM([Original Pre]) [Expected Premium]
	FROM Z0
	WHERE [Policy Status] NOT IN ('RD', 'TR', 'SU')
	AND SFC <> 'S'
	GROUP BY [Report month], [Sales_Unit_Code], [Sales Unit]
)
, A0 AS (
	SELECT
		A02.TD,
		A02.SRD,
		A02.RD,
		A02.RAD,
		A02.SZD,
		A02.ZD,
		A01.[AD Code],
		A01.REPORT_MONTH,
		A01.[Actual Premium],
		A01.[Expected Premium]
	FROM A AS A01 LEFT JOIN AD_STRUCTURE AS A02
	ON A01.[AD Code] = A02.[AD_Code]
	AND A01.REPORT_MONTH = A02.[ExplodedDate]
	WHERE A01.REPORT_MONTH BETWEEN DATEADD(month, -5, @varREPORT_MONTH) AND @varREPORT_MONTH
)
, B0 AS (
	SELECT
		ZD AS AD_CODE_FINAL,
		SUM([Actual Premium]) AS SUM_ACTUAL_PREMIUM,
		SUM([Expected Premium]) AS SUM_EXPECTED_PREMIUM
	FROM A0
	WHERE ZD IS NOT NULL
	GROUP BY ZD
	UNION
	SELECT
		SZD AS AD_CODE_FINAL,
		SUM([Actual Premium]) AS SUM_ACTUAL_PREMIUM,
		SUM([Expected Premium]) AS SUM_EXPECTED_PREMIUM
	FROM A0
	WHERE SZD IS NOT NULL
	GROUP BY SZD
	UNION
	SELECT
		RAD AS AD_CODE_FINAL,
		SUM([Actual Premium]) AS SUM_ACTUAL_PREMIUM,
		SUM([Expected Premium]) AS SUM_EXPECTED_PREMIUM
	FROM A0
	WHERE RAD IS NOT NULL
	GROUP BY RAD
	UNION
	SELECT
		RD AS AD_CODE_FINAL,
		SUM([Actual Premium]) AS SUM_ACTUAL_PREMIUM,
		SUM([Expected Premium]) AS SUM_EXPECTED_PREMIUM
	FROM A0
	WHERE RD IS NOT NULL
	GROUP BY RD
	UNION
	SELECT
		SRD AS AD_CODE_FINAL,
		SUM([Actual Premium]) AS SUM_ACTUAL_PREMIUM,
		SUM([Expected Premium]) AS SUM_EXPECTED_PREMIUM
	FROM A0
	WHERE SRD IS NOT NULL
	GROUP BY SRD
	UNION
	SELECT
		TD AS AD_CODE_FINAL,
		SUM([Actual Premium]) AS SUM_ACTUAL_PREMIUM,
		SUM([Expected Premium]) AS SUM_EXPECTED_PREMIUM
	FROM A0
	WHERE TD IS NOT NULL
	GROUP BY TD
)
, B1 AS (
	SELECT
		AD_CODE_FINAL,
		SUM(SUM_ACTUAL_PREMIUM) AS SUM_ACTUAL_PREMIUM,
		SUM(SUM_EXPECTED_PREMIUM) AS SUM_EXPECTED_PREMIUM
	FROM B0
	GROUP BY AD_CODE_FINAL
)
, B2 AS (
	SELECT 
		AD_CODE_FINAL,
		SUM_ACTUAL_PREMIUM,
		SUM_EXPECTED_PREMIUM,
		ROUND(CAST(SUM_ACTUAL_PREMIUM AS FLOAT) / CAST(SUM_EXPECTED_PREMIUM AS FLOAT), 4) AS PY2_RATE,
		FORMAT(CAST(@varREPORT_MONTH AS date), 'yyyyMM') AS REPORT_MONTH
	FROM B1 
)
, B3 AS (
	SELECT
		AD_CODE_FINAL,
		SUM_ACTUAL_PREMIUM,
		SUM_EXPECTED_PREMIUM,
		IIF(PY2_RATE > 1, 1, PY2_RATE) AS PY2_RATE,
		REPORT_MONTH
	FROM B2
)
--FINAL
SELECT
*
FROM B3

END;
GO


