USE [PowerBI]
GO

/****** Object:  UserDefinedFunction [DPO].[udf_AD_structure_wide]    Script Date: 30/09/2022 16:54:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [DPO].[udf_AD_structure_wide] 
(
	-- Add the parameters for the function here
	@date AS DATE = '2022-07-31'
)
RETURNS TABLE
AS
	RETURN 
		SELECT 
			[Child Key0]
		  ,[Child Key1]
		  ,[Child Key2]
		  ,[Child Key3]
		  ,[Child Key4]
		  ,[Child Key5]
		  ,[Child Key6]
		  ,[Child Key7]
		  ,[Child Key8]
		FROM [PowerBI].[DPO].[dwo AD Structure Wide] A
		WHERE A.[Begin Effective Date] <= @date AND @date < A.[End Effective Date]
GO


