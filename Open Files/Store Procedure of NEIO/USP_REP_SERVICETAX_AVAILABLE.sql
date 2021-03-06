DROP PROCEDURE [USP_REP_SERVICETAX_AVAILABLE]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ruepesh Prajapati.
-- Create date: 11/07/2008
-- Description:	This Stored procedure is useful to generate Service Tax Input Credit Available Report .
-- Modify date: 16/05/2007
-- Modified By: 
-- Modify date: 
-- Remark:
-- =============================================

CREATE procedure [USP_REP_SERVICETAX_AVAILABLE]
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
	Declare @FCON as NVARCHAR(2000),@SQLCOMMAND as NVARCHAR(4000)
	select m.entry_ty,m.tran_cd,m.pinvdt,m.date,m.inv_no,m.pinvno,m.serty,pdate=m.date ,a.ac_name,a.add1,a.add2,a.add3,a.SREGN,m.net_amt
	,taxable_amt=m.gro_amt+m.tot_deduc+m.tot_tax 
	,bSrTax=m.net_amt
	,bESrTax=m.net_amt
	,bHSrTax=m.net_amt
	,aSrTax=m.net_amt
	,aESrTax=m.net_amt
	,aHSrTax=m.net_amt
	into #serava
	from EPacdet ac 
	inner join EPmain m on (ac.entry_ty=m.entry_ty and ac.tran_cd=m.tran_cd) 
	inner join ac_mast a on (m.ac_id=a.ac_id) inner join ac_mast aa on (ac.ac_id=aa.ac_id) 
	inner join mainall_vw mall on (m.entry_ty=mall.entry_all and m.tran_cd=mall.main_tran and m.ac_id=mall.ac_id)   
	WHERE 1=2
	
	EXECUTE USP_REP_FILTCON 
	@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
	,@VSDATE=@SDATE,@VEDATE=@EDATE
	,@VSAC =@SAC,@VEAC =@EAC
	,@VSIT=@SIT,@VEIT=@EIT
	,@VSAMT=@SAMT,@VEAMT=@EAMT
	,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
	,@VSCATE =@SCATE,@VECATE =@ECATE
	,@VSWARE =@SWARE,@VEWARE  =@EWARE
	,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
	,@VMAINFILE='mall',@VITFILE=Null,@VACFILE='AC'
	,@VDTFLD ='DATE'
	,@VLYN=Null
	,@VEXPARA=@EXPARA
	,@VFCON =@FCON OUTPUT
	
	set @sqlcommand='insert into #serava select m.entry_ty,m.tran_cd,m.u_pinvdt,m.date,m.inv_no,m.u_pinvno,m.serty,pdate=mall.date'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',a.ac_name,a.add1,a.add2,a.add3,a.SREGN,m.net_amt,taxable_amt=m.gro_amt+m.tot_deduc+m.tot_tax'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',bSrTax=m.serbamt'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',bESrTax=m.sercamt'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',bHSrTax=m.serhamt'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',aSrTax=sum(case when aa.typ='+'''Input Service Tax'''+' then mall.tds else 0 end)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',aESrTax=sum(case when aa.typ='+'''Input Service Tax-Ecess'''+' then mall.tds else 0 end)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',aHSrTax=sum(case when aa.typ='+'''Input Service Tax-Hcess'''+' then mall.tds else 0 end)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+' from EPacdet ac'
	set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join EPmain m on (ac.entry_ty=m.entry_ty and ac.tran_cd=m.tran_cd)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join ac_mast a on (m.ac_id=a.ac_id)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join ac_mast aa on (ac.ac_id=aa.ac_id)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join mainall_vw mall on (m.entry_ty=mall.entry_all and m.tran_cd=mall.main_tran and ac.acserial=mall.acseri_all)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+rtrim(@fcon)
	set @sqlcommand=rtrim(@sqlcommand)+' '+'and aa.typ like '+'''%input%serv%'''+' and ac.amt_ty='+'''DR'''
	set @sqlcommand=rtrim(@sqlcommand)+' '+'group by m.entry_ty,m.tran_cd,m.date,m.inv_no,m.u_pinvdt,m.u_pinvno,m.serty'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',a.ac_name,a.add1,a.add2,a.add3,a.SREGN,m.net_amt,m.gro_amt,m.tot_deduc,m.tot_tax,mall.date,m.serbamt,m.sercamt,m.serhamt'
	
	print  @SQLCOMMAND
	EXECUTE SP_EXECUTESQL @SQLCOMMAND
	
	EXECUTE USP_REP_FILTCON 
	@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
	,@VSDATE=@SDATE,@VEDATE=@EDATE
	,@VSAC =@SAC,@VEAC =@EAC
	,@VSIT=@SIT,@VEIT=@EIT
	,@VSAMT=@SAMT,@VEAMT=@EAMT
	,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
	,@VSCATE =@SCATE,@VECATE =@ECATE
	,@VSWARE =@SWARE,@VEWARE  =@EWARE
	,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
	,@VMAINFILE='m',@VITFILE=Null,@VACFILE='AC'
	,@VDTFLD ='DATE'
	,@VLYN=Null
	,@VEXPARA=@EXPARA
	,@VFCON =@FCON OUTPUT

	set @sqlcommand='insert into #serava select m.entry_ty,m.tran_cd,m.u_pinvdt,m.date,m.inv_no,m.u_pinvno,m.serty'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',pdate=m.date ,a.ac_name,a.add1,a.add2,a.add3,a.SREGN,m.net_amt'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',taxable_amt=m.gro_amt+m.tot_deduc+m.tot_tax '
	set @sqlcommand=rtrim(@sqlcommand)+' '+',bSrTax=0'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',bESrTax=0'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',bHSrTax=0'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',aSrTax=sum(case when aa.typ='+'''Service Tax Available'''+' then amount else 0 end)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',aESrTax=sum(case when aa.typ='+'''Service Tax Available-Ecess'''+' then amount else 0 end)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',aHSrTax=sum(case when aa.typ='+'''Service Tax Available-Hcess'''+' then amount else 0 end)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+'from bpacdet ac '
	set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join bPmain m on (ac.entry_ty=m.entry_ty and ac.tran_cd=m.tran_cd) '
	set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join ac_mast a on (m.ac_id=a.ac_id) inner join ac_mast aa on (ac.ac_id=aa.ac_id) '
	set @sqlcommand=rtrim(@sqlcommand)+' '+rtrim(@fcon)
	set @sqlcommand=rtrim(@sqlcommand)+' '+'and aa.typ like '+'''%Service%Available%'''
	set @sqlcommand=rtrim(@sqlcommand)+' '+'and m.tdspaytype=2 and ac.amt_ty='+'''DR'''
	set @sqlcommand=rtrim(@sqlcommand)+' '+'group by m.entry_ty,m.tran_cd,m.date,m.inv_no,m.u_pinvdt,m.u_pinvno,m.serty ,a.ac_name,a.add1,a.add2,a.add3,a.SREGN,m.net_amt,m.gro_amt,m.tot_deduc,m.tot_tax,m.date '
	print  @SQLCOMMAND
	EXECUTE SP_EXECUTESQL @SQLCOMMAND

	set @sqlcommand='insert into #serava select m.entry_ty,m.tran_cd,m.u_pinvdt,m.date,m.inv_no,m.u_pinvno,m.serty'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',pdate=m.date ,a.ac_name,a.add1,a.add2,a.add3,a.SREGN,m.net_amt'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',taxable_amt=m.gro_amt+m.tot_deduc+m.tot_tax '
	set @sqlcommand=rtrim(@sqlcommand)+' '+',bSrTax=0'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',bESrTax=0'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',bHSrTax=0'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',aSrTax=sum(case when aa.typ='+'''Service Tax Available'''+' then amount else 0 end)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',aESrTax=sum(case when aa.typ='+'''Service Tax Available-Ecess'''+' then amount else 0 end)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',aHSrTax=sum(case when aa.typ='+'''Service Tax Available-Hcess'''+' then amount else 0 end)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+'from cpacdet ac '
	set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join cPmain m on (ac.entry_ty=m.entry_ty and ac.tran_cd=m.tran_cd) '
	set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join ac_mast a on (m.ac_id=a.ac_id) inner join ac_mast aa on (ac.ac_id=aa.ac_id) '
	set @sqlcommand=rtrim(@sqlcommand)+' '+rtrim(@fcon)
	set @sqlcommand=rtrim(@sqlcommand)+' '+'and aa.typ like '+'''%Service%Available%'''
	set @sqlcommand=rtrim(@sqlcommand)+' '+'and m.tdspaytype=2 and ac.amt_ty='+'''DR'''
	set @sqlcommand=rtrim(@sqlcommand)+' '+'group by m.entry_ty,m.tran_cd,m.date,m.inv_no,m.u_pinvdt,m.u_pinvno,m.serty ,a.ac_name,a.add1,a.add2,a.add3,a.SREGN,m.net_amt,m.gro_amt,m.tot_deduc,m.tot_tax,m.date '
	print  @SQLCOMMAND
	EXECUTE SP_EXECUTESQL @SQLCOMMAND

	set @sqlcommand='insert into #serava select m.entry_ty,m.tran_cd,m.u_pinvdt,m.date,m.inv_no,m.u_pinvno,m.serty'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',pdate=m.date ,a.ac_name,a.add1,a.add2,a.add3,a.SREGN,m.net_amt'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',taxable_amt=m.gro_amt+m.tot_deduc+m.tot_tax '
	set @sqlcommand=rtrim(@sqlcommand)+' '+',bSrTax=0'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',bESrTax=0'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',bHSrTax=0'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',aSrTax=sum(case when aa.typ='+'''Service Tax Available'''+' then amount else 0 end)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',aESrTax=sum(case when aa.typ='+'''Service Tax Available-Ecess'''+' then amount else 0 end)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',aHSrTax=sum(case when aa.typ='+'''Service Tax Available-Hcess'''+' then amount else 0 end)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+'from jvacdet ac '
	set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join jvmain m on (ac.entry_ty=m.entry_ty and ac.tran_cd=m.tran_cd) '
	set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join ac_mast a on (m.ac_id=a.ac_id) inner join ac_mast aa on (ac.ac_id=aa.ac_id) '
	set @sqlcommand=rtrim(@sqlcommand)+' '+rtrim(@fcon)
	set @sqlcommand=rtrim(@sqlcommand)+' '+'and aa.typ like '+'''%Service%Available%'''
	set @sqlcommand=rtrim(@sqlcommand)+' '+'and ac.amt_ty='+'''DR'''
	set @sqlcommand=rtrim(@sqlcommand)+' '+'group by m.entry_ty,m.tran_cd,m.date,m.inv_no,m.u_pinvdt,m.u_pinvno,m.serty ,a.ac_name,a.add1,a.add2,a.add3,a.SREGN,m.net_amt,m.gro_amt,m.tot_deduc,m.tot_tax,m.date '
	print  @SQLCOMMAND
	EXECUTE SP_EXECUTESQL @SQLCOMMAND


	select * from #serava where asrtax > 0 order by m.serty,m.date,m.tran_cd
	
	DROP TABLE #serava
	
END
GO
