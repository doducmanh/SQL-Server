USE DP_Manh
GO
--AD BONUS FULL PROCESS -- run on server local
--B1
INSERT INTO [DP_Manh].[dbo].[T_AD_BONUS_DETAIL_FYP]  
EXEC [DP_Manh].[dbo].[AD_BONUS_DETAILFYP] '2023-01-01'
GO
--B2
INSERT INTO [DP_Manh].[dbo].[T_AD_BONUS_DETAIL_AA]
EXEC [DP_Manh].[dbo].[AD_BONUS_DETAILAA] '2023-01-01'
GO
--B3
INSERT INTO [DP_Manh].[dbo].[T_AD_BONUS_PROBATION]
EXEC [DP_Manh].[dbo].[AD_BONUS_PROBATION] '2023-01-01'
GO
--B4
INSERT INTO [DP_Manh].[dbo].[T_AD_BONUS_ZDSZD_MTHLY]
EXEC [DP_Manh].[dbo].[AD_BONUS_ZDSZD_MTHLY] '2023-01-01'
GO
--B5
INSERT INTO [DP_Manh].[dbo].[T_AD_BONUS_PY2_RATE]
EXEC [DP_Manh].[dbo].[AD_PY2_BY_MONTHLY] '2023-01-01'
--B6
GO
INSERT INTO [DP_Manh].[dbo].[T_AD_BONUS_DETAIL_RYP]
EXEC [DP_Manh].[dbo].[AD_BONUS_DETAILRYP] '2023-01-01'
--Mỗi quý uncomment - nhập tháng cuối quý
----B7
--GO
--INSERT INTO [DP_Manh].[dbo].[T_AD_BONUS_RADSTD_QTRLY]
--EXEC [DP_Manh].[dbo].[AD_BONUS_RADSTD_QTRLY] '2023-01-01'
----B8
--GO
--INSERT INTO [DP_Manh].[dbo].[T_AD_BONUS_RYP_QTRLY]
--EXEC [DP_Manh].[dbo].[AD_BONUS_RYP_QTRLY] '2023-01-01'








