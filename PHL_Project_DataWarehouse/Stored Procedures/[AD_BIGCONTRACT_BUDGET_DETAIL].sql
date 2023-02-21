USE [DP_Manh]
GO

/****** Object:  StoredProcedure [dbo].[AD_BIGCONTRACT_BUDGET_DETAIL]    Script Date: 21/02/2023 09:38:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [dbo].[AD_BIGCONTRACT_BUDGET_DETAIL] (@varREPORT_MONTH nvarchar(4000)) 
--format @varREPORT_MONTH as 'yyyy-mm-01'
AS 
BEGIN
----PREPARE DATA
WITH AGENT_INFO_CUTOFF AS (
	SELECT *
	FROM [dbo].[T_Main_AGENT_INFO_DA_CUTOFF]
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
, AGENCY_STRUCTURE AS (
	SELECT
		*
	FROM [SQL_SV65].[PowerBI].[DPO].[Main_AGENCY_STRUCTURE]
	WHERE [ExplodedDate]  = FORMAT(CAST(@varREPORT_MONTH AS date), 'yyyyMM')
)
, DAILYSALES_FULL AS (
	SELECT 
		[Agent Code]
      ,[Policy_Number]
      ,[Issuing_Agent]
      ,[Contract Type]
      ,[Component_Code]
      ,[Proposal_Receive_Date]
      ,[Policy_Issue_Date]
      ,[Sum_Assured]
      ,[Before_Discount_Premium]
      ,[Discount_Premium]
      ,[After_Discount_Premium]
      ,[Policy_Status]
      ,[Bill_Frequency]
      ,[Modal_Factor]
      ,[Lapsed_date]
      ,[AFYP]
      ,[RISK_COMMENCE_DATE]
      ,[CUTOFF]
	  ,[ACK_DATE]
	FROM [DP_Manh].[dbo].[T_DP_TDAILYSALES_DA_CUTOFF]
	WHERE [CUTOFF] = FORMAT(EOMONTH(@varREPORT_MONTH), 'yyyyMMdd')
	UNION ALL
	SELECT
		[Agent Code]
      ,[Policy_Number]
      ,[Issuing_Agent]
      ,[Contract Type]
      ,[Component_Code]
      ,[Proposal_Receive_Date]
      ,[Policy_Issue_Date]
      ,[Sum_Assured]
      ,[Before_Discount_Premium]
      ,[Discount_Premium]
      ,[After_Discount_Premium]
      ,[Policy_Status]
      ,[Bill_Frequency]
      ,[Modal_Factor]
      ,[Lapsed_date]
      ,[AFYP]
      ,[RISK_COMMENCE_DATE]
      ,[CUTOFF]
	  ,[ACK_DATE]
	FROM [DP_Manh].[dbo].[T_DP_DA_Daily_DC_PO_WD_NT_CUTOFF]
	WHERE [CUTOFF] = FORMAT(EOMONTH(@varREPORT_MONTH), 'yyyyMMdd')
)
, CUSTOMER_INFO_CO AS (
	SELECT *
	FROM [dbo].[T_Main_CUSTOMER_INFO_CUTOFF]
	WHERE [CUTOFF] = FORMAT(EOMONTH(@varREPORT_MONTH), 'yyyyMMdd')
)
, AGPOLTRANSFER_CO AS (
	SELECT *
	FROM [dbo].[T_DP_AGPOLTRANSFER_CUTOFF]
	WHERE [CUTOFF] = FORMAT(EOMONTH(@varREPORT_MONTH), 'yyyyMMdd')
)
, PREMIUM_CUTOFF AS (
	SELECT *
	FROM [dbo].[T_DP_TAGENTPREMIUM_TEST_CUTOFF]
	WHERE [CUTOFF] = FORMAT(EOMONTH(@varREPORT_MONTH), 'yyyyMMdd')
)
----TÍNH IP
, A AS (
	SELECT
		[Agent Code],
		[Policy_Number],
		[Contract Type],
		[Component_Code],
		[Proposal_Receive_Date],
		[Policy_Issue_Date],
		[After_Discount_Premium],
		IIF([Component_Code] = 'UL81', [After_Discount_Premium] * 0.1, [After_Discount_Premium]) AS [After_Discount_Premium_REVISED],
		[Policy_Status],
		[ACK_DATE]
	FROM DAILYSALES_FULL
	WHERE [Policy_Issue_Date] BETWEEN @varREPORT_MONTH AND EOMONTH(@varREPORT_MONTH)
	AND [Contract Type] NOT IN ('UL3', 'UL4')
	AND [Policy_Status] = 'IF'
)
, A1 AS (
	SELECT
		[Agent Code],
		[Policy_Number],
		[Contract Type],
		[Proposal_Receive_Date],
		[Policy_Issue_Date],
		SUM([After_Discount_Premium]) AS IP_PREMIUM,
		SUM([After_Discount_Premium_REVISED]) AS IP_PREMIUM_COUNT_BONUS,
		[Policy_Status],
		[ACK_DATE]
	FROM A
	GROUP BY [Agent Code], [Policy_Number], [Contract Type],
		[Proposal_Receive_Date], [Policy_Issue_Date],[Policy_Status],[ACK_DATE]
)
, A2 AS (
	SELECT
		A22.Area_Name,
		A22.Sales_Unit_Code,
		A21.[Agent Code],
		A22.Agent_Name,
		A22.Grade,
		A22.Appointed_TAPSU,
		A22.SFC,
		A22.ID_Card AS SA_ID_Card,
		A21.[Policy_Number],
		A21.[Contract Type],
		A21.[Proposal_Receive_Date],
		A21.[Policy_Issue_Date],
		A21.IP_PREMIUM,
		A21.IP_PREMIUM_COUNT_BONUS,
		A21.[Policy_Status],
		A21.[ACK_DATE]
	FROM A1 AS A21 LEFT JOIN AGENT_INFO_CUTOFF AS A22
	ON A21.[Agent Code] = A22.Agent_Number
	--WHERE A21.IP_PREMIUM >= 40000000
)
--CHECK CROSS SALE
, B AS (
	SELECT
		[Agent_Number],
		[ID_Card],
		[Area_Name] AS [CUS_Area_Name],
		[Appointed_TAPSU] AS [Appointed_Date],
		[Terminated_date] AS [CUS_Terminated_Date]
	FROM AGENT_INFO_CUTOFF
)
, B1 AS (
	SELECT
		B11.*,
		B12.ID_NUMBER AS CUS_ID,
		CASE
			WHEN B12.[ID_NUMBER] = B11.SA_ID_Card THEN 'SELF_OWNER'
			WHEN B12.[ID_NUMBER] IN (SELECT [ID_Card] FROM B) 
					AND B11.[Agent Code] NOT LIKE '6999%'
					AND B11.Agent_Name NOT LIKE 'DUMMY%'
					AND B13.[ID_Card] NOT LIKE 'DUMMY%'
					AND B13.[Agent_Number] NOT LIKE '6999%'
					AND B13.[CUS_Area_Name] <> 'SEP'
					AND B13.[Appointed_Date] <= B11.[Proposal_Receive_Date]
					AND B13.[CUS_Terminated_Date] IS NULL
			THEN 'CROSS_SALES'
			ELSE 'CUSTOMER'
		END AS 'CROSS SALE'
	FROM A2 AS B11 LEFT JOIN CUSTOMER_INFO_CO AS B12
	ON B11.Policy_Number = B12.POLICY_CODE
	LEFT JOIN B AS B13 
	ON B12.[ID_NUMBER] = B13.ID_Card
)
--CHECK HD CHUYỂN GIAO
, C AS (
	SELECT
		[Agent_Number],
		Date_Appointed,
		Appointed_TAPSU
	FROM AGENT_INFO_CUTOFF
	WHERE Date_Appointed <> Appointed_TAPSU
)
, C1 AS (
	SELECT
		C11.CHDRNUM,
		C11.[Old Agent],
		C11.[Old Agent Effect From ],
		C11.[Current Agent],
		C11.[Current Agent Effect From],
		C12.Agent_Number,
		C12.Date_Appointed
	FROM AGPOLTRANSFER_CO AS C11 LEFT JOIN C AS C12
	ON C11.[Current Agent] = C12.Agent_Number
	WHERE C12.Agent_Number IS NULL
	OR (C12.Date_Appointed < C11.[Old Agent Effect From ])
)
----
, D AS (
	SELECT
		D01.*,
		CASE
			WHEN D02.CHDRNUM IS NOT NULL THEN 0
			WHEN D01.[CROSS SALE] = 'CROSS_SALES' THEN 0
			ELSE D01.IP_PREMIUM_COUNT_BONUS
		END AS IP_COUNT_BONUS_FINAL,
		(IIF(D01.IP_PREMIUM <> D01.IP_PREMIUM_COUNT_BONUS, 'PHU_HUNG_DAI_PHUC_LUA_CHON_1','')) AS PO_UL81,
		D02.CHDRNUM,
		D02.[Current Agent Effect From],
		IIF(D02.CHDRNUM IS NOT NULL, 'PO_TRANSFER', D02.CHDRNUM) AS TRANSFER_PO
	FROM B1 AS D01 LEFT JOIN C1 AS D02
	ON D01.Policy_Number = D02.CHDRNUM
)
, D1 AS (
	SELECT DISTINCT
		[Policy No],
		[Freelook]
	FROM PREMIUM_CUTOFF
)
, D2 AS (
	SELECT
		Area_Name,
		Sales_Unit_Code,
		[Agent Code],
		Agent_Name,
		Grade,
		Appointed_TAPSU,
		--SFC,
		Policy_Number,
		[Contract Type],
		Proposal_Receive_Date,
		Policy_Issue_Date,
		IP_PREMIUM,
		IP_COUNT_BONUS_FINAL,
		CASE
			WHEN IP_COUNT_BONUS_FINAL >= 100000000 THEN 2000000
			WHEN IP_COUNT_BONUS_FINAL >= 40000000 THEN 1000000
			ELSE 0
		END AS BONUS,
		Policy_Status,
		CASE
			WHEN TRANSFER_PO IS NOT NULL THEN TRANSFER_PO
			WHEN [CROSS SALE] = 'CROSS_SALES' THEN [CROSS SALE]
			WHEN PO_UL81 = 'PHU_HUNG_DAI_PHUC_LUA_CHON_1' THEN PO_UL81
			ELSE [CROSS SALE]
		END AS PO_TYPE,
		([Current Agent Effect From]) AS PO_TRANSFER_DATE,
		ACK_DATE,
		D22.Freelook AS DATES_OF_FREELOOK
	FROM D AS D21 LEFT JOIN D1 AS D22
	ON D21.Policy_Number = D22.[Policy No]
)
--JOIN AGENCY - AD STRUCTURE
--, E AS (
	SELECT
		E03.TERRITORY,
		E03.[TD],
		E03.[TDName],
		E03.[TAD],
		E03.[TADName],
		E03.[SRD],
		E03.[SRDName],
		E03.[RD],
		E03.[RDName],
		E03.[RAD],
		E03.[RADName],
		E03.[SZD],
		E03.[SZDName],
		E03.[AD_Code],
		E03.[ADName],
		E03.[AD_Grade],
		E02.[GM],
		E02.[GM_Agent_Name],
		E02.[RM],
		E02.[RM_Agent_Name],
		E02.[DM],
		E02.[DM_Agent_Name],
		E02.[FM],
		E02.[FM_Agent_Name],
		E01.Area_Name,
		E01.[Agent Code],
		E01.Agent_Name,
		E01.Grade,
		E01.Appointed_TAPSU,
		--SFC,
		E01.Policy_Number,
		E01.[Contract Type],
		E01.Proposal_Receive_Date,
		E01.Policy_Issue_Date,
		E01.IP_PREMIUM,
		E01.IP_COUNT_BONUS_FINAL,
		E01.BONUS,
		E01.Policy_Status,
		E01.PO_TYPE,
		E01.PO_TRANSFER_DATE,
		E01.ACK_DATE,
		E01.DATES_OF_FREELOOK,
		FORMAT(CAST(@varREPORT_MONTH AS date), 'yyyyMM') AS REPORT_MONTH
	FROM D2 AS E01 LEFT JOIN AGENCY_STRUCTURE AS E02
	ON E01.[Agent Code] = E02.[Agent_Number]
	LEFT JOIN AD_STRUCTURE AS E03
	ON E01.Sales_Unit_Code = E03.[AD_Code]
	WHERE E01.IP_PREMIUM >= 40000000
--)


END;
GO


