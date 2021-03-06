If Exists(Select [name] From SysObjects Where xtype='P' and [Name]='USP_REP_PB_VATFORM19')
Begin
	Drop Procedure USP_REP_PB_VATFORM19
End
GO
/*
EXECUTE USP_REP_PB_VATFORM19'','','','04/01/2014','03/31/2016','','','','',0,0,'','','','','','','','','2014-2016',''
*/


-- =============================================
-- Author:		Sandeep S.
-- Create date: 22/09/2012
-- Description:	This Stored procedure is useful to generate BP VAT FORM 19
-- Modify date: 
-- Modified By: GAURAV R. TANNA
-- Modify date: 31/07/2015
-- Remark:    : 
-- =============================================


CREATE PROCEDURE [dbo].[USP_REP_PB_VATFORM19]
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
BEGIN
DECLARE @FCON AS NVARCHAR(2000)
EXECUTE   USP_REP_FILTCON 

@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
,@VSDATE=NULL,@VEDATE=@EDATE
,@VSAC =@SAC,@VEAC =@EAC
,@VSIT=@SIT,@VEIT=@EIT
,@VSAMT=@SAMT,@VEAMT=@EAMT
,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
,@VSCATE =@SCATE,@VECATE =@ECATE
,@VSWARE =@SWARE,@VEWARE  =@EWARE
,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
,@VMAINFILE='M',@VITFILE=Null,@VACFILE='AC'
,@VDTFLD ='DATE'
,@VLYN=Null
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT

DECLARE @SQLCOMMAND NVARCHAR(4000)
DECLARE @RATE NUMERIC(12,2),@AMTA1 NUMERIC(12,2),@AMTB1 NUMERIC(12,2),@AMTC1 NUMERIC(12,2),@AMTD1 NUMERIC(12,2),@AMTE1 NUMERIC(12,2),@AMTF1 NUMERIC(12,2),@AMTG1 NUMERIC(12,2),@AMTH1 NUMERIC(12,2),@AMTI1 NUMERIC(12,2),@AMTJ1 NUMERIC(12,2),@AMTK1 NUMERIC(12,2),@AMTL1 NUMERIC(12,2),@AMTM1 NUMERIC(12,2),@AMTN1 NUMERIC(12,2),@AMTO1 NUMERIC(12,2)
DECLARE @AMTA2 NUMERIC(12,2),@AMTB2 NUMERIC(12,2),@AMTC2 NUMERIC(12,2),@AMTD2 NUMERIC(12,2),@AMTE2 NUMERIC(12,2),@AMTF2 NUMERIC(12,2),@AMTG2 NUMERIC(12,2),@AMTH2 NUMERIC(12,2),@AMTI2 NUMERIC(12,2),@AMTJ2 NUMERIC(12,2),@AMTK2 NUMERIC(12,2),@AMTL2 NUMERIC(12,2),@AMTM2 NUMERIC(12,2),@AMTN2 NUMERIC(12,2),@AMTO2 NUMERIC(12,2)
DECLARE @PER NUMERIC(12,2),@TAXAMT NUMERIC(12,2),@CHAR INT,@LEVEL NUMERIC(12,2),@ITEMTYPE VARCHAR(1)

SELECT DISTINCT AC_NAME=SUBSTRING(AC_NAME1,2,CHARINDEX('"',SUBSTRING(AC_NAME1,2,100))-1) INTO #VATAC_MAST FROM STAX_MAS WHERE AC_NAME1 NOT IN ('"SALES"','"PURCHASES"') AND ISNULL(AC_NAME1,'')<>''
INSERT INTO #VATAC_MAST SELECT DISTINCT AC_NAME=SUBSTRING(AC_NAME1,2,CHARINDEX('"',SUBSTRING(AC_NAME1,2,100))-1) FROM STAX_MAS WHERE AC_NAME1 NOT IN ('"SALES"','"PURCHASES"') AND ISNULL(AC_NAME1,'')<>''
 

Declare @NetEff as numeric (12,2), @NetTax as numeric (12,2)



SELECT PART=3,PARTSR='AAA',SRNO='AAA',tran_type=space(100),party_nm=RTRIM(ac.MAILNAME),ADDRESS=RTRIM(LTRIM(AC.STATE))	
 ,AC.S_TAX,BILLNO=M.U_PINVNO,BILLDT=M.U_PINVDT,ITDESC=B.ITEM
,QTY=b.qty
,AMT1=B.GRO_AMT
,AMT2=B.GRO_AMT
,AMT3=B.GRO_AMT
,Grno=M.U_lrno
,Grdt=M.U_lrdt 
,NTRAN=M.U_TRANSNM
,TR_NAT=SPACE(100)
INTO #FORMPB07A
FROM PTACDET A 
inner join VATITEM_VW B ON (A.ENTRY_TY=B.ENTRY_TY AND A.TRAN_CD=B.TRAN_CD)
INNER JOIN PTMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME and AC.AC_ID=M.AC_ID)
WHERE 1=2

Declare @MultiCo	VarChar(3)
Declare @MCON as NVARCHAR(2000)
IF Exists(Select A.ID From SysObjects A Inner Join SysColumns B On(A.ID = B.ID) Where A.[Name] = 'STMAIN' And B.[Name] = 'DBNAME')
Begin	------Fetch Records from Multi Co. Data
	 Set @MultiCo = 'YES'
	 EXECUTE USP_REP_MULTI_CO_DATA
	  @TMPAC, @TMPIT, @SPLCOND, @SDATE, @EDATE
	 ,@SAC, @EAC, @SIT, @EIT, @SAMT, @EAMT
	 ,@SDEPT, @EDEPT, @SCATE, @ECATE,@SWARE
	 ,@EWARE, @SINV_SR, @EINV_SR, @LYN, @EXPARA
	 ,@MFCON = @MCON OUTPUT
	SET @SQLCOMMAND='Insert InTo  VATTBL Select * from '+@MCON
	EXECUTE SP_EXECUTESQL @SQLCOMMAND
	SET @SQLCOMMAND='Drop Table '+@MCON
	EXECUTE SP_EXECUTESQL @SQLCOMMAND
End
else
Begin ------Fetch Single Co. Data
	 Set @MultiCo = 'NO'
	 EXECUTE USP_REP_SINGLE_CO_DATA_VAT
	  @TMPAC, @TMPIT, @SPLCOND, @SDATE, @EDATE
	 ,@SAC, @EAC, @SIT, @EIT, @SAMT, @EAMT
	 ,@SDEPT, @EDEPT, @SCATE, @ECATE,@SWARE
	 ,@EWARE, @SINV_SR, @EINV_SR, @LYN, @EXPARA
	 ,@MFCON = @MCON OUTPUT

End
SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,@AMTI1=0,@AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0 


SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,@AMTI1=0,@AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0 
SET @CHAR=65


Declare @VATONAMT as numeric(12,2),@INV_NO as varchar(10),@DATE as smalldatetime,@PARTY_NM as varchar(50),@ADDRESS as varchar(100),@ITEM as varchar(50),@FORM_NM as varchar(30),@S_TAX as varchar(30),@QTY as numeric(18,4)
Declare @billno as varchar (15),@billdt as smalldatetime,@itdesc as varchar(50),@recformno as varchar(10),@recformdt as smalldatetime,@grno as varchar(30),@grdt as smalldatetime,@SRNO_OF_VAT36 as varchar(10),@NTRAN as varchar(30)
Declare @U_IMPORM AS VARCHAR(100), @TAX_NAME AS VARCHAR(50), @TRAN_TYPE AS VARCHAR(100), @ST_TYPE As VarChar(50), @country As VARCHAR(60)
Declare @TR_NAT VARCHAR(100), @BHENT VARCHAR(03)

SELECT @VATONAMT=0,@INV_NO ='',@DATE ='',@PARTY_NM ='',@ADDRESS ='',@ITEM ='',@U_IMPORM ='', @TAX_NAME='', @TRAN_TYPE='', @ST_TYPE = ''
,@FORM_NM='',@S_TAX ='',@QTY=0,@ITEMTYPE='',@billno='',@billdt='',@itdesc ='',@recformno='',@recformdt ='',@grno ='',@grdt ='',@SRNO_OF_VAT36 ='',@NTRAN=''
,@COUNTRY = '', @FORM_NM = '', @BHENT = ''


Declare cur_formPB07Aaa cursor for

SELECT 
S.TRAN_CD,
S.ENTRY_TY,
A.U_IMPORM,
A.TAX_NAME,
AC.ST_TYPE,
AC.COUNTRY,
A.FORM_NM,
PARTY_NM=RTRIM(ac.MAILNAME),
ADDRESS=RTRIM(LTRIM(AC.STATE)),
AC.S_TAX,
BILLNO=A.inv_no,
BILLDT=A.DATE,
IT.IT_NAME,
ITDESC=IT.U_TRDNM--CAST(IT.IT_DESC AS VARCHAR(150))
,QTY=Sum(b.qty),
 AMT1=Sum(A.VATONAMT+B.U_FRTAMT),
 AMT2=Sum(B.U_FRTAMT),
 AMT3=Sum(B.U_ADVTAX), 
 Grno=case when S.U_lrno is null then '' else S.U_lrno end 
,Grdt=case when S.U_lrdt is null then ' ' else S.U_lrdt end,NTRAN=RTRIM(S.U_TRANSNM)
FROM vattbl A
INNER JOIN  Ptitem B ON (A.TRAN_cD=B.TRAN_cD AND A.BHENT=B.ENTRY_tY and a.itserial=b.itserial)
inner join Ptmain S on (s.tran_cd=B.tran_cd and s.ac_id=b.ac_id )
INNER JOIN AC_MAST AC ON (S.AC_ID = AC.AC_ID)
INNER JOIN IT_MAST IT ON (IT.IT_CODE = B.IT_CODE)
WHERE  A.BHENT IN ('PT', 'P1') AND  AC.ST_TYPE IN ('OUT OF STATE','OUT OF COUNTRY') AND (A.DATE BETWEEN @SDATE AND @EDATE)
GROUP BY S.TRAN_CD, S.ENTRY_TY, A.U_IMPORM, A.TAX_NAME, AC.ST_TYPE, AC.COUNTRY, A.FORM_NM, RTRIM(ac.MAILNAME), RTRIM(LTRIM(AC.STATE)),
AC.S_TAX,A.inv_no,A.DATE,IT.IT_NAME,IT.U_TRDNM,S.U_lrno,S.U_lrdt,RTRIM(S.U_TRANSNM)
UNION
SELECT 
S.TRAN_CD,
S.ENTRY_TY,
A.U_IMPORM,
A.TAX_NAME,
AC.ST_TYPE,
AC.COUNTRY,
A.FORM_NM,
PARTY_NM=RTRIM(ac.MAILNAME),
ADDRESS=RTRIM(LTRIM(AC.STATE)),
AC.S_TAX,
BILLNO=A.inv_no,
BILLDT=A.DATE,
IT.IT_NAME,
ITDESC=IT.U_TRDNM--CAST(IT.IT_DESC AS VARCHAR(150))
,QTY=Sum(b.qty),
 AMT1=Sum(A.VATONAMT+B.U_FRTAMT),
 AMT2=Sum(B.U_FRTAMT),
 AMT3=Sum(B.U_ADVTAX), 
 Grno=case when S.U_lrno is null then '' else S.U_lrno end 
,Grdt=case when S.U_lrdt is null then ' ' else S.U_lrdt end,NTRAN=RTRIM(S.U_TRANSNM)
FROM vattbl A
INNER JOIN  Stitem B ON (A.TRAN_cD=B.TRAN_cD AND A.BHENT=B.ENTRY_tY and a.itserial=b.itserial)
inner join Stmain S on (s.tran_cd=B.tran_cd and s.ac_id=b.ac_id )
INNER JOIN AC_MAST AC ON (S.AC_ID = AC.AC_ID)
INNER JOIN IT_MAST IT ON (IT.IT_CODE = B.IT_CODE)
WHERE  A.BHENT IN ('ST') AND  AC.ST_TYPE IN ('OUT OF STATE','OUT OF COUNTRY') AND (A.U_IMPORM = 'Purchase Return') AND (A.DATE BETWEEN @SDATE AND @EDATE)
GROUP BY S.TRAN_CD, S.ENTRY_TY, A.U_IMPORM, A.TAX_NAME, AC.ST_TYPE, AC.COUNTRY, A.FORM_NM, RTRIM(ac.MAILNAME), RTRIM(LTRIM(AC.STATE)),
AC.S_TAX,A.inv_no,A.DATE,IT.IT_NAME,IT.U_TRDNM,S.U_lrno,S.U_lrdt,RTRIM(S.U_TRANSNM)
UNION
SELECT 
S.TRAN_CD,
S.ENTRY_TY,
U_IMPORM='Purchase Return',
B.TAX_NAME,
AC.ST_TYPE,
AC.COUNTRY,
FORM_NM='',
PARTY_NM=RTRIM(ac.MAILNAME),
ADDRESS=RTRIM(LTRIM(AC.STATE)),
AC.S_TAX,
BILLNO=S.inv_no,
BILLDT=S.DATE,
IT.IT_NAME,
ITDESC=IT.U_TRDNM--CAST(IT.IT_DESC AS VARCHAR(150))
,QTY=Sum(b.qty),
 AMT1=Sum(B.GRO_AMT-B.U_ADVTAX-B.TAXAMT),
 AMT2=Sum(B.U_FRTAMT),
 AMT3=Sum(B.U_ADVTAX), 
 Grno=case when S.U_lrno is null then '' else S.U_lrno end 
,Grdt=case when S.U_lrdt is null then ' ' else S.U_lrdt end,NTRAN=RTRIM(S.U_TRANSNM)
FROM vattbl A
INNER JOIN  pritem B ON (A.TRAN_cD=B.TRAN_cD AND A.BHENT=B.ENTRY_tY and a.itserial=b.itserial)
inner join PRmain S on (s.tran_cd=B.tran_cd and s.entry_ty=b.entry_ty)
INNER JOIN AC_MAST AC ON (S.AC_ID = AC.AC_ID)
INNER JOIN IT_MAST IT ON (IT.IT_CODE = B.IT_CODE)
WHERE  B.ENTRY_TY ='PR' AND  AC.ST_TYPE IN ('OUT OF STATE','OUT OF COUNTRY') AND (B.DATE BETWEEN @SDATE AND @EDATE)
GROUP BY S.TRAN_CD, S.ENTRY_TY, B.TAX_NAME, AC.ST_TYPE, AC.COUNTRY, RTRIM(ac.MAILNAME), RTRIM(LTRIM(AC.STATE)),
AC.S_TAX,S.inv_no,S.DATE,IT.IT_NAME,IT.U_TRDNM,S.U_lrno,S.U_lrdt,RTRIM(S.U_TRANSNM)
UNION
SELECT 
S.TRAN_CD,
S.ENTRY_TY,
U_IMPORM='Repair/Job Work',
B.TAX_NAME,
AC.ST_TYPE,
AC.COUNTRY,
FORM_NM='',
PARTY_NM=RTRIM(ac.MAILNAME),
ADDRESS=RTRIM(LTRIM(AC.STATE)),
AC.S_TAX,
BILLNO=S.inv_no,
BILLDT=S.DATE,
IT.IT_NAME,
ITDESC=IT.U_TRDNM--CAST(IT.IT_DESC AS VARCHAR(150))
,QTY=Sum(b.qty),
 AMT1=Sum(S.NET_AMT),
 AMT2=0,--Sum(B.U_FRTAMT),
 AMT3=0,--Sum(B.U_ADVTAX), 
 Grno=case when S.U_lrno is null then '' else S.U_lrno end 
,Grdt=case when S.U_lrdt is null then ' ' else S.U_lrdt end,NTRAN=RTRIM(S.U_TRANSNM)
FROM IRItem B 
inner join IRMain S on (s.tran_cd=B.tran_cd and s.entry_ty=b.entry_ty)
INNER JOIN AC_MAST AC ON (S.AC_ID = AC.AC_ID)
INNER JOIN IT_MAST IT ON (IT.IT_CODE = B.IT_CODE)
WHERE  B.ENTRY_TY IN ('R1', 'RL') AND  AC.ST_TYPE IN ('OUT OF STATE','OUT OF COUNTRY') AND (B.DATE BETWEEN @SDATE AND @EDATE)
GROUP BY S.TRAN_CD, S.ENTRY_TY, B.TAX_NAME, AC.ST_TYPE, AC.COUNTRY, RTRIM(ac.MAILNAME), RTRIM(LTRIM(AC.STATE)),
AC.S_TAX,S.inv_no,S.DATE,IT.IT_NAME,IT.U_TRDNM,S.U_lrno,S.U_lrdt,RTRIM(S.U_TRANSNM)
order by Billdt,billno

DECLARE @RENTRY_TY VARCHAR(10), @RTRAN_CD INT, @TRAN_CD INT, @IT_NAME VARCHAR(150), @ENTRY_TAX NUMERIC (12,2)
DECLARE @FRGHT_AMT NUMERIC (12,2), @ADV_TAX NUMERIC (12,2), @REF_TAX VARCHAR(30)

SELECT @RENTRY_TY ='', @RTRAN_CD=0, @TRAN_CD=0, @IT_NAME='', @ENTRY_TAX=0, @FRGHT_AMT = 0, @ADV_TAX = 0, @REF_TAX = ''


OPEN CUR_FORMPB07Aaa
FETCH NEXT FROM CUR_FORMPB07Aaa INTO @TRAN_CD, @BHENT, @U_IMPORM, @TAX_NAME, @ST_TYPE, @COUNTRY, @FORM_NM, @PARTY_NM,@ADDRESS,@S_TAX,@billno,@billdt,@IT_NAME,@itdesc,@QTY,@VATONAMT,@FRGHT_AMT,@ADV_TAX,@grno ,@grdt,@NTRAN
WHILE (@@FETCH_STATUS=0)
BEGIN


	SET @VATONAMT=CASE WHEN @VATONAMT IS NULL THEN 0 ELSE @VATONAMT END
	SET @FRGHT_AMT=CASE WHEN @FRGHT_AMT IS NULL THEN 0 ELSE @FRGHT_AMT END
	SET @ADV_TAX=CASE WHEN @ADV_TAX IS NULL THEN 0 ELSE @ADV_TAX END
	SET @PARTY_NM=CASE WHEN @PARTY_NM IS NULL THEN '' ELSE @PARTY_NM END
	SET @ADDRESS=CASE WHEN @ADDRESS IS NULL THEN '' ELSE @ADDRESS END	
	SET @S_TAX=CASE WHEN @S_TAX IS NULL THEN '' ELSE @S_TAX END
	SET @BILLNO=CASE WHEN @BILLNO IS NULL THEN '' ELSE @BILLNO END
	SET @qty=CASE WHEN @qty IS NULL THEN 0 ELSE @qty END
	SET @COUNTRY=CASE WHEN @COUNTRY IS NULL THEN '' ELSE @COUNTRY END
	SET @IT_NAME=CASE WHEN @IT_NAME IS NULL THEN '' ELSE @IT_NAME END
	SET @ITDESC=CASE WHEN @ITDESC IS NULL THEN '' ELSE @ITDESC END
	SET @TRAN_TYPE = ''
	SET @TR_NAT=''
	SET @REF_TAX=''
	
	SET @TRAN_TYPE = @U_IMPORM
	
	IF @U_IMPORM = 'Branch Transfer' 
		begin
			SET @TRAN_TYPE = 'Interstate Branch Transfer'
		end	
	ELSE IF @U_IMPORM = 'Consignment Transfer'
		begin
			SET @TRAN_TYPE = 'Consignment Transfer'
		end
	ELSE IF @U_IMPORM = 'Import from Outside India'
		begin
			SET @TRAN_TYPE = 'Import from Outside India'
		end		
	ELSE IF @U_IMPORM = 'Discount/Incentive'
		begin
			SET @TRAN_TYPE = 'Discount/Incentive'
			SET @VATONAMT=((-1)* @VATONAMT)
			SET @FRGHT_AMT=((-1)* @FRGHT_AMT)
			SET @ADV_TAX=((-1)* @ADV_TAX)
		end	
	ELSE IF @U_IMPORM = 'Sample/Gift'
		begin
			SET @TRAN_TYPE = 'Sample/Gift'
		end	
	ELSE IF @U_IMPORM = 'Purchase Return'
		begin
			SET @TRAN_TYPE = 'Purchase Return'
			
			IF @BHENT = 'PR'
			BEGIN
				SELECT @TR_NAT=M.U_IMPORM FROM PRITREF R
				INNER JOIN PTMAIN M ON (M.ENTRY_TY = R.RENTRY_TY AND M.TRAN_CD = R.ITREF_TRAN)
				WHERE R.Tran_cd = @TRAN_CD AND R.ENTRY_TY = @BHENT AND R.ITEM = @IT_NAME AND R.RENTRY_TY in ('PT', 'P1')
				SET @TR_NAT = ISNULL(@TR_NAT,'')
				
				SELECT @REF_TAX=D.TAX_NAME FROM PRITREF R
				INNER JOIN PTITEM D ON (D.ENTRY_TY = R.RENTRY_TY AND D.TRAN_CD = R.ITREF_TRAN AND D.ITEM = R.ITEM)
				WHERE R.Tran_cd = @TRAN_CD AND R.ENTRY_TY = @BHENT AND R.ITEM = @IT_NAME AND R.RENTRY_TY in ('PT', 'P1')
				
				SET @REF_TAX = ISNULL(@REF_TAX,'')
			END
			
			IF @BHENT = 'ST'
			BEGIN
				SELECT @TR_NAT=M.U_IMPORM FROM STITREF R
				INNER JOIN PTMAIN M ON (M.ENTRY_TY = R.RENTRY_TY AND M.TRAN_CD = R.ITREF_TRAN)
				WHERE R.Tran_cd = @TRAN_CD AND R.ENTRY_TY = @BHENT AND R.ITEM = @IT_NAME AND R.RENTRY_TY in ('PT', 'P1')
				SET @TR_NAT = ISNULL(@TR_NAT,'')
				
				SELECT @REF_TAX=D.TAX_NAME FROM STITREF R
				INNER JOIN PTITEM D ON (D.ENTRY_TY = R.RENTRY_TY AND D.TRAN_CD = R.ITREF_TRAN AND D.ITEM = R.ITEM)
				WHERE R.Tran_cd = @TRAN_CD AND R.ENTRY_TY = @BHENT AND R.ITEM = @IT_NAME AND R.RENTRY_TY in ('PT', 'P1')
				
				SET @REF_TAX = ISNULL(@REF_TAX,'')
			END
			
			
			--SET @TR_NAT = 'Purchase Return'
			SET @VATONAMT=((-1)* @VATONAMT)
			SET @FRGHT_AMT=((-1)* @FRGHT_AMT)
			SET @ADV_TAX=((-1)* @ADV_TAX)
		end	
	ELSE IF @U_IMPORM = 'Repair/Job Work'
		begin
			SET @TRAN_TYPE = 'Repair/Job Work'
			--SET @TR_NAT = 'Repair/Job Work'
		end	
	ELSE IF @U_IMPORM = 'Cancellation of Sales'
		begin
			SET @TRAN_TYPE = 'Cancellation of Sales'
			SET @TR_NAT = 'Cancellation of Sales'
			SET @VATONAMT=((-1)* @VATONAMT)
			SET @FRGHT_AMT=((-1)* @FRGHT_AMT)
			SET @ADV_TAX=((-1)* @ADV_TAX)
		end
		
	IF @TAX_NAME = 'Form H'
		begin
			SET @TRAN_TYPE = 'Purchase against H form'
		end	
	ELSE IF @TAX_NAME = 'Form I'
		begin
			SET @TRAN_TYPE = 'Purchase against I(SEZ)'
		end	
	ELSE IF @TAX_NAME = 'Form C'
		begin
			SET @TRAN_TYPE = 'Purchase against C form'
		end	
	ELSE IF @TAX_NAME = 'E - 1'
		begin
			SET @TRAN_TYPE = 'Purchase in Transit(E-I)'
		end	
	ELSE IF @TAX_NAME = 'E - 2'
		begin
			SET @TRAN_TYPE = 'Purchase in Transit(E-II)'
		end
	ELSE IF @TAX_NAME = ''	
		begin
			IF @ST_TYPE = 'OUT OF STATE' and @TRAN_TYPE = ''
				BEGIN
					SET @TRAN_TYPE = 'Tax Free Purchases from Outside States'
				END
		end
	ELSE IF @TAX_NAME like ('%C.S.T.%')
		begin
			IF @FORM_NM = '' and @TRAN_TYPE = ''
				BEGIN
					SET @TRAN_TYPE = 'Purchase without C form'
				END
		end
	ELSE IF @TAX_NAME like ('%C.S.T.%')
		begin
			IF @FORM_NM in ('Form C', 'C Form', 'C') and @TRAN_TYPE = ''
				BEGIN
					SET @TRAN_TYPE = 'Purchase against C form'
				END
		end
		
		
		
		
	IF @U_IMPORM in ('Purchase Return')
		BEGIN
			IF @TR_NAT = 'Branch Transfer' 
				begin
					SET @TR_NAT = 'Interstate Branch Transfer'
				end	
			ELSE IF @TR_NAT = 'Consignment Transfer'
				begin
					SET @TR_NAT = 'Consignment Transfer'
				end
			ELSE IF @TR_NAT = 'Import from Outside India'
				begin
					SET @TR_NAT = 'Import from Outside India'
				end		
			ELSE IF @TR_NAT = 'Discount/Incentive'
				begin
					SET @TR_NAT = 'Discount/Incentive'					
				end	
			ELSE IF @TR_NAT = 'Sample/Gift'
				begin
					SET @TR_NAT = 'Sample/Gift'
				end				
			ELSE IF @TR_NAT = 'Repair/Job Work'
				begin
					SET @TR_NAT = 'Repair/Job Work'
					
				end	
			ELSE IF @TR_NAT = 'Cancellation of Sales'
				begin
					SET @TR_NAT = 'Cancellation of Sales'				
				end
				
			IF @REF_TAX = 'Form H'
				begin
					SET @TR_NAT = 'Purchase against H form'
				end	
			ELSE IF @REF_TAX = 'Form I'
				begin
					SET @TR_NAT = 'Purchase against I(SEZ)'
				end	
			ELSE IF @REF_TAX = 'Form C'
				begin
					SET @TR_NAT = 'Purchase against C form'
				end	
			ELSE IF @REF_TAX = 'E - 1'
				begin
					SET @TR_NAT = 'Purchase in Transit(E-I)'
				end	
			ELSE IF @REF_TAX = 'E - 2'
				begin
					SET @TR_NAT = 'Purchase in Transit(E-II)'
				end
			ELSE IF @REF_TAX = ''	
				begin
					IF @ST_TYPE = 'OUT OF STATE' and @TR_NAT = ''
						BEGIN
							SET @TR_NAT = 'Tax Free Purchases from Outside States'
						END
				end
			ELSE IF @REF_TAX like ('%C.S.T.%')
				begin
					IF @FORM_NM = '' and @TR_NAT = ''
						BEGIN
							SET @TR_NAT = 'Purchase without C form'
						END
				end
			ELSE IF @REF_TAX like ('%C.S.T.%')
				begin
					IF @FORM_NM in ('Form C', 'C Form', 'C') and @TR_NAT = ''
						BEGIN
							SET @TR_NAT = 'Purchase against C form'
						END
				end
		END
		
				
		
	set @itdesc = CASE WHEN isnull(@itdesc,'')<>'' THEN isnull(@itdesc,'') ELSE isnull(@it_name,'') end
	
    INSERT INTO #FORMPB07A (PART,PARTSR,SRNO,TRAN_TYPE,S_TAX,PARTY_NM,ADDRESS,billno,billdt,itdesc,QTY,AMT1,AMT2,AMT3,NTRAN ,grno ,grdt,TR_NAT)
    VALUES (1,'1',CHAR(@CHAR),@TRAN_TYPE,@S_TAX,@PARTY_NM,@ADDRESS,@billno,@billdt,@itdesc,@QTY,@VATONAMT,@FRGHT_AMT,@ADV_TAX,@NTRAN,@grno ,@grdt,@TR_NAT)	
	SET @CHAR=@CHAR+1

--	FETCH NEXT FROM CUR_FORMPB07Aaa INTO @TAXONAMT,@TAXAMT,@ITEMAMT,@PARTY_NM,@S_TAX,@billno,@billdt,@itdesc,@recformno ,@recformdt ,@grno ,@grdt ,@SRNO_OF_VAT36  
	FETCH NEXT FROM CUR_FORMPB07Aaa INTO @TRAN_CD, @BHENT, @U_IMPORM, @TAX_NAME, @ST_TYPE, @COUNTRY, @FORM_NM, @PARTY_NM,@ADDRESS,@S_TAX,@billno,@billdt,@IT_NAME,@itdesc,@QTY,@VATONAMT,@FRGHT_AMT,@ADV_TAX,@grno ,@grdt,@NTRAN
END
CLOSE CUR_FORMPB07Aaa
DEALLOCATE CUR_FORMPB07Aaa

SET @AMTA1 = 0
SELECT @AMTA1=COUNT(PARTSR) FROM  #FORMPB07A WHERE PARTSR = '1'
SET @AMTA1 = ISNULL(@AMTA1,0)
IF @AMTA1 = 0
	BEGIN
		INSERT INTO #FORMPB07A (PART,PARTSR,SRNO,TRAN_TYPE,S_TAX,PARTY_NM,ADDRESS,billno,billdt,itdesc,QTY,AMT1,AMT2,AMT3,NTRAN ,grno ,grdt,TR_NAT)
	    VALUES (1,'1','A','','','','','','','',0,0,0,0,'','','','')	
	
	END

INSERT INTO #FORMPB07A (PART,PARTSR,SRNO,TRAN_TYPE,S_TAX,PARTY_NM,ADDRESS,billno,billdt,itdesc,QTY,AMT1,AMT2,AMT3,NTRAN ,grno ,grdt,TR_NAT)
    VALUES (1,'2','A','','','','','','','',0,0,0,0,'','','','')	

Update #FORMPB07A set  PART = isnull(Part,0) , Partsr = isnull(PARTSR,''), SRNO = isnull(SRNO,''),
					 AMT1 = isnull(AMT1,0), AMT2 = isnull(AMT2,0), PARTY_NM = isnull(Party_nm,''),ADDRESS = isnull(ADDRESS,''),S_TAX = isnull(S_TAX,'')
					,BILLNO = isnull(BILLNO,''),ITDESC = isnull(ITDESC,'')	--,BILLDT = isnull(BILLDT,'')
					,Qty = isnull(Qty,0),ntran = isnull(ntran,''),tran_type = isnull(tran_type,'')
					,TR_NAT= isnull(TR_NAT,''),AMT3= isnull(amt3,0)
					
				
					

SELECT * FROM #FORMPB07A order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int)
END

--Print ''
