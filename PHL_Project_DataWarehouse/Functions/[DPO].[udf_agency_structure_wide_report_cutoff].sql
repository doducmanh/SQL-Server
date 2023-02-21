USE [PowerBI]
GO

/****** Object:  UserDefinedFunction [DPO].[udf_agency_structure_wide_report_cutoff]    Script Date: 30/09/2022 16:55:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [DPO].[udf_agency_structure_wide_report_cutoff] 
(
	-- Add the parameters for the function here
	@date AS DATE = '2022-07-31'
)
RETURNS TABLE
AS
	RETURN 
		SELECT 
			A.*
		FROM [PowerBI].[DPO].[dwo Agency Structure Wide Report Cutoff] A
		WHERE A.[Begin Effective Date] <= @date AND @date < A.[End Effective Date]
GO


