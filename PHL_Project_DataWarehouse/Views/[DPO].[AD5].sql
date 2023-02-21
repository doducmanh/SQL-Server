USE [PowerBI]
GO

/****** Object:  View [DPO].[AD5]    Script Date: 30/09/2022 16:27:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
CREATE   VIEW [DPO].[AD5] AS
WITH Q AS 
(
SELECT [AD_Code]
      --,[Grade]
      --,[AD_Parent_Code]
      ,[Territory_Code]
      --,[Office_Code]
      --,[Start_date]
      --,[End_Date]
      --,[Status]
      ,[ExplodedDate]
      --,[AD_Code]
      --,[AD_Grade]
	  --,[L1]
   --   ,[L1G]
   --   ,[L2]
   --   ,[L2G]
   --   ,[L3]
   --   ,[L3G]
   --   ,[L4]
   --   ,[L4G]
	  	  ,CASE
	  WHEN [AD_Grade] LIKE '%CDO' THEN [AD_Code]
	  WHEN [L1G] LIKE '%CDO' THEN [L1]
	  WHEN [L2G] LIKE '%CDO' THEN [L2]
	  WHEN [L3G] LIKE '%CDO' THEN [L3]
	  WHEN [L4G] LIKE '%CDO' THEN [L4]
	  ELSE 'PHL'
	  END AS L0
	  ,CASE
	  WHEN [AD_Grade] LIKE '%TD' THEN [AD_Code]
	  WHEN [L1G] LIKE '%TD' THEN [L1]
	  WHEN [L2G] LIKE '%TD' THEN [L2]
	  WHEN [L3G] LIKE '%TD' THEN [L3]
	  WHEN [L4G] LIKE '%TD' THEN [L4]
	  ELSE NULL
	  END AS L1
	  ,CASE
		  WHEN [AD_Grade] LIKE '%SRD' THEN [AD_Code]
		  WHEN [L1G] LIKE '%SRD' THEN [L1]
		  WHEN [L2G] LIKE '%SRD' THEN [L2]
		  WHEN [L3G] LIKE '%SRD' THEN [L3]
		  WHEN [L4G] LIKE '%SRD' THEN [L4]
	  ELSE NULL
	  END AS L2
	  ,CASE
	  WHEN [AD_Grade] IN('RD','RAD','ARD') THEN [AD_Code]
	  WHEN [L1G]  IN('RD','RAD','ARD') THEN [L1]
	  WHEN [L2G]  IN('RD','RAD','ARD') THEN [L2]
	  WHEN [L3G]  IN('RD','RAD','ARD') THEN [L3]
	  WHEN [L4G]  IN('RD','RAD','ARD') THEN [L4]
	  ELSE NULL
	  END AS L3
	  	  ,CASE
	  WHEN [AD_Grade] LIKE '%ZD' THEN [AD_Code]
	  WHEN [L1G] LIKE '%ZD' THEN [L1]
	  WHEN [L2G] LIKE '%ZD' THEN [L2]
	  WHEN [L3G] LIKE '%ZD' THEN [L3]
	  WHEN [L4G] LIKE '%ZD' THEN [L4]
	  ELSE NULL
	  END AS L4
	  	  ,CASE
	  WHEN [AD_Grade] LIKE '%SE' THEN [AD_Code]
	  WHEN [L1G] LIKE '%SE' THEN [L1]
	  WHEN [L2G] LIKE '%SE' THEN [L2]
	  WHEN [L3G] LIKE '%SE' THEN [L3]
	  WHEN [L4G] LIKE '%SE' THEN [L4]
	  ELSE NULL
	  END AS SE
  FROM [PowerBI].[DPO].[AD4]
  WHERE [PowerBI].[DPO].[AD4].[ExplodedDate] IS NOT NULL
)
SELECT Q.*
	, CONCAT( Q.L0 + '|', Q.L1 + '|', Q.L2 +'|', Q.L3 + '|', Q.L4) AS Structure
	, COALESCE (L0, L1, L2, L3, L4, SE, AD_Code) AS L0new
	, COALESCE (L1, L2, L3, L4, SE, AD_Code, L0) AS L1new
	, COALESCE (L2, L3, L4, SE, AD_Code, L1, L0) AS L2new
	, COALESCE (L3, L4, SE, AD_Code, L2, L1, L0) AS L3new
	, COALESCE (L4, SE, AD_Code, L3, L2, L1, L0) AS L4new
	--, Q.SE
FROM Q

--ORDER BY Q.AD_Code, Q.ExplodedDate
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[26] 4[12] 2[19] 3) )"
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
         Begin Table = "AD4"
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
' , @level0type=N'SCHEMA',@level0name=N'DPO', @level1type=N'VIEW',@level1name=N'AD5'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'DPO', @level1type=N'VIEW',@level1name=N'AD5'
GO


