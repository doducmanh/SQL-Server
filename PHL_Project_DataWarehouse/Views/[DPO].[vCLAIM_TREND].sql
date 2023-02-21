USE [PowerBI]
GO

/****** Object:  View [DPO].[vCLAIM_TREND]    Script Date: 30/09/2022 16:38:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [DPO].[vCLAIM_TREND] AS SELECT DISTINCT CONCAT(FORMAT(YEAR(CLM_SUBMIT_DATE),'0000'), FORMAT(MONTH(CLM_SUBMIT_DATE),'00')) YYYYMM
, AD_OFFICES, TERRITORY
FROM vClaim

UNION

SELECT DISTINCT CONCAT(FORMAT(YEAR(PAYMENT_NOTICED),'0000'), FORMAT(MONTH(PAYMENT_NOTICED),'00')) YYYYMM
, AD_OFFICES, TERRITORY
FROM vClaim WHERE PAYMENT_NOTICED IS NOT NULL
GO

