IF EXISTS (SELECT [name] FROM SYSOBJECTS where XTYPE = 'P' and [name] = 'USP_REP_AS_CSTFORM03')
begin
	Drop Procedure USP_REP_AS_CSTFORM03
end

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
 -- Author:  Hetal L Patel
 -- Create date: 16/05/2007
 -- Description: This Stored procedure is useful to generate AS CST FORM 03.
 -- Modify date: 16/05/2007 
 -- Modified By: Madhavi Penumalli
 -- Modify date: 04/12/2009 (Updated)
 -- Modified By: GAURAV R. TANNA - Bug: 26619
 -- Modify date: 21/07/2015
 -- =============================================
CREATE PROCEDURE [dbo].[USP_REP_AS_CSTFORM03]
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
 DECLARE @PER NUMERIC(12,2),@TAXAMT NUMERIC(12,2),@CHAR INT,@LEVEL NUMERIC(12,2)

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
 SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,@AMTI1=0,@AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0 


---Part A
--6
 Select @AMTA1=Sum(Gro_Amt) From VATTBL Where Bhent in ('ST') And (Date Between @Sdate And @Edate)
 Set @AmtA1 = IsNull(@AmtA1,0)
  INSERT INTO #FORM221
 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
 (1,'1','A',0,@AMTA1,0,0,'')

--7
 Select @AMTA1=0
  INSERT INTO #FORM221
 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
 (1,'1','B',0,@AMTA1,0,0,'')

--7 (a)
Select @AMTA1=Sum(Gro_Amt) From VATTBL Where Bhent in ('ST') And (Date Between @Sdate And @Edate) 
And st_type = 'OUT OF COUNTRY' --And RFORM_NM = ''
Set @AmtA1 = IsNull(@AmtA1,0)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
(1,'1','C',0,@AMTA1,0,0,'')

--7 (b)
Select @AMTA1=Sum(Gro_Amt) From VATTBL Where Bhent in ('ST') And (Date Between @Sdate And @Edate) 
 And (REPLACE(RFORM_NM, 'FORM','') in ('H', '-H', '- H')) 
Set @AmtA1 = IsNull(@AmtA1,0)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
(1,'1','D',0,@AMTA1,0,0,'')

--7 (c)
Select @AMTA1=Sum(Gro_Amt) From VATTBL Where Bhent in ('ST') And (Date Between @Sdate And @Edate) 
 And (REPLACE(RFORM_NM, 'FORM','') in ('F', '-F', '- F'))
Set @AmtA1 = IsNull(@AmtA1,0)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
(1,'1','E',0,@AMTA1,0,0,'')

--7 (d)
 Select @AMTA1=0
  INSERT INTO #FORM221
 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
 (1,'1','F',0,0,0,0,'')

--7 (e)
Select @AMTA1=Sum(Gro_Amt) From VATTBL Where Bhent in ('ST') And (Date Between @Sdate And @Edate) 
And st_type in ('LOCAL','')
Set @AmtA1 = IsNull(@AmtA1,0)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
(1,'1','G',0,@AMTA1,0,0,'')


--total of deduction at 7 (a+b+c+d+e)
Select @AMTA1=Sum(Amt1) From #FORM221 Where PARTSR = '1' And SRNO in ('A')
Select @AMTB1=Sum(Amt1) From #FORM221 Where PARTSR = '1' And SRNO in ('C','D','E','F','G')
Set @AmtA1 = IsNull(@AmtA1,0)
Set @AmtB1 = IsNull(@AmtB1,0)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
(1,'1','H',0,@AMTB1,0,0,'')

--8 Turnover of inter-state sales (6 – 7)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
(1,'1','I',0,@AMTA1-@AMTB1,0,0,'')


---PART B
--9 Turnover of inter-state sales at 8 (Form Part A)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
(1,'2','A',0,@AMTA1-@AMTB1,0,0,'')

--10 Deduct:-
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
(1,'2','B',0,0,0,0,'')

--(a) Inter-state sales u/s 6(2),being subsequent sales against Form ‘E-1’ & ‘C’
Select @AMTA1=Sum(Gro_Amt) From VATTBL Where Bhent in ('ST') And (Date Between @Sdate And @Edate) 
 And (REPLACE(RFORM_NM, 'FORM','') in ('E-1', '-E1', '- E1', 'E1', 'C', '-C', '- C')) AND ST_TYPE = 'OUT OF STATE'
 AND TAX_NAME NOT in ('EXEMPTED')
Set @AmtA1 = IsNull(@AmtA1,0)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
(1,'2','C',0,@AMTA1,0,0,'')


--(b) Inter-state sales u/s 6(3), being sales to diplomatic mission, UN, etc., against Form ‘J’
Select @AMTA1=Sum(Gro_Amt) From VATTBL Where Bhent in ('ST') And (Date Between @Sdate And @Edate) 
 And (REPLACE(RFORM_NM, 'FORM','') in ('J', '-J', '- J')) AND ST_TYPE = 'OUT OF STATE'
 AND TAX_NAME NOT in ('EXEMPTED')
Set @AmtA1 = IsNull(@AmtA1,0)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
(1,'2','D',0,@AMTA1,0,0,'')


--(c) Inter-state sales exempted u/s 8(5)
Select @AMTA1=Sum(Gro_Amt) From VATTBL Where Bhent in ('ST') And (Date Between @Sdate And @Edate) 
 And TAX_NAME in ('EXEMPTED') AND ST_TYPE = 'OUT OF STATE' 
 AND (REPLACE(RFORM_NM, 'FORM','') not in ('I', '-I', '- I','J', '-J', '- J','E-1', '-E1', '- E1', 'E1', 'C', '-C', '- C'))
Set @AmtA1 = IsNull(@AmtA1,0)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
(1,'2','E',0,@AMTA1,0,0,'')

--(d) Inter-state sales u/s 8(6), being sales made to a dealer in Special Economic Zone against Form ‘I’
Select @AMTA1=Sum(Gro_Amt) From VATTBL Where Bhent in ('ST') And (Date Between @Sdate And @Edate) 
 And (REPLACE(RFORM_NM, 'FORM','') in ('I', '-I', '- I')) AND ST_TYPE = 'OUT OF STATE'
 AND TAX_NAME NOT in ('EXEMPTED')
Set @AmtA1 = IsNull(@AmtA1,0)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
(1,'2','F',0,@AMTA1,0,0,'')


--(e) Inter-state sales on which no tax is payable
Select @AMTA1=Sum(Gro_Amt) From VATTBL Where Bhent in ('ST') And (Date Between @Sdate And @Edate) 
 And TAX_NAME not in ('EXEMPTED') AND ST_TYPE = 'OUT OF STATE' AND PER = 0
And (REPLACE(RFORM_NM, 'FORM','') not in ('I', '-I', '- I','J', '-J', '- J','E-1', '-E1', '- E1', 'E1', 'C', '-C', '- C'))
Set @AmtA1 = IsNull(@AmtA1,0)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
(1,'2','G',0,@AMTA1,0,0,'')

--(f) Labour & Other charges for works contract
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
(1,'2','H',0,0,0,0,'')

--(g) Other deduction, if any
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
(1,'2','I',0,0,0,0,'')


--11 Taxable inter-state sales (9-10)
Select @AMTA1=Sum(Amt1) From #FORM221 Where PARTSR = '2' And SRNO in ('A')
Select @AMTB1=Sum(Amt1) From #FORM221 Where PARTSR = '2' And SRNO in ('C','D','E','F','G','H','I')
Set @AmtA1 = IsNull(@AmtA1,0)
Set @AmtB1 = IsNull(@AmtB1,0)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
(1,'2','J',0,@AmtA1-@AMTB1,0,0,'')

declare @gro_amt numeric (14,2), @vatonamt numeric (14,2), @SRNO numeric (4,0)

select @gro_amt=0, @vatonamt =0, @taxamt =0
SET @CHAR = 65
SET @SRNO = 0

declare cr_Vatgoods cursor FOR
select a.per, Sum(a.GRO_AMT) As GRO_AMT, Sum(a.taxamt) As taxamt From VATTBL a
where a.Bhent  in('ST') And a.St_Type = 'OUT OF STATE' And a.Date Between @sdate and @edate 
AND a.TAX_NAME NOT in ('EXEMPTED') AND a.per <> 0
And (REPLACE(RFORM_NM, 'FORM','') not in ('I', '-I', '- I','J', '-J', '- J','E-1', '-E1', '- E1', 'E1', 'C', '-C', '- C'))
group by a.per
ORDER BY a.per

OPEN cr_Vatgoods
FETCH NEXT FROM cr_Vatgoods INTO @per,@gro_amt,@taxamt
 WHILE (@@FETCH_STATUS=0)
 BEGIN
	begin
		select @AMTC1 = 0, @AMTD1=0--, @NetEFF = 0, @NetTAX = 0
				
		Select @AMTC1=ISNULl(SUM(A.GRO_Amt),0),@AMTD1=ISNULl(SUM(A.TAXAMT),0) From VATTBL A
		inner join SRITREF sr on (sr.tran_cd = A.tran_cd And sr.it_code = A.it_code And sr.itserial = A.it_code And sr.entry_ty = A.bhent)
		where (sr.RDate Between @Sdate and @Edate)  And A.Bhent = 'SR'  
		And A.St_Type = 'OUT OF STATE'  AND A.Date <= DATEADD(MONTH,6, convert(datetime,sr.RDate,104)) AND A.PER=@PER
		
		SET @AMTC1=ISNULL(@AMTC1,0)
        SET @AMTD1=ISNULL(@AMTD1,0)
        
        SET @gro_amt = ISNULL(@gro_amt,0)
        SET @taxamt = ISNULL(@taxamt,0)
		
		SET @SRNO = @SRNO + 1
		
		IF @gro_amt > 0
			BEGIN
				INSERT INTO #FORM221
				(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
				(1,'3','A',@PER,@gro_amt,0,@SRNO,'')
			END
			
		IF @AMTC1 > 0
			BEGIN
				INSERT INTO #FORM221
				(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
				(1,'3','B',@PER,@AMTC1,0,@SRNO,'')
			END
			
		IF @taxamt > 0
			BEGIN
				INSERT INTO #FORM221
				(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
				(1,'3','C',@PER,@taxamt,0,@SRNO,'')
			END
			
		IF (@gro_amt-(@AMTC1+@taxamt)) > 0
			BEGIN
				INSERT INTO #FORM221
				(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
				(1,'3','D',@PER,(@AMTC1+@taxamt),0,@SRNO,'')
			END
			
		IF (@gro_amt) <> 0
			BEGIN
				INSERT INTO #FORM221
				(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
				(1,'3','E',@PER,(@gro_amt-(@AMTC1+@taxamt)),0,@SRNO,'')
			END
			
		IF (@taxamt-@AMTD1) <> 0
			BEGIN	
				INSERT INTO #FORM221
				(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
				(1,'3','F',@PER,(@taxamt-@AMTD1),0,@SRNO,'')
			END		
		 
	end
 FETCH NEXT FROM cr_Vatgoods INTO @per,@gro_amt,@taxamt
END
CLOSE cr_Vatgoods
DEALLOCATE cr_Vatgoods

SET @SRNO = 0
SELECT @SRNO = Count(*) from #FORM221 where PARTSR = '3' AND SRNO = 'A'
SET @SRNO = IsNull(@SRNO,0)
IF @SRNO = 0
	BEGIN
		INSERT INTO #FORM221
		(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
		(1,'3','A',0,0,0,1,'')		
	END
	
INSERT INTO #FORM221
	(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
	(1,'3','AA',0,0,0,1,'')		

SET @SRNO = 0
SELECT @SRNO = Count(*) from #FORM221 where PARTSR = '3' AND SRNO = 'B'
IF @SRNO = 0
	BEGIN
		INSERT INTO #FORM221
		(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
		(1,'3','B',0,0,0,1,'')		
	END

SET @SRNO = 0
SELECT @SRNO = Count(*) from #FORM221 where PARTSR = '3' AND SRNO = 'C'
IF @SRNO = 0
	BEGIN
		INSERT INTO #FORM221
		(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
		(1,'3','C',0,0,0,1,'')		
	END
	
SET @SRNO = 0
SELECT @SRNO = Count(*) from #FORM221 where PARTSR = '3' AND SRNO = 'D'
SET @SRNO = IsNull(@SRNO,0)
IF @SRNO = 0
	BEGIN
		INSERT INTO #FORM221
		(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
		(1,'3','D',0,0,0,1,'')		
	END	
		
SET @SRNO = 0
SELECT @SRNO = Count(*) from #FORM221 where PARTSR = '3' AND SRNO = 'E'
SET @SRNO = IsNull(@SRNO,0)
IF @SRNO = 0
	BEGIN
		INSERT INTO #FORM221
		(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
		(1,'3','E',0,0,0,1,'')		
	END
	
SET @SRNO = 0
SELECT @SRNO = Count(*) from #FORM221 where PARTSR = '3' AND SRNO = 'F'
SET @SRNO = IsNull(@SRNO,0)
IF @SRNO = 0
	BEGIN
		INSERT INTO #FORM221
		(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
		(1,'3','F',0,0,0,1,'')		
	END	
	
--- 16 Total tax payable
Select @AMTA1=sum(Amt1) from #form221 where partsr = '3' and srno = 'F'
Set @AmtA1 = IsNull(@AmtA1,0)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
(1,'4','A',0,@AMTA1,0,0,'')

--- 17 Interest payable
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
(1,'4','B',0,0,0,0,'')

--- 18 Penalty payable
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
(1,'4','C',0,0,0,0,'')

--- 19 Total (16+17+18)
Select @AMTA1=sum(Amt1) from #form221 where partsr = '3' and srno in ('G','H','I')
Set @AmtA1 = IsNull(@AmtA1,0)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
(1,'4','D',0,@AMTA1,0,0,'')

-- 20 Amount Paid
Select @AMTA1=sum(a.gro_amt) from VATTBL a
Inner join Bpmain B on (A.Bhent = B.Entry_ty and A.Tran_cd = B.Tran_cd)
 where a.BHENT = 'BP' And a.Date Between @sdate and @edate And B.Party_nm like '%CST Payable%'
 Set @AmtA1 = IsNull(@AmtA1,0)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
(1,'4','E',0,@AMTA1,0,0,'')

--- 21 Payable tax amount transferred to the corresponding VAT returns
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
(1,'4','F',0,0,0,0,'')

--- 22 Excess payment, if any
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
(1,'4','G',0,0,0,0,'')

Declare @chal_no varchar (30), @chal_date smalldatetime, @bank_nm varchar (100), @bank_br varchar (50)

select @chal_no = '', @chal_date = '', @bank_nm = '', @bank_br = ''

Declare cr_cstPayable cursor FOR
select B.u_chALNO,b.u_chALdt,A.Gro_amt,b.bank_nm,ac.s_tax
from VATTBL A
Inner join Bpmain B on (A.Bhent = B.Entry_ty and A.Tran_cd = B.Tran_cd)
inner join ac_mast ac on (ac.ac_name = b.bank_nm)
where BHENT = 'BP' And B.Date Between @sdate and @edate And B.Party_nm like '%CST Payable%' ORDER BY B.u_chALdt
OPEN cr_cstPayable
FETCH NEXT FROM cr_cstPayable INTO @chal_no,@chal_date,@AMTA1,@Bank_nm, @bank_br
 WHILE (@@FETCH_STATUS=0)
 BEGIN
		begin
		   Set @AmtA1 = IsNull(@AmtA1,0)
		
		  INSERT INTO #form221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm,DATE,INV_NO,s_tax) VALUES
		  (1,'5','A',0,@AMTA1,0,0,@Bank_nm,@CHAL_DATE,@chal_no, @bank_br)
		  
		END
	FETCH NEXT FROM cr_cstPayable INTO @chal_no,@chal_date,@AMTA1,@Bank_nm, @bank_br
END
CLOSE cr_cstPayable
DEALLOCATE cr_cstPayable

--- 19 Total (16+17+18)
Select @AMTA1=sum(Amt1) from #form221 where partsr = '5'
Set @AmtA1 = IsNull(@AmtA1,0)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm,Inv_No) VALUES
(1,'5','Z',0,@AMTA1,0,0,'','Total')

 
Update #form221 set  PART = isnull(Part,0) , Partsr = isnull(PARTSR,''), SRNO = isnull(SRNO,''),
		             RATE = isnull(RATE,0), AMT1 = isnull(AMT1,0), AMT2 = isnull(AMT2,0), 
					 AMT3 = isnull(AMT3,0), INV_NO = isnull(INV_NO,''), DATE = isnull(Date,''), 
					 PARTY_NM = isnull(Party_nm,''), ADDRESS = isnull(Address,''),
					 FORM_NM = isnull(form_nm,''), S_TAX = isnull(S_tax,'')--, Qty = isnull(Qty,0),  ITEM =isnull(item,''),

 SELECT * FROM #FORM221 order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int), partsr,SRNO,RATE
 
 END

set ANSI_NULLS OFF
--Print 'AS CST FORM 03'

