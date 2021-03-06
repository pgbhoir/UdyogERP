DROP PROCEDURE [USP_ENT_GET_ACGROUP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [USP_ENT_GET_ACGROUP]
@groupname as nvarchar(4000)=''
as
declare @reccount int
select cast(0 as int) as ac_group_id into #groups from ac_group_mast where 1=2
select cast(0 as int) as ac_group_id into #group1 from ac_group_mast where 1=2
insert into #groups select ac_group_id from ac_group_mast where (@groupname LIKE '%'+RTRIM([ac_group_name])+'%') 
--and [group] != ''
--insert into #groups select ac_group_id from ac_group_mast where (ac_group_name in (@groupname) or [group] in (@groupname)) and [group] != ''
insert into #group1 select * from #groups

set @reccount = 1
while @reccount>0
begin
	select ac_group_id into #group2 from ac_group_mast where gac_id in (select ac_group_id from #group1) and gac_id != ac_group_id
	insert into #groups select * from #group2 
	delete from #group1
	insert into #group1 select * from #group2
	set @reccount = @@rowcount
	drop table #group2
end
drop table #group1
select * from #groups
drop table #groups
GO
