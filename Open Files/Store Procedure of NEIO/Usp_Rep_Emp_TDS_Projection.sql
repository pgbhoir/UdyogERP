DROP PROCEDURE [Usp_Rep_Emp_TDS_Projection]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*=============================================
 Author:		Rupesh Prajapati.
 Create date: 08/09/2012
 Description:	This Stored procedure is useful to generate TDS Projection Report.
 Modification Date/By/Reason: 26/02/2013 / Ramya /for sending Email
 Remark: 
-- =============================================*/
Create Procedure [Usp_Rep_Emp_TDS_Projection] 
@FinYear Varchar(30),@EmplyeeList Varchar(8000),@UserNm Varchar(60)
as
begin
	Declare @Fld_Nm varchar(30),@SqlCommand nvarchar(4000)

	Declare @ExpFileNm varchar(60),@EMailSub varchar(1000),@EmailBody varchar(8000)
	Declare @UserName Varchar(100)	


    Select @ExpFileNm=ExpFileNm,@EMailSub=EMailSub,@EmailBody=EmailBody From R_Status where Rep_Nm='EmpTDSProj'
	Select @UserName=(case when isnull([User_Name],'')<>'' then [User_Name] else @UserNm end) From vudyog..[user] where [user]=rtrim(@UserNm) /*Ramya 01/11/12 for displaying username*/

	set @SqlCommand='Select tp.*,EmployeeName=em.pMailName,em.pAdd1,em.pAdd2,em.pAdd3,em.pCity,em.pPin,em.pState,em.PAN,EmailId=em.Emailoff' 
	set @SqlCommand=@SqlCommand+','''+@ExpFileNm +'''as  ExpFileNm,'''+@EMailSub +'''as EMailSub,'''+@EmailBody +'''as EmailBody'  /*Ramya 26/02/13*/
	set @SqlCommand=@SqlCommand+' into ##Emp_Form16_Projection from Emp_Form16_Projection tp inner join EmployeeMast em on (em.EmployeeCode=tp.EmployeeCode)'
	set @SqlCommand=@SqlCommand+' where FinYear='+Char(39)+@FinYear+Char(39)+' and '+ @EmplyeeList
	set @SqlCommand=@SqlCommand+' Order By tp.EmployeeName,Form16MainSrNo,sm_SortOrd'
	print @SqlCommand
	Execute Sp_ExecuteSql @SqlCommand



	/*Ramya 26/02/13*/
	update ##Emp_Form16_Projection set EMailSub=replace(EMailSub,'@@FinYear',@FinYear)
	--update #Emp_Form16_Projection set EMailSub=replace(EMailSub,'@@Year',Pay_Year),EmailBody=replace(EmailBody,'@@Year',Pay_Year)
	update p set p.EmailBody=replace(p.EmailBody,'@@EmployeeName',(case when isnull(e.pMailName,'')='' then rtrim(e.EmployeeName) else rtrim(e.pMailName) end)) From ##Emp_Form16_Projection p inner join EmployeeMast e on (e.EmployeeCode=p.EmployeeCode)
    update ##Emp_Form16_Projection Set EmailBody=replace(EmailBody,'@@FinYear',rtrim(@FinYear))
	update ##Emp_Form16_Projection Set EmailBody=replace(EmailBody,'@@UserName',rtrim(@UserName)) /*Ramya 01/11/12 for displaying username*/
select * from ##Emp_Form16_Projection

drop table ##Emp_Form16_Projection


end
GO
