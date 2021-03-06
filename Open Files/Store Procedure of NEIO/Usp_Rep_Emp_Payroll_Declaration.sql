DROP PROCEDURE [Usp_Rep_Emp_Payroll_Declaration]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Rupesh
-- Create date: 20/07/2012
-- Description:
-- Modify date: 
-- Remark:
-- =============================================
Create Procedure [Usp_Rep_Emp_Payroll_Declaration]
@Pay_Year varchar(30),@EmployeeCode varchar(20),@UserNm Varchar(60)
AS

Begin

Declare @FCON as NVARCHAR(2000),@SqlCommand as NVARCHAR(4000)
Declare @Fld_Nm varchar(60),@FldVal NUMERIC(17,2),@ParmDefinition nvarchar(500),@EmpNm varchar(100)
Declare @POS INT


Declare @UserName Varchar(100)
Declare @ExpFileNm varchar(60),@EMailSub varchar(1000),@EmailBody varchar(8000)
	Select @ExpFileNm=ExpFileNm,@EMailSub=EMailSub,@EmailBody=EmailBody From R_Status where Rep_Nm='PayDecDet'

	Select @UserName=(case when isnull([User_Name],'')<>'' then [User_Name] else @UserNm end) From vudyog..[user] where [user]=rtrim(@UserNm)
	--Select @ExpFileNm as  ExpFileNm,@EMailSub as EMailSub,@EmailBody as EmailBody,EmailId=e.EmailOff,EmployeeName=(case when isnull(e.pMailName,'')='' then e.EmployeeName else e.pMailName end),a.* into #PayDec From Emp_Payroll_Declaration a inner join EmployeeMast e on (a.EmployeeCode=e.EmployeeCode)


select @EmpNm=EmployeeName from EmployeeMast where EmployeeCode=@EmployeeCode
print @EmployeeCode
--Declare @Fld_Nm varchar(60),@SqlCommand nVarChar(4000),@FldVal NUMERIC(17,2),@ParmDefinition nvarchar(500)


	Select EmployeeCode=@EmployeeCode,Pay_Year=@Pay_Year,ExRec=cast(0 as int),MaxLimit=cast(0 as Decimal(12,3)),Amount=cast(0 as Decimal(12,3)),a.Section,a.DeclarationDet,a.Fld_Nm,mSortOrd=a.SortOrd,b.SortOrd,@ExpFileNm as  ExpFileNm,@EMailSub as EMailSub,@EmailBody as EmailBody,Grp=cast('' as varchar (250)),GrpOrd=3 into #EmpInvDec From Emp_Payroll_Declaration_Master a inner join Emp_Payroll_Section_Master b on (a.Section=b.Section) where 1=2
    print 'hi1'
     --SET @SqlCommand='insert into #EmpInvDec Select EmployeeCode='+Char(39)+rtrim(@EmployeeCode)+Char(39)+',Pay_Year='+Char(39)+rtrim(@Pay_Year)+Char(39)+',ExRec=cast(0 as int),Amount=cast(0 as Decimal(12,3)),a.Section,a.DeclarationDet,a.Fld_Nm,mSortOrd=a.SortOrd,b.SortOrd,'+'ExpFileNm='+char(39)+rtrim(@ExpFileNm)+char(39)+', EMailSub ='+char(39)+rtrim(@EMailSub)+char(39) +',EmailBody='+char(39)+rtrim(@EmailBody)+char(39)+',Grp='''',GrpOrd=3 From Emp_Payroll_Declaration_Master a inner join Emp_Payroll_Section_Master b on (a.Section=b.Section) where (a.IsDeactive=0  or (a.IsDeactive=1 and a.DeactFrom >'+char(39)+cast(getdate() as varchar)+char(39)+'))order by b.SortOrd,a.SortOrd' 
SET @SqlCommand='insert into #EmpInvDec Select EmployeeCode='+Char(39)+rtrim(@EmployeeCode)+Char(39)+',Pay_Year='+Char(39)+rtrim(@Pay_Year)+Char(39)+',ExRec=cast(0 as int),a.MaxLimit,Amount=cast(0 as Decimal(12,3)),a.Section,a.DeclarationDet,a.Fld_Nm,mSortOrd=a.SortOrd,b.SortOrd,'+'ExpFileNm='+char(39)+rtrim(@ExpFileNm)+char(39)+', EMailSub ='+char(39)+rtrim(@EMailSub)+char(39) +',EmailBody='+char(39)+rtrim(@EmailBody)+char(39)+',Grp='''',GrpOrd=3 From Emp_Payroll_Declaration_Master a inner join Emp_Payroll_Section_Master b on (a.Section=b.Section) where (a.IsDeactive=0  or (a.IsDeactive=1 and a.DeactFrom >'+char(39)+cast(getdate() as varchar)+char(39)+'))order by b.SortOrd,a.SortOrd' 
	 print @SqlCommand

      print 'hi2'
	execute Sp_ExecuteSql @SqlCommand
    SET @SqlCommand='Declare cur_InvDec cursor for Select distinct Fld_Nm From Emp_Payroll_Declaration_Master Where IntField=0 '
	print @SqlCommand
	execute Sp_ExecuteSql @SqlCommand
	open cur_InvDec
	Fetch Next From cur_InvDec into @Fld_Nm
	while(@@Fetch_Status=0)
	begin
		SET @FldVal=0
		SET @SqlCommand='select @FldValOut=['+@Fld_Nm+'] FROM Emp_Payroll_Declaration_Details where employeecode='+CHAR(39)+@EmployeeCode+CHAR(39)+' and Pay_Year='+CHAR(39)+@Pay_Year+CHAR(39)
		SET @ParmDefinition = N' @FldValOut Decimal(17,2) OUTPUT '
		EXECUTE sp_executesql @SqlCommand,@ParmDefinition,@FldValOut=@FldVal OUTPUT
		print @SqlCommand
		PRINT @FldVal
		SET @SqlCommand='UPDATE #EmpInvDec SET Amount='+CAST(@FldVal AS varchar)+' where Fld_Nm=' +CHAR(39)+@Fld_Nm+CHAR(39)
		PRINT @SqlCommand
		EXECUTE sp_executesql  @SqlCommand
		Fetch Next From cur_InvDec into @Fld_Nm
	end
	close cur_InvDec
	DeAllocate cur_InvDec

	update #EmpInvDec set EMailSub=replace(EMailSub,'@@Year',@Pay_Year),EmailBody=replace(EmailBody,'@@Year',rtrim(@Pay_Year))
	update #EmpInvDec Set EmailBody=replace(EmailBody,'@@EmployeeName',rtrim(@EmpNm))
	update #EmpInvDec Set EmailBody=replace(EmailBody,'@@UserName',rtrim(@UserName))

	update #EmpInvDec set Grp='Gross Salary',GrpOrd=1 where Section in ('Section17 (1)','Section17 (2)','Section17 (3)')
	update #EmpInvDec set Grp='Less Allowance Under Section 10',GrpOrd=2 where Section in ('Section 10')
	--update #EmpInvDec set Grp='Deduction Under Section 16 & 17',GrpOrd=3 where Section in ('Section 16 and 17')
update #EmpInvDec set Grp='Deduction Under Section 16 & 17',GrpOrd=3 where Section in ('Section 16')
	update #EmpInvDec set Grp='Source of Income Other than Salary',GrpOrd=4 where Section in ('Income other than salary')
	update #EmpInvDec set Grp='Investment U/S 80C,80CCC,80CCD',GrpOrd=5 where Section in ('Section 80C','Section 80CCC','Section 80CCD')
	update #EmpInvDec set Grp='Other Permitted Deduction',GrpOrd=6 where Section in ('Section 80CCF','Section 80E','Section 80G (100%)','Section 80G (50%)','Section 80GG','Section 80GGA','Section 80GGC','Section 80U','Section 80DD','Section 80D','Section 80DDB','Others Deduction Under Section VI-A')




	Select i.*,@EmpNm as EmployeeName,EmailId=e.Emailoff From #EmpInvDec i inner join Employeemast e on (i.EmployeeCode=e.EmployeeCode) order by GrpOrd
End




-- [Usp_Rep_Emp_Payroll_Declaration] '2012','C00001','ADMIN'
--'2012','A00004','Admin'
--Execute Usp_Rep_Emp_Payroll_Declaration 'A00011         ','2012','''Salary Section17_1'',''Salary Section17_2'',''Salary Section17_3'''
GO
