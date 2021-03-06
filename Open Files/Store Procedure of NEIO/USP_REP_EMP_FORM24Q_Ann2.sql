DROP PROCEDURE [USP_REP_EMP_FORM24Q_Ann2]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ruepesh Prajapati.
-- Create date: 18/09/2012
-- Description:	This Stored procedure is useful to generate TDS Form 24Q Annexure2 Report.
-- Modified By:Date:Reason: 
-- Remark:
-- =============================================
CREATE PROCEDURE [USP_REP_EMP_FORM24Q_Ann2]
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
Begin
	SET QUOTED_IDENTIFIER OFF
	Declare @FCON as NVARCHAR(2000),@VSAMT DECIMAL(14,2),@VEAMT DECIMAL(14,2),@EmployeeCode Varchar(30),@mEmployeeCode Varchar(30)

	DECLARE @SQLCOMMAND NVARCHAR(4000),@VCOND NVARCHAR(2000),@FDATE VARCHAR(10),@RcNo varchar(15)

	EXECUTE   USP_REP_FILTCON 
	@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
	,@VSDATE=@SDATE
	,@VEDATE=@EDATE
	,@VSAC =@SAC,@VEAC =@EAC
	,@VSIT=@SIT,@VEIT=@EIT
	,@VSAMT=@SAMT,@VEAMT=@EAMT
	,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
	,@VSCATE =@SCATE,@VECATE =@ECATE
	,@VSWARE =@SWARE,@VEWARE  =@EWARE
	,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
	,@VMAINFILE='M',@VITFILE='',@VACFILE='AC'
	,@VDTFLD ='U_CLDT'
	,@VLYN =NULL
	,@VEXPARA=@EXPARA
	,@VFCON =@FCON OUTPUT
	
	Declare @Sta_Dt SmallDateTime,@End_Dt SmallDateTime
	Select @Sta_Dt='2012/04/01',@End_Dt='2012/12/31'

	Select eSrNo=9999999,em.EmployeeCode,TotalSal332=PackageSal,Sec16Ded333=PackageSal,IncChargable334=PackageSal,Sec192B335=PackageSal,GrIncome336=PackageSal,Sec80c337=PackageSal,DedOthVIA338=PackageSal,TotVIA339=PackageSal,TaxableInc340=PackageSal,TDS341=PackageSal,Sur342=PackageSal,Cess343=PackageSal,Relief344=PackageSal,NetTax345=PackageSal,TDSDed346=PackageSal,TaxPend347=PackageSal into #TDS24Q2 From EmployeeMast em where 1=2
	Insert into #TDS24Q2 (EmployeeCode,eSrNO,TDSDed346) Select Distinct EmployeeCode,0,TDSAmt=sum(TDSAmt) From Emp_Monthly_Payroll where FinYear=@LYN Group by EmployeeCode
	Delete From #TDS24Q2 Where Isnull(TDSDed346,0)=0
	

	Select EmployeeCode,Amt=isnull(Sum(Amount),0) into #t332 From Emp_Form16_Projection Where FinYear=@LYN and Section in ('Section17 (1)','Section17 (2)') group by EmployeeCode
	update a set a.TotalSal332=b.Amt From #TDS24Q2 a inner join #t332 b on (a.EmployeeCode=b.EmployeeCode)
	update #TDS24Q2 set TotalSal332=isnull(TotalSal332,0)
	Drop Table #t332
	
	Select EmployeeCode,Amt=isnull(Sum(Amount),0) into #t333 From Emp_Form16_Projection Where FinYear=@LYN and Section in ('Section 16') group by EmployeeCode
	update a set a.Sec16Ded333=b.Amt From #TDS24Q2 a inner join #t333 b on (a.EmployeeCode=b.EmployeeCode)
	update #TDS24Q2 set Sec16Ded333=isnull(Sec16Ded333,0)
	Drop Table #t333

	
	Select EmployeeCode,Amt=isnull(Sum(Amount),0) into #t335 From Emp_Form16_Projection Where FinYear=@LYN and Section in ('Income other than salary') group by EmployeeCode
	update a set a.Sec192B335=b.Amt From #TDS24Q2 a inner join #t335 b on (a.EmployeeCode=b.EmployeeCode)
	update #TDS24Q2 set Sec192B335=isnull(Sec192B335,0)
	Drop Table #t335

	Select EmployeeCode,Amt=isnull(Sum(Amount),0) into #t337 From Emp_Form16_Projection Where FinYear=@LYN and ( Section in ('Section 80C','Section 80CCC','Section 80CCF','Section 80CCD') or Form16Group='(A) Deduction under chapter VIA-A') group by EmployeeCode
	update a set a.Sec80c337=b.Amt From #TDS24Q2 a inner join #t337 b on (a.EmployeeCode=b.EmployeeCode)
	update #TDS24Q2 set Sec80c337=isnull(Sec80c337,0)
	Drop Table #t337

	Select EmployeeCode,Amt=isnull(Sum(Amount),0) into #t338 From Emp_Form16_Projection Where FinYear=@LYN and ( Section in ('Section 80D','Section 80DD','Section 80DDB') or Form16Group='(B) Other Sections under Chapter VI-A') group by EmployeeCode
	update a set a.DedOthVIA338=b.Amt From #TDS24Q2 a inner join #t338 b on (a.EmployeeCode=b.EmployeeCode)
	update #TDS24Q2 set DedOthVIA338=isnull(DedOthVIA338,0)
	Drop Table #t338

	
	Update a Set a.TDS341=b.Amount From #TDS24Q2 a inner join Emp_Form16_Projection b on (a.EmployeeCode=b.EmployeeCode and b.Form16Group='Tax on total income')
	update #TDS24Q2 set TDS341=isnull(TDS341,0)
	update #TDS24Q2 set Sur342=isnull(Sur342,0)
	Update a Set a.Cess343=b.Amount From #TDS24Q2 a inner join Emp_Form16_Projection b on (a.EmployeeCode=b.EmployeeCode and b.Form16Group='Education Cess @ 3%(on tax computed at S.No. 12)')
	update #TDS24Q2 set Cess343=isnull(Cess343,0)
	
	Update a Set a.Relief344=b.Amount From #TDS24Q2 a inner join Emp_Form16_Projection b on (a.EmployeeCode=b.EmployeeCode and b.Section='Less: Relief under section 89 (attach details)')
	update #TDS24Q2 set Relief344=isnull(Relief344,0)

	Update a Set a.TaxPend347=b.Amount From #TDS24Q2 a inner join Emp_Form16_Projection b on (a.EmployeeCode=b.EmployeeCode and b.Form16Group='Tax payable / refundable ( 16 - 17 )')
	update #TDS24Q2 set TaxPend347=isnull(TaxPend347,0)
	
	update #TDS24Q2 set IncChargable334=isnull(TotalSal332,0)-isnull(Sec16Ded333,0)
	update #TDS24Q2 set GrIncome336=isnull(IncChargable334,0)+isnull(Sec192B335,0)
	update #TDS24Q2 set TotVIA339=isnull(Sec80c337,0)+isnull(DedOthVIA338,0)
	update #TDS24Q2 set TaxableInc340=isnull(GrIncome336,0)-isnull(TotVIA339,0)
	update #TDS24Q2 set NetTax345=TDS341+Sur342+Cess343+Relief344

	--,=PackageSal,=PackageSal,IncChargable334=PackageSal,Sec192B335=PackageSal,GrIncome336=PackageSal,=PackageSal,=PackageSal
	--,TotVIA339=PackageSal,=PackageSal,TDS341=PackageSal,Sur342=PackageSal,Cess343=PackageSal,Relief344=PackageSal,NetTax345=PackageSal,TDSDed346=PackageSal,TaxPend347=PackageSal into #TDS24Q2 From EmployeeMast em where 1=2

	Select a.*
	,EmployeeName=(Case when isnull(em.pMailName,'')='' then em.EmployeeName else em.pMailName end)
	,Gender=(Case when DateDiff(year,DOB,GetDate())>60 then 'S' else (Case when Sex='F' then 'W' else 'G' end) end) 
	,em.DOJ
	,DOL=(case when isnull(em.DOL,'')='' then Cast(substring(@LYn,6,4)+'/03/31' as smalldatetime) else em.DOL end)
	,em.PAN,FinYear=@LYn
	From #TDS24Q2 a  inner join EmployeeMast em on (a.EmployeeCode=em.EmployeeCode) Order By a.EmployeeCode
end
GO
