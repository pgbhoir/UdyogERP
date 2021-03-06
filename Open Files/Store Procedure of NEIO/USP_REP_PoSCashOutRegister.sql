DROP PROCEDURE [USP_REP_PoSCashOutRegister]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [USP_REP_PoSCashOutRegister]
as 
Begin
DECLARE @SQLSTR nvarchar(4000)
	SET @SQLSTR =''
	SET @SQLSTR =   'SELECT A.TRAN_CD as ItemTranCd,ItemGrosAmt =ISNULL(SUM(A.gro_amt),0),ItemTaxAmt=ISNULL(sum(A.taxamt),0),
					ItemDiscount=ISNULL(SUM(A.tot_fdisc),0),ItemTotal=ISNULL(SUM(A.gro_amt),0)-ISNULL(sum(A.taxamt),0)-ISNULL(SUM(A.tot_fdisc),0)
					Into ##TmpDcItem FROM DCITEM A INNER JOIN DCMAIN B ON A.TRAN_CD=B.TRAN_CD 					
					WHERE B.entry_ty=''PS''
					GROUP BY B.[USER_NAME],A.TRAN_CD'
	print @SQLSTR
	EXEC SP_EXECUTESQL  @SQLSTR	
	
	SET @SQLSTR =''
	SET @SQLSTR =   'SELECT TRAN_CD,Inv_no,Convert(Varchar,Date,103) as Date,Party_nm,MainTaxAmt=ISNULL(SUM(taxamt),0),
					MainDiscount=ISNULL(SUM(tot_fdisc),0),POSOUTTRAN INTO ##TmpDcMain FROM DCMAIN GROUP BY [USER_NAME],TRAN_CD,inv_no,date,Party_nm,POSOUTTRAN' 
	print @SQLSTR
	EXEC SP_EXECUTESQL  @SQLSTR	
	
	SET @SQLSTR =''
	SET @SQLSTR =   'Select Tran_Cd,Inv_no,Date,Party_nm,GrosAmount=SUM(ItemTotal),TaxAmount=Sum(ItemTaxAmt)+Sum(MainTaxAmt),DiscountAmt=Sum(ItemDiscount)-Sum(MainDiscount),
	     			NetAmount=Sum(ItemTotal)+Sum(ItemTaxAmt)+Sum(MainTaxAmt)+Sum(ItemDiscount)-Sum(MainDiscount),POSOUTTRAN FROM ##TmpDcMain A INNER JOIN ##TmpDcItem B
					ON A.Tran_Cd=B.ItemTranCd GROUP BY Tran_Cd,Inv_no,Date,Party_nm,POSOUTTRAN'
	EXEC SP_EXECUTESQL  @SQLSTR
	
	Drop Table ##TmpDcItem
	Drop Table ##TmpDcMain
End
GO
