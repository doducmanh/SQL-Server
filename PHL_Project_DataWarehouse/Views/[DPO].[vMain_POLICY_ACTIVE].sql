USE [PowerBI]
GO

/****** Object:  View [DPO].[vMain_POLICY_ACTIVE]    Script Date: 30/09/2022 16:42:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [DPO].[vMain_POLICY_ACTIVE] AS SELECT 
R.*
, [TERRITORY] = CASE WHEN (SELECT TOP 1 Territory FROM Main_AD_STRUCTURE WHERE /*status IN ('Appointed','Promoted') AND*/  AD_Code = R.sales_unit_code AND Office_Code = R.area_code ORDER BY ID DESC) IS NULL 
													THEN (SELECT TOP 1 Territory FROM Main_AD_STRUCTURE WHERE Grade IN ('ZD','SZD','TD') AND AD_Code = R.sales_unit_code ORDER BY ID DESC)
												ELSE (SELECT TOP 1 Territory FROM Main_AD_STRUCTURE WHERE /*status IN ('Appointed','Promoted') AND*/  AD_Code = R.sales_unit_code AND Office_Code = R.area_code ORDER BY ID DESC) END
FROM Main_POLICY_ACTIVE R
GO


