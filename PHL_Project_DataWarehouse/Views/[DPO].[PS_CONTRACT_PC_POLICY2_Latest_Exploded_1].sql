USE [PowerBI]
GO

/****** Object:  View [DPO].[PS_CONTRACT_PC_POLICY2_Latest_Exploded_1]    Script Date: 30/09/2022 16:35:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [DPO].[PS_CONTRACT_PC_POLICY2_Latest_Exploded_1] AS
WITH A AS (
SELECT *
FROM [DPO].[PS_CONTRACT_PC_POLICY2] 
EXCEPT
SELECT 
		T.[AREA]
      ,T.[Sales_Unit_Code]
      ,T.[SALES_UNIT]
      ,T.[DM_CODE]
      ,T.[DM_NAME]
      ,T.[FM_CODE]
      ,T.[FM_NAME]
      ,T.[AGENT_CODE]
      ,T.[AGENT_NAME]
      ,T.[GRADE]
      ,T.[AGENT_STATUS]
      ,T.[CONTRACT_NUMBER]
      ,T.[POLICY_OWNER_CODE]
      ,T.[PO_NAME]
      ,T.[PO_SEX]
      ,T.[PO_IDDATE]
      ,T.[PO_DOB]
      ,T.[PO_ID_NO]
      ,T.[SUM_ASSURED]
      ,T.[CURRENT_POLICY_STATUS]
      ,T.[LAST_PAID_DATE]
      ,T.[LAST_PAID_AMOUNT]
      ,T.[LAST_CHANGED_STATUS_DATE]
      ,T.[Staff policy]
      ,T.[ADDRESS1]
      ,T.[ADDRESS2]
      ,T.[WARD]
      ,T.[DISTRICT]
      ,T.[PROVINCE]
      ,T.[MOBILE_PHONE]
      ,T.[OFFICE_PHONE]
      ,T.[HOME_PHONE]
      ,T.[RISK_COMMENCE_DATE]
      ,T.[PAID TO DATE]
      ,T.[FREQUENCY]
      ,T.[INSTALL_PREMIUM]
      ,T.[PREMIUM_SUSPENSE]
      ,T.[APL]
      ,T.[POLICY_LOAN_AMOUNT]
      ,T.[COUPON_AMOUNT]
      ,T.[MOBILE_IC]
      ,T.[RIDER_PREMIUM]
      ,T.[CODE_BASIC PRO]
      ,T.[AUTO DEBIT]
      ,T.[CLM_NOTE]
      ,T.[LA_CODE_MAIN]
      ,T.[LA_NAME_MAIN]
      ,T.[TOTAL_ACCOUNT_VALUE]
      ,T.[MAIN_PRODUCT_PREM]
      ,T.[RIDER_FULLY_PAID_PREM]
      ,T.[RIDER_PREM_PAYING_PREM]
      ,T.[TOPUP_PLAN_PREM]
      ,T.[LOCATION]
      ,T.[POL_YEAR]
      ,T.[Premium_Plan]
      ,T.[BILLFREQ]
      ,T.[CODE_BY_WARD]
      ,T.[CODE_BY_DISTRICT]
      ,T.[CODE_BY_PROVINCE]
      ,T.[RiderTrd_UL1]
      ,T.[Amount of premium paid]
      ,T.[Application Number]
      ,T.[Full_Paid_Year]
      ,T.[PAID FREQ]
      ,T.[Paid_Premium]
      ,T.[New PTD]
      ,T.[Need_Collect]
      ,T.[PO_IDPLACE]
      ,T.[LA_DOB]
      ,T.[LA_ID_NO]
      ,T.[LA_IDDATE]
      ,T.[LA_IDPLACE]
  FROM [PowerBI].[DPO].[PS_CONTRACT_PC_POLICY2_DW] as T
  INNER JOIN (
	SELECT [CONTRACT_NUMBER], MAX([EXPLODED_DATE]) AS MAXDATE
	FROM [DPO].[PS_CONTRACT_PC_POLICY2_DW]
	GROUP BY [CONTRACT_NUMBER]
  ) AS T2 ON T.CONTRACT_NUMBER = T2.CONTRACT_NUMBER AND T.EXPLODED_DATE = T2.MAXDATE
)
--, B AS (
	SELECT *
	, FORMAT(GETDATE() - 1, 'yyyy-MM-dd') AS [EXPLODED_DATE]
	FROM A
--)


GO


