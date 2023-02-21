USE [DP_Manh]
GO

/****** Object:  StoredProcedure [dbo].[PERFORMANCE_WC]    Script Date: 12/01/2023 16:22:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[PERFORMANCE_WC] (@varREPORT_MONTH nvarchar(4000)) 
AS 
BEGIN
----NHẬP THÁNG BÁO CÁO @varREPORT_MONTH 'YYYY-MM-01'
----PREPARING DATA
WITH
AD_STRUCTURE AS (
	SELECT 
		AD_STRUCTURE2.[TERRITORY],
		AD_STRUCTURE1.*
	FROM (SELECT *
		  FROM [SQL_SV65].[PowerBI].[DPO].[Main_AD_STRUCTURE_FULL]
		  WHERE [ExplodedDate]  = @varREPORT_MONTH) AS AD_STRUCTURE1
	LEFT JOIN [dbo].[T_Main_TERRITORIES] AS AD_STRUCTURE2
	ON AD_STRUCTURE1.[Territory_Code] = AD_STRUCTURE2.[CODE]
)
, FYP_K2_MTHLY AS (
	SELECT *
	FROM [dbo].[T_AD_FYP_K2_MTHLY]
)
----
, A AS (
	SELECT
		A0.[Territory_Code],
		A0.[TERRITORY],
		A0.[TD],
		A0.[TDName],
		A0.[TAD],
		A0.[TADName],
		A0.[SRD],
		A0.[SRDName],
		A0.[RD],
		A0.[RDName],
		A0.[RAD],
		A0.[RADName],
		A0.[SZD],
		A0.[SZDName],
		A0.[AD_Code],
		A0.[ADName],
		A0.[AD_Grade],
		A0.[Appointed_Date],
		A0.[Last_Status],
		A01.TargetFYP AS TargetFYP_T_2,
		A01.FYPincTopup AS FYPincTopup_T_2,
		A01.ACHIEVED_TARGET_FYP AS ACHIEVED_TARGET_FYP_T_2,
		A02.TargetFYP AS TargetFYP_T_1,
		A02.FYPincTopup AS FYPincTopup_T_1,
		A02.ACHIEVED_TARGET_FYP AS ACHIEVED_TARGET_FYP_T_1,
		A03.TargetFYP AS TargetFYP_T,
		A03.FYPincTopup AS FYPincTopup_T,
		A03.ACHIEVED_TARGET_FYP AS ACHIEVED_TARGET_FYP_T
	FROM AD_STRUCTURE AS A0 LEFT JOIN FYP_K2_MTHLY AS A01
	ON A0.[AD_Code] = A01.AD_Code AND A01.REPORT_MONTH = FORMAT(DATEADD(month, -2, @varREPORT_MONTH), 'yyyyMM')
	LEFT JOIN FYP_K2_MTHLY AS A02
	ON A0.[AD_Code] = A02.AD_Code AND A02.REPORT_MONTH = FORMAT(DATEADD(month, -1, @varREPORT_MONTH), 'yyyyMM')
	LEFT JOIN FYP_K2_MTHLY AS A03
	ON A0.[AD_Code] = A03.AD_Code AND A03.REPORT_MONTH = FORMAT(DATEADD(month, 0, @varREPORT_MONTH), 'yyyyMM')
)
SELECT
		[TERRITORY],
		[TD],
		[TDName],
		[TAD],
		[TADName],
		[SRD],
		[SRDName],
		[RD],
		[RDName],
		[RAD],
		[RADName],
		[SZD],
		[SZDName],
		[AD_Code],
		[ADName],
		[AD_Grade],
		[Appointed_Date],
		[Last_Status],
		TargetFYP_T_2,
		FYPincTopup_T_2,
		ACHIEVED_TARGET_FYP_T_2,
		TargetFYP_T_1,
		FYPincTopup_T_1,
		ACHIEVED_TARGET_FYP_T_1,
		TargetFYP_T,
		FYPincTopup_T,
		ACHIEVED_TARGET_FYP_T
FROM A
WHERE [Territory_Code] IN ('MB3', 'MN6')
AND [Last_Status] <> 'Terminated'
END;
GO


