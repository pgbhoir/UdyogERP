DROP PROCEDURE [Usp_Rep_Emp_PaySlip]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [Usp_Rep_Emp_PaySlip] 
/*=============================================
 Author:		Rupesh Prajapati.
 Create date: 12/05/2012
 Description:	This Stored procedure is useful to generate PaySlip Default Format.
 Modification Date/By/Reason:Rupesh.04/10/2012. Add EmployeeList Para.
 Remark: 
-- =============================================*/
@Tran_Cd int,@EmplyeeList Varchar(8000),@UserNm Varchar(60)
as
begin
	Declare @ExpFileNm varchar(60),@EMailSub varchar(1000),@EmailBody varchar(8000)
	Declare @UserName Varchar(100)	

	Select @ExpFileNm=ExpFileNm,@EMailSub=EMailSub,@EmailBody=EmailBody From R_Status where Rep_Nm='PaySlip'
	Select @UserName=(case when isnull([User_Name],'')<>'' then [User_Name] else @UserNm end) From vudyog..[user] where [user]=rtrim(@UserNm) /*Ramya 01/11/12 for displaying username*/


	Declare @Date smalldatetime,@Progtotal Numeric(19,2),@Inv_no Varchar(20)
	Declare @SqlCommand nvarchar(4000),@Head_Nm varchar(60),@Fld_Nm varchar(60)
	
	Select part=1,EmployeeCode,Tran_cd,Pay_Year,Pay_Month,Head_NM=hm.short_nm,h.PayEffect,hm.Fld_Nm,NetPayment,Amount=Cast(0 as Decimal(18,2)),LvOpBal=Cast(0 as Decimal(18,2)),LvCr=Cast(0 as Decimal(18,2)),LvDr=Cast(0 as Decimal(18,2)),LvEncash=Cast(0 as Decimal(18,2)),LvCalBal=Cast(0 as Decimal(18,2)) 
	,@ExpFileNm as  ExpFileNm,@EMailSub as EMailSub,@EmailBody as EmailBody
	into #MonthlyPayroll From Emp_Monthly_Payroll, Emp_Pay_Head_Master hm Left Join Emp_Pay_Head h on (h.HeadTypeCode=hm.HeadTypeCode) 
	Where Tran_cd=@Tran_Cd and hm.prinpayslip=1
	order by Pay_Year,Pay_Month,EmployeeCode,h.SortOrd,hm.SortOrd
	
	--select * from #MonthlyPayroll
	Declare Cur_hm cursor for Select hm.short_nm,hm.Fld_Nm From Emp_Pay_Head_Master hm where hm.prinpayslip=1
	open Cur_hm
	fetch next from Cur_hm into @Head_Nm,@Fld_Nm
	while (@@fetch_Status=0)
	begin
		set @SqlCommand='update a set a.Amount=b.'+@Fld_Nm+ ' From #MonthlyPayroll a inner join Emp_Monthly_Payroll b on (a.employeeCode=b.EmployeeCode and a.Pay_Year=b.Pay_Year and a.Pay_Month=b.Pay_Month and a.Fld_Nm='+char(39)+@Fld_Nm+char(39)+')'
		print @SqlCommand
		execute sp_ExecuteSql @SqlCommand
		fetch next from Cur_hm into @Head_Nm,@Fld_Nm
	end
	close Cur_hm
	Deallocate Cur_hm
	
	Select m.EmployeeCode,m.Pay_Year,m.Pay_Month,s.Att_Code,LvOpBal=Cast(0 as Decimal(8,3)),LvCr=Cast(0 as Decimal(8,3)),LvAvailed=Cast(0 as Decimal(8,3)),LvEncash=Cast(0 as Decimal(8,3)),LvBal=Cast(0 as Decimal(8,3)) into #Leave From Emp_Leave_Maintenance m ,Emp_Attendance_Setting s where s.isLeave=1 and s.lDeactive=0
	and rtrim(m.EmployeeCode)+rtrim(m.Pay_Year)+rtrim(cast(m.Pay_Month as varchar)) in (Select distinct rtrim(EmployeeCode)+rtrim(Pay_Year)+rtrim(cast(Pay_Month as varchar)) From #MonthlyPayroll)

	Declare Cur_Leave cursor for Select Distinct Att_Code From Emp_Attendance_Setting where isLeave=1 and lDeactive=0 order by Att_Code
	open Cur_Leave
	Fetch Next From Cur_Leave into @Fld_Nm
	while (@@fetch_Status=0)
	begin
		set @SqlCommand='update a set '+'a.LvOpBal=isnull(b.'+@Fld_Nm+'_OpBal,0)'+',a.LvCr=isnull(b.'+@Fld_Nm+'_Credit,0)'+',a.LvAvailed=isnull(b.'+@Fld_Nm+'_Availed,0)'+',a.LvEnCash=isnull(b.'+@Fld_Nm+'_EnCash,0)'++',a.LvBal=isnull(b.'+@Fld_Nm+'_Balance,0)'+' From #Leave a inner join Emp_Leave_Maintenance b on (a.employeeCode=b.EmployeeCode and a.Pay_Year=b.Pay_Year and a.Pay_Month=b.Pay_Month and a.Att_Code='+char(39)+@Fld_Nm+char(39)+')'
		print @SqlCommand
		execute sp_ExecuteSql @SqlCommand
		Fetch Next From Cur_Leave into @Fld_Nm
	end
	close Cur_Leave
	deallocate Cur_Leave

	insert into #MonthlyPayroll (part,EmployeeCode,Tran_cd,Pay_Year,Pay_Month,Head_NM,PayEffect,Fld_Nm,Amount,LvOpBal,LvCr,LvDr,LvEncash,LvCalBal)
	Select  part=2,rtrim(EmployeeCode),@Tran_Cd,Pay_Year,Pay_Month,Att_Code,PayEffect='',Att_Code,Amount=0,LvOpBal,LvCr,LvAvailed,LvEncash,LvBal From #Leave

	update #MonthlyPayroll Set netpayment=isnull(Netpayment,0)
	
	update #MonthlyPayroll set EMailSub=replace(EMailSub,'@@Month',DateName( month , DateAdd( month , cast(Pay_Month as int), 0 )-1  )),EmailBody=replace(EmailBody,'@@Month',DateName( month , DateAdd( month , cast(Pay_Month as int), 0 )-1  ))  
	update #MonthlyPayroll set EMailSub=replace(EMailSub,'@@Year',Pay_Year),EmailBody=replace(EmailBody,'@@Year',Pay_Year)
	update p set p.EmailBody=replace(p.EmailBody,'@@EmployeeName',(case when isnull(e.pMailName,'')='' then rtrim(e.EmployeeName) else rtrim(e.pMailName) end)) From #MonthlyPayroll p inner join EmployeeMast e on (e.EmployeeCode=p.EmployeeCode)
	update #MonthlyPayroll Set EmailBody=replace(EmailBody,'@@UserName',rtrim(@UserName)) /*Ramya 01/11/12 for displaying username*/
		
	--select * From #MonthlyPayroll p inner join EmployeeMast e on (e.EmployeeCode=p.EmployeeCode) inner join Loc_Master L on (L.Loc_Code=e.Loc_Code)
	--where ltrim(p.EmployeeCode) in ('A00001','A00002','S00003') 

--	select  p.* 
--	from #MonthlyPayroll p 
--	inner join EmployeeMast e on (e.EmployeeCode=p.EmployeeCode) 
--	--inner join Emp_Monthly_Muster mst on (p.Pay_Year=mst.Pay_Year and p.Pay_Month=mst.Pay_Month and p.EmployeeCode=mst.EmployeeCode) 
--	inner join Loc_Master L on (L.Loc_Code=e.Loc_Code) 
--	where ltrim(p.EmployeeCode) in ('A00001','A00002','S00003') order by p.Pay_Year,p.Pay_Month,L.Loc_Desc,e.Department,e.EmployeeName,Part
	
	set @SqlCommand='select L.Loc_Desc'
	set @SqlCommand=rtrim(@SqlCommand)+' ,EmployeeName=(case when isnull(e.pMailName,'''')='''' then e.EmployeeName else e.pMailName end)'
	set @SqlCommand=rtrim(@SqlCommand)+' ,EmailId=e.Emailoff,e.Department,e.Designation,e.DOB,e.DOJ,e.PAN,mst.SalPaidDays,mst.LOP,e.PFNO,p.*' 
	set @SqlCommand=rtrim(@SqlCommand)+' from #MonthlyPayroll p '
	set @SqlCommand=rtrim(@SqlCommand)+' inner join EmployeeMast e on (e.EmployeeCode=p.EmployeeCode)'
	set @SqlCommand=rtrim(@SqlCommand)+' inner join Emp_Monthly_Muster mst on (p.Pay_Year=mst.Pay_Year and p.Pay_Month=mst.Pay_Month and p.EmployeeCode=mst.EmployeeCode)'
	set @SqlCommand=rtrim(@SqlCommand)+' inner join Loc_Master L on (L.Loc_Code=e.Loc_Code)'
	set @SqlCommand=rtrim(@SqlCommand)+' where p.'+@EmplyeeList
	set @SqlCommand=rtrim(@SqlCommand)+' order by p.Pay_Year,p.Pay_Month,L.Loc_Desc,e.Department,e.EmployeeName,Part'
	print @SqlCommand
	execute sp_ExecuteSql @SqlCommand
end
GO
