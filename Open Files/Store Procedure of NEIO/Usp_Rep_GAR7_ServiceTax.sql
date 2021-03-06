DROP PROCEDURE [Usp_Rep_GAR7_ServiceTax]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ruepesh Prajapati.
-- Create date: 16/05/2007
-- Description:	This Stored procedure is useful to generate Accounts Service Tax GAR7 Challan.
-- Modification Date/By/Reason: 31/10/2009 Rupesh Prajapati. Modified Edu. Cess & S & H. Cess Accounting Code.
-- Modification Date/By/Reason: 05/11/2009 Rupesh Prajapati. Modified for Concating Service Category for Same Challan.
-- Modification Date/By/Reason: 04/01/2009 Rupesh Prajapati. Modified for Penalty Code.
-- Remark:
-- =============================================
CREATE procedure [Usp_Rep_GAR7_ServiceTax]
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
AS
Declare @FCON as NVARCHAR(2000),@SQLCOMMAND as NVARCHAR(4000)

EXECUTE   USP_REP_FILTCON 
@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
,@VSDATE=@SDATE,@VEDATE=@EDATE
,@VSAC =@SAC,@VEAC =@EAC
,@VSIT=@SIT,@VEIT=@EIT
,@VSAMT=@SAMT,@VEAMT=@EAMT
,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
,@VSCATE =@SCATE,@VECATE =@ECATE
,@VSWARE =@SWARE,@VEWARE  =@EWARE
,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
,@VMAINFILE='M',@VITFILE=Null,@VACFILE=''
,@VDTFLD ='DATE'
,@VLYN=Null
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT
begin
	select 
	part=1,m.cheq_no,cheqdt=m.date,serty=cast('' as varchar(1000)),m.u_chalno,m.u_chaldt
	,amount,sercode=space(8),m.drawn_on
	,corder=3
	into #gar7
	from bpmain m
	inner join bpacdet ac on (m.tran_cd=ac.tran_cd)
	where 1=2 
	
	select distinct accountingcode,intcode,[name] into #sertax_mast from sertax_mast
	declare @chalno varchar(10),@chaldt smalldatetime,@cnt int
	declare cur1_gar7 cursor for
	select distinct u_chalno,u_chaldt
	from bpacdet ac
	inner join bpmain m on (m.tran_cd=ac.tran_cd)
	inner join ac_mast a on (a.ac_id=ac.ac_id)
	where a.typ in ('Service Tax Payable','Service Tax Payable-Ecess','Service Tax Payable-Hcess') 	and ac.amt_ty='dr'
	open cur1_gar7
	fetch next from cur1_gar7 into @chalno,@chaldt
	while(@@fetch_status=0)
	begin
	set @cnt=0
--		print 'cnt='+cast(@cnt as varchar)

		select part=1,m.cheq_no,cheqdt=m.u_chqdt
		,serty=(case when a.typ='Service Tax Payable-Ecess' then '00440298' else ((case when a.typ='Service Tax Payable-Hcess' then '00440426' else m.serty end)) end)
		,m.u_chalno,amount=amount
		/*,sercode=(case when a.typ='Service Tax Payable-Ecess' then '00440298' else ((case when a.typ='Service Tax Payable-Hcess' then '00440426' else sm.code end)) end) Rup 30/12/2009 */
		/*,sercode=(case when a.typ='Service Tax Payable-Ecess' then '00440298' else ((case when a.typ='Service Tax Payable-Hcess' then '00440426' else (case when m.u_arrears in ('Interest paid','Penalty paid') then sm.intcode else sm.accountingcode end) end)) end)*/
		,sercode=case 
				 when 	a.typ not in ('Service Tax Payable-Ecess','Service Tax Payable-Hcess') and m.u_arrears not in ('Interest paid','Penalty paid') then sm.accountingcode
				 when 	a.typ not in ('Service Tax Payable-Ecess','Service Tax Payable-Hcess') and m.u_arrears     in ('Interest paid','Penalty paid') then sm.intcode 	
				 when 	a.typ     in ('Service Tax Payable-Ecess')                             and m.u_arrears not in ('Interest paid','Penalty paid') then '00440298'
				 when 	a.typ     in ('Service Tax Payable-Ecess')                             and m.u_arrears     in ('Interest paid','Penalty paid') then '00440299'
				 when 	a.typ     in ('Service Tax Payable-Hcess')                             and m.u_arrears not in ('Interest paid','Penalty paid') then '00440426'
				 when 	a.typ     in ('Service Tax Payable-Hcess')                             and m.u_arrears     in ('Interest paid','Penalty paid') then '00440427'
				 else '' end 	
		,u_chaldt ,m.drawn_on
		/*,corder=(case when a.typ='Service Tax Payable-Ecess' then 2 else ((case when a.typ='Service Tax Payable-Hcess' then 3 else 1 end)) end)*/
		,corder=case 
				 when 	a.typ not in ('Service Tax Payable-Ecess','Service Tax Payable-Hcess') and m.u_arrears not in ('Interest paid','Penalty paid') then 1
				 when 	a.typ not in ('Service Tax Payable-Ecess','Service Tax Payable-Hcess') and m.u_arrears     in ('Interest paid','Penalty paid') then 4
				 when 	a.typ     in ('Service Tax Payable-Ecess')                             and m.u_arrears not in ('Interest paid','Penalty paid') then 2
				 when 	a.typ     in ('Service Tax Payable-Ecess')                             and m.u_arrears     in ('Interest paid','Penalty paid') then 5
				 when 	a.typ     in ('Service Tax Payable-Hcess')                             and m.u_arrears not in ('Interest paid','Penalty paid') then 3
				 when 	a.typ     in ('Service Tax Payable-Hcess')                             and m.u_arrears     in ('Interest paid','Penalty paid') then 6
				 else '' end
 		
		into #tmpGar7 from bpmain m
		inner join bpacdet ac on (m.tran_cd=ac.tran_cd)
		inner join ac_mast a on (a.ac_id=ac.ac_id)
		left join #sertax_mast sm on (m.serty=sm.[name])
		where a.typ in ('Service Tax Payable','Service Tax Payable-Ecess','Service Tax Payable-Hcess')
		and ac.amt_ty='dr' and (m.date between @sdate and @edate) and u_chalno=@chalno 
		
		
		insert into #gar7
		(part,cheq_no,cheqdt,serty,u_chalno,amount,sercode,u_chaldt,drawn_on,corder)
		select part,cheq_no,cheqdt,serty,u_chalno,sum(amount),sercode,u_chaldt,drawn_on,corder from #tmpGar7 group by part,serty,cheq_no,u_chalno,cheqdt,sercode,u_chaldt,drawn_on,corder 	
		print @@rowcount
		set @cnt=@@rowcount
		drop table #tmpGar7
		fetch next from cur1_gar7 into @chalno,@chaldt
	end
	close cur1_gar7
	deallocate cur1_gar7

	Declare @mserty varchar(1000),@serty varchar(100),@u_chalno varchar(20),@mu_chalno varchar(20),@c int,@c1 int
	set @c=0
	set @c1=0
	declare cur_gar7 cursor for select distinct serty,u_chalno from #gar7 where serty not in ('00440298','00440426')  order by u_chalno,serty 
	open cur_gar7
	fetch next from cur_gar7 into @serty,@u_chalno
	set @mserty=''
	set @mu_chalno=@u_chalno
	WHILE (@@fetch_status=0)
	begin
		if @mu_chalno=@u_chalno 
		begin
			set @c=@c+1
			select @mserty=rtrim(@mserty)+(case when rtrim(@mserty)='' then '' else ',' end)+rtrim(@serty)
		end
		else
		begin
			update #gar7 set serty=@mserty where u_chalno=@mu_chalno
			set @mserty=@serty
			set @mu_chalno=@u_chalno 
		end	
		
		fetch next from cur_gar7 into @serty,@u_chalno
	end
	close cur_gar7
	deallocate cur_gar7
	
	if @c>0
	begin
		update #gar7 set serty=@mserty where u_chalno=@mu_chalno 
	end
	insert into #gar7 (part,cheq_no,cheqdt,serty,u_chalno,amount,sercode,u_chaldt,drawn_on,corder) select 2,cheq_no,cheqdt,serty,u_chalno,amount,sercode,u_chaldt,drawn_on,corder from #gar7
	select * from #gar7 Order by u_chalno,part,corder,SERTY
end
GO
