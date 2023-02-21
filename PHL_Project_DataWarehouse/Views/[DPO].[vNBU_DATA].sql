USE [PowerBI]
GO

/****** Object:  View [DPO].[vNBU_DATA]    Script Date: 30/09/2022 16:42:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [DPO].[vNBU_DATA] AS SELECT
	C.RPTTYPE, 
	C.RPTPERIOD,
	C.SALEOFFICE, 
	C.AGNTNUM, 
	C.CONTRACT_NUMBER, 
	C.CONTRACT_STATUS, 
	C.PRODUCT_CODE, 
	C.FREQUENCY, 
	--C.FYPISSUEDNET, 
	CASE WHEN RPTTYPE = 'SUBMISSION' THEN FYPSUBMS
			 WHEN  RPTTYPE = 'ISSUED' THEN FYPISSUEDNET
			 WHEN RPTTYPE = 'PENDING' THEN FYPPD
			 WHEN RPTTYPE = 'CANCEL IN FREE LOOK' THEN FYPCANCEL
			 WHEN RPTTYPE = 'REJECT' THEN FYP_REJECT
	END FYP,
	--C.AFYPISSUED, 
	CASE WHEN RPTTYPE = 'SUBMISSION' THEN 0
			 WHEN  RPTTYPE = 'ISSUED' THEN AFYPISSUED
			 WHEN RPTTYPE = 'PENDING' THEN 0
			 WHEN RPTTYPE = 'CANCEL IN FREE LOOK' THEN 0
			 WHEN RPTTYPE = 'REJECT' THEN 0
	END AFYP,
	--C.CASE_COUNT, 
	CASE WHEN RPTTYPE = 'SUBMISSION' THEN CASESUBMS
			 WHEN  RPTTYPE = 'ISSUED' THEN CASEISSUED
			 WHEN RPTTYPE = 'PENDING' THEN CASEPD
			 WHEN RPTTYPE = 'CANCEL IN FREE LOOK' THEN CASECANCEL
			 WHEN RPTTYPE = 'REJECT' THEN CASERJ
	END CASE_COUNT,
	--C.SUM_ASSURED, 
	--C.BEFORE_DISCOUNT_PREMIUM, 
	--C.DISCOUNT_PREMIUM, 
	--C.AFTER_DISCOUNT_PREMIUM, 
	CASE WHEN RPTTYPE = 'SUBMISSION' THEN C.PROPOSAL_RECEIVED_DATE
		ELSE C.EFFECTIVE_DATE
	END EFFECTIVE_DATE,
	--C.EFFECTIVE_DATE, 
	
	CASE WHEN RPTTYPE = 'SUBMISSION' THEN C.PROPOSAL_RECEIVED_DATE
		ELSE C.ISSUED_DATE
	END ISSUED_DATE,
	--C.ISSUED_DATE, 
	
	C.PROPOSAL_RECEIVED_DATE, 
	C.AD_CODE, 
	C.AD_NAME
		
	, [TERRITORY] = 
			CASE 
				WHEN (SELECT TOP 1 Territory FROM DPO.Main_AD_STRUCTURE WHERE AD_Code = C.AD_CODE AND Office_Code = C.SALEOFFICE ORDER BY ID DESC) IS NULL 
				THEN 
					CASE WHEN (SELECT TOP 1 Territory FROM DPO.Main_AD_STRUCTURE WHERE Grade IN ('ZD','SZD','TD') AND AD_Code = C.AD_CODE ORDER BY ID DESC) IS NULL
					THEN CASE WHEN C.SALEOFFICE = 'PARTNERSHIP' THEN 'Head office' 
							ELSE (SELECT TOP 1 Territory FROM DPO.Main_AD_STRUCTURE WHERE Grade IN ('ZD','SZD','TD') AND AD_Code = C.AD_CODE ORDER BY ID DESC) END
					ELSE (SELECT TOP 1 Territory FROM DPO.Main_AD_STRUCTURE WHERE Grade IN ('ZD','SZD','TD') AND AD_Code = C.AD_CODE ORDER BY ID DESC) END
				ELSE (SELECT TOP 1 Territory FROM DPO.Main_AD_STRUCTURE WHERE AD_Code = C.AD_CODE AND Office_Code = C.SALEOFFICE ORDER BY ID DESC) 
									END
	
	
		
	, C.BUSDATE
FROM
	DPO.NBU_DATA AS C
	LEFT JOIN DPO.Main_POLICY_INFO AS P
	ON 
		P.POLICY_NUMBER = C.CONTRACT_NUMBER
GO

