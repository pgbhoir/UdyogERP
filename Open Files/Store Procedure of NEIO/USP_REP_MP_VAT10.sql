IF EXISTS(SELECT XTYPE,NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME ='USP_REP_MP_VAT10')
BEGIN
	DROP PROCEDURE USP_REP_MP_VAT10
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:  Hetal L Patel
-- Create date: 16/05/2007
-- Description: This Stored procedure is useful to generate MP VAT FORM 10
-- Modify date: 16/05/2007 
-- Modified By: Madhavi Penumalli
-- Modify date: 24/11/2009 
-- Modified By: Gaurav R. Tanna
-- Modify date: 18/08/2015
-- Modified By: Suraj Kumawat
-- Modify date: 28/08/2015
----========================================

CREATE PROCEDURE [dbo].[USP_REP_MP_VAT10]
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
Declare @NetEFF Numeric (14,2), @NetTax Numeric (14,2)

---Temporary Cursor
SELECT PART=3,PARTSR='AAA',SRNO='AAA',RATE=99.999,AMT1=NET_AMT,AMT2=M.TAXAMT,AMT3=M.TAXAMT,AMT4=M.TAXAMT,
M.INV_NO,M.DATE,M.U_LRNO, M.U_LRDT, M.FORM_NO, M.FORMRDT, ITEM=space(150), M.U_PONO, M.U_PODT, 
PARTY_NM=AC1.AC_NAME,ADDRESS=Ltrim(AC1.Add1)+' '+Ltrim(AC1.Add2)+' '+Ltrim(AC1.Add3), AC1.S_TAX
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
	 --EXECUTE USP_REP_MULTI_CO_DATA
	 -- @TMPAC, @TMPIT, @SPLCOND, @SDATE, @EDATE
	 --,@SAC, @EAC, @SIT, @EIT, @SAMT, @EAMT
	 --,@SDEPT, @EDEPT, @SCATE, @ECATE,@SWARE
	 --,@EWARE, @SINV_SR, @EINV_SR, @LYN, @EXPARA
	 --,@MFCON = @MCON OUTPUT

	----SET @SQLCOMMAND='Select * from '+@MCON
	-----EXECUTE SP_EXECUTESQL @SQLCOMMAND
	--SET @SQLCOMMAND='Insert InTo  #FORM221_1 Select * from '+@MCON
	--EXECUTE SP_EXECUTESQL @SQLCOMMAND
	-----Drop Temp Table 
	--SET @SQLCOMMAND='Drop Table '+@MCON
	--EXECUTE SP_EXECUTESQL @SQLCOMMAND
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

--->PART A

--1. Gross Turnover (GTO)
SET @AMTA1 = 0
SELECT @AMTA1=ISNULL(SUM(GRO_AMT),0) FROM VATTBL where bhent='ST' AND (DATE BETWEEN @SDATE AND @EDATE)
INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'1','A',0,@AMTA1,0,0,'')
--2. Less deductions in respect of,-
set @AMTA1=0
INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'1','B',0,@AMTA1,0,0,'')

 --(a) Sales returns within six months of sale
SET @AMTA1 = 0
DECLARE @LSTTHREEMTHDATE SMALLDATETIME
Set @LSTTHREEMTHDATE = DATEADD(MONTH,-6, convert(datetime,@Edate,104))
SELECT @AMTA1=ISNULL(Sum(Gro_Amt),0) FROM VATTBL A  
inner join SRITREF sr on (sr.tran_cd = A.tran_cd And sr.it_code = A.it_code And sr.entry_ty = A.bhent)
WHERE A.BHENT in ('SR') AND (sr.RDate Between @Sdate and @Edate)
AND A.Date <= DATEADD(MONTH,6, convert(datetime,sr.RDate,104)) 
INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'1','C',0,@AMTA1,0,0,'')

  --(b) Sale price of Tax Paid goods
set @AMTA1=0
SELECT @AMTA1=ISNULL(SUM(GRO_AMT),0) FROM VATTBL where bhent='ST'  AND ST_TYPE = 'LOCAL'
AND (DATE BETWEEN @SDATE AND @EDATE)  AND U_IMPORM not in ('Consignment Transfer','Branch Transfer')
AND TAXAMT > 0
INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES(1,'1','D',0,@AMTA1,0,0,'')

--(c) Sale price of goods declared Tax free
set @AMTA1=0
SELECT @AMTA1=ISNULL(SUM(GRO_AMT),0) FROM VATTBL where bhent='ST'  AND ST_TYPE = 'LOCAL'
AND (DATE BETWEEN @SDATE AND @EDATE)  AND U_IMPORM not in ('Consignment Transfer','Branch Transfer')
AND TAXAMT = 0
INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'1','E',0,@AMTA1,0,0,'')

--(d) Turnover of sales in the course of inter-state trade or commerce

SET @AMTA1=0
SELECT @AMTA1=ISNULL(SUM(GRO_AMT),0) FROM VATTBL where bhent='ST'  AND ST_TYPE='OUT OF STATE'
AND (DATE BETWEEN @SDATE AND @EDATE) AND U_IMPORM not in ('Consignment Transfer','Branch Transfer')
INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'1','F',0,@AMTA1,0,0,'')

--(e) Turnover of sales out side the State/ Consignment/ Branch Transferset
set @AMTA1=0
SELECT @AMTA1=ISNULL(SUM(GRO_AMT),0) FROM VATTBL where bhent='ST' AND (DATE BETWEEN @SDATE AND @EDATE) 
AND ST_TYPE = 'OUT OF STATE' AND U_IMPORM in ('Consignment Transfer','Branch Transfer')
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'1','G',0,@AMTA1,0,0,'')

--(f) Turnover of sales in the course of export out of the territory of India
SET @AMTA1=0
SELECT @AMTA1=isnull(SUM(GRO_AMT),0) FROM VATTBL where bhent='ST' AND (DATE BETWEEN @SDATE AND @EDATE)
AND ST_TYPE='OUT OF COUNTRY'
INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'1','H',0,@AMTA1,0,0,'')

--(g) Amount of tax included in GTO

SET @AMTA1=0
SELECT @AMTA1=isnull(SUM(TAXAMT),0) FROM VATTBL where bhent='ST' AND (DATE BETWEEN @SDATE AND @EDATE)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
(1,'1','I',0,@AMTA1,0,0,'')

--3. Taxable Turnover (1-2)
set @AMTA1=0
set @AMTB1=0

SELECT @AMTA1=ISNULL(SUM(AMT1),0) FROM #FORM221 WHERE PARTSR = '1' AND SRNO = 'A'
SELECT @AMTB1=ISNULL(SUM(AMT1),0) FROM #FORM221 WHERE PARTSR = '1' AND SRNO IN ('B','C','D','E','F','G','H','I')

INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'1','J',0,@AMTA1-@AMTB1,0,0,'')


---B: Computation of Vat on Taxable Turnover (box 3 of PART A)

INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM)
 select 1 as part,'2' as partsr,'A' as srno,0 as per1,isnull(sum(case when bhent='st' then +vatonamt else -vatonamt end),0) as amt1,
 isnull(sum(case when bhent='st' then +taxamt else -taxamt end),0) as amt2,0 as amt3
 ,(cast(per as varchar(20)) +' %' ) as per1 from vattbl where bhent in('st') and st_type in('local') 
 and per <> 0 group by per order by per
if not exists(select top 1 srno from #FORM221 where PARTSR = '2' )
begin
	INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES  (1,'2','Z',0,0,0,0,'')
end
SELECT @AMTA1 = 0, @AMTB1 = 0
SELECT @AMTA1=isnull(SUM(AMT1),0),@AMTB1=isnull(SUM(AMT2),0) FROM #FORM221 WHERE PARTSR = '2'
INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES  (1,'2','Z',0,@AMTA1,@AMTB1,0,'Total')

----PART C: Purchase Tax
INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM)
 select 1 as part,'3' as partsr,'A' as srno,0 as per1,isnull(sum(case when bhent in('PT','P1','EP') then +vatonamt else -vatonamt end),0) as amt1,
 isnull(sum(case when bhent in('PT','P1','EP') then +taxamt else -taxamt end),0) as amt2,0 as amt3
 ,(cast(per as varchar(20)) +' %' ) as per1 from vattbl where bhent in('PT','PR','P1','EP') 
 --and tax_name like '%vat%'
  and st_type in('local') and S_TAX <> ' ' and per <> 0 group by per order by per
SET @AMTA1 = 0
SELECT @AMTA1 = Count(PARTSR) FROM #FORM221 WHERE PARTSR = '3' 
SET @AMTA1 = ISNULL(@AMTA1,0)
IF @AMTA1 = 0 
	BEGIN
		INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES  (1,'3','A',0,0,0,0,'')
	END
SELECT @AMTA1 = 0, @AMTB1 = 0
SELECT @AMTA1=SUM(AMT1),@AMTB1=SUM(AMT2) FROM #FORM221 WHERE PARTSR = '3'
INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES  (1,'3','Z',0,@AMTA1,@AMTB1,0,'Total')

----PART D: *Reversal of Input Tax Rebate
Set @AmtA1 = 0
select @AmtA1 = ISNULL(SUM(A.NET_AMT),0) FROM JVMAIN A WHERE A.ENTRY_TY='J4' AND A.VAT_ADJ='Amount of Reversal of Input tax rebate' 
AND (A.DATE BETWEEN @SDATE AND @EDATE)
INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'4','A',0,@AMTA1,0,0,'')
--4

---PART E: Input Tax Rebate (on goods other than plant, machinery, equipment and parts thereof)

INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM)
select 1 as part,'4A' as partsr,'A' as srno,0 as per1,isnull(sum(a.Gro_Amt),0) as amt1,isnull(sum(a.taxamt),0) as amt2,0 as amt3
 ,(cast(s.level1 as varchar(20)) +' %' ) as per1 from JVITEM a inner join jvmain c on (a.entry_ty=c.entry_ty and a.Tran_cd = c.Tran_cd)
 inner join STAX_MAS s on (a.tax_name = s.tax_name)
 inner join it_mast b on (a.it_code=b.it_code) where a.entry_ty ='J4' and (a.DATE BETWEEN @SDATE AND @EDATE) and B.It_code in (Select A.It_Code from IT_MAST A INNER JOIN 
 ITEM_GROUP B on (A.[group] = B.it_group_name) where B.it_group_name = '' OR B.it_group_name 
 not in ('Machine','Plant','Equipment')) and a.rate <> 0 and c.VAT_ADJ='Input Tax - Rebate' and s.entry_ty = 'J4' group by s.level1 order by s.level1
-- select 1 as part,'4A' as partsr,'A' as srno,0 as per1,isnull(sum(a.Gro_Amt),0) as amt1,isnull(sum(a.taxamt),0) as amt2,0 as amt3
-- ,(cast(a.rate as varchar(20)) +' %' ) as per1 from JVITEM a inner join it_mast b on (a.it_code=b.it_code and a.itserial=b.itserial) 
-- where a.entry_ty ='J4' and B.It_code in (Select A.It_Code from IT_MAST A INNER JOIN ITEM_GROUP B on (A.[group] = B.it_group_name)
--where B.it_group_name <>'' AND B.it_group_name not in ('Machine','Plant','Equipment'))
-- --and tax_name like '%vat%'
--  and st_type in('local','') and per <> 0 group by per order by per
SET @AMTA1 = 0
SELECT @AMTA1 = Count(PARTSR) FROM #FORM221 WHERE PARTSR = '4A'
SET @AMTA1 = ISNULL(@AMTA1,0)
IF @AMTA1 = 0 
	BEGIN
		INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES  (1,'4A','A',0,0,0,0,'')
	END
SELECT @AMTA1 = 0,@AMTB1 = 0,@AMTC1 = 0,@AMTD1 = 0
SELECT @AMTA1=SUM(AMT1),@AMTB1=SUM(AMT2),@AMTC1=SUM(AMT3),@AMTD1=SUM(AMT4) FROM #FORM221 WHERE PARTSR = '4A' AND SRNO ='A'
INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'4A','A',0,@AMTA1,@AMTB1,@AMTC1,@AMTD1,'Total')

---PART F: Input Tax Rebate (on plant, machinery, equipment and parts thereof)
INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM)
select 1 as part,'5' as partsr,'A' as srno,0 as per1,isnull(sum(a.Gro_Amt),0) as amt1,isnull(sum(a.taxamt),0) as amt2,0 as amt3
 ,(cast(s.level1 as varchar(20)) +' %' ) as per1 from JVITEM a inner join jvmain c on (a.entry_ty=c.entry_ty and a.Tran_cd = c.Tran_cd)
 inner join STAX_MAS s on (a.tax_name = s.tax_name)
 inner join it_mast b on (a.it_code=b.it_code) where a.entry_ty ='J4' and (a.DATE BETWEEN @SDATE AND @EDATE) and B.It_code in (Select A.It_Code from IT_MAST A INNER JOIN 
 ITEM_GROUP B on (A.[group] = B.it_group_name) where B.it_group_name <>'' AND B.it_group_name 
 in ('Machine','Plant','Equipment')) and a.rate <> 0 and c.VAT_ADJ='Input Tax - Rebate' and s.entry_ty = 'J4' group by s.level1 order by s.level1
--select 1 as part,'5' as partsr,'A' as srno,0 as per1,isnull(sum(case when a.bhent in('PT','P1','EP') then +a.vatonamt else -a.vatonamt end),0) as amt1,isnull(sum(case when a.bhent in('PT','P1','EP') then +a.taxamt else -a.taxamt end),0) as amt2,0 as amt3
--,(cast(a.per as varchar(20)) +' %' ) as per1 from vattbl  a inner join it_mast b on (a.it_code=b.it_code) where a.bhent in('PT','PR','P1','EP') and  b.TYPE  IN ('Machinery/Stores')
----and tax_name like '%vat%'
--and st_type in('local','') and per <> 0 group by per order by per
SET @AMTA1 = 0
SELECT @AMTA1 = Count(PARTSR) FROM #FORM221 WHERE PARTSR = '5' 
SET @AMTA1 = ISNULL(@AMTA1,0)
IF @AMTA1 = 0 
	BEGIN
		INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES  (1,'5','A',0,0,0,0,'')
	END

SELECT @AMTA1 = 0,@AMTB1 = 0,@AMTC1 = 0,@AMTD1 = 0
SELECT @AMTA1=SUM(AMT1),@AMTB1=SUM(AMT2),@AMTC1=SUM(AMT3),@AMTD1=SUM(AMT4) FROM #FORM221 WHERE PARTSR = '5'
INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'5','Z',0,@AMTA1,@AMTB1,@AMTC1,@AMTD1,'Total')

---PART G: Rebate carried forward from previous quarter and other credits
--1. Input tax rebate from previous quarter
SET @AMTC1=0
DECLARE @STARTDT SMALLDATETIME,@ENDDT SMALLDATETIME,@TMONTH INT,@TYEAR INT
SET @TMONTH=DATEDIFF(M,@SDATE,@EDATE)
SET @TYEAR=DATEDIFF(YY,@SDATE,@EDATE)
SET @STARTDT=DATEADD(Y,-@TYEAR,@STARTDT)
SET @STARTDT=DATEADD(M,-(@TMONTH+1),@SDATE)
SET @ENDDT=DATEADD(D,-1,@SDATE)
select @AMTC1=SUM(A.NET_AMT) FROM JVMAIN A WHERE A.ENTRY_TY='J4' AND A.VAT_ADJ='Input tax rebate from previous quarter'
AND (A.DATE BETWEEN @SDATE AND @EDATE)
SET @AMTC1=ISNULL(@AMTC1,0)
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES(1,'6','A',0,0,@AMTC1,0,'')

--2. Other credit(i.e. Inventory Rebate/ disallowed cash refund claims in previous quarter)
SET @AMTC1 = 0
select @AMTC1=SUM(A.NET_AMT) FROM JVMAIN A WHERE A.ENTRY_TY='J4' AND A.VAT_ADJ='Refund Claim' AND (A.DATE BETWEEN @SDATE AND @EDATE)
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES(1,'6','B',0,0,@AMTC1,0,'')
---for total 1+2
SET @AMTC1 = 0
select @AMTC1 = isnull(sum(amt2),0) from #FORM221 where part=1 and partsr='6' 
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES(1,'6','C',0,0,@AMTC1,0,'')

--- PART H: Rebate for Adjustments
 --SELECT @AMTB1 = 0,@AMTD1 = 0
--SELECT @AMTB1=SUM(AMT2),@AMTD1=SUM(AMT4) FROM #FORM221 WHERE PARTSR = '5' AND SRNO = 'Z' 
--SET @AMTB1 = ISNULL(@AMTB1,0)
--SET @AMTD1 = ISNULL(@AMTD1,0)
--SELECT @AMTF1 = 0,@AMTH1 = 0
--SELECT @AMTF1=SUM(AMT2),@AMTH1=SUM(AMT4) FROM #FORM221 WHERE PARTSR = '6' AND SRNO = 'Z'
--SET @AMTF1 = ISNULL(@AMTF1,0)
--SET @AMTH1 = ISNULL(@AMTH1,0)
--SET @AMTI1 = 0
--SELECT @AMTI1=SUM(AMT1) FROM #FORM221 WHERE PARTSR = '7' AND SRNO = 'Z'
--SET @AMTI1 = ISNULL(@AMTI1,0)

--1 Total Rebate (E+F+G)
SELECT @AMTB1 = 0,@AMTD1 = 0
SELECT @AMTB1=ISNULL(SUM(AMT2),0),@AMTD1= @AMTD1+ISNULL(SUM(AMT4),0) FROM #FORM221 WHERE PARTSR ='4A' AND PARTY_NM = 'TOTAL' 
PRINT @AMTB1
SELECT @AMTB1=  @AMTB1 + ISNULL(SUM(AMT2),0),@AMTD1=@AMTD1+ISNULL(SUM(AMT4),0) FROM #FORM221 WHERE PARTSR ='5' and SRNO ='Z'
PRINT @AMTB1
SELECT @AMTB1 = @AMTB1 + ISNULL(SUM(AMT2),0),@AMTD1=@AMTD1+ISNULL(SUM(AMT4),0) FROM #FORM221 WHERE PARTSR IN('6')and srno <> 'C'
PRINT @AMTB1
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES(1,'7','A',0,0,@AMTB1,0,'')

--2. Amount of rebate for which cash refund is asked for
SELECT @AMTD1 = 0
SELECT @AMTD1 = ISNULL(SUM(A.NET_AMT),0) FROM JVMAIN A WHERE A.ENTRY_TY='J4' AND A.VAT_ADJ='Amount of rebate for which cash refund is asked for'
AND (A.DATE BETWEEN @SDATE AND @EDATE)
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES(1,'7','B',0,0,@AMTD1,0,'')

--3. Amount of rebate for adjustment (1-2)
SELECT @AmtA1 = 0
SELECT @AmtA1 = ISNULL(@AMTB1 - @AMTD1,0)
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES(1,'7','C',0,0,@AmtA1,0,'')

--(a) against VAT
Set @AmtA1 = 0
select @AmtA1 = ISNULL(SUM(A.NET_AMT),0) FROM JVMAIN A WHERE A.ENTRY_TY='J4' AND A.VAT_ADJ='VAT' AND (A.DATE BETWEEN @SDATE AND @EDATE)
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES(1,'7','D',0,0,@AmtA1,0,'')

--(b) against Central Sales Tax
Set @AmtA1 = 0
select @AmtA1 = ISNULL(SUM(A.NET_AMT),0) FROM JVMAIN A WHERE A.ENTRY_TY='J4' AND A.VAT_ADJ='CST' AND (A.DATE BETWEEN @SDATE AND @EDATE)
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES(1,'7','E',0,0,@AmtA1,0,'')

--- PART I: Amount of Tax Payable
--1. Total Tax (B+C+D)
SELECT @AMTA1 = 0
SELECT @AMTB1=isnull(SUM(AMT2),0) FROM #FORM221 WHERE PARTSR in('2','3') AND SRNO = 'Z'

SELECT @AMTE1 = 0
SELECT @AMTE1=isnull(SUM(AMT1),0) FROM #FORM221 WHERE PARTSR = '4' AND SRNO = 'A'

INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES(1,'8','A',0,(@AMTB1+@AMTE1),0,0,'')

--2. Adjustment of Rebate {3(a) of PART H}
Select @AMTG1=sum(Amt2) From #Form221 Where Partsr ='7' and srno = 'D'
Set @AMTG1 = isnull(@AMTG1,0)
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES(1,'8','B',0,@AMTG1,0,0,'')

--3. Tax Payable (1-2) (if 1 exceeds 2)
SET @AMTK1 = CASE WHEN (@AMTB1+@AMTE1) > @AMTG1 THEN ((@AMTB1+@AMTE1) - @AMTG1) ELSE 0 END
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES(1,'8','C',0,@AMTK1,0,0,'')

--4. Amount deferred from tax payable
SET @AMTD1 = 0
select @AMTD1=SUM(A.NET_AMT) FROM JVMAIN A WHERE A.ENTRY_TY='J4' AND A.VAT_ADJ='Amount deferred from tax payable' AND (A.DATE BETWEEN @SDATE AND @EDATE)
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES(1,'8','D',0,@AMTD1,0,0,'')

-- 5. Net amount Payable (3-4)
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm)
VALUES(1,'8','E',0,@AMTK1 - @AMTD1,0,0,'')

--6. Interest for Late Payment (if any)
SET @AMTA1 = 0 
SELECT @AMTA1 = ISNULl(SUM(NET_AMT),0) FROM BPMAIN WHERE U_NATURE ='INTEREST' AND PARTY_NM ='VAT PAYABLE' 
AND(DATE BETWEEN @SDATE AND @EDATE)
INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'8','F',0,@AMTA1,0,0,'')


---7. Total Amount Payable (5+6)
Set @AMTA1 = 0 
Set @AMTA2 = 0
Select @AMTA1=sum(Amt1) From #Form221 Where Partsr ='8' and srno = 'E'
Select @AMTA2=sum(Amt1) From #Form221 Where Partsr ='8' and srno = 'F'
Set @AMTA1 = isnull(@AMTA1,0)
Set @AMTA2 = isnull(@AMTA2,0)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
(1,'8','G',0,@AMTA1+@AMTA2,0,0,'')


--8. Rebate carried over to next quarter (2-1) (if 2 exceeds 1)
Set @AMTA1 = 0 
Set @AMTA2 = 0
Select @AMTA1=sum(Amt1) From #Form221 Where Partsr ='8' and srno = 'A'
Select @AMTA2=sum(Amt1) From #Form221 Where Partsr ='8' and srno = 'B'
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
(1,'8','H',0,CASE WHEN (@AMTA2-@AMTA1) > 0 THEN (@AMTA2-@AMTA1) ELSE 0 END,0,0,'')
--9

--- PAYMENT DETAILS:
--10
Declare @TAXONAMT as numeric(12,2),@TAXAMT1 as numeric(12,2),@ITEMAMT as numeric(12,2),@INV_NO as varchar(10),@DATE as smalldatetime,@PARTY_NM as varchar(50),@ADDRESS as varchar(100),@ITEM as varchar(50),@FORM_NM as varchar(30),@S_TAX as varchar(30),@QTY as numeric(18,4)
--SELECT @TAXONAMT=0,@TAXAMT =0,@ITEMAMT =0,@INV_NO ='',@DATE ='',@PARTY_NM ='',@ADDRESS ='',@ITEM ='',@FORM_NM='',@S_TAX ='',@QTY=0

--SET @CHAR=65

--Declare Cur_VatPay cursor FOR
--select B.bank_nm, A1.s_tax, b.u_chalno, B.Date, b.net_amt from VATTBL A
--Inner join Bpmain B on (A.Bhent = B.Entry_ty and A.Tran_cd = B.Tran_cd)
--INNER JOIN AC_MAST A1 ON (A1.AC_NAME = B.BANK_NM)
--where BHENT = 'BP' And B.Date Between @sdate and @edate And B.Party_nm like '%VAT%'
--open Cur_VatPay
--FETCH NEXT FROM Cur_VatPay INTO @PARTY_NM,@ADDRESS,@INV_NO,@DATE,@TAXONAMT
--	WHILE (@@FETCH_STATUS=0)
--	BEGIN

--	SET @PARTY_NM=CASE WHEN @PARTY_NM IS NULL THEN '' ELSE @PARTY_NM END
--	SET @ADDRESS=CASE WHEN @ADDRESS IS NULL THEN '' ELSE @ADDRESS END
--	SET @INV_NO=CASE WHEN @INV_NO IS NULL THEN '' ELSE @INV_NO END
--	SET @DATE=CASE WHEN @DATE IS NULL THEN '' ELSE @DATE END
--	SET @TAXONAMT=CASE WHEN @TAXONAMT IS NULL THEN 0 ELSE @TAXONAMT END

--	INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS) VALUES (1,'10',CHAR(@CHAR),0,@TAXONAMT,0,0,@INV_NO,@DATE,@PARTY_NM,@ADDRESS)
--	SET @CHAR=@CHAR+1
--	FETCH NEXT FROM CUR_VatPay INTO @PARTY_NM,@ADDRESS,@INV_NO,@DATE,@TAXONAMT
--END
--CLOSE CUR_VatPay
--DEALLOCATE CUR_VatPay

INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS)
			SELECT 1 AS PART,'9' AS PARTSR,'A' AS SRNO,0 AS RATE,A.NET_AMT AS AMT1,0 AS AMT2,0 AS AMT3
			,A.u_CHALNO,A.u_CHALDT,B.AC_NAME,B.S_TAX FROM BPMAIN A INNER JOIN AC_MAST B ON (A.BANK_NM=B.AC_NAME)
			 WHERE (A.DATE BETWEEN @SDATE AND @EDATE) AND
			  B.TYP ='BANK' AND A.PARTY_NM ='VAT PAYABLE'
-- VALUES (1,'10',CHAR(@CHAR),0,0,0,0,@INV_NO,@DATE,@PARTY_NM,@ADDRESS)


--------------------------------------------------------------------------------------------------------

IF NOT EXISTS (SELECT TOP 1 SRNO FROM #FORM221 WHERE PARTSR='9')
BEGIN
	INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,party_nm) VALUES (1,'9','A',0,0,0,0,'')
END
-----------------------------------------------------------------------------------------------------

 


--
INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,party_nm,S_TAX)
SELECT 1 AS PART,'10' AS PARTSR,'A' AS SRNO, 0 AS RATE,ISNULL(SUM(A.GRO_AMT),0) AS AMT1 ,0 AS AMT2, 0 AS AMT3, A.AC_NAME,A.S_TAX FROM VATTBL A 
INNER JOIN IT_MAST B ON (A.IT_CODE=B.IT_CODE) WHERE A.BHENT ='PT' AND a.ST_TYPE IN('LOCAL') 
AND B.u_SHCODE IN('Schedule II','Schedule-II','Schedule 2','Schedule-2') and (a.date between @sdate and @edate)
GROUP BY A.AC_NAME,A.S_TAX  having(ISNULL(SUM(A.GRO_AMT),0))>=25000 ORDER BY A.AC_NAME,A.S_TAX
if not exists (SELECT top 1 srno FROM #FORM221 WHERE PARTSR='10')
begin
	INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,party_nm,S_TAX) VALUES (1,'10','A',0,0,0,0,'','')
end
--11

--- Part K
--12
SET @AMTA1 = 0

SELECT @AMTA1 =ISNULL(SUM(A.GRO_AMT),0) FROM VATTBL A INNER JOIN PTMAIN B ON (A.BHENT=B.ENTRY_TY AND A.TRAN_CD =B.TRAN_CD) WHERE A.BHENT ='P1'
AND B.U_NT ='FOR RESALE' AND(A.DATE BETWEEN @SDATE AND @EDATE)
SET @AMTB1 = 0
SELECT @AMTB1 =ISNULL(SUM(A.GRO_AMT),0) FROM VATTBL A INNER JOIN PTMAIN B ON (A.BHENT=B.ENTRY_TY AND A.TRAN_CD =B.TRAN_CD) WHERE A.BHENT ='P1'
AND B.U_NT ='FOR USE OR CONSUMPTION IN MANUFACTURE' AND(A.DATE BETWEEN @SDATE AND @EDATE)

INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,party_nm) VALUES (1,'11','A',0,@AMTA1,@AMTB1,0,'')
--INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,party_nm) VALUES (1,'11','B',0,@AMTA1,0,0,'')

--- PART L
--13
INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,INV_NO,DATE,ITEM,PARTY_NM,ADDRESS, U_LRNO, U_LRDT, U_PONO, U_PODT, FORM_NO, FORMRDT)
SELECT 1,'12', 'A', 0, A.VATONAMT, A.INV_NO, A.DATE, D.ITEM, A.AC_NAME, A.ADDRESS, M.U_LRNO, M.U_LRDT, M.U_PONO, M.U_PODT, M.FORM_NO, M.FORMRDT FROM vattbl A
INNER JOIN STMAIN M ON (M.entry_ty = A.BHENT AND M.Tran_cd = A.TRAN_CD)
INNER JOIN STITEM D ON (D.entry_ty = A.BHENT AND  D.itserial = A.ItSerial AND D.Tran_cd = A.TRAN_CD)
WHERE A.BHENT = 'ST' AND M.VATMTYPE LIKE '%SEZ%' And A.Date Between @sdate and @edate

IF NOT EXISTS (SELECT TOP 1 SRNO FROM #FORM221 WHERE PARTSR='12')
BEGIN
	INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,party_nm) VALUES (1,'12','A',0,0,0,0,'')
END
--12


Update #form221 set  PART = isnull(Part,0) , Partsr = isnull(PARTSR,''), SRNO = isnull(SRNO,''),
	 RATE = isnull(RATE,0), AMT1 = isnull(AMT1,0), AMT2 = isnull(AMT2,0), 
				 AMT3 = isnull(AMT3,0), AMT4 = isnull(AMT4,0), INV_NO = isnull(INV_NO,''), DATE = isnull(Date,''), 
				 PARTY_NM = isnull(Party_nm,''), ADDRESS = isnull(Address,''),ITEM = isnull(ITEM,''),
				 U_LRNO = isnull(U_LRNO,''), U_LRDT = isnull(U_LRDT,''),
				 U_PONO = isnull(U_PONO,''), U_PODT = isnull(U_PODT,''),
				 FORM_NO = isnull(form_nO,''), FORMRDT = isnull(FORMRDT,''), S_TAX = isnull(S_tax,'')--, Qty = isnull(Qty,0),  ITEM =isnull(item,''),

SELECT * FROM #FORM221 order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int), partsr,SRNO

END

set ANSI_NULLS OFF
--Print 'MP VAT FORM 10'

