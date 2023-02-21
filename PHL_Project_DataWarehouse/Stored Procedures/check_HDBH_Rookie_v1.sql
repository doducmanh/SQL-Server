USE DP_Manh
GO
WITH 
----run on local
----PREPARE DATA
ROOKIES_LIST AS (
	SELECT
		*
	FROM [dbo].[T_CHECK_DATA_ROOKIES_CC]
)
, AGENT_INFO AS (
	SELECT
		*
	FROM [SQL_SV65].[PowerBI].[DPO].[Main_AGENT_INFO_DA]
)
, AD_STRUCTURE AS (
	SELECT 
		AD_STRUCTURE2.[TERRITORY],
		AD_STRUCTURE1.*
	FROM (SELECT * FROM OPENQUERY (SQL_SV65, 
	'SELECT * 
	FROM [PowerBI].[DPO].[Main_AD_STRUCTURE_FULL] 
	WHERE [ExplodedDate] = ''2023-12-01''')) AS AD_STRUCTURE1
	LEFT JOIN [dbo].[T_Main_TERRITORIES] AS AD_STRUCTURE2
	ON AD_STRUCTURE1.[Territory_Code] = AD_STRUCTURE2.[CODE]
)
, DAILYSALES AS (
	SELECT
		*
	FROM OPENQUERY(SQL_SV65, '
	SELECT *
	FROM [PowerBI].[DPO].[DP_TDAILYSALES_DA]
	WHERE [Proposal_Receive_Date] >= ''2021-01-01''
	')
)
, PREMIUMS AS (
	SELECT
		*
	FROM OPENQUERY(SQL_SV65, '
	SELECT *
	FROM [PowerBI].[DPO].[DP_TAGENTPREMIUM_TEST]
	WHERE [Issued Date] >= ''2021-01-01''
	')
)
, CUSTOMER_INFO AS (
	SELECT
		*
	FROM [SQL_SV65].[PowerBI].[DPO].[Main_CUSTOMER_INFO]
)
----IP
, A AS (
	SELECT
		[Issuing_Agent],
		[Policy_Number],
		[Policy_Issue_Date],
		[Policy_Status],
		SUM([After_Discount_Premium]) AS INSTALL_PREMIUM_IP
	FROM DAILYSALES
	WHERE [Policy_Status] = 'IF'
	AND [Issuing_Agent] IN (SELECT [Agent_Number] FROM ROOKIES_LIST)
	GROUP BY [Issuing_Agent], [Policy_Number], [Policy_Issue_Date], [Policy_Status]
)
----HO TEN KHACH HANG - BEN MUA BAO HIEM
, B AS (
	SELECT
		B01.[Issuing_Agent],
		B01.[Policy_Number],
		B01.[Policy_Issue_Date],
		B01.[Policy_Status],
		B02.[CUSTOMER_NAME],
		B01.INSTALL_PREMIUM_IP
	FROM A AS B01 LEFT JOIN CUSTOMER_INFO AS B02
	ON B01.[Policy_Number] = B02.[POLICY_CODE]
)
----AD 
, C AS (
	SELECT
		C02.[Sales_Unit_Code],
		C02.[Sales_Unit],
		C01.[Issuing_Agent],
		C02.[Agent_Name],
		C01.[Policy_Number],
		C01.[Policy_Issue_Date],
		C01.[Policy_Status],
		C01.[CUSTOMER_NAME],
		C01.INSTALL_PREMIUM_IP
	FROM B AS C01 LEFT JOIN AGENT_INFO AS C02
	ON C01.[Issuing_Agent] = C02.[Agent_Number]
)
, C1 AS (
	SELECT
		C12.TERRITORY,
		C12.[TD],
		C12.[TDName],
		C12.[TAD],
		C12.[TADName],
		C12.[RD],
		C12.[RDName],
		C11.[Sales_Unit_Code],
		C11.[Sales_Unit],
		C11.[Issuing_Agent],
		C11.[Agent_Name],
		C11.[Policy_Number],
		C11.[Policy_Issue_Date],
		C11.[Policy_Status],
		C11.[CUSTOMER_NAME],
		C11.INSTALL_PREMIUM_IP
	FROM C AS C11 LEFT JOIN AD_STRUCTURE AS C12	
	ON C11.[Sales_Unit_Code] = C12.[AD_Code]
)
----FYP
, D AS (
	SELECT
		[Policy No],
		SUM([FYP] + 0.1*[Topup Premium]) AS FYPincTopup
	FROM PREMIUMS
	GROUP BY [Policy No]
	
)
, D1 AS (
	SELECT
		D11.*,
		D12.FYPincTopup
	FROM C1 AS D11 LEFT JOIN D AS D12
	ON D11.[Policy_Number] = D12.[Policy No]
)

----FINAL
SELECT
	*
FROM D1