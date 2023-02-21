USE [DP_Manh]
GO

/****** Object:  StoredProcedure [dbo].[UPDATE_MAIN_TABLES_CUTOFF]    Script Date: 01/01/2023 13:27:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[UPDATE_MAIN_TABLES_CUTOFF] (@varCUTOFF_TIME nvarchar(4000))
AS 
BEGIN
	--format @varCUTOFF_TIME as 'yyyyMMdd'. exp: '20220731'
	--1
	INSERT INTO [dbo].[T_DP_AGPOLTRANSFER_CUTOFF] ([CHDRNUM],[Old Agent],[Old Agent Effect From ],[Current Agent],[Current Agent Effect From],[User],[Old Agent Name],[Current Agent Name],[CUTOFF])
	SELECT [CHDRNUM],[Old Agent],[Old Agent Effect From ],[Current Agent],[Current Agent Effect From],[User],[Old Agent Name],[Current Agent Name],[CUTOFF]
	FROM [SQL_SV65].[PowerBI].[DPO].[DP_AGPOLTRANSFER_CUTOFF]
	WHERE [CUTOFF] = @varCUTOFF_TIME
	--2
	INSERT INTO [dbo].[T_DP_DA_Daily_DC_PO_WD_NT_CUTOFF] ([Agent Code],[Policy_Number],[Issuing_Agent],[Contract Type],[Component_Code],[Proposal_Receive_Date],[Policy_Issue_Date],[Sum_Assured],[Before_Discount_Premium],[Discount_Premium],[After_Discount_Premium],[Policy_Status],[Bill_Frequency],[Modal_Factor],[Lapsed_date],[AFYP],[RISK_COMMENCE_DATE],[CUTOFF],[ACK_DATE])
	SELECT [Agent Code],[Policy_Number],[Issuing_Agent],[Contract Type],[Component_Code],[Proposal_Receive_Date],[Policy_Issue_Date],[Sum_Assured],[Before_Discount_Premium],[Discount_Premium],[After_Discount_Premium],[Policy_Status],[Bill_Frequency],[Modal_Factor],[Lapsed_date],[AFYP],[RISK_COMMENCE_DATE],[CUTOFF],[ACK_DATE]
	FROM [SQL_SV65].[PowerBI].[DPO].[DP_DA_Daily_DC_PO_WD_NT_CUTOFF]
	WHERE [CUTOFF] = @varCUTOFF_TIME
	--3
	INSERT INTO [dbo].[T_DP_K2_CUTOFF] ([AD],[AGENT NO],[POLICY NO],[LIFE],[COMPONENT],[RCD],[Effected Date],[PTD],[FREQUENCY],[COMPONENT STATUS],[Y2 ACTUAL PREM],[Y2 EXPECTED PREM],[CUTOFF])
	SELECT [AD],[AGENT NO],[POLICY NO],[LIFE],[COMPONENT],[RCD],[Effected Date],[PTD],[FREQUENCY],[COMPONENT STATUS],[Y2 ACTUAL PREM],[Y2 EXPECTED PREM],[CUTOFF]
	FROM [SQL_SV65].[PowerBI].[DPO].[DP_K2_CUTOFF]
	WHERE [CUTOFF] = @varCUTOFF_TIME
	--4
	INSERT INTO [dbo].[T_DP_POSubmitDA_CUTOFF] ([SALEOFFICE],[AGNTNUM],[APPLICATION_NUMBER],[CONTRACT_NUMBER],[CONTRACT_STATUS],[MAIN_PRODUCT_CODE],[FREQUENCY],[FIRST_PREMIUM],[SUBMIT_AMT],[TRANSACTION],[EFFECTIVE_DATE],[TRANSACTION_DATE],[FIRST_ISSUED_DATE],[ISSUED_DATE],[DOCUMENTNO],[REVERTED_BY_RECEIPT],[DESCRIPTION],[CUTOFF])
	SELECT [SALEOFFICE],[AGNTNUM],[APPLICATION_NUMBER],[CONTRACT_NUMBER],[CONTRACT_STATUS],[MAIN_PRODUCT_CODE],[FREQUENCY],[FIRST_PREMIUM],[SUBMIT_AMT],[TRANSACTION],[EFFECTIVE_DATE],[TRANSACTION_DATE],[FIRST_ISSUED_DATE],[ISSUED_DATE],[DOCUMENTNO],[REVERTED_BY_RECEIPT],[DESCRIPTION],[CUTOFF]
	FROM [SQL_SV65].[PowerBI].[DPO].[DP_POSubmitDA_CUTOFF]
	WHERE [CUTOFF] = @varCUTOFF_TIME
	--5
	INSERT INTO [dbo].[T_DP_TAGENTCOMM_TEST_CUTOFF] 
	([Policy No],[Product Code],[Premium transaction],[Premium transaction name],[Premium Collected],[Collected Date],[Applied Premium Date],[FYC],[RYC],[Shared Commission Rate],[Policy Status],[Policy Year],[Frequency of Payment],[Issued Date],[Effected Date],[Terminated Date],[Lapse Date]
	,[Due Date],[Next Due Date],[Area Code],[Issuing Agent],[Servicing Agent],[Commission Agent],[Transfer Date],[Proposal Receive Date],[Freelook],[RISK_COMMENCE_DATE],[Receive Policy date],[Premium Year],[CUTOFF])
	SELECT [Policy No],[Product Code],[Premium transaction],[Premium transaction name],[Premium Collected],[Collected Date],[Applied Premium Date],[FYC],[RYC],[Shared Commission Rate],[Policy Status],[Policy Year],[Frequency of Payment],[Issued Date],[Effected Date],[Terminated Date],[Lapse Date]
			,[Due Date],[Next Due Date],[Area Code],[Issuing Agent],[Servicing Agent],[Commission Agent],[Transfer Date],[Proposal Receive Date],[Freelook],[RISK_COMMENCE_DATE],[Receive Policy date],[Premium Year],[CUTOFF]
	FROM [SQL_SV65].[PowerBI].[DPO].[DP_TAGENTCOMM_TEST_CUTOFF]
	WHERE [CUTOFF] = @varCUTOFF_TIME
	--6
	INSERT INTO [dbo].[T_DP_TAGENTPREMIUM_TEST_CUTOFF]
	([Policy No],[Product Code],[Premium transaction],[PREM TRAN NAME],[Premium Collected],[Collected Date],[Applied Premium Date],[FYP Before Discount],[FYP Discount],[FYP],[RYP],[Topup Premium],[Premium Term],[Premium Year],[Policy Status],[Policy Year],[Policy Term],[Frequency of Payment],[Issued Date]
	,[Effected Date],[Terminated Date],[Lapse Date],[Due date],[Next Due Date],[Transfer Date],[POLICY ACKNOWLED],[Sum Assure],[Area Code],[Servicing Agent],[Freelook],[Proposal Receive Date],[RISK_COMMENCE_DATE],[Age_Customer],[Issuing Agent],[AFYP],[CUTOFF])
	SELECT [Policy No],[Product Code],[Premium transaction],[PREM TRAN NAME],[Premium Collected],[Collected Date],[Applied Premium Date],[FYP Before Discount],[FYP Discount],[FYP],[RYP],[Topup Premium],[Premium Term],[Premium Year],[Policy Status],[Policy Year],[Policy Term],[Frequency of Payment],[Issued Date]
	,[Effected Date],[Terminated Date],[Lapse Date],[Due date],[Next Due Date],[Transfer Date],[POLICY ACKNOWLED],[Sum Assure],[Area Code],[Servicing Agent],[Freelook],[Proposal Receive Date],[RISK_COMMENCE_DATE],[Age_Customer],[Issuing Agent],[AFYP],[CUTOFF]
	FROM [SQL_SV65].[PowerBI].[DPO].[DP_TAGENTPREMIUM_TEST_CUTOFF]
	WHERE [CUTOFF] = @varCUTOFF_TIME
	--7
	INSERT INTO [dbo].[T_DP_TDAILYSALES_DA_CUTOFF]
	([Agent Code],[Policy_Number],[Issuing_Agent],[Contract Type],[Component_Code],[Proposal_Receive_Date],[Policy_Issue_Date],[Sum_Assured],[Before_Discount_Premium],[Discount_Premium],[After_Discount_Premium]
	,[Policy_Status],[Bill_Frequency],[Modal_Factor],[Lapsed_date],[AFYP],[RISK_COMMENCE_DATE],[AREF],[CUTOFF],[ACK_DATE])
	SELECT [Agent Code],[Policy_Number],[Issuing_Agent],[Contract Type],[Component_Code],[Proposal_Receive_Date],[Policy_Issue_Date],[Sum_Assured],[Before_Discount_Premium],[Discount_Premium],[After_Discount_Premium]
	,[Policy_Status],[Bill_Frequency],[Modal_Factor],[Lapsed_date],[AFYP],[RISK_COMMENCE_DATE],[AREF],[CUTOFF],[ACK_DATE]
	FROM [SQL_SV65].[PowerBI].[DPO].[DP_TDAILYSALES_DA_CUTOFF]
	WHERE [CUTOFF] = @varCUTOFF_TIME
	--8
	INSERT INTO [dbo].[T_Main_AGENT_HISTORY_CUTOFF]
	([AGENT CODE],[STATUS],[OLD GRADE],[GRADE],[CURRFROM],[CURRTO],[New Leader Code],[Old Leader Code]
,[NOTE],[CLUB CLASS],[EFFECTIVE DATE CLUB CLASS],[Reason mark club class],[EXPIRED_LICENSE_DATE],[RN],[CUTOFF])
	SELECT [AGENT CODE],[STATUS],[OLD GRADE],[GRADE],[CURRFROM],[CURRTO],[New Leader Code],[Old Leader Code]
,[NOTE],[CLUB CLASS],[EFFECTIVE DATE CLUB CLASS],[Reason mark club class],[EXPIRED_LICENSE_DATE],[RN],[CUTOFF]
	FROM [SQL_SV65].[PowerBI].[DPO].[Main_AGENT_HISTORY_CUTOFF]
	WHERE [CUTOFF] = @varCUTOFF_TIME
	--9
	INSERT INTO [dbo].[T_Main_AGENT_INFO_DA_CUTOFF]
	([Area_Name],[Sales_Unit],[Sales_Unit_Code],[Parent_Supervisor_Code],[Parent_Supervisor_Name],[Supervisor_Code],[Supervisor_Name],[Agent_Number],[Agent_Name],[Gender],[Grade],[Club_Class],[Agent_Status],[Birthday],[BirthPlace],[ID_Card],[Issued Date],[Issued Place],[Marriage],[Age],[Client_Code],[Client_Name]
	,[Email],[Telephone],[Hand_Phone],[Contact Address],[Contact2],[Contact3],[Contact4],[Contact5],[Alternate_Address],[Alternate2],[Alternate3],[Alternate4],[Alternate5],[Date_Appointed],[Terminated_date],[Reason Terminated],[Recovered Date],[Client Number of Introducer],[Client Name of Introducer],[Client ID number of Introducer]
	,[Agent Numer of Introducer],[Agent_Bank_Account],[Bank_Code],[Bank Name],[Bank_Address],[Bank_Address2],[Bank_Address3],[Bank_Address4],[License_No],[Tax Code],[Tax Office],[Previous Insurance],[Experience in the insurance],[Agent Classification],[Promote_Date],[Demote_Date],[Effective_Date_Club_Class],[Bank_Number],[Leader],[SFC],[Leader_count],[Appointed_TAPSU],[CUTOFF])
	SELECT [Area_Name],[Sales_Unit],[Sales_Unit_Code],[Parent_Supervisor_Code],[Parent_Supervisor_Name],[Supervisor_Code],[Supervisor_Name],[Agent_Number],[Agent_Name],[Gender],[Grade],[Club_Class],[Agent_Status],[Birthday],[BirthPlace],[ID_Card],[Issued Date],[Issued Place],[Marriage],[Age],[Client_Code],[Client_Name]
	,[Email],[Telephone],[Hand_Phone],[Contact Address],[Contact2],[Contact3],[Contact4],[Contact5],[Alternate_Address],[Alternate2],[Alternate3],[Alternate4],[Alternate5],[Date_Appointed],[Terminated_date],[Reason Terminated],[Recovered Date],[Client Number of Introducer],[Client Name of Introducer],[Client ID number of Introducer]
	,[Agent Numer of Introducer],[Agent_Bank_Account],[Bank_Code],[Bank Name],[Bank_Address],[Bank_Address2],[Bank_Address3],[Bank_Address4],[License_No],[Tax Code],[Tax Office],[Previous Insurance],[Experience in the insurance],[Agent Classification],[Promote_Date],[Demote_Date],[Effective_Date_Club_Class],[Bank_Number],[Leader],[SFC],[Leader_count],[Appointed_TAPSU],[CUTOFF]
	FROM [SQL_SV65].[PowerBI].[DPO].[Main_AGENT_INFO_DA_CUTOFF]
	WHERE [CUTOFF] = @varCUTOFF_TIME
	--10
	INSERT INTO [dbo].[T_Main_CUSTOMER_INFO_CUTOFF]
	([POLICY_CODE],[CUSTOMER_NAME],[ID_NUMBER],[CONTRACT_ADDRESS],[TELEPHONE],[MOBILE_PHONE],[SERVICING_AGENT],[CUSTOMER_DOB],[GENDER],[AREF],[CUTOFF])
	SELECT [POLICY_CODE],[CUSTOMER_NAME],[ID_NUMBER],[CONTRACT_ADDRESS],[TELEPHONE],[MOBILE_PHONE],[SERVICING_AGENT],[CUSTOMER_DOB],[GENDER],[AREF],[CUTOFF]
	FROM [SQL_SV65].[PowerBI].[DPO].[Main_CUSTOMER_INFO_CUTOFF]
	WHERE [CUTOFF] = @varCUTOFF_TIME
END;
GO


