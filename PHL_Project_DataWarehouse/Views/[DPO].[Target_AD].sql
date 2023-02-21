USE [PowerBI]
GO

/****** Object:  View [DPO].[Target_AD]    Script Date: 30/09/2022 16:37:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE    VIEW [DPO].[Target_AD] AS
SELECT [AD Code], [AD Name], unpvt.[Grade], YearTarget, CAST(MonthTarget AS INT) AS MonthTarget, TargetFYP, LS.[Last_Status],LS.[Last_Status_Date],LS.[Appointed_Date]
      ,LS.[Terminated_Date]
FROM   (SELECT [AD Code], [AD Name], [Grade], [Year]  AS YearTarget
, IIF([1] IS NULL, 0, [1]) AS [1]
, IIF([2] IS NULL, 0, [2]) AS [2]
, IIF([3] IS NULL, 0, [3]) AS [3]
, IIF([4] IS NULL, 0, [4]) AS [4]
, IIF([5] IS NULL, 0, [5]) AS [5]
, IIF([6] IS NULL, 0, [6]) AS [6]
, IIF([7] IS NULL, 0, [7]) AS [7]
, IIF([8] IS NULL, 0, [8]) AS [8]
, IIF([9] IS NULL, 0, [9]) AS [9]
, IIF([10] IS NULL, 0, [10]) AS [10]
, IIF([11] IS NULL, 0, [11]) AS [11]
, IIF([12] IS NULL, 0, [12]) AS [12]
             FROM    [PowerBI].[DPO].[DP_AD_TARGET]
             WHERE  [AD Code] <> '0' AND [YEAR] = '2021'
			 ) p UNPIVOT (TargetFYP FOR MonthTarget IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])) AS unpvt
LEFT JOIN [PowerBI].[DPO].[DW_AD] AS LS
ON [AD Code] = LS.[AD_Code]

UNION ALL
SELECT [AD Code], [AD Name], unpvt.[Grade], YearTarget, CAST(MonthTarget AS INT) AS MonthTarget, TargetFYP, LS.[Last_Status],LS.[Last_Status_Date],LS.[Appointed_Date]
      ,LS.[Terminated_Date]
FROM   (SELECT [AD Code], [AD Name], [Grade], [Year]  AS YearTarget
, IIF([1] IS NULL, 0, [1]) AS [1]
, IIF([2] IS NULL, 0, [2]) AS [2]
, IIF([3] IS NULL, 0, [3]) AS [3]
, IIF([4] IS NULL, 0, [4]) AS [4]
, IIF([5] IS NULL, 0, [5]) AS [5]
, IIF([6] IS NULL, 0, [6]) AS [6]
, IIF([7] IS NULL, 0, [7]) AS [7]
, IIF([8] IS NULL, 0, [8]) AS [8]
, IIF([9] IS NULL, 0, [9]) AS [9]
, IIF([10] IS NULL, 0, [10]) AS [10]
, IIF([11] IS NULL, 0, [11]) AS [11]
, IIF([12] IS NULL, 0, [12]) AS [12]
             FROM    [PowerBI].[DPO].[DP_AD_TARGET]
             WHERE  [AD Code] <> '0' AND [YEAR] = '2022'
			 ) p UNPIVOT (TargetFYP FOR MonthTarget IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])) AS unpvt
LEFT JOIN [PowerBI].[DPO].[DW_AD] AS LS
ON [AD Code] = LS.[AD_Code]




GO


