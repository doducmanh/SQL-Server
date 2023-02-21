USE [PowerBI]
GO

/****** Object:  View [DPO].[vwMain_POLICY_INFO]    Script Date: 30/09/2022 16:46:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [DPO].[vwMain_POLICY_INFO] AS
SELECT [ID]
      ,[POLICY_NUMBER]
      ,[PO_NAME]
      ,[PO_IDNUMBER]
      ,[PO_NUMBER]
      ,[PO_DOB]
      ,[PRODUCT_CODE]
      ,[RISK_COMMENCEMENT_DATE]
      ,[SUM_ASSURED]
      ,[REINS_DATE]
      ,[FLUP_CODES]
      ,[PAID_TO_DATE]
      ,[POLICY_STATUS]
      ,[LOAN_STATUS]
      ,[LA_NAME]
      ,[LA_IDNUMBER]
      ,[LA_CLIENT_NUMBER]
      ,[LA_DOB]
      ,[LA_SEX]
      ,[AGENT_CHANNEL]
      ,[AGENT_NUMBER]
      ,[AGENT_NAME]
      ,[SALES_UNIT]
      ,[AREA_NAME]
      ,[BENEF_NAME]
      ,[BENEF_IDNUM]
      ,[BENEF_IDDATE]
      ,[BENEF_ADDRESS]
      ,[ADDRESS1]
      ,[ADDRESS2]
      ,[ADDRESS3]
      ,[ADDRESS4]
      ,[ADDRESS5]
      ,[PHONE]
      ,[ISSUED_DATE]
      ,[CLN_MOBILE]
      ,[BENEF_IDPLACE]
      ,[BENEF_DOB]
      ,[PO_IDPLACE]
      ,[PO_IDDATE]
      ,[PO_ADDRESS]
      ,[PROPOSAL_DATE]
      ,[AD_CODE]
  FROM [PowerBI].[DPO].[Main_POLICY_INFO]
GO


