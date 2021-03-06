DROP PROCEDURE [Usp_Uerport_ItemFoundFromGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ruepesh Prajapati
-- Create date: 04/05/2010. 
-- Description:	Used in uereport project for Item Group and SubGroup checking. Replacement of Usp_Ent_ItemFoundFromGroup,usp_item_subgroups in uerport.app
-- Modify By/Date/Reason: Rupesh18/05/2010 Modified for Multiple Item Group Selecttion in R_status.  
-- Remark:

--Modified Date  : 30/05/2012
--Modified By     :  Vasant
--Reason	           :  Bug 3726 (Item selection problem in stock ledger)
--Comment where Changes done : Bug3726

-- =============================================
CREATE procedure [Usp_Uerport_ItemFoundFromGroup]
@itGroup varchar(4000),@fldstr varchar(2000)
,@type varchar(40)
,@filtCond Varchar(4000)=''
as
declare @reccount integer,@Sqlcommand Nvarchar(4000),@fldcon varchar(2000)
--select it_group_name,[group] into #groups from item_group where charindex(rtrim(it_group_name),@itGroup,1)<>0 &&Rup 26/06/2008
select it_group_name,[group] into #groups from item_group where 1=2

declare @str varchar(100),@cnt int ,@pos1 int ,@pos2 int,@cond int
set @cond=1

if substring(@itGroup,len(rtrim(@itGroup)),1)=','
begin
	set @itGroup=substring(@itGroup,1,len(rtrim(@itGroup))-1)
end

print '@itGroup = '+@itGroup

print @pos1
--->Group & Sub Group List
while (@cond=1)
begin
	set @pos1 = CHARINDEX(',',@itGroup,1)
	if @pos1<>0
	begin
		set @str=substring(@itGroup,1,@pos1-1)
		set @itGroup=substring(@itGroup,@pos1+1,len(@itGroup)-@pos1+1)
	end
	else
	begin
		set @cond=0	
	end
	insert into #groups (it_group_name,[group]) select it_group_name,[group]  from item_group where it_group_name=@str
	print @str
	--print @x
end
insert into #groups (it_group_name,[group]) select it_group_name,[group]  from item_group where it_group_name= @itGroup
print @itGroup
---<--Group & Sub Group List

select it_group_name,[group]  into #item_group from item_group where it_group_name <> ' '	--Bug3726

--select * from #groups order by it_group_name
select it_group_name,[group] into #group1 from #groups
set @reccount = 2
--while @reccount>1			--Bug3726
while @reccount>0				--Bug3726
begin
	select it_group_name,[group] into #group2 from #item_group							--Bug3726
		where [group] in (select it_group_name from #group1)
	insert into #groups select * from #group2
	delete from #group1
	insert into #group1 select it_group_name,[group] from #group2
	drop table #group2
	set @reccount = (select count(it_group_name) from #group1)
end
drop table #group1
drop table #item_group	--Bug3726

set @SqlCommand='select  '+rtrim(@fldstr)+' from it_mast'
set @fldcon=' where [group] in (select it_group_name from #groups group by it_group_name)'
print '@fldcon1 ='+@fldcon
if @type<>'' /*Item Type*/
begin
	if @fldcon='' begin set @fldcon=' where ' end else begin set @fldcon=rtrim(@fldcon)+' And ' end
	set @fldcon=rtrim(@fldcon)+' '+' ([type]= '+char(39)+rtrim(@type)+char(39)+')'
end
print '@fldcon ='+@fldcon

--Added by Shrikant S. on 03/04/2017 for GST		--Start
if @filtCond<>''
Begin
	if @fldcon='' begin set @fldcon=' where ' end else begin set @fldcon=rtrim(@fldcon)+' And ' end
	set @fldcon=rtrim(@fldcon)+' '+@filtCond
end
--Added by Shrikant S. on 03/04/2017 for GST		--End

set @SqlCommand=rtrim(@SqlCommand)+' '+@fldcon
set @SqlCommand=rtrim(@SqlCommand)+' '+' order by it_name'
print @SqlCommand
EXECUTE SP_EXECUTESQL @SqlCommand


drop table #groups
GO
