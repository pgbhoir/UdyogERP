DROP PROCEDURE [Usp_Rep_Service_Distributed_Detailed]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ruepesh Prajapati.
-- Create date: 25/11/2009
-- Description:	This Stored procedure is useful for Service Distributed Register Detailed.                       
-- Modification Date/By/Reason: Shrikant S. on 08/08/2012 for ISD 
-- Remark:
-- =============================================

create Procedure [Usp_Rep_Service_Distributed_Detailed] 
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
as
begin
	Declare @FCON as NVARCHAR(2000),@SQLCOMMAND as NVARCHAR(4000)
	EXECUTE   USP_REP_FILTCON 
	@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
	,@VSDATE=@SDATE,@VEDATE=@EDATE
	,@VSAC =@SAC,@VEAC =@EAC
	,@VSIT=@SIT,@VEIT=@EIT
	,@VSAMT=@SAMT,@VEAMT=@EAMT
	,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
	,@VSCATE =@SCATE,@VECATE =@ECATE
	,@VSWARE =@SWARE,@VEWARE  =@EWARE
	,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
	,@VMAINFILE='M',@VITFILE=Null,@VACFILE=''
	,@VDTFLD ='DATE'
	,@VLYN=Null
	,@VEXPARA=@EXPARA
	,@VFCON =@FCON OUTPUT
	/*select entry_ty,code_nm,bcode_nm=case when ext_vou=0 then entry_ty else bcode_nm end into #lcode from lcode
	select aentry_ty,atran_cd,serbamt=sum(serbamt),sercamt=sum(sercamt),serhamt=sum(serhamt) 
	into #ISDAllocation 
	from ISDAllocation 
	where entry_ty=@entry_ty and tran_Cd<>@tran_cd
	group by aentry_ty,atran_cd*/
	
	SET @SQLCOMMAND='SELECT M.DATE,M.INV_NO'
	--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',m1inv_no=m1.inv_no,m1date=m1.date,m1.serty,m1.u_pinvno,m1.u_pinvdt,SerProvider=a1.ac_name'	--Commented By Shrikant S. on 07/08/2012 for ISD allocation.
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',m1inv_no=m1.inv_no,m1date=m1.date,i.serty,m1.u_pinvno,m1.u_pinvdt,SerProvider=a1.ac_name'		--Added By Shrikant S. on 07/08/2012 for ISD allocation.
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',i.serbamt,i.sercamt,i.serhamt'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',m1serbamt=m1.serbamt,m1sercamt=m1.sercamt,m1serhamt=m1.serhamt'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',AC_MAST.AC_NAME,ac_mast.eccno,ac_mast.i_tax,ac_mast.cexregno,ac_mast.division,ac_mast.coll,ac_mast.[range],ac_mast.add1,ac_mast.add2,ac_mast.add3,ac_mast.city,ac_mast.zip'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',m.entry_ty,m.tran_cd,m1entry_ty=m1.entry_ty,m1tran_cd=m1.tran_cd'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',A1.sregn'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'FROM SDMAIN M'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'INNER JOIN AC_MAST ON (M.AC_ID=AC_MAST.AC_ID)'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'inner join ISDAllocation i on (i.entry_ty=m.entry_ty and i.tran_cd=m.tran_cd)'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'inner join SerTaxMain_vw m1 on (i.aentry_ty=m1.entry_ty and i.atran_cd=m1.tran_cd)'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'INNER JOIN AC_MAST A1 ON (M1.AC_ID=A1.AC_ID)'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON)
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' Order by ac_mast.ac_name,m.date,m1.serty'
	PRINT @SQLCOMMAND
	EXECUTE SP_EXECUTESQL @SQLCOMMAND
	

end
GO
