USE [PowerBI]
GO

/****** Object:  UserDefinedFunction [DPO].[udf_AA_cutoff]    Script Date: 30/09/2022 16:52:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [DPO].[udf_AA_cutoff] 
(
	-- Add the parameters for the function here
	@date AS CHAR(8) = '20220831',
	@month AS CHAR(6) = '202208'
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

		,DP_TAGENTPREMIUM_TEST_CUTOFF
	AS (
		SELECT *
		FROM [PowerBI].[DPO].[DP_TAGENTPREMIUM_TEST_CUTOFF]
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
		,DP_TDAILYSALES_DA_CUTOFF
	AS (
		SELECT *
		FROM [PowerBI].[DPO].[DP_TDAILYSALES_DA_CUTOFF]
		WHERE CUTOFF = @date
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
						AND [PowerBI].[DPO].[udf_month_diff](IIF(B.Date_Appointed > SFC_Temp2.[Issued Date], B.Date_Appointed, SFC_Temp2.[Issued Date]), A.[Collected Date]) > IIF(A.[Collected Date] >= '2021-12-01', 9, 6)
						)
					--AND [PowerBI].[DPO].[udf_month_diff](IIF(SFC_Temp2.[Next_Issued_Date] IS NOT NULL,SFC_Temp2.[Next_Issued_Date],SFC_Temp2.[Issued Date]) ,A.[Collected Date]) > 0
					OR (
						SFC_Temp2.[Issued Date] IS NULL
						AND [PowerBI].[DPO].[udf_month_diff](B.Date_Appointed, A.[Collected Date]) > IIF(A.[Collected Date] >= '2021-12-01', 9, 6)
						)
					)
				AND A.[Collected Date] >= '2021-01-01'
				AND C.GRADE = 'IC'
				AND [PowerBI].[DPO].[udf_month_diff](A.[Issued Date], A.[Collected Date]) > IIF(A.[Collected Date] >= '2021-12-01', 9, 6)
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
		,DateType2
	AS (
		SELECT *
		FROM (
			SELECT [Policy No]
				,MIN([Issued Date]) AS FirstDate
				,MAX([Collected Date]) AS LastDate
				,[Policy Status]
				,[Issuing Agent]
			FROM view_premium
			WHERE [Policy Status] <> 'PS_NNB' --AND [Issued Date] IS NOT NULL
			GROUP BY [Policy No]
				,[Policy Status]
				,[Issued Date]
				,[Issuing Agent]
			) AS DateType
		UNPIVOT(DateActive FOR DateType IN (
					FirstDate
					,LastDate
					)) UNPVT
		)

		,DW_Agent
	AS (
		SELECT Agent_Number AS Code
			,Agent_Name AS Name
			,Grade
			,Agent_Status AS STATUS
			,Date_Appointed
			,Terminated_date
			,Sales_Unit_Code AS AD_Code
			,Sales_Unit AS AD_Name
			,Area_Name AS Office
			,Sales_Unit_Code + Area_Name AS ID
		FROM Main_AGENT_INFO_DA_CUTOFF
		WHERE (Agent_Name NOT LIKE '%BHNT%')
			AND (Sales_Unit_Code NOT LIKE 'ADM00')
		)
		,TEMP
	AS (
		SELECT [Issuing Agent]
			,AG.Date_Appointed
			,[Policy No]
			,DateActive
			,CountPolicy
			,AG.AD_Code
			,AG.AD_Code + CONVERT(CHAR(8), [DateActive], 112) AS ID
			,DATEDIFF(DAY, AG.Date_Appointed, DateActive) AS DateDif
		FROM (
			SELECT [Policy No]
				,[Issuing Agent]
				,DateActive
				,CASE 
					WHEN DateType = 'FirstDate'
						THEN 1
					WHEN [Policy Status] IN (
							'FL'
							,'PO'
							,'DC'
							,'WD'
							,'NT'
							,'CF'
							)
						THEN - 1
					ELSE 0
					END AS CountPolicy
			FROM DateType2
			) AS DS
		LEFT JOIN DW_Agent AG ON DS.[Issuing Agent] = AG.Code
		WHERE CountPolicy <> 0
		)
		,Manh_DW_AD_DailyPolicy
	AS (
		SELECT *
			--CASE
			--    WHEN condition1 THEN result1
			--    WHEN condition2 THEN result2
			--    WHEN conditionN THEN resultN
			--    ELSE result
			--END;
			,CASE 
				WHEN TEMP.DateActive < '2022/01/01'
					THEN CONVERT(CHAR(6), TEMP.[DateActive], 112)
				WHEN TEMP.DateActive <= '2022/01/27'
					THEN '202201'
				WHEN TEMP.DateActive <= '2022/02/28'
					THEN '202202'
				WHEN TEMP.DateActive <= '2022/03/29'
					THEN '202203'
				WHEN TEMP.DateActive <= '2022/04/29'
					THEN '202204'
				WHEN TEMP.DateActive <= '2022/05/31'
					THEN '202205'
				WHEN TEMP.DateActive <= '2022/06/30'
					THEN '202206'
				WHEN TEMP.DateActive <= '2022/07/31'
					THEN '202207'
				WHEN TEMP.DateActive <= '2022/08/31'
					THEN '202208'
				WHEN TEMP.DateActive <= '2022/09/30'
					THEN '202209'
				WHEN TEMP.DateActive <= '2022/10/31'
					THEN '202210'
				WHEN TEMP.DateActive <= '2022/11/30'
					THEN '202211'
				WHEN TEMP.DateActive <= '2022/12/31'
					THEN '202212'
				ELSE CONVERT(CHAR(6), TEMP.[DateActive], 112)
				END AS Cutoff_Month
		FROM TEMP
		)
		,AA_Temp1
	AS (
		SELECT [Issuing Agent]
			--,[Date_Appointed]
			,[Policy No]
			--,MONTH([DateActive]) AS MONTH_ACTIVE
			,Cutoff_Month AS MONTH_ACTIVE
			,SUM(CountPolicy) AS NET_CC
		--,[AD_Code]
		--,[ID]
		--,[DateDif]
		FROM Manh_DW_AD_DailyPolicy
		GROUP BY [AD_Code]
			,Cutoff_Month
			--,MONTH([DateActive])
			--,YEAR([DateActive])
			,[Policy No]
			,[Issuing Agent]
		HAVING SUM(CountPolicy) <> 0
		)
		,AA_Temp2
	AS (
		SELECT CONCAT (
				AA_Temp1.[Issuing Agent]
				,AA_Temp1.MONTH_ACTIVE
				) AS ID
			,AA_Temp1.[Issuing Agent]
			,AA_Temp1.MONTH_ACTIVE
			,SUM(NET_CC) AS CASE_COUNT
			,IIF(SUM(NET_CC) > 0, 1, 0) AS Active_Agent
			,CASE
				WHEN SUM(NET_CC) > 0 THEN 1
				WHEN SUM(NET_CC) = 0 THEN 0
				ELSE -1
				END AS AA_AD_Bonus
			
		FROM AA_Temp1
		GROUP BY AA_Temp1.[Issuing Agent]
			,AA_Temp1.MONTH_ACTIVE
			--ORDER BY AA_Temp1.[Issuing Agent] DESC
		)
		,Cal_Active_Agent_by_Month_MANH
	AS (
		SELECT AA_Temp2.ID
			,DATEFROMPARTS(AA_Temp2.MONTH_ACTIVE / 100, AA_Temp2.MONTH_ACTIVE % 100, 1) AS ID_DATE
			,AA_Temp2.[Issuing Agent]
			,AA_Temp2.MONTH_ACTIVE
			,AA_Temp2.CASE_COUNT
			,AA_Temp2.Active_Agent
			,AA_Temp2.AA_AD_Bonus
		FROM AA_Temp2
			--WHERE [Issuing Agent] = '60057112'
		)
	SELECT *
	FROM Cal_Active_Agent_by_Month_MANH 
	WHERE MONTH_ACTIVE = @month
)
GO


