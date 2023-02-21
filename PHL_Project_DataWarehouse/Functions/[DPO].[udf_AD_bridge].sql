USE [PowerBI]
GO

/****** Object:  UserDefinedFunction [DPO].[udf_AD_bridge]    Script Date: 30/09/2022 16:52:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [DPO].[udf_AD_bridge] 
(
	-- Add the parameters for the function here
	@date AS DATE = '2022-06-30'
)
RETURNS TABLE
AS
	RETURN 
		SELECT 
			[Parent Key]
		  ,[Child Key]
		  ,[Depth from Parent]
		  ,[Highest Parent Flag]
		  ,[Lowest Child Flag]
		FROM [DPO].[dwo AD Bridge] A
		WHERE A.[Begin Effective Date] <= @date AND @date < A.[End Effective Date];
GO


