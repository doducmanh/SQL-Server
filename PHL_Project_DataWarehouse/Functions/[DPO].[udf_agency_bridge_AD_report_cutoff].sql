USE [PowerBI]
GO

/****** Object:  UserDefinedFunction [DPO].[udf_agency_bridge_AD_report_cutoff]    Script Date: 30/09/2022 16:54:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [DPO].[udf_agency_bridge_AD_report_cutoff] 
(
	-- Add the parameters for the function here
	@date AS DATE = '2022-06-30'
)
RETURNS TABLE
AS
	RETURN 
		SELECT A.[Child Key]
		,A.[Depth from Parent]
		,A.[Lowest Child Flag]
		,B.AD_Code
		,B.AD_Name
		,B.Area_Name
		,B.Leader_count
			
		FROM (SELECT * FROM [DPO].[udf_agent_bridge_report_cutoff](@date) WHERE [Parent Key]='Root') A
		LEFT JOIN [DPO].[udf_agent_AD_cutoff](@date) B
		ON A.[Child Key] = B.Agent_Number
		
GO


