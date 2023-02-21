USE [PowerBI]
GO

/****** Object:  View [DPO].[vw_AD Structure Traditional]    Script Date: 30/09/2022 16:44:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [DPO].[vw_AD Structure Traditional] AS

SELECT 
      [AD_Code]
      ,[AD_Name]
      ,[AD_Parent_Code]
	  ,[Status_date]
      ,[Status]
  FROM [PowerBI].[DPO].[Main_AD_STRUCTURE]
GO


