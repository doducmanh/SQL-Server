USE [PowerBI]
GO

/****** Object:  View [DPO].[view_PS_in_DP_POSubmitDA]    Script Date: 30/09/2022 16:41:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- Note: from a. Phú IT
--View này lấy data toàn bộ phí đóng của khách hàng, nếu khách hàng đã đóng phí nhưng trạng thái hợp đồng là PS thì cũng sẽ có data.
--Chỉ trường hợp PS nhưng chưa đóng phí thì ko có thôi.
--View này dành cho bên DA tính thưởng cho đại lý nên ko chỉnh sửa gì trên view này nha 
CREATE VIEW [DPO].[view_PS_in_DP_POSubmitDA]
AS
SELECT IIF([APPLICATION_NUMBER] <> ''
		AND [CONTRACT_NUMBER] = '', 'PS_NNB', [CONTRACT_NUMBER]) AS [Policy No]
	--[CONTRACT_NUMBER] as [Policy No]
	,[MAIN_PRODUCT_CODE] AS [Product Code]
	,'' AS [Premium transaction]
	,'' AS [PREM TRAN NAME]
	,NULL AS [Premium Collected]
	,[TRANSACTION_DATE] AS [Collected Date]
	,NULL AS [Applied Premium Date]
	,NULL AS [FYP Before Discount]
	,NULL AS [FYP Discount]
	,[SUBMIT_AMT] AS [FYP]
	,NULL AS [RYP]
	,NULL AS [Topup Premium]
	,NULL AS [Premium Term]
	,NULL AS [Premium Year]
	,-- Với những hợp đồng chưa có [CONTRACT_NUMBER] nhưng có [APPLICATION_NUMBER]: gán [CONTRACT_STATUS] = 'PS_NNB' ĐỂ LỌC RA NHỮNG HỢP ĐỒNG POs submitted (not in NB)
	IIF([APPLICATION_NUMBER] <> ''
		AND [CONTRACT_NUMBER] = '', 'PS_NNB', [CONTRACT_STATUS]) AS [Policy Status]
	,NULL AS [Policy Year]
	,NULL AS [Policy Term]
	,'' AS [Frequency of Payment]
	,[ISSUED_DATE] AS [Issued Date]
	,[EFFECTIVE_DATE] AS [Effected Date]
	,NULL AS [Terminated Date]
	,NULL AS [Lapse Date]
	,NULL AS [Due date]
	,NULL AS [Next Due Date]
	,NULL AS [Transfer Date]
	,NULL AS [POLICY ACKNOWLED]
	,NULL AS [Sum Assure]
	,[SALEOFFICE] AS [Area Code]
	,NULL AS [Servicing Agent]
	,NULL AS [Freelook]
	,NULL AS [Proposal Receive Date]
	,NULL AS [RISK_COMMENCE_DATE]
	,NULL AS [Age_Customer]
	,[AGNTNUM] AS [Issuing Agent]
	,NULL AS [AFYP]
FROM [PowerBI].[DPO].[DP_POSubmitDA]
WHERE [CONTRACT_STATUS] IN (
		'PS'
		,''
		)
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
         Begin Table = "DP_POSubmitDA (dbo)"
            Begin Extent = 
               Top = 9
               Left = 57
               Bottom = 206
               Right = 348
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
' , @level0type=N'SCHEMA',@level0name=N'DPO', @level1type=N'VIEW',@level1name=N'view_PS_in_DP_POSubmitDA'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'DPO', @level1type=N'VIEW',@level1name=N'view_PS_in_DP_POSubmitDA'
GO


