DROP PROCEDURE [Usp_Rep_Emp_PT_Payment_Challan]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- AUTHOR:		RUEPESH PRAJAPATI
-- CREATE DATE: 20/04/2009
-- DESCRIPTION:	THIS STORED PROCEDURE IS USEFUL TO GENERATE Employee PT CHALLAN REPORT.
-- MODIFY DATE/BY/Reason:
-- REMARK:
-- =============================================
Create PROCEDURE   [Usp_Rep_Emp_PT_Payment_Challan]
	@ENTRYCOND NVARCHAR(254)
AS
Begin
	Declare @Month varchar(100),@sDate smalldatetime,@eDate  smalldatetime,@Cnt int
	Declare @RangeFrom Decimal(17,2),@RangeTo Decimal(17,2),@Amount Decimal(17,2)
	print 'R'
	SET QUOTED_IDENTIFIER OFF
	DECLARE @SQLCOMMAND NVARCHAR(4000),@FCON AS NVARCHAR(2000),@VSAMT DECIMAL(14,4),@VEAMT DECIMAL(14,4)
	Select Tran_cd into #PTChal1 From CRItem where 1=2
	
		declare @ent varchar(2),@trn int,@pos1 int,@pos2 int,@pos3 int--,@ENTRYCOND NVARCHAR(254)
		if(charindex('m.u_Cldt between',@ENTRYCOND)>0) /*Sp Called from USP_REP_EMP_TDS_CHALLAN_MENU*/
		begin
			set @SQLCOMMAND='insert into #PTChal1 Select Tran_Cd From Bpmain m where Entry_ty=''RH'' and '+@ENTRYCOND
			print @SQLCOMMAND
			execute Sp_ExecuteSql @SQLCOMMAND
		end
		else/*Sp Called from Voucher*/
		Begin
			/*--->Entry_Ty and Tran_Cd Separation*/
			print @ENTRYCOND
			set @pos1=charindex('''',@ENTRYCOND,1)+1
			set @ent= substring(@ENTRYCOND,@pos1,2)
			set @pos2=charindex('=',@ENTRYCOND,charindex('''',@ENTRYCOND,@pos1))+1
			set @pos3=charindex('=',@ENTRYCOND,charindex('''',@ENTRYCOND,@pos2))+1
			set @trn= substring(@ENTRYCOND,@pos2,@pos2-@pos3)
			print 'ent '+ @ent
			print @trn
			insert into #PTChal1 (Tran_cd) values (@trn)
			/*<---Entry_Ty and Tran_Cd Separation*/
		end

	--EXECUTE [Usp_Rep_Emp_PT_Payment_Challan] "A.ENTRY_TY = 'RH' AND A.TRAN_CD =1376 " 
	
	SELECT DISTINCT Part=1,SrNo=3,M.L_YN ,CHALNO=ISNULL(M.U_CHALNO,''),CHALDT=ISNULL(M.U_CHALDT,''),M.CHEQ_NO,M.DATE,BANK_NM=ISNULL(M.BANK_NM,''),m.u_ClDt 
	,PTaxAmt=sum(CASE WHEN A.TYP in ('PT Payable') THEN AC.AMOUNT ELSE 0 END) 
	,DRAWN_ON=ISNULL(M.DRAWN_ON,'') 
	,RangeFrom=cast(0 as Decimal(17,2)),RangeTo=cast(0 as Decimal(17,2)),Amount=cast(0 as Decimal(17,2)),NoEmp=cast(0 as int)
	INTO #PTChal
	FROM BpMain M 
	INNER JOIN BpAcDet AC ON (M.ENTRY_TY=AC.ENTRY_TY AND M.TRAN_CD=AC.TRAN_CD) 
	INNER JOIN AC_MAST A ON (AC.AC_ID=A.AC_ID)
	inner join #PTChal1 tem on (tem.Tran_cd=m.Tran_cd)
	group by M.L_YN ,ISNULL(M.U_CHALNO,''),ISNULL(M.U_CHALDT,''),CHEQ_NO,m.DATE,ISNULL(M.BANK_NM,''),m.u_ClDt,M.DRAWN_ON 

	Select @sDate=min(U_Cldt) From #PTChal
	set @sDate=cast(cast(year(@sDate) as varchar)+'/'+cast(month(@sDate) as varchar)+'/01' as smalldatetime)

	Select @eDate=min(U_Cldt) From #PTChal
	set @eDate=cast(cast(year(@sDate) as varchar)+'/'+cast(month(@sDate) as varchar)+'/'+cast(dbo.funMonthDays(month(@eDate),year(@eDate)) as varchar) as smalldatetime)

	
	Declare cur_slab cursor For 
	Select RangeFrom,RangeTo,Amount from Emp_Pay_Head_Slab_Master where Fld_nm='PTaxAmt' and [State]='Maharashtra' and (@sdate>sDate)
	union  Select max(RangeFrom),max(RangeTo),300 from Emp_Pay_Head_Slab_Master where Fld_nm='PTaxAmt' and [State]='Maharashtra' and (@sdate>sDate)
	open cur_slab 
	set @Cnt=0
	fetch next from cur_slab into @RangeFrom,@RangeTo,@Amount
	while (@@fetch_status=0)
	begin
		set @Cnt=@Cnt+1
		insert into #PTChal(Part,SrNo,CHALNO,CHALDT,CHEQ_NO,DATE,BANK_NM,L_YN,u_Cldt,PTaxAmt,DRAWN_ON,RangeFrom,RangeTo,Amount,NoEmp)
		Select Part=2,SrNo=@Cnt,CHALNO='',CHALDT='',CHEQ_NO='',DATE='',BANK_NM='',L_YN='',u_Cldt='',PTaxAmt=isnull(sum(PTaxAmt),0),DRAWN_ON='',RangeFrom=@RangeFrom,RangeTo=@RangeTo,@Amount,NoEmp=count(EmployeeCode) 
		From Emp_Monthly_Payroll m 
		inner join #PTChal1 tem on (tem.Tran_cd=m.Rh_Trn_cd)
		where PTaxAmt=@Amount
		
		fetch next from cur_slab into @RangeFrom,@RangeTo,@Amount
	end
	Close cur_slab
	DeAllocate cur_slab

	SELECT sDate=@sDate,eDate=@eDate,* FROM #PTChal order by Part,SrNo
end
GO
