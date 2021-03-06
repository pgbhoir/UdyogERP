IF  not EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Emp_Payroll_Declaration]') AND type in (N'U'))
begin
CREATE TABLE [dbo].[Emp_Payroll_Declaration](
	[Id] [decimal](10, 0) IDENTITY(1,1) NOT NULL,
	[Pay_Year] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[EmployeeCode] [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[EPF] [decimal](16, 3) NULL,
	[NSC] [decimal](16, 3) NULL,
	[LifeInsurancePolicy] [decimal](16, 3) NULL,
	[PPF] [decimal](16, 3) NULL,
	[HBLoanPrincipal] [decimal](16, 3) NULL,
	[TaxSavingFD] [decimal](16, 3) NULL,
	[EquityLinkSavingsBond] [decimal](16, 3) NULL,
	[section80CCC] [decimal](16, 3) NULL,
	[Section80CCD] [decimal](16, 3) NULL,
	[Section80CCF] [decimal](16, 3) NULL,
	[ULIP] [decimal](16, 3) NULL,
	[TutionFees] [decimal](16, 3) NULL,
	[Section80E] [decimal](16, 3) NULL,
	[Section80G] [decimal](16, 3) NULL,
	[Section80GG] [decimal](16, 3) NULL,
	[Section80GGA] [decimal](16, 3) NULL,
	[Section80GGC] [decimal](16, 3) NULL,
	[Section80U] [decimal](16, 3) NULL,
	[Section80DD] [decimal](16, 3) NULL,
	[MedicalInsurance80D] [decimal](16, 3) NULL,
	[Section80DDB] [decimal](16, 3) NULL,
	[OtherDeductionVI_A] [decimal](16, 3) NULL,
	[OthIncomeDivedends] [decimal](16, 3) NULL,
	[OthIncomeSpcify] [decimal](16, 3) NULL,
	[OthIncomeInterest] [decimal](16, 3) NULL,
    [HRA_10_13A] [decimal](16, 3) NULL,
    [MediAmt] [decimal](16, 3) NULL,
    [CONWAMT] [decimal](16, 3) NULL,
    [LTCAmt] [decimal](16, 3) NULL,
	[EntAmt] [decimal](16, 3) NULL,
	[PTAmt] [decimal](16, 3) NULL,
	[HBLoanAmt] [decimal](16, 3) NULL,
	[ChildEduAmt] [decimal](16, 3) NULL,
	[ChildHostelAmt] [decimal](16, 3) NULL,
    [section17_1] [decimal](16, 3) NULL,
    [section17_21] [decimal](16, 3) NULL,
    [section17_3] [decimal](16, 3) NULL
	) ON [PRIMARY]
end
else
begin
	Execute Add_Multiple_Columns 'Emp_Payroll_Declaration','HRA_10_13A decimal(16, 3) Default 0 with Values'
	Execute Add_Multiple_Columns 'Emp_Payroll_Declaration','MediAmt decimal(16, 3) Default 0 with Values'
	Execute Add_Multiple_Columns 'Emp_Payroll_Declaration','CONWAMT decimal(16, 3) Default 0 with Values'
	Execute Add_Multiple_Columns 'Emp_Payroll_Declaration','LTCAmt decimal(16, 3) Default 0 with Values'
	Execute Add_Multiple_Columns 'Emp_Payroll_Declaration','EntAmt decimal(16, 3) Default 0 with Values'
	Execute Add_Multiple_Columns 'Emp_Payroll_Declaration','PTAmt decimal(16, 3) Default 0 with Values'
	Execute Add_Multiple_Columns 'Emp_Payroll_Declaration','HBLoanAmt decimal(16, 3) Default 0 with Values'
	Execute Add_Multiple_Columns 'Emp_Payroll_Declaration','ChildEduAmt decimal(16, 3) Default 0 with Values'
	Execute Add_Multiple_Columns 'Emp_Payroll_Declaration','ChildHostelAmt decimal(16, 3) Default 0 with Values'
	Execute Add_Multiple_Columns 'Emp_Payroll_Declaration','section17_1 decimal(16, 3) Default 0 with Values'
	Execute Add_Multiple_Columns 'Emp_Payroll_Declaration','section17_2 decimal(16, 3) Default 0 with Values'
	Execute Add_Multiple_Columns 'Emp_Payroll_Declaration','section17_3 decimal(16, 3) Default 0 with Values'
end


--[HRA_10_13A]
--MediAmt
--[CONWAMT]
--[LTCAmt]
--EntAmt
--PTAmt
--HBLoanAmt
--ChildEduAmt
--ChildHostelAmt
