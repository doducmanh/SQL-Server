USE [PowerBI]
GO

/****** Object:  View [DPO].[vwPOLICY_AD]    Script Date: 30/09/2022 16:47:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [DPO].[vwPOLICY_AD] AS

WITH POL AS(

	SELECT 
		[POLICY_NUMBER]
		,[AGENT_NUMBER]
	FROM vwMain_POLICY_INFO
)

SELECT *
FROM POL




GO


