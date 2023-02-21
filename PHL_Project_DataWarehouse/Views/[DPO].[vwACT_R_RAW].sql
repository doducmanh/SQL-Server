USE [PowerBI]
GO

/****** Object:  View [DPO].[vwACT_R_RAW]    Script Date: 30/09/2022 16:44:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [DPO].[vwACT_R_RAW] AS
SELECT [KEY 1]
      ,[CHDRNUM]
      ,[LIFE]
      ,[COVERAGE]
      ,[RIDER]
      ,[STATCODE]
      ,[CRRCD]
      ,[SEX]
      ,[CLTDOB]
      ,[CRTABLE]
      ,[RISK_CESS_DATE]
      ,[PREM_CESS_DATE]
      ,[SUMINS]
      ,[HOISSDTE]
      ,[BILLFREQ]
      ,[BTDATE]
      ,[SRCEBUS]
      ,[ISSUED_AGE]
      ,[PREMIUM_AFTER_DISCOUNT]
      ,[PREMIUM_DISCOUNT]
      ,[PREMIUM_BEFORE_DISCOUNT]
      ,[POLICY_TERM]
      ,[PREMIUM_TERM]
      ,[TRANSACTION_DATE]
      ,[CURRFROM]
      ,[HISSDTE]
      ,[PTDATE]
      ,[POLICY YEAR DATA]
      ,[POLICY YEAR]
      ,[EFFECTIVE DATE]
      ,[REINDATE]
      ,[AP]
      ,[FIRST ISSUE MONTH]
      ,[LAST OVER DUE DATE]
      ,[PREVIOUS SA]
      ,[CHANGE SA]
      ,[BASIC]
      ,[MONTH_END]
  FROM [PowerBI].[DPO].[ACT_R_RAW]
GO


