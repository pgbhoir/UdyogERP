IF EXISTS(SELECT XTYPE,NAME FROM SYSOBJECTS WHERE XTYPE='P' AND name ='usp_rep_TN_Vat_Form1')
BEGIN
	DROP PROCEDURE usp_rep_TN_Vat_Form1
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
=====================
Modify   : By Suraj Kumawat 
Date     : 13-05-2015 : Bug 26170
=====================
EXECUTE usp_rep_TN_Vat_Form1 '','','','04/01/2015','03/31/2016','','','','',0,0,'','','','','','','','','2015-2016',''
*/
create PROCEDURE [dbo].[usp_rep_TN_Vat_Form1]
@TMPAC NVARCHAR(50),@TMPIT NVARCHAR(50),@SPLCOND VARCHAR(8000),@SDATE DATETIME,@EDATE SMALLDATETIME
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
DECLARE @RATE NUMERIC(12,2),@AMTA1 NUMERIC(12,2),@AMTA2 NUMERIC(12,2),@AMTA3 NUMERIC(12,2),@AMTA4 NUMERIC(12,2),@Bal_AMTA1 NUMERIC(12,2),@Bal_AMTA2 NUMERIC(12,2),@Bal_AMTA3 NUMERIC(12,2),@Bal_AMTA4 NUMERIC(12,2)
----Temporary Cursor1
SELECT PART=3,PARTSR='AAA',SRNO='AAA',RATE=99.999,AMT1=NET_AMT,AMT2=M.TAXAMT,AMT3=M.TAXAMT,AMT4=M.TAXAMT,
M.INV_NO,M.DATE,PARTY_NM=AC1.AC_NAME,ADDRESS=Ltrim(AC1.Add1)+' '+Ltrim(AC1.Add2)+' '+Ltrim(AC1.Add3),STM.FORM_NM,AC1.S_TAX,PARTY_NM1=ac1.ac_NAME
INTO #FORMVAT_I
FROM PTACDET A 
INNER JOIN STMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME)
INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID)
WHERE 1=2

------
Declare @MultiCo	VarChar(3)
Declare @MCON as NVARCHAR(2000)
IF Exists(Select A.ID From SysObjects A Inner Join SysColumns B On(A.ID = B.ID) Where A.[Name] = 'STMAIN' And B.[Name] = 'DBNAME')
Begin	------Fetch Records from Multi Co. Data
	 Set @MultiCo = 'YES'
	 
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
--------------------------------
---Purchase turnover  under Section 12 (Rs.)
--PT
SET @AMTA1 = 0
Set @AmtA2 = 0
Select @AMTA3=isnull(Sum(a.vatonamt),0),@AmtA4=isnull(Sum(a.taxamt),0) From VATTBL a where (a.Date Between @Sdate and @Edate) And a.Bhent in('PT','P1','EP')
INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM,PARTY_NM1) VALUES  (1,'1','',0,@AmtA1,@AmtA2,@AmtA3,@AmtA4,'','')
--(a) Goods Taxable at 1%  --(a)Local sales at 1%
SET @AmtA1= 0
SET @AmtA2= 0
SET @AmtA3= 0
SET @AmtA4= 0
--PT
Select @AmtA1=isnull(SUM(VATONAMT),0),@AmtA2=isnull(Sum(taxamt),0) From vattbl  where st_type in ('LOCAL','') and Per=1 and BHENT in ('PT','P1','EP') and itemtype  = 'I' and (Date Between @sdate and @edate)
--ST
Select @AmtA3=isnull(SUM(VATONAMT),0),@AmtA4 =isnull(Sum(taxamt),0) From vattbl  where st_type in ('LOCAL','') and Per=1 and BHENT ='ST' and (Date Between @sdate and @edate)
INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM,PARTY_NM1) VALUES  (1,'1','A',0,@AmtA1,@AmtA2,@AmtA3,@AmtA4,'','')

--(b) Goods Taxable at 2% --(b)Local sales at 2%
SET @AmtA1= 0
SET @AmtA2= 0
SET @AmtA3= 0
SET @AmtA4= 0
--PT
Select @AmtA1=isnull(SUM(VATONAMT),0),@AmtA2=isnull(Sum(taxamt),0) From vattbl  where st_type in ('LOCAL','') and Per=2 and BHENT in ('PT','P1','EP') and itemtype  = 'I' and (Date Between @sdate and @edate)
--ST
Select @AmtA3=isnull(SUM(VATONAMT),0),@AmtA4 =isnull(Sum(taxamt),0) From vattbl  where st_type in ('LOCAL','') and Per=2 and BHENT ='ST' and (Date Between @sdate and @edate)
INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM,PARTY_NM1) VALUES  (1,'1','B',0,@AmtA1,@AmtA2,@AmtA3,@AmtA4,'','')

--(C) Goods Taxable at 4% --(b)Local sales at 4%
SET @AmtA1= 0
SET @AmtA2= 0
SET @AmtA3= 0
SET @AmtA4= 0
--PT
Select @AmtA1=isnull(SUM(VATONAMT),0),@AmtA2=isnull(Sum(taxamt),0) From vattbl  where st_type in ('LOCAL','') and Per=4 and BHENT in ('PT','P1','EP') and itemtype  = 'I' and (Date Between @sdate and @edate)
--ST
Select @AmtA3=isnull(SUM(VATONAMT),0),@AmtA4 =isnull(Sum(taxamt),0) From vattbl  where st_type in ('LOCAL','') and Per=4 and BHENT ='ST' and (Date Between @sdate and @edate)
INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM,PARTY_NM1) VALUES  (1,'1','C',0,@AmtA1,@AmtA2,@AmtA3,@AmtA4,'','')   

--(D) Goods Taxable at 5% --(b)Local sales at 5%
SET @AmtA1= 0
SET @AmtA2= 0
SET @AmtA3= 0
SET @AmtA4= 0
--PT
Select @AmtA1=isnull(SUM(VATONAMT),0),@AmtA2=isnull(Sum(taxamt),0) From vattbl  where st_type in ('LOCAL','') and Per=5 and BHENT in ('PT','P1','EP') and itemtype  = 'I' and (Date Between @sdate and @edate)
--ST
Select @AmtA3=isnull(SUM(VATONAMT),0),@AmtA4 =isnull(Sum(taxamt),0) From vattbl  where st_type in ('LOCAL','') and Per=5 and BHENT ='ST' and (Date Between @sdate and @edate)
INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM,PARTY_NM1) VALUES  (1,'1','D',0,@AmtA1,@AmtA2,@AmtA3,@AmtA4,'','')   

--(E) Goods Taxable at 12.5% --(b)Local sales at 12.5%
SET @AmtA1= 0
SET @AmtA2= 0
SET @AmtA3= 0
SET @AmtA4= 0
--PT
Select @AmtA1=isnull(SUM(VATONAMT),0),@AmtA2=isnull(Sum(taxamt),0) From vattbl  where st_type in ('LOCAL','') and Per=12.5 and BHENT in ('PT','P1','EP') and itemtype  = 'I' and (Date Between @sdate and @edate)
--ST
Select @AmtA3=isnull(SUM(VATONAMT),0),@AmtA4 =isnull(Sum(taxamt),0) From vattbl  where st_type in ('LOCAL','') and Per=12.5 and BHENT ='ST'  and (Date Between @sdate and @edate)
INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM,PARTY_NM1) VALUES  (1,'1','E',0,@AmtA1,@AmtA2,@AmtA3,@AmtA4,'','')   

--(F) Goods Taxable at 14.5% --(b)Local sales at 14.5%
SET @AmtA1= 0
SET @AmtA2= 0
SET @AmtA3= 0
SET @AmtA4= 0
--PT
Select @AmtA1=isnull(SUM(VATONAMT),0),@AmtA2=isnull(Sum(taxamt),0) From vattbl  where st_type in ('LOCAL','') and Per=14.5 and BHENT in ('PT','P1','EP') and itemtype  = 'I' and (Date Between @sdate and @edate)
--ST
Select @AmtA3=isnull(SUM(VATONAMT),0),@AmtA4 =isnull(Sum(taxamt),0) From vattbl  where st_type in ('LOCAL','') and Per=14.5 and BHENT ='ST' and (Date Between @sdate and @edate)
INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM,PARTY_NM1) VALUES  (1,'1','F',0,@AmtA1,@AmtA2,@AmtA3,@AmtA4,'','')
---(g) Purchase under section 12 --
SET @AmtA1= 0
SET @AmtA2= 0
SET @AmtA3= 0
SET @AmtA4= 0
INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM,PARTY_NM1) VALUES  (1,'1','G',0,@AmtA1,@AmtA2,@AmtA3,@AmtA4,'','')
---Total =(a)+(b)+(c)+(d)+(e)+(f)+(g)
SET @AmtA1= 0
SET @AmtA2= 0
SET @AmtA3= 0
SET @AmtA4= 0
SELECT @AmtA1 =isnull(SUM(amt1),0),@AmtA2 =isnull(SUM(amt2),0),@AmtA3 =isnull(SUM(amt3),0),@AmtA4 =isnull(SUM(amt4),0) FROM #FORMVAT_I where PART=1 and PARTSR ='1' and SRNO in('A','B','C','D','E','F','G')
INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM,PARTY_NM1) VALUES  (1,'1','H',0,@AmtA1,@AmtA2,@AmtA3,@AmtA4,'','')
--Less   : Reverse Credit *  --- Less   : Sales return/Unfructified Sales
SET @AmtA1= 0
SET @AmtA2= 0
SET @AmtA3= 0
SET @AmtA4= 0
--SR
Select @AmtA3=isnull(SUM(VATONAMT),0),@AmtA4 =isnull(Sum(taxamt),0) From vattbl  where st_type in ('LOCAL','') and BHENT ='SR'  and (Date Between @sdate and @edate)
INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM,PARTY_NM1) VALUES  (1,'1','I',0,@AMTA1,@AMTA2,@AMTA3,@AMTA4,'','')
--Less   : ITC refund claimed as per G.O.  -- Total(F) 
SET @AmtA1= 0
SET @AmtA2= 0
SET @AmtA3= 0
SET @AmtA4= 0
select @AmtA3 = ISNULL(SUM((CASE WHEN SRNO ='H' THEN amt3 ELSE -AMT3 END )),0),
	   @AmtA4 =ISNULL(SUM((CASE WHEN SRNO ='H' THEN amt4 ELSE -AMT4 END )),0) from  #FORMVAT_I where PART=1 and PARTSR='1' and SRNO in('H','I')
INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM,PARTY_NM1) VALUES  (1,'1','J',0,@AmtA1,@AmtA2,@AmtA3,@AmtA4,'','')
--TOTAL (NET)    (B)  --Zero rate Sales
SET @AmtA1= 0
SET @AmtA2= 0
SET @AmtA3= 0
SET @AmtA4= 0
--ST
Select @AmtA3=isnull(SUM(vatonamt),0),@AmtA4=isnull(Sum(taxamt),0) From vattbl  where st_type in ('LOCAL','') and BHENT ='ST' and (Date Between @sdate and @edate) and TAX_NAME <> '' and PER = 0
--TOTAL(NET)(B)
select @AmtA1 = ISNULL(SUM((CASE WHEN SRNO ='H' THEN amt1 ELSE -amt1 END )),0),
	   @AmtA2 =ISNULL(SUM((CASE WHEN SRNO ='H' THEN amt2 ELSE -AMT2 END )),0) from  #FORMVAT_I where PART=1 and PARTSR='1' and SRNO in('H','I')
INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM,PARTY_NM1) VALUES  (1,'1','K',0,@AmtA1,@AmtA2,@AmtA3,@AmtA4,'','')

--Goods Exempted (C)  --1.Adjustment of advance tax
SET @AmtA1= 0
SET @AmtA2= 0
SET @AmtA3= 0
SET @AmtA4= 0
SELECT @AmtA1=ISNULL(SUM(VATONAMT),0),@AmtA2=ISNULL(SUM(TAXAMT),0) FROM VATTBL where BHENT IN('PT','EP','P1') AND ITEMTYPE='I' AND TAX_NAME ='Exempted' and (date between @sdate and @edate)
SELECT @AmtA4=ISNULL(SUM(A.vatonamt),0) FROM VATTBL A INNER JOIN BPMAIN B ON (A.TRAN_CD =B.Tran_cd  and A.BHENT =B.entry_ty ) WHERE B.tdspaytype = 3 AND A.AC_NAME ='VAT PAYABLE' and (A.date between @sdate and @edate)
INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM,PARTY_NM1) VALUES  (1,'1','L',0,@AmtA1,@AmtA2,@AmtA3,@AmtA4,'','') 

--					 --2.Entry Tax Paid,if any	
INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,PARTY_NM1) VALUES  (1,'1','M',0,0,0,0,'','') 

					--Less   total(1+2)
SET @AmtA1= 0
SET @AmtA2= 0
SET @AmtA3= 0
SET @AmtA4= 0
select @AmtA3 = isnull(SUM(amt3),0),@AmtA4 = isnull(SUM(amt4),0)	from #FORMVAT_I where PART=1 and PARTSR='1' and SRNO in('L','M')
INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM,PARTY_NM1) VALUES  (1,'1','N',0,@AMTA1,@AMTA2,@AMTA3,@AMTA4,'','') 
					--Net tax payble
					--(T1)=(F1)-(H1) 
SET @AmtA1= 0
SET @AmtA2= 0
SET @AmtA3= 0
SET @AmtA4= 0
select @AmtA4 = ISNULL(SUM((CASE WHEN SRNO='J' THEN amt4 ELSE -AMT4 END)),0)from #FORMVAT_I where PART=1 and PARTSR='1' and SRNO in('J','N')
INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM,PARTY_NM1) VALUES  (1,'1','O',0,0,0,0,@AmtA4,'','') 
--(T2)=(A1)-(T1)
select @AmtA4 = ISNULL(SUM((CASE WHEN SRNO=' ' THEN amt4 ELSE -AMT4 END)),0)from #FORMVAT_I where PART=1 and PARTSR='1' and SRNO in(' ','O')
INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM,PARTY_NM1) VALUES  (1,'1','P',0,0,0,0,@AmtA4,'','') 

--INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,PARTY_NM1) VALUES  (1,'1','P',0,0,0,0,'','') 


-----------------------------------------
-- OUTPUT ITEMS --(Input Tax credit not allowable)
--(a) upto previous month --Exempted Sales
SET @AmtA1= 0
SET @AmtA2= 0
SET @AmtA3= 0
SET @AmtA4= 0
SELECT @AmtA3=ISNULL(SUM(vatonamt),0) FROM VATTBL WHERE BHENT='ST' AND TAX_NAME='EXEMPTED' AND (DATE BETWEEN @SDATE AND @EDATE) AND ST_TYPE IN('LOCAL','')
INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,PARTY_NM1) VALUES  (2,'2','A',0,@AmtA1,@AmtA2,@AmtA3,'','')
--(b) During the month--Less : Sales return/unfructified sales
SET @AmtA1= 0
SET @AmtA2= 0
SET @AmtA3= 0
SET @AmtA4= 0
SELECT @AmtA1=ISNULL(SUM(VATONAMT),0),@AmtA2=ISNULL(SUM(TAXAMT),0) FROM VATTBL WHERE BHENT in('PT','P1','EP') AND (DATE BETWEEN @SDATE AND @EDATE) AND ST_TYPE IN('LOCAL','')  AND itemtype='C'
SELECT @AmtA3=ISNULL(SUM(vatonamt),0),@AmtA4=ISNULL(SUM(TAXAMT),0) FROM VATTBL WHERE BHENT='SR' AND (DATE BETWEEN @SDATE AND @EDATE) AND ST_TYPE IN('LOCAL','') and TAX_NAME ='EXEMPTED'
INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM,PARTY_NM1) VALUES  (2,'2','B',0,@AmtA1,@AmtA2,@AmtA3,@AmtA4,'','')   
--Total     (J)
SET @AmtA1= 0
SET @AmtA2= 0
SET @AmtA3= 0
SET @AmtA4= 0
select @AmtA1=ISNULL(SUM(AMT1),0),@AmtA2=ISNULL(SUM(AMT2),0),@AmtA3 = ISNULL(SUM((CASE WHEN SRNO='A' THEN amt3 ELSE -amt3 END)),0)from #FORMVAT_I where PART=2 and PARTSR='2' and SRNO in('A','B')
INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,PARTY_NM1) VALUES  (2,'2','C',0,@AmtA1,@AmtA2,@AmtA3,'','')   
--Less Reverse Credit  --Sales under section 10
INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,PARTY_NM1) VALUES  (2,'2','D',0,0,0,0,'','')   
--Less :ITC refung claimed as per G.O.  --1.Adjustment of advance tax
INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,PARTY_NM1) VALUES  (2,'2','E',0,0,0,0,'','')   
--Total(NET)   (D)--2.Entry Tax paid,TDS,refund,if any
SET @AmtA1= 0
SET @AmtA2= 0
SET @AmtA3= 0
SET @AmtA4= 0
select @AmtA1=ISNULL(SUM((CASE WHEN SRNO='C' THEN amt1 ELSE -amt1 END)),0),
    @AmtA2=ISNULL(SUM((CASE WHEN SRNO='C' THEN amt2 ELSE -amt2 END)),0)  from #FORMVAT_I where PART=2 and PARTSR='2' and SRNO in('C','D','E')
INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,PARTY_NM1) VALUES  (2,'2','F',0,@AmtA1,@AmtA2,0,'','')   
--Total Input Tax Credit(E) * (A1)+(B1)+(D1) --Less : Total (1+2)
SET @AmtA1= 0
SET @AmtA2= 0
SET @AmtA3= 0
SET @AmtA4= 0
select @AmtA2=ISNULL(SUM(amt2),0)  from #FORMVAT_I where (PART=1 and PARTSR='1' and SRNO in('','K')) or (PART=2 and PARTSR='2' and SRNO ='F')
INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,PARTY_NM1) VALUES  (2,'2','G',0,0,@AmtA2,0,'','')   
--Total turnover (f)+(j)+(s)
SET @AmtA1= 0
SET @AmtA2= 0
SET @AmtA3= 0
SET @AmtA4= 0
select @AmtA4 = ISNULL(SUM(AMT4),0)from #FORMVAT_I where PART=1 and PARTSR='1' and SRNO='P'
INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM,PARTY_NM1) VALUES  (2,'2','H',0,0,0,0,@AmtA4,'','')   
--INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,PARTY_NM1) VALUES  (2,'2','I',0,0,0,0,'','')   
--INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,PARTY_NM1) VALUES  (2,'2','J',0,0,0,0,'','')   

--INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,PARTY_NM1) VALUES  (2,'2','K',0,0,0,0,'','')   
--INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,PARTY_NM1) VALUES  (2,'2','L',0,0,0,0,'','')   
--INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,PARTY_NM1) VALUES  (2,'2','M',0,0,0,0,'','')   
------------------



----------------
--(1).Output Tax Paid and claimed  Refund
INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,PARTY_NM1) VALUES  (2,'3','A',0,0,0,0,'','')    
--(2).Tax Deferred
INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,PARTY_NM1) VALUES  (2,'3','B',0,0,0,0,'','')   
--NET TAX PAYABLE (T4) REVISED
INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,PARTY_NM1) VALUES  (2,'3','C',0,0,0,0,'','')   
----------

INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,PARTY_NM1) VALUES  (2,'4','A',0,0,0,0,'','')   

INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,PARTY_NM1) VALUES  (2,'5','A',0,0,0,0,'','')   
----A.Payment Details 
DECLARE @GRO_AMT NUMERIC(17,2) ,@U_CHALNO VARCHAR(50),@U_CHALDT SMALLDATETIME,@bank_nm VARCHAR(150),@BSRCODE VARCHAR(100)
SET @GRO_AMT =0
SET @U_CHALNO=''
SET @U_CHALDT =''
SET @bank_nm=''
SET @BSRCODE=''
SET @Bal_AMTA1 = 0
DECLARE BANK_PAY_DETAIL CURSOR FOR select A.GRO_AMT,B.U_CHALNO,B.U_CHALDT,B.bank_nm,C.BSRCODE from VATTBL A INNER JOIN BPMAIN B ON(A.TRAN_CD=B.TRAN_CD AND A.BHENT =B.ENTRY_TY)
INNER JOIN AC_MAST C ON (B.bank_nm =C.ac_name ) where A.BHENT ='BP' AND A.AC_NAME ='VAT PAYABLE'
OPEN BANK_PAY_DETAIL
FETCH BANK_PAY_DETAIL  INTO @GRO_AMT,@U_CHALNO,@U_CHALDT,@bank_nm,@BSRCODE
WHILE(@@FETCH_STATUS =0 )
BEGIN
	BEGIN
		SET @Bal_AMTA1 = @Bal_AMTA1 + ISNULL(@GRO_AMT,0)
		INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,PARTY_NM1,S_TAX,DATE,INV_NO) VALUES  (2,'6','A',0,@GRO_AMT,0,0,@bank_nm,'',@BSRCODE,@U_CHALDT,@U_CHALNO)
	END
	FETCH BANK_PAY_DETAIL  INTO @GRO_AMT,@U_CHALNO,@U_CHALDT,@bank_nm,@BSRCODE
	
END
CLOSE BANK_PAY_DETAIL
DEALLOCATE BANK_PAY_DETAIL
---Blank records insert into section 2
if not exists(select top 1 PARTSR from #FORMVAT_I where part=2 and partsr='6' and srno='A')
BEGIN
	INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,PARTY_NM1,S_TAX,DATE,INV_NO) VALUES  (2,'6','A',0,@GRO_AMT,0,0,@bank_nm,'',@BSRCODE,@U_CHALDT,@U_CHALNO)
END
---Updating total vat payable value in section 5 below
 UPDATE #FORMVAT_I  SET AMT2=@Bal_AMTA1 WHERE PART=2  AND PARTSR='5' AND SRNO='A'
----
INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,PARTY_NM1) VALUES  (2,'7','A',0,0,0,0,'','')   

INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,PARTY_NM1) VALUES  (2,'8','A',0,0,0,0,'','')   
INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,PARTY_NM1) VALUES  (2,'9','A',0,0,0,0,'','') 
---
INSERT INTO #FORMVAT_I (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,PARTY_NM1) VALUES  (2,'10','A',0,0,0,0,'','') 

------------------------------------------------------15.4/15.8 END----------------------------------------------
----------------------------------------PART XII- B END------------------------------------------------------------------------------------------



Update #FORMVAT_I set  PART = isnull(Part,0) , Partsr = isnull(PARTSR,''), SRNO = isnull(SRNO,''),
		             RATE = isnull(RATE,0), AMT1 = isnull(AMT1,0), AMT2 = isnull(AMT2,0), 
					 AMT3 = isnull(AMT3,0), INV_NO = isnull(INV_NO,''), DATE = isnull(Date,''), 
					 PARTY_NM = isnull(Party_nm,''), ADDRESS = isnull(Address,''), 
					 FORM_NM = isnull(form_nm,''), S_TAX = isnull(S_tax,''),PARTY_NM1 = isnull(party_nm1,'')  --, Qty = isnull(Qty,0), ITEM =isnull(item,'')


    
SELECT * FROM #FORMVAT_I order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int)    
  
    
END
----Print 'KA VAT FORM 115'

