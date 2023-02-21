USE [PowerBI]
GO

/****** Object:  StoredProcedure [DPO].[CC_IF]    Script Date: 30/09/2022 16:50:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [DPO].[CC_IF]
AS
Select C.[Issuing Agent],COUNT(C.[Policy No])AS Count_Policy_IF ,B.Period
from [DPO].[DP_TAGENTPREMIUM_TEST] AS C JOIN [DPO].[Comp_Calendar] AS B
ON C.[Issued Date] BETWEEN B.[Start Month] and B.[End Month]
WHERE B.Period>='202201' and C.[Policy Status]='IF'
GROUP BY C.[Issuing Agent],B.Period
ORDER BY B.Period
GO


