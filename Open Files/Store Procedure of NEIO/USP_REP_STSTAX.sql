DROP PROCEDURE [USP_REP_STSTAX]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ruepesh Prajapati
-- Create date: 16/05/2007
-- Description:	This Stored procedure is useful to generate Excise Duty Available Report.
-- Modify date: 16/05/2007
-- Modified By: Shrikant S. on 29 Mar, 2010 for TKT-624
-- Modify date: 10/11/2011
-- Modified By: Sandeep on 10/11/2011 for Bug-406
-- Modify date: 
-- Remark:
-- =============================================

Create PROCEDURE [USP_REP_STSTAX]
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

Select BHent=(CASE WHEN EXT_VOU=1 THEN BCODE_NM ELSE ENTRY_TY END),Entry_ty,Code_nm Into #L from Lcode Order by BHent

Select a.Entry_ty,a.Tran_cd,tot_deduc=sum(a.tot_deduc),tot_tax=sum(a.tot_tax)
,tot_add=sum(a.tot_add),tot_nontax=sum(a.tot_nontax),tot_fdisc=sum(a.tot_fdisc),u_asseamt=sum(a.qty * a.Rate)
Into #ststax2 from stitem a
where a.tax_name<>' ' and a.date between @sdate and @edate
group by a.Entry_ty,a.Tran_cd
Union all
Select a.Entry_ty,a.Tran_cd,tot_deduc=sum(a.tot_deduc),tot_tax=sum(a.tot_tax)
,tot_add=sum(a.tot_add),tot_nontax=sum(a.tot_nontax),tot_fdisc=sum(a.tot_fdisc),u_asseamt=sum(a.qty * a.Rate)
from sritem a
where a.tax_name<>' ' and a.date between @sdate and @edate
Group by a.Entry_ty,a.Tran_cd


select a.tran_cd,a.entry_ty,mon=month(a.date),yearr=year(a.date),monthh=datename(mm,a.date)
,a.date,a.inv_no,a.gro_amt,tot_deduc=a.tot_deduc+abs(b.tot_deduc),tot_tax=a.tot_tax+b.tot_tax
,a.tot_examt,tot_add=a.tot_add+b.tot_add,a.tax_name,a.taxamt
,tot_nontax=a.tot_nontax+b.tot_nontax,tot_fdisc=a.tot_fdisc+abs(b.tot_fdisc),a.net_amt 
,b.u_asseamt
,Net_amt2=b.u_asseamt-(a.tot_deduc+abs(b.tot_deduc))+(a.tot_tax+b.tot_tax)+a.tot_examt
		+a.taxamt+(a.tot_add+b.tot_add)+(a.tot_nontax+b.tot_nontax)-(a.tot_fdisc+abs(b.tot_fdisc))
,srno='a' ,ac.vend_type into #ststax 
from stmain a 
Inner Join #ststax2 b on (a.entry_ty=b.entry_ty and a.tran_cd=b.tran_cd)
Inner Join ac_mast ac on (ac.ac_id=a.ac_id)
where a.tax_name<>' ' and date between @sdate and @edate  --change by  sandeep on 10/11/2011 for Bug-406  
union 
select a.tran_cd,a.entry_ty,mon=month(a.date),yearr=year(a.date),monthh=datename(mm,a.date)
,a.date,a.inv_no,a.gro_amt,tot_deduc=a.tot_deduc+abs(b.tot_deduc),tot_tax=a.tot_tax+b.tot_tax
,a.tot_examt,tot_add=a.tot_add+b.tot_add,a.tax_name,a.taxamt
,tot_nontax=a.tot_nontax+b.tot_nontax,tot_fdisc=a.tot_fdisc+abs(b.tot_fdisc),a.net_amt 
,b.u_asseamt
,Net_amt2=b.u_asseamt-(a.tot_deduc+abs(b.tot_deduc))+(a.tot_tax+b.tot_tax)+a.tot_examt
		+a.taxamt+(a.tot_add+b.tot_add)+(a.tot_nontax+b.tot_nontax)-(a.tot_fdisc+abs(b.tot_fdisc))
,srno='b' ,ac.vend_type
from srmain a
Inner Join #ststax2 b on (a.entry_ty=b.entry_ty and a.tran_cd=b.tran_cd)
Inner Join ac_mast ac on (ac.ac_id=a.ac_id)
where a.tax_name<>' ' and date between @sdate and @edate --change by  sandeep on 10/11/2011 for Bug-406

alter table #ststax add duty_add bit
Update #ststax set duty_add=Case when Net_amt=Net_amt2 then 1 else 0 End


select * from #ststax order by yearr,mon,tax_name,srno,date

Drop table #ststax
Drop table #ststax2
GO
