IF EXISTS(SELECT XTYPE,NAME FROM SYSOBJECTS WHERE XTYPE ='P' AND NAME ='USP_REP_DLANNER2A_DADOS')
BEGIN
	DROP PROCEDURE USP_REP_DLANNER2A_DADOS
END
go
/*
EXECUTE USP_REP_DLANNER2A_DADOS'','04/01/2009','03/31/2015',''
*/


-- =============================================
-- Author:		Hetal L Patel
-- Create date: 22/05/2010
-- Description:	This Stored procedure is useful to generate Delhi VAT Form 30
-- Modify date: 23/05/2011
-- Modified By: Sandeep Shah
-- Remark:      Duplicate details reflecting in Delhi VAT Report for the TKT-8061
-- Modify date: 27/07/2011
-- Modified By: Sandeep Shah
-- Remark:      If we take the same material more than one time in a signle transaction for purchase
--				, it shows multiple times in Vat Form 30 report for TKT-8983
-- Modify date: 05/09/2011
-- Modified By: Sandeep Shah
-- Remark:      Add bill date and transaction date wise filter option by sandeep for TKT-9444 -->Start 
-- Remark:      changes by sandeep for bug-15540 on 11-06-03
-- Remark:      changes by sandeep for bug-20342 on 22-11-13
-- Modify date: 26/02/2014
-- Modified By: Archana Khade
-- Remark:      Change has been done for Bug-21922
-- Modify date: 12-08-2016
-- Modified By: Suraj Kumawat
-- Remark:      Change has been done for Bug-28563 
-- =============================================

create PROCEDURE [dbo].[USP_REP_DLANNER2A_DADOS]
--@TMPAC NVARCHAR(50),@TMPIT NVARCHAR(50),--Commented by Archana K. on 26/02/14 for Bug-21922
 @SPLCOND VARCHAR(8000),@SDATE SMALLDATETIME,@EDATE SMALLDATETIME, @MFCON VARCHAR(4000)
 -- @SDATE SMALLDATETIME,@EDATE SMALLDATETIME
 --Commented by Archana K. on 26/02/14 for Bug-21922 Start
--,@SAC AS VARCHAR(60) = '',@EAC AS VARCHAR(60)= ''
--,@SIT AS VARCHAR(60) = '',@EIT AS VARCHAR(60)= ''
--,@SAMT FLOAT=0,@EAMT FLOAT=0
--,@SDEPT AS VARCHAR(60)= '',@EDEPT AS VARCHAR(60)= ''
--,@SCATE AS VARCHAR(60)= '',@ECATE AS VARCHAR(60)= ''
--,@SWARE AS VARCHAR(60)= '',@EWARE AS VARCHAR(60)= ''
--,@SINV_SR AS VARCHAR(60)= '',@EINV_SR AS VARCHAR(60)= ''
--,@LYN VARCHAR(20) = ''
--,@EXPARA  AS VARCHAR(60)= null
--, @MFCON VARCHAR(4000) = ''
--Commented by Archana K. on 26/02/14 for Bug-21922 End
AS
set nocount on
--SET QUOTED_IDENTIFIER off
--DECLARE @VATFLTNO NVARCHAR(10),@VATFLTDT NVARCHAR(10)
DECLARE @vatfltopt VARCHAR(25)
select @vatfltopt=vat_flt_opt from manufact
print @vatfltopt

		--SET DATEFORMAT DMY 
		-- --DECLARE @SDATE SMALLDATETIME ,@EDATE SMALLDATETIME 
 	--	 SET @SDATE = '01/04/2010'
		-- SET @EDATE = '31/03/2015'			 
--SELECT @VATFLTNO=CASE WHEN VAT_FLT_OPT=1 THEN 'U_PTINVNO' ELSE 'INV_NO' END  FROM MANUFACT
--SELECT @VATFLTDT=CASE WHEN VAT_FLT_OPT=1 THEN 'U_PTINVDT' ELSE 'DATE' END  FROM MANUFACT
Begin
--SET QUOTED_IDENTIFIER ON
--Commented by Archana K. on 26/02/14 for Bug-21922 Start
--Declare @FCON as NVARCHAR(2000),@VSAMT DECIMAL(14,2),@VEAMT DECIMAL(14,2)
--EXECUTE   USP_REP_FILTCON 
--@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
--,@VSDATE=NULL
--,@VEDATE=@EDATE
--,@VSAC =@SAC,@VEAC =@EAC
--,@VSIT=@SIT,@VEIT=@EIT
--,@VSAMT=@SAMT,@VEAMT=@EAMT
--,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
--,@VSCATE =@SCATE,@VECATE =@ECATE
--,@VSWARE =@SWARE,@VEWARE  =@EWARE
--,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
--,@VMAINFILE='M',@VITFILE=NULL,@VACFILE=NULL
--,@VDTFLD ='DATE'
--,@VLYN=NULL
--,@VEXPARA=@EXPARA
--,@VFCON =@FCON OUTPUT
--Commented by Archana K. on 26/02/14 for Bug-21922 end

Declare @SQLCOMMAND NVARCHAR(4000)
 DECLARE @RATE NUMERIC(12,2),@AMTA1 NUMERIC(12,2),@AMTB1 NUMERIC(12,2),@AMTC1 NUMERIC(12,2),@AMTD1 NUMERIC(12,2),@AMTE1 NUMERIC(12,2),@AMTF1 NUMERIC(12,2),@AMTG1 NUMERIC(12,2),@AMTH1 NUMERIC(12,2),@AMTI1 NUMERIC(12,2),@AMTJ1 NUMERIC(12,2),@AMTK1 NUMERIC(12,2),@AMTL1 NUMERIC(12,2),@AMTM1 NUMERIC(12,2),@AMTN1 NUMERIC(12,2),@AMTO1 NUMERIC(12,2)
 DECLARE @AMTA2 NUMERIC(12,2),@AMTB2 NUMERIC(12,2),@AMTC2 NUMERIC(12,2),@AMTD2 NUMERIC(12,2),@AMTE2 NUMERIC(12,2),@AMTF2 NUMERIC(12,2),@AMTG2 NUMERIC(12,2),@AMTH2 NUMERIC(12,2),@AMTI2 NUMERIC(12,2),@AMTJ2 NUMERIC(12,2),@AMTK2 NUMERIC(12,2),@AMTL2 NUMERIC(12,2),@AMTM2 NUMERIC(12,2),@AMTN2 NUMERIC(12,2),@AMTO2 NUMERIC(12,2)
 DECLARE @PER NUMERIC(12,2),@TAXAMT NUMERIC(12,2),@CHAR INT,@LEVEL NUMERIC(12,2),@HSNCODE VARCHAR(50),@COMMODITY_NM VARCHAR(50)

SELECT DISTINCT AC_NAME=SUBSTRING(AC_NAME1,2,CHARINDEX('"',SUBSTRING(AC_NAME1,2,100))-1) INTO #VATAC_MAST FROM STAX_MAS WHERE AC_NAME1 NOT IN ('"SALES"','"PURCHASES"') AND ISNULL(AC_NAME1,'')<>''
INSERT INTO #VATAC_MAST SELECT DISTINCT AC_NAME=SUBSTRING(AC_NAME1,2,CHARINDEX('"',SUBSTRING(AC_NAME1,2,100))-1) FROM STAX_MAS WHERE AC_NAME1 NOT IN ('"SALES"','"PURCHASES"') AND ISNULL(AC_NAME1,'')<>''
--select vatfltopt=vat_flt_opt into #vatfltopt from manufact  
--select * from #vatfltopt
SELECT ENTRY_TY,BCODE=(CASE WHEN EXT_VOU=1 THEN BCODE_NM ELSE ENTRY_TY END),STAX_ITEM  INTO #LCODE FROM LCODE --for bug-6755,LUBRI


Declare @NetEff as numeric (12,2), @NetTax as numeric (12,2)
/*
----Temporary Cursor1
SELECT BHENT='PT',M.INV_NO,M.Date,A.AC_NAME,A.AMT_TY,STM.TAX_NAME,SET_APP=ISNULL(SET_APP,0),STM.ST_TYPE,M.NET_AMT,M.GRO_AMT,TAXONAMT=M.GRO_AMT+M.TOT_DEDUC+M.TOT_TAX+M.TOT_EXAMT+M.TOT_ADD,PER=STM.LEVEL1,MTAXAMT=M.TAXAMT,TAXAMT=A.AMOUNT,STM.FORM_NM,ac_name=AC1.AC_NAME,AC1.S_TAX,M.U_IMPORM
,ADDRESS=LTRIM(AC1.ADD1)+ ' ' + LTRIM(AC1.ADD2) + ' ' + LTRIM(AC1.ADD3),M.TRAN_CD,VATONAMT=99999999999.99,Dbname=space(20),ItemType=space(1),It_code = 999999999999999999-999999999999999999,ItSerial=space(5)
INTO #DLVAT_30
FROM PTACDET A 
INNER JOIN PTMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME)
INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID)
WHERE 1=2 --A.AC_NAME IN ( SELECT AC_NAME FROM #VATAC_MAST)

alter table #DLVAT_30 add recno int identity
*/
---Temporary Cursor2
SELECT PART=3,PARTSR='AAA',RATE=99.999,AMT1=NET_AMT,AMT2=M.TAXAMT,AMT3=M.TAXAMT,AMT4=TAXAMT,
VATMTYPE=SPACE(10),DATE=space(10),PARTY_NM=AC1.AC_NAME,ADDRESS=Ltrim(AC1.Add1)+' '+Ltrim(AC1.Add2)+' '+Ltrim(AC1.Add3),
STM.FORM_NM,AC1.S_TAX,PTTYPE=SPACE(20),HSNCODE =SPACE(50),COMMODITY_NM =SPACE(50)--,STM.TAX_NAME
INTO #DLVAT30
FROM PTACDET A 
INNER JOIN STMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME)
INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID)
WHERE 1=2

Declare @MultiCo	VarChar(3)
Declare @MCON as NVARCHAR(2000)
DECLARE @TABLE_NAME as NVARCHAR(2000)
IF Exists(Select A.ID From SysObjects A Inner Join SysColumns B On(A.ID = B.ID) Where A.[Name] = 'STMAIN' And B.[Name] = 'DBNAME')
	Begin	------Fetch Records from Multi Co. Data
		 Set @MultiCo = 'YES'
--		 EXECUTE USP_REP_MULTI_CO_DATA--Commented by Archana K. on 27/02/14 for Bug-21922
		 SET  @TABLE_NAME ='#TMP'
		 EXECUTE USP_REP_MULTI_CO_DATA_Dados--Changed by Archana K. on 27/02/14 for Bug-21922
--		  @TMPAC, @TMPIT,--Commented by Archana K. on 26/02/14 for bug-21922
		 '', @SDATE, @EDATE,@MFCON = @MCON OUTPUT
--Commented by Archana K. on 26/02/14 for bug-21922 start
--		 ,@SAC, @EAC, @SIT, @EIT, @SAMT, @EAMT
--		 ,@SDEPT, @EDEPT, @SCATE, @ECATE,@SWARE
--		 ,@EWARE, @SINV_SR, @EINV_SR, @LYN, @EXPARA
--		 ,@MFCON = @MCON OUTPUT
--Commented by Archana K. on 26/02/14 for bug-21922 end
		PRINT @MCON	
		--SET @SQLCOMMAND='Select * from '+@MCON
		---EXECUTE SP_EXECUTESQL @SQLCOMMAND
		SET @SQLCOMMAND='Insert InTo #DLVAT_30 Select * from '+@TABLE_NAME
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
		---Drop Temp Table 
		SET @SQLCOMMAND='Drop Table '+@MCON

		EXECUTE SP_EXECUTESQL @SQLCOMMAND
	End
else
	Begin ------Fetch Single Co. Data
		 Set @MultiCo = 'NO'
--		 EXECUTE USP_REP_SINGLE_CO_DATA--Commented by Archana K. on 26/02/14 for bug-21922
		EXECUTE USP_REP_SINGLE_CO_DATA_VAT
		 --EXECUTE USP_REP_SINGLE_CO_DATA_DADOS_NEW --changed by Archana K. on 26/02/14 for Bug-21922
--		  @TMPAC, @TMPIT, --Commented by Archana K. on 26/02/14 for bug-21922		 			
		-- @SPLCOND, @SDATE, @EDATE,'"PT"','#DLVAT_30',@MFCON = @MCON OUTPUT
		  '','','',@SDATE,@EDATE
 ,'',''
 ,'',''
 ,0,0
 ,'',''
 ,'',''
 ,'',''
 ,'',''
 ,''
 ,'PT'
 ,@MFCON = @MCON OUTPUT
--Commented by Archana K. on 26/02/14 for bug-21922 start
--		 ,@SAC, @EAC, @SIT, @EIT, @SAMT, @EAMT
--		 ,@SDEPT, @EDEPT, @SCATE, @ECATE,@SWARE
--		 ,@EWARE, @SINV_SR, @EINV_SR, @LYN, @EXPARA
--		 ,@MFCON = @MCON OUTPUT
--Commented by Archana K. on 26/02/14 for bug-21922 end
		--SET @SQLCOMMAND='Select * from '+@MCON
		---EXECUTE SP_EXECUTESQL @SQLCOMMAND		
		--SET @SQLCOMMAND='Insert InTo #DLVAT_30 Select * from '+@MCON
		--PRINT @SQLCOMMAND	
		--EXECUTE SP_EXECUTESQL @SQLCOMMAND
		---Drop Temp Table 
		--SET @SQLCOMMAND='SELECT * FROM '+@MCON
		--SET @SQLCOMMAND='Drop Table '+@MCON				
		--EXECUTE SP_EXECUTESQL @SQLCOMMAND
	End

--SELECT * FROM #DLVAT_30 WHERE  bhent IN ('LR','IR')-- WHERE ITTEMTYPE= 'C'	

 SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,@AMTI1=0,@AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0 

------->- PART 1-4 
Declare @TAXONAMT as numeric(12,2),@TAXAMT1 as numeric(12,2),@ITEMAMT as numeric(12,2),@VATMTYPE as varchar(10),@DATE as VARCHAR(6) ,@ac_name as varchar(50),@ADDRESS as varchar(100),@ITEM as varchar(50),@FORM_NM as varchar(30),@S_TAX as varchar(30),@QTY as numeric(18,4),@STTYPE AS  VARCHAR(20),@ITEMTYPE AS VARCHAR(1),@PTTYPE AS VARCHAR(20),@TAX_NAME AS VARCHAR(10)

SELECT @TAXONAMT=0,@TAXAMT1 =0,@ITEMAMT =0,@VATMTYPE ='',@DATE ='',@ac_name ='',@ADDRESS ='',@ITEM ='',@FORM_NM='',@S_TAX ='',@QTY=0,@TAX_NAME=''

--Select * frOM vatTBL where ac_name='Seller'

SELECT distinct a.Per,TAXONAMT=sum(A.VATONAMT),TAXAMT=SUM(A.TAXAMT),
ITEMAMT=SUM(A.Net_amt)
,VATMTYPE=c.vatmtype--case when @vatfltopt='Bill Date' then c.u_pinvno  else a.inv_no end
--,DATE=case when @vatfltopt='Bill Date' then Datename(month, c.u_pinvdt )  else Datename(month, c.date ) END  + ' ' +case when @vatfltopt='Bill Date' then Convert(Varchar,DatePart(Year, c.u_pinvdt))  else Convert(Varchar,DatePart(Year, a.date)) END 
,date=case when  ( case when @vatfltopt='Bill Date' then month(  c.u_pinvdt )  else month(c.date ) END   between 4 and 6 ) then (case when @vatfltopt='Bill Date' then convert(varchar(4),year( c.u_pinvdt))  else convert(varchar(4),year(c.date)) end) +'41' 
 else  case when  ( case when @vatfltopt='Bill Date' then month(  c.u_pinvdt)  else month(c.date ) END   between 7 and 9 ) then (case when @vatfltopt='Bill Date' then convert(varchar(4),year( c.u_pinvdt))  else convert(varchar(4),year(c.date)) end) +'42' 
 else case when  ( case when @vatfltopt='Bill Date' then month(  c.u_pinvdt )  else month(c.date ) END   between 10 and 12 ) then (case when @vatfltopt='Bill Date' then convert(varchar(4),year( c.u_pinvdt))  else convert(varchar(4),year(c.date)) end) +'43' 
 else case when  ( case when @vatfltopt='Bill Date' then month(  c.u_pinvdt)  else month(c.date ) END   between 1 and 3 ) then (case when @vatfltopt='Bill Date' then convert(varchar(4),year( c.u_pinvdt))  else convert(varchar(4),year(c.date)) end) +'44'  end end end end 
,A.ac_name,A.ADDRESS
,FORM_NM= (case when month(  c.u_pinvdt )  between 4 and 6  AND month(  c.DATE )  not between 4 and 6  then 'YES' 
 else   case when month(  c.u_pinvdt )  between 7 and 9  AND month(  c.DATE )  not between 7 and 9  then 'YES' 
 else  case when month(  c.u_pinvdt )  between 10 and 12  AND month(  c.DATE )  not between 10 and 12  then 'YES' 
 else   case when month(  c.u_pinvdt )  between 1 and 3  AND month(  c.DATE )  not between 1 and 3  then 'YES' 
 else 'NO'
   end end end end )
 
,s_tax=a.s_tax,
PTTYPE = CASE 
	WHEN A.ST_TYPE in ('OUT OF COUNTRY') AND ITEMTYPE<>'' AND  a.u_imporm in ('Import from Outside India','Direct Imports')  AND A.TAX_NAME<>'EXEMPTED' 
	--AND a.u_imporm='Import from Outside India'	 and c.vatmtype='IOI'	
	THEN 'IMPORT'
	WHEN  A.ST_type in ('OUT OF STATE','OUT OF COUNTRY') AND a.u_imporm='High Seas Purchases' --and ITEMTYPE<>''  AND A.TAX_NAME<>' ' 
	-- and c.vatmtype='HSP'
	 THEN 'HSEASP'
	 WHEN A.ST_TYPE in ('OUT OF STATE') AND ITEMTYPE<>'' AND A.TAX_NAME='FORM F' AND a.BHENT='LR'	 
	  THEN 'OWNGOODSREC' 
	WHEN  
     a.s_tax=''  and A.st_type = ('LOCAL')     
	  then 'UNREGPUR' 		
	  
	 WHEN A.ST_TYPE in ('OUT OF STATE') AND ITEMTYPE<>'' AND A.TAX_NAME='FORM F' AND a.BHENT='RL'
	 THEN 'OTHGOODSREC' 
	 
	 WHEN A.ST_type in ('OUT OF STATE') and ITEMTYPE='C' and A.FORM_NM = 'FORM C' --AND A.TAX_NAME<>'EXEMPTED' --and ITEMTYPE='C'

	 THEN 'CAPNCR'
	 WHEN A.ST_type in ('OUT OF STATE') and ITEMTYPE<>'C' and A.FORM_NM = 'FORM C' --AND A.TAX_NAME<>'EXEMPTED'		
	-- and a.u_imporm='Inter State purchase - Capital Goods' and  c.vatmtype='GD'
	 THEN 'OTHCAPNCR'
	 WHEN A.ST_type in ('OUT OF STATE') and ITEMTYPE<>' ' and A.FORM_NM = ' ' and a.tax_name <>' ' -- and  A.TAX_NAME<>'EXEMPTED' 
	-- and a.u_imporm='Inter State purchase - Capital Goods' and  c.vatmtype='GD'
	 THEN 'INT_TRANS'
	 
	 WHEN A.ST_TYPE='LOCAL' and a.s_tax<>'' AND ITEMTYPE<>'C' AND A.TAX_NAME<>'EXEMPTED'
	-- and a.u_imporm='Eligible Local purchases' and  c.vatmtype='GD'  
	 THEN 'LOCAL O' 
	 WHEN  A.ST_TYPE='LOCAL' and a.s_tax<>'' AND ITEMTYPE='C' AND A.TAX_NAME<>'EXEMPTED'
	-- and a.u_imporm='Eligible Local purchases' and  c.vatmtype='GD' 
	 THEN 'LOCAL C'	
		--Inter state purchase against H-Form(Other than Delhi dealers)
	WHEN A.ST_type='OUT OF STATE' AND ITEMTYPE<>'' AND A.FORM_NM in ('FORM H') AND A.TAX_NAME<>'EXEMPTED' 
	 --and a.tax_name='FORM F'or a.tax_name=''  and sum(a.taxamt)=0 
	 --THEN 'BRN_TRN'	 
	 THEN 'INT_BRN_TRN'	
	 WHEN A.ST_type='OUT OF STATE' AND ITEMTYPE<>'' AND a.u_imporm='Branch Transfer' and   A.FORM_NM IN  ('FORM F') and sum(a.taxamt)=0  AND A.TAX_NAME<>'EXEMPTED'
	 THEN 'INW_STOCK'
	 --Inward stock transfer (Consignment) against F-Form	 
	 WHEN A.ST_type='OUT OF STATE' AND ITEMTYPE<>'' AND a.u_imporm='Consignment Transfer' and  A.FORM_NM in ('FORM F') AND A.TAX_NAME<>'EXEMPTED' and sum(a.taxamt)=0  
	 -- --THEN 'CONS_TRN' 
	  THEN 'INW_STOCK_CONS' 	  
	--Local Purchase eligible Capital goods Rate of Tax
	 WHEN A.ST_type='LOCAL C' AND ITEMTYPE='C'  AND ITEMTYPE<>'I' and a.S_TAX<>'' AND A.TAX_NAME<>'EXEMPTED' 
			-- and a.u_imporm='Inter State Purchase' 
	 THEN 'LOCAL C' 
	 --Local Purchase eligible Capital goods Purchase amount	 
	 WHEN A.ST_type='LOCAL C' AND ITEMTYPE='C'  AND ITEMTYPE<>'I' and a.S_TAX<>'' AND A.TAX_NAME<>'EXEMPTED' 
			-- and a.u_imporm='Inter State Purchase' 
	 THEN 'LOCAL_GOODS_PUR' 
	 
	 --Local Purchase eligible Capital goods Input Tax Paid
	 WHEN A.ST_type='LOCAL C' AND ITEMTYPE='C'  AND ITEMTYPE<>'I' and a.S_TAX<>'' AND A.TAX_NAME<>'EXEMPTED' 
			-- and a.u_imporm='Inter State Purchase' 
	 THEN 'AMT2_LOCAL_InputTax' 	 
	--Local Purchase eligible Capital goods Total Purchase Including Tax			 	 
	 WHEN A.ST_type='LOCAL C' AND ITEMTYPE='C'  AND ITEMTYPE<>'I'  and a.S_TAX<>'' AND A.TAX_NAME<>'EXEMPTED' 
			-- and a.u_imporm='Inter State Purchase' 
	 THEN 'AMT2_LOCAL' 	 
	 WHEN c.VATMTYPE<>''
	 --Type of Purchas	 	 
	 then 'AMT2_PURTYPE' 	 
	--Local Purchase eligible Others Total Rate of Tax
	 WHEN A.ST_type IN ('LOCAL') aND ITEMTYPE='I'  AND ITEMTYPE<>'C' and a.S_TAX<>'' AND A.TAX_NAME<>'EXEMPTED' 
	--Local Purchase eligible Others Purchase amount
	 THEN 'Rate_LOCAL_PRTAX' 
	 --Local Purchase eligible Others Total Purchase amount	 
	 WHEN A.ST_type IN ('LOCAL') AND ITEMTYPE='I'  AND ITEMTYPE<>'C'   and a.S_TAX<>'' AND A.TAX_NAME<>'EXEMPTED' 
	--Local Purchase eligible Others Input tax Paid
	 THEN 'AMT2_LOCAL_PUR_OTHER' 	 
	 --Local Purchase eligible Others Total Input Tax Paid
	 WHEN A.ST_type IN ('LOCAL') AND ITEMTYPE='I'  AND ITEMTYPE<>'C'   and a.S_TAX<>'' AND A.TAX_NAME<>'EXEMPTED' 
			-- and a.u_imporm='Inter State Purchase' 
	 THEN 'AMT2_LOCAL_PUR_INPUTTAX' 	 
	--Local Purchase eligible Others Total Total Purchase Including Tax			 	 
	 WHEN A.ST_type IN ('LOCAL') AND ITEMTYPE='I'  AND ITEMTYPE<>'C'  and a.S_TAX<>'' AND A.TAX_NAME<>'EXEMPTED' 
	 --Local Purchase eligible Others Total Purchase Including Tax
	 THEN 'AMT2_LOCAL_TOT_PUR' 	 
	 WHEN A.ST_type IN ('LOCAL') AND ITEMTYPE='I'  AND ITEMTYPE='C'  and a.S_TAX<>'' AND A.TAX_NAME<>'EXEMPTED' 
	--Rate of Tax on the item under Delhi value added Tax Act
	 THEN 'AMT2_RATE_TAX' 	 
else 
	' '	 
	END		 
 
 ,D.HSNCODE,(SUBSTRING(SUBSTRING(D.U_VATITM,1,15), 0, PATINDEX('%-%',SUBSTRING(D.U_VATITM,1,15))))AS COMMODITY_NM -- 12-08-2016
--bug-20342 --->END
INTO #1 FROM  vatTBL A
--FROM  vatTBL A
--Inner Join Litem_vw B On(A.Bhent = B.Entry_ty And A.Tran_cd = b.Tran_cd and a.it_code=b.it_code and a.itserial=b.itserial)-- And A.Tax_name = B.Tax_Name )
  inner JOIN PTMAIN C ON (A.Bhent = C.Entry_ty And A.Tran_cd = C.Tran_cd)
  inner JOIN IT_MAST d ON (A.It_code = d.It_code)
  --INNER JOIN AC_MAST d ON (b.AC_ID = d.AC_ID)
  --inner JOIN IRMAIN LR ON (A.Bhent = LR.Entry_ty And A.Tran_cd = LR.Tran_cd)
--left join stax_mas st on (st.entry_ty=a.bhent and a.tax_name=st.tax_name )
--inner join #lcode lc on (lc.entry_ty=a.bhent)
--WHERE lc.bcode in( 'PT','II','IR') --AND ( case when @vatfltopt='Bill Date' then c.u_pinvdt  else a.date end  BETWEEN @SDATE AND @EDATE )
group by  A.PER,c.u_pinvno,c.u_pinvdt, A.bhent,D.HSNCODE,(SUBSTRING(SUBSTRING(D.U_VATITM,1,15), 0, PATINDEX('%-%',SUBSTRING(D.U_VATITM,1,15)))) -- 12-08-2016
--,case when @vatfltopt='Bill Date' then Datename(month, c.u_pinvdt )  else Datename(month, c.date ) END  + ' ' +case when @vatfltopt='Bill Date' then Convert(Varchar,DatePart(Year, c.u_pinvdt))  else Convert(Varchar,DatePart(Year, a.date)) END 
,case when  ( case when @vatfltopt='Bill Date' then month(  c.u_pinvdt )  else month(c.date ) END   between 4 and 6 ) then (case when @vatfltopt='Bill Date' then convert(varchar(4),year( c.u_pinvdt))  else convert(varchar(4),year(c.date)) end) +'41' 
 else  case when  ( case when @vatfltopt='Bill Date' then month(  c.u_pinvdt)  else month(c.date ) END   between 7 and 9 ) then (case when @vatfltopt='Bill Date' then convert(varchar(4),year( c.u_pinvdt))  else convert(varchar(4),year(c.date)) end) +'42' 
 else case when  ( case when @vatfltopt='Bill Date' then month(  c.u_pinvdt )  else month(c.date ) END   between 10 and 12 ) then (case when @vatfltopt='Bill Date' then convert(varchar(4),year( c.u_pinvdt))  else convert(varchar(4),year(c.date)) end) +'43' 
 else case when  ( case when @vatfltopt='Bill Date' then month(  c.u_pinvdt)  else month(c.date ) END   between 1 and 3 ) then (case when @vatfltopt='Bill Date' then convert(varchar(4),year( c.u_pinvdt))  else convert(varchar(4),year(c.date)) end) +'44'  end end end end 
,A.ac_name,A.ADDRESS,c.form_no,A.S_TAX,A.ST_type,a.tax_name,a.itemtype, a.u_imporm,c.vatmtype
,A.Form_nm,A.rform_nm,
(case when month(  c.u_pinvdt )  between 4 and 6  AND month(  c.DATE )  not between 4 and 6  then 'YES' 
 else   case when month(  c.u_pinvdt )  between 7 and 9  AND month(  c.DATE )  not between 7 and 9  then 'YES' 
 else  case when month(  c.u_pinvdt )  between 10 and 12  AND month(  c.DATE )  not between 10 and 12  then 'YES' 
 else   case when month(  c.u_pinvdt )  between 1 and 3  AND month(  c.DATE )  not between 1 and 3  then 'YES' 
 else 'NO'
   end end end end )
--,b.entry_Ty
--order by a.date
--select * from #1 --WHERE ST_TYPE in ('OUT OF STATE') AND ITEMTYPE<>'' AND TAX_NAME='FORM F' AND entry_ty='RL'

Declare cur_dlvat30 cursor for
--Add bill date and transaction date wise filter option by sandeep for TKT-9444 -->Start 
-- change by Sandeep for TKT-8983 -->start

select Per,TAXONAMT=sum(TAXONAMT),TAXAMT=SUM(TAXAMT),ITEMAMT=sum(ITEMAMT),VATMTYPE,date,ac_name,ADDRESS,FORM_NM,s_tax,PTTYPE,HSNCODE,COMMODITY_NM 
from #1 group by per,ac_name,ADDRESS,VATMTYPE,date,s_tax,PTTYPE,form_nm ,HSNCODE,COMMODITY_NM
OPEN CUR_DLVAT30
FETCH NEXT FROM CUR_DLVAT30 INTO @PER,@TAXONAMT,@TAXAMT,@ITEMAMT,@VATMTYPE,@DATE,@ac_name,@ADDRESS,@FORM_NM,@S_TAX,@PTTYPE,@HSNCODE,@COMMODITY_NM--,@TAX_NAME
WHILE (@@FETCH_STATUS=0)
BEGIN
	SET @PER =CASE WHEN @PER IS NULL THEN 0 ELSE @PER END
	SET @TAXONAMT=CASE WHEN @TAXONAMT IS NULL THEN 0 ELSE @TAXONAMT END
	SET @TAXAMT1=CASE WHEN @TAXAMT1 IS NULL THEN 0 ELSE @TAXAMT1 END
	SET @ITEMAMT=CASE WHEN @ITEMAMT IS NULL THEN 0 ELSE @ITEMAMT END
	SET @ac_name=CASE WHEN @ac_name IS NULL THEN '' ELSE @ac_name END
	SET @VATMTYPE=CASE WHEN @VATMTYPE IS NULL THEN '' ELSE @VATMTYPE END
	SET @DATE=CASE WHEN @DATE IS NULL THEN '' ELSE @DATE END
	SET @ADDRESS=CASE WHEN @ADDRESS IS NULL THEN '' ELSE @ADDRESS END
	SET @S_TAX=CASE WHEN @S_TAX IS NULL THEN '' ELSE @S_TAX END
	SET @FORM_NM=CASE WHEN @FORM_NM IS NULL THEN '' ELSE @FORM_NM END
    SET @PTTYPE=CASE WHEN @PTTYPE IS NULL THEN '' ELSE @PTTYPE END
	INSERT INTO #DLVAT30 (PART,PARTSR,RATE,AMT1,AMT2,AMT3,VATMTYPE,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX,PTTYPE,HSNCODE,COMMODITY_NM)
                 VALUES (1,'1',@PER,@TAXONAMT,@TAXAMT,@ITEMAMT,@VATMTYPE,@DATE,@ac_name,@ADDRESS,@FORM_NM,@S_TAX,@PTTYPE,@HSNCODE,@COMMODITY_NM)
	
	SET @CHAR=@CHAR+1
	FETCH NEXT FROM CUR_DLVAT30 INTO @PER,@TAXONAMT,@TAXAMT,@ITEMAMT,@VATMTYPE,@DATE,@ac_name,@ADDRESS,@FORM_NM,@S_TAX,@PTTYPE,@HSNCODE,@COMMODITY_NM
END
CLOSE CUR_DLVAT30
DEALLOCATE CUR_DLVAT30
--<- PART 1-4

   --SELECT * FROM #DLVAT_30
drop table #1
--SELECT * FROM #DLVAT30
--Update #DLVAT30 set  PART = isnull(Part,0) , Partsr = isnull(PARTSR,''), SRNO = isnull(SRNO,''),
--		             RATE = isnull(RATE,0),AMT1 = isnull(AMT1,0), AMT2 = isnull(AMT2,0), 
--					 AMT3 = isnull(AMT3,0),AMT4 = isnull(AMT4,0), VATMTYPE = isnull(VATMTYPE,''), DATE = isnull(Date,''), 
--					 ac_name = isnull(ac_name,''), ADDRESS = isnull(Address,''),
--					 FORM_NM = isnull(form_nm,''), S_TAX = isnull(S_tax,'')--, Qty = isnull(Qty,0),  ITEM =isnull(item,''),

 

-- SELECT * FROM #DLVAT30 order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int), partsr,SRNO,DATE--Commented by Archana K. on 28/02/14 for Bug-21922

--Commented by Shrikant S. on 03/03/2014 for Bug-21922		--Start
--SELECT *,AMT1_imp=CASE WHEN PTTYPE='IMPORT' THEN AMT1 ELSE 0 END,AMT1_HSEASP=CASE WHEN PTTYPE='HSEASP' THEN AMT1 ELSE 0 END
--,AMT1_EXEMUNIT=CASE WHEN PTTYPE='EXEMUNIT' THEN AMT1 ELSE 0 END,
--AMT1_UNREGPUR=CASE WHEN PTTYPE='UNREGPUR' THEN AMT1 ELSE 0 END
--,AMT1_CAPNCR=CASE WHEN PTTYPE='CAPNCR' THEN AMT1 ELSE 0 END,AMT1_NONE=CASE WHEN PTTYPE='NONE' THEN AMT1 ELSE 0 END,AMT1_BRN_TRN=CASE WHEN PTTYPE='BRN_TRN' THEN AMT1 ELSE 0 END,AMT1_CONS_TRN=CASE WHEN PTTYPE='CONS_TRN' THEN AMT1 ELSE 0 END,
--AMT1_LOCALC=CASE WHEN PTTYPE='LOCAL C' THEN AMT1 ELSE 0 END,Rate_LOCALC=CASE WHEN PTTYPE='LOCAL C' THEN RATE ELSE 0 END,AMT2_LOCALC=CASE WHEN PTTYPE='LOCAL C' THEN AMT2 ELSE 0 END,AMT2_LOCALO=CASE WHEN PTTYPE='LOCAL O' THEN AMT1 ELSE 0 END,
--AMT2_LOCAL=CASE WHEN substring(PTTYPE,1,5)='LOCAL' THEN AMT2 ELSE 0 END
--FROM #DLVAT30 order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int), partsr,SRNO,DATE--changed by Archana K. on 28/02/14 for Bug-21922
--Commented by Shrikant S. on 03/03/2014 for Bug-21922		--End
--Adde by Shrikant S. on 03/03/2014 for Bug-21922		--Start

--select * FROM #DLVAT30 WHERE party_nm='Seller(Out Of State)                              '

SELECT 
ROW_NUMBER()OVER(order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int), partsr,DATE) AS SRNO
, Year_Quarter=Date--=CASE WHEN MTH='IMPORT' THEN AMT1 ELSE 0 ENDdate]
,S_TAX
,PARTY_NM
,AMT1_imp=CASE WHEN PTTYPE='IMPORT' THEN AMT1 ELSE 0 END
,AMT1_HSEASP=CASE WHEN PTTYPE =('HSEASP') THEN AMT1 ELSE 0 END
,AMT1_OWNGOODSREC=CASE WHEN PTTYPE='OWNGOODSREC' THEN AMT1 ELSE 0 END ---C
,AMT1_UNREGPUR=CASE WHEN PTTYPE='UNREGPUR' THEN AMT1 ELSE 0 END
,AMT1_OTHGOODSREC=CASE WHEN PTTYPE='OTHGOODSREC' THEN AMT1 ELSE 0 END---C
,AMT1_CAPNCR=CASE WHEN PTTYPE='CAPNCR' THEN AMT1 ELSE 0 END
,AMT1_OTHCAPNCR=CASE WHEN PTTYPE='OTHCAPNCR' THEN AMT1 ELSE 0 END
,AMT1_INT_BRN_TRN=CASE WHEN PTTYPE='INT_BRN_TRN' THEN AMT1 ELSE 0 END
,AMT1_INT_TRANS=CASE WHEN PTTYPE IN ('INT_TRANS',' ') THEN AMT1 ELSE 0 END
,AMT1_INW_STOCK=CASE WHEN PTTYPE='INW_STOCK' THEN AMT1 ELSE 0 END
--,AMT1_INW_STOCK=CASE WHEN PTTYPE='INW_STOCK' THEN AMT1 ELSE 0 END
,AMT1_INW_STOCK_CONS=CASE WHEN PTTYPE='INW_STOCK_CONS' THEN AMT1 ELSE 0 END
,Rate_LOCALC=CASE WHEN PTTYPE='LOCAL C' THEN RATE ELSE 0 END
--,AMT2_LOCAL_GOODS_PUR=CASE WHEN PTTYPE='LOCAL_GOODS_PUR' THEN AMT2 ELSE 0 END
--,AMT2_LOCAL_InputTax=CASE WHEN PTTYPE='LOCAL_INPUTTAX' THEN AMT2 ELSE 0 END
,AMT2_LOCAL_GOODS_PUR=CASE WHEN PTTYPE='LOCAL C' THEN AMT1 ELSE 0 END
,AMT2_LOCAL_InputTax=CASE WHEN PTTYPE='LOCAL C' THEN AMT2 ELSE 0 END
--,AMT2_LOCAL=CASE WHEN substring(PTTYPE,1,5) IN ('LOCAL','LOCAL O') THEN AMT2+1 ELSE 0 END
,AMT2_LOCAL=CASE WHEN PTTYPE='LOCAL C' THEN AMT1+AMT2 ELSE 0 END
--,AMT2_PURTYPE='T'
,AMT2_PURTYPE=VATMTYPE
--,Rate_LOCAL_PRTAX=CASE WHEN PTTYPE='LOCAL_PRTAX' THEN RATE ELSE 0 END
,Rate_LOCAL_PRTAX=CASE WHEN PTTYPE='LOCAL O' THEN RATE ELSE 0 END
--,AMT2_LOCAL_PUR_OTHER=CASE WHEN PTTYPE='LOCAL_PUR_OTHER' THEN AMT2 ELSE 0 END
,AMT2_LOCAL_PUR_OTHER=CASE WHEN PTTYPE='LOCAL O' THEN AMT1 ELSE 0 END
--,AMT2_LOCAL_PUR_INPUTTAX=CASE WHEN PTTYPE='LOCAL_PUR_INPUTTAX' THEN AMT2 ELSE 0 END
,AMT2_LOCAL_PUR_INPUTTAX=CASE WHEN PTTYPE='LOCAL O' THEN AMT2 ELSE 0 END
--,AMT2_LOCAL_TOT_PUR=CASE WHEN PTTYPE='LOCAL_TOT_PUR' THEN AMT1+AMT1 ELSE 0 END
,AMT2_LOCAL_TOT_PUR=CASE WHEN PTTYPE='LOCAL O' THEN AMT1+AMT2 ELSE 0 END
,AMT2_RATE_TAX=CASE WHEN PTTYPE='LOCAL O' THEN RATE ELSE 0 END
,VAT_YES_NO=FORM_NM
,COMMODITY_NM --- Added by suraj Kumawat for bug-28563
,HSNCODE --- Added by suraj Kumawat for bug-28563
FROM #DLVAT30  order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int), partsr,DATE--changed by Archana K. on 28/02/14 for Bug-21922

--FROM #DLVAT30  order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int), partsr,SRNO,DATE--changed by Archana K. on 28/02/14 for Bug-21922
--Adde by Shrikant S. on 03/03/2014 for Bug-21922		--End

End
