USE [PowerBI]
GO

/****** Object:  View [DPO].[AD_Appointed_Date]    Script Date: 30/09/2022 16:21:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [DPO].[AD_Appointed_Date] AS WITH Q AS (SELECT AD_Code, MAX(ID) AS Last_ID
                   FROM   [DPO].Main_AD_STRUCTURE
                   WHERE Status = 'Appointed'
				   GROUP BY AD_Code
				   ), K AS
    (SELECT Q1.ID, Q1.AD_Code, Q1.AD_Name, Q1.Grade, Q1.AD_Parent_Code, Q1.AD_Parent, Q1.Territory, Q1.Territory_Code, Q1.Office, Q1.Office_Code, Q1.Status_date, Q1.Status, Q1.Update_Time
    FROM    [DPO].Main_AD_STRUCTURE AS Q1 INNER JOIN
                 Q AS Q_1 ON Q_1.AD_Code = Q1.AD_Code AND Q_1.Last_ID = Q1.ID)
    SELECT DISTINCT AD_Code, AD_Name, Grade, AD_Parent, AD_Parent_Code, Territory, Territory_Code, Status, Status_date
   FROM    K AS K_1
GO


