USE [PowerBI]
GO

/****** Object:  UserDefinedFunction [DPO].[udf_agent_AD_cutoff]    Script Date: 30/09/2022 16:56:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [DPO].[udf_agent_AD_cutoff] 
(
	-- Add the parameters for the function here
	@date AS DATE = '2022-06-30'
)
RETURNS TABLE
AS
	RETURN 
		SELECT [Agent_Number]
		  ,[Agent_Name]
		  ,[AD_Code]
		  ,[AD_Name]
		  ,[Area_Name] AS [Area_Code]
		  ,[Leader_count]
		FROM dpo.[dwo Agent AD Cutoff] A
		WHERE A.[Begin Effective Date] <= @date AND @date < A.[End Effective Date];
GO


