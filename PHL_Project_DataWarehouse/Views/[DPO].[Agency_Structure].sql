USE [PowerBI]
GO

/****** Object:  View [DPO].[Agency_Structure]    Script Date: 30/09/2022 16:28:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [DPO].[Agency_Structure]
AS
WITH A
AS (
	SELECT --A0.AD_Office 
		--,A0.AD_Code
		--,
		A0.[Agent_Number]
		,CONVERT(CHAR(6), A0.ExplodedDate, 112) AS ExplodedDate
		,A0.GRADE
		,A0.Supervisor_Code
		,A0.[Agent_Number] + CONVERT(CHAR(6), A0.ExplodedDate, 112) AS ID
		--,A0.AD_Code + CONVERT(CHAR(6), A0.ExplodedDate, 112) AS ID_AD
		,IIF(A0.Supervisor_Code IS NOT NULL, A0.Supervisor_Code + CONVERT(CHAR(6), A0.ExplodedDate, 112), NULL) AS IDSup
	FROM [PowerBI].[DPO].[AGENCY_STRUCTURE_Exploded] AS A0
	)
	,B
AS (
	SELECT
		-- K.ID_AD	
		K.ID
		--, K.AD_Office
		--, K.AD_Code
		,K.Agent_Number
		,K.ExplodedDate
		,K.GRADE
		--,K.[Date_Appointed]
		--,K.[Terminated_date]
		,K.Supervisor_Code AS L1
		,A1.GRADE AS L1G
		,A1.Supervisor_Code AS L2
		,A2.GRADE AS L2G
		,A2.Supervisor_Code AS L3
		,A3.GRADE AS L3G
		,A3.Supervisor_Code AS L4
		,A4.GRADE AS L4G
		,A4.Supervisor_Code AS L5
		,A5.GRADE AS L5G
		,A5.Supervisor_Code AS L6
		,A6.GRADE AS L6G
		,A6.Supervisor_Code AS L7
		,A7.GRADE AS L7G
		,A7.Supervisor_Code AS L8
		,A8.GRADE AS L8G
		,A8.Supervisor_Code AS L9
		,A9.GRADE AS L9G
		,A9.Supervisor_Code AS L10
		,A10.GRADE AS L10G
		,A10.Supervisor_Code AS L11
		,A11.GRADE AS L11G
		,A11.Supervisor_Code AS L12
		,A12.GRADE AS L12G
		,A12.Supervisor_Code AS L13
		,A13.GRADE AS L13G
		,A13.Supervisor_Code AS L14
		,A14.GRADE AS L14G
	FROM A AS K
	LEFT JOIN A AS A1 ON --K.[IDSup] IS NOT NULL AND 
		K.[IDSup] = A1.ID
	LEFT JOIN A AS A2 ON --A1.[IDSup] IS NOT NULL   AND 
		A1.[IDSup] = A2.ID
	LEFT JOIN A AS A3 ON --A2.[IDSup] IS NOT NULL  AND 
		A2.[IDSup] = A3.ID
	LEFT JOIN A AS A4 ON --A3.[IDSup] IS NOT NULL   AND 
		A3.[IDSup] = A4.ID
	LEFT JOIN A AS A5 ON --A4.[IDSup] IS NOT NULL   AND 
		A4.[IDSup] = A5.ID
	LEFT JOIN A AS A6 ON --A5.[IDSup] IS NOT NULL   AND 
		A5.[IDSup] = A6.ID
	LEFT JOIN A AS A7 ON --A6.[IDSup] IS NOT NULL   AND 
		A6.[IDSup] = A7.ID
	LEFT JOIN A AS A8 ON --A7.[IDSup] IS NOT NULL   AND 
		A7.[IDSup] = A8.ID
	LEFT JOIN A AS A9 ON --A8.[IDSup] IS NOT NULL   AND 
		A8.[IDSup] = A9.ID
	LEFT JOIN A AS A10 ON --A9.[IDSup] IS NOT NULL   AND 
		A9.[IDSup] = A10.ID
	LEFT JOIN A AS A11 ON A10.[IDSup] = A11.ID
	LEFT JOIN A AS A12 ON A11.[IDSup] = A12.ID
	LEFT JOIN A AS A13 ON A12.[IDSup] = A13.ID
	LEFT JOIN A AS A14 ON A13.[IDSup] = A14.ID
	)
	,B1
AS (
	SELECT B.Agent_Number
		,B.ID
		--,B.AD_Office
		--,B.AD_Code
		--,B.ID_AD
		--,B.[Date_Appointed]
		--,B.[Terminated_date]
		,B.ExplodedDate
		,B.GRADE
		,IIF(B.L1 <> '', B.L1, NULL) AS L1
		,B.L1G
		,IIF(B.L2 <> '', B.L2, NULL) AS L2
		,B.L2G
		,IIF(B.L3 <> '', B.L3, NULL) AS L3
		,B.L3G
		,IIF(B.L4 <> '', B.L4, NULL) AS L4
		,B.L4G
		,IIF(B.L5 <> '', B.L5, NULL) AS L5
		,B.L5G
		,IIF(B.L6 <> '', B.L6, NULL) AS L6
		,B.L6G
		,IIF(B.L7 <> '', B.L7, NULL) AS L7
		,B.L7G
		,IIF(B.L8 <> '', B.L8, NULL) AS L8
		,B.L8G
		,IIF(B.L9 <> '', B.L9, NULL) AS L9
		,B.L9G
		,IIF(B.L10 <> '', B.L10, NULL) AS L10
		,B.L10G
		,IIF(B.L11 <> '', B.L11, NULL) AS L11
		,B.L11G
		,IIF(B.L12 <> '', B.L12, NULL) AS L12
		,B.L12G
		,IIF(B.L13 <> '', B.L13, NULL) AS L13
		,B.L13G
		,IIF(B.L14 <> '', B.L14, NULL) AS L14
		,B.L14G
	FROM B
	)
	,C
AS (
	SELECT B1.*
		,COALESCE(B1.L14, B1.L13, B1.L12, B1.L11, B1.L10, B1.L9, B1.L8, B1.L7, B1.L6, B1.L5, B1.L4, B1.L3, B1.L2, B1.L1, B1.Agent_Number) AS L0R
	FROM B1
	)
	,D
AS (
	SELECT C.*
		,CASE 
			WHEN L0R = Agent_Number
				THEN 0
			WHEN L0R = L1
				THEN 1
			WHEN L0R = L2
				THEN 2
			WHEN L0R = L3
				THEN 3
			WHEN L0R = L4
				THEN 4
			WHEN L0R = L5
				THEN 5
			WHEN L0R = L6
				THEN 6
			WHEN L0R = L7
				THEN 7
			WHEN L0R = L8
				THEN 8
			WHEN L0R = L9
				THEN 9
			WHEN L0R = L10
				THEN 10
			WHEN L0R = L11
				THEN 11
			WHEN L0R = L12
				THEN 12
			WHEN L0R = L13
				THEN 13
			WHEN L0R = L14
				THEN 14
			END AS INDEX_LEADER
	FROM C
	)
	,E
AS (
	SELECT --D.*
		D.[ExplodedDate]
		,D.ID
		--,D.AD_Code + CONVERT(CHAR(6), D.ExplodedDate, 112) AS ID_AD
		--,IIF(A0.Supervisor_Code IS NOT NULL,CONCAT(A0.Supervisor_Code,A0.[ExplodedDate]),NULL)  AS IDSup
		--,D.[AD_Office]
		--,D.AD_Code
		--, AGENT.Sales_Unit_Code AS AD_Code
		,CASE 
			WHEN D.[GRADE] = 'GM'
				THEN D.[Agent_Number]
			WHEN D.L1G = 'GM'
				THEN D.L1
			WHEN D.L2G = 'GM'
				THEN D.L2
			WHEN D.L3G = 'GM'
				THEN D.L3
			WHEN D.L4G = 'GM'
				THEN D.L4
			WHEN D.L5G = 'GM'
				THEN D.L5
			WHEN D.L6G = 'GM'
				THEN D.L6
			WHEN D.L7G = 'GM'
				THEN D.L7
			WHEN D.L8G = 'GM'
				THEN D.L8
			WHEN D.L9G = 'GM'
				THEN D.L9
			WHEN D.L10G = 'GM'
				THEN D.L10
			WHEN D.L11G = 'GM'
				THEN D.L11
			WHEN D.L12G = 'GM'
				THEN D.L12
			WHEN D.L13G = 'GM'
				THEN D.L13
			WHEN D.L14G = 'GM'
				THEN D.L14
			END AS GM
		,CASE 
			WHEN D.[GRADE] = 'RM'
				THEN D.[Agent_Number]
			WHEN D.L1G = 'RM'
				THEN D.L1
			WHEN D.L2G = 'RM'
				THEN D.L2
			WHEN D.L3G = 'RM'
				THEN D.L3
			WHEN D.L4G = 'RM'
				THEN D.L4
			WHEN D.L5G = 'RM'
				THEN D.L5
			WHEN D.L6G = 'RM'
				THEN D.L6
			WHEN D.L7G = 'RM'
				THEN D.L7
			WHEN D.L8G = 'RM'
				THEN D.L8
			WHEN D.L9G = 'RM'
				THEN D.L9
			WHEN D.L10G = 'RM'
				THEN D.L10
			WHEN D.L11G = 'RM'
				THEN D.L11
			WHEN D.L12G = 'RM'
				THEN D.L12
			WHEN D.L13G = 'RM'
				THEN D.L13
			WHEN D.L14G = 'RM'
				THEN D.L14
			END AS RM
		,CASE 
			WHEN D.[GRADE] = 'DM'
				THEN D.[Agent_Number]
			WHEN D.L1G = 'DM'
				THEN D.L1
			WHEN D.L2G = 'DM'
				THEN D.L2
			WHEN D.L3G = 'DM'
				THEN D.L3
			WHEN D.L4G = 'DM'
				THEN D.L4
			WHEN D.L5G = 'DM'
				THEN D.L5
			WHEN D.L6G = 'DM'
				THEN D.L6
			WHEN D.L7G = 'DM'
				THEN D.L7
			WHEN D.L8G = 'DM'
				THEN D.L8
			WHEN D.L9G = 'DM'
				THEN D.L9
			WHEN D.L10G = 'DM'
				THEN D.L10
			WHEN D.L11G = 'DM'
				THEN D.L11
			WHEN D.L12G = 'DM'
				THEN D.L12
			WHEN D.L13G = 'DM'
				THEN D.L13
			WHEN D.L14G = 'DM'
				THEN D.L14
			END AS DM
		,CASE 
			WHEN D.[GRADE] = 'FM'
				THEN D.[Agent_Number]
			WHEN D.L1G = 'FM'
				THEN D.L1
			WHEN D.L2G = 'FM'
				THEN D.L2
			WHEN D.L3G = 'FM'
				THEN D.L3
			WHEN D.L4G = 'FM'
				THEN D.L4
			WHEN D.L5G = 'FM'
				THEN D.L5
			WHEN D.L6G = 'FM'
				THEN D.L6
			WHEN D.L7G = 'FM'
				THEN D.L7
			WHEN D.L8G = 'FM'
				THEN D.L8
			WHEN D.L9G = 'FM'
				THEN D.L9
			WHEN D.L10G = 'FM'
				THEN D.L10
			WHEN D.L11G = 'FM'
				THEN D.L11
			WHEN D.L12G = 'FM'
				THEN D.L12
			WHEN D.L13G = 'FM'
				THEN D.L13
			WHEN D.L14G = 'FM'
				THEN D.L14
			END AS FM
		--,D.[ID_AD]
		--,D.[Date_Appointed]
		--,D.[Terminated_date]
		,D.[Agent_Number]
		,D.[GRADE]
		,D.[L1]
		,D.[L1G]
		,D.[L2]
		,D.[L2G]
		,D.[L3]
		,D.[L3G]
		,D.[L4]
		,D.[L4G]
		,D.[L5]
		,D.[L5G]
		,D.[L6]
		,D.[L6G]
		,D.[L7]
		,D.[L7G]
		,D.[L8]
		,D.[L8G]
		,D.[L9]
		,D.[L9G]
		,D.[L10]
		,D.[L10G]
		,D.[L11]
		,D.[L11G]
		,D.[L12]
		,D.[L12G]
		,D.[L13]
		,D.[L13G]
		,D.[L14]
		,D.[L14G]
		,D.[L0R]
		,D.[INDEX_LEADER]
		,IIF(D.GRADE <> D.L1G
			AND L1G <> 'IC', 1, 0) AS [L1 Direct]
		,IIF(D.L1G <> D.L2G
			AND L2G <> 'IC', 1, 0) AS [L2 Direct]
		,IIF(D.L2G <> D.L3G
			AND L3G <> 'IC', 1, 0) AS [L3 Direct]
		,IIF(D.L3G <> D.L4G
			AND L4G <> 'IC', 1, 0) AS [L4 Direct]
		,IIF(D.L4G <> D.L5G
			AND L5G <> 'IC', 1, 0) AS [L5 Direct]
		,IIF(D.L5G <> D.L6G
			AND L6G <> 'IC', 1, 0) AS [L6 Direct]
		,IIF(D.L6G <> D.L7G
			AND L7G <> 'IC', 1, 0) AS [L7 Direct]
		,IIF(D.L7G <> D.L8G
			AND L8G <> 'IC', 1, 0) AS [L8 Direct]
		,IIF(D.L8G <> D.L9G
			AND L9G <> 'IC', 1, 0) AS [L9 Direct]
		,IIF(D.L9G <> D.L10G
			AND L10G <> 'IC', 1, 0) AS [L10 Direct]
		,IIF(D.L10G <> D.L11G
			AND L11G <> 'IC', 1, 0) AS [L11 Direct]
		,IIF(D.L11G <> D.L12G
			AND L12G <> 'IC', 1, 0) AS [L12 Direct]
		,IIF(D.L12G <> D.L13G
			AND L13G <> 'IC', 1, 0) AS [L13 Direct]
		,IIF(D.L13G <> D.L14G
			AND L14G <> 'IC', 1, 0) AS [L14 Direct]
	FROM D
	)
	-----------------------------Begin AGENT - AD - HISTORY--------------------------------
	,AGENT_AD_Temp1
AS (
	SELECT A.[Agent_Number]
		,A.[Agent_Name]
		,A.[Sales_Unit_Code]
		,A.[Sales_Unit_Name]
		,A.[Area_Name]
		,A.[Curr_From]
		-------------------- Temp add in pseudo structure-------------------------------
		,IIF(A.[Curr_From] > B.[Appointed_TAPSU]
			AND A.[RN] = 1, CONVERT(CHAR(6), B.[Appointed_TAPSU], 112), CONVERT(CHAR(6), A.[Curr_From], 112)) AS EFFECTIVE
		-------------------- End Temp add in pseudo structure-------------------------------
		,A.[RN]
		,COUNT(*) OVER (PARTITION BY A.[Agent_Number]) AS MAXRN
		,B.Date_Appointed
	FROM [PowerBI].[DPO].[Main_AGENT_AD_HISTORY] AS A
	LEFT JOIN [PowerBI].[DPO].[Main_AGENT_INFO_DA] AS B ON A.Agent_Number = B.Agent_Number
	)
	,AGENT_AD_Temp2
AS (
	SELECT A.[Agent_Number]
		,A.[Agent_Name]
		,A.[Sales_Unit_Code]
		,A.[Sales_Unit_Name]
		,A.[Area_Name]
		,A.Curr_From
		,IIF(RN = 1, A.EFFECTIVE, LAG(CONVERT(CHAR(6), A.Curr_From, 112)) OVER (
				PARTITION BY A.Agent_Number ORDER BY A.[RN]
				)) AS FROM_EFFECTIVE
		,IIF(RN = MAXRN, NULL, CONVERT(CHAR(6), A.[Curr_From], 112)) AS END_EFFECTIVE
		,A.[RN]
	--,A.MAXRN
	FROM AGENT_AD_Temp1 AS A
	)
	,AGENT_AD
AS (
	SELECT B.*
	FROM AGENT_AD_Temp2 AS B
	WHERE B.FROM_EFFECTIVE <> IIF(B.END_EFFECTIVE IS NULL, '209912', B.END_EFFECTIVE)
	)
	-----------------------------End AGENT - AD - HISTORY--------------------------------
	,FINAL
AS (
	SELECT IIF(Current_Structure.Sales_Unit_Code IS NULL, 'ADNUL', Current_Structure.Sales_Unit_Code) + CONVERT(CHAR(6), EOMONTH(GETDATE()), 112) AS ID_AD_Current
		,Current_Structure.Sales_Unit_Code AS AD_Code_Current
		,Current_Structure.Area_Name AS AD_Office_Current
		,IIF(HISTORY.Sales_Unit_Code IS NULL, 'ADNUL', HISTORY.Sales_Unit_Code) + E.ExplodedDate AS ID_AD
		,IIF(HISTORY.Sales_Unit_Code IS NULL, 'ADNUL', HISTORY.Sales_Unit_Code) AS AD_Code
		,IIF(HISTORY.Area_Name IS NULL, 'PHL', HISTORY.Area_Name) AS AD_Office
		,E.*
		,S.SFC
		,Current_Structure.SFC AS SFC_MARK_IT
		,Current_Structure.Agent_Name
		,Current_Structure.Date_Appointed
		,Current_Structure.Terminated_date
		,Current_Structure.Agent_Status
		,GM.Agent_Name AS GM_Agent_Name
		,GM.Date_Appointed AS GM_Date_Appointed
		,GM.Agent_Status AS GM_Agent_Status
		,RM.Agent_Name AS RM_Agent_Name
		,RM.Date_Appointed AS RM_Date_Appointed
		,RM.Agent_Status AS RM_Agent_Status
		,DM.Agent_Name AS DM_Agent_Name
		,DM.Date_Appointed AS DM_Date_Appointed
		,DM.Agent_Status AS DM_Agent_Status
		,FM.Agent_Name AS FM_Agent_Name
		,FM.Date_Appointed AS FM_Date_Appointed
		,FM.Agent_Status AS FM_Agent_Status
	--, S.Date_Appointed
	--, S.Terminated_date
	FROM E
	LEFT JOIN [PowerBI].[DPO].[AGENCY_SFC] AS S ON E.ID = S.ID_AGENT
	LEFT JOIN AGENT_AD AS HISTORY ON E.[Agent_Number] = HISTORY.Agent_Number
		AND E.[ExplodedDate] >= HISTORY.FROM_EFFECTIVE
		AND E.[ExplodedDate] < IIF(HISTORY.END_EFFECTIVE IS NULL, '209912', HISTORY.END_EFFECTIVE)
	LEFT JOIN [DPO].[Main_AGENT_INFO_DA] AS Current_Structure ON E.Agent_Number = Current_Structure.Agent_Number
	LEFT JOIN [DPO].[Main_AGENT_INFO_DA] AS GM ON E.GM = GM.Agent_Number
	LEFT JOIN [DPO].[Main_AGENT_INFO_DA] AS RM ON E.RM = RM.Agent_Number
	LEFT JOIN [DPO].[Main_AGENT_INFO_DA] AS DM ON E.DM = DM.Agent_Number
	LEFT JOIN [DPO].[Main_AGENT_INFO_DA] AS FM ON E.FM = FM.Agent_Number
		----WHERE L9 IS NOT NULL
		--WHERE E.[Agent_Number] = '60046377'
		--ORDER BY E.Agent_Number, E.[ExplodedDate]
	)
SELECT F.[ID_AD_Current]
	,F.[AD_Code_Current]
	,F.[AD_Office_Current]
	,F.[ID_AD]
	,F.[AD_Code]
	,F.[AD_Office]
	,F.[ExplodedDate]
	,F.[ID]
	,F.[RM]
	,F.[DM]
	,F.[FM]
	,F.[Agent_Number]
	,F.[GRADE]
	,F.[L1]
	,F.[L1G]
	,F.[L2]
	,F.[L2G]
	,F.[L3]
	,F.[L3G]
	,F.[L4]
	,F.[L4G]
	,F.[L5]
	,F.[L5G]
	,F.[L6]
	,F.[L6G]
	,F.[L7]
	,F.[L7G]
	,F.[L8]
	,F.[L8G]
	,F.[L9]
	,F.[L9G]
	,F.[L10]
	,F.[L10G]
	,F.[L11]
	,F.[L11G]
	,F.[L12]
	,F.[L12G]
	,F.[L13]
	,F.[L13G]
	,F.[L14]
	,F.[L14G]
	,F.[L0R]
	,F.[INDEX_LEADER]
	,F.[L1 Direct]
	,F.[L2 Direct]
	,F.[L3 Direct]
	,F.[L4 Direct]
	,F.[L5 Direct]
	,F.[L6 Direct]
	,F.[L7 Direct]
	,F.[L8 Direct]
	,F.[L9 Direct]
	,F.[L10 Direct]
	,F.[L11 Direct]
	,F.[L12 Direct]
	,F.[L13 Direct]
	,F.[L14 Direct]
	,F.[SFC]
	,F.[SFC_MARK_IT]
	,F.[Date_Appointed]
	,F.[Terminated_date]
	,F.[RM_Date_Appointed]
	,F.[DM_Date_Appointed]
	,F.[FM_Date_Appointed]
	--NEW COLUMNS
	,F.Agent_Name
	,F.Agent_Status
	,F.GM
	,F.GM_Agent_Name
	,F.GM_Date_Appointed
	,F.GM_Agent_Status
	,F.RM_Agent_Name
	,F.RM_Agent_Status
	,F.DM_Agent_Name
	,F.DM_Agent_Status
	,F.FM_Agent_Name
	,F.FM_Agent_Status
--NEW COLUMNS
FROM FINAL AS F
GO


