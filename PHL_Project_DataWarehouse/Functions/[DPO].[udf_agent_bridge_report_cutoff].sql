USE [PowerBI]
GO

/****** Object:  UserDefinedFunction [DPO].[udf_agent_bridge_report_cutoff]    Script Date: 30/09/2022 16:56:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [DPO].[udf_agent_bridge_report_cutoff] 
(
	-- Add the parameters for the function here
	@date AS DATE = '2022-07-31'
)
RETURNS TABLE
AS
RETURN
	SELECT A.[Parent Key]
		,A.[Child Key]
		,A.[Depth from Parent]
		,A.[Highest Parent Flag]
		,A.[Lowest Child Flag]
	FROM dpo.[dwo Agent Bridge Report Cutoff] A
	WHERE A.[Begin Effective Date] <= @date AND @date < A.[End Effective Date]
GO


