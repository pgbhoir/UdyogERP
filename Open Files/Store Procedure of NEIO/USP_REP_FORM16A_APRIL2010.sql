DROP PROCEDURE [USP_REP_FORM16A_APRIL2010]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Rupesh Prajapati		
-- Create date: 29/06/2010
-- Description:	This is useful for TDS FORM 16A w.e.f. 01 April 2010 report.
-- Modification Date/By/Reason: Changes done by Ajay Jaiswal on 15/07/2010 for TKT-2867.
-- Modification Date/By/Reason: Changes done by Shrikant S. on 19/01/2012 for Bug-1631
-- Remark: 
-- =============================================
Create    PROCEDURE [USP_REP_FORM16A_APRIL2010]  
 @TMPAC NVARCHAR(60),@TMPIT NVARCHAR(60),@SPLCOND NVARCHAR(500),  
 @SDATE SMALLDATETIME,@EDATE SMALLDATETIME,  
 @SNAME NVARCHAR(60),@ENAME NVARCHAR(60),  
 @SITEM NVARCHAR(60),@EITEM NVARCHAR(60),  
 @SAMT NUMERIC,@EAMT NUMERIC,  
 @SDEPT NVARCHAR(60),@EDEPT NVARCHAR(60),  
 @SCAT NVARCHAR(60),@ECAT NVARCHAR(60),  
 @SWARE NVARCHAR(60),@EWARE NVARCHAR(60),  
 @SINVSR NVARCHAR(60),@EINVSR NVARCHAR(60),  
 @FINYR NVARCHAR(20), @EXTPAR NVARCHAR(60)  
 AS
Declare @FCON as NVARCHAR(4000),@SQLCOMMAND as NVARCHAR(4000)  
  EXECUTE USP_REP_FILTCON   
  @VTMPAC=@TMPAC,@VTMPIT=null,@VSPLCOND=@SPLCOND,  
  @VSDATE=@SDATE,@VEDATE=@EDATE,  
  @VSAC =@SNAME,@VEAC =@ENAME,  
  @VSIT=null,@VEIT=null,  
  @VSAMT=@SAMT,@VEAMT=@EAMT,  
  @VSDEPT=@SDEPT,@VEDEPT=@EDEPT,  
  @VSCATE =@SCAT,@VECATE =@ECAT,  
  @VSWARE =null,@VEWARE  =null,  
  @VSINV_SR =@SINVSR,@VEINV_SR =@EINVSR,  
  @VMAINFILE='M',@VITFILE=null,@VACFILE=NULL,  
  @VDTFLD = 'U_CLDT',@VLYN=null,@VEXPARA=@EXTPAR,  
  @VFCON =@FCON OUTPUT  
 PRINT @FCON  
 SET @SQLCOMMAND = ''  
Declare @ac_id int ,@section varchar(60),@svc_cate varchar(200),@date smalldatetime,@SRNO1 int,@SRNO2 int

SELECT DISTINCT SVC_CATE,SECTION INTO #TDSMASTER FROM TDSMASTER 

Select ac_mast.ac_id,m.cheq_no,m.u_chalno,m.u_chaldt,m.bsrcode  /*m.entry_ty,m.tran_cd,ac.acserial,mall.new_all,*/
,m.svc_cate,m.TDSonAmt,m.date,tm.section,tdspay=m.net_amt
,TDSAmt=mall.new_all,scamt=mall.new_all,ecamt=mall.new_all,hcamt=mall.new_all,TotTDSAmt=mall.new_all
--,ac_mast.ac_name,ac_mast.add1,ac_mast.add2,ac_mast.add3,ac_mast.city,ac_mast.zip,ac_mast.i_tax
,mall.entry_all,mall.main_tran,mall.acseri_all 
into #table1
from tdsmain_vw m
inner join lac_vw ac on (m.entry_ty=ac.entry_ty and m.tran_cd=ac.tran_cd) 
inner join mainall_vw mall on (ac.entry_ty=mall.entry_ty and ac.tran_cd=mall.tran_cd and ac.acserial=mall.acserial)
inner join ac_mast on (ac_mast.ac_id=ac.ac_id)
inner join #TDSMASTER tm on (m.svc_cate=tm.svc_cate)
where 1=2
 
set @SqlCommand = 'insert into #table1 Select ac_mast.ac_id,m.cheq_no,m.u_chalno,m.u_chaldt,m.bsrcode' /*m.entry_ty,m.tran_cd,ac.acserial,mall.new_all,*/
set @SqlCommand=RTRIM(@SqlCommand)+' '+',m1.svc_cate,m1.TDSonAmt,m1.date,tm.section,tdspay=m1.net_amt'
set @SqlCommand=RTRIM(@SqlCommand)+' '+',TDSAmt=0'
set @SqlCommand=RTRIM(@SqlCommand)+' '+',scamt=0'
set @SqlCommand=RTRIM(@SqlCommand)+' '+',ecamt=0'
set @SqlCommand=RTRIM(@SqlCommand)+' '+',hcamt=0'
set @SqlCommand=RTRIM(@SqlCommand)+' '+',TotTDSAmt=sum(case when AC_MAST1.TYP IN (''TDS'',''TDS-SUR'',''TDS-ECESS'',''TDS-HCESS'') then new_all else 0 end)'
set @SqlCommand=RTRIM(@SqlCommand)+' '+',mall.entry_all,mall.main_tran,mall.acseri_all'
set @SqlCommand=RTRIM(@SqlCommand)+' '+'from tdsmain_vw m'
set @SqlCommand=RTRIM(@SqlCommand)+' '+'inner join lac_vw ac on (m.entry_ty=ac.entry_ty and m.tran_cd=ac.tran_cd) '
set @SqlCommand=RTRIM(@SqlCommand)+' '+'inner join mainall_vw mall on (ac.entry_ty=mall.entry_ty and ac.tran_cd=mall.tran_cd and ac.acserial=mall.acserial)'
set @SqlCommand=RTRIM(@SqlCommand)+' '+'inner join ac_mast ac_mast1 on (ac_mast1.ac_id=ac.ac_id)'
set @SqlCommand=RTRIM(@SqlCommand)+' '+'inner join tdsmain_vw m1 on (m1.entry_ty=mall.entry_all and m1.tran_cd=mall.main_tran)'
set @SqlCommand=RTRIM(@SqlCommand)+' '+'inner join ac_mast on (ac_mast.ac_id=m1.ac_id)'
set @SqlCommand=RTRIM(@SqlCommand)+' '+'inner join #TDSMASTER tm on (m1.svc_cate=tm.svc_cate)'
set @SqlCommand=RTRIM(@SqlCommand)+' '+rtrim(@fcon)
set @SqlCommand=RTRIM(@SqlCommand)+' '+' and isnull(mall.new_all,0)>0 '
set @SqlCommand=RTRIM(@SqlCommand)+' '+' and AC_MAST1.TYP IN (''TDS'',''TDS-ECESS'',''TDS-HCESS'',''TDS-SUR'')'
set @SqlCommand=RTRIM(@SqlCommand)+' '+' group by ac_mast.ac_id,m.cheq_no,m.u_chalno,m.u_chaldt,m.bsrcode'
set @SqlCommand=RTRIM(@SqlCommand)+' '+',m1.svc_cate,m1.TDSonAmt,m1.date,tm.section,m1.net_amt'
set @SqlCommand=RTRIM(@SqlCommand)+' '+',mall.entry_all,mall.main_tran,mall.acseri_all'
PRINT @SQLCOMMAND  
EXECUTE SP_EXECUTESQL @SQLCOMMAND 

Select m.Entry_ty,m.Tran_cd
,TDSAmt=sum(case when AC_MAST1.TYP IN ('TDS') then amount else 0 end)
,scamt=sum(case when AC_MAST1.TYP IN ('TDS-SUR') then amount else 0 end)
,ecamt=sum(case when AC_MAST1.TYP IN ('TDS-ECESS') then amount else 0 end)
,hcamt=sum(case when AC_MAST1.TYP IN ('TDS-HCESS') then amount else 0 end)
into #lac1
from tdsmain_vw m 
inner join lac_vw ac on (m.entry_ty=ac.entry_ty and m.tran_cd=ac.tran_cd)
inner join ac_mast ac_mast1 on (ac_mast1.ac_id=ac.ac_id)
where ac.date<=@edate and ac.amt_ty='CR'
group by m.Entry_ty,m.Tran_cd

update a set a.tdsamt=b.tdsamt,a.scamt=b.scamt,a.ecamt=b.ecamt,a.hcamt=b.hcamt
from #table1 a inner join #lac1 b on (b.entry_ty=a.entry_all and b.tran_cd=a.main_tran)

---- Added By Shrikant S. on 19/01/2011 for Bug-1631		--Start
select Part=3,ac_id,section,svc_cate,date,TDSonAmt,totTDS_Ded=TDSAmt
,TotTDSAmt,u_chalno,u_chaldt,bsrcode,Quarter='A' 
into #form16a from #table1 where 1=2

insert into #form16a (Part,ac_id,section,svc_cate,date,TDSonAmt,totTDS_Ded,TotTDSAmt,u_chalno,u_chaldt,bsrcode,Quarter) 
	select Part=1,ac_id,section,svc_cate,date,TDSonAmt=sum(TDSonAmt),totTDS_Ded=sum( isnull(tdsamt,0)+isnull(scamt,0)+isnull(ecamt,0)+isnull(hcamt,0) )
	,TotTDSAmt=sum(TotTDSAmt),u_chalno,u_chaldt,bsrcode,Quarter=case when month(date) between 4 and 6 then '1' else (case when month(date) between 7 and 9 then '2' else (case when month(date) between 10 and 12 then '3' else '4' End ) end)end
	from #table1 
	group by ac_id,section,svc_cate,date,u_chalno,u_chaldt,bsrcode

insert into #form16a (Part,ac_id,section,svc_cate,date,TDSonAmt,totTDS_Ded,TotTDSAmt,u_chalno,u_chaldt,bsrcode,Quarter) 
	select Part=2,ac_id,section,svc_cate,date=0,TDSonAmt=sum(TDSonAmt),totTDS_Ded=sum(totTDS_Ded)
	,TotTDSAmt=sum(TotTDSAmt),u_chalno='',u_chaldt=0,bsrcode='',Quarter
	from #form16a
	Where part=1
	group by ac_id,section,svc_cate,Quarter

insert into #form16a (Part,ac_id,section,svc_cate,date,TDSonAmt,totTDS_Ded,TotTDSAmt,u_chalno,u_chaldt,bsrcode,Quarter) 
	select Part=3,ac_id,section,svc_cate,date,TDSonAmt,totTDS_Ded
	,TotTDSAmt,u_chalno,u_chaldt,bsrcode,Quarter
	from #form16a
	Where part=1

select  
a.*,c.acknow_no
,MailName=(CASE WHEN ISNULL(Ac_mast.MailName,'')='' THEN Ac_mast.ac_name ELSE Ac_mast.mailname END) -- Added by Ajay Jaiswal on 15/07/2010 for TKT-2867
,ac_mast.ac_name,ac_mast.add1,ac_mast.add2,ac_mast.add3,ac_mast.city,ac_mast.zip,ac_mast.i_tax
from #form16a a
inner join ac_mast on (a.ac_id=ac_mast.ac_id)
left Join (Select quarter,acknow_no=rtrim(b.acknow_no) from TDSACKNOW b Where l_yn=@FINYR ) c on (a.quarter=c.quarter)
ORDER BY Mailname,AC_mast.ac_name,a.svc_cate,PART,u_CHALDT,U_CHALNO
---- Added By Shrikant S. on 19/01/2011 for Bug-1631		--End


/*	---- Commented By Shrikant S. on 19/01/2011 for Bug-1631		--Start
select Part=3,SRNO1=99999,ac_id,section,svc_cate,date,TDSonAmt,totTDS_Ded=TDSAmt
,TotTDSAmt,u_chalno,u_chaldt,bsrcode 
into #form16a from #table1 where 1=2


select distinct ac_id,section,svc_cate,date,TDSonAmt,totTDS_Ded=( isnull(tdsamt,0)+isnull(scamt,0)+isnull(ecamt,0)+isnull(hcamt,0) )  into #table2 from #table1 
select distinct ac_id,section,svc_cate,date,TotTDSAmt=sum(isnull(TotTDSAmt,0))  into #table3 from #table1 group by ac_id,section,svc_cate,date

set @SRNO1=0
Declare cur_form16a1 cursor for select distinct ac_id,section,svc_cate,date from #table1 order by ac_id,date,section,svc_cate
open cur_form16a1
fetch next from cur_form16a1 into @ac_id,@section,@svc_cate,@date
while (@@fetch_status=0)
begin
	set @SRNO1=@SRNO1+1
	insert into #form16a (Part,SRNO1,ac_id,section,svc_cate,date,TDSonAmt,totTDS_Ded,TotTDSAmt,u_chalno,u_chaldt,bsrcode) 
	select Part=1,SRNO1=@SRNO1,ac_id,section,svc_cate,date,TDSonAmt=sum(TDSonAmt),totTDS_Ded=sum(totTDS_Ded)
	,TotTDSAmt=0,u_chalno='',u_chaldt='',bsrcode=''
	from #table2
	where ac_id=@ac_id and section=@section and svc_cate=@svc_cate and date=@date
	group by ac_id,section,svc_cate,date
	
	update a set a.TotTDSAmt=b.TotTDSAmt from #form16a a inner join #table3 b on (a.ac_id=b.ac_id and a.section=b.section and a.svc_cate=b.svc_cate and a.date=b.date) 
	where a.ac_id=@ac_id and a.section=@section and a.svc_cate=@svc_cate and a.date=@date and a.part=1
	
	insert into #form16a (Part,SRNO1,ac_id,section,svc_cate,date,TDSonAmt,totTDS_Ded,TotTDSAmt,u_chalno,u_chaldt,bsrcode) 
	select Part=3,SRNO1=@SRNO1,ac_id,section,svc_cate,date,TDSonAmt=0,totTDS_Ded=0
	,TotTDSAmt=sum(isnull(TotTDSAmt,0)),u_chalno,u_chaldt,bsrcode
	from #table1 
	where ac_id=@ac_id and section=@section and svc_cate=@svc_cate and date=@date
	group by ac_id,section,svc_cate,date,u_chalno,u_chaldt,bsrcode
	fetch next from cur_form16a1 into @ac_id,@section,@svc_cate,@date
end	
close cur_form16a1
deallocate cur_form16a1


 DECLARE @QUARTER VARCHAR(20),@ACK_NO VARCHAR(50),@QUARTER1 VARCHAR(20),@QUARTER2 VARCHAR(20),@QUARTER3 VARCHAR(20),@QUARTER4 VARCHAR(20)  
 SELECT @QUARTER=CASE DATEPART(qq,@EDATE) WHEN '1' THEN '4'  
   WHEN '2' THEN '1'  
   WHEN '3' THEN '2'  
   WHEN '4' THEN '3' END  
 --SELECT @ACK_NO=isnull(ACKNOW_NO,'') FROM TDSACKNOW WHERE L_YN=@FINYR AND QUARTER=@QUARTER   
PRINT 'S1'+@QUARTER
if @QUARTER='1'  
Begin
	SELECT @QUARTER1=isnull(ACKNOW_NO,'') FROM TDSACKNOW WHERE L_YN=@FINYR AND QUARTER='1'   
	set @QUARTER2=''
	set @QUARTER3=''
	set @QUARTER4=''
end
if @QUARTER='2'  
Begin
	SELECT @QUARTER1=isnull(ACKNOW_NO,'') FROM TDSACKNOW WHERE L_YN=@FINYR AND QUARTER='1'   
	SELECT @QUARTER2=isnull(ACKNOW_NO,'') FROM TDSACKNOW WHERE L_YN=@FINYR AND QUARTER='2'   
	set @QUARTER3=''
	set @QUARTER4=''
end
if @QUARTER='3'  
Begin
	SELECT @QUARTER1=isnull(ACKNOW_NO,'') FROM TDSACKNOW WHERE L_YN=@FINYR AND QUARTER='1'   
	SELECT @QUARTER2=isnull(ACKNOW_NO,'') FROM TDSACKNOW WHERE L_YN=@FINYR AND QUARTER='2'   
	SELECT @QUARTER3=isnull(ACKNOW_NO,'') FROM TDSACKNOW WHERE L_YN=@FINYR AND QUARTER='3'   
	set @QUARTER4=''
end
if @QUARTER='4'  
Begin
	SELECT @QUARTER1=isnull(ACKNOW_NO,'') FROM TDSACKNOW WHERE L_YN=@FINYR AND QUARTER='1'   
	SELECT @QUARTER2=isnull(ACKNOW_NO,'') FROM TDSACKNOW WHERE L_YN=@FINYR AND QUARTER='2'   
	SELECT @QUARTER3=isnull(ACKNOW_NO,'') FROM TDSACKNOW WHERE L_YN=@FINYR AND QUARTER='3'   
	SELECT @QUARTER4=isnull(ACKNOW_NO,'') FROM TDSACKNOW WHERE L_YN=@FINYR AND QUARTER='4'   
end 
/*print '-----'
PRINT @QUARTER1
PRINT @QUARTER2
PRINT @QUARTER3
PRINT @QUARTER4*/



select  
a.*,QUARTER1=isnull(@QUARTER1,''),QUARTER2=isnull(@QUARTER2,''),QUARTER3=isnull(@QUARTER3,''),QUARTER4=isnull(@QUARTER4,'') 
,MailName=(CASE WHEN ISNULL(Ac_mast.MailName,'')='' THEN Ac_mast.ac_name ELSE Ac_mast.mailname END) -- Added by Ajay Jaiswal on 15/07/2010 for TKT-2867
,ac_mast.ac_name,ac_mast.add1,ac_mast.add2,ac_mast.add3,ac_mast.city,ac_mast.zip,ac_mast.i_tax
from #form16a a
inner join ac_mast on (a.ac_id=ac_mast.ac_id)
ORDER BY Mailname,AC_mast.ac_name,SRNO1,PART,u_CHALDT,U_CHALNO
--Commented By Shrikant S. on 19/01/2011 for Bug-1631		End	*/
GO
