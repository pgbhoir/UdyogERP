IF EXISTS (SELECT XTYPE, NAME FROM SYSOBJECTS WHERE XTYPE = 'P' AND NAME = 'USP_REP_UA_CSTFORM01')
BEGIN
	DROP PROCEDURE USP_REP_UA_CSTFORM01
END
GO
set ANSI_NULLS ON
GO
set QUOTED_IDENTIFIER ON
go
--EXECUTE USP_REP_UA_CSTFORM01'','','','04/01/2013','03/31/2015','','','','',0,0,'','','','','','','','','2013-2015',''
 -- =============================================
 -- Author:  Hetal L. Patel
 -- Create date: 16/07/2009 
 -- Description: This Stored procedure is useful to generate UA CST Form1
 -- Modify date: 22/06/2015
 -- Modified By: Gaurav R. Tanna, bug - 26398, updated as per new USP_REP_SINGLE_CO_DATA_VAT sp.
 -- Modified By: Sumit S. Gavate, bug - 26398.
 -- =============================================
CREATE PROCEDURE [dbo].[USP_REP_UA_CSTFORM01]
 @TMPAC NVARCHAR(50),@TMPIT NVARCHAR(50),@SPLCOND VARCHAR(8000),@SDATE  SMALLDATETIME,@EDATE SMALLDATETIME
 ,@SAC AS VARCHAR(60),@EAC AS VARCHAR(60)
 ,@SIT AS VARCHAR(60),@EIT AS VARCHAR(60)
 ,@SAMT FLOAT,@EAMT FLOAT
 ,@SDEPT AS VARCHAR(60),@EDEPT AS VARCHAR(60)
 ,@SCATE AS VARCHAR(60),@ECATE AS VARCHAR(60)
 ,@SWARE AS VARCHAR(60),@EWARE AS VARCHAR(60)
 ,@SINV_SR AS VARCHAR(60),@EINV_SR AS VARCHAR(60)
 ,@LYN VARCHAR(20)
 ,@EXPARA  AS VARCHAR(60)= null
 AS
 BEGIN
 Declare @FCON as NVARCHAR(2000),@VSAMT DECIMAL(14,2),@VEAMT DECIMAL(14,2)
 EXECUTE   USP_REP_FILTCON 
 @VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
 ,@VSDATE=NULL
 ,@VEDATE=@EDATE
 ,@VSAC =@SAC,@VEAC =@EAC
 ,@VSIT=@SIT,@VEIT=@EIT
 ,@VSAMT=@SAMT,@VEAMT=@EAMT
 ,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
 ,@VSCATE =@SCATE,@VECATE =@ECATE
 ,@VSWARE =@SWARE,@VEWARE  =@EWARE
 ,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
 ,@VMAINFILE='M',@VITFILE=NULL,@VACFILE=NULL
 ,@VDTFLD ='DATE'
 ,@VLYN=NULL
 ,@VEXPARA=@EXPARA
 ,@VFCON =@FCON OUTPUT
 
 DECLARE @SQLCOMMAND NVARCHAR(4000)
 DECLARE @RATE NUMERIC(12,2),@AMTA1 NUMERIC(12,2),@AMTB1 NUMERIC(12,2),@AMTC1 NUMERIC(12,2),@AMTD1 NUMERIC(12,2),@AMTE1 NUMERIC(12,2),@AMTF1 NUMERIC(12,2),@AMTG1 NUMERIC(12,2),@AMTH1 NUMERIC(12,2),@AMTI1 NUMERIC(12,2),@AMTJ1 NUMERIC(12,2),@AMTK1 NUMERIC(12,2),@AMTL1 NUMERIC(12,2),@AMTM1 NUMERIC(12,2),@AMTN1 NUMERIC(12,2),@AMTO1 NUMERIC(12,2)
 DECLARE @AMTA2 NUMERIC(12,2),@AMTB2 NUMERIC(12,2),@AMTC2 NUMERIC(12,2),@AMTD2 NUMERIC(12,2),@AMTE2 NUMERIC(12,2),@AMTF2 NUMERIC(12,2),@AMTG2 NUMERIC(12,2),@AMTH2 NUMERIC(12,2),@AMTI2 NUMERIC(12,2),@AMTJ2 NUMERIC(12,2),@AMTK2 NUMERIC(12,2),@AMTL2 NUMERIC(12,2),@AMTM2 NUMERIC(12,2),@AMTN2 NUMERIC(12,2),@AMTO2 NUMERIC(12,2)
 DECLARE @PER NUMERIC(12,2),@TAXAMT NUMERIC(12,2),@CHAR INT,@LEVEL NUMERIC(12,2)
 
SELECT DISTINCT AC_NAME=SUBSTRING(AC_NAME1,2,CHARINDEX('"',SUBSTRING(AC_NAME1,2,100))-1) INTO #VATAC_MAST FROM STAX_MAS WHERE AC_NAME1 NOT IN ('"SALES"','"PURCHASES"') AND ISNULL(AC_NAME1,'')<>''
INSERT INTO #VATAC_MAST SELECT DISTINCT AC_NAME=SUBSTRING(AC_NAME1,2,CHARINDEX('"',SUBSTRING(AC_NAME1,2,100))-1) FROM STAX_MAS WHERE AC_NAME1 NOT IN ('"SALES"','"PURCHASES"') AND ISNULL(AC_NAME1,'')<>''
 
Declare @BalAmt as numeric (14,2)
Declare @NetEff as numeric (12,2), @NetTax as numeric (12,2)

----Temporary Cursor1
SELECT PART=3,PARTSR='AAA',SRNO='AAA',RATE=99.999,AMT1=NET_AMT,AMT2=M.TAXAMT,AMT3=M.TAXAMT,
M.INV_NO,M.DATE,PARTY_NM=AC1.AC_NAME,ADDRESS=Ltrim(AC1.Add1)+' '+Ltrim(AC1.Add2)+' '+Ltrim(AC1.Add3),STM.FORM_NM,AC1.S_TAX
INTO #FORM221
FROM PTACDET A 
INNER JOIN STMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME)
INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID)
WHERE 1=2

Declare @MultiCo	VarChar(3)
Declare @MCON as NVARCHAR(2000)
IF Exists(Select A.ID From SysObjects A Inner Join SysColumns B On(A.ID = B.ID) Where A.[Name] = 'STMAIN' And B.[Name] = 'DBNAME')
	Begin	------Fetch Records from Multi Co. Data
		 Set @MultiCo = 'YES'
		  
		 /* 
		 EXECUTE USP_REP_MULTI_CO_DATA
		  @TMPAC, @TMPIT, @SPLCOND, @SDATE, @EDATE
		 ,@SAC, @EAC, @SIT, @EIT, @SAMT, @EAMT
		 ,@SDEPT, @EDEPT, @SCATE, @ECATE,@SWARE
		 ,@EWARE, @SINV_SR, @EINV_SR, @LYN, @EXPARA
		 ,@MFCON = @MCON OUTPUT

		--SET @SQLCOMMAND='Select * from '+@MCON
		---EXECUTE SP_EXECUTESQL @SQLCOMMAND
		SET @SQLCOMMAND='Insert InTo  #FORM221_1 Select * from '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
		---Drop Temp Table 
		SET @SQLCOMMAND='Drop Table '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
		*/
	End
else
	Begin ------Fetch Single Co. Data
		 Set @MultiCo = 'NO'
		-- EXECUTE USP_REP_SINGLE_CO_DATA
		 EXECUTE USP_REP_SINGLE_CO_DATA_VAT
		  @TMPAC, @TMPIT, @SPLCOND, @SDATE, @EDATE
		 ,@SAC, @EAC, @SIT, @EIT, @SAMT, @EAMT
		 ,@SDEPT, @EDEPT, @SCATE, @ECATE,@SWARE
		 ,@EWARE, @SINV_SR, @EINV_SR, @LYN, @EXPARA
		 ,@MFCON = @MCON OUTPUT

        /*
		--SET @SQLCOMMAND='Select * from '+@MCON
		---EXECUTE SP_EXECUTESQL @SQLCOMMAND
		SET @SQLCOMMAND='Insert InTo  #FORM221_1 Select * from '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
		---Drop Temp Table 
		SET @SQLCOMMAND='Drop Table '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
		*/
	End
-----
-----SELECT * from #form221_1 where (Date Between @Sdate and @Edate) and Bhent in('EP','PT','CN') and TAX_NAME In('','NO-TAX') and U_imporm = ''
-----

--Gross Sales
SET @AMTA1 = 0
SET  @BALAMT = 0
Select @AMTA1 = isnulL(Sum(CASE WHEN BHENT='ST' THEN gro_Amt ELSE -GRO_AMT END),0) From VATTBL 
where (Date Between @Sdate and @Edate) And Bhent in('ST','CN','SR')
Set @BALAMT = @BALAMT + ISNULL(@AMTA1,0)
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES(1,'1','A',0,@AMTA1,0,0,'')

--Dedut--
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES(1,'1','B',0,0,0,0,'')

--(i)  Sales of goods outside the State (as defined in section 4 of the Central Act)
SET @AMTA1 = 0
Select @AMTA1=ISNULL(Sum(CASE WHEN BHENT='ST' THEN gro_Amt ELSE -GRO_AMT END),0) From VATTBL where (Date Between @Sdate and @Edate) 
And Bhent in('ST','CN','SR')  And St_Type = 'OUT OF STATE' AND (U_IMPORM IN('BRANCH TRANSFER','CONSIGNMENT TRANSFER')) --AND TAX_NAME <> 'EXEMPTED'
--AND (U_IMPORM IN('BRANCH TRANSFER','CONSIGNMENT TRANSFER') OR RFORM_NM LIKE('%FORM%')) AND TAX_NAME <> 'EXEMPTED'
Set @BALAMT = @BALAMT - @AMTA1
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES(1,'1','BA',0,@AMTA1,0,0,'')

--(ii) Sales of goods in course of export outside India (as defined in section 5 of the Central Act)
SET @AMTA1 = 0
Select @AMTA1=ISNULL(Sum(CASE WHEN BHENT='ST' THEN gro_Amt ELSE -GRO_AMT END),0) From VATTBL where (Date Between @Sdate and @Edate) 
And Bhent in('ST','CN','SR')  And St_Type = 'OUT OF COUNTRY'
Set @BALAMT = @BALAMT - @AMTA1
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES(1,'1','BB',0,@AMTA1,0,0,'')

--Balance- Turnover of inter state sales & sales within the State
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES(1,'1','C',0,@BALAMT,0,0,'')

--Deduct- Turnover of sales within the State
SET @AMTA1 = 0
Select @AMTA1=ISNULL(Sum(CASE WHEN BHENT='ST' THEN gro_Amt ELSE -GRO_AMT END),0) From vattbl where (Date Between @Sdate and @Edate) 
And Bhent in('ST','CN','SR') And St_Type in('LOCAL','')
Set @BALAMT = @BALAMT - @AMTA1 --this used for 3.(i)Balance-Turnover on inter-State Sales
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES(1,'1','CC',0,@AMTA1,0,0,'')

-- Balance- Turnover of inter state sales
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES(1,'1','D',0,@BALAMT,0,0,'')

-- Deduct- Cost of Freight, delivery of installation when such cost is seperately charged
SELECT @AMTA1 = 0,@AMTA2 = 0
SELECT @AMTA1 = ISNULL(Sum(A.U_FRTAMT),0) FROM STITEM A
INNER JOIN VATTBL V ON (A.entry_ty = V.BHENT AND A.Tran_cd = V.Tran_cd AND A.Inv_no = V.INV_NO AND A.It_code = V.It_Code AND A.Itserial = V.ItSerial)
WHERE V.ST_TYPE = 'OUT OF STATE' AND A.Date Between @SDATE And @EDATE AND A.Entry_TY IN ('ST','SR','CN')
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES(1,'1','DD',0,@AMTA1,0,0,'')
SET @BALAMT = @BALAMT - @AMTA1

--Balance- Total turnover on Inter-State sales
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES(1,'1','E',0,@BALAMT,0,0,'')

--Deduct- Subsequent sales not taxable under section 6(2) of the Act
SET @AMTA1=0
Select @AMTA1=ISNULL(Sum(CASE WHEN BHENT='ST' THEN gro_Amt ELSE -GRO_AMT END),0) From VATTBL 
where (Date Between @Sdate and @Edate) And Bhent in('ST','CN','SR') AND ST_TYPE='OUT OF STATE'
AND rform_nm IN('E-II','Form E-II','E-II Form','E - 2', 'Form E - 2','E - 2 Form','E-2','Form E-2','E-2 Form','E2','E2 Form','Form E2')
AND TAX_NAME IN('E-II','Form E-II','E-II Form','E - 2', 'Form E - 2','E - 2 Form','E-2','Form E-2','E-2 Form','E2','E2 Form','Form E2')
SET @BALAMT = @BALAMT - @AMTA1 
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES(1,'1','EE',0,@AMTA1,0,0,'')

--Goods-wise break-up of above
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES(1,'1','F',0,0,0,0,'')

--(A) Declare Goods.
--(i)  Sold to registered dealers on prescribed declaration (vide declaration
--(ii) Sold Otherwise
Declare @BALAMT62A Numeric (12,2), @BALAMT62B Numeric (12,2)
SET @BALAMT62A = 0
SET @BALAMT62B = 0

SET  @AMTA1 = 0  
Select @AMTA1 = isnull(Sum(CASE WHEN A.BHENT='ST' THEN A.gro_Amt ELSE -A.GRO_AMT END),0) From VATTBL A INNER JOIN IT_MAST I on (A.It_Code = I.It_Code)
where (A.Date Between @Sdate and @Edate) And A.Bhent  in('ST','CN','SR') And A.s_tax <> ''  And A.St_Type = 'OUT OF STATE' AND I.U_IT_IMP = 1
AND A.U_IMPORM NOT IN ('BRANCH TRANSFER','CONSIGNMENT TRANSFER')
SET @BALAMT62A = ISNULL(@AMTA1,0)

SET @AMTC1 = 0
SELECT @AMTC1 = ISNULL(Sum(A.U_FRTAMT),0) FROM STITEM A
INNER JOIN VATTBL V on (A.entry_ty = V.BHENT AND A.Tran_cd = V.Tran_cd AND A.Inv_no = V.INV_NO AND A.It_Code = V.IT_Code AND A.itserial = V.ItSerial) 
INNER JOIN IT_MAST I on (A.It_Code = I.It_Code) WHERE I.U_IT_IMP = 1 AND V.S_TAX <> '' AND V.St_TYPE = 'OUT OF STATE' 
AND A.Entry_Ty in ('ST','SR','CN') AND (A.Date Between @Sdate and @Edate)
SET @BALAMT62A = @BALAMT62A - ISNULL(@AMTC1,0)

SET  @AMTA1 = 0
Select @AMTA1=isnull(Sum(CASE WHEN A.BHENT='ST' THEN A.gro_Amt ELSE -A.GRO_AMT END),0) From VATTBL A INNER JOIN IT_MAST I on (A.It_Code = I.It_Code)
where (A.Date Between @Sdate and @Edate) And A.Bhent  IN( 'ST','CN','SR') And A.s_tax = ''  And A.St_Type = 'OUT OF STATE' AND I.U_IT_IMP = 1
AND A.U_IMPORM NOT IN ('BRANCH TRANSFER','CONSIGNMENT TRANSFER')
SET @BALAMT62B = ISNULL(@AMTA1,0)

SET @AMTC1 = 0
SELECT @AMTC1 = ISNULL(Sum(A.U_FRTAMT),0) FROM STITEM A
INNER JOIN VATTBL V on (A.entry_ty = V.BHENT AND A.Tran_cd = V.Tran_cd AND A.Inv_no = V.INV_NO AND A.It_Code = V.IT_Code AND A.itserial = V.ItSerial) 
INNER JOIN IT_MAST I on (A.It_Code = I.It_Code) WHERE I.U_IT_IMP = 1 AND V.S_TAX = '' AND V.St_TYPE = 'OUT OF STATE' 
AND A.Entry_Ty in ('ST','SR','CN') AND (A.Date Between @Sdate and @Edate)
SET @BALAMT62B = @BALAMT62B - ISNULL(@AMTC1,0)

SET @AMTA1=0
Select @AMTA1=ISNULL(Sum(CASE WHEN A.BHENT='ST' THEN A.gro_Amt ELSE -A.GRO_AMT END),0) From VATTBL A INNER JOIN IT_MAST I on (A.It_Code = I.It_Code)
where (A.Date Between @Sdate and @Edate) And A.Bhent in('ST','CN','SR') and A.s_tax <>''  AND A.ST_TYPE='OUT OF STATE' AND I.U_IT_IMP = 1
AND A.rform_nm IN('E-II','Form E-II','E-II Form','E - 2', 'Form E - 2','E - 2 Form','E-2','Form E-2','E-2 Form','E2','E2 Form','Form E2')
and A.TAX_NAME IN('E-II','Form E-II','E-II Form','E - 2', 'Form E - 2','E - 2 Form','E-2','Form E-2','E-2 Form','E2','E2 Form','Form E2')

SET @BALAMT62A = @BALAMT62A - @AMTA1

SET @AMTA1=0
Select @AMTA1=ISNULL(Sum(CASE WHEN A.BHENT='ST' THEN A.gro_Amt ELSE -A.GRO_AMT END),0) From VATTBL A INNER JOIN IT_MAST I on (A.It_Code = I.It_Code)
where (A.Date Between @Sdate and @Edate) And A.Bhent in('ST','CN','SR') and A.s_tax ='' AND A.ST_TYPE='OUT OF STATE' AND I.U_IT_IMP = 1
AND A.rform_nm IN('E-II','Form E-II','E-II Form','E - 2', 'Form E - 2','E - 2 Form','E-2','Form E-2','E-2 Form','E2','E2 Form','Form E2')
and A.TAX_NAME IN('E-II','Form E-II','E-II Form','E - 2', 'Form E - 2','E - 2 Form','E-2','Form E-2','E-2 Form','E2','E2 Form','Form E2')
SET @BALAMT62B = @BALAMT62B - ISNULL(@AMTA1,0)

--(A) Declare Goods.
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES(1,'1','FA',0,@BALAMT62A + @BALAMT62B,0,0,'')
--(i)  Sold to registered dealers on prescribed declaration (vide declaration
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES(1,'1','FB',0,@BALAMT62A,0,0,'')
--(ii) Sold Otherwise
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES(1,'1','FC',0,@BALAMT62B,0,0,'')

-- Other Goods
--(i) Sold to registerd dealers on prescribed declaration (vide declaration
--(ii) Sold Otherwise
SET @BALAMT62A = 0
SET @BALAMT62B = 0
SET  @AMTA1 = 0  
Select @AMTA1 = isnull(Sum(CASE WHEN A.BHENT='ST' THEN A.gro_Amt ELSE -A.GRO_AMT END),0) From VATTBL A INNER JOIN IT_MAST I on (A.It_Code = I.It_Code)
where (A.Date Between @Sdate and @Edate) And A.Bhent  in('ST','CN','SR') And A.s_tax <> ''  And A.St_Type = 'OUT OF STATE' AND I.U_IT_IMP = 0
AND A.U_IMPORM NOT IN ('BRANCH TRANSFER','CONSIGNMENT TRANSFER')
SET @BALAMT62A = ISNULL(@AMTA1,0)

SET @AMTC1 = 0
SELECT @AMTC1 = ISNULL(Sum(A.U_FRTAMT),0) FROM STITEM A
INNER JOIN VATTBL V on (A.entry_ty = V.BHENT AND A.Tran_cd = V.Tran_cd AND A.Inv_no = V.INV_NO AND A.It_Code = V.IT_Code AND A.itserial = V.ItSerial) 
INNER JOIN IT_MAST I on (A.It_Code = I.It_Code) WHERE I.U_IT_IMP = 0 AND V.S_TAX <> '' AND V.St_TYPE = 'OUT OF STATE' 
AND A.Entry_Ty in ('ST','SR','CN') AND (A.Date Between @Sdate and @Edate)
SET @BALAMT62A = @BALAMT62A - ISNULL(@AMTC1,0)

SET  @AMTA1 = 0
Select @AMTA1=isnull(Sum(CASE WHEN A.BHENT='ST' THEN A.gro_Amt ELSE -A.GRO_AMT END),0) From VATTBL A INNER JOIN IT_MAST I on (A.It_Code = I.It_Code)
where (A.Date Between @Sdate and @Edate) And A.Bhent  IN( 'ST','CN','SR') And A.s_tax = ''  And A.St_Type = 'OUT OF STATE' AND I.U_IT_IMP = 0
AND A.U_IMPORM NOT IN ('BRANCH TRANSFER','CONSIGNMENT TRANSFER')
SET @BALAMT62B = ISNULL(@AMTA1,0)

SET @AMTC1 = 0
SELECT @AMTC1 = ISNULL(Sum(A.U_FRTAMT),0) FROM STITEM A
INNER JOIN VATTBL V on (A.entry_ty = V.BHENT AND A.Tran_cd = V.Tran_cd AND A.Inv_no = V.INV_NO AND A.It_Code = V.IT_Code AND A.itserial = V.ItSerial) 
INNER JOIN IT_MAST I on (A.It_Code = I.It_Code) WHERE I.U_IT_IMP = 0 AND V.S_TAX = '' AND V.St_TYPE = 'OUT OF STATE' 
AND A.Entry_Ty in ('ST','SR','CN') AND (A.Date Between @Sdate and @Edate)
SET @BALAMT62B = @BALAMT62B - ISNULL(@AMTC1,0)

SET @AMTA1=0
Select @AMTA1=ISNULL(Sum(CASE WHEN A.BHENT='ST' THEN A.gro_Amt ELSE -A.GRO_AMT END),0) From VATTBL A INNER JOIN IT_MAST I on (A.It_Code = I.It_Code)
where (A.Date Between @Sdate and @Edate) And A.Bhent in('ST','CN','SR') and A.s_tax <>''  AND A.ST_TYPE='OUT OF STATE' AND I.U_IT_IMP = 0
AND A.rform_nm IN('E-II','Form E-II','E-II Form','E - 2', 'Form E - 2','E - 2 Form','E-2','Form E-2','E-2 Form','E2','E2 Form','Form E2')
and A.TAX_NAME IN('E-II','Form E-II','E-II Form','E - 2', 'Form E - 2','E - 2 Form','E-2','Form E-2','E-2 Form','E2','E2 Form','Form E2')
SET @BALAMT62A = @BALAMT62A - @AMTA1

SET @AMTA1=0
Select @AMTA1=ISNULL(Sum(CASE WHEN A.BHENT='ST' THEN A.gro_Amt ELSE -A.GRO_AMT END),0) From VATTBL A INNER JOIN IT_MAST I on (A.It_Code = I.It_Code)
where (A.Date Between @Sdate and @Edate) And A.Bhent in('ST','CN','SR') and A.s_tax ='' AND A.ST_TYPE='OUT OF STATE' AND I.U_IT_IMP = 0
AND A.rform_nm IN('E-II','Form E-II','E-II Form','E - 2', 'Form E - 2','E - 2 Form','E-2','Form E-2','E-2 Form','E2','E2 Form','Form E2')
and A.TAX_NAME IN('E-II','Form E-II','E-II Form','E - 2', 'Form E - 2','E - 2 Form','E-2','Form E-2','E-2 Form','E2','E2 Form','Form E2')
SET @BALAMT62B = @BALAMT62B - ISNULL(@AMTA1,0)
-- Other Goods
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES(1,'1','FD',0,@BALAMT62A + @BALAMT62B,0,0,'')
--(i) Sold to registerd dealers on prescribed declaration (vide declaration
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES(1,'1','FE',0,@BALAMT62A,0,0,'')
--(ii) Sold Otherwise
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES(1,'1','FF',0,@BALAMT62B,0,0,'')

-- Total
--Select @AMTA1=Sum(Amt1) from #Form221 Where Partsr = '1' and srno in('FB','FC','FD','FE','FF')
Select @AMTA1=Sum(Amt1) from #Form221 Where Partsr = '1' and srno in('FA','FD')
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES(1,'1','FG',0,@AMTA1,0,0,'')

 -->---PART 2
---Tax & Taxable Amount of Sales for the period
 SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,@AMTI1=0,@AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0
 SET @CHAR=65
 DECLARE  CUR_FORM221 CURSOR FOR 
 select distinct level1 from stax_mas 
 OPEN CUR_FORM221
 FETCH NEXT FROM CUR_FORM221 INTO @PER
 WHILE (@@FETCH_STATUS=0)
 BEGIN
	BEGIN
		SELECT @AMTA1 = 0,@AMTA2 = 0,@AMTB1 = 0,@AMTB2 = 0,@AMTC1 = 0,@AMTC2 = 0,@AMTD1 = 0,@AMTD2 = 0,@AMTE1 = 0,@AMTE2 = 0
		SELECT @AMTA1 = ISNULL(SUM(A.VATONAMT),0) - ISNULL(SUM(S.U_FRTAMT),0),
		@AMTA2 = (ISNULL(SUM(A.TAXAMT),0) - ISNULL((SUM(CASE WHEN A.TAXAMT > 0 THEN S.U_FRTAMT ELSE 0 END) * @PER) / 100,0))
		FROM VATTBL A
		INNER JOIN STITEM S ON (A.TRAN_CD = S.Tran_cd AND A.Inv_no = S.Inv_no AND A.It_code = S.It_code AND A.ItSerial = S.itserial)
		where A.Bhent IN('ST') AND A.PER = @PER And A.St_Type = 'OUT OF STATE'
		AND A.U_IMPORM NOT IN ('BRANCH TRANSFER','CONSIGNMENT TRANSFER') AND (A.Date Between @Sdate and @Edate)
		AND A.rform_nm NOT IN('E-II','Form E-II','E-II Form','E - 2', 'Form E - 2','E - 2 Form','E-2','Form E-2','E-2 Form','E2','E2 Form','Form E2')
		and A.TAX_NAME NOT IN('E-II','Form E-II','E-II Form','E - 2', 'Form E - 2','E - 2 Form','E-2','Form E-2','E-2 Form','E2','E2 Form','Form E2')

		SELECT @AMTB1 = ISNULL(SUM(A.VATONAMT),0),@AMTB2 = ISNULL(SUM(A.TAXAMT),0) FROM VATTBL A
		where A.Bhent IN('SR','CN') AND A.PER = @PER And A.St_Type = 'OUT OF STATE'
		AND A.U_IMPORM NOT IN ('BRANCH TRANSFER','CONSIGNMENT TRANSFER') AND (A.Date Between @Sdate and @Edate)
		AND A.rform_nm NOT IN('E-II','Form E-II','E-II Form','E - 2', 'Form E - 2','E - 2 Form','E-2','Form E-2','E-2 Form','E2','E2 Form','Form E2')
		and A.TAX_NAME NOT IN('E-II','Form E-II','E-II Form','E - 2', 'Form E - 2','E - 2 Form','E-2','Form E-2','E-2 Form','E2','E2 Form','Form E2')
	END
  --Net Effect
  Set @NetEFF = @AMTA1-(@AMTB1)
  Set @NetTAX = @AMTA2-(@AMTB2)
  if @NetEFF <> 0
	  begin

		  INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
		  (1,'2',CHAR(@CHAR),@PER,@NETEFF,@NETTAX,(round(@NETTAX,0)-(@NETTAX)),'') 
		  
 		  SET @AMTJ1=@AMTJ1+@NETEFF --TOTAL TAXABLE AMOUNT
		  SET @AMTK1=@AMTK1+@NETTAX --TOTAL TAX
		  --SET @AMTK1=@AMTK1+((@NETEFF *@PER)/100)		  
		  --SET @AMTK11=@AMTK11+(round(@NETTAX,0)-(@NETTAX))
		  SET @CHAR=@CHAR+1
	  end
  FETCH NEXT FROM CUR_FORM221 INTO @PER
 END
 CLOSE CUR_FORM221
 DEALLOCATE CUR_FORM221
if not exists(select * from #FORM221 where PARTSR ='2') 
begin
	INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES  (1,'2',' ',0,0,0,0,'') 
end
 
---Total of Tax & Taxable Amount of Sales for the period
 INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES(1,'3','Z',0,@AMTJ1,@AMTK1,0,'')
-- (1,'6','Z',0,@AMTJ1-@AMTK1,@AMTK1,0)
  
Declare @INVNO VARCHAR(250),@CHLN_DATE DATETIME ,@Bank_nm varchar(250)  
  
Declare cr_castPayable cursor FOR
select B.u_chALNO,b.u_chALdt,A.Gro_amt,b.bank_nm
from VATTBL A
Inner join Bpmain B on (A.Bhent = B.Entry_ty and A.Tran_cd = B.Tran_cd)
where BHENT = 'BP' And B.Date Between @sdate and @edate And B.Party_nm like '%CST Payable%' ORDER BY B.u_chALdt
SET @INVNO =''
SET @CHLN_DATE =NULL
SET @AMTA1 = 0.00
set @Bank_nm = ''
OPEN cr_castPayable
FETCH NEXT FROM cr_castPayable INTO @INVNO,@CHLN_DATE,@AMTA1,@Bank_nm
 WHILE (@@FETCH_STATUS=0)
 BEGIN
		begin
		  INSERT INTO #form221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm,DATE,INV_NO) VALUES
		  (1,'4','Z',0,0,@AMTA1,0,@Bank_nm,@CHLN_DATE,@INVNO)
		  PRINT @CHLN_DATE
		  PRINT @INVNO
		END
	FETCH NEXT FROM cr_castPayable INTO @INVNO,@CHLN_DATE,@AMTA1,@Bank_nm
END
CLOSE cr_castPayable
DEALLOCATE cr_castPayable
IF NOT EXISTS (SELECT SRNO FROM #FORM221 WHERE PART=1 AND PARTSR='4' )
BEGIN
	 INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES(1,'4','Z',0,0,0,0,'')
END

SET @AMTA1 = 0
select @AMTA1 = isnull(sum(case when PARTSR='3' then AMT2 else -AMT2 end),0) from #FORM221 where PARTSR IN('3','4')
		  INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES(1,'5','',0,0,@AMTA1,0,'')
PRINT @AMTA1
  --<---PART 6


--Updating Null Records  
Update #form221 set  PART = isnull(Part,0) , Partsr = isnull(PARTSR,''), SRNO = isnull(SRNO,''),
		             RATE = isnull(RATE,0), AMT1 = isnull(AMT1,0), AMT2 = isnull(AMT2,0), 
					 AMT3 = isnull(AMT3,0), INV_NO = isnull(INV_NO,''), DATE = isnull(Date,''), 
					 PARTY_NM = isnull(Party_nm,''), ADDRESS = isnull(Address,''),
					 FORM_NM = isnull(form_nm,''), S_TAX = isnull(S_tax,'')--, Qty = isnull(Qty,0),  ITEM =isnull(item,''),

 SELECT * FROM #FORM221 order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int)
 --SELECT * FROM #FORM221_1 --order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int)
 
 END
--Print 'UA CST FORM 01'

