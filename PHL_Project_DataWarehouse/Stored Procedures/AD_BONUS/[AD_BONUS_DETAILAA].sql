USE [DP_Manh]
GO

/****** Object:  StoredProcedure [dbo].[AD_BONUS_DETAILAA]    Script Date: 15/02/2023 13:19:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [dbo].[AD_BONUS_DETAILAA] (@varREPORT_MONTH nvarchar(4000)) 
AS 
BEGIN
--@varREPORT_MONTH format 'yyyy-MM-01'
WITH
PREMIUM_CO AS (
	SELECT *
	FROM [DP_Manh].[dbo].[T_DP_TAGENTPREMIUM_TEST_CUTOFF]
	WHERE [CUTOFF] = FORMAT(EOMONTH(@varREPORT_MONTH), 'yyyyMMdd')
)
, AGT_INFO_CO AS (
	SELECT *
	FROM [DP_Manh].[dbo].[T_Main_AGENT_INFO_DA_CUTOFF]
	WHERE [CUTOFF] = FORMAT(EOMONTH(@varREPORT_MONTH), 'yyyyMMdd')
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
	FROM [DP_Manh].[dbo].[T_DP_DA_Daily_DC_PO_WD_NT_CUTOFF]
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
-----------TINH ACTIVE AGENT
, A0 AS (
	SELECT 
		A01.*,
		A02.Policy_Issue_Date AS Policy_Issue_Date_FULL
	FROM PREMIUM_CO AS A01 LEFT JOIN DAILYSALES_FULL AS A02
	ON A01.[Policy No] = A02.Policy_Number
)
, A AS (
	SELECT DISTINCT
		[Issuing Agent],
		[Policy No],
		[Policy Status],
		Policy_Issue_Date_FULL,
	CASE 
	WHEN [Policy Status] = 'IF' THEN 1
	WHEN [Policy Status] IN ('FL', 'PO', 'DC', 'WD', 'NT', 'CF')
		AND ((Policy_Issue_Date_FULL NOT BETWEEN @varREPORT_MONTH AND EOMONTH(@varREPORT_MONTH)) OR Policy_Issue_Date_FULL IS NULL)
	THEN -1
	ELSE 0 END AS CountPolicy
	FROM A0
	WHERE Policy_Issue_Date_FULL BETWEEN @varREPORT_MONTH AND EOMONTH(@varREPORT_MONTH)
	OR ([Policy Status] != 'IF' AND [Collected Date] BETWEEN @varREPORT_MONTH AND EOMONTH(@varREPORT_MONTH))
)
, A1 AS (
	SELECT
		[Issuing Agent],
		SUM(CountPolicy) AS CC,
		CASE
			WHEN SUM(CountPolicy) > 0 then 1
			WHEN SUM(CountPolicy) = 0 then 0
			WHEN SUM(CountPolicy) < 0 then -1
		END AS AA
	FROM A
	GROUP BY [Issuing Agent]
)
, B AS (
	SELECT
		B01.Sales_Unit_Code,
		B01.Agent_Number,
		B01.Area_Name,
		B01.Agent_Name,
		B01.Grade,
		B01.Date_Appointed,
		B01.Agent_Status,
		B02.TERRITORY,
		B02.[TDName],
		B02.[TADName],
		B02.[SRDName],
		B02.[RDName],
		B02.[RADName],
		B02.[SZDName],
		B02.[ZDName],
		B02.[ADName],
		B02.[TD],
		B02.[TAD],
		B02.[SRD],
		B02.[RD],
		B02.[RAD],
		B02.[SZD],
		B02.[ZD],
		B02.[AD_Code]
	FROM AGT_INFO_CO AS B01 LEFT JOIN AD_STRUCTURE AS B02
	ON B01.Sales_Unit_Code = B02.[AD_Code]
)
, B2 AS (
	SELECT
		B.TERRITORY,
		B.[TDName],
		B.[TADName],
		B.[SRDName],
		B.[RDName],
		B.[RADName],
		B.[SZDName],
		B.[ZDName],
		B.[ADName],
		B.[Area_Name],
		A1.[Issuing Agent],
		B.Agent_Name,
		B.Grade,
		B.Date_Appointed,
		B.Agent_Status,
		A1.CC,
		A1.AA,
		B.[TD],
		B.[TAD],
		B.[SRD],
		B.[RD],
		B.[RAD],
		B.[SZD],
		B.[ZD],
		B.[AD_Code],
		FORMAT(CAST(@varREPORT_MONTH AS date), 'yyyyMM') AS REPORT_MONTH
	FROM A1 LEFT JOIN B ON A1.[Issuing Agent] = B.Agent_Number
)
-----------FINAL
SELECT 
	*
FROM B2
END;
GO


