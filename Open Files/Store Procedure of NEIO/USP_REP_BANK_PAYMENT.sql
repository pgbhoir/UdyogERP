DROP PROCEDURE [USP_REP_BANK_PAYMENT]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lokesh.
-- Create date: 25/04/2012
-- Description:	This Stored procedure is useful to generate Sales vs Purchase details.
-- Modify By/date/Remark: Shrikant S. on 25/06/2013 for Bug-16243
-- Modify By/date/Remark: sandeep on  5-Sep-13 for bug-18794
-- =============================================

--EXECUTE USP_REP_BANK_PAYMENT '','','','04/01/2014','03/31/2015','HDFC                                              ','HDFC                                              ','','',0,0,'','','','','','','','','2014-2015',''

Create procedure [USP_REP_BANK_PAYMENT]
@TMPAC NVARCHAR(50),@TMPIT NVARCHAR(50),@SPLCOND VARCHAR(8000),@SDATE  SMALLDATETIME,@EDATE SMALLDATETIME
,@SAC AS VARCHAR(60),@EAC AS VARCHAR(60)
,@SIT AS VARCHAR(60),@EIT AS VARCHAR(60)
,@SAMT FLOAT,@EAMT FLOAT
,@SDEPT AS VARCHAR(60),@EDEPT AS VARCHAR(60)
,@SCATE AS VARCHAR(60),@ECATE AS VARCHAR(60)
,@SWARE AS VARCHAR(60),@EWARE AS VARCHAR(60)
,@SINV_SR AS VARCHAR(60),@EINV_SR AS VARCHAR(60)
,@LYN VARCHAR(20)
,@EXPARA  AS VARCHAR(60)= null
AS


Begin
SELECT entry_ty,date,doc_no,party_nm,inv_no,inv_sr,gro_amt,cast(narr as varchar(2000)) as narr,cheq_no,bank_nm,drawn_on,tdspaytype
,Tran_cd,Ac_id,Bk_id,CompId
FROM BPMAIN
Where (date Between  @SDATE and @EDATE)--Added By Shrikant S. on 25/06/2013 for Bug-16243
AND (BANK_NM BETWEEN @SAC AND @EAC)	   --Added by sandeep on  5-Sep-13 for bug-18794
End
GO
