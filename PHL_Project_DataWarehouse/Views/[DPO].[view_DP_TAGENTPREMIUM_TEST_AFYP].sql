USE [PowerBI]
GO

/****** Object:  View [DPO].[view_DP_TAGENTPREMIUM_TEST_AFYP]    Script Date: 30/09/2022 16:40:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- view calculate AFYP from table :
-- [dbo].[DP_TAGENTPREMIUM_TEST]
-- [dbo].[DP_TDAILYSALES_DA]
CREATE VIEW [DPO].[view_DP_TAGENTPREMIUM_TEST_AFYP]
AS
SELECT *
	,CASE 
		WHEN (
				YEAR([Issued Date]) = YEAR([Collected Date])
				AND MONTH([Issued Date]) = MONTH([Collected Date])
				)
			THEN (([FYP] / Frequency) + ([Topup Premium] * 0.1))
		WHEN (
				(
					YEAR([Issued Date]) <> YEAR([Collected Date])
					OR MONTH([Issued Date]) <> MONTH([Collected Date])
					)
				AND [Policy Status] = 'IF'
				)
			THEN 0
		WHEN (
				(
					YEAR([Issued Date]) <> YEAR([Collected Date])
					OR MONTH([Issued Date]) <> MONTH([Collected Date])
					)
				AND ([FYP] + [Topup Premium] < 0)
				)
			THEN (([FYP] / Frequency) + ([Topup Premium] * 0.1))
		WHEN (
				([Issued Date] IS NULL)
				AND [Policy Status] IN (
					'DC'
					,'PO'
					,'NT'
					,'WD'
					,'CF'
					)
				)
			THEN ([FYP] + ([Topup Premium] * 0.1))
		ELSE 0
		END AS AFYP_new
FROM (
	SELECT *
		,CASE 
			WHEN (
					c.[Contract Type] NOT LIKE 'UL%'
					AND [Frequency of Payment] = 'Yearly'
					)
				THEN 1
			WHEN (
					c.[Contract Type] NOT LIKE 'UL%'
					AND [Frequency of Payment] = 'Half-year'
					)
				THEN 0.53
			WHEN (
					c.[Contract Type] NOT LIKE 'UL%'
					AND [Frequency of Payment] = 'Quarterly'
					)
				THEN 0.27
			WHEN (
					c.[Contract Type] NOT LIKE 'UL%'
					AND [Frequency of Payment] = 'Monthly'
					)
				THEN 0.09
			WHEN (
					c.[Contract Type] LIKE 'UL%'
					AND [Frequency of Payment] = 'Yearly'
					)
				THEN 1
			WHEN (
					c.[Contract Type] LIKE 'UL%'
					AND [Frequency of Payment] = 'Half-year'
					)
				THEN 0.5
			WHEN (
					c.[Contract Type] LIKE 'UL%'
					AND [Frequency of Payment] = 'Quarterly'
					)
				THEN 0.25
			END AS Frequency
	FROM (
		SELECT *
		FROM [DPO].[view_DP_TAGENTPREMIUM_TEST_PS] a
		LEFT JOIN (
			SELECT DISTINCT [Policy_Number]
				,[Contract Type]
			FROM [DPO].[DP_TDAILYSALES_DA]
			) b ON a.[Policy No] = b.Policy_Number
		) AS c
	) AS q
GO


