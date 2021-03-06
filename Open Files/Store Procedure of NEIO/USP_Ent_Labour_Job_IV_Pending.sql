DROP PROCEDURE [USP_Ent_Labour_Job_IV_Pending]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Shrikant S. 
-- Create date: 21/03/2011
-- Description:	This Stored procedure is useful to generate Excise Annexure IV for Labour Job Pending Stock.
-- Modification Date/By/Reason: 
-- Remark:
-- =============================================
Create PROCEDURE [USP_Ent_Labour_Job_IV_Pending] 
@SDATE  SMALLDATETIME
AS

Set NoCount On
SELECT IIITEM.DATE,IIMAIN.INV_NO,IIITEM.ITSERIAL,IIITEM.ENTRY_TY,IIITEM.TRAN_CD,IIITEM.PARTY_NM,IIITEM.QTY,IIITEM.INV_SR,IIITEM.AC_ID
,QTY_USED=IIITEM.QTY,WASTAGE=IIITEM.QTY,RANGE='',DIVISION='',IT_MAST.CHAPNO,IT_MAST.P_UNIT,IT_MAST.IT_NAME
,It_Desc=(CASE WHEN ISNULL(it_mast.it_alias,'')='' THEN it_mast.it_name ELSE it_mast.it_alias END)
,MailName=(CASE WHEN ISNULL(Ac_mast.MailName,'')='' THEN Ac_mast.ac_name ELSE Ac_mast.mailname END)
,IRITEM.IT_CODE LR_ITCODE,IRITEM.QTY LR_QTY, IRITEM.DATE LR_DATE,BALQTY=IIITEM.QTY-(isnull(IRRMDET.QTY_USED,0)+isnull(IRRMDET.WASTAGE,0)),LR_ACMAST.AC_NAME
,FITEM=(CASE WHEN ISNULL(LR_ITMAST.it_alias,'')='' THEN LR_ITMAST.it_name ELSE LR_ITMAST.it_alias END)
,FQTY=IRITEM.QTY
,PDAYS=DATEDIFF(DAY,IIITEM.DATE,'Oct  8 2009 12:00AM' ),IIITEM.RATE,IIITEM.IT_CODE,IIMAIN.DOC_NO,IIMAIN.[RULE],IIITEM.WARE_NM
,IIMAIN.CONS_ID
INTO #PENDCHALL
FROM IIITEM  
INNER JOIN IIMAIN ON  (IIITEM.TRAN_CD=IIMAIN.TRAN_CD)  
INNER JOIN AC_MAST ON (AC_MAST.AC_ID=IIITEM.AC_ID)  
INNER JOIN IT_MAST ON (IIITEM.IT_CODE=IT_MAST.IT_CODE)  
LEFT JOIN IRRMDET ON (IIITEM.TRAN_CD=IRRMDET.LI_TRAN_CD AND IIITEM.ENTRY_TY=IRRMDET.LIENTRY_TY AND IIITEM.ITSERIAL=IRRMDET.LI_ITSER)  
LEFT JOIN IRMAIN ON (IRRMDET.TRAN_CD=IRMAIN.TRAN_CD)  
LEFT JOIN IRITEM ON (IRRMDET.TRAN_CD=IRITEM.TRAN_CD AND IRITEM.ENTRY_TY=IRRMDET.ENTRY_TY AND IRRMDET.ITSERIAL=IRITEM.ITSERIAL)  
LEFT JOIN AC_MAST LR_ACMAST ON (LR_ACMAST.AC_ID=IRITEM.AC_ID)  
LEFT JOIN IT_MAST LR_ITMAST ON (LR_ITMAST.IT_CODE=IRITEM.IT_CODE)  
WHERE 1=2


DECLARE @SQLCOMMAND NVARCHAR(4000)
SET @SQLCOMMAND=' INSERT INTO #PENDCHALL SELECT IIITEM.DATE,IIMAIN.INV_NO,IIITEM.ITSERIAL,   IIITEM.ENTRY_TY,IIITEM.TRAN_CD,PARTY_NM=AC_MAST.AC_NAME,IIITEM.QTY,IIITEM.INV_SR,IIITEM.AC_ID,'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' QTY_USED=CASE WHEN IRRMDET.DATE<='+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+' THEN isnull(IRRMDET.QTY_USED,0) ELSE 0 END,WASTAGE=CASE WHEN IRRMDET.DATE<='+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+' THEN isnull(IRRMDET.WASTAGE,0) ELSE 0 END, ' 
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' AC_MAST.RANGE,AC_MAST.DIVISION, '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' IT_MAST.CHAPNO,IT_MAST.P_UNIT, IT_MAST.IT_NAME,'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' It_Desc=(CASE WHEN ISNULL(it_mast.it_alias,'''')='''' THEN it_mast.it_name ELSE it_mast.it_alias END),'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' MailName=(CASE WHEN ISNULL(Ac_mast.MailName,'''')='''' THEN Ac_mast.ac_name ELSE Ac_mast.mailname END),'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' IRITEM.IT_CODE LR_ITCODE,LR_QTY=CASE WHEN IRRMDET.DATE<='+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+' THEN ISNULL(IRITEM.QTY,0) ELSE 0 END , IRITEM.DATE LR_DATE,'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' BALQTY=IIITEM.QTY-(CASE WHEN IRRMDET.DATE<='+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+' THEN isnull(IRRMDET.QTY_USED,0) ELSE 0 END+CASE WHEN IRRMDET.DATE<='+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+' THEN isnull(IRRMDET.WASTAGE,0) ELSE 0 END),' 
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' LR_ACMAST.AC_NAME,'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' FITEM=(CASE WHEN ISNULL(LR_ITMAST.it_alias,'''')='''' THEN LR_ITMAST.it_name ELSE LR_ITMAST.it_alias END),'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' FQTY=CASE WHEN IRRMDET.DATE<='+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+' THEN ISNULL(IRITEM.QTY,0) ELSE 0 END ' --Added by Shrikant S. on 13 Apr, 2010 for TKT-968
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' ,PDAYS=DATEDIFF(DAY,IIITEM.DATE,'+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+' ),IIITEM.RATE,IIITEM.IT_CODE,IIMAIN.DOC_NO,IIMAIN.[RULE],IIITEM.WARE_NM'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' ,IIMAIN.CONS_ID'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' FROM IIITEM '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' INNER JOIN IIMAIN ON  (IIITEM.TRAN_CD=IIMAIN.TRAN_CD) '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' INNER JOIN AC_MAST ON (AC_MAST.AC_ID=IIITEM.AC_ID) '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' INNER JOIN IT_MAST ON (IIITEM.IT_CODE=IT_MAST.IT_CODE) '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' LEFT JOIN IRRMDET ON (IIITEM.TRAN_CD=IRRMDET.LI_TRAN_CD AND IIITEM.ENTRY_TY=IRRMDET.LIENTRY_TY AND IIITEM.ITSERIAL=IRRMDET.LI_ITSER AND IRRMDET.DATE<='+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+') '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' LEFT JOIN IRMAIN ON (IRRMDET.TRAN_CD=IRMAIN.TRAN_CD) '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' LEFT JOIN IRITEM ON (IRRMDET.TRAN_CD=IRITEM.TRAN_CD AND IRITEM.ENTRY_TY=IRRMDET.ENTRY_TY AND IRRMDET.ITSERIAL=IRITEM.ITSERIAL)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' LEFT JOIN AC_MAST LR_ACMAST ON (LR_ACMAST.AC_ID=IRITEM.AC_ID)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' LEFT JOIN IT_MAST LR_ITMAST ON (LR_ITMAST.IT_CODE=IRITEM.IT_CODE)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'WHERE IIMAIN.ENTRY_TY=''LI'' AND IIMAIN.DATE <='++CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' ORDER BY Mailname,IIITEM.DATE,IIMAIN.INV_NO,IIITEM.ITSERIAL ' 
--print @SQLCOMMAND
EXEC SP_EXECUTESQL  @SQLCOMMAND

select Date,Inv_no,Itserial,Entry_ty,Tran_cd,Party_nm,Qty,inv_sr,ac_id,
qty_used=sum(Qty_used+WASTAGE),p_Unit,It_Name,BalQty=Qty-sum(Qty_used+WASTAGE),Rate,It_Code,DOC_NO,[rule],WARE_NM,CONS_ID
Into #PENDCHALL1 from #PENDCHALL 
Group By Date,Inv_no,Itserial,Entry_ty,Tran_cd,Party_nm,Qty,inv_sr,ac_id,p_Unit,It_Name,Rate,It_Code,DOC_NO,[rule],WARE_NM,CONS_ID

SELECT QTY,LIENTRY_TY,LI_TRAN_CD,LI_ITSER,QTY_USED=SUM(QTY_USED+WASTAGE) 
INTO #QTYUSED
FROM IRRMDET 
WHERE LI_DATE<=@SDATE 
AND DATE<=@SDATE 
GROUP BY LIENTRY_TY,LI_TRAN_CD,LI_ITSER,QTY

DELETE FROM #QTYUSED WHERE QTY<>QTY_USED

DELETE FROM #PENDCHALL1 WHERE ENTRY_TY+RTRIM(CAST(TRAN_CD AS VARCHAR))+ITSERIAL IN (SELECT LIENTRY_TY+RTRIM(CAST(LI_TRAN_CD AS VARCHAR))+LI_ITSER FROM #QTYUSED)

Declare @Entry_ty Varchar(2),@fld_nm Varchar(20),@att_file Bit,@fld_lst Varchar(2000)
set @fld_lst=''
Declare LotherCursor Cursor for
Select E_code,fld_nm,att_file from Lother Where E_code='LI' 
Open LotherCursor 
Fetch Next from LotherCursor Into @Entry_ty, @fld_nm, @att_file 
While @@Fetch_Status=0
Begin
	if @att_file=1
		set @fld_lst=@fld_lst+',IIMain.'+rtrim(@fld_nm)	
	else
		set @fld_lst=@fld_lst+',IIItem.'+rtrim(@fld_nm)	
	Fetch Next from LotherCursor Into @Entry_ty, @fld_nm, @att_file 
End
Close LotherCursor 
Deallocate LotherCursor 

SET @SQLCOMMAND='SELECT a.*,iimain.l_yn '+@fld_lst+' FROM #PENDCHALL1 a'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'Inner Join IIItem on (IIItem.Entry_ty=a.Entry_ty and IIItem.Tran_cd=a.Tran_cd and IIItem.Itserial=a.Itserial) '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'Inner Join IIMain on (IiMain.Entry_ty=IIItem.Entry_ty and IiMain.Tran_cd=IIItem.Tran_cd)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'ORDER BY a.DATE,a.INV_NO,a.ITSERIAL'
EXEC SP_EXECUTESQL  @SQLCOMMAND

DROP TABLE #PENDCHALL
DROP TABLE #PENDCHALL1
DROP TABLE #QTYUSED
GO
