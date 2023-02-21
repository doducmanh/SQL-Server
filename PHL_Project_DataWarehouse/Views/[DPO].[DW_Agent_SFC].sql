USE [PowerBI]
GO

/****** Object:  View [DPO].[DW_Agent_SFC]    Script Date: 30/09/2022 16:32:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


 CREATE    VIEW [DPO].[DW_Agent_SFC] AS
WITH CountMonth AS
(
SELECT	SQ.*
		,MAX(VP2.[Collected Date]) AS Date_LastService
FROM (
SELECT A.[Code]
      ,A.[Name]
	  ,A.Grade
      ,A.[Status]
      ,A.Date_Appointed AS Date_Appointed
	  ,MAX(VP.[Issued Date]) AS Date_LastIssue
  FROM [PowerBI].[DPO].[DW_Agent] A
LEFT JOIN [DPO].view_premium VP 
	ON A.Code = VP.[Issuing Agent]
WHERE A.Name NOT LIKE 'DUMMY%'
GROUP BY A.[Code]
		,A.[Name]
		,A.Grade
		,A.[Status]
		,A.Date_Appointed
) AS SQ
LEFT JOIN (SELECT * FROM view_premium
			WHERE [Policy Status] = 'IF') AS VP2 
	ON SQ.Code = VP2.[Servicing Agent]
GROUP BY	SQ.[Code]
			,SQ.[Name]
			,SQ.Grade
			,SQ.[Status]
			,SQ.Date_Appointed
			,SQ.Date_LastIssue
)

SELECT	*,
		ABS(DATEDIFF(MONTH, GETDATE(), Date_LastIssue)) AS Month_Issued,
		ABS(DATEDIFF(MONTH, GETDATE(), Date_LastService)) AS Month_Serviced
FROM CountMonth
GO


