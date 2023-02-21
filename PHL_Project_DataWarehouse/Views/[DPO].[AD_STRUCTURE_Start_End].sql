USE [PowerBI]
GO

/****** Object:  View [DPO].[AD_STRUCTURE_Start_End]    Script Date: 30/09/2022 16:24:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [DPO].[AD_STRUCTURE_Start_End] AS
WITH Q AS (
SELECT [AD_Code]
      --,[AD_Name]
      ,[Grade]
      ,[AD_Parent_Code]
      --,[AD_Parent]
      --,[Territory]
      ,[Territory_Code]
      --,[Office]
      --,[Office_Code]
      ,[Status_date] AS Start_date
      ,[Status] 
	  --,[Update_Time]
  FROM [DPO].[AD_STRUCTURE2]
  --WHERE [Status] <> 'Office / Territory' 
  GROUP BY [AD_Code]
      --,[AD_Name]
      ,[Grade]
      ,[AD_Parent_Code]
      --,[AD_Parent]
      --,[Territory]
      ,[Territory_Code]
      --,[Office]
      --,[Office_Code]
      ,[Status_date]
      ,[Status] 
),
F AS (
SELECT Q.[AD_Code] 
      --,Q.[AD_Name]
      ,Q.[Grade]
      ,Q.[AD_Parent_Code]
      --,Q.[AD_Parent]
      --,[Territory]
      ,[Territory_Code]
      --,[Office]
      --,[Office_Code]
      ,Q.[Start_date]
	  ,LEAD([Start_date]) OVER (PARTITION BY AD_Code ORDER BY [Start_date]) AS End_Date
	  ,[Status] 

FROM Q
)

SELECT F.AD_Code, F.Grade, F.AD_Parent_Code, F.Territory_Code, F.Start_date, F.End_Date, F.Status
FROM   F
WHERE NOT ((F.End_Date IS NULL) AND (F.Status = 'Terminated'))
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[20] 2[11] 3) )"
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
         Begin Table = "AD_STRUCTURE_Start_End0"
            Begin Extent = 
               Top = 9
               Left = 57
               Bottom = 206
               Right = 292
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
' , @level0type=N'SCHEMA',@level0name=N'DPO', @level1type=N'VIEW',@level1name=N'AD_STRUCTURE_Start_End'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'DPO', @level1type=N'VIEW',@level1name=N'AD_STRUCTURE_Start_End'
GO


