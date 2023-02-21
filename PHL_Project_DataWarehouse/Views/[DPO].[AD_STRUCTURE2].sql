USE [PowerBI]
GO

/****** Object:  View [DPO].[AD_STRUCTURE2]    Script Date: 30/09/2022 16:25:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [DPO].[AD_STRUCTURE2]
AS
WITH A AS (
SELECT DISTINCT [AD_CODE]
      --,[AD_NAME]
	  ,MIN([TRANS_DATE]) AS Start_Date1
	  ,MAX([TRANS_DATE]) AS End_Date1
FROM [PowerBI].[DPO].[CS_APPLICATION_PREMIUM]
GROUP BY [AD_CODE]
      --,[AD_NAME]
),
Temp1 AS (
			SELECT DISTINCT Temp.[AD_Code]
			  --,Temp.[AD_Name]
			  ,MAX(Temp.[Status_date]) AS Last_Date
			FROM [PowerBI].[DPO].[Main_AD_STRUCTURE] AS Temp
			GROUP BY Temp.[AD_Code]
			  --,Temp.[AD_Name]
),
Temp2 AS (
			SELECT DISTINCT Temp1.AD_Code
			--, Temp1.AD_Name
			, K.Status AS Last_Status
			FROM Temp1
			LEFT JOIN  [PowerBI].[DPO].[Main_AD_STRUCTURE] AS K
			ON Temp1.AD_Code = K.AD_Code
			AND Temp1.Last_Date = K.Status_date
),
Temp3 AS (
SELECT DISTINCT B0.[AD_Code]
      --, B0.[AD_Name]
	  , MIN(B0.[Status_date]) AS Start_Date2
	  , MAX(B0.[Status_date]) AS End_Date2
  FROM [PowerBI].[DPO].[Main_AD_STRUCTURE] AS B0
  GROUP BY [AD_CODE]
      --,[AD_NAME]
),
Temp4 AS (
SELECT DISTINCT Temp3.[AD_Code]
      --, Temp3.[AD_Name]
	  , Temp3.Start_Date2
	  , B0.Grade
	  , B0.AD_Parent_Code AS AD_Parent_Code
	  , B0.Territory_Code AS Territory_Code
  FROM Temp3
  LEFT JOIN [PowerBI].[DPO].[Main_AD_STRUCTURE] AS B0
  ON Temp3.AD_Code = B0.AD_Code AND Temp3.Start_Date2 = B0.Status_date
),
B AS (
  SELECT Temp3.AD_Code
  --, Temp3.AD_Name
  , Temp3.Start_Date2, Temp3.End_Date2, Temp2.Last_Status
  FROM Temp3
  RIGHT JOIN Temp2
  ON Temp2.[AD_Code] = Temp3.[AD_Code]

),
C AS (
SELECT A.[AD_CODE]
		--, B.[Start_Date2]
		--, B.[End_Date2]
		--, B.Last_Status
		, CASE
			WHEN B.Last_Status IS NULL THEN A.Start_Date1
			WHEN B.Last_Status = 'Terminated' AND A.End_Date1 > B.End_Date2 THEN A.End_Date1
			WHEN B.Last_Status <> 'Terminated' AND A.Start_Date1 < B.Start_Date2 THEN A.Start_Date1
		END AS Special_Adjustment
		, CASE
			WHEN B.Last_Status IS NULL THEN 'Sale'
			WHEN B.Last_Status = 'Terminated' AND A.End_Date1 > B.End_Date2 THEN 'Sale after Ter'
			WHEN B.Last_Status <> 'Terminated' AND A.Start_Date1 < B.Start_Date2 AND DateDiff(day, A.Start_Date1, B.Start_Date2) < = 30 THEN 'Sale before Appointed'
			WHEN B.Last_Status <> 'Terminated' AND A.Start_Date1 < B.Start_Date2 AND DateDiff(day,A.Start_Date1, B.Start_Date2) > 30 THEN 'PHL'
		END AS Note

FROM A LEFT JOIN B
ON A.[AD_Code] = B.[AD_Code]
),
D AS (
SELECT C.*
FROM C
WHERE Special_Adjustment IS NOT NULL
)


SELECT DISTINCT 
      [AD_Code]
      ,[Grade]
      ,[AD_Parent_Code]
      ,[Territory_Code]
      ,MIN(Status_date) AS Status_date
      ,[Status]
FROM [PowerBI].[DPO].[Main_AD_STRUCTURE]
GROUP BY [ID]
      ,[AD_Code]
      ,[Grade]
      ,[AD_Parent_Code]
      ,[Territory_Code]
      ,[Status]


	  UNION

SELECT distinct D.AD_CODE
		, IIF(Temp4.Grade IS NOT NULL, Temp4.Grade, 'ZD') AS Grade
		, IIF(Temp4.AD_Parent_Code IS NOT NULL AND D.Note <> 'PHL', Temp4.AD_Parent_Code, 'PHL') AS AD_Parent_Code
		, IIF(Temp4.Territory_Code IS NOT NULL, Temp4.Territory_Code, 'PHL') AS Territory_Code
		, D.Special_Adjustment AS [Status_date]
		,'Special_Adjustment' AS Status
		--, D.Note
FROM D
LEFT JOIN Temp4 ON D.AD_CODE = Temp4.AD_Code

UNION
   SELECT distinct [Sales_Unit_Code], 'ZD' AS Grade, 'PHL' AS AD_Parent_Code, 'PHL' AS Territory_Code, CONVERT(date, DATEADD(month, -1, getdate())) AS [Status_date],
 'Appointed' AS Status
 
  FROM [PowerBI].[DPO].[Main_AGENT_INFO_DA]

WHERE  [Sales_Unit_Code] NOT IN (SELECT [AD_Code] FROM [PowerBI].[DPO].[Main_AD_STRUCTURE])
AND [Sales_Unit_Code] NOT IN (SELECT D.[AD_Code] FROM D)
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[23] 4[14] 2[37] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Main_AD_STRUCTURE (dbo)"
            Begin Extent = 
               Top = 9
               Left = 57
               Bottom = 206
               Right = 308
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1000
         Width = 1000
         Width = 1000
         Width = 1000
         Width = 1000
         Width = 1000
         Width = 1000
         Width = 1000
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'DPO', @level1type=N'VIEW',@level1name=N'AD_STRUCTURE2'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'DPO', @level1type=N'VIEW',@level1name=N'AD_STRUCTURE2'
GO


