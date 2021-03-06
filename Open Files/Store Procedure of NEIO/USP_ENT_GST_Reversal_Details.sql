DROP PROCEDURE [USP_ENT_GST_Reversal_Details]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Shrikant S.
-- Create date: 29/03/2017 
-- Description:	This Stored procedure is useful in getting the of GST Payable under reverse charge
-- Remark:
-- =============================================
CREATE procedure [USP_ENT_GST_Reversal_Details]
@entry_ty varchar(2),@tran_cd int ,@date smalldatetime
as
begin
	declare @sqlcommand nvarchar(4000),@whcon nvarchar(1000)
	set @whcon=''
	
	select entry_all,main_tran,acseri_all,new_all=sum(new_all) 
	into #mall 
	from mainall_vw 
	inner join ac_mast a on (a.ac_id=mainall_vw.ac_id)
	where ( entry_ty+rtrim(cast(tran_cd as varchar)) ) <> ( @entry_ty+rtrim(cast(@tran_cd as varchar)) )
	and (a.typ Like '%GST Pay%' or a.typ Like  '%Cess payable%')
	group by entry_all,main_tran,acseri_all



	select sel=cast(0 as bit),m.entry_ty,m.tran_cd,ac.acserial,ac_name=ac_mast.ac_name,ac.amount,new_all=isnull(ac.amount,0),ac.amt_ty,ac_mast.typ
	,ac.Serty,party_nm=ac_mast.mailName,m.inv_no,m.date,tpayment=cast(0 as decimal(17,2)),m.l_yn,ac.ac_id,m.inv_sr,isused=0,m.net_amt,compid=0
	,TrnType=L.code_nm
	Into #tmpsdata
	from SerTaxMain_vw m
	INNER JOIN SerTaxAcDet_vw ac on (m.entry_ty=ac.entry_ty and m.tran_cd=ac.tran_cd)
	inner join ac_mast on (ac_mast.ac_id=m.ac_id)
	inner join lcode l on (l.entry_ty=m.entry_ty)
	WHERE 1=2
	
	
	insert Into #tmpsdata
	select sel=cast(0 as bit),m.entry_ty,m.tran_cd,ac.acserial,a.ac_name,ac.amount,new_all=isnull(mall.new_all,0),ac.amt_ty,a.typ
	,ac.Serty,party_nm=ac_mast.mailName,m.inv_no,m.date,tpayment=cast(0 as decimal(17,2)),m.l_yn,ac.ac_id,m.inv_sr,isused=0,m.net_amt,compid=0
	,TrnType=l.code_nm
	from SerTaxMain_vw m
	INNER JOIN SerTaxAcDet_vw ac on (m.entry_ty=ac.entry_ty and m.tran_cd=ac.tran_cd)
	inner join ac_mast on (ac_mast.ac_id=m.ac_id)
	inner join ac_mast a on (a.ac_id=ac.ac_id)
	inner join lcode l on (l.entry_ty=m.entry_ty)
	left join #mall mall on(ac.entry_ty=mall.entry_all and ac.tran_cd=main_tran and ac.acserial=acseri_all)
	where (a.typ  Like '%GST Pay%' or a.typ Like  '%Cess payable%')
	and ac.amt_ty='CR'
	and ac.amount<>isnull(mall.new_all,0)
	and ac.date<=@date
	and (l.entry_ty in ('BP','CP','B1','C1','IF','OF') or l.bcode_nm in ('BP','CP','B1','C1','IF','OF')) 
	order by m.date,inv_no
	
	
	
	insert Into #tmpsdata
	select sel=cast(0 as bit),rm.entry_ty,rm.tran_cd,ac.acserial,a.ac_name,ac.amount,new_all=isnull(mall.new_all,0),ac.amt_ty,a.typ
	,Serty=ac.serty,party_nm=ac_mast.mailName,rm.inv_no,rm.date,tpayment=cast(0 as decimal(17,2)),l_yn='',ac.ac_id,rm.inv_sr,isused=0,rm.net_amt,compid=0
	,TrnType=l.code_nm
	from RevMain_vw rm --on (rm.entry_ty=m.entry_ty and rm.tran_cd=m.tran_cd)
	--inner join Revitem_vw ri on (rm.entry_ty=ri.entry_ty and rm.tran_cd=ri.tran_cd)
	--INNER JOIN lac_vw ac on (rm.entry_ty=ac.entry_ty and rm.tran_cd=ac.tran_cd)			--Commented by Shrikant S. on 22/07/2017 for GST
	INNER JOIN SerTaxAcDet_vw ac on (rm.entry_ty=ac.entry_ty and rm.tran_cd=ac.tran_cd)		--Added by Shrikant S. on 22/07/2017 for GST
	inner join ac_mast on (ac_mast.ac_id=rm.ac_id)
	inner join ac_mast a on (a.ac_id=ac.ac_id)
	inner join lcode l on (l.entry_ty=rm.entry_ty)
	left join #mall mall on(ac.entry_ty=mall.entry_all and ac.tran_cd=main_tran and ac.acserial=acseri_all)
	where (a.typ  Like '%GST Pay%' or a.typ Like  '%Cess payable%')
	and ac.amt_ty='CR'
	and ac.date<=@date
	and (l.entry_ty in ('PT','P1','E1','UB') or l.bcode_nm in ('PT','P1','E1')) 
	--and ac.Entry_ty+quotename(ac.tran_cd)+ac.acserial Not In (Select Entry_ALL+quotename(Main_tran)+ACSERI_ALL from Mainall_vw Where Entry_all='UB')
	--and Not(ac.Entry_ty=@entry_ty and ac.tran_cd=@tran_cd)
	order by rm.date,rm.inv_no
	
	insert Into #tmpsdata
	select sel=cast(0 as bit),rm.entry_ty,rm.tran_cd,ac.acserial,a.ac_name,ac.amount,new_all=isnull(mall.new_all,0),ac.amt_ty,a.typ
	,Serty=ac.serty,party_nm=ac_mast.mailName,rm.inv_no,rm.date,tpayment=cast(0 as decimal(17,2)),l_yn='',ac.ac_id,rm.inv_sr,isused=0,rm.net_amt,compid=0
	,TrnType=l.code_nm
	from cnmain rm --on (rm.entry_ty=m.entry_ty and rm.tran_cd=m.tran_cd)
	INNER JOIN cnacdet ac on (rm.entry_ty=ac.entry_ty and rm.tran_cd=ac.tran_cd)		--Added by Shrikant S. on 22/07/2017 for GST
	inner join ac_mast on (ac_mast.ac_id=rm.ac_id)
	inner join ac_mast a on (a.ac_id=ac.ac_id)
	inner join lcode l on (l.entry_ty=rm.entry_ty)
	left join #mall mall on(ac.entry_ty=mall.entry_all and ac.tran_cd=main_tran and ac.acserial=acseri_all)
	where (a.typ  Like '%GST Pay%' or a.typ Like  '%Cess payable%')
	and ac.amt_ty='CR'
	and ac.date<=@date
	--and l.entry_ty ='C6' and rm.AGAINSTGS='SERVICE PURCHASE BILL'  --Commented by Priyanka B on 19032018 for Bug-31214
	and l.entry_ty in ('C6','GC') and rm.AGAINSTGS in ('SERVICE PURCHASE BILL','PURCHASES')  --Modified by Priyanka B on 19032018 for Bug-31214 
	order by rm.date,rm.inv_no
	
	Select Entry_ty,Tran_cd,Rentry_ty,Itref_tran Into #Othref from Othitref group by Entry_ty,Tran_cd,Rentry_ty,Itref_tran 
	
	select sel=cast(0 as bit),rm.entry_ty,rm.tran_cd,ac.acserial,a.ac_name,ac.amount,new_all=isnull(mall.new_all,0),ac.amt_ty,a.typ
	,Serty=ac.serty,party_nm=ac_mast.mailName,rm.inv_no,rm.date,tpayment=cast(0 as decimal(17,2)),l_yn='',ac.ac_id,rm.inv_sr,isused=0,rm.net_amt,compid=0
	,TrnType=l.code_nm
	,o.itref_tran,o.rentry_ty
	Into #debit
	from Dnmain rm 
	INNER JOIN Dnacdet ac on (rm.entry_ty=ac.entry_ty and rm.tran_cd=ac.tran_cd)		
	inner join ac_mast on (ac_mast.ac_id=rm.ac_id)
	inner join ac_mast a on (a.ac_id=ac.ac_id)
	inner join lcode l on (l.entry_ty=rm.entry_ty)
	Inner Join #Othref o on (o.entry_ty=rm.entry_ty and o.Tran_cd=rm.Tran_cd)
	left join #mall mall on(ac.entry_ty=mall.entry_all and ac.tran_cd=main_tran and ac.acserial=acseri_all)
	where (a.typ  Like '%GST Pay%' or a.typ Like  '%Cess payable%')
	and ac.amt_ty='DR'
	and ac.date<=@date
	--and l.entry_ty ='D6' and rm.AGAINSTGS='SERVICE PURCHASE BILL'  --Commented by Priyanka B on 19032018 for Bug-31214
	and l.entry_ty in ('D6','GD') and rm.AGAINSTGS in ('SERVICE PURCHASE BILL','PURCHASES')  --Modified by Priyanka B on 19032018 for Bug-31214
	order by rm.date,rm.inv_no
	
	--select * from #mall
	--select * from #tmpsdata
	--select * from #debit
	
	Update #tmpsdata set amount=a.amount-b.amount from #tmpsdata a inner join #debit b on (a.entry_ty=b.rentry_ty and a.tran_cd=b.itref_tran and a.ac_id=b.ac_id and a.serty=b.serty)
		
	Delete from #tmpsdata where amount<=0
	
	select * from #tmpsdata
	
end
GO
