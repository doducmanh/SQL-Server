USE [PowerBI]
GO

/****** Object:  UserDefinedFunction [DPO].[udf_AD_info_raw]    Script Date: 30/09/2022 16:53:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [DPO].[udf_AD_info_raw] 
(
	-- Add the parameters for the function here
	@date AS DATE = '2022-06-30'
)
RETURNS TABLE
AS
	RETURN 
		SELECT 
			A.AD_Code
			,A.AD_Name
			,A.Grade
			,A.Status
			,A.[Begin Effective Date] AS [Status_Date]
			,A.Territory_Code
			,A.Territory
		FROM [DPO].[dwo AD Info Raw] A
		WHERE A.[Begin Effective Date] <= @date AND @date < A.[End Effective Date];
GO


