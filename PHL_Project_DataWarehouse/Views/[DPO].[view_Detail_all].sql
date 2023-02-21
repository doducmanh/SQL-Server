USE [PowerBI]
GO

/****** Object:  View [DPO].[view_Detail_all]    Script Date: 30/09/2022 16:39:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- VIEW DETAIL FROM :	[dbo].[DP_TAGENTPREMIUM_TEST]
--						[dbo].[Main_AGENT_INFO_DA]
--						[DPO].[view_DP_TAGENTPREMIUM_TEST_AFYP]
-- WHERE 	YEAR([Collected Date]) = 
--			AND MONTH([Collected Date])  
--			AND a.[Servicing Agent] NOT LIKE '69%'		-- KHONG CO AGENT OF PHL SERVICING
--			AND b.[Area_Name] NOT LIKE 'A%'				-- KHONG CO MEKONG 3

----------------------------------------------------

CREATE    VIEW [DPO].[view_Detail_all] AS

SELECT *,
		Gross_AFYP + Cancel_AFYP	AS NET_AFYP,
		Gross_FYP + Cancel_FYP		AS NET_FYP
FROM ( 
SELECT 
		 [Servicing_Agent_Code]
		,[Servicing_Agent_Name]
		,[Grade]
		,[Date_Appointed]
		,[Agent_Status]
		,[Policy No]
		,[AD_CODE]
		,[Issued Date]
		,[Policy Status]
		,[Collected Date]
--		,MIN([Collected Date]) AS [Collected Date]
		,[Area Code]
		,IIF([Policy Status] IN ('IF','PS'),		SUM([SUM_AFYP])	, 0)	AS Gross_AFYP
		,IIF([Policy Status] IN ('IF','PS'),		SUM([SUM_FYP])	+ SUM(TOPUP), 0)	AS Gross_FYP
		,IIF([Policy Status] IN ('DC','FL','PO'),   SUM([SUM_AFYP])	, 0)	AS Cancel_AFYP
		,IIF([Policy Status] IN ('DC','FL','PO'),	SUM([SUM_FYP])  + SUM(TOPUP), 0)	AS Cancel_FYP
		,[Issuing_Agent_Code]
		,[Issuing_Agent_Name]
	FROM 
	(	SELECT 
			 a.[Servicing Agent] AS	'Servicing_Agent_Code'
			,c.[Agent_Name]	AS	'Servicing_Agent_Name'
			,c.[Grade]			
			,c.[Date_Appointed]	
			,c.[Agent_Status]		
			,a.[Policy No]
			,a.[Issued Date]		
			,a.[Policy Status]	
			,d.[AD_CODE]
			,a.[Collected Date]
--			,MIN(a.[Collected Date])	AS [Collected Date]
			,a.[Area Code]
			,SUM(a.[FYP])				AS SUM_FYP
			,SUM(a.[AFYP_new])			AS SUM_AFYP
			,SUM(a.[RYP])				AS SUM_RYP
			,SUM(a.[Topup Premium])*0.1 AS TOPUP			
			,a.[Issuing Agent]			AS 'Issuing_Agent_Code'
			,b.[Agent_Name]				AS 'Issuing_Agent_Name'			
		FROM [DPO].[view_DP_TAGENTPREMIUM_TEST_AFYP] a 
			JOIN [DPO].[Main_AGENT_INFO_DA] b 
				ON a.[Issuing Agent] = b.[Agent_Number]
					JOIN [DPO].[Main_AGENT_INFO_DA] c		
						ON a.[Servicing Agent] = c.[Agent_Number]
							JOIN [DPO].[Main_POLICY_INFO] d
								ON a.[Policy No] = d.[POLICY_NUMBER]

		WHERE 
			--	YEAR([Collected Date]) = 2021
			-- AND MONTH([Collected Date]) = 1 
				a.[Servicing Agent] NOT LIKE '69%' 
			AND b.[Area_Name] NOT LIKE 'A%'		-- NOT MK3
		GROUP BY
			 a.[Servicing Agent]
			,c.[Agent_Name]
			,c.[Grade]			
			,c.[Date_Appointed]	
			,c.[Agent_Status]		
			,a.[Policy No]
			,d.[AD_CODE]
			,a.[Issued Date]		
			,a.[Policy Status]	
			,a.[Collected Date]
			,a.[Area Code]
--			,a.[Effected Date]
			,a.[Issuing Agent]
			,b.[Agent_Name]
) q

GROUP BY 
		 [Servicing_Agent_Code]
		,[Servicing_Agent_Name]
		,[Grade]
		,[Date_Appointed]
		,[Agent_Status]
		,[Policy No]
		,[Collected Date]
		,[AD_CODE]
		,[Issued Date]
		,[Area Code]
		,[Policy Status]
		,SUM_RYP
		,[Issuing_Agent_Code]
		,[Issuing_Agent_Name]
	HAVING (SUM(SUM_FYP) + SUM(TOPUP)) != 0
) w
GO


