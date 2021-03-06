set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go







/*:*****************************************************************************
*:       Program: USP_FINAL_ACCOUNTS
*:        System: UDYOG Software (I) Ltd.
*:    Programmer: RAGHAVENDRA B. JOSHI
*: Last modified: 19/09/2008
*:		AIM		: Maintain Final Acounts reports Like
*:				  [Trial Balance, Profit and Loss Accounts and Balance Sheet]
**:******************************************************************************/
ALTER PROCEDURE [dbo].[Usp_Final_Accounts]
@FDate SMALLDATETIME,@TDate SMALLDATETIME,@C_St_Date SMALLDATETIME,@aa varchar(1)
As
If @FDate IS NULL OR @TDate IS NULL OR @C_St_Date IS NULL
Begin
	RAISERROR ('Please pass valid parameters..',16,1)
	Return 
End
If @FDate = '' OR @TDate = '' OR @C_St_Date = ''
Begin
	RAISERROR ('Please pass valid parameters..',16,1)
	Return 
End

/* Internale Variable declaration and Assigning [Start] */
Declare @Balance Numeric(17,2),@TBLNM VARCHAR(50),@TBLNAME1 Varchar(50),
	@TBLNAME2 Varchar(50),@TBLNAME3 Varchar(50),@TBLNAME4 Varchar(50),
	@SQLCOMMAND as NVARCHAR(4000)

Select @TBLNM = (SELECT substring(rtrim(ltrim(str(RAND( (DATEPART(mm, GETDATE()) * 100000 )
		+ (DATEPART(ss, GETDATE()) * 1000 )+ DATEPART(ms, GETDATE())) , 20,15))),3,20) as No),
		@Balance = 0,@SQLCOMMAND = ''

Select @TBLNAME1 = '##TMP1'+@TBLNM,@TBLNAME2 = '##TMP2'+@TBLNM
Select @TBLNAME3 = '##TMP3'+@TBLNM,@TBLNAME4 = '##TMP4'+@TBLNM
/* Internale Variable declaration and Assigning [End] */

/* Collecting Data from accounts details and create table [Start] */
SET @SQLCOMMAND = 'SELECT AVW.TRAN_CD,AVW.ENTRY_TY,AVW.DATE,AVW.AMOUNT,AVW.AMT_TY,
		MVW.INV_NO,AC_MAST.AC_ID,AC_MAST.[TYPE],AC_MAST.AC_NAME
		INTO '+@TBLNAME1+' FROM LAC_VW AVW (NOLOCK)
		INNER JOIN AC_MAST (NOLOCK) ON AVW.AC_ID = AC_MAST.AC_ID
		INNER JOIN LMAIN_VW MVW (NOLOCK) 
		ON AVW.TRAN_CD = MVW.TRAN_CD AND AVW.ENTRY_TY = MVW.ENTRY_TY
		WHERE (MVW.DATE < = '''+CONVERT(VARCHAR(50),@TDate)+''' )'
EXECUTE sp_executesql @SQLCOMMAND
/* Collecting Data from accounts details and create table [End] */


SET @SQLCOMMAND = 'UPDATE '+@TBLNAME1+' SET AC_NAME = ''OPENING STOCK'', AC_ID=(SELECT AC_ID FROM AC_MAST WHERE AC_NAME = ''OPENING STOCK'') WHERE AC_NAME = ''CLOSING STOCK'' AND [DATE] < '''+CONVERT(VARCHAR(50),@C_St_Date)+''' '
EXECUTE sp_executesql @SQLCOMMAND 

/*Remove Trading and Profit loss Previous Entry [Start]*/
SET @SQLCOMMAND = 'DELETE FROM '+@TBLNAME1+' WHERE CONVERT(VARCHAR(20),TRAN_CD)+''-''+ENTRY_TY IN 
	(SELECT CONVERT(VARCHAR(20),TRAN_CD)+''-''+ENTRY_TY AS COMEID FROM '+@TBLNAME1+' WHERE [TYPE] IN (''T'',''P'') 
	AND [DATE] NOT BETWEEN '''+CONVERT(VARCHAR(50),@C_St_Date)+''' AND '''+CONVERT(VARCHAR(50),@TDate)+''') AND [TYPE] IN (''T'',''P'') '
	
EXECUTE sp_executesql @SQLCOMMAND
/*Remove Trading and Profit loss Previous Entry [End]*/

/* Removing carry-forwarded records [Start] */
SET @SQLCOMMAND = 'DELETE FROM '+@TBLNAME1+' WHERE 
		DATE < (SELECT TOP 1 DATE FROM '+@TBLNAME1+'
		WHERE ENTRY_TY IN (Select Entry_Ty From LCode Where bCode_Nm = ''OB''
		OR Entry_Ty = ''OB'' OR bCode_Nm = ''OS''
		OR Entry_Ty = ''OS'') AND DATE = '''+CONVERT(VARCHAR(50),@C_St_Date)+''')
		AND AC_NAME IN (SELECT AC_NAME FROM '+@TBLNAME1+'
		WHERE ENTRY_TY IN (Select Entry_Ty From LCode Where bCode_Nm = ''OB''
		OR Entry_Ty = ''OB'' OR bCode_Nm = ''OS''
		OR Entry_Ty = ''OS'') AND DATE = '''+CONVERT(VARCHAR(50),@C_St_Date)+''' GROUP BY AC_NAME)'
EXECUTE sp_executesql @SQLCOMMAND

/* Removing carry-forwarded records [End] */
SET @SQLCOMMAND = 'SELECT TRAN_CD=0,ENTRY_TY='' '',
	DATE = '''+CONVERT(VARCHAR(50),@FDate)+''',
	AMOUNT=ISNULL(SUM(CASE WHEN TVW.AMT_TY = ''DR'' THEN TVW.AMOUNT ELSE - TVW.AMOUNT END),0),
	TVW.AC_ID,TVW.AC_NAME,AMT_TY=''A'',INV_NO='' ''
	INTO '+@TBLNAME2+' FROM '+@TBLNAME1+' TVW
	WHERE (TVW.DATE < '''+CONVERT(VARCHAR(50),@FDate)+'''
	OR TVW.ENTRY_TY IN (Select Entry_Ty From LCode Where bCode_Nm = ''OB'' OR Entry_Ty = ''OB'' OR bCode_Nm = ''OS'' OR Entry_Ty = ''OS'')) 
	GROUP BY TVW.AC_ID,TVW.AC_NAME
	UNION
SELECT TVW.TRAN_CD,TVW.ENTRY_TY,TVW.DATE,
	AMOUNT=(CASE WHEN TVW.AMT_TY=''DR'' THEN TVW.AMOUNT ELSE -TVW.AMOUNT END),
	TVW.AC_ID,TVW.AC_NAME,TVW.AMT_TY,TVW.INV_NO
	FROM '+@TBLNAME1+' TVW
	LEFT JOIN LAC_VW LVW (NOLOCK) 
	ON TVW.TRAN_CD = LVW.TRAN_CD AND TVW.ENTRY_TY = LVW.ENTRY_TY AND TVW.AC_ID != LVW.AC_ID
	WHERE (TVW.DATE BETWEEN '''+CONVERT(VARCHAR(50),@FDate)+''' AND '''+CONVERT(VARCHAR(50),@TDate)+''' AND 
	TVW.ENTRY_TY NOT IN (Select Entry_Ty From LCode Where bCode_Nm = ''OB'' OR Entry_Ty = ''OB'' OR bCode_Nm = ''OS'' OR Entry_Ty = ''OS''))'
EXECUTE sp_executesql @SQLCOMMAND


SET @SQLCOMMAND = 'SELECT a.Ac_id,
	Opening = isnull(CASE Amt_Ty WHEN ''A'' THEN SUM(a.Amount)END,0),
	Debit = isnull(CASE Amt_Ty WHEN ''DR'' THEN SUM(a.Amount)END,0),
	Credit = isnull(CASE Amt_Ty WHEN ''CR'' THEN SUM(a.Amount) END,0)
	Into '+@TBLNAME3+' from '+@TBLNAME2+' a
	group by a.Ac_id,a.amt_ty'
EXECUTE sp_executesql @SQLCOMMAND


SET @SQLCOMMAND = 'SELECT b.Ac_id,Sum(a.Opening) as OpBal,Sum(a.Debit) as Debit,
	Sum(a.Credit) as Credit,CAST(0 AS Numeric(17,2)) As ClBal
	Into '+@TBLNAME4+' from '+@TBLNAME3+' a Right Join Ac_Mast b 
	ON (b.Ac_id = a.Ac_id) group by b.Ac_id'
EXECUTE sp_executesql @SQLCOMMAND


SET @SQLCOMMAND = 'Update '+@TBLNAME4+' SET OPbal = (CASE WHEN OpBal IS NULL THEN 0 ELSE OPBAL END),
	Debit = (CASE WHEN Debit IS NULL THEN 0 ELSE Debit END),
	Credit = (CASE WHEN Credit IS NULL THEN 0 ELSE Credit END),
	Clbal = (CASE WHEN Clbal IS NULL THEN 0 ELSE Clbal END)'
EXECUTE sp_executesql @SQLCOMMAND


/* Combined Groups And Ledgers with Opening,Debit,Credit[Start] */
SET @SQLCOMMAND = 'Select Updown,''G'' As MainFlg,Ac_Group_Id as Ac_Id,gAC_id as Ac_Group_Id,AC_GROUP_NAME+space(100) as Ac_Name,[Group],
	CAST(0 AS Numeric(17,2)) As OpBal,CAST(0 AS Numeric(17,2)) As Debit,CAST(0 AS Numeric(17,2)) As Credit,CAST(0 AS Numeric(17,2)) As ClBal
	From Ac_Group_Mast
Union All 
Select Updown,''L'' As MainFlg,b.Ac_Id,b.Ac_Group_Id,b.Ac_Name+space(100), b.[Group],
	a.OpBal,a.Debit,ABS(a.Credit),(a.OpBal+a.Debit-ABS(a.Credit)) as ClBal
	From '+@TBLNAME4+' a Right Join Ac_Mast b ON (b.Ac_id = a.Ac_id)'
EXECUTE sp_executesql @SQLCOMMAND
/* Combined Groups And Ledgers [End] */

/* Droping Temp tables [Start] */
SET @SQLCOMMAND = 'Drop table '+@TBLNAME1
EXECUTE sp_executesql @SQLCOMMAND
SET @SQLCOMMAND = 'Drop table '+@TBLNAME2
EXECUTE sp_executesql @SQLCOMMAND
SET @SQLCOMMAND = 'Drop table '+@TBLNAME3
EXECUTE sp_executesql @SQLCOMMAND
SET @SQLCOMMAND = 'Drop table '+@TBLNAME4
EXECUTE sp_executesql @SQLCOMMAND
/* Droping Temp tables [End] */






