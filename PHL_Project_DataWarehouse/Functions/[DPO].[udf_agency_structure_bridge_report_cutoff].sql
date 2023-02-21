USE [PowerBI]
GO

/****** Object:  UserDefinedFunction [DPO].[udf_agency_structure_bridge_report_cutoff]    Script Date: 30/09/2022 16:54:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [DPO].[udf_agency_structure_bridge_report_cutoff] 
(
	-- Add the parameters for the function here
	@date AS DATE = '2022-06-30'
)
RETURNS TABLE
AS
	RETURN 
		SELECT A.[Parent Key]
			,B.[Agent_Name]
			,B.[Grade]
			,B.[Agent_Status]
			,B.Date_Appointed
			,B.Terminated_date
			,B.AD_Code
			,B.AD_Name
			,B.Area_Code
			,A.[Child Key]
			,A.[Depth from Parent]
			,A.[Highest Parent Flag]
			,A.[Lowest Child Flag]
			,C.[Agent_Name] AS [Child Agent_Name]
			,C.[Grade] AS [Child Grade]
			,C.[Agent_Status] AS [Child Status]
			,C.Date_Appointed AS [Child Date_Appointed]
			,C.Terminated_date AS [Child Terminated_date]
			,C.AD_Code AS [Child AD_Code]
			,C.AD_Name AS [Child AD_Name]
			,C.Area_Code AS [Child Area_Code]
			,C.Leader_count AS [Child Leader_count]
		FROM [DPO].[udf_agent_bridge_report_cutoff](@date) A
		LEFT JOIN [DPO].[udf_agent_info_AD_cutoff](@date) B
		ON A.[Parent Key] = B.Agent_Number
		LEFT JOIN [DPO].[udf_agent_info_AD_cutoff](@date) C
		ON A.[Child Key] = C.Agent_Number;
GO


