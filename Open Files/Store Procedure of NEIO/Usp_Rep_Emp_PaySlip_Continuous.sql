DROP PROCEDURE [Usp_Rep_Emp_PaySlip_Continuous]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*=============================================
 Author:		Rupesh Prajapati.
 Create date: 12/05/2012
 Description:	This Stored procedure is useful to generate PaySlip Default Format.
 Modification Date/By/Reason:
 Remark: 
-- =============================================*/
CREATE Procedure [Usp_Rep_Emp_PaySlip_Continuous] 
@TMPAC NVARCHAR(50),@TMPIT NVARCHAR(50),@SPLCOND VARCHAR(8000),@SDATE  SMALLDATETIME,@EDATE SMALLDATETIME
,@SAC AS VARCHAR(60),@EAC AS VARCHAR(60)
,@SIT AS VARCHAR(60),@EIT AS VARCHAR(60)
,@SAMT FLOAT,@EAMT FLOAT
,@SDEPT AS VARCHAR(60),@EDEPT AS VARCHAR(60)
,@SCATE AS VARCHAR(60),@ECATE AS VARCHAR(60)
,@SWARE AS VARCHAR(60),@EWARE AS VARCHAR(60)
,@SINV_SR AS VARCHAR(60),@EINV_SR AS VARCHAR(60)
,@LYN VARCHAR(20)
,@EXPARA  AS VARCHAR(1000)
AS
BEGIN
	DECLARE @FCON AS NVARCHAR(2000)
	EXECUTE   USP_REP_FILTCON 
	@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
	,@VSDATE=null
	,@VEDATE=null
	,@VSAC =@SAC,@VEAC =@EAC
	,@VSIT=@SIT,@VEIT=@EIT
	,@VSAMT=@SAMT,@VEAMT=@EAMT
	,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
	,@VSCATE =@SCATE,@VECATE =@ECATE
	,@VSWARE =@SWARE,@VEWARE  =@EWARE
	,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
	,@VMAINFILE='e',@VITFILE='',@VACFILE=' '
	,@VDTFLD =''
	,@VLYN =NULL
	,@VEXPARA=@EXPARA
	,@VFCON =@FCON OUTPUT

	if(@FCON='')
	begin
		set @FCON=' where 1=1'
	end 	
	set @FCON=replace(@FCON,'Dept','Department')
	set @FCON=replace(@FCON,'Cate','Category')
	print @FCON
	Declare @SQLCOMMAND as NVARCHAR(4000)
		


Declare @pay_year varchar(30),@pay_month int,@cpay_month varchar(30),@EmpNm varchar(100)
Declare @POS INT

--Set @EXPARA='[pay_year=2012][pay_month=January][EmpNm=Rup]'
if(charindex('[pay_year=',@EXPARA)>0)
begin
	SET @POS=CHARINDEX(']',@EXPARA)
	SET @pay_year=SUBSTRING(@EXPARA,11,@POS-11)
end 	

if(charindex('[pay_month=',@EXPARA)>0)
begin
	SET @POS=CHARINDEX('[pay_month=',@EXPARA)
	SET @cpay_month=SUBSTRING(@EXPARA,@POS+11,len(@EXPARA)-@pos)
	SET @cpay_month=replace(@cpay_month,'[pay_month=','')
	SET @POS=CHARINDEX(']',@cpay_month)
	SET @cpay_month=SUBSTRING(@cpay_month,1,@pos)
	SET @cpay_month=replace(@cpay_month,']','')
end

if(charindex('[EmpNm=',@EXPARA)>0)
begin
	SET @POS=CHARINDEX('[EmpNm=',@EXPARA)
	SET @EmpNm=SUBSTRING(@EXPARA,@POS+7,len(@EXPARA)-@pos)
	SET @EmpNm=replace(@EmpNm,']','')
end

PRINT @pay_year
print @cpay_month
print @EmpNm
Select @pay_month =
     case  @cpay_month 
        when 'January' then 1 
        when 'February' then 2	
		when 'March' then 3 
		when 'April' then 4 
		when 'May' then 5 
		when 'June' then 6 
		when 'July' then 7 
		when 'August' then 8 
		when 'September' then 9 
		when 'October' then 10 
		when 'November' then 11
		when 'December' then 12 end




	--Declare @Tran_Cd int
	----
	Declare @ExpFileNm varchar(60),@EMailSub varchar(1000),@EmailBody varchar(8000)

	Select part=1,p.EmployeeCode
	,p.Tran_cd,p.pay_year,p.pay_month,Head_NM=hm.short_nm,h.PayEffect,hm.Fld_Nm,p.NetPayment,Amount=Cast(0 as Decimal(18,2)),LvOpBal=Cast(0 as Decimal(18,2)),LvCr=Cast(0 as Decimal(18,2)),LvDr=Cast(0 as Decimal(18,2)),LvEncash=Cast(0 as Decimal(18,2)),LvCalBal=Cast(0 as Decimal(18,2))
	,@ExpFileNm as  ExpFileNm,@EMailSub as EMailSub,@EmailBody as EmailBody
	into #MonthlyPayroll 
	From Emp_Monthly_Payroll p 
	cross join Emp_Pay_Head_Master hm 
	Left Join Emp_Pay_Head h on (h.HeadTypeCode=hm.HeadTypeCode)
	Left Join EmployeeMast E on(p.EmployeeCode=E.EmployeeCode)
	Where  1=2	

	
	
	Select @ExpFileNm=ExpFileNm,@EMailSub=EMailSub,@EmailBody=EmailBody From R_Status where Rep_Nm='PaySlip'

	Declare @Date smalldatetime,@Progtotal Numeric(19,2),@Inv_no Varchar(20)
	Declare @Head_Nm varchar(60),@Fld_Nm varchar(60)
	
	Set @SqlCommand='insert into #MonthlyPayroll Select part=1,p.EmployeeCode,p.Tran_cd,p.pay_year,p.pay_month,Head_NM=hm.short_nm,h.PayEffect,hm.Fld_Nm,p.NetPayment,Amount=Cast(0 as Decimal(18,2)),LvOpBal=Cast(0 as Decimal(18,2)),LvCr=Cast(0 as Decimal(18,2)),LvDr=Cast(0 as Decimal(18,2)),LvEncash=Cast(0 as Decimal(18,2)),LvCalBal=Cast(0 as Decimal(18,2))' 
	Set @SqlCommand=Rtrim(@SqlCommand)+' '+','+char(39)+@ExpFileNm+char(39)+' as  ExpFileNm,'+char(39)+@EMailSub+char(39)+' as EMailSub,'+char(39)+@EmailBody+char(39)+' as EmailBody'
	Set @SqlCommand=Rtrim(@SqlCommand)+' '+'From Emp_Monthly_Payroll p '
	Set @SqlCommand=Rtrim(@SqlCommand)+' '+'cross join Emp_Pay_Head_Master hm '
	Set @SqlCommand=Rtrim(@SqlCommand)+' '+'Left Join Emp_Pay_Head h on (h.HeadTypeCode=hm.HeadTypeCode)' 
	Set @SqlCommand=Rtrim(@SqlCommand)+' '+'Left Join Employeemast E on(P.EmployeeCode=E.EmployeeCode)'
	Set @SqlCommand=Rtrim(@SqlCommand)+' '+@FCON
	Set @SqlCommand=Rtrim(@SqlCommand)+' '+'and  hm.prinpayslip=1'
	
	if(@pay_year<>'')
	begin
		Set @SqlCommand=Rtrim(@SqlCommand)+' '+'and (p.pay_year='+char(39)+@pay_year+char(39)+')'
	end	
	if(@pay_month<>0)
	begin
		Set @SqlCommand=Rtrim(@SqlCommand)+' '+'and (p.pay_month='+Cast(@pay_month as varchar)+')'
	end	
	if(@EmpNm<>'')
	begin
		Set @SqlCommand=Rtrim(@SqlCommand)+' '+'and (e.EmployeeName='+char(39)+@EmpNm+char(39)+')'
	end	
	
	Set @SqlCommand=Rtrim(@SqlCommand)+' '+'order by pay_year,pay_month,e.EmployeeCode,h.SortOrd,hm.SortOrd'

	print @SqlCommand
	Execute Sp_ExecuteSql @SqlCommand

	--select * from #MonthlyPayroll
	Declare Cur_hm cursor for Select hm.short_nm,hm.Fld_Nm From Emp_Pay_Head_Master hm where hm.prinpayslip=1
	open Cur_hm
	fetch next from Cur_hm into @Head_Nm,@Fld_Nm
	while (@@fetch_Status=0)
	begin
		set @SqlCommand='update a set a.Amount=b.'+@Fld_Nm+ ' From #MonthlyPayroll a inner join Emp_Monthly_Payroll b on (a.employeeCode=b.EmployeeCode and a.pay_year=b.pay_year and a.pay_month=b.pay_month and a.Fld_Nm='+char(39)+@Fld_Nm+char(39)+')'
		print @SqlCommand
		execute sp_ExecuteSql @SqlCommand
		fetch next from Cur_hm into @Head_Nm,@Fld_Nm
	end
	close Cur_hm
	Deallocate Cur_hm
	
	Select m.EmployeeCode,m.pay_year,m.pay_month,s.Att_Code,LvOpBal=Cast(0 as Decimal(8,3)),LvCr=Cast(0 as Decimal(8,3)),LvAvailed=Cast(0 as Decimal(8,3)),LvEncash=Cast(0 as Decimal(8,3)),LvBal=Cast(0 as Decimal(8,3)) into #Leave From Emp_Leave_Maintenance m ,Emp_Attendance_Setting s where s.isLeave=1 and s.lDeactive=0
	and rtrim(m.EmployeeCode)+rtrim(m.pay_year)+rtrim(cast(m.pay_month as varchar)) in (Select distinct rtrim(EmployeeCode)+rtrim(pay_year)+rtrim(cast(pay_month as varchar)) From #MonthlyPayroll)

	Declare Cur_Leave cursor for Select Distinct Att_Code From Emp_Attendance_Setting where isLeave=1 and lDeactive=0 order by Att_Code
	open Cur_Leave
	Fetch Next From Cur_Leave into @Fld_Nm
	while (@@fetch_Status=0)
	begin
		set @SqlCommand='update a set '+'a.LvOpBal=isnull(b.'+@Fld_Nm+'_OpBal,0)'+',a.LvCr=isnull(b.'+@Fld_Nm+'_Credit,0)'+',a.LvAvailed=isnull(b.'+@Fld_Nm+'_Availed,0)'+',a.LvEnCash=isnull(b.'+@Fld_Nm+'_EnCash,0)'++',a.LvBal=isnull(b.'+@Fld_Nm+'_Balance,0)'+' From #Leave a inner join Emp_Leave_Maintenance b on (a.employeeCode=b.EmployeeCode and a.pay_year=b.pay_year and a.pay_month=b.pay_month and a.Att_Code='+char(39)+@Fld_Nm+char(39)+')'
		print @SqlCommand
		execute sp_ExecuteSql @SqlCommand
		Fetch Next From Cur_Leave into @Fld_Nm
	end
	close Cur_Leave
	deallocate Cur_Leave

	insert into #MonthlyPayroll (part,EmployeeCode,Tran_cd,pay_year,pay_month,Head_NM,PayEffect,Fld_Nm,Amount,LvOpBal,LvCr,LvDr,LvEncash,LvCalBal)
	Select  part=2,rtrim(EmployeeCode),Tran_Cd=0,pay_year,pay_month,Att_Code,PayEffect='',Att_Code,Amount=0,LvOpBal,LvCr,LvAvailed,LvEncash,LvBal From #Leave

	update #MonthlyPayroll Set netpayment=isnull(Netpayment,0)
	
	update #MonthlyPayroll set EMailSub=replace(EMailSub,'@@Month',DateName( month , DateAdd( month , cast(pay_month as int), 0 )-1  )),EmailBody=replace(EmailBody,'@@Month',DateName( month , DateAdd( month , cast(pay_month as int), 0 )-1  ))  
	update #MonthlyPayroll set EMailSub=replace(EMailSub,'@@Year',pay_year),EmailBody=replace(EmailBody,'@@Year',pay_year)
	update p set p.EmailBody=replace(p.EmailBody,'@@EmployeeName',(case when isnull(e.pMailName,'')='' then rtrim(e.EmployeeName) else rtrim(e.pMailName) end)) From #MonthlyPayroll p inner join EmployeeMast e on (e.EmployeeCode=p.EmployeeCode)
			
	
	select L.Loc_Desc
	,EmployeeName=(case when isnull(e.pMailName,'')='' then e.EmployeeName else e.pMailName end)
	,EmailId=e.Emailoff,e.Department,e.Designation,e.DOB,e.DOJ,e.PAN,mst.SalPaidDays,mst.LOP,e.PFNO,p.* 
	from #MonthlyPayroll p 
	inner join EmployeeMast e on (e.EmployeeCode=p.EmployeeCode)
	inner join Emp_Monthly_Muster mst on (p.pay_year=mst.pay_year and p.pay_month=mst.pay_month and p.EmployeeCode=mst.EmployeeCode)
	inner join Loc_Master L on (L.Loc_Code=e.Loc_Code)
	order by p.pay_year,p.pay_month,L.Loc_Desc,e.Department,e.EmployeeName,Part
	
end
GO
