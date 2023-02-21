USE DP_Manh
GO

/****** Object:  View [DPO].[AD_STRUCTURE_UPLOAD_TO_S_DRIVE]    Script Date: 17/01/2023 10:08:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [AD_STRUCTURE_S_DRIVE] AS
WITH T_LATEST_AD_STRUCTURE AS (
SELECT 
	   B.TERRITORY 
	  ,[STD]
      ,[STDName]
      ,[TD]
      ,[TDName]
	  ,[TAD]
      ,[TADName]
      ,[SRD]
      ,[SRDName]
      ,[RD]
      ,[RDName]
	  ,[RAD]
      ,[RADName]
      ,[SZD]
      ,[SZDName]
      ,[AD_Code]
      ,[ADName]
      ,[AD_Grade]
      ,[Appointed_Date]
      ,[Terminated_Date]
      ,[Last_Status]
      ,[Last_Status_Date]
      ,[DemotePromote_Date]
FROM [SQL_SV65].[PowerBI].[DPO].[AD_STRUCTURE] AS A
LEFT JOIN [SQL_SV65].[PowerBI].[DPO].[DW_Territory] AS B
ON A.Territory_Code = B.CODE
WHERE 
A.[ExplodedDate] IN (SELECT MAX([ExplodedDate]) FROM [SQL_SV65].[PowerBI].[DPO].[AD_STRUCTURE])
AND A.[Territory_Code] NOT IN ('PHL')
)
, T_AD_OFFICES AS (
	SELECT DISTINCT
		[Area_Name]
		,[Sales_Unit_Code]
	FROM [SQL_SV65].[PowerBI].[DPO].[Main_AGENT_INFO_DA]
	UNION
	SELECT DISTINCT
		[Office_Code]
		,[AD_Code]
	FROM [SQL_SV65].[PowerBI].[DPO].[Main_AD_STRUCTURE]
	WHERE ID IN (SELECT MAX([ID]) AS ID FROM [SQL_SV65].[PowerBI].[DPO].[Main_AD_STRUCTURE] GROUP BY [AD_Code])
	AND [AD_Code] NOT IN (SELECT DISTINCT [Sales_Unit_Code] FROM [SQL_SV65].[PowerBI].[DPO].[Main_AGENT_INFO_DA])
)
, T_AD_OFFICES_2 AS (
	SELECT C.[Area_Name], C.[Sales_Unit_Code], D.Office_Name
	FROM T_AD_OFFICES AS C LEFT JOIN [SQL_SV65].[PowerBI].[DPO].[DW_Office] AS D
	ON C.Area_Name = D.Office_Code
)
--Last Query--
SELECT 
	T_LATEST_AD_STRUCTURE.TERRITORY AS [Territories],
	T_LATEST_AD_STRUCTURE.STD AS [Code STD],
	T_LATEST_AD_STRUCTURE.STDName AS [Name STD],
	T_LATEST_AD_STRUCTURE.TD AS [Code TD],
	T_LATEST_AD_STRUCTURE.TDName AS [Name TD],
	T_LATEST_AD_STRUCTURE.TAD AS [Code TAD],
	T_LATEST_AD_STRUCTURE.TADName AS [Name TAD],
	T_LATEST_AD_STRUCTURE.SRD AS [Code SRD],
	T_LATEST_AD_STRUCTURE.SRDName AS [Name SRD],
	T_LATEST_AD_STRUCTURE.RD AS [Code RD],
	T_LATEST_AD_STRUCTURE.RDName AS [Name RD],
	T_LATEST_AD_STRUCTURE.RAD AS [Code RAD],
	T_LATEST_AD_STRUCTURE.RADName AS [Name RAD],
	T_LATEST_AD_STRUCTURE.SZD AS [Code SZD],
	T_LATEST_AD_STRUCTURE.SZDName AS [Name SZD],
	T_AD_OFFICES_2.[Area_Name] AS [Code Office], 
	T_AD_OFFICES_2.Office_Name AS [Sales Office],
	T_LATEST_AD_STRUCTURE.AD_Code AS [AD Code],
	T_LATEST_AD_STRUCTURE.ADName AS [AD Name],
	T_LATEST_AD_STRUCTURE.AD_Grade AS [Grade],
	T_LATEST_AD_STRUCTURE.Last_Status AS [NOTE],
	--FORMAT(CAST(T_LATEST_AD_STRUCTURE.Appointed_Date AS smalldatetime), 'dd/MM/yyyy') AS [Date Appointed],
	CAST(T_LATEST_AD_STRUCTURE.Appointed_Date AS smalldatetime) AS [Date Appointed],
	--FORMAT(CAST(T_LATEST_AD_STRUCTURE.Terminated_Date AS smalldatetime), 'dd/MM/yyyy') AS [Date Terminated],
	CAST(T_LATEST_AD_STRUCTURE.Terminated_Date AS smalldatetime) AS [Date Terminated],
	T_LATEST_AD_STRUCTURE.Last_Status AS [Status],
	--FORMAT(CAST(T_LATEST_AD_STRUCTURE.DemotePromote_Date AS smalldatetime), 'dd/MM/yyyy') AS [DemotePromote_Date],
	CAST(T_LATEST_AD_STRUCTURE.DemotePromote_Date AS smalldatetime) AS [DemotePromote_Date],
	--FORMAT(CAST(T_LATEST_AD_STRUCTURE.Last_Status_Date AS smalldatetime), 'dd/MM/yyyy') AS [Last_Status_Date]
	CAST(T_LATEST_AD_STRUCTURE.Last_Status_Date AS smalldatetime) AS [Last_Status_Date],
	AD_EMAIL.[EMAIL]
FROM T_LATEST_AD_STRUCTURE LEFT JOIN T_AD_OFFICES_2
ON T_LATEST_AD_STRUCTURE.AD_Code = T_AD_OFFICES_2.Sales_Unit_Code
LEFT JOIN [SQL_SV65].[PowerBI].[DPO].[Main_AD_EMAIL] AS AD_EMAIL
ON T_LATEST_AD_STRUCTURE.AD_Code = AD_EMAIL.[CODE]
--ORDER BY T_LATEST_AD_STRUCTURE.TERRITORY, T_LATEST_AD_STRUCTURE.TD, T_LATEST_AD_STRUCTURE.SRD, T_LATEST_AD_STRUCTURE.RD, T_LATEST_AD_STRUCTURE.SZD

GO


