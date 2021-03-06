DROP PROCEDURE [Usp_rep_Sertax_Proforma_Bill_reg]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [Usp_rep_Sertax_Proforma_Bill_reg]
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
Declare @FCON as NVARCHAR(2000),@SQLCOMMAND NVARCHAR(4000)
EXECUTE   USP_REP_FILTCON 
@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =' '
,@VSDATE=@SDATE
,@VEDATE=@EDATE
,@VSAC =@SAC,@VEAC =@EAC
,@VSIT=@SIT,@VEIT=@EIT
,@VSAMT=@SAMT,@VEAMT=@EAMT
,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
,@VSCATE =@SCATE,@VECATE =@ECATE
,@VSWARE =@SWARE,@VEWARE  =@EWARE
,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
,@VMAINFILE='b',@VITFILE='i',@VACFILE='ac'
,@VDTFLD ='Date'
,@VLYN =NULL
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT


Select a.Entry_ty,a.Tran_cd,b.Net_amt,a.Amount,a.STaxable,a.SerBamt,a.SerCamt,a.SerHAmt,aLevel=1,REF=a.Entry_ty+SPACE(1)+CONVERT(VARCHAR(10),a.Tran_cd)+space(1)+a.itserial
,a.Serty,b.date,b.Serrule,b.Inv_no
,ac_mast.ac_name,ac_mast.sregn,ac_mast.add1,ac_mast.add2,ac_mast.add3,Rdate=b.Date,RInvNo=b.Inv_no
,adj_taxable=b.net_amt,adj_sertax=b.net_amt,adj_cess=b.net_amt,adj_hcess=b.net_amt
,i.Qty,i.rate,i.gro_amt,i.itserial,It_mast.it_Name
Into #tmpsertax From Acdetalloc a
Inner Join SerTaxitem_vw i on (i.Entry_ty=a.Entry_ty and i.tran_cd=a.Tran_cd and i.itserial=a.itserial)
Inner Join SerTaxmain_vw b On (b.Entry_ty=i.Entry_ty and b.Tran_cd=i.Tran_cd)
Inner Join ac_mast on (ac_mast.Ac_Id=b.Ac_Id)
Inner Join It_mast on (it_mast.it_code=i.it_code)
Where 1=2

SET @SQLCOMMAND=''
SET @SQLCOMMAND=@SQLCOMMAND+' '+'Insert Into #tmpsertax'
SET @SQLCOMMAND=@SQLCOMMAND+' '+'Select a.Entry_ty,a.Tran_cd,b.Net_amt,a.Amount,a.STaxable,a.SerBamt,a.SerCamt,a.SerHAmt,aLevel=1,REF=a.Entry_ty+SPACE(1)+CONVERT(VARCHAR(10),a.Tran_cd)+space(1)+a.itserial'
SET @SQLCOMMAND=@SQLCOMMAND+' '+',a.Serty,b.date,b.Serrule,b.Inv_no'
SET @SQLCOMMAND=@SQLCOMMAND+' '+',ac_mast.ac_name,ac_mast.sregn,ac_mast.add1,ac_mast.add2,ac_mast.add3,Rdate=b.Date,RInvNo=b.Inv_no'
SET @SQLCOMMAND=@SQLCOMMAND+' '+',adj_taxable=0,adj_sertax=0,adj_cess=0,adj_hcess=0'
SET @SQLCOMMAND=@SQLCOMMAND+' '+',i.Qty,i.rate,i.gro_amt,i.itserial,It_mast.it_Name'
SET @SQLCOMMAND=@SQLCOMMAND+' '+'From Acdetalloc a'
SET @SQLCOMMAND=@SQLCOMMAND+' '+'Inner Join SerTaxitem_vw i on (i.Entry_ty=a.Entry_ty and i.tran_cd=a.Tran_cd and i.itserial=a.itserial)'
SET @SQLCOMMAND=@SQLCOMMAND+' '+'Inner Join SerTaxmain_vw b On (b.Entry_ty=i.Entry_ty and b.Tran_cd=i.Tran_cd)'
SET @SQLCOMMAND=@SQLCOMMAND+' '+'Inner Join ac_mast on (ac_mast.Ac_Id=b.Ac_Id)'
SET @SQLCOMMAND=@SQLCOMMAND+' '+'Inner Join It_mast on (it_mast.it_code=i.it_code)'
SET @SQLCOMMAND=@SQLCOMMAND+' '+@FCON
SET @SQLCOMMAND=@SQLCOMMAND+' '+'and b.Entry_ty=''P4'' '
print @SQLCOMMAND
EXEC SP_EXECUTESQL  @SQLCOMMAND

set @SQLCOMMAND=''
SET @SQLCOMMAND=@SQLCOMMAND+' '+'Insert Into #tmpsertax'
SET @SQLCOMMAND=@SQLCOMMAND+' '+'Select a.Entry_ty,a.Tran_cd,b.Net_amt,a.Amount,a.STaxable,a.SerBamt,a.SerCamt,a.SerHAmt,aLevel=2,REF=c.rentry_ty+SPACE(1)+CONVERT(VARCHAR(10),c.Itref_Tran)+space(1)+c.ritserial'
SET @SQLCOMMAND=@SQLCOMMAND+' '+',a.Serty,b.date,b.Serrule,b.Inv_no'
SET @SQLCOMMAND=@SQLCOMMAND+' '+',ac_mast.ac_name,ac_mast.sregn,ac_mast.add1,ac_mast.add2,ac_mast.add3,Rdate=c.Rdate,RInvNo=c.Rinv_no'
SET @SQLCOMMAND=@SQLCOMMAND+' '+',adj_taxable=0.00,adj_sertax=0.00,adj_cess=0.00,adj_hcess=0.00'
SET @SQLCOMMAND=@SQLCOMMAND+' '+',i.Qty,i.Rate,i.gro_amt,i.itserial,It_mast.it_Name'
SET @SQLCOMMAND=@SQLCOMMAND+' '+'From SbItref c'
SET @SQLCOMMAND=@SQLCOMMAND+' '+'Inner Join SerTaxitem_vw i on (i.Entry_ty=c.Entry_ty and i.Tran_cd=c.Tran_cd and i.itserial=c.itserial)'
SET @SQLCOMMAND=@SQLCOMMAND+' '+'Inner Join SerTaxmain_vw b on (b.Entry_ty=i.Entry_ty and b.Tran_cd=i.Tran_cd )'
SET @SQLCOMMAND=@SQLCOMMAND+' '+'Inner Join AcdetAlloc a On (a.Entry_ty=i.Entry_ty and a.Tran_cd=i.Tran_cd and a.itserial=i.itserial)'
SET @SQLCOMMAND=@SQLCOMMAND+' '+'Inner Join ac_mast on (ac_mast.Ac_Id=b.Ac_Id)'
SET @SQLCOMMAND=@SQLCOMMAND+' '+'Inner Join It_mast on (it_mast.it_code=i.it_code)'
SET @SQLCOMMAND=@SQLCOMMAND+' '+'Where c.rentry_ty+SPACE(1)+CONVERT(VARCHAR(10),c.Itref_Tran)+space(1)+c.ritserial in (Select Entry_ty+SPACE(1)+CONVERT(VARCHAR(10),Tran_cd)+space(1)+itserial From #tmpsertax)'
print @SQLCOMMAND
EXEC SP_EXECUTESQL  @SQLCOMMAND


select ref,STaxable=sum(STaxable),SerBamt=sum(SerBamt),SerCamt=sum(SerCamt),SerHAmt=sum(SerHAmt) Into #tmpsertax2 from #tmpsertax Where alevel>1 group by ref


Update #tmpsertax set adj_taxable=a.STaxable,adj_sertax=a.SerBamt,adj_cess=a.SerCamt,adj_hcess=a.SerHAmt  from #tmpsertax2 a inner join #tmpsertax b on (a.ref=b.ref) 
where b.alevel=1

select Entry_ty,Tran_cd,Inv_no,Date
,ac_Name ,sregn ,Net_amt ,Serty ,sTaxable 
,SerBamt ,SerCamt ,SerHAmt ,Serrule ,aLevel ,amount,REF
,add1,add2,add3,Rdate,Rinvno,adj_taxable,adj_sertax,adj_cess,adj_hcess
,bal_taxable=case when alevel=1 then staxable-adj_taxable else 0 end
,bal_sertax=case when alevel=1 then SerBamt-adj_sertax else 0 end
,bal_cess=case when alevel=1 then SerCamt-adj_cess else 0 end
,bal_hcess=case when alevel=1 then SerHAmt-adj_hcess else 0 end
,qty,rate,gro_amt,it_Name,colorcode=space(25)
from #tmpsertax a 
Order by rdate,Rinvno,Ac_Name,ref,aLevel



drop table #tmpsertax
GO
