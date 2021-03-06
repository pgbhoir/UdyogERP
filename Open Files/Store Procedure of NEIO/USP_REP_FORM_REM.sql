DROP PROCEDURE [USP_REP_FORM_REM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_REP_FORM_REM'','','','04/01/2014','03/31/2015','','WORK ORDER                                        ','','',0,0,'','','','','','','','LABOUR JOB [ANNE-V] ','2014-2015',''
*/


-- =============================================
-- Author:		Ruepesh Prajapati.
-- Create date: 16/05/2007
-- Description:	This Stored procedure is useful to generate ACCOUNTS 1key Balance Listing  Report .
-- Modify date: 16/05/2007
-- Modified By: 
-- Modify date: 
-- Modification: Nilesh Yadav on 6/8/14 for Bug23748(Form Issued / Form Received Details is not displaying in the Form Reminder Report)
-- Remark:
-- =============================================
create PROCEDURE [USP_REP_FORM_REM]  
--@SDATE AS SMALLDATETIME,@EDATE AS SMALLDATETIME, @SAC AS VARCHAR(100), @EAC AS VARCHAR(100)
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

Declare @FCON as NVARCHAR(2000),@SQLCOMMAND as NVARCHAR(4000)
--Bug23748 start
Declare @a varchar(10)															
select @a=stax_item from LCODE where Entry_ty='st'								 
--Bug23748 end

EXECUTE   USP_REP_FILTCON 
@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
,@VSDATE=@SDATE,@VEDATE=@EDATE
,@VSAC =@SAC,@VEAC =@EAC
,@VSIT=NULL,@VEIT=NULL
,@VSAMT=@SAMT,@VEAMT=@EAMT
,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
,@VSCATE =@SCATE,@VECATE =@ECATE
,@VSWARE =@SWARE,@VEWARE  =@EWARE
,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
,@VMAINFILE='STMAIN',@VITFILE=Null,@VACFILE='NULL'
,@VDTFLD ='DATE'
,@VLYN=@LYN
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT


-- Bug23748 start
if(@a='1')
begin
SET @SQLCOMMAND='SELECT ac_mast.ac_name,ac_mast.ADD1,ac_mast.ADD2,ac_mast.ADD3,ac_mast.contact,ac_mast.CITY,ac_mast.ZIP,ac_mast.STATE,s.INV_NO,s.DATE,stmain.NET_AMT,stmain.form_no,c.rform_nm'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'FROM STITEM s'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'inner JOIN AC_MAST ON (s.AC_ID=ac_mast.AC_ID)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'inner join STMAIN on (stmain.Tran_cd=s.Tran_cd)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'inner join STAX_MAS c on (s.tax_name=c.tax_name and s.entry_ty=c.entry_ty)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON)
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'AND stmain.form_no='+CHAR(39)+SPACE(1)+CHAR(39)
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'Order by Ac_name'
end
else 
begin
SET @SQLCOMMAND='SELECT ac_mast.ac_name,ac_mast.ADD1,ac_mast.ADD2,ac_mast.ADD3,ac_mast.contact,ac_mast.CITY,ac_mast.ZIP,ac_mast.STATE,stmain.INV_NO,stmain.DATE,stmain.NET_AMT,stmain.form_no,c.rform_nm'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'FROM STmain'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'inner JOIN AC_MAST ON (stmain.AC_ID=ac_mast.AC_ID)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'inner join STAX_MAS c on (stmain.tax_name=c.tax_name and stmain.entry_ty=c.entry_ty)'
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'where stmain.form_no='''''				&& commented by nilesh for bug 23748 on 23-08-14
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON)
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'AND stmain.form_no='+CHAR(39)+SPACE(1)+CHAR(39)
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'Order by Ac_name'
end
--Bug23748 end

EXECUTE SP_EXECUTESQL @SQLCOMMAND
GO
