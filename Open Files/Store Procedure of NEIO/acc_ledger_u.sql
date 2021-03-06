DROP PROCEDURE [acc_ledger_u]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [acc_ledger_u]
@sdate smalldatetime,@edate smalldatetime,
@sname varchar(50),@ename varchar(50),@scate varchar(20)
as
create table #tmpDbo_T (ty1 varchar(2) null, date1 smalldatetime null, doc1 varchar(5) null,
item1 varchar(30) null, qty1 decimal(14,4) null,rate1 decimal(10,2) null,
amount1 decimal(18,2) null,net_amt1 decimal(18,2) null, ac_name1 varchar(35) null,
cheq_no1 varchar(20) null,narr_1 text null,ty2 varchar(2) null, date2 smalldatetime null,
doc2 varchar(5) null, item2 varchar(30) null, qty2 decimal(14,4) null,
rate2 decimal(10,2) null, amount2 decimal(18,2) null, net_amt2 decimal(18,2) null,
ac_name2 decimal(35) null, cheq_no2 varchar(20) null,narr_2 text null,hname varchar(35) null)

declare @drec integer,@crec integer,@page_count integer,@@op_bal decimal(14,2),
	@trancd integer,@entryty varchar(2)
set @drec=1
set @crec=1
set @page_count = 0
set @@op_bal = 0
execute prc_account_opening_balance @sname,@sdate,@@op_bal output
print @page_count
print @@op_bal
if @@op_bal != 0
begin
	if @@op_bal>0
	begin
		insert into #tmpDbo_T(date1,ac_name1,amount1,hname) values(@sdate,'Opening Balance B/f.',@@op_bal,@sname)
		print 'More than zero'
	end
	else
	begin
		insert into #tmpDbo_T(date2,ac_name2,amount2,hname) values(@sdate,'Opening Balance B/f.',@@op_bal,@sname)
		print 'Less than zero'
	end
end
declare curLacVw cursor for
select entry_ty,tran_cd from lac_vw
open curLacVw
fetch next from curLacVw into @entryty,@trancd
while @@fetch_status=0
begin
	declare curLitem cursor for
	select * from litem_vw where tran_cd=@trancd
	fetch next from curLacVw into @entryty,@trancd
end
select * from #tmpDbo_T
drop table #tmpDbo_T
GO
