USE [PowerBI]
GO

/****** Object:  View [DPO].[AGENCY_SFC]    Script Date: 30/09/2022 16:27:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [DPO].[AGENCY_SFC]
AS
/*** INFORCE POLICIES****/
WITH Temp1
AS (
	SELECT MAX(A.[Policy No]) AS Last_Issued_Policy
		,A.[Issuing Agent]
		--,A.[Servicing Agent]
		--,A.[Policy Status]
		--C.Date_Appointed AS IA_Appointed
		,A.[Issued Date]
	--,LEAD(A.[Issued Date]) OVER (PARTITION BY A.[Issuing Agent] ORDER BY A.[Issued Date]) AS Next_Issued_Date
	FROM [PowerBI].[DPO].[DP_TAGENTPREMIUM_TEST] AS A
	WHERE A.[Policy Status] = 'IF' --OR A.[Policy Status] = 'LA'
	GROUP BY --A.[Policy No]
		-- ,
		A.[Issued Date]
		,A.[Issuing Agent]
		,A.[Policy Status]
		--,A.[Servicing Agent]
		--,C.Date_Appointed
	)
	,Temp2
AS (
	SELECT Temp1.[Issued Date]
		,Temp1.[Issuing Agent]
		,Temp1.Last_Issued_Policy
		,LEAD(Temp1.[Issued Date]) OVER (
			PARTITION BY Temp1.[Issuing Agent] ORDER BY Temp1.[Issued Date]
			) AS Next_Issued_Date
	FROM Temp1
		--WHERE Temp1.[Issuing Agent] = '60015683'
		--ORDER BY Temp1.[Issued Date]
	)
	,Temp4
AS (
	SELECT A.Agent_Number
		--,A.Date_Appointed
		,A.ExplodedDate
		,A.Agent_Number + CONVERT(CHAR(6), A.ExplodedDate, 112) AS ID_AGENT
		,A.Agent_Number + CONVERT(CHAR(6), MAX(B.[Issued Date]), 112) AS ID_AGENT_Last_Policy
		,MAX(B.Last_Issued_Policy) AS Last_Issued_Policy
		,A.GRADE
		,MAX(B.[Issued Date]) AS Last_Issued_Date
	--,B.Last_Issued_Policy
	FROM [DPO].[AGENCY_STRUCTURE_Exploded] AS A
	LEFT JOIN Temp2 AS B ON A.Agent_Number = B.[Issuing Agent]
		AND EOMONTH(A.ExplodedDate) >= B.[Issued Date]
	--WHERE  A.Agent_Number = '60028654'
	GROUP BY A.Agent_Number
		--,A.Date_Appointed
		,A.ExplodedDate
		,A.GRADE
		--ORDER BY A.Agent_Number
		--,A.Date_Appointed
		--,A.ExplodedDate
	)
	--,Temp5 AS (
	--SELECT MAX(A.[Policy No])
	--      ,A.[Issuing Agent]
	--	  --,A.[Servicing Agent]
	--	  --,A.[Policy Status]
	--	  --C.Date_Appointed AS IA_Appointed
	--	  ,A.[Issued Date]
	--	  --,LEAD(A.[Issued Date]) OVER (PARTITION BY A.[Issuing Agent] ORDER BY A.[Issued Date]) AS Next_Issued_Date
	--  FROM [PowerBI].[DPO].[DP_TAGENTPREMIUM_TEST] AS A
	--  WHERE A.[Policy Status] = 'IF'
	--  GROUP BY 
	--	  A.[Issued Date]
	--      ,A.[Issuing Agent]
	--	  ,A.[Policy Status]
	--	  --,A.[Servicing Agent]
	--	  --,C.Date_Appointed
	--)
	,PolicyStatus
AS (
	SELECT DISTINCT [POLICY_NUMBER]
		,[POLICY_STATUS]
	FROM [PowerBI].[DPO].[Main_POLICY_INFO]
	)
	,Last_Servicing_Policy1
AS (
	SELECT [AD_Code]
		,[AD_Office]
		,[Agent_Number]
		,[ExplodedDate]
		,[GRADE]
		,[Supervisor_Code]
	FROM [PowerBI].[DPO].[AGENCY_STRUCTURE_Exploded]
		--WHERE [Agent_Number] = '60019678' 
	)
	,Last_Servicing_Policy2
AS (
	SELECT -- [RN]
		[Policy_Number]
		--,[POLICY_STATUS]
		,[POLICY_STATUS]
		--,[Agent_Name]
		,[PAID_TO_DATE]
		,IIF([Agent_Number] <> [Issuing Agent]
			AND [FROM_DATE] = [Issued Date], [Issuing Agent], [Agent_Number]) AS Agent_Number
		,[FROM_DATE]
		,[TO_DATE]
	--,EOMONTH([FROM_DATE])
	--,EOMONTH([TO_DATE])
	FROM [PowerBI].[DPO].[Policy_Servicing_Agent]
	WHERE --[Policy_Number]  = '80083241'
		[POLICY_STATUS] = 'IF' --OR ([POLICY_STATUS] = 'LA' )--AND [PAID_TO_DATE] >=  '2021-01-01')
	)
	,Last_Servicing_Policy_End
AS (
	SELECT A.AD_Code
		,A.AD_Office
		,A.Agent_Number
		,A.Agent_Number + CONVERT(CHAR(6), A.ExplodedDate, 112) AS ID_AGENT
		,A.ExplodedDate
		--,A.GRADE
		--,A.Supervisor_Code
		,MAX(B.[Policy_Number]) AS Last_Servicing_Policy
	FROM Last_Servicing_Policy1 AS A
	LEFT JOIN Last_Servicing_Policy2 AS B ON A.Agent_Number = B.[Agent_Number]
		AND EOMONTH(A.ExplodedDate) > = B.FROM_DATE
		AND EOMONTH(A.ExplodedDate) < IIF(B.TO_DATE IS NULL, IIF(B.[POLICY_STATUS] <> 'IF'
				AND B.[POLICY_STATUS] <> 'FL', DATEADD(MONTH, 2, B.[PAID_TO_DATE]), '2099-12-31'), B.TO_DATE)
	--WHERE A.Agent_Number = '60007741'
	GROUP BY A.AD_Code
		,A.AD_Office
		,A.Agent_Number
		,A.ExplodedDate
		--,A.GRADE
		--,A.Supervisor_Code
		-- ORDER BY A.ExplodedDate
	)
--, Temp5 AS (
SELECT A.ExplodedDate
	,A.ID_AGENT
	,B.Sales_Unit_Code + CONVERT(CHAR(6), A.ExplodedDate, 112) AS ID_AD
	,B.Sales_Unit_Code AS AD_Code
	,B.Area_Name AS AD_Office
	,A.Agent_Number
	,B.Agent_Name
	,B.Grade AS Current_Grade
	,B.SFC AS Current_SFC
	,IIF(EOMONTH(A.ExplodedDate) > = EOMONTH(B.Date_Appointed)
		AND EOMONTH(A.ExplodedDate) < IIF(B.Terminated_date IS NULL, '2099-12-31', B.Terminated_date), 1, 0) AS ENFORCE_MONTH
	--,P.Policy_Number
	,IIF(A.Grade = 'IC'
		AND A.Agent_Number NOT LIKE '6999%'
		AND (C.Last_Servicing_Policy IS NOT NULL)
		AND C.AD_Office NOT IN (
			'SEP'
			,'DR1'
			,'ACB'
			)
		AND DATEDIFF(MONTH, IIF(A.Last_Issued_Date IS NULL
				OR B.Date_Appointed > A.Last_Issued_Date, B.Date_Appointed, A.Last_Issued_Date), A.ExplodedDate) > 9
		AND A.ExplodedDate >= '2021-02-01'
		AND ((IIF(B.Terminated_date IS NULL, '2099-12-31', B.Terminated_date)) > EOMONTH(A.ExplodedDate)), 'S', '') AS SFC
	,A.Grade
	,B.Date_Appointed
	,B.Terminated_date
	,B.License_No
	,IIF(DATEDIFF(MONTH, IIF(A.Last_Issued_Date IS NULL
				OR B.Date_Appointed > A.Last_Issued_Date, B.Date_Appointed, A.Last_Issued_Date), A.ExplodedDate) < 0, 0, DATEDIFF(MONTH, IIF(A.Last_Issued_Date IS NULL
				OR B.Date_Appointed > A.Last_Issued_Date, B.Date_Appointed, A.Last_Issued_Date), A.ExplodedDate)) AS MONTH_INACTIVE
	,DATEDIFF(MONTH, B.Birthday, A.ExplodedDate) / 12 AS Age
	--,B.Hand_Phone
	--,B.Birthday
	--,B.[Contact Address],B.Contact2,B.Contact3,B.Contact4,B.Contact5
	--,IIF(B.[Alternate_Address] <>'',B.[Alternate_Address] + ', ','') + IIF(B.Alternate2 <>'',B.Alternate2 + ', ','')  + IIF(B.Alternate3 <>'',B.Alternate3 + ', ','') + IIF(B.Alternate4 <>'',B.Alternate4 + ', ','')  + IIF(B.Alternate5 <>'',B.Alternate5,'') AS ALTERNATE_ADDRESS
	--,IIF(B.[Contact Address] <>'',B.[Contact Address] + ', ','') + IIF(B.Contact2 <>'',B.Contact2 + ', ','')  + IIF(B.Contact3 <>'',B.Contact3 + ', ','') + IIF(B.Contact4 <>'',B.Contact4 + ', ','')  + IIF(B.Contact5 <>'',B.Contact5,'') AS ADDRESS
	--,IIF(B.[Alternate_Address] <>'',B.[Alternate_Address] + ', ','') + IIF(B.Alternate2 <>'',B.Alternate2 + ', ','')  + IIF(B.Alternate3 <>'',B.Alternate3 + ', ','') + IIF(B.Alternate4 <>'',B.Alternate4 + ', ','')  + IIF(B.Alternate5 <>'',B.Alternate5,'') AS ALTERNATE_ADDRESS
	,A.Last_Issued_Date
	,A.Last_Issued_Policy
	,D.POLICY_STATUS AS Last_Issued_Policy_Status
	,C.Last_Servicing_Policy
	,E.POLICY_STATUS AS Last_Servicing_Policy_Status
FROM Temp4 AS A
LEFT JOIN [DPO].[Main_AGENT_INFO_DA] AS B ON A.Agent_Number = B.Agent_Number
LEFT JOIN Last_Servicing_Policy_End AS C ON A.ID_AGENT = C.ID_AGENT
LEFT JOIN PolicyStatus AS D ON A.Last_Issued_Policy = D.POLICY_NUMBER
LEFT JOIN PolicyStatus AS E ON C.Last_Servicing_Policy = E.POLICY_NUMBER
WHERE A.ExplodedDate >= '2020-01-01' --AND A.Agent_Number = '60034345'
	--ORDER BY A.ExplodedDate
	--)
	--SELECT
	--	A.ExplodedDate, A.ID_AGENT, A.ID_AD, A.AD_Code, A.AD_Office, A.Agent_Number, A.SFC
	--	,A.GRADE,A.Date_Appointed, A.Last_Issued_Date, A.Last_Issued_Policy, A.Last_Servicing_Policy
	--FROM Temp5 AS A
	--LEFT JOIN Last_Servicing_Policy2 AS B
	--ON A.Last_Servicing_Policy IS NOT NULL AND A.Last_Servicing_Policy = B.Policy_Number
	--ORDER BY A.Agent_Number,A.ExplodedDate
	--LEFT JOIN [DPO].[Policy_Servicing_Agent] AS P
	--ON A.Agent_Number = P.Agent_Number
	--AND EOMONTH(A.ExplodedDate) >= EOMONTH(P.FROM_DATE) AND EOMONTH(A.ExplodedDate) < IIF(P.TO_DATE IS NULL, '2099-12-31', EOMONTH(P.TO_DATE))
	--AND P.POLICY_STATUS = 'IF'
	----WHERE  B.Terminated_date IS NOT NULL AND SFC IS NOT NULL
	--WHERE  A.Agent_Number = '60029216'
	--ORDER BY A.ExplodedDate
GO


