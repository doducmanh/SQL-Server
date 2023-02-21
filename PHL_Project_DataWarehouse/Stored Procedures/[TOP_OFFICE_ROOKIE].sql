USE [DP_Manh]
GO

/****** Object:  StoredProcedure [dbo].[TOP_OFFICE_ROOKIE]    Script Date: 15/02/2023 13:22:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[TOP_OFFICE_ROOKIE] (@varREPORT_MONTH nvarchar(4000)) 
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
----LAY DANH SÁCH ROOKIE
, A AS (
	SELECT
		[Area_Name],
		[Sales_Unit_Code],
		[Sales_Unit],
		[Agent_Number],
		[Agent_Name],
		[Grade],
		[Agent_Status],
		[Date_Appointed],
		[License_No]
	FROM AGT_INFO_CO
	WHERE [Agent_Status] = 'ENFORCE'
	AND [Date_Appointed] BETWEEN DATEADD(month, -2, @varREPORT_MONTH) AND EOMONTH(@varREPORT_MONTH)
	AND [Agent_Name] NOT LIKE 'DUMMY%'
	AND [Area_Name] NOT IN ('DR1', 'DSR', 'ACB', 'TTU')
)
----TINH FYP
, B AS (
	SELECT
		[Servicing Agent],
		SUM([FYP]) + SUM(0.1*[Topup Premium]) AS FYPincTopup
	FROM PREMIUM_CO
	WHERE [Collected Date] BETWEEN @varREPORT_MONTH AND EOMONTH(@varREPORT_MONTH)
	--VI ROOKIE LA DAI LY MOI GIA NHAP NEN KO THE NAO CO SFC, NEN KO CAN THIET LOC
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
	SUM(CountPolicy) AS CC
	FROM C
	GROUP BY [Issuing Agent]
)
----KET QUA
, D AS (
	SELECT *
	FROM A AS D1 LEFT JOIN B AS D2 ON D1.Agent_Number = D2.[Servicing Agent]
	LEFT JOIN C1 AS D3 ON D1.Agent_Number = D3.[Issuing Agent]
)

--, D2 AS (
	SELECT
		D22.TERRITORY,
		D22.[TD],
		D22.[TDName],
		D22.[TAD],
		D22.[TADName],
		D22.[SRD],
		D22.[SRDName],
		D22.[RD],
		D22.[RDName],
		D21.Area_Name,
		D21.Sales_Unit_Code,
		D21.Sales_Unit,
		D21.Agent_Number,
		D21.Agent_Name,
		D21.Grade,
		D21.Agent_Status,
		D21.Date_Appointed,
		D21.FYPincTopup,
		D21.CC
	FROM D AS D21 LEFT JOIN AD_STRUCTURE AS D22
	ON D21.Sales_Unit_Code = D22.[AD_Code]
--)

END;
GO


