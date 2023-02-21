USE [PowerBI]
GO

/****** Object:  UserDefinedFunction [DPO].[udf_agent_info_cutoff]    Script Date: 30/09/2022 16:57:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [DPO].[udf_agent_info_cutoff] 
(
	-- Add the parameters for the function here
	@date AS DATE = '2022-06-30'
)
RETURNS TABLE
AS
	RETURN 
		SELECT 
			[Agent_Number]
		  ,[Agent_Name]
		  ,[Gender]
		  ,[Grade]
		  ,[Agent_Status]
		  ,[Birthday]
		  ,[BirthPlace]
		  ,[ID_Card]
		  ,[Issued Date]
		  ,[Issued Place]
		  ,[Marriage]
		  ,[Client_Code]
		  ,[Client_Name]
		  ,[Email]
		  ,[Telephone]
		  ,[Hand_Phone]
		  ,[Contact Address]
		  ,[Contact2]
		  ,[Contact3]
		  ,[Contact4]
		  ,[Contact5]
		  ,[Alternate_Address]
		  ,[Alternate2]
		  ,[Alternate3]
		  ,[Alternate4]
		  ,[Alternate5]
		  ,[Date_Appointed]
		  ,[Terminated_date]
		  ,[Reason Terminated]
		  ,[Recovered Date]
		  ,[Client Number of Introducer]
		  ,[Client Name of Introducer]
		  ,[Agent_Bank_Account]
		  ,[Bank_Code]
		  ,[Bank_Address]
		  ,[Bank_Address2]
		  ,[Bank_Address3]
		  ,[Bank_Address4]
		  ,[License_No]
		  ,[Tax Code]
		  ,[Tax Office]
		  ,[Previous Insurance]
		  ,[Experience in the insurance]
		  ,[Agent Classification]
		  ,[Promote_Date]
		  ,[Demote_Date]
		  ,[Club_Class]
		  ,[Effective_Date_Club_Class]
		  ,[Bank Name]
		  ,[Bank_Number]
		  ,[SFC]
		  ,[Appointed_TAPSU]
		  ,[Client ID number of Introducer]
		  ,[Agent Numer of Introducer]
		FROM dpo.[dwo Agent Info Cutoff] A
		WHERE A.[Begin Effective Date] <= @date AND @date < A.[End Effective Date];
GO


