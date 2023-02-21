USE [PowerBI]
GO

/****** Object:  UserDefinedFunction [DPO].[udf_agent_info_AD_cutoff]    Script Date: 30/09/2022 16:56:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [DPO].[udf_agent_info_AD_cutoff] 
(
	-- Add the parameters for the function here
	@date AS DATE = '2022-06-30'
)
RETURNS TABLE
AS
	RETURN 
		SELECT 
			A.*
			,B.AD_Code
			,B.AD_Name
			,B.Area_Code
			,B.Leader_count
		FROM [DPO].[udf_agent_info_cutoff](@date) A
		LEFT JOIN [DPO].[udf_agent_AD_cutoff](@date) B
		ON A.Agent_Number = B.Agent_Number
GO


