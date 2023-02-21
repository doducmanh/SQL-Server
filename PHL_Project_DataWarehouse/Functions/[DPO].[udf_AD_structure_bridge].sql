USE [PowerBI]
GO

/****** Object:  UserDefinedFunction [DPO].[udf_AD_structure_bridge]    Script Date: 30/09/2022 16:53:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [DPO].[udf_AD_structure_bridge] 
(
	-- Add the parameters for the function here
	@date AS DATE = '2022-06-30'
)
RETURNS TABLE
AS
	RETURN 
		SELECT A.[Parent Key]      
			,B.AD_Name
			,B.[Grade]
			,B.[Status]
			,B.Status_Date
			,B.[Territory_Code]
			,B.Territory
			,A.[Depth from Parent]
			,A.[Highest Parent Flag]
			,A.[Lowest Child Flag]
			,A.[Child Key]
			,C.[AD_Name] AS [Child AD_Name]
			,C.[Grade] AS [Child Grade]
			,C.[Status] AS [Child Status]
			,C.Status_Date AS [Child Status_Date]
			,C.Territory_Code AS [Child Territory_Code]
			,C.Territory AS [Child Territory]
		FROM [DPO].[udf_AD_bridge](@date) A
		LEFT JOIN [DPO].[udf_AD_info_raw](@date) B
		ON A.[Parent Key] = B.AD_Code
		LEFT JOIN [DPO].[udf_AD_info_raw](@date) C
		ON A.[Child Key] = C.AD_Code
GO


