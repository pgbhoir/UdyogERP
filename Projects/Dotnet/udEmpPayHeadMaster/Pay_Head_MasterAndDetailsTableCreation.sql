IF  not EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Emp_Pay_Head]') AND type in (N'U'))
Begin

	CREATE TABLE [dbo].[Emp_Pay_Head](
	[HeadType] [varchar](70) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[HeadTypeCode] [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PayEffect] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SortOrd] [int] NOT NULL
	) ON [PRIMARY]
End

IF  not EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Emp_Pay_Head_Master]') AND type in (N'U'))
Begin
	CREATE TABLE [dbo].[Emp_Pay_Head_Master](
	[Head_Nm] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[HeadTypeCode] [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Emp_Pay_Head_Master_HeadTypeCode]  DEFAULT (''),
	[StPayType] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Emp_Pay_Head_Master_CalcPeriod1]  DEFAULT (''),
	[Short_Nm] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SortOrd] [smallint] NOT NULL,
	[CalcPeriod] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Emp_Pay_Head_Master_CalcPeriod]  DEFAULT (''),
	[Fld_Nm] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Slab_Appl] [bit] NULL CONSTRAINT [DF_Emp_Pay_Head_Master_Slab_Appl]  DEFAULT ((0)),
	[Def_Rate] [decimal](10, 3) NULL,
	[Def_Amt] [decimal](16, 2) NULL,
	[Formula] [varchar](300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[dAc_Name] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[cAc_Name] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrInPaySlip] [bit] NULL,
	[PayEditable] [bit] NULL,
	[IsDeactive] [bit] NULL,
	[DeactFrom] [smalldatetime] NULL,
	[Remark] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[id] [int] IDENTITY(1,1) NOT NULL,
	[RoundOff] [bit] NULL DEFAULT ((0)),
	[Round_Off] [bit] NULL DEFAULT ((0))
	) ON [PRIMARY]
End
IF  not EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Emp_Pay_Head_Details]') AND type in (N'U'))
Begin
	CREATE TABLE [dbo].[Emp_Pay_Head_Details](
	[EmpID] [int] NULL,
	[EmployeeCode] [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Emp_ED_Details_EmployeeCode]  DEFAULT ((0)),
	[BasicAmtYN] [bit] NULL CONSTRAINT [DF__Emp_ED_De__Basic__25FD2E3B]  DEFAULT ((0)),	
	[BasicAmt] [decimal](17, 2) NULL CONSTRAINT [DF_Emp_ED_Details_BasicAmt]  DEFAULT ((0)),
	[HRAAmtYN] [bit] NULL CONSTRAINT [DF__Emp_ED_De__HRAAm__26F15274]  DEFAULT ((0)),
	[HRAAmt] [decimal](17, 2) NULL CONSTRAINT [DF_Emp_ED_Details_HRAAmt]  DEFAULT ((0)),
	[DAAMTYN] [bit] NULL CONSTRAINT [DF__Emp_ED_De__DAAMT__27E576AD]  DEFAULT ((0)),
	[DAAMT] [decimal](17, 2) NULL CONSTRAINT [DF_Emp_ED_Details_DAAMT]  DEFAULT ((0)),
	[MediAmtYN] [bit] NULL CONSTRAINT [DF__Emp_ED_De__MediA__28D99AE6]  DEFAULT ((0)),
	[MediAmt] [decimal](17, 2) NULL CONSTRAINT [DF_Emp_ED_Details_MediAmt]  DEFAULT ((0)),
	[CONWAMTYN] [bit] NULL CONSTRAINT [DF__Emp_ED_De__CONWA__29CDBF1F]  DEFAULT ((0)),
	[CONWAMT] [decimal](17, 2) NULL CONSTRAINT [DF_Emp_ED_Details_CONWAMT]  DEFAULT ((0)),
	[BonusAmtYN] [bit] NULL CONSTRAINT [DF__Emp_ED_De__Bonus__2AC1E358]  DEFAULT ((0)),
	[BonusAmt] [decimal](17, 2) NULL CONSTRAINT [DF_Emp_ED_Details_BonusAmt]  DEFAULT ((0)),
	[oAllowAmtYN] [bit] NULL CONSTRAINT [DF__Emp_ED_De__oAllo__2BB60791]  DEFAULT ((0)),
	[oAllowAmt] [decimal](17, 2) NULL CONSTRAINT [DF_Emp_ED_Details_oAllowAmt]  DEFAULT ((0)),
	[ArrAmtYN] [bit] NULL CONSTRAINT [DF__Emp_ED_De__ArrAm__2CAA2BCA]  DEFAULT ((0)),
	[ArrAmt] [decimal](17, 2) NULL CONSTRAINT [DF_Emp_ED_Details_ArrAmt]  DEFAULT ((0)),
	[dAllowAmtYN] [bit] NULL CONSTRAINT [DF__Emp_ED_De__dAllo__2D9E5003]  DEFAULT ((0)),
	[dAllowAmt] [decimal](17, 2) NULL CONSTRAINT [DF_Emp_ED_Details_dAllowAmt]  DEFAULT ((0)),
	[OtWagAmtYN] [bit] NULL CONSTRAINT [DF__Emp_ED_De__OtWag__2E92743C]  DEFAULT ((0)),
	[OtWagAmt] [decimal](17, 2) NULL CONSTRAINT [DF_Emp_ED_Details_OtWagAmt]  DEFAULT ((0)),
	[PTaxAmtYN] [bit] NULL CONSTRAINT [DF__Emp_ED_De__PTaxA__2F869875]  DEFAULT ((0)),
	[PTaxAmt] [decimal](17, 2) NULL CONSTRAINT [DF_Emp_ED_Details_PTaxAmt]  DEFAULT ((0)),
	[PFEmpEYN] [bit] NULL CONSTRAINT [DF__Emp_ED_De__PFEmp__307ABCAE]  DEFAULT ((0)),
	[PFEmpE] [decimal](17, 2) NULL CONSTRAINT [DF_Emp_ED_Details_PFEmpE]  DEFAULT ((0)),
	[PFEmpRYN] [bit] NULL CONSTRAINT [DF__Emp_ED_De__PFEmp__316EE0E7]  DEFAULT ((0)),
	[PFEmpR] [decimal](17, 2) NULL CONSTRAINT [DF_Emp_ED_Details_PFEmpR]  DEFAULT ((0)),
	[ESICEmpEYN] [bit] NULL CONSTRAINT [DF__Emp_ED_De__ESICE__32630520]  DEFAULT ((0)),
	[ESICEmpE] [decimal](17, 2) NULL CONSTRAINT [DF_Emp_ED_Details_ESICEmpE]  DEFAULT ((0)),
	[ESICEmpRYN] [bit] NULL CONSTRAINT [DF__Emp_ED_De__ESICE__33572959]  DEFAULT ((0)),
	[ESICEmpR] [decimal](17, 2) NULL CONSTRAINT [DF_Emp_ED_Details_ESICEmpR]  DEFAULT ((0)),
	[TDSAmtYN] [bit] NULL CONSTRAINT [DF__Emp_ED_De__TDSAm__344B4D92]  DEFAULT ((0)),
	[TDSAmt] [decimal](17, 2) NULL CONSTRAINT [DF_Emp_ED_Details_TDSAmt]  DEFAULT ((0)),
	[LoanAmtYN] [bit] NULL CONSTRAINT [DF__Emp_ED_De__LoanA__353F71CB]  DEFAULT ((0)),
	[LoanAmt] [decimal](17, 2) NULL CONSTRAINT [DF_Emp_ED_Details_LoanAmt]  DEFAULT ((0)),
	[AdvAmtYN] [bit] NULL CONSTRAINT [DF__Emp_ED_De__AdvAm__36339604]  DEFAULT ((0)),
	[AdvAmt] [decimal](17, 2) NULL CONSTRAINT [DF_Emp_ED_Details_AdvAmt]  DEFAULT ((0)),
	[MLWFAmtYN] [bit] NULL CONSTRAINT [DF__Emp_ED_De__MLWFA__3727BA3D]  DEFAULT ((0)),
	[MLWFAmt] [decimal](17, 2) NULL CONSTRAINT [DF_Emp_ED_Details_MLWFAmt]  DEFAULT ((0)),
	[InsAmtYN] [bit] NULL CONSTRAINT [DF_Emp_ED_Details_InsAmtYN]  DEFAULT ((0)),
	[InsAmt] [decimal](17, 2) NULL CONSTRAINT [DF_Emp_ED_Details_InsAmt]  DEFAULT ((0)),
	[VEPFAmtYN] [bit] NULL CONSTRAINT [DF_Emp_Pay_Head_Details_InsAmtYN2]  DEFAULT ((0)),
	[VEPFAmt] [decimal](17, 2) NULL CONSTRAINT [DF_Emp_Pay_Head_Details_InsAmt1]  DEFAULT ((0)),
	[EDLIContrYN] [bit] NULL CONSTRAINT [DF_Emp_Pay_Head_Details_InsAmtYN3]  DEFAULT ((0)),
	[EDLIContr] [decimal](17, 2) NULL CONSTRAINT [DF_Emp_Pay_Head_Details_InsAmt2]  DEFAULT ((0)),
	[GratuityAmtYN] [bit] NULL CONSTRAINT [DF_Emp_Pay_Head_Details_InsAmtYN4]  DEFAULT ((0)),
	[GratuityAmt] [decimal](17, 2) NULL CONSTRAINT [DF_Emp_Pay_Head_Details_InsAmt3]  DEFAULT ((0)),
	[EPSAMTYN] [bit] NULL CONSTRAINT [DF_Emp_Pay_Head_Details_InsAmtYN5]  DEFAULT ((0)),
	[EPSAmt] [decimal](17, 2) NULL CONSTRAINT [DF_Emp_Pay_Head_Details_InsAmt4]  DEFAULT ((0)),
	[EDLIAdChgYN] [bit] NULL CONSTRAINT [DF_Emp_Pay_Head_Details_InsAmtYN1]  DEFAULT ((0)),
	[EDLIAdChg] [decimal](17, 2) NULL CONSTRAINT [DF_Emp_Pay_Head_Details_InsAmt5]  DEFAULT ((0)),
	[PFAdChgYN] [bit] NULL CONSTRAINT [DF_Emp_Pay_Head_Details_EDLIAdChgYN1]  DEFAULT ((0)),	
	[PFAdChg] [decimal](17, 2) NULL CONSTRAINT [DF_Emp_Pay_Head_Details_EDLIAdChg1]  DEFAULT ((0))
	) ON [PRIMARY]
end
