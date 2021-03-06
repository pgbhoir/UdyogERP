If Exists(Select [name] From SysObjects Where xtype='P' and [Name]='USP_REP_GJFORM201A')
Begin
	Drop Procedure USP_REP_GJFORM201A
End
GO
-- =============================================
-- Author:		Hetal L Patel
-- Create date: 16/05/2007
-- Description:	This Stored procedure is useful to generate GJ VAT FORM 201A
-- Modify date: 16/05/2007
-- Modified By: Birendra on 24/07/2010 for TKT-3120
-- Modify by/date/reason: sandeep/19-02-2014 for bug-21822 
-- Modified By: Changes has been done by Gaurav Tanna on 28/11/2014 for BUG-24831

-- Remark:
-- ============================================= 
CREATE Procedure [dbo].[USP_REP_GJFORM201A]
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
IF Exists(Select A.ID From SysObjects A Inner Join SysColumns B On(A.ID = B.ID) Where A.[Name] = 'STMAIN' And B.[Name] = 'DBNAME')
	Begin	------Fetch Records from Multi Co. Data
		Set @MultiCo = 'YES'
																																																							
		-- Gaurav - start here for Bug 24831
		--SET @SQLCOMMAND='SELECT M.ENTRY_TY,M.TRAN_CD,M.INV_NO,M.DATE,AC_MAST.AC_NAME,AC_MAST.S_TAX,IT_MAST.IT_NAME,IT_MAST.HSNCODE,M.FORM_NM,M.TAX_NAME,M.GRO_AMT,M.NET_AMT,TAXABLEAMOUNT=(CASE WHEN l.stax_item=1 then ((I.U_asseamt+I.tot_examt)+I.TOT_TAX+I.TOT_ADD) else (m.GRO_AMT-m.TOT_DEDUC)+m.TOT_TAX+m.TOT_ADD end) ,taxamt=(CASE WHEN l.stax_item=1 then (I.TAXAMT) else m.taxamt end ),additinaltax=(CASE WHEN l.stax_item=1 then (I.addlvat1) end )'--Change by sandeep/19-02-2014 for bug-21822 
		--SET @SQLCOMMAND='SELECT M.ENTRY_TY,M.TRAN_CD,M.INV_NO,M.DATE,AC_MAST.AC_NAME,AC_MAST.S_TAX,IT_MAST.IT_NAME,IT_MAST.HSNCODE,M.FORM_NM,M.TAX_NAME,M.GRO_AMT,M.NET_AMT,TAXABLEAMOUNT=(CASE WHEN l.stax_item=1 then round(I.u_asseamt+I.EXAMT+I.U_CESSAMT+I.U_HCESAMT+I.tot_add+I.TOT_DEDUC,2) else round(((M.gro_amt+M.tot_add+M.tot_tax)-M.tot_deduc),2) end) ,taxamt=(CASE WHEN l.stax_item=1 then (I.TAXAMT) else m.taxamt end ),additinaltax=(CASE WHEN l.stax_item=1 then (I.addlvat1) end )'--Change by sandeep/19-02-2014 for bug-21822 
		SET @SQLCOMMAND='SELECT M.ENTRY_TY,M.TRAN_CD,M.INV_NO,M.DATE,AC_MAST.AC_NAME,AC_MAST.S_TAX,IT_MAST.IT_NAME,IT_MAST.HSNCODE,M.FORM_NM,M.TAX_NAME,M.GRO_AMT,M.NET_AMT,TAXABLEAMOUNT=(I.gro_amt-I.Taxamt-I.addlvat1),taxamt=(I.TAXAMT),additinaltax=(I.addlvat1)'
		-- Gaurav - end here for Bug 24831
		
		--Start : Added by Birendra on 24 july 2010 for TKT-3120
		set @sqlcommand=@sqlcommand+' '+',case when isnull(Ac_Mast.mailname,'''') = '''' then Ac_Mast.ac_name else Ac_Mast.mailname end as mailname' 
		set @sqlcommand=@sqlcommand+' '+',case when isnull(cast(it_mast.it_desc as varchar),'''') = '''' then it_mast.it_name else it_mast.it_desc end as it_desc ' 
		--End : Added by Birendra on 24 july 2010 for TKT-3120
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ ' FROM STMAIN M INNER JOIN AC_MAST ON (M.AC_ID=AC_MAST.AC_ID AND M.DBNAME=AC_MAST.DBNAME)'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ ' INNER JOIN STITEM I ON (M.TRAN_CD=I.TRAN_CD AND M.DBNAME = I.DBNAME)'		
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ ' inner join LCODE l on (l.Entry_ty=I.entry_ty AND I.DBNAME = IT_MAST.DBNAME)'		
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON)
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' AND M.TAXAMT<>0  And AC_MAST.St_Type = ''Local'' and ac_mast.s_tax<>'' '''
	End
Else
	Begin	------Fetch Records from Single Co. Data
		Set @MultiCo = 'NO'

		-- Gaurav - start here for Bug 24831
		--SET @SQLCOMMAND='SELECT M.ENTRY_TY,M.TRAN_CD,M.INV_NO,M.DATE,AC_MAST.AC_NAME,AC_MAST.S_TAX,IT_MAST.IT_NAME,IT_MAST.HSNCODE,M.FORM_NM,M.TAX_NAME,M.GRO_AMT,M.NET_AMT,TAXABLEAMOUNT=(CASE WHEN l.stax_item=1 then ((I.U_asseamt+I.tot_examt)+I.TOT_TAX+I.TOT_ADD)else (m.GRO_AMT-m.TOT_DEDUC)+m.TOT_TAX+m.TOT_ADD end) ,taxamt=(CASE WHEN l.stax_item=1 then (I.TAXAMT) else m.taxamt end ),additinaltax=(CASE WHEN l.stax_item=1 then (I.addlvat1) end ) '--Change by sandeep/19-02-2014 for bug-21822 
		--SET @SQLCOMMAND='SELECT M.ENTRY_TY,M.TRAN_CD,M.INV_NO,M.DATE,AC_MAST.AC_NAME,AC_MAST.S_TAX,IT_MAST.IT_NAME,IT_MAST.HSNCODE,M.FORM_NM,M.TAX_NAME,M.GRO_AMT,M.NET_AMT,TAXABLEAMOUNT=(CASE WHEN l.stax_item=1 then round(I.u_asseamt+I.EXAMT+I.U_CESSAMT+I.U_HCESAMT+I.tot_add+I.TOT_DEDUC,2) else round(((M.gro_amt+M.tot_add+M.tot_tax)-M.tot_deduc),2) end) ,taxamt=(CASE WHEN l.stax_item=1 then (I.TAXAMT) else m.taxamt end ),additinaltax=(CASE WHEN l.stax_item=1 then (I.addlvat1) end ) '--Change by sandeep/19-02-2014 for bug-21822 
		SET @SQLCOMMAND='SELECT M.ENTRY_TY,M.TRAN_CD,M.INV_NO,M.DATE,AC_MAST.AC_NAME,AC_MAST.S_TAX,IT_MAST.IT_NAME,IT_MAST.HSNCODE,M.FORM_NM,M.TAX_NAME,M.GRO_AMT,M.NET_AMT,TAXABLEAMOUNT=(I.gro_amt-I.Taxamt-I.addlvat1),taxamt=(I.TAXAMT),additinaltax=(I.addlvat1) '
			
		-- Gaurav - end here for Bug 24831
		
		
		--Start : Added by Birendra on 24 july 2010 for TKT-3120
		set @sqlcommand=@sqlcommand+' '+',case when isnull(Ac_Mast.mailname,'''') = '''' then Ac_Mast.ac_name else Ac_Mast.mailname end as mailname' 
		set @sqlcommand=@sqlcommand+' '+',case when isnull(cast(it_mast.it_desc as varchar),'''') = '''' then it_mast.it_name else it_mast.it_desc end as it_desc ' 
		--End : Added by Birendra on 24 july 2010 for TKT-3120
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ ' FROM STMAIN M INNER JOIN AC_MAST ON (M.AC_ID=AC_MAST.AC_ID)'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ ' INNER JOIN STITEM I ON (M.TRAN_CD=I.TRAN_CD)'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ ' INNER JOIN IT_MAST  ON (I.IT_CODE=IT_MAST.IT_CODE)'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ 'inner join LCODE l on (l.Entry_ty=I.entry_ty) '		
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON)
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' AND M.TAXAMT<>0 And AC_MAST.St_Type = ''Local'' and ac_mast.s_tax<>'' '''
	End
	

--PRINT @SQLCOMMAND
EXECUTE SP_EXECUTESQL @SQLCOMMAND
--Print 'GJ VAT FORM 201A'
