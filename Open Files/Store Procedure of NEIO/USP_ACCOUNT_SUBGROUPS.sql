DROP PROCEDURE [USP_ACCOUNT_SUBGROUPS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create procedure [USP_ACCOUNT_SUBGROUPS]
@accountname as nvarchar(4000)=''
as
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
select ac_name,[group] from ac_mast where [group] in (select ac_group_name from #groups group by ac_group_name) order by ac_name
drop table #groups
GO
