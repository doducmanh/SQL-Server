USE [PowerBI]
GO

/****** Object:  StoredProcedure [DPO].[BI_PS_TABLE_DW]    Script Date: 30/09/2022 16:50:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [DPO].[BI_PS_TABLE_DW]

AS
BEGIN

	--input new change to data warehouse
	INSERT INTO PowerBI.[DPO].PS_CONTRACT_PC_POLICY2_DW
			SELECT * FROM [DPO].[PS_CONTRACT_PC_POLICY2_Latest_Exploded_1]
	;
END
GO


