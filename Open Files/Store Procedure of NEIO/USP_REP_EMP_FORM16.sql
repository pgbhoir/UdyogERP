DROP PROCEDURE [USP_REP_EMP_FORM16]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  Procedure [USP_REP_EMP_FORM16]
/*=============================================
 Author:		Rupesh Prajapati.
 Create date: 08/09/2012
 Description:	This Stored procedure is useful to generate TDS Form16 Report.
 Modification Date/By/Reason:
 Remark: 
-- =============================================*/
@TMPAC NVARCHAR(50),@TMPIT NVARCHAR(50),@SPLCOND VARCHAR(8000),@SDATE  SMALLDATETIME,@EDATE SMALLDATETIME
,@SAC AS VARCHAR(60),@EAC AS VARCHAR(60)
,@SIT AS VARCHAR(60),@EIT AS VARCHAR(60)
,@SAMT FLOAT,@EAMT FLOAT
,@SDEPT AS VARCHAR(60),@EDEPT AS VARCHAR(60)
,@SCATE AS VARCHAR(60),@ECATE AS VARCHAR(60)
,@SWARE AS VARCHAR(60),@EWARE AS VARCHAR(60)
,@SINV_SR AS VARCHAR(60),@EINV_SR AS VARCHAR(60)
,@FinYear VARCHAR(20)
,@EXPARA  AS VARCHAR(60)= null
as
begin

Declare @pay_year varchar(30),@pay_month int,@cpay_month varchar(30),@EmpNm varchar(100)
Declare @POS INT

--Set @EXPARA='[pay_year=2012][pay_month=January][EmpNm=Rup]'

	if(charindex('[EmpNm=',@EXPARA)>0)
	begin
		SET @POS=CHARINDEX('[EmpNm=',@EXPARA)
		SET @EmpNm=SUBSTRING(@EXPARA,@POS+7,len(@EXPARA)-@pos)
		SET @EmpNm=replace(@EmpNm,']','')
	end

	--EXECUTE USP_REP_EMP_FORM16'','','','04/01/2012','03/31/2013','','','','',0,0,'','TANKHWA             ','','','','','','','2012-2013','[EMPNM=R0000C]'	
	
	Declare @Fld_Nm varchar(30),@SqlCommand nvarchar(4000)
	Select Part=9,tp.*--,EmployeeName=em.pMailName,em.pAdd1,em.pAdd2,em.pAdd3,em.pCity,em.pPin,em.pState,em.PAN--,Qrt=Space(100),RecNo=Space(30) 
	,Date=cast('' as smalldatetime)
	into #Form16
	from Emp_Form16_Projection tp 
	--inner join EmployeeMast em on (em.EmployeeCode=tp.EmployeeCode)
	where 1=2
	set @SqlCommand='insert into #Form16 Select Part=2,tp.*,Date=getdate()'--,EmployeeName=em.pMailName,em.pAdd1,em.pAdd2,em.pAdd3,em.pCity,em.pPin,em.pState,em.PAN' 
	--set @SqlCommand=@SqlCommand+' ,Qrt='''',RecNo='''''
	set @SqlCommand=@SqlCommand+' from Emp_Form16_Projection tp inner join EmployeeMast em on (em.EmployeeCode=tp.EmployeeCode)'
	set @SqlCommand=@SqlCommand+' where FinYear='+Char(39)+@FinYear+Char(39)
	if(@EmpNm<>'')
	begin
		Set @SqlCommand=Rtrim(@SqlCommand)+' '+'and (em.EmployeeName='+char(39)+@EmpNm+char(39)+')'
	end	
	--set @SqlCommand=@SqlCommand+' Order By tp.EmployeeName,Form16MainSrNo,sm_SortOrd'
	print @SqlCommand
	Execute Sp_ExecuteSql @SqlCommand
	--Select top 1 * From #Form16 Group by EmployeeCode
	--Select Qrt=Case 
	--when month(mpm.Date) in (4,5,6) then 'Quarter 1' else 
	print 'R1'
	/*Execute Add_Columns 'tdsacknow','FormNo Varchar(10) Default '''' with values'
	update tdsacknow set FormNo='26Q' where isnull(FormCode,'')=''*/

	insert into #Form16 (Part,EmployeeCode,Section,DeclarationDet,Amount,AmountPaid) Select Distinct Part=1,EmployeeCode,Section='Quarter 1',DeclarationDet='',0,0 From #Form16
	insert into #Form16 (Part,EmployeeCode,Section,DeclarationDet,Amount,AmountPaid) Select Distinct Part=1,EmployeeCode,Section='Quarter 2',DeclarationDet='',0,0 From #Form16
	insert into #Form16 (Part,EmployeeCode,Section,DeclarationDet,Amount,AmountPaid) Select Distinct Part=1,EmployeeCode,Section='Quarter 3',DeclarationDet='',0,0 From #Form16
	insert into #Form16 (Part,EmployeeCode,Section,DeclarationDet,Amount,AmountPaid) Select Distinct Part=1,EmployeeCode,Section='Quarter 4',DeclarationDet='',0,0 From #Form16
	
	Select EmployeeCode,TDSAmt=Sum(mnp.TDSAmt) into #TDSDed1 From Emp_monthly_Payroll mnp inner join MpMain m on (m.Tran_cd=mnp.Tran_cd) Where m.Entry_ty='MP' and l_yn=@FinYear and mnp.Pay_Month in (4,5,6) Group by EmployeeCode--Th_Trn_Cd
	Select EmployeeCode,TDSAmt=Sum(mnp.TDSAmt) into #TDSDed2 From Emp_monthly_Payroll mnp inner join MpMain m on (m.Tran_cd=mnp.Tran_cd) Where m.Entry_ty='MP' and l_yn=@FinYear and mnp.Pay_Month in (7,8,9) Group by EmployeeCode
	Select EmployeeCode,TDSAmt=Sum(mnp.TDSAmt) into #TDSDed3 From Emp_monthly_Payroll mnp inner join MpMain m on (m.Tran_cd=mnp.Tran_cd) Where m.Entry_ty='MP' and l_yn=@FinYear and mnp.Pay_Month in (10,11,12) Group by EmployeeCode
	Select EmployeeCode,TDSAmt=Sum(mnp.TDSAmt) into #TDSDed4 From Emp_monthly_Payroll mnp inner join MpMain m on (m.Tran_cd=mnp.Tran_cd) Where m.Entry_ty='MP' and l_yn=@FinYear and mnp.Pay_Month in (1,2,3) Group by EmployeeCode

	Select EmployeeCode,TDSAmt=Sum(mnp.TDSAmt) into #TDSDepo1 From Emp_monthly_Payroll mnp inner join BpMain m on (m.Tran_cd=mnp.Th_Trn_Cd) Where m.Entry_ty='TH' and l_yn=@FinYear and month(m.u_Cldt) in (4,5,6) Group by EmployeeCode--Th_Trn_Cd
	Select EmployeeCode,TDSAmt=Sum(mnp.TDSAmt) into #TDSDepo2 From Emp_monthly_Payroll mnp inner join BpMain m on (m.Tran_cd=mnp.Th_Trn_Cd) Where m.Entry_ty='TH' and l_yn=@FinYear and month(m.u_Cldt) in (7,8,9) Group by EmployeeCode
	Select EmployeeCode,TDSAmt=Sum(mnp.TDSAmt) into #TDSDepo3 From Emp_monthly_Payroll mnp inner join BpMain m on (m.Tran_cd=mnp.Th_Trn_Cd) Where m.Entry_ty='TH' and l_yn=@FinYear and month(m.u_Cldt) in (10,11,12) Group by EmployeeCode
	Select EmployeeCode,TDSAmt=Sum(mnp.TDSAmt) into #TDSDepo4 From Emp_monthly_Payroll mnp inner join BpMain m on (m.Tran_cd=mnp.Th_Trn_Cd) Where m.Entry_ty='TH' and l_yn=@FinYear and month(m.u_Cldt) in (1,2,3) Group by EmployeeCode
	print 'R2'
	update a set a.Amount=b.TDSAmt From #Form16 a inner join #TDSDed1 b on (a.EmployeeCode=b.EmployeeCode and a.Section='Quarter 1') 
	update a set a.Amount=b.TDSAmt From #Form16 a inner join #TDSDed2 b on (a.EmployeeCode=b.EmployeeCode and a.Section='Quarter 2')
	update a set a.Amount=b.TDSAmt From #Form16 a inner join #TDSDed3 b on (a.EmployeeCode=b.EmployeeCode and a.Section='Quarter 3')
	update a set a.Amount=b.TDSAmt From #Form16 a inner join #TDSDed4 b on (a.EmployeeCode=b.EmployeeCode and a.Section='Quarter 4')

	update a set a.AmountPaid=b.TDSAmt From #Form16 a inner join #TDSDepo1 b on (a.EmployeeCode=b.EmployeeCode and a.Section='Quarter 1') 
	update a set a.AmountPaid=b.TDSAmt From #Form16 a inner join #TDSDepo2 b on (a.EmployeeCode=b.EmployeeCode and a.Section='Quarter 2')
	update a set a.AmountPaid=b.TDSAmt From #Form16 a inner join #TDSDepo3 b on (a.EmployeeCode=b.EmployeeCode and a.Section='Quarter 3')
	update a set a.AmountPaid=b.TDSAmt From #Form16 a inner join #TDSDepo4 b on (a.EmployeeCode=b.EmployeeCode and a.Section='Quarter 4')
	
	set @SqlCommand=''
	Select @SqlCommand=Acknow_No From TdsAcknow Where FormNo='24Q' and L_Yn=@FinYear and Quarter=1
	--Select SqlCommand=Acknow_No From TdsAcknow Where FormNo='24Q' and L_Yn=@FinYear and Quarter=1
	print @SqlCommand
	update #Form16 set Form16MainSrNo=1,Form16Group=rtrim(isnull(@SqlCommand,''))  where Part=1 and Section='Quarter 1' 
	set @SqlCommand=''
	Select @SqlCommand=Acknow_No From TdsAcknow Where FormNo='24Q' and L_Yn=@FinYear and Quarter=2
	update #Form16 set Form16MainSrNo=2,Form16Group=rtrim(isnull(@SqlCommand,''))  where Part=1 and Section='Quarter 2' 
	set @SqlCommand=''
	Select @SqlCommand=Acknow_No From TdsAcknow Where FormNo='24Q' and L_Yn=@FinYear and Quarter=3
	update #Form16 set Form16MainSrNo=3,Form16Group=rtrim(isnull(@SqlCommand,''))  where Part=1 and Section='Quarter 3' 	
	set @SqlCommand=''
	Select @SqlCommand=Acknow_No From TdsAcknow Where FormNo='24Q' and L_Yn=@FinYear and Quarter=4
	update #Form16 set Form16MainSrNo=4,Form16Group=rtrim(isnull(@SqlCommand,''))  where Part=1 and Section='Quarter 4' 
	--update #Form16 set Form16Group=rtrim(isnull(@SqlCommand,''))  where Part=1 and Section='Quarter 1' 

	update #Form16 Set FinYear=@FinYear
	set @SqlCommand=''
	insert into #Form16 (Part,EmployeeCode,AmountPaid,Section,Date,Form16Group,DeclarationDet)
	Select 3,EmployeeCode,AmountPaid=mnp.TDSAmt,Section=m.BSRCode,m.u_Chaldt,Form16Group=m.U_Chalno,'' 
	From Emp_monthly_Payroll mnp inner join BpMain m on (m.Tran_cd=mnp.Th_Trn_Cd) 
	Where m.Entry_ty='TH' and l_yn=@FinYear and mnp.EmployeeCode in (Select Distinct EmployeeCode From #Form16)
--	


	Select f.*
	,AsYear=cast(cast(substring(@FinYear,1,4) as int)+1 as VarChar)+'-'+cast(cast(substring(@FinYear,6,4) as int)+1 as VarChar)
	,EmployeeName=em.pMailName,em.pAdd1,em.pAdd2,em.pAdd3,em.pCity,em.pPin,em.pState,em.PAN  From #Form16 f inner join EmployeeMast em on (f.EmployeeCode=em.EmployeeCode) Order by EmployeeName,Part,Form16MainSrNo,sm_SortOrd,Date 


end
GO
