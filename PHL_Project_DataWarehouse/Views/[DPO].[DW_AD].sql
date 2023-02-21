USE [PowerBI]
GO

/****** Object:  View [DPO].[DW_AD]    Script Date: 30/09/2022 16:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   VIEW [DPO].[DW_AD] AS
WITH AllAD AS (
SELECT DISTINCT Sales_Unit_Code AS AD_Code, Sales_Unit AS AD_Name
FROM   [DPO].Main_AGENT_INFO_DA

UNION

SELECT DISTINCT a.AD_Code
--,b.Sales_Unit
, IIF(b.Sales_Unit IS NULL, a.AD_Name, b.Sales_Unit) AS AD_Name
FROM [DPO].[Main_AD_STRUCTURE] AS a

LEFT JOIN [DPO].Main_AGENT_INFO_DA AS b ON b.Sales_Unit_Code = a.AD_Code
)
, A AS (
SELECT [AD_Code]
      ,MAX([ID]) AS Last_Status_Date
  FROM [PowerBI].[DPO].[Main_AD_STRUCTURE]
  GROUP BY
		[AD_Code]
 -- ORDER BY [AD_Code]
)
, B AS (
SELECT DISTINCT K.[AD_Code]
	  ,K.AD_Name
	  ,K.Grade
      ,K.[Status] AS Last_Status
	  ,K.Status_date AS Last_Status_Date
  FROM [PowerBI].[DPO].[Main_AD_STRUCTURE] AS K
  RIGHT JOIN A
  ON K.AD_Code = A.AD_Code AND K.ID = A.Last_Status_Date
  --ORDER BY K.[AD_Code]
)
, Q AS (SELECT AD_Code, MAX(ID) AS Last_ID
                   FROM   [DPO].Main_AD_STRUCTURE
                   WHERE Status = 'Rejoined' OR Status = 'Appointed'
				   GROUP BY AD_Code
				   )
, K AS
    (SELECT Q1.ID, Q1.AD_Code, Q1.AD_Name, Q1.Grade, Q1.AD_Parent_Code, Q1.AD_Parent, Q1.Territory, Q1.Territory_Code, Q1.Office, Q1.Office_Code, Q1.Status_date, Q1.Status, Q1.Update_Time
    FROM    [DPO].Main_AD_STRUCTURE AS Q1 INNER JOIN
                 Q AS Q_1 ON Q_1.AD_Code = Q1.AD_Code AND Q_1.Last_ID = Q1.ID)
, C AS (
    SELECT DISTINCT AD_Code, AD_Name, Grade, AD_Parent, AD_Parent_Code, Territory, Territory_Code, Status, Status_date
   FROM    K AS K_1

)
, L AS (SELECT AD_Code, MAX(ID) AS Last_ID
                   FROM   [DPO].Main_AD_STRUCTURE
                   WHERE Status = 'Demoted' OR Status = 'Promoted'
				   GROUP BY AD_Code
				   )
, M AS
    (SELECT Q1.ID, Q1.AD_Code, Q1.Status_date, Q1.Status, Q1.Update_Time
    FROM    [DPO].Main_AD_STRUCTURE AS Q1 INNER JOIN
                 L AS Q_1 ON Q_1.AD_Code = Q1.AD_Code AND Q_1.Last_ID = Q1.ID)
, D AS (
    SELECT DISTINCT AD_Code, Status AS Demote_Promote_Date, Status_date
   FROM    M AS K_1

)

SELECT AllAD.AD_Code
	,AllAD.AD_Name
	,B.Grade
	,B.Last_Status
	,B.Last_Status_Date
	,C.Status_date AS Appointed_Date
	,IIF (B.Last_Status = 'Terminated', B.Last_Status_Date,NULL) AS Terminated_Date
	,D.Status_date AS DemotePromote_Date
FROM AllAD
LEFT JOIN B
ON AllAD.AD_Code = B.AD_Code

LEFT JOIN C
ON AllAD.AD_Code = C.AD_Code

LEFT JOIN D
ON AllAD.AD_Code = D.AD_Code

GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
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
         Begin Table = "Main_AGENT_INFO_DA (dbo)"
            Begin Extent = 
               Top = 9
               Left = 57
               Bottom = 206
               Right = 384
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
      Begin ColumnWidths = 11
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
' , @level0type=N'SCHEMA',@level0name=N'DPO', @level1type=N'VIEW',@level1name=N'DW_AD'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'DPO', @level1type=N'VIEW',@level1name=N'DW_AD'
GO


