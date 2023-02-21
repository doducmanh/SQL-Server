USE [PowerBI]
GO

/****** Object:  View [DPO].[AD4]    Script Date: 30/09/2022 16:26:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
CREATE   VIEW [DPO].[AD4] AS
WITH G AS (
SELECT [AD_Code]
      ,[Grade]
	  ,[AD_Parent_Code]
      ,[ExplodedDate]
  FROM [PowerBI].[DPO].[AD_STRUCTURE_Exploded]
)

SELECT 
	A.AD_Code
	, A.Grade AS AD_Grade
	--IIF(A.[AD_Parent_Code] IS NULL,'', A.[AD_Parent_Code]) AS [AD_Parent_Code]
	 ,IIF(A.[Territory_Code] IS NULL, 'PHL', A.[Territory_Code]) AS [Territory_Code]
	--,IIF(A.[Office_Code] IS NULL, 'PHL', A.[Office_Code]) AS [Office_Code]
	,A.[ExplodedDate]
	,[Start_date]
    ,[End_Date]
    ,[Status]
	--, A.AD_Code AS AD_Code
	--, A.Grade AS AD_Grade
	, G1.AD_Code AS L1
	, G1.Grade AS L1G
	, G2.AD_Code AS L2
	, G2.Grade AS L2G
	, G3.AD_Code AS L3
	, G3.Grade AS L3G
	, G4.AD_Code AS L4
	, G4.Grade AS L4G

FROM [PowerBI].[DPO].[AD_STRUCTURE_Exploded] AS A
LEFT JOIN G AS G1 ON A.[AD_Parent_Code] = G1.AD_Code AND A.ExplodedDate = G1.ExplodedDate
LEFT JOIN G AS G2 ON G1.AD_Parent_Code = G2.AD_Code AND A.ExplodedDate = G2.ExplodedDate
LEFT JOIN G AS G3 ON G2.AD_Parent_Code = G3.AD_Code AND A.ExplodedDate = G3.ExplodedDate
LEFT JOIN G AS G4 ON G3.AD_Parent_Code = G4.AD_Code AND A.ExplodedDate = G4.ExplodedDate
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
         Begin Table = "A"
            Begin Extent = 
               Top = 9
               Left = 57
               Bottom = 206
               Right = 292
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "G1"
            Begin Extent = 
               Top = 9
               Left = 349
               Bottom = 206
               Right = 584
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "G2"
            Begin Extent = 
               Top = 9
               Left = 641
               Bottom = 206
               Right = 876
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "G3"
            Begin Extent = 
               Top = 207
               Left = 57
               Bottom = 404
               Right = 292
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "G4"
            Begin Extent = 
               Top = 207
               Left = 349
               Bottom = 404
               Right = 584
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
' , @level0type=N'SCHEMA',@level0name=N'DPO', @level1type=N'VIEW',@level1name=N'AD4'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'DPO', @level1type=N'VIEW',@level1name=N'AD4'
GO


