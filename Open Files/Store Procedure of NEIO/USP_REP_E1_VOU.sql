DROP PROCEDURE [USP_REP_E1_VOU]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [USP_REP_E1_VOU]
	@ENTRYCOND NVARCHAR(254)
	AS
	
Declare @SQLCOMMAND NVARCHAR(max),@TBLCON NVARCHAR(max),@SQLCOMMAND1 NVARCHAR(max),@ParmDefinition NVARCHAR(max),@SQLCOMMAND2 NVARCHAR(max)
Declare @chapno varchar(30),@eit_name  varchar(100),@mchapno varchar(250),@meit_name  varchar(250),@Tot_flds Varchar(4000),@QueryString NVarchar(max)
	
	SET @TBLCON=RTRIM(@ENTRYCOND)

--ruchit

declare @ITAddLess varchar(500),@NonTaxIT varchar(500),@HeaderDisc varchar(500),@HeaderTAX nvarchar(max),@HeaderNTX nvarchar(max),@ItemTaxable nvarchar(max),@ItemNTX nvarchar(max),@ItemAddl nvarchar(max),@GSTReceivable nvarchar(max)
--itemwise 
SELECT 
    @ITAddLess = isnull(STUFF(
                 (SELECT Case when a_s<>'' then a_s else (case when code in( 'D','F') THEN '-' else '+' end ) end + fld_nm FROM Dcmast where code in( 'D','F') and att_file=0 and Entry_ty='E1'  FOR XML PATH ('')), 1, 0, ''
               ),0)
--itemwise taxable and non taxable
SELECT 
    @ItemTaxable = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code='T' and att_file=0 and Entry_ty='E1' and fld_nm not in ('staxamt') FOR XML PATH ('')), 1, 0, ''
                 --(select case when fld_nm<>'' then '+'+fld_nm else ''  end from dcmast where code='T' and att_file=0 and entry_ty='PT' and bef_aft=2  FOR XML PATH ('')), 1, 0, ''
               ),0)
               
               
               
SELECT 
    @ItemNTX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=0 and Entry_ty='E1' and fld_nm not in  ('CGSRT_AMT','SGSRT_AMT','IGSRT_AMT') FOR XML PATH ('')), 1, 0, ''
               ),0)     

--and fld_nm not in ('CGSRT_AMT','SGSRT_AMT','IGSRT_AMT')           
SELECT 
    @GSTReceivable = isnull(STUFF(
                 (SELECT  '+EPITEM.'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=0 and Entry_ty='E1' and fld_nm in ('CGSRT_AMT','SGSRT_AMT','IGSRT_AMT','FCCGSRT_AM','FCSGSRT_AM','FCIGSRT_AM')/*and bef_aft=2*/  FOR XML PATH ('')), 1, 0, ''
               ),0)
--itemwise non tax

--headerwise disc
SELECT 
    @HeaderDisc = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('D','F') and att_file=1  and Entry_ty='E1'  FOR XML PATH ('')), 1, 0, ''
               ),0)

--headerwise taxable chargs
SELECT 
    @HeaderTAX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code='T' and att_file=1 and Entry_ty='E1'  FOR XML PATH ('')), 1, 0, ''
               ),0)


--headerwise non taxable chargs
SELECT 
    @HeaderNTX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=1 and Entry_ty='E1'  FOR XML PATH ('')), 1, 0, ''
               ),0)
--ruchit

Select Entry_ty,Tran_cd=0,inv_no,itserial=space(6) Into #EPMAIN from EPMAIN Where 1=0
	Create NonClustered Index Idx_tmpEPMAIN On #EPMAIN (Entry_ty asc, Tran_cd Asc, Itserial asc)

set @sqlcommand='Insert Into #EPMAIN Select EPMAIN.Entry_ty,EPMAIN.Tran_cd,EPMAIN.inv_no,EPITEM.itserial from EPMAIN Inner Join EPITEM on (EPMAIN.Entry_ty=EPITEM.Entry_ty and EPMAIN.Tran_cd=EPITEM.Tran_cd) Where '+@TBLCON
print @sqlcommand
execute sp_executesql @sqlcommand
print '1'	
SET @QueryString = ''		
SET @QueryString =@QueryString+'SELECT EPMAIN.INV_SR,EPMAIN.TRAN_CD,EPMAIN.ENTRY_TY,EPMAIN.INV_NO,EPMAIN.DATE,EPMAIN.DUE_DT,
EPMAIN.GRO_AMT GRO_AMT1,EPMAIN.NET_AMT,EPMAIN.SLIPNO,EPMAIN.TOT_NONTAX,
EPMAIN.TOT_TAX,EPMAIN.TOT_DEDUC,EPMAIN.CGST_AMT,EPMAIN.SGST_AMT,EPMAIN.IGST_AMT,
CONVERT(VARCHAR(254),EPMAIN.NARR) AS NARR,EPMAIN.USER_NAME,EPITEM.GRO_AMT,EPITEM.ITEM_NO,
EPITEM.QTY,EPITEM.RATE,EPITEM.U_ASSEAMT,IT_MAST.IT_NAME AS ITEM,
It_Desc=(CASE WHEN ISNULL(it_mast.it_alias,'''')='''' THEN it_mast.it_name ELSE it_mast.it_alias END),
MailName=(CASE WHEN EPMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.MailName,'''')='''' THEN AC_MAST.mailname ELSE SHIPTO.mailname END) ELSE AC_MAST.mailname END),
IT_MAST.[GROUP],IT_MAST.EIT_NAME,IT_MAST.CHAPNO,IT_MAST.RATEUNIT
,AC_NAME=(CASE WHEN EPMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.MailName,'''')='''' THEN AC_MAST.mailname ELSE SHIPTO.mailname END) ELSE AC_MAST.mailname END)
,ADD1=(CASE WHEN EPMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.add1,'''')='''' THEN AC_MAST.add1 ELSE SHIPTO.ADD1 END) ELSE AC_MAST.ADD1 END)
,ADD2=(CASE WHEN EPMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.add2,'''')='''' THEN AC_MAST.add2 ELSE SHIPTO.add2 END) ELSE AC_MAST.ADD2 END)
,ADD3=(CASE WHEN EPMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.add3,'''')='''' THEN AC_MAST.add3 ELSE SHIPTO.add3 END) ELSE AC_MAST.ADD3 END)
,City=(CASE WHEN EPMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.city,'''')='''' THEN AC_MAST.city ELSE SHIPTO.city END) ELSE AC_MAST.city END)
,Zip=(CASE WHEN EPMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.zip,'''')='''' THEN AC_MAST.zip ELSE SHIPTO.zip END) ELSE AC_MAST.zip END)
,consignee=(CASE WHEN EPMAIN.scons_id > 0 THEN (CASE WHEN ISNULL(SHIPTO1.MailName,'''')='''' THEN AC_MAST1.ac_name ELSE SHIPTO1.mailname END) ELSE AC_MAST1.AC_NAME END)
,ADD11=(CASE WHEN EPMAIN.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.add1,'''')='''' THEN AC_MAST1.add1 ELSE SHIPTO1.ADD1 END) ELSE AC_MAST.ADD1 END)
,ADD22=(CASE WHEN EPMAIN.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.add2,'''')='''' THEN AC_MAST1.add2 ELSE SHIPTO1.add2 END) ELSE AC_MAST.ADD2 END)
,ADD33=(CASE WHEN EPMAIN.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.add3,'''')='''' THEN AC_MAST1.add3 ELSE SHIPTO1.add3 END) ELSE AC_MAST1.ADD3 END)
,City1=(CASE WHEN EPMAIN.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.city,'''')='''' THEN AC_MAST1.city ELSE SHIPTO1.city END) ELSE AC_MAST1.city END)
,Zip1=(CASE WHEN EPMAIN.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.zip,'''')='''' THEN AC_MAST1.zip ELSE SHIPTO1.zip END) ELSE AC_MAST1.zip END)
,EPMAIN.Ac_id,EPMAIN.CONS_ID,EPMAIN.SAC_ID,EPMAIN.SCONS_ID,IT_MAST.SERTY,AcdetAlloc.Amount AS Servamount,AcdetAlloc.SExpAmt,acdetalloc.sabtamt,EPITEM.STAXAMT,item_fdisc=epitem.tot_fdisc'
SET @QueryString =@QueryString+',ITADDLESS='+@ITAddLess+',ITEMTAX='+@ItemTaxable+',ITEMNTX='+@ItemNTX+',HEADERDISC='+@HeaderDisc+''--ruchit
SET @QueryString =@QueryString+',HEADERTAX='+@HeaderTAX+',HEADERNTX='+@HeaderNTX+',GSTReceivable='+@GSTReceivable+''
print @QueryString
set @Tot_flds=''
SET @SQLCOMMAND=''
SET @SQLCOMMAND = N''+@QueryString+''+N''+@Tot_flds+''+' FROM EPMAIN '
--FROM EPMAIN 
 SET @SQLCOMMAND =	@SQLCOMMAND+'
 INNER JOIN EPITEM ON (EPMAIN.TRAN_CD=EPITEM.TRAN_CD) 
INNER JOIN IT_MAST ON (EPITEM.IT_CODE=IT_MAST.IT_CODE) 
INNER JOIN AC_MAST ON (AC_MAST.AC_ID=EPMAIN.AC_ID) 
INNER JOIN #EPMAIN ON (EPITEM.TRAN_CD=#EPMAIN.TRAN_CD and EPITEM.Entry_ty=#EPMAIN.entry_ty and EPITEM.ITSERIAL=#EPMAIN.itserial)
INNER JOIN AcdetAlloc ON (EPITEM.entry_ty=AcdetAlloc.Entry_ty AND EPITEM.Tran_cd=ACDETALLOC.TRAN_CD AND EPITEM.ITSERIAL=ACDETALLOC.itserial)
LEFT JOIN AC_MAST AC_MAST1 ON (AC_MAST1.AC_ID=EPMAIN.CONS_ID)
LEFT JOIN SHIPTO ON (SHIPTO.AC_ID=EPMAIN.Ac_id AND SHIPTO.Shipto_id=EPMAIN.sac_id)
LEFT JOIN SHIPTO SHIPTO1 ON(SHIPTO1.AC_ID=EPMAIN.CONS_id AND SHIPTO1.Shipto_id =EPMAIN.scons_id)
ORDER BY EPMAIN.INV_SR,EPMAIN.INV_NO '
print @sqlcommand
execute sp_executesql @sqlcommand
GO
