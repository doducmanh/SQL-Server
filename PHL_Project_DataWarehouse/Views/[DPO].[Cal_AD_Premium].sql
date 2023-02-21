USE [PowerBI]
GO

/****** Object:  View [DPO].[Cal_AD_Premium]    Script Date: 30/09/2022 16:31:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [DPO].[Cal_AD_Premium]
AS
WITH VP
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
	FROM DPO.view_premium AS A
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
	FROM [PowerBI].[DPO].[Main_AGENT_HISTORY]
	--WHERE [AGENT CODE] = '60046644' 
	WHERE [NOTE] LIKE '%TAPSU'
	
	UNION
	
	SELECT [Agent_Number]
	--,[License_No]
	FROM [PowerBI].[DPO].[Main_AGENT_INFO_DA]
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
	FROM [PowerBI].[DPO].[DP_AGPOLTRANSFER]
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
	LEFT JOIN Main_POLICY_INFO AS B ON A.[Policy No] = B.POLICY_NUMBER
	LEFT JOIN [Main_AGENT_INFO_DA] AS C ON A.[Current Agent] = C.Agent_Number
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
	,Temp3
AS (
	SELECT *
	FROM (
		SELECT [Agent Code]
			,[Policy_Number]
			,[Issuing_Agent]
			,[Contract Type]
			,[Component_Code]
			,[After_Discount_Premium]
		FROM DP_TDAILYSALES_DA
		
		UNION ALL
		
		SELECT [Agent Code]
			,[Policy_Number]
			,[Issuing_Agent]
			,[Contract Type]
			,[Component_Code]
			,[After_Discount_Premium]
		FROM DP_DA_Daily_DC_PO_WD_NT
		) AS A
	)
	,Temp2
AS (
	SELECT CONCAT (
			Policy_Number
			,Component_Code
			) AS ID_Policy_Component
		,SUM(After_Discount_Premium) AS After_Discount_Premium_IP
	FROM Temp3
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
	FROM DP_TAGENTPREMIUM_TEST
	GROUP BY [Policy No]
		,[Product Code]
	)
	,C
AS (
	SELECT B.ID_Policy_Component
		,B.[Policy No]
		,B.Min_Collected_Date
		,B.[Product Code]
		,Temp2.After_Discount_Premium_IP
	FROM B
	JOIN Temp2 ON B.ID_Policy_Component = Temp2.ID_Policy_Component
	)
	--- end add IP
	,Temp1
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
		,A.Agent_Name AS SA_Name
		,A.Date_Appointed AS SA_Date_Appointed
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
					FROM [PowerBI].[DPO].[Main_AGENT_INFO_DA]
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
	LEFT OUTER JOIN [PowerBI].[DPO].[Main_AGENT_INFO_DA] AS A ON VP.[Servicing Agent] = A.[Agent_Number]
	--(A.Agent_Name NOT LIKE '%BHNT%') AND (A.Sales_Unit_Code NOT LIKE 'ADM00')
	LEFT OUTER JOIN [PowerBI].[DPO].[Main_POLICY_INFO] AS P ON VP.[Policy No] = P.POLICY_NUMBER
	LEFT OUTER JOIN [PowerBI].[DPO].[Main_AGENT_INFO_DA] AS B ON P.PO_IDNUMBER = B.ID_Card
	--WHERE VP.[Servicing Agent] IS NOT NULL
	--LEFT OUTER JOIN Transfer_Policy_Last_Agent AS Y
	--ON VP.[Policy No] = Y.[Policy No] AND VP.[Collected Date] >= Y.[Current Agent Effect From]
	LEFT OUTER JOIN Transfer_Policy AS T ON VP.[Policy No] = T.[Policy No]
	)
SELECT Temp1.*
	,C.After_Discount_Premium_IP
FROM Temp1
LEFT JOIN C ON Temp1.[Policy No] = C.[Policy No]
	AND Temp1.[Product Code] = C.[Product Code]
	AND Temp1.[Collected Date] = C.Min_Collected_Date
	--where Temp1.[Policy No] = '80058942'
	--order by [Policy No], [Collected Date] asc
	--WHERE Cross_Sales = 'CROSS_SALES' 
	----AND 
	--Temp1.[Policy No] = '80103007'
GO


