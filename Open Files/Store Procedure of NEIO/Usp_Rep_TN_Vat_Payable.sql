set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go







-- =============================================
-- Author:		Hetal L Patel
-- Create date: 16/05/2007
-- Description:	This Stored procedure is useful to generate Tamilnadu VAT Payable Report.
-- Modify date: 16/05/2007
-- Modified By: Sandeep shah 
-- Modify date: 17-08-2010
-- Remark:      Amount of Less:- Input Tax Credit (v) (B) corrected for TKT-3566   
-- =============================================

alter procedure [dbo].[usp_rep_TN_Vat_Payable]
@TMPAC NVARCHAR(50),@TMPIT NVARCHAR(50),@SPLCOND VARCHAR(8000),@SDATE  SMALLDATETIME,@EDATE SMALLDATETIME
,@SAC AS VARCHAR(60),@EAC AS VARCHAR(60)
,@SIT AS VARCHAR(60),@EIT AS VARCHAR(60)
,@SAMT FLOAT,@EAMT FLOAT
,@SDEPT AS VARCHAR(60),@EDEPT AS VARCHAR(60)
,@SCATE AS VARCHAR(60),@ECATE AS VARCHAR(60)
,@SWARE AS VARCHAR(60),@EWARE AS VARCHAR(60)
,@SINV_SR AS VARCHAR(60),@EINV_SR AS VARCHAR(60)
,@LYN VARCHAR(20)
,@EXPARA  AS VARCHAR(60)= NULL
AS
Declare @FCON as NVARCHAR(2000)
Declare @SQLCOMMAND NVARCHAR(4000)
Declare @gro_amt decimal(12,2),@taxamt decimal(12,2)

EXECUTE   USP_REP_FILTCON 
@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
,@VSDATE=@SDATE --null
,@VEDATE=@EDATE
,@VSAC =@SAC,@VEAC =@EAC
,@VSIT=@SIT,@VEIT=@EIT
,@VSAMT=@SAMT,@VEAMT=@EAMT
,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
,@VSCATE =@SCATE,@VECATE =@ECATE
,@VSWARE =@SWARE,@VEWARE  =@EWARE
,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
,@VMAINFILE='m',@VITFILE='',@VACFILE=''
,@VDTFLD ='DATE'
,@VLYN =NULL
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT

select part=1,srno1=space(1),srno2=space(1),srno3=space(1),trdesc=space(100)
,itdesc=space(100),gro_amt,tax_name,taxamt,taxamt1=taxamt,[level1]=99.999 
into #tnvatpay
from stmain where 1=2

select itdesc=m.cate,m.gro_amt,m.tax_name,st.set_app
,taxamt=sum(case when (isnull(ac_mast.typ,'')='Output Vat' and ac.amt_ty='Cr') then amount else 0 end)
,st.level1
into #part1a
from stmain m 
left join stacdet ac  on (m.tran_cd=ac.tran_cd and m.tran_cd=ac.tran_cd)
left join ac_mast on (ac.ac_id=ac_mast.ac_id)
inner join stax_mas st on (m.tax_name=st.tax_name) And st.entry_Ty = 'ST'
inner join lcode l on (l.entry_ty=m.entry_ty)
where (m.date between @sdate and @edate) 
and isnull(m.tax_name,'')<>'' 
group by m.cate,m.gro_amt,m.tax_name,st.set_app,st.level1

insert into #tnvatpay
(part,srno1,srno2,srno3
,trdesc,itdesc,gro_amt,tax_name,taxamt,taxamt1,level1)
select part=1,'a','',''
,trdesc='Deferral Sales',itdesc,gro_amt=sum(gro_amt),tax_name,taxamt=sum(taxamt),taxamt1=0
,level1
from #part1a
where set_app=1
group by tax_name,itdesc,set_app,level1


select itdesc=m.cate,m.gro_amt,m.tax_name,st.set_app
,taxamt=sum(case when (isnull(ac_mast.typ,'')='Output Vat' and ac.amt_ty='Dr') then amount else 0 end)
,st.level1
into #part1b
from sracdet ac 
inner join ac_mast on (ac.ac_id=ac_mast.ac_id)
inner join srmain m on (m.tran_cd=ac.tran_cd and m.tran_cd=ac.tran_cd)
inner join stax_mas st on (m.tax_name=st.tax_name) And st.entry_Ty = 'SR' 
inner join lcode l on (l.entry_ty=m.entry_ty)
where (m.date between @sdate and @edate) 
and isnull(m.tax_name,'')<>'' 
and ac_mast.typ='Output Vat'
group by m.cate,m.gro_amt,m.tax_name,st.set_app,st.level1

insert into #tnvatpay
(part,srno1,srno2,srno3
,trdesc,itdesc,gro_amt,tax_name,taxamt,taxamt1,level1)
select part=1,'b','',''
,trdesc='Deferral Sales Return',itdesc,gro_amt=sum(gro_amt),tax_name,taxamt=sum(taxamt),taxamt1=0
,level1
from #part1b
where set_app=1
group by tax_name,itdesc,set_app,level1

insert into #tnvatpay
(part,srno1,srno2,srno3
,trdesc,itdesc,gro_amt,tax_name,taxamt,taxamt1,level1)
select part=2,'a','',''
,trdesc='Purchases',itdesc='',gro_amt=sum(m.gro_amt),tax_name=''
,taxamt=sum(case when ac.amt_ty='dr' then amount else -amount end),taxamt1=0
,0
from lac_vw ac 
inner join ac_mast on (ac.ac_id=ac_mast.ac_id)
inner join lmain_vw m on (m.tran_cd=ac.tran_cd and m.entry_ty=ac.entry_ty)
inner join stax_mas st on (m.tax_name=st.tax_name and st.entry_ty=m.entry_ty)
where (m.date < @edate) and isnull(m.tax_name,'')<>'' 
and st.set_app=1 and ac_mast.typ='Input Vat'

select  * from #tnvatpay

insert into #tnvatpay
(part,srno1,srno2,srno3
,trdesc,itdesc,gro_amt,tax_name,taxamt,taxamt1,level1)
select part=3,'a','',''
,trdesc='Non-Deferral Sales',itdesc,gro_amt=sum(gro_amt),tax_name
,taxamt=0,taxamt1=sum(taxamt)
,level1
from #part1a
where set_app=0
group by tax_name,itdesc,set_app,level1

insert into #tnvatpay
(part,srno1,srno2,srno3
,trdesc,itdesc,gro_amt,tax_name,taxamt,taxamt1,level1)
select part=3,'b','',''
,trdesc='Non-Deferral Sales Return',itdesc,gro_amt=sum(gro_amt),tax_name
,taxamt=0,taxamt1=sum(taxamt)
,level1
from #part1b
where set_app=0
group by tax_name,itdesc,set_app,level1


select * from #tnvatpay order by part,itdesc,tax_name










