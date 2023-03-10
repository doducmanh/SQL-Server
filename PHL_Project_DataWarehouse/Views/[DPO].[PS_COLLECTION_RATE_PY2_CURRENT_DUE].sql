USE [PowerBI]
GO

/****** Object:  View [DPO].[PS_COLLECTION_RATE_PY2_CURRENT_DUE]    Script Date: 30/09/2022 16:35:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [DPO].[PS_COLLECTION_RATE_PY2_CURRENT_DUE] AS
WITH A AS (
	--SELECT 
	--	m1.[AREA],
	--	m1.[Sales_Unit_Code],
	--	m1.[SALES_UNIT],
	--	m1.[CONTRACT_NUMBER],
	--	m1.RISK_COMMENCE_DATE,
	--	m1.[PAID TO DATE],
	--	( SELECT MAX(m2.[PAID TO DATE])
	--		FROM [PowerBI].[DPO].[PS_CONTRACT_PC_POLICY2_DW] AS m2
	--		WHERE m2.[CONTRACT_NUMBER] = m1.[CONTRACT_NUMBER]
	--		AND m2.[PAID TO DATE] < m1.[PAID TO DATE] 
	--	) AS CURRENT_DUE_DATE,
	--	m1.INSTALL_PREMIUM,
	--	m1.POL_YEAR,
	--	m1.[CURRENT_POLICY_STATUS],
	--	m1.[CLM_NOTE]
	--FROM [PowerBI].[DPO].[PS_CONTRACT_PC_POLICY2] AS m1
	SELECT 
		[AREA],
		[Sales_Unit_Code],
		[SALES_UNIT],
		[CONTRACT_NUMBER],
		RISK_COMMENCE_DATE,
		[PAID TO DATE],
		[FREQUENCY],
		CASE
			WHEN [FREQUENCY] = 'Yearly' THEN DATEADD(m, (FLOOR(DATEDIFF(m, RISK_COMMENCE_DATE, GETDATE()))/12)*12, RISK_COMMENCE_DATE)
			WHEN [FREQUENCY] = 'Half-Yearly' THEN DATEADD(m, (FLOOR(DATEDIFF(m, RISK_COMMENCE_DATE, GETDATE()))/6)*6, RISK_COMMENCE_DATE)
			WHEN [FREQUENCY] = 'Quarterly' THEN DATEADD(m, (FLOOR(DATEDIFF(m, RISK_COMMENCE_DATE, GETDATE()))/3)*3, RISK_COMMENCE_DATE)
			WHEN [FREQUENCY] = 'Monthly' THEN DATEADD(m, (FLOOR(DATEDIFF(m, RISK_COMMENCE_DATE, GETDATE()))/1)*1, RISK_COMMENCE_DATE)
		END AS CURRENT_DUE_DATE,
		POL_YEAR,
		INSTALL_PREMIUM,
		[CURRENT_POLICY_STATUS],
		[CLM_NOTE]
	FROM [PowerBI].[DPO].[PS_CONTRACT_PC_POLICY2]
)
, B AS (
	SELECT
		CONTRACT_NUMBER,
		[PAID TO DATE],
		INSTALL_PREMIUM,
		[CURRENT_POLICY_STATUS],
		EXPLODED_DATE,
		ROW_NUMBER() OVER (PARTITION BY CONTRACT_NUMBER, [PAID TO DATE] ORDER BY EXPLODED_DATE) AS IDROW
	FROM [PowerBI].[DPO].[PS_CONTRACT_PC_POLICY2_DW]
)
, C AS (
	SELECT 
		CONTRACT_NUMBER,
		[PAID TO DATE],
		INSTALL_PREMIUM,
		[CURRENT_POLICY_STATUS],
		EXPLODED_DATE
	FROM B
	WHERE IDROW = 1
)

, D AS (
	SELECT
      [RDOCNUM]
      ,SUM([PREMIUM_APPLIED]) AS COLLECTED_PREMIUM_DP
	FROM [PowerBI].[DPO].[PS_PREMIUM] AS D1 LEFT JOIN A 
	ON  D1.RDOCNUM = A.CONTRACT_NUMBER
	WHERE D1.[BATCTRCDE] IN ('B522', 'B536', 'T679', 'T656', 'T659')
	AND D1.COLLECTED_DATE BETWEEN /*CONCAT(YEAR(A.CURRENT_DUE_DATE), FORMAT(MONTH(A.CURRENT_DUE_DATE) - 1, '00'), '15')*/
								FORMAT(DATEADD(d, -15, A.CURRENT_DUE_DATE), 'yyyyMMdd')	
							AND FORMAT(EOMONTH(A.CURRENT_DUE_DATE, 2), 'yyyyMMdd')
	AND D1.EFFECTIVE_DATE >= FORMAT(A.CURRENT_DUE_DATE, 'yyyyMMdd')
	GROUP BY [RDOCNUM], A.CURRENT_DUE_DATE
)
, E AS (
	SELECT DISTINCT
		A.*,
		IIF(A.[CURRENT_DUE_DATE] BETWEEN DATEADD(m, -2, DATEADD(DAY, 1, EOMONTH(GETDATE(), -1)))
								  AND EOMONTH(GETDATE()),1,0) AS IS_REPORT_CURRENT_DUE_DATE,
		FLOOR(DATEDIFF(m, A.RISK_COMMENCE_DATE, A.CURRENT_DUE_DATE)/12) + 1 AS POL_YEAR_DP,
		IIF(C.INSTALL_PREMIUM IS NULL, A.INSTALL_PREMIUM, C.INSTALL_PREMIUM)  AS ORIGINAL_PRE,
		IIF(C.CURRENT_POLICY_STATUS IS NULL, A.CURRENT_POLICY_STATUS, C.CURRENT_POLICY_STATUS) AS ORIGINAL_STATUS
	FROM A LEFT JOIN C
	ON A.CONTRACT_NUMBER = C.CONTRACT_NUMBER
	AND A.CURRENT_DUE_DATE = C.[PAID TO DATE]
)

SELECT 
	E.*
	,D.COLLECTED_PREMIUM_DP
FROM E LEFT JOIN D
ON E.CONTRACT_NUMBER = D.RDOCNUM
--WHERE E.POL_YEAR_DP = 2

	
GO


