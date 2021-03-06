if exists(select [name] from sysobjects where [name]='USP_REP_DL_CSTFORM01' and xtype='P')
begin
	drop procedure USP_REP_DL_CSTFORM01
end
GO
/****** Object:  StoredProcedure [dbo].[USP_REP_DL_CSTFORM01]    Script Date: 04/15/2014 15:40:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
EXECUTE USP_REP_DL_CSTFORM01'','','','04/01/2013','03/31/2019','','','','',0,0,'','','','','','','','','2016-2017',''
*/
 -- =============================================
 -- Author:      Sandeep 
 -- Create date: 05-03-2014
 -- Description: This Stored procedure is useful to generate DL CST FORM 01
 -- Modification : By "Suraj Kumawat " for Bug-28099
 -- Modification Date : 27/05/2016  
 -- =============================================

CREATE PROCEDURE [dbo].[USP_REP_DL_CSTFORM01]
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
, @MFCON VARCHAR(4000) = ''
AS
BEGIN
SET NOCOUNT ON
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
DECLARE @RATE NUMERIC(20,2),@AMTA1 NUMERIC(20,2),@AMTB1 NUMERIC(20,2),@AMTC1 NUMERIC(20,2),@AMTD1 NUMERIC(20,2),@AMTE1 NUMERIC(20,2),@AMTF1 NUMERIC(20,2),@AMTG1 NUMERIC(20,2),@AMTH1 NUMERIC(20,2),@AMTI1 NUMERIC(20,2),@AMTJ1 NUMERIC(20,2),@AMTK1 NUMERIC(20,2),@AMTL1 NUMERIC(20,2),@AMTM1 NUMERIC(20,2),@AMTN1 NUMERIC(20,2),@AMTO1 NUMERIC(20,2)
DECLARE @AMTA2 NUMERIC(20,2),@AMTB2 NUMERIC(20,2),@AMTC2 NUMERIC(20,2),@AMTD2 NUMERIC(20,2),@AMTE2 NUMERIC(20,2),@AMTF2 NUMERIC(20,2),@AMTG2 NUMERIC(20,2),@AMTH2 NUMERIC(20,2),@AMTI2 NUMERIC(20,2),@AMTJ2 NUMERIC(20,2),@AMTK2 NUMERIC(20,2),@AMTL2 NUMERIC(20,2),@AMTM2 NUMERIC(20,2),@AMTN2 NUMERIC(20,2),@AMTO2 NUMERIC(20,2)
DECLARE @PER NUMERIC(20,2),@TAXAMT NUMERIC(20,2),@CHAR INT,@LEVEL NUMERIC(20,2),@TAXNAME NVARCHAR(50),@TYPE NVARCHAR(50),@PARTY_NM as varchar(50),@FORM_NM as varchar(50)

SELECT DISTINCT AC_NAME=SUBSTRING(AC_NAME1,2,CHARINDEX('"',SUBSTRING(AC_NAME1,2,100))-1) INTO #VATAC_MAST FROM STAX_MAS WHERE AC_NAME1 NOT IN ('"SALES"','"PURCHASES"') AND ISNULL(AC_NAME1,'')<>''
INSERT INTO #VATAC_MAST SELECT DISTINCT AC_NAME=SUBSTRING(AC_NAME1,2,CHARINDEX('"',SUBSTRING(AC_NAME1,2,100))-1) FROM STAX_MAS WHERE AC_NAME1 NOT IN ('"SALES"','"PURCHASES"') AND ISNULL(AC_NAME1,'')<>''
SELECT ENTRY_TY,BCODE=(CASE WHEN EXT_VOU=1 THEN BCODE_NM ELSE ENTRY_TY END)  INTO #LCODE FROM LCODE 
Declare @NetEff as numeric (12,2), @NetTax as numeric (12,2)
SELECT PART=3,PARTSR='AAA',SRNO='AAA',RATE=99.999,AMT1=CAST('0' AS NUMERIC(20,2)),AMT2=CAST('0' AS NUMERIC(20,2)),AMT3=CAST('0' AS NUMERIC(20,2)),
M.INV_NO,M.DATE,PARTY_NM=AC1.AC_NAME,ADDRESS=Ltrim(AC1.Add1)+' '+Ltrim(AC1.Add2)+' '+Ltrim(AC1.Add3),STM.FORM_NM,AC1.S_TAX
,STM.RFORM_NM,CAST('0' AS NUMERIC(20,2)) AS AMT4,CAST('0' AS NUMERIC(20,2)) AS AMT5 --Added by Priyanka on 25022014
,TAX_NAME=CAST('' AS VARCHAR(12)),n.item,EIT_NAME=CAST('' AS VARCHAR(50)),CONTTAX=CAST(0 AS DECIMAL(12,2)),CTYPE=CAST('' AS VARCHAR(2)) -- Added by Pankaj on 03.03.2014
INTO #FORMCST01
FROM PTACDET A 
INNER JOIN STMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME)
INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID)
inner join stitem n on (m.tran_cd=n.tran_cd) 
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
		SET @SQLCOMMAND='Insert InTo  #FORMCST_01 Select * from '+@MCON
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
--------------------------------------------
SET @AMTA1=0
SET @AMTB1=0
SET @AMTC1=0
SELECT @AMTA1=SUM(NET_AMT) FROM (SELECT DISTINCT A.NET_AMT,a.tran_cd FROM VATTBL a inner join #lcode lc on (a.bhent=lc.entry_ty)
WHERE (lc.bcode='ST') AND (DATE BETWEEN @SDATE AND @EDATE) and rtrim(ltrim((a.st_type)))='LOCAL' )C
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES  (1,'4','B',0,@AMTA1,0,0,'')
--------------------------------------------
SET @AMTB1=0
SELECT @AMTB1=SUM(NET_AMT) FROM (SELECT DISTINCT A.NET_AMT,a.tran_cd FROM VATTBL a inner join #lcode lc on (a.bhent=lc.entry_ty)
WHERE (lc.bcode='ST') AND (DATE BETWEEN @SDATE AND @EDATE) and rtrim(ltrim((a.st_type)))='OUT OF STATE' ) C
SET @AMTB1=CASE WHEN @AMTB1 IS NULL THEN 0 ELSE @AMTB1 END
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES  (1,'4','C',0,@AMTB1,0,0,'')  
-----------------------------------------------
---Commented by suraj date on 23-07-2016 start
--SET @AMTC1=0
--SET @AMTC1=CASE WHEN @AMTC1 IS NULL THEN 0 ELSE @AMTC1 END
--SET @AMTA1=0
--SET @AMTB1=0
--SET @PARTY_NM=''
--SELECT @AMTA1=amt1 FROM #FORMCST01
--SELECT tot_amt=sum(a.NET_AMT),volume=(SUM(A.NET_AMT)/@AMTA1)*100,it_desc= case when ltrim(rtrim(cast(IT.IT_DESC as varchar(50)))) ='' then IT.it_name else  ltrim(rtrim(cast(IT.IT_DESC as varchar(50)))) end,a.per,it.it_name--ltrim(rtrim(it.it_name))+' '+ltrim(rtrim(cast(IT.IT_DESC as varchar(50)))),a.per
--into #1 
--FROM VATTBL a inner join #lcode lc on (a.bhent=lc.entry_ty)  inner join it_mast it on (it.it_code=a.it_code)
--where lc.bcode='ST' AND (DATE BETWEEN @SDATE AND @EDATE) and a.per<>0 --and  it.nonstk='Stockable'AND (DATE BETWEEN @SDATE AND @EDATE) 
--group by a.per,it_name,ltrim(rtrim(cast(IT.IT_DESC as varchar(50))))--,ltrim(rtrim(it.it_name))
--SET @CHAR=65
--SET @PER = 0
--declare Cur_VatPay cursor  for
--select top 5 MAX(volume),it_desc,per,it_name from #1 GROUP BY it_desc,per,it_name ORDER BY MAX(volume) DESC
--open Cur_VatPay
--FETCH NEXT FROM Cur_VatPay INTO @AMTB1,@PARTY_NM,@PER,@form_nm
--	WHILE (@@FETCH_STATUS=0)
--	BEGIN
--	SET @AMTB1=CASE WHEN @AMTB1 IS NULL THEN 0 ELSE @AMTB1 END
--	SET @PARTY_NM=CASE WHEN @PARTY_NM IS NULL THEN '' ELSE @PARTY_NM END
--	SET @PER=CASE WHEN @PER IS NULL THEN 0 ELSE @PER END
--	SET @FORM_NM=CASE WHEN @FORM_NM IS NULL THEN '' ELSE @FORM_NM END
	
--	INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,FORM_NM)
--                      VALUES (1,'3','A',@PER,0,0,0,@PARTY_NM,@FORM_NM)
--	FETCH NEXT FROM CUR_VatPay INTO @AMTB1,@PARTY_NM,@per,@FORM_NM
--END
--CLOSE CUR_VatPay
--DEALLOCATE CUR_VatPay
--drop table #1
---Commented by suraj date on 23-07-2016 End
---added by suraj date on 23-07-2016 Start
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,FORM_NM)select top 5 c.* from (select 1 as part,'3' as partsr,'A' as srno,a.PER
,isnull(sum(a.taxamt),0) as taxamt,isnull(sum(a.gro_amt),0)as gro_amt ,0 as amt3
, (case when cast(b.it_desc as varchar(150)) ='' then b.it_name else cast(b.it_desc as varchar(150)) end) as descr
,b.it_name from VATTBL a inner join it_mast b on (a.It_code =b.It_code) where a.BHENT  ='st' and a.TAX_NAME like '%c.s.t%'
and a.per > 0 group by a.PER,b.it_name, cast(b.it_desc as varchar(150))) c order by c.GRO_AMT desc
if not exists(select top 1 srno from #FORMCST01 where PART = 1 and PARTSR ='3') 
begin
	INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,FORM_NM)
	 VALUES (1,'3','A',0,0,0,0,'','')

end

 
---added by suraj date on 23-07-2016 End
----------------------------------------------------------------
SET @AMTA1=0
SELECT @AMTA1=SUM(NET_AMT) FROM (SELECT DISTINCT A.NET_AMT,a.tran_cd FROM VATTBL a inner join #lcode lc on (a.bhent=lc.entry_ty)
WHERE (A.BHENT='ST') AND (DATE BETWEEN @SDATE AND @EDATE))C
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES  (1,'4','A',0,@AMTA1,0,0,'')  

---R5 Less: Value of goods returned for sales made during the current tax period

SET @AMTA1=0
SET @AMTA2=0
SET @PER  =0
SELECT @AMTA1=SUM(NET_AMT) FROM (SELECT DISTINCT A.NET_AMT,a.tran_cd  FROM VATTBL a inner join #lcode lc on (a.bhent=lc.entry_ty)
WHERE lc.bcode IN ('SR') and st_type='OUT OF STATE' AND (DATE BETWEEN @SDATE AND @EDATE))C 
-------------------------------------------------------------------------------------
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES  (1,'5','A',0,@AMTA1,0,0,'')  
-------------------------------------------------------
---R5.1 Net Turnover (Central) (R4.3 - R 5.0)

SET @AMTA1=0
SET @AMTA2=0
SET @AMTB1=0
SET @PER  =0
SELECT  @AMTA1=AMT1 FROM #FORMCST01 WHERE PARTSR='4' AND SRNO='C'
SELECT  @AMTA2=AMT1 FROM #FORMCST01 WHERE PARTSR='5' AND SRNO='A'
SET @AMTB1=@AMTA1-@AMTA2
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
SET @AMTB1=CASE WHEN @AMTB1 IS NULL THEN 0 ELSE @AMTB1 END

INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES  (1,'5','B',0,@AMTB1,0,0,'')  

-------------------------------------------------------------
--part 6 
--R6 Deductions Claimed
--------------------------------------------------
--R6.1 Exports outside India
 INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'6','A',0,0,0,0,'')
----------------------
---R6.1 (1) Exports [Sec. 5(1)]
SET @AMTA1=0
SELECT @AMTA1=ISNULL(SUM(GRO_AMT),0) FROM VATTBL WHERE BHENT ='ST' AND U_IMPORM ='Export Out of India' AND ST_TYPE ='OUT OF COUNTRY'
AND  (DATE BETWEEN @SDATE AND @EDATE )
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'6','B',0,@AMTA1,0,0,'')
-----------------------------------------
--R6.1 (2) High Sea Sales [Sec. 5(2)]
SET @AMTA1=0
SELECT @AMTA1=ISNULL(SUM(GRO_AMT),0) FROM VATTBL WHERE BHENT ='ST' AND U_IMPORM in ('High Sea Sales','High Seas Sales') AND ST_TYPE = 'OUT OF COUNTRY' 
AND (DATE BETWEEN @SDATE AND @EDATE)
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'6','C',0,@AMTA1,0,0,'')

---R6.1 (3) Sales against H Forms [Sec. 5(3) Inter State]

SET @AMTA1=0
SET @AMTA2=0
SET @PER =0
SELECT @AMTA1=isnull(SUM(Gro_amt),0),@AMTA2=isnull(SUM(TAXAMT),0) FROM VATTBL 
WHERE (bhent='ST') AND (DATE BETWEEN @SDATE AND @EDATE) and st_type ='OUT OF STATE'
and ((RTRIM(LTRIM(REPLACE(replace(RFORM_NM,'FORM',''),'-',''))) = 'H') 
OR (RTRIM(LTRIM(REPLACE(replace(TAX_NAME,'FORM',''),'-',''))) = 'H'))
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES  (1,'6','D',@PER,@AMTA1,@AMTA2,0,'')

--R6.1(4) Sub-Total [R6.1(1)+R6.1(2)+ R6.1(3)]
SET @AMTA1=0
SET @AMTA2=0
SET @PER =0
SELECT @AMTA1=ISNULL(SUM(AMT1),0),@AMTA2=ISNULL(SUM(AMT2),0) FROM #FORMCST01 WHERE PARTSR='6' AND SRNO IN ('B','C','D')
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES  (1,'6','E',@PER,@AMTA1,@AMTA2,0,'Total')  

--R6.2 Stock/Branch Transfer against F Forms [Sec. 6(a)]

INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES  (1,'6','F',0,0,0,0,'')
--R6.2(1) On Consignment basis
SET @AMTA1=0
SET @AMTA2=0
SET @PER =0
SELECT  @AMTA1=ISNULL(SUM(Gro_amt),0),@AMTA2=ISNULL(SUM(TAXAMT),0) FROM vattbl WHERE (bhent='ST') AND U_IMPORM='Consignment Transfer'  and st_type ='OUT OF STATE' AND (DATE BETWEEN @SDATE AND @EDATE) 
and ((RTRIM(LTRIM(REPLACE(replace(RFORM_NM,'FORM',''),'-',''))) = 'F') 
OR (RTRIM(LTRIM(REPLACE(replace(TAX_NAME,'FORM',''),'-',''))) = 'F'))
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES  (1,'6','G',0,@AMTA1,@AMTA2,0,'')  

---R6.2(2) Branch Transfer

SET @AMTA1=0
SET @AMTA2=0
SET @PER =0
SELECT  @AMTA1=ISNULL(SUM(NET_AMT),0),@AMTA2=ISNULL(SUM(TAXAMT),0) FROM VATTBL A
WHERE (A.BHENT='ST') AND a.U_IMPORM='Branch Transfer' and a.st_type IN ('OUT OF STATE') AND (A.DATE BETWEEN @SDATE AND @EDATE) 
and ((RTRIM(LTRIM(REPLACE(replace(a.RFORM_NM,'FORM',''),'-',''))) = 'F') OR (RTRIM(LTRIM(REPLACE(replace(a.TAX_NAME,'FORM',''),'-',''))) = 'F'))
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES  (1,'6','H',0,@AMTA1,@AMTA2,0,'')  
--R6.2(3) Own goods transferred for Job Work against F Form
SET @AMTA1=0
SET @AMTA2=0
SELECT @AMTA1=ISNULL(SUM(A.NET_AMT),0) FROM IIMAIN A  INNER JOIN AC_MAST B ON (A.Ac_id = B.Ac_id ) WHERE A.entry_ty='LI' AND  ( A.DATE BETWEEN @SDATE AND @EDATE ) AND B.ST_TYPE ='OUT OF STATE'
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES  (1,'6','I',0,@AMTA1,@AMTA2,0,'')  
--R6.2(4) Other dealers’goods returned after Job work against F-Form
SET @AMTA1 = 0
SET @AMTA2 = 0
SELECT @AMTA1 =ISNULL(SUM(A.NET_AMT),0) FROM IIMAIN A INNER JOIN AC_MAST B ON (A.Ac_id =B.Ac_id ) WHERE A.entry_ty ='IL' AND  ( A.DATE BETWEEN @SDATE AND @EDATE ) AND B.st_type ='OUT OF STATE'
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES  (1,'6','J',0,@AMTA1,@AMTA2,0,'')

--R6.2(3) Sub-Total [R6.2(1)+R6.2(2)+R6.2(3)+R6.2(4)]

SET @AMTA1=0
SET @AMTA2=0
SET @PER =0
SELECT @AMTA1=ISNULL(SUM(AMT1),0),@AMTA2=ISNULL(SUM(AMT2),0) FROM #FORMCST01 WHERE PARTSR='6' AND SRNO IN ('G','H','I','J')
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES  (1,'6','K',0,@AMTA1,@AMTA2,0,'')  

---R6.3 Sales against E-I & E-II Forms [Sec. 6(2)]

SET @AMTA1=0
SET @AMTA2=0
SET @PER =0
SELECT  @AMTA1=ISNULL(SUM(gro_amt),0),@AMTA2=ISNULL(SUM(TAXAMT),0) FROM vattbl a WHERE (a.bhent='ST') and ( A.Tax_Name 
IN ('E - 1','E - 2','E-I','E-II','FORM E-1','FORM E-2','FORM E-I','FORM E-II') OR a.rform_nm IN ('E - 1','E - 2','E-I','E-II','FORM E-1','FORM E-2','FORM E-I','FORM E-II')) and (A.DATE BETWEEN @SDATE AND @EDATE) 
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES  (1,'6','L',0,@AMTA1,@AMTA2,0,'')  

--R6.4 Sales to diplomatic missions & U.N etc [Sec. 6(3)]

SET @AMTA1=0
SET @AMTA2=0
SET @PER =0
SELECT  @AMTA1=SUM(A.GRO_AMT),@AMTA2=SUM(A.TAXAMT) FROM VATTBL  A WHERE (A.BHENT='ST') and LTRIM(RTRIM(REPLACE(REPLACE(a.rform_nm,'FORM',''),'-',''))) ='J' and a.st_type IN ('OUT OF COUNTRY')
and A.U_IMPORM='Sales to Diplomatic Missions & U.N. Etc.'
AND (A.DATE BETWEEN @SDATE AND @EDATE)
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES  (1,'6','M',0,@AMTA1,@AMTA2,0,'')  

--R6.5 Sale of Exempted Goods (specified in Schedule 1 of DVAT ACT)

SET @AMTA1=0
SET @AMTA2=0
SET @PER =0
SELECT  @AMTA1=isnull(SUM(gro_amt),0),@AMTA2=isnull(SUM(TAXAMT),0) FROM vattbl WHERE (bhent='ST') AND TAX_NAME LIKE '%Exempted%' AND st_type IN ('OUT OF STATE') AND (DATE BETWEEN @SDATE AND @EDATE) 
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES  (1,'6','N',0,@AMTA1,@AMTA2,0,'') 
--R6.6 Sales covered under provision to [Sec.9(1)] Read with Sec 8(4)(a)]
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES  (1,'6','O',0,0,0,0,'') 

--R6.7 Sales of Goods Outside Delhi (Sec. 4)
SET @AMTA1=0
SET @AMTA2=0
SET @PER =0

SELECT  @AMTA1=ISNULL(SUM(A.GRO_AMT),0),@AMTA2=ISNULL(SUM(A.TAXAMT),0) FROM VATTBL A
WHERE A.BHENT ='ST' and A.ST_TYPE='OUT OF STATE' AND (A.DATE BETWEEN @SDATE AND @EDATE)
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES  (1,'6','P',0,@AMTA1,@aMTA2,0,'') 

--R6.8 Sales to S.E.Z. against Form I [Sec. 8(6) to 8(8)]
SET @AMTA1=0
SET @AMTA2=0
SET @per=0

SELECT @AMTA1=ISNULL(SUM(A.gro_amt),0),@AMTA2=ISNULL(SUM(A.TAXAMT),0) FROM VATTBL A WHERE (A.BHENT='ST') and A.ST_TYPE='OUT OF STATE' and  RTRIM(LTRIM(REPLACE(REPLACE(a.rform_nm,'FORM',''),'-','')))='I' AND (A.DATE BETWEEN @SDATE AND @EDATE)
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'6','Q',0,@AMTA1,@AMTA2,0,'')
--R6.9 Cost of Freight, deliveries, freight or installation, separately charged and cash discount
SET @AMTA1=0
SET @AMTA2=0
select @AMTA1=isnull(sum(a.u_frtamt),0) from stitem a inner join AC_MAST b on (a.Ac_id= b.Ac_id ) where a.entry_ty ='st' 
and  ( a.date between @sdate and @EDATE ) and b.st_type ='out of state' and  isnull((a.u_frtamt),0) <> 0
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'6','R',0,@AMTA1,0,0,'')
--R6.10 Job work, labour & Service charges for works contracts not amounting to sales but included in the Central Turnover

SET @AMTA1=0
SET @AMTA2=0
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'6','S',0,0,0,0,'')

--R6.11 Total deductions claimed [R6.1(4) to R6.10]
SET @AMTA1=0
SET @AMTA2=0
SET @per=0
SELECT  @AMTA1=isnull(SUM(AMT1),0), @AMTA2=isnull(SUM(AMT2),0) FROM #FORMCST01 WHERE  PARTSR='6' AND SRNO IN ('E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S')
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'6','T',0,@AMTA1,@AMTA2,0,'')

--R6.12 Balance Total turnover of Inter State Sales (R5.1 - R6.11)
SELECT  @AMTA1=AMT1, @AMTA2=AMT2 FROM #FORMCST01 WHERE  PARTSR='5'  AND SRNO='B' -- or  
SELECT  @AMTB1=AMT1, @AMTB2=AMT2 FROM #FORMCST01 WHERE  PARTSR='6'  AND SRNO='T' -- or  

--PARTSR='6'  AND (SRNO BETWEEN 'A' AND 'R')
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
SET @AMTB1=CASE WHEN @AMTB1 IS NULL THEN 0 ELSE @AMTB1 END
SET @AMTB2=CASE WHEN @AMTB2 IS NULL THEN 0 ELSE @AMTB2 END
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'6','U',0,@AMTA1-@AMTB1,@AMTA2-@AMTB2,0,'')

--R7 Calculation of Tax for the Quarter 
--R7.1 Turnover of Goods sold against C-Form [Goods specified in Schedule III of DVAT Act (i.e. @ 5%)]

--SELECT DISTINCT A.vatonamt,A.TAXAMT,a.per FROM #FORMCST_01 a inner join #lcode lc on (a.bhent=lc.entry_ty)
--left join stax_mas st on (a.bhent=st.entry_ty and a.tax_name=st.tax_name)
--WHERE (lc.bcode='ST') AND a.PER = 2.0 AND (a.DATE BETWEEN @SDATE AND @EDATE) and A.ST_TYPE='OUT OF STATE' AND st.Rform_NM='FORM C' 

SET @AMTA1=0
SET @AMTA2=0
SET @per=0
--SELECT  @Per=(Per),@AMTA1=((sum(VATONAMT)*5)/100),@AMTA2=(@AMTA1*@PER)/100 FROM (SELECT DISTINCT A.vatonamt,A.TAXAMT,a.per FROM VATTBL a inner join #lcode lc on (a.bhent=lc.entry_ty)
--WHERE (lc.bcode='ST') AND a.PER = 2.0 AND (a.DATE BETWEEN @SDATE AND @EDATE) and A.ST_TYPE='OUT OF STATE' AND a.Rform_NM='FORM C' )c 
--Group by per
--SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
--SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
SELECT @AMTA1=ISNULL(SUM(A.VATONAMT),0),@AMTA2=ISNULL(SUM(A.TAXAMT),0)  FROM VATTBL A 
INNER JOIN IT_MAST B ON (A.It_code =B.It_code)
WHERE A.BHENT ='ST' AND A.PER = 5  AND ((RTRIM(LTRIM(REPLACE(replace(a.RFORM_NM,'FORM',''),'-',''))) = 'C') 
OR (RTRIM(LTRIM(REPLACE(replace(a.TAX_NAME,'FORM',''),'-',''))) = 'C')) AND B.U_SHCODE IN('Schedule III','Schedule 3','Schedule-III','Schedule-3','Sch III','Sch 3','Sch-III','Sch-3')
and a.ST_TYPE='OUT OF STATE'
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES  (1,'7','A',5.00,@AMTA1,@AMTA2,0,'')  
--R7.2 Turnover of Goods sold against C-Form [Goods not specified in any Schedules of DVAT Act (i.e. @ 12.5%)]
SET @AMTA1=0
SET @AMTA2=0
SET @per=0


--SELECT  @Per=(Per),@AMTA1=((sum(VATONAMT)*12.5)/100),@AMTA2=(@AMTA1*@PER)/100 FROM (SELECT DISTINCT A.vatonamt,A.TAXAMT,a.per FROM VATTBL a inner join #lcode lc on (a.bhent=lc.entry_ty)

--WHERE (lc.bcode='ST') AND a.PER = 2.0 AND (a.DATE BETWEEN @SDATE AND @EDATE) and A.ST_TYPE='OUT OF STATE' AND a.Rform_NM='FORM C' )c 
--Group by per
SELECT @AMTA1=ISNULL(SUM(A.VATONAMT),0),@AMTA2=ISNULL(SUM(A.TAXAMT),0)  FROM VATTBL A 
INNER JOIN IT_MAST B ON ( A.IT_CODE =B.IT_CODE )WHERE A.BHENT ='ST' AND A.PER = 12.5 
AND ((RTRIM(LTRIM(REPLACE(replace(a.RFORM_NM,'FORM',''),'-',''))) = 'C'))
AND ISNULL(B.U_SHCODE,'') ='' and a.ST_TYPE='OUT OF STATE'
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'7','B',12.50,@AMTA1,@AMTA2,0,'')

--R7.3 Turnover of Goods sold against C-Form [Fourth Schedule of DVAT Act (i.e. @ 20%)]
SET @AMTA1=0
SET @AMTA2=0
SET @per=0


--SELECT  @Per=(Per),@AMTA1=((sum(VATONAMT)*20.00)/100),@AMTA2=(@AMTA1*@PER)/100 FROM (SELECT DISTINCT A.vatonamt,A.TAXAMT,a.per FROM VATTBL a inner join #lcode lc on (a.bhent=lc.entry_ty)

--WHERE (lc.bcode='ST') AND a.PER = 2.0 AND (a.DATE BETWEEN @SDATE AND @EDATE) and A.ST_TYPE='OUT OF STATE' AND a.Rform_NM='FORM C' )c 
--Group by per
SELECT @AMTA1=ISNULL(SUM(A.VATONAMT),0),@AMTA2=ISNULL(SUM(A.TAXAMT),0)  FROM VATTBL A 
INNER JOIN IT_MAST B ON (A.It_code =B.It_code) WHERE A.BHENT ='ST' AND A.PER = 20 
AND ((RTRIM(LTRIM(REPLACE(replace(a.RFORM_NM,'FORM',''),'-',''))) = 'C'))
AND B.U_SHCODE IN('Schedule 4','Schedule IV','Schedule-4','Schedule-4','Sch IV','Sch IV','Sch-IV','Sch-4')
and a.ST_TYPE='OUT OF STATE'

INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'7','C',20,@AMTA1,@AMTA2,0,'')
--R7.4 Turnover of Goods sold against C-Form [Specified in Schedule II of DVAT Act]
SET @AMTA1=0
SET @AMTA2=0
SET @per=0


--SELECT  @AMTA1=SUM(vatonamt),@AMTA2=SUM(TAXAMT),@Per=(Per) FROM (SELECT DISTINCT A.vatonamt,A.TAXAMT,a.per FROM VATTBL a inner join #lcode lc on (a.bhent=lc.entry_ty)

--WHERE (lc.bcode='ST') AND a.PER = 1.0 AND (a.DATE BETWEEN @SDATE AND @EDATE) and A.ST_TYPE='OUT OF STATE' AND a.Rform_NM='FORM C' )c 
--Group by per
SELECT @AMTA1=ISNULL(SUM(A.VATONAMT),0),@AMTA2=ISNULL(SUM(A.TAXAMT),0)  FROM VATTBL A
 INNER JOIN IT_MAST B ON (A.It_code =B.IT_CODE) WHERE A.BHENT ='ST' AND A.PER NOT IN(12.5,5,20) 
AND ((RTRIM(LTRIM(REPLACE(replace(a.RFORM_NM,'FORM',''),'-',''))) = 'C'))
AND B.U_SHCODE IN('Schedule II','Schedule 2','Schedule-II','Schedule-2','Sch II','Sch 2','Sch-II','Sch-2')
and a.ST_TYPE='OUT OF STATE'
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'7','D',0,@AMTA1,@AMTA2,0,'')

--R7.5 Turnover of Goods sold without C-Form [Goods specified in Schedule III of DVAT Act]
SET @AMTA1=0
SET @AMTA2=0
SET @per=0

SELECT @AMTA1=ISNULL(SUM(A.VATONAMT),0),@AMTA2=ISNULL(SUM(A.TAXAMT),0)  FROM VATTBL A 
 INNER JOIN IT_MAST B ON (A.It_code =B.It_code ) WHERE A.BHENT ='ST' 
AND ((RTRIM(LTRIM(REPLACE(replace(a.RFORM_NM,'FORM',''),'-',''))) != 'C'))
AND B.U_SHCODE IN('Schedule III','Schedule 3','Schedule-III','Schedule-3','Sch III','Sch 3','Sch-III','Sch-3')
and a.ST_TYPE='OUT OF STATE'
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'7','E',0,@AMTA1,@AMTA2,0,'')
--R7.6 Turnover of Goods sold without C-Form [Goods not specified in any Schedules of DVAT Act]
SET @AMTA1=0
SET @AMTA2=0
SET @per=0

--SELECT  @AMTA1=SUM(vatonamt),@AMTA2=SUM(TAXAMT),@Per=(Per) FROM (SELECT DISTINCT A.vatonamt,A.TAXAMT,a.per FROM VATTBL a inner join #lcode lc on (a.bhent=lc.entry_ty)

--WHERE (lc.bcode='ST') AND a.PER = 12.5 AND (a.DATE BETWEEN @SDATE AND @EDATE) and A.ST_TYPE='OUT OF STATE' AND a.Rform_NM='FORM C' )c 
--Group by per

SELECT @AMTA1=ISNULL(SUM(A.VATONAMT),0),@AMTA2=ISNULL(SUM(A.TAXAMT),0)  FROM VATTBL A 
INNER JOIN IT_MAST B ON (A.It_code =B.It_code ) WHERE A.BHENT ='ST' 
AND ((RTRIM(LTRIM(REPLACE(replace(a.RFORM_NM,'FORM',''),'-',''))) != 'C'))
AND ISNULL(B.U_SHCODE,'') =''  and a.ST_TYPE='OUT OF STATE'
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'7','F', 0,@AMTA1,@AMTA2,0,'')

--R7.7 Turnover of Goods sold without C-Form [Fourth Schedule of DVAT Act]
SET @AMTA1=0
SET @AMTA2=0
SET @per=0

SELECT @AMTA1=ISNULL(SUM(A.VATONAMT),0),@AMTA2=ISNULL(SUM(A.TAXAMT),0)  FROM VATTBL A 
 INNER JOIN IT_MAST B ON (A.It_code =B.It_code ) WHERE A.BHENT ='ST' 
AND ((RTRIM(LTRIM(REPLACE(replace(a.RFORM_NM,'FORM',''),'-',''))) != 'C'))
AND B.U_SHCODE IN('Schedule IV','Schedule 4','Schedule-IV','Schedule-4','Sch IV','Sch 4','Sch-IV','Sch-4')
and a.ST_TYPE='OUT OF STATE'
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'7','G',0,@AMTA1,@AMTA2,0,'')

--R7.8 Total (R7.1 to R7.7)
SET @AMTA1=0
SET @AMTA2=0
SELECT @AMTA1=SUM(AMT1),@AMTA2=SUM(AMT2) FROM #FORMCST01 WHERE PARTSR='7' AND SRNO IN ('A','B','C','D','E','F','G')
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'7','H',0,@AMTA1,@AMTA2,0,'')


--R7.9 Less: Amount of tax on value of sold goods return under CST Act,for the previous tax periods but not older than six months
	---- Previous Period /Earlier Period---------
	--print 'Last year'
	--DECLARE @STARTDT int ,@ENDDT INT
	--set  @STARTDT =  DATEADD(m, -6, @sdate)
	--set @ENDDT  = DATEADD(d, -1, @sdate)
	--print @STARTDT
	--print @ENDDT
--set @STARTDT = cast(substring(@LYN,1,4) as int) - 1
--set @ENDDT   = cast(substring(@LYN,6,4) as int)  - 1
 
--rtrim(ltrim(CAST(@STARTDT AS CHAR))) + '-' + rtrim(ltrim(CAST(@ENDDT AS CHAR)))
---PRINT 'LAST YEAR FINANCAIL'

   --------------------------------------------
SET @AMTA1=0
SET @AMTA2=0
SET @per=0
--SELECT @AMTA1 = isnull(sum(CASE WHEN Lc.STAX_ITEM=1 THEN round(d.u_asseamt+D.EXAMT+D.U_CESSAMT+D.U_HCESAMT+d.tot_add+D.TOT_DEDUC,2) else round(((M.gro_amt+M.tot_add+M.tot_tax)-M.tot_deduc),2) end),0)
--,@AMTA2= isnull(sum(D.TAXAMT),0)
--FROM SRMAIN M  INNER JOIN SRITEM D ON (M.ENTRY_TY=D.ENTRY_TY AND M.TRAN_CD=D.TRAN_CD )  INNER JOIN AC_MAST AC ON (M.AC_ID=AC.AC_ID)  LEFT OUTER JOIN STAX_MAS STM 
--ON (D.TAX_NAME=STM.TAX_NAME And STM.Entry_ty = D.Entry_ty)  INNER JOIN IT_MAST IT  ON 
--(D.IT_CODE=IT.IT_CODE)  LEFT JOIN SHIPTO SHIP ON (SHIP.SHIPTO_ID=M.SAC_ID)  INNER JOIN LCODE lc  
--ON (lc.ENTRY_TY=D.ENTRY_TY)  where  ( M.DATE BETWEEN @STARTDT and @STARTDT )

SELECT @AMTA1=isnull(sum(CASE WHEN Lc.STAX_ITEM = 1 THEN round(d.u_asseamt+D.EXAMT+D.U_CESSAMT+D.U_HCESAMT+d.tot_add+D.TOT_DEDUC,2) else round(((M.gro_amt+M.tot_add+M.tot_tax)-M.tot_deduc),2) end),0)
,@AMTA2= isnull(sum(D.TAXAMT),0)
FROM SRMAIN M  INNER JOIN SRITEM D ON (M.ENTRY_TY=D.ENTRY_TY AND M.TRAN_CD=D.TRAN_CD )  INNER JOIN AC_MAST AC ON (M.AC_ID=AC.AC_ID)  LEFT OUTER JOIN STAX_MAS STM 
ON (D.TAX_NAME=STM.TAX_NAME And STM.Entry_ty = D.Entry_ty)  INNER JOIN IT_MAST IT  ON 
(D.IT_CODE=IT.IT_CODE)  LEFT JOIN SHIPTO SHIP ON (SHIP.SHIPTO_ID=M.SAC_ID)  INNER JOIN LCODE lc  
ON (lc.ENTRY_TY=D.ENTRY_TY) 
inner join SRITREF  G on(g.ENTRY_TY=D.ENTRY_TY AND g.TRAN_CD=D.TRAN_CD and g.Itserial =d.itserial) where 
( m.date between @SDATE and @EDATE)  and 
M.entry_ty ='SR' AND DATEDIFF(mm,G.Rdate,M.date) < = 6 
and ac.st_type ='out of state'

INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'7B','I',0,@AMTA1,@AMTA2,0,'')
--R7.10 Balance Tax Payable (R7.8 - 7.9)
SET @AMTA1=0
SET @AMTA2=0
SET @AMTb1=0
SET @AMTb2=0

SELECT @AMTA1=SUM(AMT1),@AMTA2=SUM(AMT2) FROM #FORMCST01 WHERE PARTSR='7' AND SRNO='H'
SELECT @AMTB1=SUM(AMT1),@AMTB2=SUM(AMT2) FROM #FORMCST01 WHERE PARTSR='7B' AND SRNO='I'
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
SET @AMTB1=CASE WHEN @AMTB1 IS NULL THEN 0 ELSE @AMTB1 END
SET @AMTB2=CASE WHEN @AMTB2 IS NULL THEN 0 ELSE @AMTB2 END


--INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'7','J',0,0,@AMTA2-@AMTB2,0,'')
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'7B','J',0,0,@AMTA2-@AMTB2,0,'')

--R7.11 Balance carried forward from previous tax period
set @AMTA1 = 0
set @AMTA2 = 0
SELECT @AMTA2=isnull(SUM(b.amount),0) FROM JVMAIN A inner join JVACDET b on (a.Tran_cd =b.Tran_cd and a.entry_ty =b.entry_ty and b.amt_ty ='dr') WHERE A.entry_ty  ='J4'  AND A.VAT_ADJ = 'Excess credit carried forward to  subsequent tax period' AND A.party_nm ='CST Payable'
and ( a.date between @SDATE and @EDATE)
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'7B','K',0,@AMTA1,@AMTA2,0,'')



--R7.12 Adjustment of Excess Tax Credit under DVAT towards CST liability (refer Item R9.1 of Form DVAT-16)
SET @AMTA1=0
SET @AMTA2=0

SELECT @AMTA2=isnull(SUM(b.amount),0) FROM JVMAIN A inner join JVACDET b on (a.Tran_cd =b.Tran_cd and a.entry_ty =b.entry_ty and b.amt_ty ='dr') WHERE A.entry_ty  ='J4'  
AND A.VAT_ADJ = 'Adjusted against liability under Local Act' AND A.party_nm ='CST Payable'
and ( a.date between @SDATE and @EDATE)
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'7B','L',0,0,@AMTA2,0,'')

--print 's11'

--R7.13 Net Tax [R7.10 - (R7.11 + R7.12)]
SET @AMTA1=0
SET @AMTA2=0
SET @AMTb1=0
SET @AMTb2=0
SELECT @AMTA1=SUM(AMT1),@AMTA2=SUM(AMT2) FROM #FORMCST01 WHERE PARTSR='7B' AND SRNO='J'
SELECT @AMTB1=SUM(AMT1),@AMTB2=SUM(AMT2) FROM #FORMCST01 WHERE PARTSR='7B' AND SRNO IN ('K','L')
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
--SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
SET @AMTB1=CASE WHEN @AMTB1 IS NULL THEN 0 ELSE @AMTB1 END
--SET @AMTB2=CASE WHEN @AMTB2 IS NULL THEN 0 ELSE @AMTB2 END
--INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'7','M',0,0,@AMTA2-@AMTB1,0,'')
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'7B','M',0,0,@AMTA2-@AMTB2,0,'')
--R7.14 Interest, if payable

SET @AMTA1=0
SET @AMTA2=0
SELECT @AMTA1 = ISNULL(SUM(NET_AMT),0) FROM BPMAIN A  WHERE A.ENTRY_TY IN ('BP') AND A.U_NATURE='INTEREST' AND (A.DATE BETWEEN @SDATE AND @EDATE)
AND A.party_nm ='CST PAYABLE'
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
--INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'7','N',0,0,@AMTA1,0,'')
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'7B','N',0,0,@AMTA1,0,'')
--R.7.15 Penalty, if payable

SET @AMTA1=0
SET @AMTA2=0
SELECT @AMTA1 = ISNULL(SUM(NET_AMT),0) FROM BPMAIN A  WHERE A.ENTRY_TY IN ('BP') AND A.U_NATURE='Penalty' AND (A.DATE BETWEEN @SDATE AND @EDATE)
AND A.party_nm ='CST PAYABLE'
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'7B','O',0,0,@AMTA1,0,'')
--R7.16 Balance Payable

SET @AMTA1=0
SET @AMTA2=0
SELECT @AMTB1=SUM(AMT1),@AMTB2=SUM(AMT2) FROM #FORMCST01 WHERE PARTSR='7B' AND SRNO IN ('N','M','O')
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
--INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'7','P',0,0,@AMTA1,0,'')
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'7B','P',0,0,@AMTB2,0,'')

--R7.17 Less : Amount deposited by the dealer (attach proof of payment with Form DVAT-56)

--part 7C
----Bank Payment Details
Declare @TAXONAMT as NUMERIC(20,2),@TAXAMT1 as NUMERIC(20,2),@ITEMAMT as NUMERIC(20,2),@INV_NO as varchar(10),@DATE as smalldatetime,@ADDRESS as varchar(100),@ITEM as varchar(50)
--,@FORM_NM as varchar(30)
,@S_TAX as varchar(30),@QTY as numeric(18,2),@u_chqdt as smalldatetime
SELECT @TAXONAMT=0,@TAXAMT =0,@ITEMAMT =0,@INV_NO ='',@DATE ='',@PARTY_NM ='',@ADDRESS ='',@ITEM =''
--,@FORM_NM=''
,@S_TAX ='',@QTY=0,@u_chqdt=''

SET @CHAR=65
SET @PER = 0
declare Cur_VatPay cursor  for
select Taxonamt=B.NET_AMT,A.Gro_amt,A.taxamt,INV_NO='',B.Date,Party_nm=RTRIM(B.BANK_NM)+' '+RTRIM(ac.s_tax),Address='',Form_nm=B.U_CHALNO,S_tax=B.U_CHQDT
from VATTBL A
--Inner join Bpmain B on (A.Bhent = B.Entry_ty and A.Tran_cd = B.Tran_cd)
Inner Join Bpmain B On(A.Bhent = B.Entry_Ty And A.Tran_cd = B.Tran_cd) INNER JOIN AC_MAST AC ON (AC.ac_name=B.bank_nm) 
where BHENT = 'BP' And B.Date Between @sdate and @edate And B.Party_nm ='CST PAYABLE'  and b.U_NATURE='CST'

open Cur_VatPay
FETCH NEXT FROM Cur_VatPay INTO @TAXONAMT,@ITEMAMT,@TAXAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@FORM_NM,@S_TAX
	WHILE (@@FETCH_STATUS=0)
	BEGIN
	SET @PER=CASE WHEN @PER IS NULL THEN 0 ELSE @PER END
	SET @TAXONAMT=CASE WHEN @TAXONAMT IS NULL THEN 0 ELSE @TAXONAMT END
	SET @TAXAMT=CASE WHEN @TAXAMT IS NULL THEN 0 ELSE @TAXAMT END
	SET @ITEMAMT=CASE WHEN @ITEMAMT IS NULL THEN 0 ELSE @ITEMAMT END
	SET @QTY=CASE WHEN @QTY IS NULL THEN 0 ELSE @QTY END
	SET @PARTY_NM=CASE WHEN @PARTY_NM IS NULL THEN '' ELSE @PARTY_NM END
	SET @INV_NO=CASE WHEN @INV_NO IS NULL THEN '' ELSE @INV_NO END
	SET @DATE=CASE WHEN @DATE IS NULL THEN '' ELSE @DATE END
	SET @ADDRESS=CASE WHEN @ADDRESS IS NULL THEN '' ELSE @ADDRESS END
	SET @ITEM=CASE WHEN @ITEM IS NULL THEN '' ELSE @ITEM END
	SET @S_TAX=CASE WHEN @S_TAX IS NULL THEN '' ELSE @S_TAX END
	SET @FORM_NM=CASE WHEN @FORM_NM IS NULL THEN '' ELSE @FORM_NM END

	--INSERT INTO #FORM01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'8','Z',0,@AMTJ1-@AMTK1,@AMTK1,0,'') 
	IF (@TAXONAMT+@ITEMAMT) > 0
	BEGIN
		INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX)
		 VALUES (1,'7C',CHAR(@CHAR),@PER,0,@TAXONAMT,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@FORM_NM,@S_TAX)
	END
	--INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
   --VALUES (1,'8','A',@taxonamt,@AMTK1,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@FORM_NM,@S_TAX)
   

	SET @CHAR=@CHAR+1
	FETCH NEXT FROM CUR_VatPay INTO @TAXONAMT,@TAXAMT,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@FORM_NM,@S_TAX --@ITEM,@QTY
END
CLOSE CUR_VatPay
DEALLOCATE CUR_VatPay


--SELECT * FROM #FORMCST01 WHERE PARTSR='7C' --AND SRNO IN ('N','M','O')
--	SELECT @AMTA1=SUM(AMT1) FROM #FORMCST01 WHERE PARTSR='7C' --AND SRNO IN ('N','M','O')
	INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX)
   VALUES (1,'7C','Z',0,@AMTA1,0,0,'','','','','','')
Update #FORMCST01 Set AMT2 =@AMTA1  where Partsr = '7B' and Srno = 'Q'

--R7.17 Less : Amount deposited by the dealer (attach proof of payment with Form DVAT-56)

SET @AMTA1=0
SELECT @AMTA1=SUM(AMT2) FROM #FORMCST01 WHERE PARTSR='7C '-- AND SRNO IN ('N','M','O')
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'7B','Q',0,0,@AMTA1,0,'')

--R8 Net Balance* (R7.16- R7.17)
SET @AMTA1=0
SET @AMTA2=0
SELECT @AMTA1=sum(AMT2) FROM #FORMCST01  WHERE PARTSR='7B' and SRNO IN ('P')
SELECT @AMTB1=sum(AMT2) FROM #FORMCST01  WHERE PARTSR='7B' and SRNO IN ('Q')
SET @AMTA2=@AMTA1-@AMTB1
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
SET @AMTB1=CASE WHEN @AMTB1 IS NULL THEN 0 ELSE @AMTB1 END
SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
SET @AMTC2 = 0
SET @AMTC2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'8','A',0,0,@AMTA2,0,'')
print 'r8'
print @AMTA2

--INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'8','A',0,0,CASE WHEN @AMTA2 > 0 THEN @AMTA2 ELSE 0 END,0,'')
--Update #FORMCST01 Set AMT2=CASE WHEN @AMTA2 > 0 THEN @AMTA2 ELSE 0 END  where Partsr = '8' and Srno = 'A'

--R9 Balance brought forward from line R8 (positive balance of R8)
SET @AMTA1=0
SET @AMTA2=0
SELECT @AMTA1=isnull(sum(AMT2),0) FROM #FORMCST01  WHERE PARTSR ='8' and SRNO IN ('A') and part = 1
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'9','A',0,0,CASE WHEN @AMTC2 < 0 THEN ABS(@AMTA1) ELSE 0 END ,0,'')
--R9.1 Adjusted against liability under Local Act
SET @AMTA1=0
SET @AMTA2=0
SELECT @AMTA1=isnull(SUM(b.amount),0) FROM JVMAIN A inner join JVACDET b on (a.Tran_cd =b.Tran_cd and a.entry_ty =b.entry_ty and b.amt_ty ='dr') WHERE A.entry_ty  ='J4'  
AND A.VAT_ADJ = 'Adjusted against liability under Local Act' AND A.party_nm ='CST Payable' and  ( a.date between @SDATE and @EDATE )
and ( a.date between @SDATE and @EDATE)

INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'9','B',0,0,CASE WHEN @AMTC2 < 0 THEN @AMTA1 ELSE 0 END ,0,'')	

--R9.2 Balance carried forward to next tax period
SET @AMTA1=0
SET @AMTA2=0
SELECT @AMTA1=isnull(SUM(b.amount),0) FROM JVMAIN A inner join JVACDET b on (a.Tran_cd =b.Tran_cd and a.entry_ty =b.entry_ty and b.amt_ty ='dr') WHERE A.entry_ty  ='J4'  AND A.VAT_ADJ = 'Excess credit carried forward to  subsequent tax period' AND A.party_nm ='CST Payable'
and ( a.date between @SDATE and @EDATE)
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'9','C',0,0,CASE WHEN @AMTC2 < 0 THEN @AMTA1 ELSE 0 END ,0,'')	


----R10 Year-wise details of pending forms/ declarations.
--INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'10','A',0,0,0,0,'')
---‘C’ Form (Excluding sale in transit against E1/E2)
--IF @AMTC2 < 0  
--	BEGIN
	INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,form_nm)  SELECT 1 ,'10' ,'B' ,PER
	,isnull(SUM(VATONAMT),0),isnull(SUM(TAXAMT),0),0,year(date),RFORM_NM  FROM VATTBL  WHERE BHENT ='ST'  AND ST_TYPE ='OUT OF STATE' and ((RTRIM(LTRIM(REPLACE(replace(RFORM_NM,'FORM',''),'-','')))= 'C'))
	GROUP BY per,year(date) ,RFORM_NM
	ORDER BY year(date),per
--END
--IF @AMTC2 > 0  
--	begin
--		INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,form_nm) 
--		VALUES (1,'10','B',0,0 ,0 ,0,'','')
--	end
if not exists(select srno from #FORMCST01 where PART =1 and  PARTSR ='10' and SRNO ='B')
begin
	INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,form_nm) 
	VALUES (1,'10','B',0,0,0 ,0,'','')
end
	
---for f Form
--IF @AMTC2 < 0  
--begin
	INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,form_nm)
	SELECT  1,'10','C',per,isnull(SUM(VATONAMT),0),isnull(SUM(TAXAMT),0),0,year(date),RFORM_NM FROM 
	VATTBL  WHERE BHENT ='ST'  AND ST_TYPE ='OUT OF STATE'  and ((RTRIM(LTRIM(REPLACE(replace(RFORM_NM,'FORM',''),'-','')))= 'F'))
	GROUP BY per,year(date) ,RFORM_NM
	ORDER BY year(date),per 
--end
--IF @AMTC2 > 0  
--	begin
--	INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,form_nm) 
--	VALUES (1,'10','C',0,0,0 ,0,' ','')
--	end
if not exists(select srno from #FORMCST01 where PART =1 and  PARTSR ='10' and SRNO ='C')
begin
	INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,form_nm) 
	VALUES (1,'10','C',0,0,0 ,0,'','')
end

---for I Form
--IF @AMTC2 < 0  
--begin
	INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,form_nm) 
	SELECT  1,'10','D',per,SUM(VATONAMT),SUM(TAXAMT),0,year(date),RFORM_NM FROM 
	VATTBL  WHERE BHENT ='ST'   AND ST_TYPE ='OUT OF STATE' and ((RTRIM(LTRIM(REPLACE(replace(RFORM_NM,'FORM',''),'-','')))= 'I'))
	GROUP BY per,year(date),RFORM_NM 
	ORDER BY year(date),per
--end
--IF @AMTC2 > 0  
----begin
--	INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM)
--	VALUES (1,'10','D',0,0,0,0,'')
--end
if not exists(select srno from #FORMCST01 where PART =1 and  PARTSR ='10' and SRNO ='D')
begin
	INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,form_nm) 
	VALUES (1,'10','D',0,0,0 ,0,'','')
end


	
---for C Form
--IF @AMTC2 < 0  
--begin
--	INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,form_nm) 
--		SELECT  1,'10','E',per,SUM(GRO_AMT),SUM(TAXAMT),0,year(date),RFORM_NM  FROM VATTBL  WHERE BHENT ='ST'   and ((RTRIM(LTRIM(REPLACE(replace(RFORM_NM,'FORM',''),'-','')))= 'C')  OR (RTRIM(LTRIM(REPLACE(replace(TAX_NAME,'FORM',''),'-',''))) = 'C'))
--	GROUP BY Rform_NM,per,year(date) 
--	ORDER BY Rform_NM,per,year(date) 
--end
--IF @AMTC2 > 0  
--begin
	--INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES 
	--(1,'10','E',0,0 ,0 ,0,'')	
--end
---for E1/E2 from 
--IF @AMTC2 < 0  
--begin
	INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,form_nm) 
	SELECT  1,'10','F',per,SUM(VATONAMT),SUM(TAXAMT),0,year(date),RFORM_NM FROM VATTBL  WHERE BHENT ='ST'  AND ST_TYPE ='OUT OF STATE'
	AND ((RTRIM(LTRIM(REPLACE(replace(RFORM_NM,'FORM',''),'-',''))) IN('E1','E-1','E-I')))
	GROUP BY per,year(date),RFORM_NM
	ORDER BY year(date),per
--end
--IF @AMTC2 > 0 
--begin
--	INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,form_nm) 
--	VALUES (1,'10','F',0,0,0 ,0,'','')
--end
if not exists(select srno from #FORMCST01 where PART =1 and  PARTSR ='10' and SRNO ='F')
begin
	INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,form_nm) 
	VALUES (1,'10','F',0,0,0 ,0,'','')
end

	INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,form_nm) 
	SELECT  1,'10','G',per,SUM(VATONAMT),SUM(TAXAMT),0,year(date),RFORM_NM FROM VATTBL  WHERE BHENT ='ST'  AND ST_TYPE ='OUT OF STATE'
	AND ((RTRIM(LTRIM(REPLACE(replace(RFORM_NM,'FORM',''),'-',''))) IN('E2','E-2','E-II')))
	GROUP BY per,year(date),RFORM_NM
	ORDER BY year(date),per
	
if not exists(select srno from #FORMCST01 where PART =1 and  PARTSR ='10' and SRNO ='G')
begin
	INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,form_nm) 
	VALUES (1,'10','G',0,0,0 ,0,'','')
end
	



/*
SELECT  @AMTA1=(net_amt),@inv_no=u_PINVNO,@date=u_pinvdt,@PARTY_NM=item,@form_nm=form_nm,@S_TAX=formidt FROM (select DISTINCT m.net_amt,i.item,m.u_pinvno,m.u_pinvdt,m.form_nm,m.formidt FROM VATTBL a inner join #lcode lc on (a.bhent=lc.entry_ty)
inner join PTMAIN m on (m.entry_ty=lc.entry_ty and m.tran_cd=A.tran_cd)inner join PTITEM I on (i.entry_ty=lc.entry_ty and i.tran_cd=A.tran_cd)
WHERE lc.bcode in ('PT') AND (a.DATE BETWEEN @SDATE AND @EDATE) AND a.st_type='OUT OF STATE') b-- group by item,u_pinvno,u_pinvdt,form_nm,formidt --and m.form_nm =' ') b
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,inv_no,PARTY_NM,date,address,form_nm,s_tax)  VALUES (1,'11','A',0,@AMTA1,0,0,0,@INV_NO,@DATE,@PARTY_NM,@FORM_NM,@S_TAX)
*/
SELECT @TAXONAMT=0,@TAXAMT =0,@ITEMAMT =0,@INV_NO ='',@DATE ='',@PARTY_NM ='',@ADDRESS ='',@ITEM ='',@FORM_NM='',@S_TAX ='',@QTY=0,@u_chqdt=''
--IF @AMTC2 < 0 
--BEGIN

	SET @CHAR=65
	SET @PER = 0
	declare Cur_VatPay cursor  for
	SELECT  Taxonamt=(GRO_AMT),inv_no=u_PINVNO,date=u_pinvdt,PARTY_NM=item,form_nm=form_nm,S_TAX=formidt FROM (select DISTINCT i.gro_amt,i.item,m.u_pinvno,m.u_pinvdt,m.form_nm,m.formidt FROM VATTBL a inner join #lcode lc on (a.bhent=lc.entry_ty)
	inner join PTMAIN m on (m.entry_ty=lc.entry_ty and m.tran_cd=A.tran_cd)inner join PTITEM I on (i.entry_ty=lc.entry_ty and i.tran_cd=A.tran_cd)
	WHERE lc.bcode in ('PT') AND (a.DATE BETWEEN @SDATE AND @EDATE) AND a.st_type='OUT OF STATE' and a.FORM_NM <> '') b
	open Cur_VatPay
	FETCH NEXT FROM Cur_VatPay INTO @TAXONAMT,@INV_NO,@DATE,@PARTY_NM,@FORM_NM,@S_TAX
		WHILE (@@FETCH_STATUS=0)
		BEGIN

		SET @TAXONAMT=CASE WHEN @TAXONAMT IS NULL THEN 0 ELSE @TAXONAMT END
		SET @PARTY_NM=CASE WHEN @PARTY_NM IS NULL THEN '' ELSE @PARTY_NM END
		SET @INV_NO=CASE WHEN @INV_NO IS NULL THEN '' ELSE @INV_NO END
		SET @DATE=CASE WHEN @DATE IS NULL THEN '' ELSE @DATE END
		SET @ITEM=CASE WHEN @ITEM IS NULL THEN '' ELSE @ITEM END
		SET @S_TAX=CASE WHEN @S_TAX IS NULL THEN '' ELSE @S_TAX END
		SET @FORM_NM=CASE WHEN @FORM_NM IS NULL THEN '' ELSE @FORM_NM END
		if (@TAXONAMT + @ITEMAMT) > 0
		begin
		INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,FORM_NM,S_TAX)
		VALUES (1,'11','A',@PER,0,@TAXONAMT,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@FORM_NM,@S_TAX)
	    end
		FETCH NEXT FROM CUR_VatPay INTO @TAXONAMT,@INV_NO,@DATE,@PARTY_NM,@FORM_NM,@S_TAX --@ITEM,@QTY
	END
	CLOSE CUR_VatPay
	DEALLOCATE CUR_VatPay
--END

--if not exists(select top 1 srno  from #FORMCST01 where  PART = 1 and PARTSR='11')
--begin
--	INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,FORM_NM,S_TAX)
--	VALUES (1,'11','A',0,0,@TAXONAMT,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@FORM_NM,cast(@S_TAX as DATE))
--end 

INSERT INTO #FORMCST01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'12','A',0,0,0,0,'')

Update #FORMCST01 set  PART = isnull(Part,'') , Partsr = isnull(PARTSR,''), SRNO = isnull(SRNO,''),
RATE = isnull(RATE,0), AMT1 = isnull(AMT1,0), AMT2 = isnull(AMT2,0), AMT3 = isnull(AMT3,0),
INV_NO = isnull(INV_NO,''), DATE = isnull(Date,''),PARTY_NM = isnull(Party_nm,''), ADDRESS = isnull(Address,''),
FORM_NM = isnull(form_nm,''), S_TAX = isnull(S_tax,'')--, Qty = isnull(Qty,0),  ITEM =isnull(item,''),

SELECT * FROM #FORMCST01 order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int), partsr,SRNO

end

---set ANSI_NULLS OFF

