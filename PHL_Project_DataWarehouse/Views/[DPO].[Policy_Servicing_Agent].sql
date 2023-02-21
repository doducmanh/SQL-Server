USE [PowerBI]
GO

/****** Object:  View [DPO].[Policy_Servicing_Agent]    Script Date: 30/09/2022 16:34:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 CREATE   VIEW [DPO].[Policy_Servicing_Agent] AS
  WITH A AS (
 SELECT  
		 ROW_NUMBER() OVER (PARTITION BY [CHDRNUM] ORDER BY [Old Agent Effect From ]) AS RN
		, K.*
  FROM [PowerBI].[DPO].[DP_AGPOLTRANSFER] AS K
)
, B AS (
SELECT  
	MAX(A.RN)AS RN
	,A.CHDRNUM
FROM A
GROUP BY A.CHDRNUM
)
,C AS (
SELECT
	A.RN
	,A.CHDRNUM
	,A.[Old Agent]
	,A.[Old Agent Effect From ]
	,A.[User]
	,A.[Old Agent Name]

FROM A

UNION

SELECT
	A.RN + 1 AS RN
	,A.CHDRNUM
	,A.[Current Agent]
	,A.[Current Agent Effect From]
	,A.[User]
	--,A.[Old Agent Name]
	,A.[Current Agent Name]
FROM A
RIGHT JOIN B ON A.RN = B.RN AND A.CHDRNUM = B.CHDRNUM

UNION

SELECT 1 AS RN
	  ,A.[POLICY_NUMBER] 
      ,A.[AGENT_NUMBER]
	  ,A.[ISSUED_DATE] AS Effective_Date
	  ,'' AS USERPHL
	  ,A.[AGENT_NAME]
	  --,'2099-12-31'
FROM [PowerBI].[DPO].[Main_POLICY_INFO] AS A
WHERE A.[POLICY_NUMBER] NOT IN (SELECT [CHDRNUM] FROM [PowerBI].[DPO].[DP_AGPOLTRANSFER])

)
, D AS (
SELECT A.[Issuing Agent]

            ,A.[Policy No]
			,A.[Issued Date]
FROM [PowerBI].[DPO].[DP_TAGENTPREMIUM_TEST] AS A
GROUP BY A.[Policy No],A.[Issuing Agent],A.[Issued Date]

)

SELECT C.RN
	,C.CHDRNUM AS [Policy_Number]
	,P.POLICY_STATUS
	,P.[PAID_TO_DATE]
	,C.[Old Agent] AS [Agent_Number]
	--,C.[Old Agent Effect From ] AS Effective_Date
	,C.[Old Agent Name] AS [Agent_Name]
	,C.[Old Agent Effect From ] AS FROM_DATE
	,LEAD (C.[Old Agent Effect From ]) OVER (PARTITION BY C.[CHDRNUM] ORDER BY C.[RN]) AS TO_DATE
	,D.[Issuing Agent]
	,D.[Issued Date]
FROM C
LEFT JOIN [PowerBI].[DPO].[Main_POLICY_INFO] AS P
ON C.CHDRNUM = P.POLICY_NUMBER

LEFT JOIN D
ON C.CHDRNUM = D.[Policy No]





GO


