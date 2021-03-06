If Exists(Select [name] From SysObjects Where xtype='P' and [Name]='USP_REP_GJ_CST_ANNE_II')
Begin
	Drop Procedure USP_REP_GJ_CST_ANNE_II
End
GO
-- =============================================
-- Author:		Sandeep Shah
-- Create date: 19-02-2014
-- Description:	This Stored procedure is useful to generate CST- PURCHASE_DETAILS
-- Modify by/date/reason: sandeep/bug-21701 21-02-14 (added u_pinvno,u_pinvdt columns)
-- Modify by: Changes has been done by Gaurav Tanna on 29/11/2014 for BUG-24839
-- Remark:
-- =============================================
CREATE PROCEDURE [dbo].[USP_REP_GJ_CST_ANNE_II]
@TMPAC NVARCHAR(50),@TMPIT NVARCHAR(50),@SPLCOND VARCHAR(8000),@SDATE  SMALLDATETIME,@EDATE SMALLDATETIME
,@SAC AS VARCHAR(60),@EAC AS VARCHAR(60)
,@SIT AS VARCHAR(60),@EIT AS VARCHAR(60)
,@SAMT FLOAT,@EAMT FLOAT
,@SDEPT AS VARCHAR(60),@EDEPT AS VARCHAR(60)
,@SCATE AS VARCHAR(60),@ECATE AS VARCHAR(60)
,@SWARE AS VARCHAR(60),@EWARE AS VARCHAR(60)
,@SINV_SR AS VARCHAR(60),@EINV_SR AS VARCHAR(60)
,@LYN VARCHAR(20)
,@EXPARA  AS VARCHAR(60)= NULL
AS
DECLARE @FCON AS NVARCHAR(2000)
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
,@VMAINFILE='M',@VITFILE='I',@VACFILE=' '
,@VDTFLD ='DATE'
,@VLYN=@LYN
,@VEXPARA=NULL
,@VFCON =@FCON OUTPUT

DECLARE @SQLCOMMAND NVARCHAR(4000),@VCOND NVARCHAR(1000)
Declare @MultiCo	VarChar(3)
Declare @MCON as NVARCHAR(2000)
IF Exists(Select A.ID From SysObjects A Inner Join SysColumns B On(A.ID = B.ID) Where A.[Name] = 'PTMAIN' And B.[Name] = 'DBNAME')
	Begin	------Fetch Records from Multi Co. Data
		Set @MultiCo = 'YES'

		-- Gaurav - start here for Bug 24839
		--SET @SQLCOMMAND='SELECT M.ENTRY_TY,M.TRAN_CD,INV_NO=M.U_PINVNO,DATE=M.U_PINVDT,AC_MAST.AC_NAME,AC_MAST.S_TAX,IT_MAST.IT_NAME,IT_MAST.HSNCODE,M.TAX_NAME,M.GRO_AMT,M.NET_AMT,TAXABLEAMOUNT=(CASE WHEN l.stax_item=1 then ((I.U_asseamt+I.tot_examt)+I.TOT_TAX+I.TOT_ADD)else (m.GRO_AMT-m.TOT_DEDUC)+m.TOT_TAX+m.TOT_ADD end) ,taxamt=(CASE WHEN l.stax_item=1 then (I.TAXAMT) else m.taxamt end ),st.form_nm'
		SET @SQLCOMMAND='SELECT M.ENTRY_TY,M.TRAN_CD,INV_NO=M.U_PINVNO,DATE=M.U_PINVDT,AC_MAST.AC_NAME,AC_MAST.C_TAX,AC_MAST.STATE,IT_MAST.IT_NAME,IT_MAST.HSNCODE,M.TAX_NAME,M.GRO_AMT,M.NET_AMT,TAXABLEAMOUNT= (I.gro_amt-I.Taxamt-I.addlvat1),taxamt=(I.TAXAMT),st.form_nm'
		-- Gaurav - end here for Bug 24839
		
		set @sqlcommand=@sqlcommand+' '+',case when isnull(Ac_Mast.mailname,'''') = '''' then Ac_Mast.ac_name else Ac_Mast.mailname end as mailname' 
		set @sqlcommand=@sqlcommand+' '+',case when isnull(cast(it_mast.it_desc as varchar),'''') = '''' then it_mast.it_name else it_mast.it_desc end as it_desc ' 
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ ' FROM PTMAIN M INNER JOIN AC_MAST ON (M.AC_ID=AC_MAST.AC_ID AND M.DBNAME=AC_MAST.DBNAME)'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ ' INNER JOIN PTITEM I ON (M.TRAN_CD=I.TRAN_CD AND M.DBNAME = I.DBNAME)'		
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ ' inner join LCODE l on (l.Entry_ty=I.entry_ty AND I.DBNAME = IT_MAST.DBNAME)'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ ' left join stax_mas st on (st.Entry_ty=I.entry_ty and st.tax_name=i.tax_name  AND st.DBNAME = IT_MAST.DBNAME)'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON)
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' AND M.TAXAMT<>0  and ac_mast.c_tax<>'' '' AND st.form_nm<>'' '' AND ac_mast.st_type = ''OUT OF STATE'''
	End
Else
	Begin	------Fetch Records from Single Co. Data
		Set @MultiCo = 'NO'

		-- Gaurav - start here for Bug 24839
		--SET @SQLCOMMAND='SELECT M.ENTRY_TY,M.TRAN_CD,INV_NO=M.U_PINVNO,DATE=M.U_PINVDT,AC_MAST.AC_NAME,AC_MAST.S_TAX,IT_MAST.IT_NAME,IT_MAST.HSNCODE,M.TAX_NAME,M.GRO_AMT,M.NET_AMT,TAXABLEAMOUNT=(CASE WHEN l.stax_item=1 then ((I.U_asseamt+I.tot_examt)+I.TOT_TAX+I.TOT_ADD) else (m.GRO_AMT-m.TOT_DEDUC)+m.TOT_TAX+m.TOT_ADD end) ,taxamt=(CASE WHEN l.stax_item=1 then (I.TAXAMT) else m.taxamt end ),st.form_nm'--,additinaltax=(CASE WHEN l.stax_item=1 then (I.addlvat1) end ) '
		SET @SQLCOMMAND='SELECT M.ENTRY_TY,M.TRAN_CD,INV_NO=M.U_PINVNO,DATE=M.U_PINVDT,AC_MAST.AC_NAME,AC_MAST.STATE,AC_MAST.C_TAX,IT_MAST.IT_NAME,IT_MAST.HSNCODE,M.TAX_NAME,M.GRO_AMT,M.NET_AMT,TAXABLEAMOUNT=(I.gro_amt-I.Taxamt-I.addlvat1),taxamt=(I.TAXAMT),st.form_nm'--,additinaltax=(CASE WHEN l.stax_item=1 then (I.addlvat1) end ) '
		-- Gaurav - end here for Bug 24839
		
		set @sqlcommand=@sqlcommand+' '+',case when isnull(Ac_Mast.mailname,'''') = '''' then Ac_Mast.ac_name else Ac_Mast.mailname end as mailname' 
		set @sqlcommand=@sqlcommand+' '+',case when isnull(cast(it_mast.it_desc as varchar),'''') = '''' then it_mast.it_name else it_mast.it_desc end as it_desc ' 
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ ' FROM PTMAIN M INNER JOIN AC_MAST ON (M.AC_ID=AC_MAST.AC_ID)'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ ' INNER JOIN PTITEM I ON (M.TRAN_CD=I.TRAN_CD)'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ ' INNER JOIN IT_MAST  ON (I.IT_CODE=IT_MAST.IT_CODE)'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ ' inner join LCODE l on (l.Entry_ty=I.entry_ty) '		
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ ' left join stax_mas st on (st.Entry_ty=I.entry_ty and st.tax_name=i.tax_name)'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON)
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' AND M.TAXAMT<>0  and ac_mast.c_tax<>'' '' AND st.form_nm<>'' '' AND ac_mast.st_type = ''OUT OF STATE'''
	End
	

--PRINT @SQLCOMMAND
EXECUTE SP_EXECUTESQL @SQLCOMMAND
