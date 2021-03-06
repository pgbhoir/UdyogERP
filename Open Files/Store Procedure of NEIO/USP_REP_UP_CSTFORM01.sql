IF EXISTS (SELECT XTYPE, NAME FROM SYSOBJECTS WHERE XTYPE = 'P' AND NAME = 'USP_REP_UP_CSTFORM01')
BEGIN
	DROP PROCEDURE USP_REP_UP_CSTFORM01
END
GO
set ANSI_NULLS ON
GO
set QUOTED_IDENTIFIER ON
go
 -- =============================================
 -- Author:  Hetal L Patel
 -- Create date: 16/05/2007
 -- Description: This Stored procedure is useful to generate UP CST FORM 01
 -- Modify date: 16/05/2007 
 -- Modified By: Madhavi Penumalli
 -- Modify date: 04/12/2009 (Updated)
 -- Modified By: GAURAV R. TANNA
 -- Modify date: 08/07/2015
 -- Modified By: Suraj Kumawat  for bug-26465
 -- Modify date: 26/06/2016
 
 -- =============================================
CREATE PROCEDURE [dbo].[USP_REP_UP_CSTFORM01]
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
 ,@VSDATE=@SDATE
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
 DECLARE @PER NUMERIC(12,2),@TAXAMT NUMERIC(12,2),@CHAR INT,@LEVEL NUMERIC(12,2),@BALAMT NUMERIC (14,2)

Declare @NetEff as numeric (12,2), @NetTax as numeric (12,2)

---Temporary Cursor
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
-----
-----SELECT * from #form221_1 where (Date Between @Sdate and @Edate) and Bhent in('EP','PT','CN') and TAX_NAME In('','NO-TAX') and U_imporm = ''
-----
--->PART 1-5 
 SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,@AMTI1=0,@AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0 
---1
---
SET @AMTA1=0
select @AMTA1=ISNULL(SUM(case when bhent ='PT' THEN + GRO_AMT ELSE -GRO_AMT END),0) FROM VATTBL WHERE BHENT in('PT','DN','PR') 
And St_type = 'Out of State'  AND (LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(tax_name,'FORM',''),'-',''),'/',''),' ',''))) IN('E1','E2','E 1','E 2','E I','E II','EI','EII')) And VATTYPE = ''  and S_TAX <> ''
INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'1','A',0,@AMTA1,0,0,'')

---VAT Purchase 
--- Purchase in U.P. in Ex. U.P. Principal's a/c
SET @AMTA1=0
Set @AMTA1 =  0
INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES  (1,'1','B',0,@AMTA1,0,0,'')
 ---Unregister & Import Purchase 
----7. Any other purchase
SET @AMTA1=0
select @AMTA1=ISNULL(SUM(case when bhent ='PT' THEN + GRO_AMT ELSE -GRO_AMT END),0) FROM VATTBL WHERE BHENT in ('PT','PR','DN')
And St_type in('Out of State')  AND (LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(tax_name,'FORM',''),'-',''),'/',''),' ',''))) not IN('E1','E2','E 1','E 2','E I','E II','EI','EII'))
 And VATTYPE = ''  and S_TAX <> ''
INSERT INTO #FORM221  (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES  (1,'1','C',0,@AMTA1,0,0,'')
 
SET @AMTA1=0 
select @AMTA1=ISNULL(SUM(AMT1),0) FROM #FORM221 WHERE Partsr = '1'
 INSERT INTO #FORM221
 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
 (1,'1','D',0,@AMTA1,0,0,'')

---1
---2
--Non VAT Purchase
---Interstate purchase by transfer of documents during movement of  goods
SET @AMTA1=0
select @AMTA1=ISNULL(SUM(case when bhent ='PT' THEN + GRO_AMT ELSE -GRO_AMT END),0) FROM VATTBL WHERE BHENT in ('PT','PR','DN')
And St_type  in('Out of State')   And VATTYPE = 'Non Vat' and s_tax <> ''
AND (LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(tax_name,'FORM',''),'-',''),'/',''),' ',''))) IN('E1','E2','E 1','E 2','E I','E II','EI','EII'))
INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES  (1,'2','A',0,@AMTA1,0,0,'')

---
----
SET @AMTA1=0
INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES  (1,'2','B',0,0,0,0,'')

---
SET @AMTA1=0
select @AMTA1=ISNULL(SUM(case when bhent ='PT' THEN + GRO_AMT ELSE -GRO_AMT END),0) FROM VATTBL WHERE BHENT in ('PT','PR','DN')
And St_type in('Out of State') And VATTYPE = 'Non Vat' and s_tax <> ''
AND (LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(tax_name,'FORM',''),'-',''),'/',''),' ',''))) NOT IN('E1','E2','E 1','E 2','E I','E II','EI','EII'))

INSERT INTO #FORM221  (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES  (1,'2','C',0,@AMTA1,0,0,'')

SET @AMTA1=0
select @AMTA1=ISNULL(SUM(AMT1),0) FROM #FORM221 WHERE Partsr = '2'  
INSERT INTO #FORM221  (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES  (1,'2','D',0,@AMTA1,0,0,'')

SET @AMTA1=0 
select @AMTA1=ISNULL(sum(AMT1),0) FROM #FORM221 WHERE ((Partsr = '1' And SrNo = 'D') Or (Partsr = '2' And SrNo = 'D'))
INSERT INTO #FORM221  (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES  (1,'2','E',0,@AMTA1,0,0,'')


---2
---3
----8    CALCULATION OF GROSS INTER-STATE SALE
 SET @AMTA1=0
 INSERT INTO #FORM221  (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES  (1,'3','A',0,@AMTA1,0,0,'')
Set @BALAMT = 0
set @AMTA1=0
select @AMTA1=ISNULL(SUM(GRO_AMT),0) FROM VATTBL WHERE  BHENT ='st' and ( DATE between @SDATE and @EDATE )
 Set @BALAMT = @BALAMT + ISNULL(@AMTA1,0)
 INSERT INTO #FORM221  (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES  (1,'3','B',0,@AMTA1,0,0,'') 

set @AMTA1=0
 INSERT INTO #FORM221  (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES  (1,'3','C',0,@AMTA1,0,0,'')
set @AMTA1=0
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
(1,'3','D',0,@AMTA1,0,0,'')

-- b (ii)
SET @AMTA1 = 0
Select @AMTA1=ISNULL(SUM(case when bhent ='ST' THEN + GRO_AMT ELSE -GRO_AMT END),0) From VATTBL where (Date Between @Sdate and @Edate)
And Bhent in('ST','SR','CN')
And St_Type = 'OUT OF COUNTRY' And U_IMPORM  like'%Export Out of India%'
Set @AMTA1 = IsNull(@AMTA1,0)  
Set @BALAMT = @BALAMT - ISNULL(@AMTA1,0)
INSERT INTO #FORM221
 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
 (1,'3','E',0,@AMTA1,0,0,'')

-- b (iii)
SET @AMTA1 = 0
Select @AMTA1=ISNULL(SUM(case when i.bhent ='ST' THEN + i.GRO_AMT ELSE -i.GRO_AMT END),0) From VATTBL i
INNER JOIN STmain m on (m.entry_ty=i.bhent and m.tran_cd=i.tran_cd)
where (i.Date Between @Sdate and @Edate) And i.Bhent in('ST')  And i.St_Type = 'OUT OF COUNTRY' 
And m.VATMTYPE like '%Sale in the course of import into India%'
Set @AMTA1 = IsNull(@AMTA1,0)  
Set @BALAMT = @BALAMT - ISNULL(@AMTA1,0)
INSERT INTO #FORM221
 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
 (1,'3','F',0,@AMTA1,0,0,'')

-- b (iv)
SET @AMTA1 = 0
Select @AMTA1=ISNULL(SUM(case when i.bhent ='ST' THEN + i.GRO_AMT ELSE -i.GRO_AMT END),0) From VATTBL i
INNER JOIN STmain m on (m.entry_ty=i.bhent and m.tran_cd=i.tran_cd)
where (i.Date Between @Sdate and @Edate) And i.Bhent in('ST')  And i.St_Type = 'OUT OF COUNTRY' 
And m.VATMTYPE not like'%Sale in the course of import into India%' And i.U_IMPORM not like '%Export Out of India%'
Set @AMTA1 = IsNull(@AMTA1,0)  
Set @BALAMT = @BALAMT - ISNULL(@AMTA1,0)
 INSERT INTO #FORM221
 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
 (1,'3','G',0,@AMTA1,0,0,'')

-- b (v)
SET @AMTA1 = 0
Select @AMTA1=ISNULL(SUM(case when bhent ='ST' THEN + GRO_AMT ELSE -GRO_AMT END),0) From vattbl where (Date Between @Sdate and @Edate) 
And Bhent in('ST','SR','CN') And St_Type in('LOCAL','')
Set @AMTA1 = IsNull(@AMTA1,0)  
Set @BALAMT = @BALAMT - ISNULL(@AMTA1,0)
 INSERT INTO #FORM221
 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
 (1,'3','H',0,@AMTA1,0,0,'')
 
 -- b(vi)
SET @AMTA1 = 0
--DECLARE @RAMTA1 NUMERIC(14,2),@RAMTA2 NUMERIC(14,2),@LSTTHREEMTHDATE DATETIME
--SET @RAMTA1 = 0
--SET @RAMTA2 = 0
--Set @LSTTHREEMTHDATE = DATEADD(MONTH,-6, convert(datetime,@Edate,104)) 

--SELECT @AMTA1=Sum(Gro_Amt) FROM VATTBL A  
--inner join SRITREF sr on (sr.tran_cd = A.tran_cd And sr.it_code = A.it_code And sr.entry_ty = A.bhent)
--WHERE A.BHENT in ('SR') AND A.ST_TYPE ='OUT OF STATE' AND (sr.RDate Between @Sdate and @Edate)
--AND A.Date <= DATEADD(MONTH,6, convert(datetime,sr.RDate,104)) 
-- for bug-26465 
SELECT @AMTA1=isnull(Sum(Gro_Amt),0) FROM VATTBL  A INNER JOIN PRITREF B ON ( A.BHENT = B.entry_ty  AND A.TRAN_CD =B.TRAN_CD  AND A.ItSerial =B.Itserial)
WHERE A.BHENT ='PR' and datediff(mm,b.rdate,a.date) <=6  and  ( a.date between @sdate and @edate )
SET @BALAMT =@BALAMT - ISNULL(@AMTA1,0)

SELECT @AMTA1 = @AMTA1 + isnull(Sum(Gro_Amt),0) FROM VATTBL  WHERE BHENT ='ST' AND U_IMPORM ='Purchase Return' AND  date between @sdate and @edate 
 Set @BALAMT = @BALAMT + ISNULL(@AMTA1,0)
 
 INSERT INTO #FORM221  (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES 
 (1,'3','I',0,@AMTA1,0,0,'')
 
 
 -- b (vii)
SET @AMTA1 = 0
Select @AMTA1=ISNULL(SUM(case when bhent ='ST' THEN + GRO_AMT ELSE -GRO_AMT END),0) From VATTBL where (Date Between @Sdate and @Edate) And Bhent in('ST','SR','CN')  
And St_Type = 'OUT OF STATE' And TAX_NAME like '%EXEMPTED%'

Select @AMTA1= @AMTA1 + ISNULL(SUM(case when bhent ='ST' THEN + GRO_AMT ELSE -GRO_AMT END),0) From VATTBL where (Date Between @Sdate and @Edate) And Bhent in('ST','SR','CN')  
And St_Type = 'OUT OF STATE' and U_IMPORM in('Branch Transfer','Consignment Transfer') And ( ltrim(rtrim(REPLACE(REPLACE(RFORM_NM,'form',''),'-',''))) ='F' or ltrim(rtrim(REPLACE(REPLACE(tax_name,'form',''),'-','')))='F')
Set @BALAMT = @BALAMT - ISNULL(@AMTA1,0)INSERT INTO #FORM221
 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
 (1,'3','J',0,@AMTA1,0,0,'')


--	Total deductions
SET @AMTA1=0
select @AMTA1=SUM(AMT1) FROM #FORM221 WHERE PartSr = '3' And SrNo <> 'B'
INSERT INTO #FORM221
 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
 (1,'3','K',0,@AMTA1,0,0,'')
 
 ---Gross Inter State sales
SET @AMTA1=0
SET @AMTB1=0
SET @AMTC1=0
select @AMTA1=SUM(AMT1) FROM #FORM221 WHERE PartSr = '3' And Srno = 'B'
select @AMTB1=SUM(AMT1) FROM #FORM221 WHERE PartSr = '3' And SrNo = 'K'
SET @AMTC1=@AMTA1-@AMTB1
INSERT INTO #FORM221
 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
 (1,'3','L',0,@AMTC1,0,0,'')

---end 3

--- start 4
--Turnover of goods, unconditionally, exempt under UPVAT, 2008, sold in  course of inter state trade or commerce.
SET @AMTA1=0
Select @AMTA1=ISNULL(SUM(case when bhent ='ST' THEN + GRO_AMT ELSE -GRO_AMT END),0) From VATTBL
where (Date Between @Sdate and @Edate) And Bhent  in('ST','SR','CN') And St_Type = 'OUT OF STATE'
AND TAX_NAME like '%EXEMPTED%' 
SET @BALAMT = @BALAMT - ISNULL(@AMTA1,0)
 INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES  (1,'4','A',0,@AMTA1,0,0,'') 

SET @AMTA1=0
SET @BALAMT = @BALAMT - ISNULL(@AMTA1,0)
 INSERT INTO #FORM221  (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES  (1,'4','B',0,@AMTA1,0,0,'')

SET @AMTA1=0 
 INSERT INTO #FORM221  (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES  (1,'4','C',0,@AMTA1,0,0,'')

 SET @AMTA1=0
select @AMTA1=SUM(AMT1) FROM #FORM221 WHERE PartSr = '4' And SrNo <> 'D'
Set @AMTA1 = IsNull(@AMTA1,0)  
 INSERT INTO #FORM221
 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
 (1,'4','D',0,@AMTA1,0,0,'')

-- 10 (i)
SET @AMTA1=0
SET @AMTB1=0
SET @AMTC1=0
select @AMTA1=SUM(AMT1) FROM #FORM221 WHERE PartSr = '3' And Srno = 'L'
select @AMTB1=SUM(AMT1) FROM #FORM221 WHERE PartSr = '4' And SrNo = 'D'
SET @AMTC1=@AMTA1-@AMTB1
 INSERT INTO #FORM221
 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
 (1,'4A','D',0,@AMTC1,0,0,'')


---5
DECLARE @it_name as varchar(200), @vatonamt as numeric(14,2), @srno as numeric(4)
DECLARE @it_code as numeric(18,0)

SET @it_name =''
SET @it_code = 0
SET @per = 0.00
SET @vatonamt = 0.00
SET @taxamt = 0.00
SET @srno = 0

SET @CHAR = 65
------11   CALCULATION OF CENTRAL SALES TAX ON NET INTER-STATE SALES
--declare cr_Vatgoods cursor FOR
--select a.per, i.it_name, i.it_code, Sum(a.vatonamt) As vatonamt, Sum(a.taxamt) As taxamt From VATTBL a
--inner join stitem d on (d.it_code = a.it_code And d.tran_cd = a.tran_cd and d.entry_ty = a.bhent)
--inner join IT_MAST i on (i.it_code = a.it_code)
--where a.Bhent  in('ST','SR','CN') And a.St_Type = 'OUT OF STATE' And a.Date Between @sdate and @edate 
-----AND a.U_IMPORM NOT IN ('BRANCH TRANSFER','CONSIGNMENT TRANSFER') AND d.TAX_NAME <> 'EXEMPTED' -- for Bug-26465 date on 26-06-2016
----AND a.U_IMPORM NOT IN ('BRANCH TRANSFER','CONSIGNMENT TRANSFER') AND d.TAX_NAME <> 'EXEMPTED' -- for Bug-26465 date on 26-06-2016
--AND a.VATTYPE = ''
--group by it_name, i.it_code, VATTYPE, per
--ORDER BY it_name, i.it_code, VATTYPE, per

--OPEN cr_Vatgoods
--FETCH NEXT FROM cr_Vatgoods INTO @per,@it_name,@it_code,@vatonamt,@taxamt
-- WHILE (@@FETCH_STATUS=0)
-- BEGIN
--	begin
--		select @AMTC1 = 0, @AMTD1=0, @NetEFF = 0, @NetTAX = 0
				
--		Select @AMTC1=ISNULl(SUM(A.VATONAMT),0),@AMTD1=ISNULl(SUM(A.TAXAMT),0) From VATTBL A
--		inner join SRITREF sr on (sr.tran_cd = A.tran_cd And sr.it_code = A.it_code And sr.itserial = A.it_code And sr.entry_ty = A.bhent)
--		where (sr.RDate Between @Sdate and @Edate)  And A.Bhent IN('SR')
--		And A.St_Type = 'OUT OF STATE'  AND A.Date <= DATEADD(MONTH,6, convert(datetime,sr.RDate,104)) AND A.PER=@PER
--		AND (Sr.It_code = @it_code) AND (Sr.item = @it_name)
		
--		SET @AMTC1=ISNULL(@AMTC1,0)
--        SET @AMTD1=ISNULL(@AMTD1,0)
        
--        SET @vatonamt = ISNULL(@vatonamt,0)
--        SET @taxamt = ISNULL(@taxamt,0)
		
--		SET @SRNO = @SRNO + 1
		
--		Set @NetEFF = (@vatonamt-@AMTC1)
--		Set @NetTAX = (@taxamt- @AMTD1)

--		if @NetEFF <> 0
--			begin
--			   INSERT INTO #FORM221
--			  (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
--			  (1,'5',CHAR(@CHAR),@PER,@NETEFF,@NETTAX,@SRNO,@it_name)
			  
--			  SET @AMTJ1=@AMTJ1+@NETEFF --TOTAL TAXABLE AMOUNT
--			  SET @AMTK1=@AMTK1+@NETTAX --TOTAL TAX
--		      SET @CHAR=@CHAR+1
--			end  
		 
--	end
-- FETCH NEXT FROM cr_Vatgoods INTO @per,@it_name,@it_code,@vatonamt,@taxamt
--END
--CLOSE cr_Vatgoods
--DEALLOCATE cr_Vatgoods
 INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) 
select 1 AS PART,'5' AS PARTSR,'A' AS SRNO ,a.per, isnull(Sum(case when a.BHENT ='st' then  a.vatonamt else -a.vatonamt end ),0) As vatonamt, isnull(Sum(case when a.BHENT ='st' then  a.taxamt else -a.taxamt end ),0) As taxamt,0, i.it_name From VATTBL a
left outer join IT_MAST i on (i.it_code = a.it_code)
where a.Bhent  in('ST','SR','CN') And a.St_Type = 'OUT OF STATE'  AND PER > 0 And a.Date Between @sdate and @edate 
AND a.VATTYPE = ''
group by it_name, per
ORDER BY per ,it_name

IF NOT EXISTS (SELECT SRNO FROM #FORM221 WHERE PART=1 AND PARTSR='5' )
BEGIN
	 INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
		  (1,'5','A',0,0,0,0,'')
END

Select @AMTA1=sum(Amt1),@AMTA2=sum(Amt2) from #form221 where partsr = '5'
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
(1,'5','Z',0,@AMTA1,@AMTA2,0,'Total:')
---5

SET @CHAR = 65
--6
-----11.B. NON VAT GOODS
--declare cr_Othgoods cursor FOR
--select a.per, i.it_name, i.it_code, Sum(a.vatonamt) As vatonamt, Sum(a.taxamt) As taxamt From VATTBL a
--inner join stitem d on (d.it_code = a.it_code And d.tran_cd = a.tran_cd and d.entry_ty = a.bhent)
--inner join IT_MAST i on (i.it_code = a.it_code)
--where a.Bhent  in('ST','SR','CN') And a.St_Type = 'OUT OF STATE' And a.Date Between @sdate and @edate 
----AND a.U_IMPORM NOT IN ('BRANCH TRANSFER','CONSIGNMENT TRANSFER') AND d.TAX_NAME <> 'EXEMPTED'  for bug-26465
--AND a.VATTYPE = 'Non Vat'
--group by it_name, i.it_code, VATTYPE, per
--ORDER BY it_name, i.it_code, VATTYPE, per
--SET @it_name =''
--SET @it_code = 0
--SET @per = 0.00
--SET @vatonamt = 0.00
--SET @taxamt = 0.00
--SET @srno = 0
--OPEN cr_Othgoods
--FETCH NEXT FROM cr_Othgoods INTO @per,@it_name,@it_code,@vatonamt,@taxamt
-- WHILE (@@FETCH_STATUS=0)
-- BEGIN
--	begin
--		select @AMTC1 = 0, @AMTD1=0, @NetEFF = 0, @NetTAX = 0
		
--		Select @AMTC1=ISNULl(SUM(A.VATONAMT),0),@AMTD1=ISNULl(SUM(A.TAXAMT),0) From VATTBL A
--		inner join SRITREF sr on (sr.tran_cd = A.tran_cd And sr.it_code = A.it_code And sr.itserial = A.it_code And sr.entry_ty = A.bhent)
--		where (sr.RDate Between @Sdate and @Edate)  And A.Bhent IN('SR','CN')
--		And A.St_Type = 'OUT OF STATE'  AND A.Date <= DATEADD(MONTH,6, convert(datetime,sr.RDate,104)) AND A.PER=@PER
--		AND (Sr.It_code = @it_code) AND (Sr.item = @it_name)
		
--		SET @AMTC1=ISNULL(@AMTC1,0)
--        SET @AMTD1=ISNULL(@AMTD1,0)
        
--        SET @vatonamt = ISNULL(@vatonamt,0)
--        SET @taxamt = ISNULL(@taxamt,0)
		
--		SET @SRNO = @SRNO + 1
		
--		Set @NetEFF = (@vatonamt-@AMTC1)
--		Set @NetTAX = (@taxamt- @AMTD1)

--		if @NetEFF <> 0
--			begin
--			   INSERT INTO #FORM221
--			  (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
--			  (1,'6',CHAR(@CHAR),@PER,@NETEFF,@NETTAX,@SRNO,@it_name)
			  
--			  SET @AMTJ1=@AMTJ1+@NETEFF --TOTAL TAXABLE AMOUNT
--			  SET @AMTK1=@AMTK1+@NETTAX --TOTAL TAX
--		      SET @CHAR=@CHAR+1
--			end  
		 
--	end
-- FETCH NEXT FROM cr_Othgoods INTO @per,@it_name,@it_code,@vatonamt,@taxamt
--END
--CLOSE cr_Othgoods
--DEALLOCATE cr_Othgoods
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) 
select 1 AS PART,'6' AS PARTSR,'A' AS SRNO ,a.per, isnull(Sum(case when a.BHENT ='st' then  a.vatonamt else -a.vatonamt end),0) As vatonamt
, isnull(Sum(case when a.BHENT ='st' then  a.taxamt else -a.taxamt end),0) As taxamt,0, i.it_name From VATTBL a
left outer join IT_MAST i on (i.it_code = a.it_code)
where a.Bhent  in('ST','SR','CN') And a.St_Type = 'OUT OF STATE'  AND PER > 0 And a.Date Between @sdate and @edate 
AND a.VATTYPE = 'Non Vat'
group by it_name, per
ORDER BY per ,it_name


IF NOT EXISTS (SELECT SRNO FROM #FORM221 WHERE PART=1 AND PARTSR='6' )
BEGIN
	 INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
		  (1,'6','A',0,0,0,0,'')
END
Select @AMTA1=sum(Amt1),@AMTA2=sum(Amt2) from #form221 where partsr = '6' And Srno NOT IN ('Y','Z')
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
(1,'6','Y',0,@AMTA1,@AMTA2,0,'Total:')

-- Grand Total
SET @AMTA1=0
SET @AMTB1=0
SET @AMTC1=0
SET @AMTD1=0
select @AMTA1=SUM(AMT1),@AMTC1=SUM(AMT2) FROM #FORM221 WHERE PartSr = '5' And Srno = 'Z'
select @AMTB1=SUM(AMT1),@AMTD1=SUM(AMT2) FROM #FORM221 WHERE PartSr = '6' And SrNo = 'Y'

 INSERT INTO #FORM221
 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
 (1,'6','Z',0,(@AMTA1+@AMTB1),(@AMTC1+@AMTD1),0,'Grand Total :')

---6

-- Adjustment of ITC against CST
SET @AMTA1 = 0
SELECT @AMTA1=ISNULL(SUM(C.amount),0) FROM  JVMAIN A  
inner JOIN JVACDET C on (A.entry_ty = C.ENTRY_TY AND A.TRAN_CD = C.TRAN_CD AND C.amt_ty ='CR')
where A.ENTRY_TY in('J4')  and A.VAT_ADJ='Input Vat Adjustment Against CST'  AND A.party_nm ='CST PAYABLE' AND ( A.date BETWEEN @SDATE AND @EDATE) 
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
(1,'6A','A',0,@AMTA1,0,0,'')

-- Tax Payable [in rupees] = Tax as calculated in Sl.No. 11 - Amount declared in Sel.No.12
SET @AMTC1=0
SET @AMTD1=0
select @AMTC1=ISNULL(SUM(AMT2),0) FROM #FORM221 WHERE PartSr = '6' And Srno = 'Z'
select @AMTD1=ISNULL(SUM(AMT1),0) FROM #FORM221 WHERE PartSr = '6A' And SrNo = 'A'

 INSERT INTO #FORM221
 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES  (1,'6B','A',0,0,(@AMTC1-@AMTD1),0,'')

--7
Declare @INVNO VARCHAR(250),@CHLN_DATE DATETIME ,@Bank_nm varchar(250)  
  
Declare cr_cstPayable cursor FOR
select B.u_chALNO,b.u_chALdt,A.Gro_amt,b.bank_nm
from VATTBL A
Inner join Bpmain B on (A.Bhent = B.Entry_ty and A.Tran_cd = B.Tran_cd)
where BHENT = 'BP' And B.Date Between @sdate and @edate And B.Party_nm like '%CST Payable%' ORDER BY B.u_chALdt
SET @INVNO =''
SET @CHLN_DATE =NULL
SET @AMTA1 = 0.00
set @Bank_nm = ''
OPEN cr_cstPayable
FETCH NEXT FROM cr_cstPayable INTO @INVNO,@CHLN_DATE,@AMTA1,@Bank_nm
 WHILE (@@FETCH_STATUS=0)
 BEGIN
		begin
		  INSERT INTO #form221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm,DATE,INV_NO) VALUES
		  (1,'7','A',0,0,@AMTA1,0,@Bank_nm,@CHLN_DATE,@INVNO)
		  PRINT @CHLN_DATE
		  PRINT @INVNO
		END
	FETCH NEXT FROM cr_cstPayable INTO @INVNO,@CHLN_DATE,@AMTA1,@Bank_nm
END
CLOSE cr_cstPayable
DEALLOCATE cr_cstPayable

IF NOT EXISTS (SELECT SRNO FROM #FORM221 WHERE PART=1 AND PARTSR='7' )
BEGIN
	 INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
		  (1,'7','A',0,0,0,0,'')
END


--INSERT INTO #FORM221
-- (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
-- (1,'7','A',0,@AMTA1,0,0,'')
--
---7 


Update #form221 set  PART = isnull(Part,0) , Partsr = isnull(PARTSR,''), SRNO = isnull(SRNO,''),
		             RATE = isnull(RATE,0), AMT1 = isnull(AMT1,0), AMT2 = isnull(AMT2,0), 
					 AMT3 = isnull(AMT3,0), INV_NO = isnull(INV_NO,''), DATE = isnull(Date,''), 
					 PARTY_NM = isnull(Party_nm,''), ADDRESS = isnull(Address,''),
					 FORM_NM = isnull(form_nm,''), S_TAX = isnull(S_tax,'')--, Qty = isnull(Qty,0),  ITEM =isnull(item,''),

 SELECT * FROM #FORM221 order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int), partsr,SRNO
 
 END

set ANSI_NULLS OFF
--Print 'UP CST FORM 01'

