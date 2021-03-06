IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[UTrig_Emp_Monthly_Payroll_Loan_Del]'))
Begin
	DROP TRIGGER [dbo].[UTrig_Emp_Monthly_Payroll_Loan_Del]
End
GO
-- =============================================
-- Author: Rupesh
-- Create date: 08/09/2012
-- Description:This Triger is Used to update Emp_Loan_Advance_Details
-- Modified By/On/For : Sachin N. S. on 30/05/2014 for Bug-23004
-- Modified By/On/For : Sachin N. S. on 22/05/2014 for Bug-22159
-- Remark:
-- =============================================
CREATE Trigger [dbo].[UTrig_Emp_Monthly_Payroll_Loan_Del]  on [dbo].[Emp_Monthly_Payroll]
AFTER  Delete
As
begin
	
	Declare @EmployeeCode varchar(15),@Pay_Year Varchar(15),@Pay_Month int,@Fld_Nm varchar(30) ,@Amount Decimal(17,2)
	Declare @tSqlCommand nvarchar(4000)
	--Select @Pay_Month=Pay_Month from inserted
	
	
	if exists ( Select distinct EmployeeCode From Deleted)
	begin
		Select @Pay_Year=Pay_Year,@Pay_Month=Pay_Month from Deleted
		Select * into #TrigDeleted From Deleted

--		Changed by Sachin N. S. on 22/05/2014 for Bug-22159 -- Start
--		Declare Cur_Trig_Loan cursor for Select Fld_Nm from Emp_Loan_Advance a 
--		inner join Emp_Loan_Advance_Details b on (a.Tran_Cd=b.Tran_cd) --where Pay_Year=@Pay_Year and Pay_Month=@Pay_Month

		Declare Cur_Trig_Loan cursor for Select distinct Fld_Nm,a.EmployeeCode from Emp_Loan_Advance a 
			inner join Emp_Loan_Advance_Details b on (a.Tran_Cd=b.Tran_cd) 
			inner join #TrigDeleted c on (a.employeecode=c.employeecode)		
--		Changed by Sachin N. S. on 22/05/2014 for Bug-22159 -- End

		Open Cur_Trig_Loan
--		Fetch next From Cur_Trig_Loan into @Fld_Nm
		Fetch next From Cur_Trig_Loan into @Fld_Nm,@EmployeeCode		-- Changed by Sachin N. S. on 22/05/2014 for Bug-22159
		while(@@Fetch_Status=0)
		begin
			Set @tSqlCommand='update a Set Proj_RePay=a.Inst_Amt+a.Interest,a.Repay_Amt=0 From Emp_Loan_Advance_Details a inner join #TrigDeleted b on (a.EmployeeCode=b.EmployeeCode and a.Pay_Year=b.Pay_Year and a.Pay_Month=b.Pay_month)'
			Execute Sp_ExecuteSql @tSqlCommand
			execute Usp_Ent_Emp_Update_Loan_Balance @EmployeeCode,@Pay_Year,@Pay_Month,@Fld_Nm,'D'	-- Changed by Sachin N. S. on 28/05/2014 for Bug-23004	
			Fetch next From Cur_Trig_Loan into @Fld_Nm,@EmployeeCode	-- Changed by Sachin N. S. on 22/05/2014 for Bug-22159
--			execute Usp_Ent_Emp_Update_Loan_Balance @EmployeeCode,@Pay_Year,@Pay_Month,@Fld_Nm
--			Fetch next From Cur_Trig_Loan into @Fld_Nm
		end
		Close Cur_Trig_Loan
		DeAllocate Cur_Trig_Loan
		execute Usp_Ent_Emp_Update_Loan_Balance @EmployeeCode,@Pay_Year,@Pay_Month,@Fld_Nm,'D'	-- Changed by Sachin N. S. on 28/05/2014 for Bug-23004	
--		execute Usp_Ent_Emp_Update_Loan_Balance @Pay_Year,@Pay_Month
--		execute Usp_Ent_Emp_Update_Loan_Balance @EmployeeCode,@Pay_Year,@Pay_Month,@Fld_Nm
	end
end 

