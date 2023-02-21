USE [PowerBI]
GO

/****** Object:  View [DPO].[view_PS_in_DP_TDAILYSALES_DA]    Script Date: 30/09/2022 16:41:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- Note: from a. Phú IT
--View này lấy data toàn bộ phí đóng của khách hàng, nếu khách hàng đã đóng phí nhưng trạng thái hợp đồng là PS thì cũng sẽ có data.
--Chỉ trường hợp PS nhưng chưa đóng phí thì ko có thôi.
--View này dành cho bên DA tính thưởng cho đại lý nên ko chỉnh sửa gì trên view này nha 

CREATE   VIEW [DPO].[view_PS_in_DP_TDAILYSALES_DA]
AS
SELECT [Policy_Number] as [Policy No]
      ,[Contract Type] as [Product Code]
      ,'' as [Premium transaction] 
      ,'' as [PREM TRAN NAME]
      ,NULL as [Premium Collected]
      ,NULL as [Collected Date]
      ,NULL as [Applied Premium Date]
      ,[Before_Discount_Premium] as [FYP Before Discount]
      ,[Discount_Premium] as [FYP Discount]
      ,[After_Discount_Premium] as [FYP]
      ,NULL as [RYP] 
      ,NULL as [Topup Premium]
      ,NULL as [Premium Term]
      ,NULL as [Premium Year]
      ,[Policy_Status] as [Policy Status]
      ,NULL as [Policy Year]
      ,NULL as [Policy Term]
      ,'' as [Frequency of Payment]
      ,[Policy_Issue_Date] as [Issued Date]
      ,NULL as [Effected Date]
      ,NULL as [Terminated Date]
      ,[Lapsed_date] as [Lapse Date]
      ,NULL as [Due date]
      ,NULL as [Next Due Date]
      ,NULL as [Transfer Date]
      ,NULL as [POLICY ACKNOWLED]
      ,[Sum_Assured] as [Sum Assure]
      ,'' as [Area Code]
      , [Agent Code] as [Servicing Agent]
      ,NULL as [Freelook]
      ,[Proposal_Receive_Date] as [Proposal Receive Date]
      ,[RISK_COMMENCE_DATE] as [RISK_COMMENCE_DATE]
      ,NULL as [Age_Customer]
      , [Issuing_Agent] as [Issuing Agent]
      ,[AFYP] as [AFYP]
    
  FROM [PowerBI].[DPO].[DP_TDAILYSALES_DA]
  where [Policy_Status] = 'PS'
GO


