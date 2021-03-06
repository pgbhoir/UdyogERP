DROP PROCEDURE [Usp_Ent_Emp_TDS_Projection]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Rupesh
-- Create date: 08/09/2012
-- Description:This SP used for TDS Projection Transaction
--ADDED BY SATISH PAL FOR BUG-18531 DATED 11/09/2013
-- Modify date: 
-- Remark:
-- =============================================

CREATE Procedure [Usp_Ent_Emp_TDS_Projection]
@FinYear Varchar(30),@EmplyeeList Varchar(8000),@IsProje bit,@Sta_Dt SmallDatetime ,@End_Dt SmallDatetime
as
Begin
	Set DateFormat dmy
	Declare @fDate SmallDatetime,@Pay_Month int,@Pay_Year varchar(20),@InsertSameRecord int,@FiltPara varchar(4000)--,@FldList varchar(4000),@Fld_Nm  varchar(100),@Fld_Nm1  varchar(100),@AvgTax Decimal(12,3),@MaxLimit Decimal(13,3),@Form16FldNm Varchar(30),@IncomeFldLst Varchar(1000),@InvestmentFldLst Varchar(1000),@CessPer Decimal(10,3),@TaxableIncomeEffect varchar(1)
	Declare @Fld_Nm varchar(60),@SqlCommand nvarchar(4000),@Monthly_Payroll_Fld_Nm varchar(40),@Amount Decimal(18,3),@TempTblNm VARCHAR(1000)
	Declare @FldList nvarchar(4000),@Fld_Nm1  varchar(100),@EmployeeCode varchar(15),@Limit Decimal(13,3)
	Declare @RangeFrom Decimal(13,3),@RangeTo Decimal(13,3),@Percentage Decimal(10,3),@Cate Varchar(60),@Formula Varchar(1000),@CessPer Decimal(10,3)
	
	Set @TempTblNm = '##Emp_TDS_Projection_'+(SELECT substring(rtrim(ltrim(str(RAND( (DATEPART(mm, GETDATE()) * 100000 )
					+ (DATEPART(ss, GETDATE()) * 1000 )
					+ DATEPART(ms, GETDATE())) , 20,15))),3,20) as No)

	print @TempTblNm


	Select EmployeeCode into #EmpList From EmployeeMast where 1=2
	Set @SqlCommand='insert into #EmpList Select EmployeeCode From EmployeeMast em where '+@EmplyeeList
	print @SqlCommand
	Execute Sp_ExecuteSql @SqlCommand


	/*-->1.Getting Details From Monthly Payroll already Generated*/
	/*-->1.A Insert Existing Record From Emp_Monthly_Payroll_Generation to Emp_TDS_Projection_Paid*/	
	Set @SqlCommand='Delete From Emp_TDS_Projection_Paid where FinYear='+Char(39)+@FinYear+Char(39)+' and '+replace(@EmplyeeList,'em.','')
	print @SqlCommand
	Execute Sp_ExecuteSql @SqlCommand

	Declare  curFldNmProj Cursor for Select distinct Monthly_payroll_Fld_Nm From Emp_payroll_Declaration_Master Where isnull(Monthly_payroll_Fld_Nm,'')<>''
	open curFldNmProj
	Fetch Next From curFldNmProj into @Fld_Nm
	While(@@Fetch_Status=0)
	Begin	
		Set @SqlCommand='Insert into Emp_TDS_Projection_Paid (EmployeeCode,Pay_Year,Pay_Month,FinYear,Fld_Nm,AmountProj,AmountPaid,PayGenerated)'
		Set @SqlCommand=@SqlCommand+' '+'Select EmployeeCode,Pay_Year,Pay_Month,FinYear,'+char(39)+@Fld_Nm+char(39)+',AmountPeoj=0,AmountPaid=isnull(Sum('+@Fld_Nm+'),0),PayGenerated=1 From Emp_Monthly_Payroll em where PayGenerated=1 and FinYear='+Char(39)+@FinYear+Char(39)+' and '+@EmplyeeList +' Group by EmployeeCode,Pay_Year,Pay_Month,FinYear'
		print @SqlCommand
		Execute Sp_ExecuteSql @SqlCommand
		--Set @SqlCommand=@SqlCommand+' '+'Select (BasiAmt) From Emp_Monthly_Payroll Where FinYear'+=@FinYear'
		Fetch Next From curFldNmProj into @Fld_Nm
	End
	Close curFldNmProj
	DeAllocate curFldNmProj
	/*<--1.A Insert Existing Record From Emp_Monthly_Payroll_Generation to Emp_TDS_Projection_Paid*/	
	/*-->1B Add projection Record to Emp_TDS_Projection_Paid*/
	--Select '1b1' as '1b1',* From Emp_TDS_Projection_Paid Order by EmployeeCode,Pay_Month
	--Select distinct EmployeeCode from EmployeeMast where EmployeeCode in (Select Distinct EmployeeCode from #EmpList) order by EmployeeCode
	Declare curEmpList Cursor for Select distinct EmployeeCode from EmployeeMast where EmployeeCode in (Select Distinct EmployeeCode from #EmpList) order by EmployeeCode
	open curEmpList
	Fetch Next From curEmpList into @EmployeeCode
	While(@@Fetch_Status=0)
	Begin
		
		set @InsertSameRecord=0
		Set @fDate=@Sta_Dt
		while(@fDate<=@End_Dt and (@IsProje=1))
		begin
			print 'R1'
			set @Pay_Month=month(@fDate)
			Select @Pay_Year=Case when @Pay_Month in (1,2,3) then substring(@FinYear,6,4) else substring(@FinYear,1,4) end	
			if not Exists(Select EmployeeCode From Emp_TDS_Projection_Paid where EmployeeCode=@EmployeeCode and FinYear=@FinYear and Pay_Month=@Pay_Month)
			begin
				print @Pay_Month
				set @InsertSameRecord=1/*???*/
				set @FiltPara=' and e.employeeCode='+char(39)+@EmployeeCode+Char(39)

				Execute usp_Ent_Emp_Monthly_Payroll 0 ,@Pay_Year,@Pay_Month ,'',@FiltPara,@FinYear,@TempTblNm /*Getting Details From Monthly Payroll already Generated*/
				--Set @SqlCommand='Select ''@TempTblNm'' as ''@TempTblNm'', * From '+@TempTblNm
				--print @SqlCommand
				--Execute Sp_ExecuteSql @SqlCommand

				print 'R2'	
				--*
				Declare @cnt int
				Set @cnt=0
				--Select distinct @Pay_Month,Monthly_payroll_Fld_Nm From Emp_payroll_Declaration_Master Where isnull(Monthly_payroll_Fld_Nm,'')<>''
				Declare  curFldNmProj Cursor for Select distinct Monthly_payroll_Fld_Nm From Emp_payroll_Declaration_Master Where isnull(Monthly_payroll_Fld_Nm,'')<>''
				open curFldNmProj
				Fetch Next From curFldNmProj into @Fld_Nm
				While(@@Fetch_Status=0)
				Begin	
					Set @cnt=@cnt+1
					Set @SqlCommand='Insert into Emp_TDS_Projection_Paid (EmployeeCode,Pay_Year,Pay_Month,FinYear,Fld_Nm,AmountProj,AmountPaid,PayGenerated)'
					Set @SqlCommand=@SqlCommand+' '+'Select EmployeeCode,Pay_Year,Pay_Month,FinYear,'+char(39)+@Fld_Nm+char(39)+',AmountPeoj=0,AmountPaid=isnull('+@Fld_Nm+',0),PayGenerated=0 From '+@TempTblNm
					--print @SqlCommand
					--print @Pay_Month	
					Execute Sp_ExecuteSql @SqlCommand
					Fetch Next From curFldNmProj into @Fld_Nm
				End
				Close curFldNmProj
				DeAllocate curFldNmProj	
				print @cnt
				--*
				
				if exists (Select [Name] From tempdb..Sysobjects where [Name]=@TempTblNm)
				Begin
					Set @SqlCommand='Drop Table '+@TempTblNm
					print @SqlCommand
					execute Sp_executeSql @SqlCommand
				End
			end
			set @fDate=DateAdd(mm,1,@fDate)
			print @fDate
		end

	
		Fetch Next From curEmpList into @EmployeeCode
	end
	Close curEmpList
	DeAllocate curEmpList
	--Select '1b2' as '1b2',* From Emp_TDS_Projection_Paid Order by EmployeeCode,Pay_Month
	--print @EmployeeCode	
	update Emp_TDS_Projection_Paid set AmountPaid=0 where Fld_Nm='TDSAmt' and PayGenerated=0
	--Select 'a' as 'a',* From Emp_TDS_Projection_Paid Order by EmployeeCode,Pay_Month,Fld_Nm
	/*<--1B Add projection Record to Emp_TDS_Projection_Paid*/
	/*-->2.1 Add projection Blank Record to Emp_Form16_Projection*/
	Set @SqlCommand='Delete From Emp_Form16_Projection where FinYear='+Char(39)+@FinYear+Char(39)+' and '+replace(@EmplyeeList,'em.','')
	print @SqlCommand
	Execute Sp_ExecuteSql @SqlCommand

	Set @SqlCommand='Insert into Emp_Form16_Projection (EmployeeCode,Section,Form16Group,sm_SortOrd,Form16MainSrNo'
	Set @SqlCommand=rtrim(@SqlCommand)+',DeclarationDet,Fld_nm,MaxLimit,Monthly_Payroll_Fld_Nm,Amount,AmountPaid,intField,FinYear)'
	Set @SqlCommand=rtrim(@SqlCommand)+' Select em.EmployeeCode,sm.Section,sm.Form16Group,sm_SortOrd=sm.SortOrd,sm.Form16MainSrNo'
	Set @SqlCommand=rtrim(@SqlCommand)+' ,dm.DeclarationDet,dm.Fld_nm,dm.MaxLimit,dm.Monthly_Payroll_Fld_Nm,Amount=cast(0 as Decimal(12,3)),AmountPaid=cast(0 as Decimal(12,3)),dm.intField,'+char(39)+@FinYear+Char(39)
	Set @SqlCommand=rtrim(@SqlCommand)+' From EmployeeMast em,Emp_Payroll_Section_Master sm inner join Emp_Payroll_Declaration_Master dm on (sm.Section=dm.Section)'
	Set @SqlCommand=rtrim(@SqlCommand)+' Where  '+@EmplyeeList
	--order by em.pMailName,sm.SortOrd
	print @SqlCommand
	Execute Sp_ExecuteSql @SqlCommand
	--Select 'b1' as 'b1',* from Emp_Form16_Projection Order By EmployeeCode,sm_SortOrd
	/*<--2.1 Add projection Blank Record to Emp_Form16_Projection*/
	/*-->2.2 Update AmountPaid From Emp_TDS_Projection_Paid to Emp_Form16_Projection*/
	Select EmployeeCode,Fld_Nm,AmountPaid into #Emp_TDS_Projection_Paid From Emp_TDS_Projection_Paid where 1=2
	Set @SqlCommand='Insert Into #Emp_TDS_Projection_Paid Select EmployeeCode,Fld_Nm,AmountPaid=Sum(AmountPaid) From Emp_TDS_Projection_Paid where FinYear='+Char(39)+@FinYear+Char(39)+' and '+replace(@EmplyeeList,'em.','')+' Group by EmployeeCode,Fld_Nm'
	print @SqlCommand
	Execute Sp_ExecuteSql @SqlCommand
	--Select 'b2' as 'b2',* from #Emp_TDS_Projection_Paid Order By EmployeeCode
	update a set a.AmountPaid=b.AmountPaid From Emp_Form16_Projection a inner join #Emp_TDS_Projection_Paid b on (a.EmployeeCode=b.EmployeeCode and a.Monthly_Payroll_Fld_Nm=b.Fld_Nm)
	--Select 'b3' as 'b3',* from Emp_Form16_Projection Order By EmployeeCode,sm_SortOrd
	/*<--2.2 Update AmountPaid From Emp_TDS_Projection_Paid to Emp_Form16_Projection*/
	
	/*-->3.A Update AmountPaid From Emp_Payroll_Declaration_Details to Emp_Form16_Projection*/
	Declare cur_Pay_Dec Cursor for 	Select Distinct Fld_Nm From Emp_Payroll_Declaration_Master where IntField=0 order by Fld_Nm
	open cur_Pay_Dec
	Fetch Next From cur_Pay_Dec into @Fld_Nm
	while(@@Fetch_Status=0)
	begin
		--Set @SqlCommand='Update a set 
		Set @SqlCommand='Update a set a.Amount=b.'+@Fld_Nm +' From Emp_Form16_Projection a inner join #EmpList te on(a.EmployeeCode=te.EmployeeCode) inner join Emp_Payroll_Declaration_Details b on (a.EmployeeCode=b.EmployeeCode and a.FinYear=b.FinYear) and a.Fld_Nm='+char(39)+@Fld_Nm+char(39)+' and a.FinYear='+Char(39)+@FinYear+Char(39)
		Print 'c '+@SqlCommand
		execute Sp_executeSql @SqlCommand
		--set @SqlCommand='update a set a.Amount'+'=Sum(b.'+@Monthly_Payroll_Fld_Nm+') From #EmpTDSProjection a Inner Join Emp_TDS_Projection b on (a.EmployeeCode=b.EmployeeCode) Where a.Fld_Nm='+char(39)+@Fld_Nm+char(39)+' and b.FinYear='+char(39)+@FinYear+Char(39)  
		Fetch Next From cur_Pay_Dec into @Fld_Nm
	end	
	close cur_Pay_Dec
	DeAllocate cur_Pay_Dec	
	--Select '3A' as '3A',* from Emp_Form16_Projection Order By EmployeeCode,sm_SortOrd
	
	/*-->3.B Update HRA Calculation to Emp_Form16_Projection*/
	update Emp_Form16_Projection set Amount=AmountPaid*10/100 where Monthly_Payroll_Fld_Nm='BasicAmt'
	Select EmployeeCode,Basic10=Amount into #Basic10 From Emp_Form16_Projection where Monthly_Payroll_Fld_Nm='BasicAmt'
	update a set a.Basic10=(case when b.Amount-a.Basic10 >0 then b.Amount-a.Basic10  else 0 end) From #Basic10 a inner join Emp_Form16_Projection b on (a.EmployeeCode=b.EmployeeCode) where Monthly_Payroll_Fld_Nm='HRAAmt'
	update a set a.AmountPaid=b.Basic10 From Emp_Form16_Projection a inner join #Basic10 b on (a.EmployeeCode=b.EmployeeCode) where Monthly_Payroll_Fld_Nm='HRAAmt' and b.Basic10<a.AmountPaid
	--Select '3B' as '3B',* from Emp_Form16_Projection Order By EmployeeCode,sm_SortOrd
	Delete From Emp_Form16_Projection where Fld_Nm='Basic10'
	/*<--3.B Update HRA Calculation to Emp_Form16_Projection*/

	/*-->3.C Update Amount by Maximum Limit Checking to Emp_Form16_Projection*/
	update Emp_Form16_Projection set Amount=AmountPaid where Section not in('Section 10',' Section 80C',' Section 80CCC',' Section 80CCD') and AmountPaid>0
	update Emp_Form16_Projection set AmountPaid=0 where Section not in('Section 10','S ection 80C',' Section 80CCC',' Section 80CCD') and AmountPaid>0
	update Emp_Form16_Projection set Amount=AmountPaid where Section='Section 10' and AmountPaid<Amount
	update Emp_Form16_Projection set Amount=Amount/2 Where Section='Section 80G (50%)'
	update Emp_Form16_Projection set Amount=MaxLimit where MaxLimit<Amount and MaxLimit<>0
	--Select '3C' as '3C',* from Emp_Form16_Projection Order By EmployeeCode,sm_SortOrd
	/*<--3.C Update Amount by Maximum Limit Checking to Emp_Form16_Projection*/
	/*-->3.D Update Section 80C Limit to Emp_Form16_Projection*/
	--Declare @EmployeeCode varchar(15),@Limit Decimal(13,3),@Cnt int
	print 'priyanka1'
	Declare CurCount Cursor For Select EmployeeCode From Emp_Form16_Projection where  Section in ('Section 80C','Section 80CCC','Section 80CCD') Group by EmployeeCode having sum(Amount)>100000
	open CurCount
	Fetch Next From CurCount into @EmployeeCode
	While(@@Fetch_Status=0)
	Begin
		Set @Limit=100000
		--Select fld_nm,Amount From #EmpTDSProjection where EmployeeCode=@EmployeeCode and Section in ('Section 80C','Section 80CCC','Section 80CCD') and Amount<>0
		Declare curSection Cursor for Select fld_nm,Amount From Emp_Form16_Projection where EmployeeCode=@EmployeeCode and Section in ('Section 80C','Section 80CCC','Section 80CCD') and Amount<>0
		Open curSection
		Fetch Next From curSection into @fld_nm,@Amount
		While(@@Fetch_Status=0 )
		Begin
			print 'F1 '+@fld_nm
			print @Limit
			if(@Limit>=@Amount)
			begin
				set @Limit=@Limit-@Amount
			end
			else
			Begin
--				print 'F1 O limit '+@fld_nm
--				print @Limit	
--				Select 'aa' ,* From #EmpTDSProjection Where EmployeeCode=@EmployeeCode and Fld_Nm=@Fld_Nm
				update Emp_Form16_Projection set Amount=@Limit Where EmployeeCode=@EmployeeCode and Fld_Nm=@Fld_Nm
				set @Limit=0
			End
						
			Fetch Next From curSection into @fld_nm,@Amount
		End
		Close curSection
		DeAllocate curSection
	
		Fetch Next From CurCount into @EmployeeCode
	End
	close CurCount
	DeAllocate CurCount
	--Select '3C' as '3C',* from Emp_Form16_Projection Order By EmployeeCode,sm_SortOrd
	/*<--3.D Update Section 80C Limit to Emp_Form16_Projection*/
	/*-->4.A Insert  Blank Record For Form16 Head (3,5,6,8,10,11,12,13,14,15,18) into Emp_Form16_Projection*/
	print 'priyanka2'
	insert into Emp_Form16_Projection (EmployeeCode,Form16Group,Form16MainSrNo,sm_SortOrd,Section,DeclarationDet,Amount,FinYear) Select distinct a.EmployeeCode,Form16Group='Balance (1-2)',Form16MainSrNo=3,sm_SortOrd=0,Section='',DeclarationDet='',Amount=0,@FinYear From Emp_Form16_Projection a inner join #EmpList b on (a.EmployeeCode=b.EmployeeCode) and a.FinYear=@FinYear --where EmployeeCode+FinYear+'3' not in (Select distinct EmployeeCode+FinYear+rtrim(cast(Form16MainSrNo as Varchar)) From Emp_Form16_Projection)
	insert into Emp_Form16_Projection (EmployeeCode,Form16Group,Form16MainSrNo,sm_SortOrd,Section,DeclarationDet,Amount,FinYear) Select distinct a.EmployeeCode,Form16Group='Aggregate of 4',Form16MainSrNo=5,sm_SortOrd=0,Section='',DeclarationDet='',Amount=0,@FinYear From Emp_Form16_Projection   a inner join #EmpList b on (a.EmployeeCode=b.EmployeeCode) and a.FinYear=@FinYear
	insert into Emp_Form16_Projection (EmployeeCode,Form16Group,Form16MainSrNo,sm_SortOrd,Section,DeclarationDet,Amount,FinYear) Select distinct a.EmployeeCode,Form16Group='Income chargable under the head " salaries " (3-5)',Form16MainSrNo=6,sm_SortOrd=0,Section='',DeclarationDet='',Amount=0,@FinYear From Emp_Form16_Projection a inner join #EmpList b on (a.EmployeeCode=b.EmployeeCode) and a.FinYear=@FinYear
	insert into Emp_Form16_Projection (EmployeeCode,Form16Group,Form16MainSrNo,sm_SortOrd,Section,DeclarationDet,Amount,FinYear) Select distinct a.EmployeeCode,Form16Group='Gross Total Income (6+7)',Form16MainSrNo=8,sm_SortOrd=0,Section='',DeclarationDet='',Amount=0,@FinYear From Emp_Form16_Projection a inner join #EmpList b on (a.EmployeeCode=b.EmployeeCode) and a.FinYear=@FinYear
	
	insert into Emp_Form16_Projection (EmployeeCode,Form16Group,Form16MainSrNo,sm_SortOrd,Section,DeclarationDet,Amount,FinYear) Select distinct a.EmployeeCode,Form16Group='Aggregate of deductible amount under Chapter VI A',Form16MainSrNo=10,sm_SortOrd=0,Section='',DeclarationDet='',Amount=0,@FinYear From Emp_Form16_Projection a inner join #EmpList b on (a.EmployeeCode=b.EmployeeCode) and a.FinYear=@FinYear
	insert into Emp_Form16_Projection (EmployeeCode,Form16Group,Form16MainSrNo,sm_SortOrd,Section,DeclarationDet,Amount,FinYear) Select distinct a.EmployeeCode,Form16Group='Total Income (8-10) [Taxable Income]',Form16MainSrNo=11,sm_SortOrd=0,Section='',DeclarationDet='',Amount=0,@FinYear From Emp_Form16_Projection a inner join #EmpList b on (a.EmployeeCode=b.EmployeeCode) and a.FinYear=@FinYear
	insert into Emp_Form16_Projection (EmployeeCode,Form16Group,Form16MainSrNo,sm_SortOrd,Section,DeclarationDet,Amount,FinYear) Select distinct a.EmployeeCode,Form16Group='Tax on total income',Form16MainSrNo=12,sm_SortOrd=0,Section='',DeclarationDet='',Amount=0,@FinYear From Emp_Form16_Projection a inner join #EmpList b on (a.EmployeeCode=b.EmployeeCode) and a.FinYear=@FinYear
	insert into Emp_Form16_Projection (EmployeeCode,Form16Group,Form16MainSrNo,sm_SortOrd,Section,DeclarationDet,Amount,FinYear) Select distinct a.EmployeeCode,Form16Group='Education Cess @ 3%(on tax computed at S.No. 12)',Form16MainSrNo=13,sm_SortOrd=0,Section='',DeclarationDet='',Amount=0,@FinYear From Emp_Form16_Projection a inner join #EmpList b on (a.EmployeeCode=b.EmployeeCode) and a.FinYear=@FinYear
	insert into Emp_Form16_Projection (EmployeeCode,Form16Group,Form16MainSrNo,sm_SortOrd,Section,DeclarationDet,Amount,FinYear) Select distinct a.EmployeeCode,Form16Group='Tax Payable (12+13)',Form16MainSrNo=14,sm_SortOrd=0,Section='',DeclarationDet='',Amount=0,@FinYear From Emp_Form16_Projection a inner join #EmpList b on (a.EmployeeCode=b.EmployeeCode) and a.FinYear=@FinYear
	insert into Emp_Form16_Projection (EmployeeCode,Form16Group,Form16MainSrNo,sm_SortOrd,Section,DeclarationDet,Amount,FinYear) Select distinct a.EmployeeCode,Form16Group='Less: Relief unde section 89 (attach details)',Form16MainSrNo=15,sm_SortOrd=0,Section='',DeclarationDet='',Amount=0,@FinYear From Emp_Form16_Projection a inner join #EmpList b on (a.EmployeeCode=b.EmployeeCode) and a.FinYear=@FinYear
	insert into Emp_Form16_Projection (EmployeeCode,Form16Group,Form16MainSrNo,sm_SortOrd,Section,DeclarationDet,Amount,FinYear) Select distinct a.EmployeeCode,Form16Group='Tax Payable (14-15)',Form16MainSrNo=16,sm_SortOrd=0,Section='',DeclarationDet='',Amount=0,@FinYear From Emp_Form16_Projection a inner join #EmpList b on (a.EmployeeCode=b.EmployeeCode) and a.FinYear=@FinYear
	--insert into Emp_Form16_Projection (EmployeeCode,Form16Group,Form16MainSrNo,sm_SortOrd,Section,DeclarationDet,Amount,FinYear) Select distinct a..EmployeeCode,Form16Group='Tax payable / refundable ( 16 - 17 )',Form16MainSrNo=18,sm_SortOrd=0,Section='',DeclarationDet='',Amount=0,@FinYear From Emp_Form16_Projection a inner join #EmpList b on (a.EmployeeCode=b.EmployeeCode) and a.FinYear=@FinYear  --Commented by Priyanka B on 22062017 for Bug-28097
	insert into Emp_Form16_Projection (EmployeeCode,Form16Group,Form16MainSrNo,sm_SortOrd,Section,DeclarationDet,Amount,FinYear) Select distinct a.EmployeeCode,Form16Group='Tax payable / refundable ( 16 - 17 )',Form16MainSrNo=18,sm_SortOrd=0,Section='',DeclarationDet='',Amount=0,@FinYear From Emp_Form16_Projection a inner join #EmpList b on (a.EmployeeCode=b.EmployeeCode) and a.FinYear=@FinYear  --Modified by Priyanka B on 22062017 for Bug-28097
print 'priyanka3'
	Execute Update_Table_Column_Default_Value 'Emp_Form16_Projection', 1
	print 'priyanka4'
	/*<--4.A Insert  Blank Record For Form16 Head (3,5,6,8,10,11,12,13,14,15,18) into Emp_Form16_Projection*/
	/*-->4.A Update Form16 Head (3,5,6,8,10,11) to Emp_Form16_Projection*/
	Select a.EmployeeCode,Amount=sum(case when Form16MainSrNo=1 then Amount else -Amount end) into #Bal3 From Emp_Form16_Projection a inner join #EmpList b on (a.EmployeeCode=b.EmployeeCode) where Form16MainSrNo in (1,2) and FinYear=@FinYear Group by a.EmployeeCode
	update #Bal3 set Amount=0 where Amount<0
	update a set a.Amount=b.Amount from Emp_Form16_Projection a inner join #Bal3 b on (a.EmployeeCode=b.EmployeeCode and a.Form16MainSrNo=3 and a.FinYear=@FinYear ) 
	 
	
	Select a.EmployeeCode,Amount=sum(Amount) into #Bal4 From Emp_Form16_Projection a inner join #EmpList b on (a.EmployeeCode=b.EmployeeCode) where Form16MainSrNo=4 and FinYear=@FinYear Group by a.EmployeeCode
	update a set a.Amount=b.Amount from Emp_Form16_Projection a inner join #Bal4 b on (a.EmployeeCode=b.EmployeeCode and a.Form16MainSrNo=5 and a.FinYear=@FinYear ) 
	
	Select a.EmployeeCode,Amount=sum(case when Form16MainSrNo=3 then Amount else -Amount end) into #Bal6 From Emp_Form16_Projection a inner join #EmpList b on (a.EmployeeCode=b.EmployeeCode) where Form16MainSrNo in (3,5) and FinYear=@FinYear Group by a.EmployeeCode
	update #Bal6 set Amount=0 where Amount<0
	update a set a.Amount=b.Amount from Emp_Form16_Projection a inner join #Bal6 b on (a.EmployeeCode=b.EmployeeCode and a.Form16MainSrNo=6 and a.FinYear=@FinYear ) 
	
	Select a.EmployeeCode,Amount=sum(Amount) into #Bal8 From Emp_Form16_Projection a inner join #EmpList b on (a.EmployeeCode=b.EmployeeCode) where Form16MainSrNo in(6,7) and FinYear=@FinYear Group by a.EmployeeCode
	update a set a.Amount=b.Amount from Emp_Form16_Projection a inner join #Bal8 b on (a.EmployeeCode=b.EmployeeCode and a.Form16MainSrNo=8 and a.FinYear=@FinYear ) 

	Select a.EmployeeCode,Amount=sum(Amount) into #Bal10 From Emp_Form16_Projection a inner join #EmpList b on (a.EmployeeCode=b.EmployeeCode) where Form16MainSrNo in(9) and FinYear=@FinYear Group by a.EmployeeCode
	update a set a.Amount=b.Amount from Emp_Form16_Projection a inner join #Bal10 b on (a.EmployeeCode=b.EmployeeCode and a.Form16MainSrNo=10 and a.FinYear=@FinYear ) 
	
	Select a.EmployeeCode,Amount=sum(case when Form16MainSrNo=8 then Amount else -Amount end) into #Bal11 From Emp_Form16_Projection a inner join #EmpList b on (a.EmployeeCode=b.EmployeeCode)  where Form16MainSrNo in (8,10) and FinYear=@FinYear Group by a.EmployeeCode
	update #Bal11 set Amount=0 where Amount<0
	update a set a.Amount=b.Amount from Emp_Form16_Projection a inner join #Bal11 b on (a.EmployeeCode=b.EmployeeCode and a.Form16MainSrNo=11 and a.FinYear=@FinYear ) 

	--Select '4A' as '4A',* from Emp_Form16_Projection Order By EmployeeCode,sm_SortOrd
	/*<--4.A Update Form16 Head (3,5,6,8,10,11) to Emp_Form16_Projection*/
	/*-->4.B Update Form16 TDS Head (12,13,14) to Emp_Form16_Projection*/
	Select EmployeeCode,TaxableIncome=Amount,TaxPer=Cast(0 as Decimal(10,3)),TaxAmt=Cast(0 as Decimal(13,3)),CessPer=Cast(0 as Decimal(10,3)),CessAmt=Cast(0 as Decimal(13,3)),TotTDsAmt=Cast(0 as Decimal(13,3)) into #Tax From Emp_Form16_Projection where FinYear=@FinYear and charindex('[Taxable Income]',Form16Group)>0
	Declare Cur_TDS_Slab cursor for Select RangeFrom,RangeTo,Percentage,CessPer,Amount,Cate,Formula From Emp_TDS_Slab_Master where FinYear=@FinYear order by RangeFrom
	open Cur_TDS_Slab
	Fetch Next From Cur_TDS_Slab into @RangeFrom,@RangeTo,@Percentage,@CessPer,@Amount,@Cate,@Formula
	while(@@Fetch_Status=0)
	begin
		Set @SqlCommand='update #Tax Set TaxPer='+Cast(@Percentage as Varchar(14))+',CessPer='+Cast(@CessPer as Varchar(14))+' where (TaxableIncome between '+Cast(@RangeFrom as Varchar(14))+ ' and '++Cast(@RangeTo as Varchar(14))+ ')'--+@Formula
		print @SqlCommand
		Execute Sp_ExecuteSql @SqlCommand
		
		Set @SqlCommand='update #Tax Set TaxAmt='+@Formula + ' where (TaxableIncome between '+Cast(@RangeFrom as Varchar(14))+ ' and '++Cast(@RangeTo as Varchar(14))+ ')'--+@Formula
		print @SqlCommand
		Execute Sp_ExecuteSql @SqlCommand

		Set @SqlCommand='update #Tax Set CessAmt=Round((TaxAmt*'+Cast(@CessPer as Varchar(14))+ ')/100,0)'
		print @SqlCommand
		Execute Sp_ExecuteSql @SqlCommand

		Set @SqlCommand='update #Tax Set TotTDsAmt=TaxAmt+CessAmt'
		print @SqlCommand
		Execute Sp_ExecuteSql @SqlCommand
		Fetch Next From Cur_TDS_Slab into @RangeFrom,@RangeTo,@Percentage,@CessPer,@Amount,@Cate,@Formula
	end
	close Cur_TDS_Slab
	DeAllocate Cur_TDS_Slab
	print 'Aa'
	--Select '4B1' as '4B1','#Tax' as '#Tax' ,* From #Tax order by employeeCode
	update a set a.Amount=b.TaxAmt From Emp_Form16_Projection a inner join #Tax b on (a.EmployeeCode=b.EmployeeCode) where a.Form16MainSrNo=12 and a.FinYear=@FinYear
	update a set a.Amount=b.CessAmt From Emp_Form16_Projection a inner join #Tax b on (a.EmployeeCode=b.EmployeeCode) where a.Form16MainSrNo=13 and a.FinYear=@FinYear
	update a set a.Amount=b.TotTDsAmt From Emp_Form16_Projection a inner join #Tax b on (a.EmployeeCode=b.EmployeeCode) where a.Form16MainSrNo=14 and a.FinYear=@FinYear
	--Select '4B2' as '4B2',* from Emp_Form16_Projection Order By EmployeeCode,sm_SortOrd
	/*<--4.B Update Form16 TDS Head (12,13,14) Emp_Form16_Projection*/
	/*-->4.C Update Form16 Head (16,18) to Emp_Form16_Projection*/
	--update a set a.Amount=0 From #EmpTDSProjection a  where a.Form16MainSrNo=15
	update a set a.Amount=isnull(a.Amount,0) From Emp_Form16_Projection a 
	Select EmployeeCode,Amount=sum(case when Form16MainSrNo=14 then Amount else -Amount end) into #Bal16 From Emp_Form16_Projection where Form16MainSrNo in (14,15) and FinYear=@FinYear Group by EmployeeCode
	update a set a.Amount=b.Amount from Emp_Form16_Projection a inner join #Bal16 b on (a.EmployeeCode=b.EmployeeCode and a.Form16MainSrNo=16 and a.FinYear=@FinYear ) 
	
	Select EmployeeCode,Amount=sum(case when Form16MainSrNo=16 then Amount else -Amount end) into #Bal18 From Emp_Form16_Projection where Form16MainSrNo in (16,17) and FinYear=@FinYear Group by EmployeeCode
	update a set a.Amount=b.Amount from Emp_Form16_Projection a inner join #Bal18 b on (a.EmployeeCode=b.EmployeeCode and a.Form16MainSrNo=18 and a.FinYear=@FinYear ) 
	--Select '4C' as '4C',* from Emp_Form16_Projection Order By EmployeeCode,sm_SortOrd
	/*<--4.C Update Form16 Head (16,18) to Emp_Form16_Projection*/

	Delete from Emp_Form16_Projection where Form16MainSrNo in (2,4,7,9) and Amount=0

	Delete From Emp_TDS_Projection_Paid where fld_nm='TDSPer'   and FinYear=@FinYear AND EmployeeCode =@EmplyeeList --ADDED BY SATISH PAL FOR BUG-18531 DATED 11/09/2013
	Delete From Emp_TDS_Projection_Paid where fld_nm='TDSPen'   and FinYear=@FinYear AND EmployeeCode =@EmplyeeList --ADDED BY SATISH PAL FOR BUG-18531 DATED 11/09/2013
 	Delete From Emp_TDS_Projection_Paid where fld_nm='MonthPen' and FinYear=@FinYear AND EmployeeCode =@EmplyeeList --ADDED BY SATISH PAL FOR BUG-18531 DATED 11/09/2013
	Delete From Emp_TDS_Projection_Paid where fld_nm='TDSAvg'   and FinYear=@FinYear AND EmployeeCode =@EmplyeeList --ADDED BY SATISH PAL FOR BUG-18531 DATED 11/09/2013

	insert into Emp_TDS_Projection_Paid (EmployeeCode,Pay_Year,Pay_Month,FinYear,Fld_Nm,AmountProj,AmountPaid,PayGenerated)
	Select a.EmployeeCode,Pay_Year='',Pay_Month=0,FinYear,'TDSPer',AmountProj=0,AmountPaid=0,PayGenerated=0 
	From Emp_Form16_Projection a inner join #EmpList b on (a.EmployeeCode=b.EmployeeCode) 
	where Form16MainSrNo in(18) and FinYear=@FinYear
	update a set a.AmountPaid=b.TaxPer From Emp_TDS_Projection_Paid a inner join #Tax b on (a.EmployeeCode=b.EmployeeCode) and FinYear=@FinYear and Fld_Nm='TDSPer'
	
	insert into Emp_TDS_Projection_Paid (EmployeeCode,Pay_Year,Pay_Month,FinYear,Fld_Nm,AmountProj,AmountPaid,PayGenerated)
	Select a.EmployeeCode,Pay_Year='',Pay_Month=0,a.FinYear,Fld_Nm='TDSPen',AmountProj=0,AmountPaid=Amount,PayGenerated=0
	From Emp_Form16_Projection a inner join #EmpList b on (a.EmployeeCode=b.EmployeeCode) where a.Form16MainSrNo=18 and a.FinYear=@FinYear 
 
	
	Select a.EmployeeCode,MonthPending=count(PayGenerated) into #EmpPenMonth From Emp_TDS_Projection_Paid a inner join #EmpList b on (a.EmployeeCode=b.EmployeeCode) and FinYear=@FinYear and Fld_Nm='TDSAmt' and PayGenerated=0 Group by a.EmployeeCode
	--Select a.EmployeeCode,MonthPending=(case when PayGenerated=1 then -1 else 1 end),* From Emp_TDS_Projection_Paid a inner join #EmpList b on (a.EmployeeCode=b.EmployeeCode) and FinYear=@FinYear and Fld_Nm='TDSAmt' order by a.EmployeeCode,FinYear,fld_nm
	--Select * From #EmpPenMonth 
	insert into Emp_TDS_Projection_Paid (EmployeeCode,Pay_Year,Pay_Month,FinYear,Fld_Nm,AmountProj,AmountPaid,PayGenerated)
	Select a.EmployeeCode,Pay_Year='',Pay_Month=0,FinYear,'MonthPen',AmountProj=0,AmountPaid=0,PayGenerated=0 
	From Emp_Form16_Projection a inner join #EmpList b on (a.EmployeeCode=b.EmployeeCode) 
	where Form16MainSrNo in(18) and FinYear=@FinYear
	update a set a.AmountPaid=b.MonthPending From Emp_TDS_Projection_Paid a inner join #EmpPenMonth b on (a.EmployeeCode=b.EmployeeCode) and FinYear=@FinYear and Fld_Nm='MonthPen'
	
	insert into Emp_TDS_Projection_Paid (EmployeeCode,Pay_Year,Pay_Month,FinYear,Fld_Nm,AmountProj,AmountPaid,PayGenerated)
	Select a.EmployeeCode,Pay_Year='',Pay_Month=0,FinYear,'TDSAvg',AmountProj=0,AmountPaid=0,PayGenerated=0 
	From Emp_Form16_Projection a inner join #EmpList b on (a.EmployeeCode=b.EmployeeCode) 
	where Form16MainSrNo in(18) and FinYear=@FinYear
	update a set a.AmountPaid=b.AmountPaid/c.AmountPaid 
	From Emp_TDS_Projection_Paid a 
	inner join Emp_TDS_Projection_Paid b on(a.EmployeeCode=b.EmployeeCode and a.FinYear=b.FinYear and b.Fld_Nm='TDSPen') 
	inner join Emp_TDS_Projection_Paid c on(a.EmployeeCode=c.EmployeeCode and a.FinYear=c.FinYear and c.Fld_Nm='MonthPen' and c.AmountPaid<>0)
	Where a.Fld_Nm='TDSAvg'
	

	--update a set a.AmountPaid=b.Amount From Emp_TDS_Projection_Paid a inner join Emp_Form16_Projection b on (a.EmployeeCode=b.EmployeeCode and b.Form16MainSrNo=12 and a.FinYear=b.FinYear and b.FinYear=@FinYear) and a.Fld_Nm='TDSPen'
	--Execute Usp_Emp_TDS_Projection '2012-2013', 'em.EmployeeCode in (''A00001'')',1,'2012/4/01','2013/3/28'

	Select tp.*,EmployeeName=em.pMailName,em.pAdd1,em.pAdd2,em.pAdd3,em.pCity,em.pPin,em.pState,em.PAN 
	from Emp_Form16_Projection tp inner join EmployeeMast em on (em.EmployeeCode=tp.EmployeeCode) 
	--Order By 	tp.EmployeeName,Form16MainSrNo,sm_SortOrd


end
GO
