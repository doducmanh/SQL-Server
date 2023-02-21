USE [PowerBI]
GO

/****** Object:  UserDefinedFunction [DPO].[udf_agency_structure_map_bridge]    Script Date: 30/09/2022 16:55:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [DPO].[udf_agency_structure_map_bridge] 
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
			,B.[Status]
			,A.[Child Key]
			,C.[Agent_Name] AS [Agent_Name Child]
			,C.[Grade] AS [Grade Child]
			,C.[Status] AS [Status Child]
		FROM [PowerBI].[DPO].[dwo Agent Bridge] A
		LEFT JOIN [PowerBI].[DPO].[dwo Agent Info] B
		ON A.[Parent Key] = B.Agent_Number
		LEFT JOIN [PowerBI].[DPO].[dwo Agent Info] C
		ON A.[Child Key] = C.Agent_Number

		WHERE A.[Begin Effective Date] <= @date AND @date < A.[End Effective Date]
		AND B.[Begin Effective Date] <= @date AND @date < B.[End Effective Date]
		AND C.[Begin Effective Date] <= @date AND @date < C.[End Effective Date];
GO


