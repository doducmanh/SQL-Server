USE [DP_Manh]
GO

/****** Object:  StoredProcedure [dbo].[TOP_OFFICE_LEADER]    Script Date: 15/02/2023 13:21:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[TOP_OFFICE_LEADER] (@varREPORT_MONTH nvarchar(4000)) 
AS 
BEGIN
----TEMPLATE @varREPORT_MONTH 'yyyy-MM-01'
----PREPARE DATA SOURCE
WITH AGT_INFO_CO AS (
	SELECT *
	FROM T_Main_AGENT_INFO_DA_CUTOFF
	WHERE CUTOFF = FORMAT(EOMONTH(@varREPORT_MONTH), 'yyyyMMdd')
)
, PREMIUM_CO AS (
	SELECT *
	FROM [DP_Manh].[dbo].[T_DP_TAGENTPREMIUM_TEST_CUTOFF]
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
, AGENCY_STRUCTURE AS (
	SELECT *
	FROM [SQL_SV65].[PowerBI].[DPO].[Main_AGENCY_STRUCTURE]
	WHERE [ExplodedDate] = FORMAT(CAST(@varREPORT_MONTH AS date), 'yyyyMM')
)
----LAY DANH SACH LEADER AND FC DIRECT
, A AS (
	SELECT 
	   [FM] AS LEADER_AGT_NUM
      ,[Agent_Number]
      ,[Agent_Name]
      ,[GRADE]
	  ,[Date_Appointed]
	FROM AGENCY_STRUCTURE
	WHERE [FM] IS NOT NULL
	UNION
	SELECT 
       [DM]
      ,[Agent_Number]
      ,[Agent_Name]
      ,[GRADE]
	  ,[Date_Appointed]
	FROM AGENCY_STRUCTURE
	WHERE [FM] IS NULL
	AND [DM] IS NOT NULL
	UNION
	SELECT 
       [RM]
      ,[Agent_Number]
      ,[Agent_Name]
      ,[GRADE]
	  ,[Date_Appointed]
	FROM AGENCY_STRUCTURE
	WHERE [FM] IS NULL
	AND [DM] IS NULL
	AND [RM] IS NOT NULL
	UNION
	SELECT 
       [GM]
      ,[Agent_Number]
      ,[Agent_Name]
      ,[GRADE]
	  ,[Date_Appointed]
	FROM AGENCY_STRUCTURE
	WHERE [FM] IS NULL
	AND [DM] IS NULL
	AND [RM] IS NULL
	AND [GM] IS NOT NULL
)
, A1 AS (
	SELECT
		A11.LEADER_AGT_NUM,
		A11.[Agent_Number],
		A11.[Agent_Name],
		A11.[GRADE],
		A11.[Date_Appointed],
		A12.Agent_Status,
		A12.Appointed_TAPSU
	FROM A AS A11 LEFT JOIN AGT_INFO_CO AS A12
	ON A11.[Agent_Number] = A12.Agent_Number
)
----TINH FYP
, B AS (
	SELECT
		[Servicing Agent],
		SUM([FYP]) + SUM(0.1*[Topup Premium]) AS FYPincTopup
	FROM PREMIUM_CO
	WHERE [Collected Date] BETWEEN @varREPORT_MONTH AND EOMONTH(@varREPORT_MONTH)
	GROUP BY [Servicing Agent]
)
----TINH CC
, C0 AS (
	SELECT 
		C01.*,
		C02.Policy_Issue_Date AS Policy_Issue_Date_FULL
	FROM PREMIUM_CO AS C01 LEFT JOIN DAILYSALES_FULL AS C02
	ON C01.[Policy No] = C02.Policy_Number
)
, C AS (
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
	FROM C0
	WHERE Policy_Issue_Date_FULL BETWEEN @varREPORT_MONTH AND EOMONTH(@varREPORT_MONTH)
	OR ([Policy Status] != 'IF' AND [Collected Date] BETWEEN @varREPORT_MONTH AND EOMONTH(@varREPORT_MONTH))
)
, C1 AS (
	SELECT
	[Issuing Agent],
	SUM(CountPolicy) AS CC,
	CASE
		WHEN SUM(CountPolicy) > 0 THEN 1
		WHEN SUM(CountPolicy) = 0 THEN 0
		WHEN SUM(CountPolicy) < 0 THEN 0
	END AS AA
	FROM C
	GROUP BY [Issuing Agent]
)
----KET QUA
, D AS (
	SELECT 
		D1.LEADER_AGT_NUM,
		SUM(D2.FYPincTopup) AS FYPincTOPUP,
		SUM(D3.CC) AS ALCaseCount,
		SUM(D3.AA) AS ALActiveAgent,
		SUM(
			CASE 
				WHEN D1.Appointed_TAPSU BETWEEN @varREPORT_MONTH AND EOMONTH(@varREPORT_MONTH)
				AND D1.LEADER_AGT_NUM <> D1.Agent_Number THEN 1
				ELSE 0
			END
		) AS ALRecruitDirectFC
	FROM A1 AS D1 LEFT JOIN B AS D2 ON D1.[Agent_Number] = D2.[Servicing Agent]
	LEFT JOIN C1 AS D3 ON D1.[Agent_Number] = D3.[Issuing Agent]
	GROUP BY LEADER_AGT_NUM
)

, D2 AS (
	SELECT
		D21.Area_Name,
		D21.Sales_Unit_Code,
		D21.Sales_Unit,
		D21.Agent_Number,
		D21.Agent_Name,
		D21.Grade,
		D21.Agent_Status,
		D21.Date_Appointed,
		D22.FYPincTOPUP,
		D22.ALCaseCount,
		D22.ALActiveAgent,
		D22.ALRecruitDirectFC
	FROM AGT_INFO_CO AS D21 LEFT JOIN D AS D22
	ON D21.Agent_Number = D22.LEADER_AGT_NUM
	WHERE D21.Agent_Name NOT LIKE 'DUMMY%'
	AND D21.[Grade] IN ('FM', 'DM', 'RM', 'GM')
	AND D21.Agent_Status = 'ENFORCE'
)

--, D3 AS (
	SELECT
		D32.TERRITORY,
		D32.[TD],
		D32.[TDName],
		D32.[TAD],
		D32.[TADName],
		D32.[SRD],
		D32.[SRDName],
		D32.[RD],
		D32.[RDName],
		D31.Area_Name,
		D31.Sales_Unit_Code,
		D31.Sales_Unit,
		D31.Agent_Number,
		D31.Agent_Name,
		D31.Grade,
		D31.Agent_Status,
		D31.Date_Appointed,
		D31.FYPincTOPUP,
		D31.ALCaseCount,
		D31.ALActiveAgent,
		D31.ALRecruitDirectFC
	FROM D2 AS D31 LEFT JOIN AD_STRUCTURE AS D32
	ON D31.Sales_Unit_Code = D32.[AD_Code]
--)

END;
GO


