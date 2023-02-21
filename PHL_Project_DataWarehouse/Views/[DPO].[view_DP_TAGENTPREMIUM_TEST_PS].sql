USE [PowerBI]
GO

/****** Object:  View [DPO].[view_DP_TAGENTPREMIUM_TEST_PS]    Script Date: 30/09/2022 16:40:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [DPO].[view_DP_TAGENTPREMIUM_TEST_PS]
AS
SELECT [Policy No]
	,[Product Code]
	,[Premium transaction]
	,[PREM TRAN NAME]
	,[Premium Collected]
	,[Collected Date]
	,[Applied Premium Date]
	,[FYP Before Discount]
	,[FYP Discount]
	,[FYP]
	,[RYP]
	,[Topup Premium]
	,[Premium Term]
	,[Premium Year]
	,[Policy Status]
	,[Policy Year]
	,[Policy Term]
	,[Frequency of Payment]
	,[Issued Date]
	,[Effected Date]
	,[Terminated Date]
	,[Lapse Date]
	,[Due date]
	,[Next Due Date]
	,[Transfer Date]
	,[POLICY ACKNOWLED]
	,[Sum Assure]
	,[Area Code]
	,[Servicing Agent]
	,[Freelook]
	,[Proposal Receive Date]
	,[RISK_COMMENCE_DATE]
	,[Age_Customer]
	,[Issuing Agent]
	,[AFYP] /*,[SA_Next_Issued_Date]*/
	,[SFC]
/*,[SA_Grade]*/
FROM [PowerBI].[DPO].[SFC Dynamic]

UNION ALL

SELECT *
	,'' AS SFC
FROM [DPO].[view_PS_in_DP_POSubmitDA]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[24] 4[13] 2[12] 3) )"
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
' , @level0type=N'SCHEMA',@level0name=N'DPO', @level1type=N'VIEW',@level1name=N'view_DP_TAGENTPREMIUM_TEST_PS'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'DPO', @level1type=N'VIEW',@level1name=N'view_DP_TAGENTPREMIUM_TEST_PS'
GO


