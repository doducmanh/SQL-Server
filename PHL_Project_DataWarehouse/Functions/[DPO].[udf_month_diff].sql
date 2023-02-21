USE [PowerBI]
GO

/****** Object:  UserDefinedFunction [DPO].[udf_month_diff]    Script Date: 30/09/2022 16:51:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [DPO].[udf_month_diff]
(
   @FromDate DATETIME, @ToDate DATETIME
)
RETURNS DECIMAL
AS
BEGIN
    DECLARE @Years INT, @Months INT, @Days INT, @tmpFromDate DATETIME
    SET @Years = DATEDIFF(YEAR, @FromDate, @ToDate)
     - (CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, @FromDate, @ToDate),
              @FromDate) > @ToDate THEN 1 ELSE 0 END) 
    
    SET @tmpFromDate = DATEADD(YEAR, @Years , @FromDate)
    SET @Months =  DATEDIFF(MONTH, @tmpFromDate, @ToDate)
     - (CASE WHEN DATEADD(MONTH,DATEDIFF(MONTH, @tmpFromDate, @ToDate),
              @tmpFromDate) > @ToDate THEN 1 ELSE 0 END) 
    
    SET @tmpFromDate = DATEADD(MONTH, @Months , @tmpFromDate)
    SET @Days =  DATEDIFF(DAY, @tmpFromDate, @ToDate)
     - (CASE WHEN DATEADD(DAY, DATEDIFF(DAY, @tmpFromDate, @ToDate),
              @tmpFromDate) > @ToDate THEN 1 ELSE 0 END) 
   
   
    RETURN @Years*12 + @Months + @Days/30.0
END
GO


