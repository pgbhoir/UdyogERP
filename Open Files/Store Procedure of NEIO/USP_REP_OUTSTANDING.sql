DROP PROCEDURE [USP_REP_OUTSTANDING]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [USP_REP_OUTSTANDING]
@TMPAC NVARCHAR(50),@TMPIT NVARCHAR(50),@SPLCOND VARCHAR(8000),
@SDATE  SMALLDATETIME,@EDATE SMALLDATETIME,@SAC AS VARCHAR(60),
@EAC AS VARCHAR(60),@SIT AS VARCHAR(60),@EIT AS VARCHAR(60),
@SAMT FLOAT,@EAMT FLOAT,@SDEPT AS VARCHAR(60),@EDEPT AS VARCHAR(60),
@SCATE AS VARCHAR(60),@ECATE AS VARCHAR(60),@SWARE AS VARCHAR(60),
@EWARE AS VARCHAR(60),@SINV_SR AS VARCHAR(60),@EINV_SR AS VARCHAR(60)
,@LYN VARCHAR(20),@EXPARA  AS VARCHAR(60)= null

 AS

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
--declare @edate  datetime
--declare @sdate  datetime
--Set-@sdate='01/03/2007'
select a.entry_ty,a.dept,a.cate,a.inv_sr,a.inv_no,a.l_yn,a.date,
c.due_dt,a.ac_name,a.amount,sum(b.new_all+b.tds) 
as recamt into #outstand from lac_vw a left join mainall_vw b on
a.entry_ty=b.entry_all and a.tran_cd =b.main_tran and a.ac_name=b.party_nm and b.date <=@sdate
inner join lmain_vw c on 
a.entry_ty=c.entry_ty and a.date= c.date and a.doc_no =c.doc_no
where c.due_dt <=@sdate  and a.ac_name in (select ac_name from ac_mast where [group] in (select ac_group_name from #groups group by ac_group_name))
group by  a.entry_ty,a.inv_sr,a.inv_no,a.l_yn,a.date,
c.due_dt,a.ac_name,a.amount,a.dept,a.cate
drop table #groups

declare @cond nvarchar(4000),@SqlQuery nvarchar(4000)


set @cond = ' 1=1 '

if @SAC!='' and @SAC is not null
begin
	
set @cond=rtrim(@cond) +
 ' and a.ac_name between '+char(39)+@sac+char(39)+' and '+ char(39)+@eac+char(39)
	
end

if @SIT!='' and @SIT is not null
begin
	set @cond=rtrim(@cond) + ' and a.item between '+@sit+' and '+@eit
end

if @SDEPT!='' and @SDEPT is not null
begin
	set @cond=rtrim(@cond) + ' and a.item between '+@sdept+ ' and '+@edept
end

if @SCATE!='' and @SCATE is not null
begin
	set @cond=rtrim(@cond) + ' and a.item between'+@scate+ ' and '+@ecate
end

set @sqlquery = 'select * from #outstand a where '+rtrim(@cond)

exec sp_sqlexec @sqlquery
GO
