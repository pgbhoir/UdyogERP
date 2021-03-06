DROP PROCEDURE [OUTSTANDING_SHYAM]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE  [OUTSTANDING_SHYAM] AS

DECLARE @accountname as nvarchar(4000)
SET @accountname='SUNDRY DEBTORS'

declare @reccount integer
select ac_group_name,[group] into #groups from ac_group_mast where ac_group_name = @accountname
select ac_group_name,[group] into #group1 from #groups
set @reccount = 2
while @reccount>0
begin
	select ac_group_name,[group] into #group2 from ac_group_mast 
		where [group] in (select ac_group_name from #group1)
	insert into #groups select * from #group2
	delete from #group1
	insert into #group1 select ac_group_name,[group] from #group2
	set @reccount = @@rowcount
	drop table #group2
end
drop table #group1
set dateformat dmy
declare @edate  datetime
declare @sdate  datetime
set @edate='01/04/2007'
set @sdate='01/03/2007'
select a.entry_ty,a.inv_sr,a.inv_no,a.l_yn,a.date,
c.due_dt,a.ac_name,a.amount,sum(b.new_all+b.tds) 
as recamt from lac_vw a left join mainall_vw b on
a.entry_ty=b.entry_all and a.tran_cd =b.main_tran and a.ac_name=b.party_nm and b.date <=@edate
inner join lmain_vw c on 
a.entry_ty=c.entry_ty and a.date= c.date and a.doc_no =c.doc_no
where c.due_dt <=@edate  and a.ac_name in (select ac_name from ac_mast where [group] in (select ac_group_name from #groups group by ac_group_name))
group by  a.entry_ty,a.inv_sr,a.inv_no,a.l_yn,a.date,
c.due_dt,a.ac_name,a.amount
drop table #groups
--exec usp_account_subgroups 'SUNDRY DEBTORS'
GO
