DROP PROCEDURE [USP_REP_1_JVREG]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ruepesh Prajapati.
-- Create date: 16/05/2007
-- Description:	This Stored procedure is useful to generate ACCOUNTS 1key JV Register Report.
-- Modify date: 16/05/2007
-- Modified By: 
-- Modify date: 
-- Remark:
-- =============================================

Create PROCEDURE [USP_REP_1_JVREG] 
@SDATE AS SMALLDATETIME,@EDATE AS SMALLDATETIME,@SAC AS VARCHAR(100),@EAC AS VARCHAR(100)
 AS


SELECT YEAR=year(M.date),YearMonth=convert(varchar(4),year(M.date))+'-'+convert(varchar(2),M.date,101),MONTH=DATENAME(MM,M.DATE), A.AC_NAME as [Account Name],M.Date,m.Inv_no as [Ref.No.]
,M.net_amt as [Amount]
,M.Narr as [Narration] ,m.dept as [Department],m.cate as [Category],m.inv_sr as [Invoice Series],M.entry_ty as [Transaction Type],M.TRAN_cd,M.AC_ID,a.mailname,a.State
FROM JVMAIN M 
INNER JOIN AC_MAST A ON (M.AC_ID=A.AC_ID) 
WHERE (M.DATE BETWEEN @SDATE AND @EDATE) AND (A.AC_NAME BETWEEN @SAC AND @EAC)
ORDER BY M.DATE,M.TRAN_CD
GO
