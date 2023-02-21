USE [DP_Manh]
GO

/****** Object:  StoredProcedure [dbo].[AD_BONUS_DETAILRYP]    Script Date: 12/01/2023 13:44:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[AD_BONUS_DETAILRYP] (@varREPORT_MONTH nvarchar(4000)) 
AS 
BEGIN
--chạy mỗi tháng
--@varREPORT_MONTH template 'yyyy-MM-01'
WITH
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

--COMBINE PREMIUM & AGENTINFOR ----------------
, B AS (
	SELECT
		B02.Area_Name,
		B02.Sales_Unit_Code,
		B02.Agent_Name AS SA_NAME,
		B02.Agent_Status AS SA_STATUS,
		B02.Grade AS SA_Grade,
		B02.Date_Appointed AS SA_Appointed,
		B02.Appointed_TAPSU AS SA_Appointed_TAPSU,
		B02.Terminated_date AS SA_Terminated_date,
		B02.ID_Card AS SA_ID_Card,
		B01.*
	FROM PREMIUM_CUTOFF AS B01 LEFT JOIN AGENT_INFO_CUTOFF AS B02
	ON B01.[Servicing Agent] = B02.Agent_Number
)

--LAY RYP --------------------
, C AS (
	SELECT 
		[Area_Name],
		[Sales_Unit_Code],
		[Servicing Agent],
		SA_NAME,
		SA_STATUS,
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
		SUM(RYP) AS RYP
	FROM B
	WHERE [Collected Date] BETWEEN @varREPORT_MONTH AND EOMONTH(@varREPORT_MONTH)
	AND [Servicing Agent] NOT LIKE '6999%'
	GROUP BY [Area_Name], [Sales_Unit_Code], [Servicing Agent], SA_NAME, SA_STATUS, SA_Grade,
		SA_Appointed, SA_Appointed_TAPSU, SA_Terminated_date, SA_ID_Card, [Policy No], [Policy Status],
		[Issued Date], [Proposal Receive Date], [Collected Date]
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
		C5.RYP,
		CASE
			WHEN C5.[CROSS SALE] = 'CROSS_SALES' THEN 0
			WHEN C5.[Policy Status] IN ('LA', 'TR', 'SU') THEN 0
			ELSE C5.RYP
		END AS RYP_COUNT_BONUS,
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


