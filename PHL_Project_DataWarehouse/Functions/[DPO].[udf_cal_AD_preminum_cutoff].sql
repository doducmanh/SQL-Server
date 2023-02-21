USE [PowerBI]
GO

/****** Object:  UserDefinedFunction [DPO].[udf_cal_AD_preminum_cutoff]    Script Date: 30/09/2022 16:57:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [DPO].[udf_cal_AD_preminum_cutoff] 
(
	-- Add the parameters for the function here
	@date AS DATE = '2022-08-31',
	@start AS DATE = '2022-08-01',
	@end AS DATE = '2022-08-31'
)
RETURNS TABLE
AS
RETURN
(
	WITH DP_POSubmitDA_CUTOFF
	AS (
		SELECT *
		FROM [PowerBI].[DPO].[DP_POSubmitDA_CUTOFF]
		WHERE CUTOFF = @date
		)

		,Main_AGENT_INFO_DA_CUTOFF
	AS (
		SELECT *
		FROM [PowerBI].[DPO].[Main_AGENT_INFO_DA_CUTOFF]
		WHERE CUTOFF = @date
		)

		,Main_AGENT_HISTORY_CUTOFF
	AS (
		SELECT *
		FROM [PowerBI].[DPO].[Main_AGENT_HISTORY_CUTOFF]
		WHERE CUTOFF = @date
		)
		,DP_AGPOLTRANSFER_CUTOFF
	AS (
		SELECT *
		FROM [PowerBI].[DPO].[DP_AGPOLTRANSFER_CUTOFF]
		WHERE CUTOFF = @date
		)
		,DP_TDAILYSALES_DA_CUTOFF
	AS (
		SELECT *
		FROM [PowerBI].[DPO].[DP_TDAILYSALES_DA_CUTOFF]
		WHERE CUTOFF = @date
		)
		,DP_DA_Daily_DC_PO_WD_NT_CUTOFF
	AS (
		SELECT *
		FROM [PowerBI].[DPO].[DP_DA_Daily_DC_PO_WD_NT_CUTOFF]
		WHERE CUTOFF = @date
		)
		,DP_TAGENTPREMIUM_TEST_CUTOFF
	AS (
		SELECT *
		FROM [PowerBI].[DPO].[DP_TAGENTPREMIUM_TEST_CUTOFF]
		WHERE CUTOFF = @date
		)
		,Main_POLICY_INFO_CUTOFF
	AS (
		SELECT *
		FROM [PowerBI].[DPO].[Main_POLICY_INFO]
		--FROM [PowerBI].[DPO].[Main_POLICY_INFO_CUTOFF]
		--WHERE CUTOFF = @date
		)

		,view_PS_in_DP_POSubmitDA
	AS (
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
		FROM DP_POSubmitDA_CUTOFF
		WHERE [CONTRACT_STATUS] IN (
				'PS'
				,''
				)
		)
		,SFC_Temp1
	AS (
		SELECT A.[Policy No]
			,A.[Issuing Agent]
			,A.[Policy Status]
			,C.Date_Appointed AS IA_Appointed
			,A.[Issued Date]
		--,LEAD(A.[Issued Date]) OVER (PARTITION BY A.[Issuing Agent] ORDER BY A.[Issued Date]) AS Next_Issued_Date
		FROM DP_TAGENTPREMIUM_TEST_CUTOFF AS A
		LEFT JOIN Main_AGENT_INFO_DA_CUTOFF AS C ON A.[Issuing Agent] = C.Agent_Number
		WHERE A.[Policy Status] = 'IF'
		GROUP BY A.[Policy No]
			,A.[Issued Date]
			,A.[Issuing Agent]
			,A.[Policy Status]
			,C.Date_Appointed
		)
		,SFC_Temp2
	AS (
		SELECT SFC_Temp1.*
			,LEAD(SFC_Temp1.[Issued Date]) OVER (
				PARTITION BY SFC_Temp1.[Issuing Agent] ORDER BY SFC_Temp1.[Issued Date]
				) AS Next_Issued_Date
		FROM SFC_Temp1
			--WHERE SFC_Temp1.[Issuing Agent] = '60015683'
			--ORDER BY SFC_Temp1.[Issued Date]
		)
		,[SFC Dynamic]
	AS (
		SELECT A.*
			--A.[Policy No]    
			--      --,A.[Issued Date]
			--      ,A.[Servicing Agent]
			--      --,A.[Issuing Agent]
			--	  ,A.[Policy Status]
			,B.Date_Appointed AS SA_Appointed
			--,A.[Collected Date]
			,SFC_Temp2.[Issued Date] AS SA_Last_Issued_Date
			,SFC_Temp2.[Next_Issued_Date] AS SA_Next_Issued_Date
			,IIF((
					(
						SFC_Temp2.[Issued Date] IS NOT NULL
						AND dpo.udf_month_diff(IIF(B.Date_Appointed > SFC_Temp2.[Issued Date], B.Date_Appointed, SFC_Temp2.[Issued Date]), A.[Collected Date]) > IIF(A.[Collected Date] >= '2021-12-01', 9, 6)
						)
					--AND dpo.udf_month_diff(IIF(SFC_Temp2.[Next_Issued_Date] IS NOT NULL,SFC_Temp2.[Next_Issued_Date],SFC_Temp2.[Issued Date]) ,A.[Collected Date]) > 0
					OR (
						SFC_Temp2.[Issued Date] IS NULL
						AND dpo.udf_month_diff(B.Date_Appointed, A.[Collected Date]) > IIF(A.[Collected Date] >= '2021-12-01', 9, 6)
						)
					)
				AND A.[Collected Date] >= '2021-01-01'
				AND C.GRADE = 'IC'
				AND dpo.udf_month_diff(A.[Issued Date], A.[Collected Date]) > IIF(A.[Collected Date] >= '2021-12-01', 9, 6)
				AND EOMONTH(IIF(SFC_Temp2.[Next_Issued_Date] IS NULL, '2099-12-31', SFC_Temp2.[Next_Issued_Date])) <> EOMONTH(A.[Collected Date]), 'S', '') AS SFC
			,C.GRADE AS SA_Grade
		FROM DP_TAGENTPREMIUM_TEST_CUTOFF AS A
		LEFT JOIN Main_AGENT_INFO_DA_CUTOFF AS B ON A.[Servicing Agent] = B.Agent_Number
		LEFT JOIN SFC_Temp2 ON A.[Servicing Agent] = SFC_Temp2.[Issuing Agent]
			AND A.[Collected Date] >= SFC_Temp2.[Issued Date]
			AND A.[Collected Date] < IIF(SFC_Temp2.[Next_Issued_Date] IS NULL, '2099-12-31', SFC_Temp2.[Next_Issued_Date])
		LEFT JOIN Main_AGENT_HISTORY_CUTOFF AS C ON A.[Servicing Agent] = C.[AGENT CODE]
			AND A.[Collected Date] >= C.CURRFROM
			AND A.[Collected Date] < IIF(C.CURRTO IS NULL, '2099-12-31', C.CURRTO)
			--WHERE SFC   = 'S'
			--ORDER BY A.[Collected Date]
			--)
			--WHERE a.[Policy No] = '80044835'
		)
		,view_DP_TAGENTPREMIUM_TEST_PS
	AS (
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
		FROM [SFC Dynamic]
		--FROM DP_TAGENTPREMIUM_TEST_CUTOFF
	
		UNION ALL
	
		SELECT *
			,'' AS SFC
		FROM view_PS_in_DP_POSubmitDA
		)
		,view_DP_TAGENTPREMIUM_TEST_AFYP
	AS (
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
				FROM view_DP_TAGENTPREMIUM_TEST_PS a
				LEFT JOIN (
					SELECT DISTINCT [Policy_Number]
						,[Contract Type]
					FROM DP_TDAILYSALES_DA_CUTOFF
					WHERE CUTOFF = @date
					) b ON a.[Policy No] = b.Policy_Number
				) AS c
			) AS q
		)
		,view_premium
	AS (
		SELECT [Policy No]
			,[Product Code]
			,[Collected Date]
			,[Policy Status]
			,[Issuing Agent]
			,[Issued Date]
			,[Proposal Receive Date]
			,[Servicing Agent]
			,[SFC]
			,[FYP]
			,[RYP]
			,[Topup Premium]
			,[AFYP_new] AS AFYP
			,[Area Code]
			,[POLICY ACKNOWLED]
			,[Freelook]
		FROM view_DP_TAGENTPREMIUM_TEST_AFYP
			--WHERE [Collected Date] > '2020-01-01'
		)
		,VP
	AS (
		SELECT [Area Code]
			,[Policy No]
			,[Product Code]
			,[Collected Date]
			,[Issued Date]
			,[Proposal Receive Date]
			,[Policy Status]
			,[Issuing Agent]
			,[Servicing Agent]
			,[SFC]
			,SUM(FYP) AS FYP
			,SUM(RYP) AS RYP
			,SUM([Topup Premium]) AS Topup
			,SUM(AFYP) AS AFYP
			,[POLICY ACKNOWLED]
			,[Freelook]
		FROM view_premium AS A
		--WHERE A.[Servicing Agent] IS  NULL
		GROUP BY [Policy No]
			,[Product Code]
			,[Collected Date]
			,[Policy Status]
			,[Issuing Agent]
			,[Issued Date]
			,[Proposal Receive Date]
			,[Servicing Agent]
			,[SFC]
			,[Area Code]
			,[POLICY ACKNOWLED]
			,[Freelook]
		)
		--Get transfer date and exclude TAPSU Agents
		,TAPSU_LIST
	AS (
		SELECT [AGENT CODE]
		--,[STATUS]
		--,[OLD GRADE]
		--,[GRADE]
		--,[CURRFROM]
		--,[CURRTO]
		--,[New Leader Code]
		--,[Old Leader Code]
		--,[NOTE]
		--,[CLUB CLASS]
		--,[EFFECTIVE DATE CLUB CLASS]
		--,[Reason mark club class]
		--,[EXPIRED_LICENSE_DATE]
		--,[RN]
		FROM Main_AGENT_HISTORY_CUTOFF
		--WHERE [AGENT CODE] = '60046644' 
		WHERE [NOTE] LIKE '%TAPSU'
	
		UNION
	
		SELECT [Agent_Number]
		--,[License_No]
		FROM Main_AGENT_INFO_DA_CUTOFF
		WHERE [License_No] = 'TAPSU'
		)
		,Transfer_Policy_1
	AS (
		SELECT [CHDRNUM] AS [Policy No]
			--,[Old Agent]
			--,[Old Agent Effect From ]
			,[Current Agent]
			,MAX([Current Agent Effect From]) AS [Current Agent Effect From]
		--,[User]
		--,[Old Agent Name]
		--,[Current Agent Name]
		FROM DP_AGPOLTRANSFER_CUTOFF
		--WHERE [Current Agent] NOT IN (SELECT TAPSU_LIST.[AGENT CODE] FROM TAPSU_LIST)
		GROUP BY [CHDRNUM]
			,[Current Agent]
			--,[Old Agent]
		)
		,Transfer_Policy_2
	AS (
		SELECT A.[Policy No]
			,A.[Current Agent]
			,A.[Current Agent Effect From]
			,B.ISSUED_DATE
			,C.Appointed_TAPSU
			,IIF(C.Appointed_TAPSU <= B.ISSUED_DATE
				AND A.[Current Agent] IN (
					SELECT TAPSU_LIST.[AGENT CODE]
					FROM TAPSU_LIST
					), NULL, A.[Current Agent Effect From]) AS Transfer_Date
		FROM Transfer_Policy_1 AS A
		LEFT JOIN Main_POLICY_INFO_CUTOFF AS B ON A.[Policy No] = B.POLICY_NUMBER
		LEFT JOIN Main_AGENT_INFO_DA_CUTOFF AS C ON A.[Current Agent] = C.Agent_Number
		)
		,Transfer_Policy
	AS (
		SELECT A.[Policy No]
			,MAX(A.Transfer_Date) AS TRANSFER_DATE
		FROM Transfer_Policy_2 AS A
		--WHERE A.[Policy No] = '80093228'
		GROUP BY A.[Policy No]
		)
		--- Add IP 
		,Prem_Temp3
	AS (
		SELECT *
		FROM (
			SELECT [Agent Code]
				,[Policy_Number]
				,[Issuing_Agent]
				,[Contract Type]
				,[Component_Code]
				,[After_Discount_Premium]
			FROM DP_TDAILYSALES_DA_CUTOFF
		
			UNION ALL
		
			SELECT [Agent Code]
				,[Policy_Number]
				,[Issuing_Agent]
				,[Contract Type]
				,[Component_Code]
				,[After_Discount_Premium]
			FROM DP_DA_Daily_DC_PO_WD_NT_CUTOFF
			) AS A
		)
		,Prem_Temp2
	AS (
		SELECT CONCAT (
				Policy_Number
				,Component_Code
				) AS ID_Policy_Component
			,SUM(After_Discount_Premium) AS After_Discount_Premium_IP
		FROM Prem_Temp3
		GROUP BY Policy_Number
			,Component_Code
		)
		,B
	AS (
		SELECT CONCAT (
				[Policy No]
				,[Product Code]
				) AS ID_Policy_Component
			,[Policy No]
			,[Product Code]
			,min([Collected Date]) AS Min_Collected_Date
		FROM DP_TAGENTPREMIUM_TEST_CUTOFF
		GROUP BY [Policy No]
			,[Product Code]
		)
		,C
	AS (
		SELECT B.ID_Policy_Component
			,B.[Policy No]
			,B.Min_Collected_Date
			,B.[Product Code]
			,Prem_Temp2.After_Discount_Premium_IP
		FROM B
		JOIN Prem_Temp2 ON B.ID_Policy_Component = Prem_Temp2.ID_Policy_Component
		)
		--- end add IP
		,Prem_Temp1
	AS (
		SELECT VP.[Area Code]
			,VP.[Policy No]
			,VP.[Product Code]
			,VP.[Collected Date]
			,VP.[Issued Date]
			,VP.[Proposal Receive Date]
			,VP.[Policy Status]
			,VP.[Issuing Agent]
			,VP.[Servicing Agent]
			,VP.[SFC]
			,VP.FYP
			,VP.RYP
			,VP.Topup
			,VP.AFYP
			,VP.[POLICY ACKNOWLED]
			,VP.[Freelook]
			,A.[Sales_Unit_Code] SA_AD_Code
			,A.Agent_Name AS SA_Name
			,A.[Grade] AS SA_Grade
			,A.Date_Appointed AS SA_Date_Appointed
			,A.[Agent_Status] AS SA_Status
			,A.Appointed_TAPSU AS SA_Date_Appointed_TAPSU
			,A.SFC AS Current_SFC
			,A.Terminated_date AS SA_Terminated_date
			,A.ID_Card AS SA_ID
			,P.PO_IDNUMBER AS PO_ID
			,B.Agent_Number AS PO_Agent_Number
			,B.Area_Name
			,B.Date_Appointed AS PO_Date_Appointed
			,B.Terminated_date AS PO_Terminated_date
			,CASE 
				WHEN A.ID_Card = P.PO_IDNUMBER
					THEN 'SELF_OWNER'
				WHEN P.PO_IDNUMBER IN (
						SELECT ID_Card
						FROM Main_AGENT_INFO_DA_CUTOFF
						)
					AND B.Agent_Status = 'Enforce'
					AND VP.[Servicing Agent] NOT LIKE '699*'
					AND B.Area_Name <> 'SEP'
					AND A.Agent_Name NOT LIKE 'DUMMY%'
					AND B.Appointed_TAPSU <= VP.[Proposal Receive Date]
					THEN 'CROSS_SALES'
				ELSE 'CUSTOMER'
				END AS Cross_Sales
			,IIF(VP.[Collected Date] < A.Date_Appointed
				OR A.License_No = 'TAPSU', 1, 0) AS TAPSU_SALES
			,T.TRANSFER_DATE AS Transfer_Policy_Date
			,A.Sales_Unit_Code AS AD_Code
			,A.Sales_Unit_Code + REPLACE(CAST(VP.[Collected Date] AS DATE), '-', '') AS ID
		FROM VP
		LEFT OUTER JOIN Main_AGENT_INFO_DA_CUTOFF AS A ON VP.[Servicing Agent] = A.[Agent_Number]
		--(A.Agent_Name NOT LIKE '%BHNT%') AND (A.Sales_Unit_Code NOT LIKE 'ADM00')
		LEFT OUTER JOIN Main_POLICY_INFO_CUTOFF AS P ON VP.[Policy No] = P.POLICY_NUMBER
		LEFT OUTER JOIN Main_AGENT_INFO_DA_CUTOFF AS B ON P.PO_IDNUMBER = B.ID_Card
		--WHERE VP.[Servicing Agent] IS NOT NULL
		--LEFT OUTER JOIN Transfer_Policy_Last_Agent AS Y
		--ON VP.[Policy No] = Y.[Policy No] AND VP.[Collected Date] >= Y.[Current Agent Effect From]
		LEFT OUTER JOIN Transfer_Policy AS T ON VP.[Policy No] = T.[Policy No]
		)
		,Cal_AD_Premium
	AS (
		SELECT Prem_Temp1.*
			,C.After_Discount_Premium_IP
		FROM Prem_Temp1
		LEFT JOIN C ON Prem_Temp1.[Policy No] = C.[Policy No]
			AND Prem_Temp1.[Product Code] = C.[Product Code]
			AND Prem_Temp1.[Collected Date] = C.Min_Collected_Date
			--where Prem_Temp1.[Policy No] = '80058942'
			--order by [Policy No], [Collected Date] asc
			--WHERE Cross_Sales = 'CROSS_SALES' 
			----AND 
			--Prem_Temp1.[Policy No] = '80103007'
		)
	SELECT *
	FROM Cal_AD_Premium
	WHERE SFC <> 'S' AND ([Collected Date] BETWEEN @start AND @end)
)
GO


