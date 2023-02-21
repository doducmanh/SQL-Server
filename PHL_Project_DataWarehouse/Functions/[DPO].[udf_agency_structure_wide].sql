USE [PowerBI]
GO

/****** Object:  UserDefinedFunction [DPO].[udf_agency_structure_wide]    Script Date: 30/09/2022 16:55:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [DPO].[udf_agency_structure_wide] 
(
	-- Add the parameters for the function here
	@date AS DATE = '2022-07-31'
)
RETURNS TABLE
AS
	RETURN 
		SELECT 
			A.[Child Key0]
			,A.[Child Key1]
			,A.[Child Key2]
			,A.[Child Key3]
			,A.[Child Key4]
			,A.[Child Key5]
			,A.[Child Key6]
			,A.[Child Key7]
			,A.[Child Key8]
			,A.[Child Key9]
			,A.[Child Key10]
			,A.[Child Key11]
			,A.[Child Key12]
			,A.[Child Key13]
			,A.[Child Key14]
			,A.[Child Key15]
			,A.[Child Key16]
		FROM [PowerBI].[DPO].[dwo Agency Structure Wide] A
		WHERE A.[Begin Effective Date] <= @date AND @date < A.[End Effective Date]
GO


