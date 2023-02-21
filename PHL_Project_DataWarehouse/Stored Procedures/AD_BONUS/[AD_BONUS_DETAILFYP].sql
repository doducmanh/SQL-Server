USE [DP_Manh]
GO

/****** Object:  StoredProcedure [dbo].[AD_BONUS_DETAILFYP]    Script Date: 16/01/2023 15:26:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[AD_BONUS_DETAILFYP] (@varREPORT_MONTH nvarchar(4000)) 
AS 
BEGIN
--@varREPORT_MONTH format 'yyyy-MM-01'
WITH
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
, CUSTOMER_INFO_CO AS (
	SELECT *
	FROM [dbo].[T_Main_CUSTOMER_INFO_CUTOFF]
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

--LAY DANH SACH SFC ----------------
,B AS (
	SELECT DISTINCT
		[Policy No],
		[Issuing Agent],
		[Policy Status],
		[Issued Date]
	FROM PREMIUM_CUTOFF
	WHERE [Policy Status] = 'IF'
)
, B2 AS (
	SELECT
		*,
		LEAD([Issued Date]) OVER (PARTITION BY [Issuing Agent] ORDER BY [Issued Date]) AS Next_Issued_Date
	FROM B
)
, B3 AS (
	SELECT B31.*
	,B32.[Area_Name]
	,B32.[Agent_Name]
	,B32.[Grade] AS SA_Grade
	,B32.[Sales_Unit_Code]
	  ,B32.Date_Appointed AS SA_Appointed
	  ,B32.[Appointed_TAPSU] AS SA_Appointed_TAPSU
	  ,B32.[Terminated_date] AS SA_Terminated_date
	  ,B32.[ID_Card] AS SA_ID_Card
	  ,B32.[Agent_Status]
	  ,B2.[Issued Date] AS SA_Last_Issued_Date
	  ,B2.[Next_Issued_Date] AS SA_Next_Issued_Date

	  ----RULE DUNG CHUAN THEO NGAY
	  --,IIF((
	  --(B2.[Issued Date] IS NOT NULL AND (
	  --IIF(B31.[Collected Date] >='2021-12-01', 
			--IIF(DATEADD(month, 9, IIF(B32.Date_Appointed > B2.[Issued Date], B32.Date_Appointed,B2.[Issued Date])) < B31.[Collected Date], 1, 0), 
			--IIF(DATEADD(month, 6, IIF(B32.Date_Appointed > B2.[Issued Date], B32.Date_Appointed,B2.[Issued Date])) < B31.[Collected Date], 1, 0)
		 --) = 1
			--							)) 
   --OR (B2.[Issued Date] IS NULL AND (
	  --IIF(B31.[Collected Date] >='2021-12-01', 
			--IIF(DATEADD(MONTH, 9, B32.Date_Appointed) < B31.[Collected Date], 1, 0), 
			--IIF(DATEADD(MONTH, 6, B32.Date_Appointed) < B31.[Collected Date], 1, 0)
		 --) = 1
			--						)))
	  --AND B31.[Collected Date] >='2021-01-01' 
	  --AND B33.GRADE = 'IC'
	  --AND (IIF(B31.[Collected Date] >='2021-12-01', 
			--	IIF(DATEADD(MONTH, 9, B31.[Issued Date]) < B31.[Collected Date], 1, 0), 
			--	IIF(DATEADD(MONTH, 6, B31.[Issued Date]) < B31.[Collected Date], 1, 0)
			-- ) = 1)
	  --AND EOMONTH(IIF(B2.[Next_Issued_Date] IS NULL, '2099-12-31',B2.[Next_Issued_Date])) <> EOMONTH(B31.[Collected Date])
	  --, 'S','' ) AS SFC

	  --RULE DUNG THEO BAO CAO TEAM PHUONG
	  ,IIF(((B2.[Issued Date] IS NOT NULL 
	  AND DATEDIFF(MONTH,
	  IIF(B32.Date_Appointed > B2.[Issued Date], B32.Date_Appointed,B2.[Issued Date]),B31.[Collected Date]) > IIF(B31.[Collected Date] >='2021-12-01',9,6 ))  
	      OR (B2.[Issued Date] IS NULL AND DATEDIFF(MONTH, B32.Date_Appointed, B31.[Collected Date]) > IIF(B31.[Collected Date] >='2021-12-01',9,6 )) ) 
	  AND B31.[Collected Date] >='2021-01-01' 
	  AND B33.GRADE = 'IC'
	  AND DATEDIFF(MONTH,B31.[Issued Date], B31.[Collected Date]) > IIF(B31.[Collected Date] >='2021-12-01',9,6 )
	  AND EOMONTH(IIF(B2.[Next_Issued_Date] IS NULL, '2099-12-31',B2.[Next_Issued_Date])) <> EOMONTH(B31.[Collected Date])
	  , 'S','' ) AS SFC

	FROM PREMIUM_CUTOFF AS B31
	LEFT JOIN AGENT_INFO_CUTOFF AS B32
	ON B31.[Servicing Agent] = B32.Agent_Number

	LEFT JOIN B2
	ON B31.[Servicing Agent] = B2.[Issuing Agent]
	AND B31.[Collected Date] >= B2.[Issued Date]
	AND B31.[Collected Date] < IIF(B2.[Next_Issued_Date] IS NULL, '2099-12-31',B2.[Next_Issued_Date])

	LEFT JOIN AGENT_HISTORY_CUTOFF AS B33
	ON B31.[Servicing Agent] = B33.[AGENT CODE]
	AND B31.[Collected Date] >= B33.CURRFROM
	AND B31.[Collected Date] < IIF(B33.CURRTO IS NULL, '2099-12-31',B33.CURRTO)
)
--LAY FYP --------------------
, C00 AS (
	SELECT 
		[Area_Name],
		[Sales_Unit_Code],
		[Servicing Agent],
		[Agent_Name] AS SA_NAME,
		[Agent_Status] AS SA_STATUS,
		SA_Grade,
		SA_Appointed,
		SA_Appointed_TAPSU,
		SA_Terminated_date,
		SA_ID_Card,
		[Policy No],
		[Policy Status],
		[Issued Date],
		[Proposal Receive Date],
		[Collected Date],
		SUM([FYP]) AS FYP,
		SUM(0.1*[Topup Premium]) AS [10% TOPUP 1],
		SUM([FYP]) + SUM(0.1*[Topup Premium]) AS FYPincTopup1
	FROM B3
	WHERE [Collected Date] BETWEEN @varREPORT_MONTH AND EOMONTH(@varREPORT_MONTH)
	AND SFC <> 'S'
	AND [Servicing Agent] NOT LIKE '6999%'
	GROUP BY [Area_Name], [Sales_Unit_Code], [Servicing Agent], [Agent_Name], [Agent_Status], SA_Grade, 
	SA_Appointed, SA_Appointed_TAPSU, SA_Terminated_date, SA_ID_Card, [Policy No], [Policy Status], 
	[Issued Date], [Proposal Receive Date], [Collected Date]
)
, C AS (
	SELECT
		C011.[Area_Name],
		C011.[Sales_Unit_Code],
		C011.[Servicing Agent],
		C011.SA_NAME,
		C011.SA_STATUS,
		C011.SA_Grade,
		C011.SA_Appointed,
		C011.SA_Appointed_TAPSU,
		C011.SA_Terminated_date,
		C011.SA_ID_Card,
		C011.[Policy No],
		C011.[Policy Status],
		C011.[Issued Date],
		C011.[Proposal Receive Date],
		C011.[Collected Date],
		C011.FYP,
		IIF(C012.[Topup Revised] IS NULL, C011.[10% TOPUP 1], C012.[Topup Revised] * 0.1) AS [10% TOPUP],
		C011.FYPincTopup1,
		(C011.FYPincTopup1 + ISNULL(C012.[FYP_Difference], 0)) AS FYPincTopup
	FROM C00 AS C011 LEFT JOIN TOPUP_REVISE AS C012
	ON C011.[Policy No] = C012.[Policy No]
	AND C011.[Servicing Agent] = C012.[Servicing Agent]
	AND C011.Sales_Unit_Code = C012.AD_CODE
)
, C2 AS (
	SELECT
		[AD Code] AS AGT_AD_CODE,
		[ID Number],
		'' AS [CUS_Area_Name],
		C22.[Appointed_Date],
		C22.[Terminated_Date] AS [CUS_Terminated_Date]
	FROM [SQL_SV64].[PowerBI].[DPO].[AD Info] AS C21
	LEFT JOIN AD_STRUCTURE AS C22
	ON C21.[AD Code] = C22.[AD_Code]
	WHERE C21.[ID Number] <> ''
)
, C3 AS (
	SELECT
		[Agent_Number],
		[ID_Card],
		[Area_Name],
		[Appointed_TAPSU],
		[Terminated_date]
	FROM AGENT_INFO_CUTOFF AS C31
	LEFT JOIN C2 ON C31.[ID_Card] = C2.[ID Number]
	WHERE C2.[ID Number] IS NULL
)
, C4 AS (
	SELECT
		AGT_AD_CODE,
		[ID Number],
		[CUS_Area_Name],
		[Appointed_Date],
		[CUS_Terminated_Date]
	FROM C2
	UNION
	SELECT
		[Agent_Number],
		[ID_Card],
		[Area_Name],
		[Appointed_TAPSU],
		[Terminated_date]
	FROM C3
)

, C5 AS (
	SELECT
	C.*,
	CUSTOMER_INFO_CO.[ID_NUMBER] AS CUS_ID,
	CASE
		WHEN CUSTOMER_INFO_CO.[ID_NUMBER] = C.SA_ID_Card THEN 'SELF_OWNER'
		WHEN CUSTOMER_INFO_CO.[ID_NUMBER] IN (SELECT [ID Number] FROM C4) 
				AND C.[Servicing Agent] NOT LIKE '6999%'
				AND C.SA_NAME NOT LIKE 'DUMMY%'
				AND C4.[ID Number] NOT LIKE 'DUMMY%'
				AND C4.AGT_AD_CODE NOT LIKE '6999%'
				AND C4.[CUS_Area_Name] <> 'SEP'
				AND C4.[Appointed_Date] <= C.[Proposal Receive Date]
				AND C4.[CUS_Terminated_Date] IS NULL
				--AND IIF(C4.[CUS_Terminated_Date] IS NULL, '2099-12-31', C4.[CUS_Terminated_Date]) >= C.[Issued Date]
		THEN 'CROSS_SALES'
		ELSE 'CUSTOMER'
	END AS 'CROSS SALE'
	FROM C LEFT JOIN CUSTOMER_INFO_CO
	ON C.[Policy No] = CUSTOMER_INFO_CO.[POLICY_CODE]
	LEFT JOIN C4
	ON CUSTOMER_INFO_CO.[ID_NUMBER] = C4.[ID Number]
)
, C6 AS (
	SELECT
		C61.[TERRITORY],
		C61.[TDName],
		C61.[TADName],
		C61.[SRDName],
		C61.[RDName],
		C61.[RADName],
		C61.[SZDName],
		C61.[ZDName],
		C61.[ADName],
		C5.[Area_Name],
		C5.[Servicing Agent],
		C5.SA_NAME,
		C5.SA_Grade,
		C5.SA_Appointed,
		C5.SA_STATUS,
		C5.[Policy No],
		C5.[Policy Status],
		C5.[Issued Date],
		C5.[Collected Date],
		C5.FYP AS FYP_NOT_TOPUP,
		C5.[10% TOPUP],
		C5.FYPincTopup,
		CASE
			WHEN C5.[CROSS SALE] = 'CROSS_SALES' THEN 0
			WHEN C5.[Policy Status] IN ('LA', 'TR', 'SU') THEN 0
			ELSE C5.FYPincTopup
		END AS FYP_COUNT_BONUS,
		C5.[CROSS SALE],
		C61.[TD],
		C61.[TAD],
		C61.[SRD],
		C61.[RD],
		C61.[RAD],
		C61.[SZD],
		C61.[ZD],
		C61.[AD_Code],
		FORMAT(CAST(@varREPORT_MONTH AS date), 'yyyyMM') AS REPORT_MONTH
	FROM C5 LEFT JOIN AD_STRUCTURE AS C61
	ON C5.[Sales_Unit_Code] = C61.[AD_Code]
)

-------FINAL---------
SELECT *
FROM C6
END;
GO


