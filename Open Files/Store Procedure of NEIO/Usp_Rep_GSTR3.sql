DROP PROCEDURE [Usp_Rep_GSTR3]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Author : Suraj Kumawat 
--Date created : 16-08-2017
Modify By :  
Modify Date : 
set dateformat dmy EXECUTE Usp_Rep_GSTR3 '','','','01/08/2017 ','30/08/2017','','','','',0,0,'','','','','','','','','2017-2018',''
set dateformat dmy EXECUTE Usp_Rep_GSTR3 '','','','01/09/2017 ','30/09/2017','','','','',0,0,'','','','','','','','','2017-2018',''



*/

Create Procedure [Usp_Rep_GSTR3]
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
As
BEGIN
Declare @FCON as NVARCHAR(2000),@fld_list NVARCHAR(2000)
EXECUTE   USP_REP_FILTCON 
	@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
	,@VSDATE=@SDATE,@VEDATE=@EDATE
	,@VSAC =@SAC,@VEAC =@EAC
	,@VSIT=@SIT,@VEIT=@EIT
	,@VSAMT=@SAMT,@VEAMT=@EAMT
	,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
	,@VSCATE =@SCATE,@VECATE =@ECATE
	,@VSWARE =@SWARE,@VEWARE  =@EWARE
	,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
	,@VMAINFILE='M',@VITFILE=Null,@VACFILE='i'
	,@VDTFLD ='DATE'
	,@VLYN=Null
	,@VEXPARA=@EXPARA
	,@VFCON =@FCON OUTPUT

-------Temporary Table Creation ----
SELECT  PART=0
,PARTSR=D.RATE-- as decimal(4,2))
--,PARTSR=space(10)
,SECTION=CAST(0 AS Int) ,D.RATE,srno ='A',SR_NO=SPACE(15),descr=SPACE(200),D.gro_amt  AS NET_AMT,D.gro_amt AS TAXABLEAMT,D.CGST_AMT,D.SGST_AMT,D.IGST_AMT ,D.IGST_AMT AS CESS_AMT
,D.IGST_AMT AS TAX_PAID,D.IGST_AMT AS CESS_PAID,D.IGST_AMT AS INTEREST,D.IGST_AMT AS LATE_FEE,Ecom_gstin =space(25),add_type=SPACE(50) 
,D.IGST_AMT  as itc_igst_amt,D.IGST_AMT  as itc_cgst_amt ,D.IGST_AMT  as itc_sgst_amt ,D.IGST_AMT  as itc_cess_amt 
,rptmonth=SPACE(15),rptyear =SPACE(15)
into #GSTR3 FROM  PTMAIN H INNER JOIN
PTITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) WHERE 1=2
---Temprory Table 
SELECT * INTO #GSTR3TBL FROM GSTR3_VW WHERE DATE BETWEEN @SDATE AND @EDATE
SELECT * INTO #GSTR3TBLAMD FROM GSTR3_VW WHERE AmendDate BETWEEN @SDATE AND @EDATE
UPDATE #GSTR3TBL SET SUPP_TYPE = ''  WHERE ST_TYPE = 'OUT OF COUNTRY'
UPDATE #GSTR3TBLAMD SET SUPP_TYPE = ''  WHERE ST_TYPE = 'OUT OF COUNTRY'

-----Variable Declaration 
declare @amt1 decimal(18,2),@amt2 decimal(18,2),@amt3 decimal(18,2),@amt4 decimal(18,2)	,@amt5 decimal(18,2),@amt6 decimal(18,2),@amt7 decimal(18,2),@Taxtype varchar(50)	
/* 3*/
---Taxable[other than zero rated]

set @amt1 = 0.00
select @amt1= SUM(CASE WHEN ENTRY_TY IN('ST','S1','D6','GD','BR','CR') THEN +(isnull(Taxableamt,0)) ELSE -(isnull(Taxableamt,0)) END -ADJ_TAXABLE)  
from #GSTR3TBL where TranType = 'Outward' and Entry_ty in('ST','S1','C6','D6','GC','GD','SR','BR','CR','RV')
and LineRule not in('Exempted','Nill Rated','Non-GST') and hsncode <> '' AND st_type IN('INTRASTATE','INTERSTATE') AND SUPP_TYPE not IN('SEZ','EXPORT','EOU','Import','')
AND (isnull(IGST_AMT,0) + isnull(CGST_AMT,0) + isnull(SGST_AMT,0) ) > 0
Insert Into #GSTR3(PART,PARTSR,Section,srno,SR_NO,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
			VALUES(3,3,1,'A','(i)','Taxable[other than zero rated]',@amt1,0,0,0,0 ,0,0,0,0,0)
			
---Zero rated supply on payment of Tax
set @amt1 = 0.00
select @amt1= SUM(CASE WHEN ENTRY_TY IN('ST','S1','D6','GD','BR','CR') THEN +(isnull(TAXABLEAMT,0)) ELSE -(isnull(TAXABLEAMT,0)) END -ADJ_TAXABLE )  from #GSTR3TBL where TranType = 'Outward' and Entry_ty in('ST','S1','C6','D6','GC','GD','SR','BR','CR','RV')
and LineRule not in('Exempted','Nill Rated','Non-GST') and hsncode <> ''
and st_type ='OUT OF COUNTRY'
AND (isnull(IGST_AMT,0) + isnull(CGST_AMT,0) + isnull(SGST_AMT,0) ) > 0
Insert Into #GSTR3(PART,PARTSR,Section,srno,SR_NO,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
			VALUES(3,3,1,'B','(ii)','Zero rated supply on payment of Tax',isnull(@amt1,0),0,0,0,0 ,0,0,0,0,0)
---Zero rated supply without payment of Tax
set @amt1 = 0.00
select @amt1= SUM(CASE WHEN ENTRY_TY IN('ST','S1','D6','GD','BR','CR') THEN +(isnull(taxableamt,0)) ELSE -(isnull(taxableamt,0)) END -ADJ_TAXABLE )  from #GSTR3TBL where TranType = 'Outward' and Entry_ty in('ST','S1','C6','D6','GC','GD','SR','BR','CR','RV')
and LineRule not in('Exempted','Nill Rated','Non-GST') and hsncode <> '' 
and st_type ='OUT OF COUNTRY'
AND (isnull(IGST_AMT,0) + isnull(CGST_AMT,0) + isnull(SGST_AMT,0) ) = 0

Insert Into #GSTR3(PART,PARTSR,Section,srno,SR_NO,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
			VALUES(3,3,1,'C','(iii)','Zero rated supply without payment of Tax',isnull(@amt1,0),0,0,0,0 ,0,0,0,0,0)
---Deemed Exports
set @amt1 = 0.00
select @amt1= SUM(CASE WHEN ENTRY_TY IN('ST','S1','D6','GD','BR','CR') THEN +(isnull(taxableamt,0)) ELSE -(isnull(taxableamt,0)) END -ADJ_TAXABLE )  from #GSTR3TBL where TranType = 'Outward' and Entry_ty in('ST','S1','C6','D6','GC','GD','SR','BR','CR','RV')
and LineRule not in('Exempted','Nill Rated','Non-GST') and hsncode <> '' 
and st_type IN('INTERSTATE','INTRASTATE') and SUPP_TYPE IN('Export','SEZ','IMPORT','EOU')

Insert Into #GSTR3(PART,PARTSR,Section,srno,SR_NO,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
			VALUES(3,3,1,'D','(iv)','Deemed Exports',isnull(@amt1,0),0,0,0,0,0,0,0,0,0)
----Exempted
set @amt1 = 0.00
select @amt1= SUM(CASE WHEN ENTRY_TY IN('ST','S1','D6','GD','BR','CR') THEN +(isnull(TAXABLEAMT,0)) ELSE -(isnull(TAXABLEAMT,0)) END -ADJ_TAXABLE )  from #GSTR3TBL where TranType = 'Outward' and Entry_ty in('ST','S1','C6','D6','GC','GD','SR','BR','CR','RV')
and LineRule ='Exempted' and hsncode <> ''
and st_type IN('INTERSTATE','INTRASTATE') 
Insert Into #GSTR3(PART,PARTSR,Section,srno,SR_NO,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
			VALUES(3,3,1,'E','(v)','Exempted',isnull(@amt1,0),0,0,0,0 ,0,0,0,0,0)
---Nil Rated
set @amt1 = 0.00
select @amt1= SUM(CASE WHEN ENTRY_TY IN('ST','S1','D6','GD','BR','CR') THEN +(isnull(TAXABLEAMT,0)) ELSE -(isnull(TAXABLEAMT,0)) END -ADJ_TAXABLE )  from #GSTR3TBL where TranType = 'Outward' and Entry_ty in('ST','S1','C6','D6','GC','GD','SR','BR','CR','RV')
and LineRule ='Nill Rated' and hsncode <> '' 
and st_type IN('INTERSTATE','INTRASTATE') 
Insert Into #GSTR3(PART,PARTSR,Section,srno,SR_NO,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
			VALUES(3,3,1,'F','(vi)','Nil Rated',isnull(@amt1,0),0,0,0,0 ,0,0,0,0,0)
---Non GST supply
set @amt1 = 0.00
select @amt1= SUM(CASE WHEN ENTRY_TY IN('ST','S1','D6','GD','BR','CR') THEN +(isnull(TAXABLEAMT,0)) ELSE -(isnull(TAXABLEAMT,0)) END -ADJ_TAXABLE )  from #GSTR3TBL where TranType = 'Outward' and Entry_ty in('ST','S1','C6','D6','GC','GD','SR','BR','CR','RV')
and hsncode = '' and st_type IN('INTERSTATE','INTRASTATE') and LineRule not in('Nill Rated')
Insert Into #GSTR3(PART,PARTSR,Section,srno,SR_NO,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
			VALUES(3,3,1,'G','(vii)','Non GST supply',isnull(@amt1,0),0,0,0,0 ,0,0,0,0,0)
---Total
set @amt1 = 0.00
select @amt1 =sum(isnull(net_amt,0)) from #GSTR3 where PART = 3
Insert Into #GSTR3(PART,PARTSR,Section,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
			VALUES(3,3,1,'H','Total',isnull(@amt1,0),0,0,0,0 ,0,0,0,0,0)

   
/*4 Outward Supplies*/
	---4.1 Inter - State Supplies(Net supply for the month)
	--A.Taxable supplies(other than reverse charge and zero rated supply)[Tax Rate Wise]
	INSERT INTO #GSTR3(PART,PARTSR,Section,srno,RATE,TAXABLEAMT,IGST_AMT,CESS_AMT)
	Select * from (  --Added by Priyanka B on 12102017
	SELECT 4 AS PART,4.1 AS PARTSR,1 AS SECTION,'A' AS SRNO,RATE1
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then + isnull(Taxableamt,0)  else - isnull(Taxableamt,0)  end)-ADJ_TAXABLE) as TAXABLEAMT
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then + isnull(IGST_AMT,0) else - isnull(IGST_AMT,0) end)-ADJ_IGST_AMT) as IGST_AMT
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then + isnull(cess_amt,0)  else -isnull(cess_amt,0) end)-ADJ_CESS_AMT) as CESS_AMT  FROM #GSTR3TBL 
	WHERE ENTRY_TY IN('ST','S1','SR','C6','D6','GC','GD','BR','CR','RV') AND Trantype = 'OUTWARD'
	AND ST_TYPE ='INTERSTATE' AND SUPP_TYPE NOT IN('SEZ','EOU','EXPORT','IMPORT')  and HSNCODE <> ''
    AND (isnull(IGST_AMT,0))> 0 GROUP BY RATE1 
    )aa where (isnull(IGST_AMT,0))> 0  --Added by Priyanka B on 12102017
    ORDER BY RATE1
	IF NOT EXISTS(SELECT PART,PARTSR FROM #GSTR3 WHERE PART= 4  AND PARTSR = 4.1 AND SECTION=1 AND srno = 'A')
	BEGIN
		Insert Into #GSTR3(PART,PARTSR,SECTION,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4.1,1,'A','',0,0,0,0,0 ,0,0,0,0,0)
	END
	
	--B.Supply attracting reverse change-Tax Payable b receipient of supply
	INSERT INTO #GSTR3(PART,PARTSR,Section,srno,RATE,TAXABLEAMT,IGST_AMT,CESS_AMT)
	Select * from (  --Added by Priyanka B on 12102017
	SELECT 4 AS PART,4.1 AS PARTSR,2 AS SECTION,'B' AS SRNO,rate1
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then +isnull(Taxableamt,0)  else -isnull(Taxableamt,0)  end)-ADJ_TAXABLE) as TAXABLEAMT
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then + isnull(IGST_AMT,0) else -isnull(IGST_AMT,0) end)-ADJ_IGST_AMT) as IGST_AMT
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then + isnull(cess_amt,0)  else -isnull(cess_amt,0) end)-ADJ_CESS_AMT) as CESS_AMT  FROM #GSTR3TBL
	WHERE ENTRY_TY IN('ST','S1','SR','C6','D6','GC','GD','BR','CR','RV')  AND Trantype = 'OUTWARD' AND AGAINSTGS NOT IN('PURCHASES','SERVICE PURCHASE BILL') AND ST_TYPE ='INTERSTATE' AND SUPP_TYPE NOT IN('SEZ','EOU','EXPORT','IMPORT') AND buyer_SUPP_TYPE <> 'E-COMMERCE' 
	AND (isnull(IGSRT_AMT,0))> 0 
	and ISNULL(HSNCODE,'') <> '' GROUP BY RATE1 
	)aa where (isnull(IGST_AMT,0))>0  --Added by Priyanka B on 12102017
	ORDER BY RATE1
	IF NOT EXISTS(SELECT PART,PARTSR FROM #GSTR3 WHERE PART= 4  AND PARTSR = 4.1 AND SECTION=2 AND srno = 'B')
	BEGIN
		Insert Into #GSTR3(PART,PARTSR,SECTION,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4.1,2,'B','',0,0,0,0,0 ,0,0,0,0,0)
	end
	--C.Zero rated supply made with payment of Integrated Tax
	INSERT INTO #GSTR3(PART,PARTSR,Section,srno,RATE,TAXABLEAMT,IGST_AMT,CESS_AMT)
	Select * from ( --Added by Priyanka B on 12102017
	SELECT 4 AS PART,4.1 AS PARTSR,3 as SECTION,'C' AS SRNO,RATE1
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then + ISNULL(Taxableamt,0)  else -ISNULL(Taxableamt,0)  end)-ADJ_TAXABLE) as TAXABLEAMT
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then +ISNULL(IGST_AMT,0) else -ISNULL(IGST_AMT,0) end)-ADJ_IGST_AMT) as IGST_AMT
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then + ISNULL(cess_amt,0)  else -ISNULL(cess_amt,0) end)-ADJ_CESS_AMT) as CESS_AMT  FROM #GSTR3TBL
	 WHERE ENTRY_TY IN('ST','S1','SR','C6','D6','GC','GD','BR','CR','RV')  AND Trantype = 'OUTWARD' AND (ST_TYPE ='OUT OF COUNTRY' or (ST_TYPE in('INTERSTATE','INTRASTATE') AND SUPP_TYPE  IN('SEZ','EOU','EXPORT','IMPORT'))) AND buyer_SUPP_TYPE <> 'E-COMMERCE'   and HSNCODE <> ''
    AND(isnull(IGST_AMT,0))> 0 GROUP BY RATE1 
    )aa where (isnull(IGST_AMT,0))>0  --Added by Priyanka B on 12102017
    ORDER BY RATE1
    
    IF NOT EXISTS(SELECT PART,PARTSR FROM #GSTR3 WHERE PART= 4  AND PARTSR = 4.1 AND SECTION=3 AND srno = 'C')
	BEGIN
		Insert Into #GSTR3(PART,PARTSR,Section,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4.1,3,'C','',0,0,0,0,0 ,0,0,0,0,0)
	END
	--D.Out of supplies mentioned at A,the value of supplies made though an e-commerce operator attracting	TCS [Rate Wise]
	  ---GSTIN of E-commerce opertator
	INSERT INTO #GSTR3(PART,PARTSR,Section,srno,RATE,TAXABLEAMT,IGST_AMT,CESS_AMT,Ecom_gstin)
	Select * from (  --Added by Priyanka B on 12102017
	SELECT 4 AS PART,4.1 AS PARTSR,4 as SECTION,'D' AS SRNO,RATE1
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then +ISNULL(Taxableamt,0)  else -ISNULL(Taxableamt,0)  end)-ADJ_TAXABLE) as TAXABLEAMT
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then +ISNULL(IGST_AMT,0) else -ISNULL(IGST_AMT,0) end)-ADJ_IGST_AMT) as IGST_AMT
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then +ISNULL(cess_amt,0)  else -ISNULL(cess_amt,0) end)-ADJ_CESS_AMT) as CESS_AMT ,buyer_gstin 
	FROM #GSTR3TBL  WHERE ENTRY_TY IN('ST','S1','SR','C6','D6','GC','GD','BR','CR','RV') AND Trantype = 'OUTWARD' AND ST_TYPE ='INTERSTATE' AND SUPP_TYPE NOT IN('SEZ','EOU','EXPORT','IMPORT')  AND buyer_SUPP_TYPE = 'E-COMMERCE'
    AND (ISNULL(IGST_AMT,0))> 0 GROUP BY buyer_gstin,RATE1 
    )aa where (ISNULL(IGST_AMT,0))> 0   --Added by Priyanka B on 12102017
    ORDER BY buyer_gstin,RATE1
    IF NOT EXISTS(SELECT PART,PARTSR FROM #GSTR3 WHERE PART= 4  AND PARTSR = 4.1 AND SECTION=4 AND srno = 'D')
	BEGIN
		Insert Into #GSTR3(PART,PARTSR,Section,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4.1,4,'D','',0,0,0,0,0 ,0,0,0,0,0)
	END
	
	---4.2 Intra - State Supplies(Net supply for the month)
	--A.Taxable supplies(other than reverse charge)[Tax Rate Wise]
	INSERT INTO #GSTR3(PART,PARTSR,Section,srno,RATE,TAXABLEAMT,CGST_AMT,SGST_AMT,CESS_AMT)
	Select * from (  --Added by Priyanka B on 12102017
	SELECT 4 AS PART,4.2 AS PARTSR,1 as SECTION,'A' AS SRNO,RATE1
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then + ISNULL(Taxableamt,0)  else -ISNULL(Taxableamt,0)  end)-ADJ_TAXABLE) as TAXABLEAMT
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then + ISNULL(CGST_AMT,0) else -ISNULL(CGST_AMT,0) end)-ADJ_CGST_AMT) as CGST_AMT
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then + ISNULL(SGST_AMT,0) else -ISNULL(SGST_AMT,0) end)-ADJ_SGST_AMT) as SGST_AMT
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then + ISNULL(cess_amt,0)  else -ISNULL(cess_amt,0) end)-ADJ_CESS_AMT) as CESS_AMT
	FROM #GSTR3TBL  WHERE ENTRY_TY IN('ST','S1','SR','C6','D6','GC','GD','BR','CR','RV') AND Trantype = 'OUTWARD' AND ST_TYPE ='INTRASTATE' 
    AND (ISNULL(CGST_AMT,0) +ISNULL(SGST_AMT,0) )> 0 GROUP BY RATE1 
    )aa where (ISNULL(CGST_AMT,0) +ISNULL(SGST_AMT,0) )> 0   --Added by Priyanka B on 12102017
    ORDER BY RATE1
    IF NOT EXISTS(SELECT PART,PARTSR FROM #GSTR3 WHERE PART= 4  AND PARTSR = 4.2 AND SECTION=1 AND srno = 'A')
	BEGIN
		Insert Into #GSTR3(PART,PARTSR,Section,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4.2,1,'A','',0,0,0,0,0 ,0,0,0,0,0)
	END
	
	--B.Supplies attracting reverse charge- Tax payable by the receipient of supply
	INSERT INTO #GSTR3(PART,PARTSR,Section,srno,RATE,TAXABLEAMT,CGST_AMT,SGST_AMT,CESS_AMT)
	Select * from (  --Added by Priyanka B on 12102017
	SELECT 4 AS PART,4.2 AS PARTSR,2 as SECTION,'B' AS SRNO,RATE1
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then + ISNULL(Taxableamt,0)  else - ISNULL(Taxableamt,0)  end)-ADJ_TAXABLE) as TAXABLEAMT
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then + ISNULL(CGST_AMT,0) else -ISNULL(CGST_AMT,0) end)-ADJ_CGST_AMT) as CGST_AMT
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then + ISNULL(SGST_AMT,0) else -ISNULL(SGST_AMT,0) end)-ADJ_SGST_AMT) as SGST_AMT
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then + ISNULL(cess_amt,0)  else -ISNULL(cess_amt,0) end)-ADJ_CESS_AMT) as CESS_AMT
	FROM #GSTR3TBL  WHERE ENTRY_TY IN('ST','S1','SR','C6','D6','GC','GD','BR','CR','RV') AND Trantype = 'OUTWARD' AND ST_TYPE ='INTRASTATE' AND buyer_SUPP_TYPE <> 'E-COMMERCE'
    AND (ISNULL(CGSRT_AMT,0) +ISNULL(SGSRT_AMT,0))> 0 
    GROUP BY RATE1 
    )aa where (ISNULL(CGST_AMT,0) +ISNULL(SGST_AMT,0))> 0  --Added by Priyanka B on 12102017
    ORDER BY RATE1
    IF NOT EXISTS(SELECT PART,PARTSR FROM #GSTR3 WHERE PART= 4  AND PARTSR = 4.2 AND SECTION=2 AND srno = 'B')
	BEGIN
		Insert Into #GSTR3(PART,PARTSR,Section,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4.2,2,'B','',0,0,0,0,0 ,0,0,0,0,0)
	END
	--C.Out of the supplies mentioned at A,the value of supplies made though an e-commerce operator attracting TCS [Rate Wise]
	INSERT INTO #GSTR3(PART,PARTSR,Section,srno,RATE,TAXABLEAMT,CGST_AMT,SGST_AMT,CESS_AMT,Ecom_gstin)
	Select * from (  --Added by Priyanka B on 12102017
	SELECT 4 AS PART,4.2 AS PARTSR,3 as SECTION,'C' AS SRNO,RATE1
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then + ISNULL(Taxableamt,0)  else -ISNULL(Taxableamt,0)  end)-ADJ_TAXABLE) as TAXABLEAMT
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then + ISNULL(CGST_AMT,0) else -ISNULL(CGST_AMT,0) end)-ADJ_CGST_AMT) as CGST_AMT
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then + ISNULL(SGST_AMT,0) else -ISNULL(SGST_AMT,0) end)-ADJ_SGST_AMT) as SGST_AMT
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then + ISNULL(cess_amt,0)  else -ISNULL(cess_amt,0) end)-ADJ_CESS_AMT) as CESS_AMT,buyer_gstin
	FROM #GSTR3TBL  WHERE ENTRY_TY IN('ST','S1','SR','C6','D6','GC','GD','BR','CR','RV') AND Trantype = 'OUTWARD' AND ST_TYPE ='INTRASTATE' AND buyer_SUPP_TYPE = 'E-COMMERCE'
    AND (ISNULL(CGST_AMT,0) + ISNULL(SGST_AMT,0))> 0 GROUP BY buyer_gstin,RATE1 
    )aa where (ISNULL(CGST_AMT,0) + ISNULL(SGST_AMT,0))> 0  --Added by Priyanka B on 12102017
    ORDER BY buyer_gstin,RATE1
    IF NOT EXISTS(SELECT PART,PARTSR FROM #GSTR3 WHERE PART= 4  AND PARTSR = 4.2 AND SECTION=3 AND srno = 'C')
	BEGIN
		Insert Into #GSTR3(PART,PARTSR,Section,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4.2,3,'C','',0,0,0,0,0 ,0,0,0,0,0)
	END
	
	/* 4.3 Tax effect of amendments made in respect of outward supplies */
	---A.Taxable supplies (other than reverse charge and Zero rated supply made with payment of Integrated Tax)[Rate wise]
	INSERT INTO #GSTR3(PART,PARTSR,SECTION,srno,RATE,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT)
	SELECT 4 AS PART,4.31 AS PARTSR,1 AS SECTION,'A' AS SRNO,rate1
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then + ISNULL(Taxableamt,0)  else - ISNULL(Taxableamt,0)  end)-ADJ_TAXABLE) as TAXABLEAMT
	,0 as CGST_AMT
	,0 as SGST_AMT
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then + ISNULL(IGST_AMT,0) else -ISNULL(IGST_AMT,0) end)-ADJ_IGST_AMT) as IGST_AMT
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then + ISNULL(cess_amt,0)  else -ISNULL(cess_amt,0) end)-ADJ_CESS_AMT) as CESS_AMT  FROM #GSTR3TBLAMD
	WHERE ENTRY_TY IN('ST','S1','SR','C6','D6','GC','GD','BR','CR','RV') AND Trantype = 'OUTWARD'
	AND ST_TYPE ='INTERSTATE' AND SUPP_TYPE NOT IN('SEZ','EOU','EXPORT','IMPORT')  and HSNCODE <> ''
    AND (ISNULL(IGST_AMT,0))> 0 GROUP BY rate1 ORDER BY rate1
    IF NOT EXISTS(SELECT PART,PARTSR FROM #GSTR3 WHERE PART= 4  AND PARTSR = 4.31 AND  SECTION=1 AND srno = 'A')
	BEGIN
		Insert Into #GSTR3(PART,PARTSR,SECTION,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4.31,1,'A','',0,0,0,0,0 ,0,0,0,0,0)
	END
	---B.Zero rated supply made with payment of Integrated Tax)[Rate wise]
	INSERT INTO #GSTR3(PART,PARTSR,SECTION,srno,RATE,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT)
	SELECT 4 AS PART,4.31 AS PARTSR,2 AS SECTION,'B' AS SRNO,rate1
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then + ISNULL(Taxableamt,0)  else -ISNULL(Taxableamt,0)  end)-ADJ_TAXABLE) as TAXABLEAMT
	,0 as CGST_AMT
	,0 as SGST_AMT
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then +ISNULL(IGST_AMT,0) else -ISNULL(IGST_AMT,0) end)-ADJ_IGST_AMT) as IGST_AMT
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then +ISNULL(cess_amt,0)  else -ISNULL(cess_amt,0) end)-ADJ_CESS_AMT) as CESS_AMT  FROM #GSTR3TBLAMD
	WHERE ENTRY_TY IN('ST','S1','SR','C6','D6','GC','GD','BR','CR','RV') AND Trantype = 'OUTWARD' AND (ST_TYPE ='OUT OF COUNTRY' or (ST_TYPE in('INTERSTATE','INTRASTATE') AND SUPP_TYPE  IN('SEZ','EOU','EXPORT','IMPORT'))) AND buyer_SUPP_TYPE <> 'E-COMMERCE'   and HSNCODE <> ''
    AND (ISNULL(IGST_AMT,0))> 0 GROUP BY rate1 ORDER BY rate1
    IF NOT EXISTS(SELECT PART,PARTSR FROM #GSTR3 WHERE PART= 4  AND PARTSR = 4.31 AND  SECTION=2 AND srno = 'B')
	BEGIN
		Insert Into #GSTR3(PART,PARTSR,SECTION,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4.31,2,'B','',0,0,0,0,0 ,0,0,0,0,0)
	END
	---C.Out of supplies mentioned at A,the value of supplies made though  an e-commerce operator attracting TCS
	INSERT INTO #GSTR3(PART,PARTSR,SECTION,srno,RATE,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,Ecom_gstin)
	SELECT 4 AS PART,4.31 AS PARTSR,3 AS SECTION,'C' AS SRNO,RATE1
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then + ISNULL(Taxableamt,0)  else - ISNULL(Taxableamt,0)  end)-ADJ_TAXABLE) as TAXABLEAMT
	,0 as CGST_AMT
	,0 as SGST_AMT
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then + ISNULL(IGST_AMT,0) else -ISNULL(IGST_AMT,0) end)-ADJ_IGST_AMT) as IGST_AMT
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then + ISNULL(cess_amt,0)  else -ISNULL(cess_amt,0) end)-ADJ_CESS_AMT) as CESS_AMT ,buyer_gstin 
	FROM #GSTR3TBLAMD  WHERE ENTRY_TY IN('ST','S1','SR','C6','D6','GC','GD','BR','CR','RV') AND Trantype = 'OUTWARD' AND ST_TYPE ='INTERSTATE' AND SUPP_TYPE NOT IN('SEZ','EOU','EXPORT','IMPORT')  AND buyer_SUPP_TYPE = 'E-COMMERCE'
    AND (ISNULL(IGST_AMT,0))> 0 GROUP BY buyer_gstin,RATE1 ORDER BY buyer_gstin,RATE1
    IF NOT EXISTS(SELECT PART,PARTSR FROM #GSTR3 WHERE PART= 4  AND PARTSR = 4.31 AND  SECTION=3 AND srno = 'C')
	BEGIN
		Insert Into #GSTR3(PART,PARTSR,SECTION,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4.31,3,'C','',0,0,0,0,0 ,0,0,0,0,0)
	END
	---(Intra State supplies)
	--A.Taxable supplies (other then revierse charge)[Rate wise]
	INSERT INTO #GSTR3(PART,PARTSR,SECTION,srno,RATE,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT)
	SELECT 4 AS PART,4.32 AS PARTSR,1 AS SECTION,'A' AS SRNO,RATE1
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then +ISNULL(Taxableamt,0)  else -ISNULL(Taxableamt,0)  end)-ADJ_TAXABLE) as TAXABLEAMT
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then + ISNULL(CGST_AMT,0) else -ISNULL(CGST_AMT,0) end)-ADJ_CGST_AMT) as CGST_AMT
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then + ISNULL(SGST_AMT,0) else - ISNULL(SGST_AMT,0) end)-ADJ_SGST_AMT) as SGST_AMT
	,0 as IGST_AMT   
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then + ISNULL(cess_amt,0)  else - ISNULL(cess_amt,0) end)-ADJ_CESS_AMT) as CESS_AMT
	FROM #GSTR3TBLAMD  WHERE ENTRY_TY IN('ST','S1','SR','C6','D6','GC','GD','BR','CR','RV')
	AND Trantype = 'OUTWARD'  AND ST_TYPE ='INTRASTATE' AND buyer_SUPP_TYPE <> 'E-COMMERCE'
    AND (ISNULL(CGST_AMT,0) + ISNULL(SGST_AMT,0))> 0 GROUP BY RATE1 ORDER BY RATE1
	IF NOT EXISTS(SELECT PART,PARTSR FROM #GSTR3 WHERE PART= 4  AND PARTSR = 4.32 AND  SECTION=1 AND srno = 'A')
	BEGIN
		Insert Into #GSTR3(PART,PARTSR,SECTION,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4.32,1,'A','',0,0,0,0,0 ,0,0,0,0,0)
	END
	--B.Out of the supplies mentioned at a,the value of supplies made though an e-commerce operator attracting TCS
	INSERT INTO #GSTR3(PART,PARTSR,SECTION,srno,RATE,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,Ecom_gstin)
	SELECT 4 AS PART,4.32 AS PARTSR,2 AS SECTION,'B' AS SRNO,RATE1
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then + ISNULL(Taxableamt,0)  else -ISNULL(Taxableamt,0) end)-ADJ_TAXABLE) as TAXABLEAMT
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then + ISNULL(CGST_AMT,0) else -ISNULL(CGST_AMT,0) end)-ADJ_CGST_AMT) as CGST_AMT
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then + ISNULL(SGST_AMT,0) else - ISNULL(SGST_AMT,0) end)-ADJ_SGST_AMT) as SGST_AMT
	,0 as IGST_AMT
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then + ISNULL(cess_amt,0)  else - ISNULL(cess_amt,0) end)-ADJ_CESS_AMT) as CESS_AMT,buyer_gstin
	FROM #GSTR3TBLAMD  WHERE ENTRY_TY IN('ST','S1','SR','C6','D6','GC','GD','BR','CR','RV') 
	AND Trantype = 'OUTWARD'  AND ST_TYPE ='INTRASTATE' AND buyer_SUPP_TYPE = 'E-COMMERCE'
    AND (ISNULL(CGST_AMT,0) + ISNULL(SGST_AMT,0))> 0 GROUP BY buyer_gstin,RATE1 ORDER BY buyer_gstin,RATE1
	IF NOT EXISTS(SELECT PART,PARTSR FROM #GSTR3 WHERE PART= 4  AND PARTSR = 4.32 AND  SECTION=2 AND srno = 'B')
	BEGIN
		Insert Into #GSTR3(PART,PARTSR,SECTION,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4.32,2,'B','',0,0,0,0,0 ,0,0,0,0,0)
	END	
	
	/*5.Inward supplies attracting reverse charge including import of services (Net of advance adjustments)*/
	---5A Inward supplies on witch tax is payable on reverse charge basis
	---Inter-State inward supllies [Rate wise]
	INSERT INTO #GSTR3(PART,PARTSR,SECTION,srno,RATE,TAXABLEAMT,IGST_AMT,CGST_AMT,SGST_AMT,CESS_AMT)

	SELECT 5 AS PART,5.1 AS PARTSR,1 AS SECTION,'A' AS SRNO,PER
	,sum((case when ENTRY_TY IN('UB','PT','P1','E1','C6','GC','CP','BP') then + isnull(Taxableamt,0)  else -isnull(Taxableamt,0)  end)-ADJ_TAXABLE) as TAXABLEAMT
	,sum((case when ENTRY_TY IN('UB','PT','P1','E1','C6','GC','CP','BP') then + isnull(IGST_AMT,0) else -isnull(IGST_AMT,0) end)-ADJ_iGST_AMT) as IGST_AMT
	,0 as CGST_AMT
	,0 as SGST_AMT
	,sum((case when ENTRY_TY IN('UB','PT','P1','E1','C6','GC','CP','BP') then + isnull(cess_amt,0)  else -isnull(cess_amt,0) end)-ADJ_CESS_AMT) as CESS_AMT
	FROM (SELECT ENTRY_TY,RATE1 AS PER ,Taxableamt,IGST_AMT,CGST_AMT,SGST_AMT,CESS_AMT,ADJ_TAXABLE,ADJ_CGST_AMT,ADJ_SGST_AMT,ADJ_IGST_AMT,ADJ_CESS_AMT,ADJ_GRO_AMT
	FROM #GSTR3TBL  WHERE ENTRY_TY='UB' AND Trantype = 'INWARD' and isnull(IGST_AMT,0) > 0 
	union all 
	SELECT ENTRY_TY,RATE1 AS PER ,Taxableamt ,IGSRT_AMT,CGSRT_AMT,SGSRT_AMT,CESSR_AMT,ADJ_TAXABLE,ADJ_CGSRT_AMT,ADJ_SGSRT_AMT,ADJ_IGSRT_AMT,ADJ_CESSRT_AMT,ADJ_GRO_AMT
	FROM #GSTR3TBL  WHERE ENTRY_TY IN('PT','P1','E1','PR','C6','D6','GC','GD','CP','BP') AND Trantype = 'INWARD' 
	--AND ST_TYPE ='INTERSTATE'  --Commented by Priyanka B on 24102017	
	--AND SUPP_TYPE NOT IN('UNREGISTERED','')  --Commented by Priyanka B on 13102017
	AND SUPP_TYPE NOT IN('UNREGISTERED')  --Modified by Priyanka B on 13102017
	AND (isnull(IGSRT_AMT,0))> 0 ) AA WHERE ENTRY_TY IN('UB','PT','P1','E1','PR','C6','D6','GC','GD','CP','BP')
	GROUP BY PER  ORDER BY PER 
	
	IF NOT EXISTS(SELECT PART,PARTSR FROM #GSTR3 WHERE PART= 5  AND PARTSR = 5.1 AND srno = 'A' AND SECTION = 1)
	begin
		Insert Into #GSTR3(PART,PARTSR,SECTION ,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(5,5.1,1,'A','',0,0,0,0,0 ,0,0,0,0,0)
	end	
	
	---Intra-State inward supllies [Rate wise]
	INSERT INTO #GSTR3(PART,PARTSR,SECTION,srno,RATE,TAXABLEAMT,IGST_AMT,CGST_AMT,SGST_AMT,CESS_AMT)
	SELECT 5 AS PART,5.1 AS PARTSR,2 AS SECTION,'B' AS SRNO,PER
	,sum((case when ENTRY_TY IN('UB','PT','P1','E1','C6','GC','CP','BP') then + ISNULL(Taxableamt,0)  else -ISNULL(Taxableamt,0)  end) - ADJ_TAXABLE) as TAXABLEAMT
	,sum((case when ENTRY_TY IN('UB','PT','P1','E1','C6','GC','CP','BP') then +ISNULL(IGST_AMT,0) else -ISNULL(IGST_AMT,0) end)-ADJ_IGST_AMT) as IGST_AMT
	,sum((case when ENTRY_TY IN('UB','PT','P1','E1','C6','GC','CP','BP') then +ISNULL(CGST_AMT,0) else -ISNULL(CGST_AMT,0) end)-ADJ_CGST_AMT) as CGST_AMT
	,sum((case when ENTRY_TY IN('UB','PT','P1','E1','C6','GC','CP','BP') then +ISNULL(SGST_AMT,0) else -ISNULL(SGST_AMT,0) end)-ADJ_sGST_AMT) as SGST_AMT
	,sum((case when ENTRY_TY IN('UB','PT','P1','E1','C6','GC','CP','BP') then + ISNULL(cess_amt,0)  else -ISNULL(cess_amt,0) end)-ADJ_CESS_AMT) as CESS_AMT
	FROM (
	SELECT ENTRY_TY,RATE1 AS PER ,Taxableamt ,IGST_AMT ,CGST_AMT ,SGST_AMT,CESS_AMT,ADJ_TAXABLE,ADJ_CGST_AMT,ADJ_SGST_AMT,ADJ_IGST_AMT,ADJ_CESS_AMT,ADJ_GRO_AMT
	FROM #GSTR3TBL  WHERE ENTRY_TY='UB' AND BUYER_ST_TYPE ='INTRASTATE' AND Trantype = 'INWARD'  and (ISNULL(CGST_AMT,0) + ISNULL(SGST_AMT,0)) > 0
	union all 
	SELECT ENTRY_TY,RATE1 AS PER ,Taxableamt,IGSRT_AMT,CGSRT_AMT,SGSRT_AMT,CESSR_AMT ,ADJ_TAXABLE,ADJ_CGSRT_AMT,ADJ_SGSRT_AMT,ADJ_IGSRT_AMT,ADJ_CESSRT_AMT,ADJ_GRO_AMT
	FROM #GSTR3TBL  WHERE ENTRY_TY IN('PT','P1','E1','PR','C6','D6','GC','GD','CP','BP') AND Trantype = 'INWARD' AND ST_TYPE ='INTRASTATE' 
	AND SUPP_TYPE NOT IN('UNREGISTERED','')
	AND (ISNULL(CGSRT_AMT,0) + ISNULL(SGSRT_AMT,0))> 0 )AA WHERE ENTRY_TY IN('UB','PT','P1','E1','PR','C6','D6','GC','GD','CP','BP')
	GROUP BY PER  ORDER BY PER 
	IF NOT EXISTS(SELECT PART,PARTSR FROM #GSTR3 WHERE PART= 5  AND PARTSR = 5.1 AND srno = 'B' AND SECTION = 2)
	begin
		Insert Into #GSTR3(PART,PARTSR,SECTION,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(5,5.1,2,'B','',0,0,0,0,0 ,0,0,0,0,0)
	END
			 
	---5B Tax effect of amendments in respect of supplies attracting reverse charge 
	---Inter-State inward supllies [Rate wise]
	INSERT INTO #GSTR3(PART,PARTSR,SECTION,srno,RATE,TAXABLEAMT,IGST_AMT,CGST_AMT,SGST_AMT,CESS_AMT)
	SELECT 5 AS PART,5.2 AS PARTSR,1 AS SECTION,'A' AS SRNO,PER
	,sum((case when ENTRY_TY IN('UB','PT','P1','E1','C6','GC','CP','BP') then + ISNULL(Taxableamt,0)  else - ISNULL(Taxableamt,0)  end)-ADJ_TAXABLE) as TAXABLEAMT
	,sum((case when ENTRY_TY IN('UB','PT','P1','E1','C6','GC','CP','BP') then + ISNULL(IGST_AMT,0) else - ISNULL(IGST_AMT,0) end)-ADJ_IGST_AMT) as IGST_AMT
	,0 as CGST_AMT
	,0 as SGST_AMT
	,sum((case when ENTRY_TY IN('UB','PT','P1','E1','C6','GC','CP','BP') then + ISNULL(cess_amt,0)  else - ISNULL(cess_amt,0) end)-ADJ_CESS_AMT) as CESS_AMT
	FROM (SELECT ENTRY_TY,rate1 AS PER,Taxableamt,IGST_AMT,CGST_AMT,SGST_AMT,CESS_AMT,ADJ_TAXABLE,ADJ_CGST_AMT,ADJ_SGST_AMT,ADJ_IGST_AMT,ADJ_CESS_AMT,ADJ_GRO_AMT
	FROM #GSTR3TBLAMD  WHERE ENTRY_TY='UB' 
	--AND BUYER_ST_TYPE ='INTERSTATE'   --Commented by Priyanka B on 24102017
	AND Trantype = 'INWARD'  and ISNULL(IGST_AMT,0) > 0
	union all 
	SELECT ENTRY_TY,RATE1 AS PER ,Taxableamt ,IGSRT_AMT,CGSRT_AMT,SGSRT_AMT,CESSR_AMT,ADJ_TAXABLE,ADJ_CGSRT_AMT,ADJ_SGSRT_AMT,ADJ_IGSRT_AMT,ADJ_CESSRT_AMT,ADJ_GRO_AMT
	FROM #GSTR3TBLAMD  WHERE ENTRY_TY IN('PT','P1','E1','PR','C6','D6','GC','GD','CP','BP') AND Trantype = 'INWARD' 
	--AND ST_TYPE ='INTERSTATE'   --Commented by Priyanka B on 24102017
	AND ST_TYPE in ('INTERSTATE','OUT OF COUNTRY')  --Modified by Priyanka B on 24102017
	--AND SUPP_TYPE NOT IN('UNREGISTERED','')  --Commented by Priyanka B on 13102017
	AND SUPP_TYPE NOT IN('UNREGISTERED')  --Modified by Priyanka B on 13102017
	AND ( ISNULL(IGSRT_AMT,0)  )> 0 )AA WHERE ENTRY_TY IN('UB','PT','P1','E1','PR','C6','D6','GC','GD','CP','BP')
	GROUP BY PER  ORDER BY PER 
	IF NOT EXISTS(SELECT PART,PARTSR FROM #GSTR3 WHERE PART= 5  AND PARTSR = 5.2 AND srno = 'A' AND SECTION = 1)
	begin
		Insert Into #GSTR3(PART,PARTSR,SECTION,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(5,5.2,1,'A','',0,0,0,0,0 ,0,0,0,0,0)
	end
	
	---Intra-State inward supllies [Rate wise]
	INSERT INTO #GSTR3(PART,PARTSR,SECTION,srno,RATE,TAXABLEAMT,IGST_AMT,CGST_AMT,SGST_AMT,CESS_AMT)
	SELECT 5 AS PART,5.2 AS PARTSR,2 AS SECTION,'B' AS SRNO,PER
	,sum((case when ENTRY_TY IN('UB','PT','P1','E1','C6','GC','CP','BP') then + ISNULL(Taxableamt,0)  else - ISNULL(Taxableamt,0)end)-ADJ_TAXABLE) as TAXABLEAMT
	,0 as IGST_AMT
	,sum((case when ENTRY_TY IN('UB','PT','P1','E1','C6','GC','CP','BP') then + ISNULL(CGST_AMT,0) else -ISNULL(CGST_AMT,0) end)-ADJ_CGST_AMT) as CGST_AMT
	,sum((case when ENTRY_TY IN('UB','PT','P1','E1','C6','GC','CP','BP') then + ISNULL(SGST_AMT,0) else -ISNULL(SGST_AMT,0) end)-ADJ_SGST_AMT) as SGST_AMT
	,sum((case when ENTRY_TY IN('UB','PT','P1','E1','C6','GC','CP','BP') then + ISNULL(cess_amt,0)  else -ISNULL(cess_amt,0) end)-ADJ_CESS_AMT) as CESS_AMT
	FROM (
	SELECT ENTRY_TY,rate1 AS PER ,Taxableamt ,IGST_AMT ,CGST_AMT ,SGST_AMT,CESS_AMT,ADJ_TAXABLE,ADJ_CGST_AMT,ADJ_SGST_AMT,ADJ_IGST_AMT,ADJ_CESS_AMT,ADJ_GRO_AMT
	FROM #GSTR3TBLAMD  WHERE ENTRY_TY='UB' AND BUYER_ST_TYPE ='INTRASTATE' AND Trantype = 'INWARD'  and (ISNULL(CGST_AMT,0)+ isnull(SGST_AMT,0)) > 0
	union all 
	SELECT ENTRY_TY,rate1 AS PER ,Taxableamt ,IGSRT_AMT,CGSRT_AMT,SGSRT_AMT,CESSR_AMT,ADJ_TAXABLE,ADJ_CGSRT_AMT,ADJ_SGSRT_AMT,ADJ_IGSRT_AMT,ADJ_CESSRT_AMT,ADJ_GRO_AMT
	FROM #GSTR3TBLAMD  WHERE ENTRY_TY IN('PT','P1','E1','PR','C6','D6','GC','GD','CP','BP') AND Trantype = 'INWARD' AND ST_TYPE ='INTRASTATE' AND SUPP_TYPE NOT IN('UNREGISTERED','')
	AND (ISNULL(CGSRT_AMT,0) + ISNULL(SGSRT_AMT,0))> 0 )AA WHERE ENTRY_TY IN('UB','PT','P1','E1','PR','C6','D6','GC','GD','CP','BP')
	GROUP BY PER  ORDER BY PER 
	IF NOT EXISTS(SELECT PART,PARTSR FROM #GSTR3 WHERE PART= 5  AND PARTSR = 5.2 AND srno = 'B' AND SECTION = 2)
	begin
		Insert Into #GSTR3(PART,PARTSR,SECTION ,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(5,5.2,2,'B','',0,0,0,0,0 ,0,0,0,0,0)
	END
	 
	/*6.Input Tax Credit
		ITC on inward taxable supplies including inports ITC revevied from ISD[NET OF DEBIT NOTE OR CREDIT NOTE]
		(I) On account of supplies received and debit notes /credit notes received during the current tax period
	*/	
		SELECT *  INTO #GSTR3TBL6_2  FROM (SELECT * FROM #GSTR3TBL 
		WHERE ENTRY_TY not in('UB')
		AND tranType = 'INWARD' AND SUPP_TYPE NOT IN('UNREGISTERED')  AND AVL_ITC = 1
		AND (ISNULL(CGST_AMT,0)+ISNULL(SGST_AMT,0)+ISNULL(IGST_AMT,0)+ISNULL(CESS_AMT,0)) > 0
		UNION ALL 
		SELECT * FROM #GSTR3TBL 
		WHERE ENTRY_TY='UB' AND tranType = 'INWARD' AND (entry_ty +QUOTENAME(Tran_cd)) in (select (entry_ALL +QUOTENAME(MAIN_TRAN)) from  Mainall_vw where entry_ty='GB')
		Union all
		SELECT * FROM #GSTR3TBL 
		WHERE ENTRY_TY not in('UB')
		AND tranType = 'INWARD' AND SUPP_TYPE NOT IN('UNREGISTERED')  AND AVL_ITC = 1
		AND (ISNULL(CGSRT_AMT,0)+ISNULL(SGSRT_AMT,0)+ISNULL(IGSRT_AMT,0)+ISNULL(CESSR_AMT,0)) > 0
		AND (entry_ty +QUOTENAME(Tran_cd)) in (select (entry_ALL +QUOTENAME(MAIN_TRAN)) from  Mainall_vw			
					where entry_ty='GB')
		)AA 
	
	--Inputs
	INSERT INTO #GSTR3(PART,PARTSR,SECTION,srno,RATE,TAXABLEAMT,IGST_AMT,CGST_AMT,SGST_AMT,CESS_AMT,itc_igst_amt,itc_cgst_amt ,itc_sgst_amt ,itc_cess_amt,descr)
	SELECT 6 AS PART,6.1 AS PARTSR,1 AS SECTION,'A' AS SRNO,0.00 as PER
	,sum((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(Taxableamt,0)  else - ISNULL(Taxableamt,0)end)-ADJ_TAXABLE) as TAXABLEAMT
	,sum((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(IGST_AMT,0) else -ISNULL(IGST_AMT,0) end)-ADJ_IGST_AMT) as IGST_AMT
	,sum((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(CGST_AMT,0) else -ISNULL(CGST_AMT,0) end)-ADJ_CGST_AMT) as CGST_AMT
	,sum((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(SGST_AMT,0) else -ISNULL(SGST_AMT,0) end)-ADJ_SGST_AMT) as SGST_AMT
	,sum((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(cess_amt,0)  else - ISNULL(cess_amt,0) end)-ADJ_CESS_AMT) as CESS_AMT
	,sum(case when TRANSTATUS = 1  then ((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(IGST_AMT,0) else -ISNULL(IGST_AMT,0) end)-ADJ_IGST_AMT)  else 0.00 end ) as itc_IGST_AMT 
	,sum(case when TRANSTATUS = 1  then ((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(CGST_AMT,0) else -ISNULL(CGST_AMT,0) end)-ADJ_CGST_AMT)  else 0.00 end )as itc_CGST_AMT
	,sum(case when TRANSTATUS = 1  then ((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(SGST_AMT,0) else -ISNULL(SGST_AMT,0) end)-ADJ_SGST_AMT)  else 0.00 end ) as  itc_SGST_AMT
	,sum(case when TRANSTATUS = 1  then ((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(cess_amt,0)  else - ISNULL(cess_amt,0) end)-ADJ_CESS_AMT)  else 0.00 end) as  itc_CESS_AMT
	,'Inputs' as descr
	--from #GSTR3TBL6_2 WHERE Entry_ty  IN('PT','P1','E1','PR','C6','D6','GC','GD','J6','J8','UB') AND Trantype = 'INWARD' AND gstype = 'Inputs'  --Commented by Priyanka B on 16102017
	--Modified by Priyanka B on 16102017 Start
	from (SELECT ENTRY_TY,TRANSTATUS,Trantype,gstype,rate1 AS PER ,Taxableamt ,IGST_AMT ,CGST_AMT ,SGST_AMT,CESS_AMT,ADJ_TAXABLE,ADJ_CGST_AMT,ADJ_SGST_AMT,ADJ_IGST_AMT,ADJ_CESS_AMT  
			FROM #GSTR3TBL6_2 WHERE (ISNULL(CGST_AMT,0)+ISNULL(SGST_AMT,0)+ISNULL(IGST_AMT,0)+ISNULL(CESS_AMT,0)) > 0
			UNION ALL
		  SELECT ENTRY_TY,TRANSTATUS,Trantype,gstype,rate1 AS PER ,Taxableamt ,IGSRT_AMT ,CGSRT_AMT ,SGSRT_AMT,CESSR_AMT,ADJ_TAXABLE,ADJ_CGSRT_AMT,ADJ_SGSRT_AMT,ADJ_IGSRT_AMT,ADJ_CESSRT_AMT  
			FROM #GSTR3TBL6_2 WHERE (ISNULL(CGSRT_AMT,0)+ISNULL(SGSRT_AMT,0)+ISNULL(IGSRT_AMT,0)+ISNULL(CESSR_AMT,0)) > 0)aa
		WHERE Entry_ty  IN('PT','P1','E1','PR','C6','D6','GC','GD','J6','J8','UB','BP','CP') AND Trantype = 'INWARD' AND gstype = 'Inputs'
	--Modified by Priyanka B on 16102017 End
	
	IF NOT EXISTS(SELECT PART,PARTSR FROM #GSTR3 WHERE PART= 6  AND PARTSR = 6.1 AND srno = 'A' and section = 1)
	begin
		Insert Into #GSTR3(PART,PARTSR,SECTION,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(6,6.1,1,'A','Inputs',0,0,0,0,0 ,0,0,0,0,0)
	end 
	--Inputs Services
	--SELECT ENTRY_TY,TRANSTATUS,Trantype,gstype,rate1 AS PER ,Taxableamt ,IGST_AMT ,CGST_AMT ,SGST_AMT,CESS_AMT,ADJ_TAXABLE,ADJ_CGST_AMT,ADJ_SGST_AMT,ADJ_IGST_AMT,ADJ_CESS_AMT  
	--		FROM #GSTR3TBL6_2 WHERE (ISNULL(CGST_AMT,0)+ISNULL(SGST_AMT,0)+ISNULL(IGST_AMT,0)+ISNULL(CESS_AMT,0)) > 0
	--		UNION ALL
	--	  SELECT ENTRY_TY,TRANSTATUS,Trantype,gstype,rate1 AS PER ,Taxableamt ,IGSRT_AMT ,CGSRT_AMT ,SGSRT_AMT,CESSR_AMT,ADJ_TAXABLE,ADJ_CGSRT_AMT,ADJ_SGSRT_AMT,ADJ_IGSRT_AMT,ADJ_CESSRT_AMT  
	--		FROM #GSTR3TBL6_2 WHERE (ISNULL(CGSRT_AMT,0)+ISNULL(SGSRT_AMT,0)+ISNULL(IGSRT_AMT,0)+ISNULL(CESSR_AMT,0)) > 0
			
	INSERT INTO #GSTR3(PART,PARTSR,SECTION,srno,RATE,TAXABLEAMT,IGST_AMT,CGST_AMT,SGST_AMT,CESS_AMT,itc_igst_amt,itc_cgst_amt ,itc_sgst_amt ,itc_cess_amt,descr)
	SELECT 6 AS PART,6.1 AS PARTSR,1 AS SECTION,'B' AS SRNO,0.00 as PER
	,sum((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(Taxableamt,0)  else -ISNULL(Taxableamt,0)end)-ADJ_TAXABLE) as TAXABLEAMT
	,sum((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(IGST_AMT,0) else -ISNULL(IGST_AMT,0) end)-ADJ_IGST_AMT) as IGST_AMT
	,sum((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(CGST_AMT,0) else -ISNULL(CGST_AMT,0) end)-ADJ_CGST_AMT) as CGST_AMT
	,sum((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(SGST_AMT,0) else -ISNULL(SGST_AMT,0) end)-ADJ_SGST_AMT) as SGST_AMT
	,sum((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(cess_amt,0)  else -ISNULL(cess_amt,0) end)-ADJ_CESS_AMT) as CESS_AMT
	,sum(case when TRANSTATUS = 1  then ((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(IGST_AMT,0) else -ISNULL(IGST_AMT,0) end)-ADJ_IGST_AMT)  else 0.00 end ) as itc_IGST_AMT 
	,sum(case when TRANSTATUS = 1  then ((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(CGST_AMT,0) else -ISNULL(CGST_AMT,0) end)-ADJ_CGST_AMT) else 0.00 end ) as itc_CGST_AMT
	,sum(case when TRANSTATUS = 1  then ((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(SGST_AMT,0) else -ISNULL(SGST_AMT,0) end)-ADJ_SGST_AMT) else 0.00 end ) as itc_SGST_AMT
	,sum(case when TRANSTATUS = 1  then ((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(cess_amt,0)  else -ISNULL(cess_amt,0) end)-ADJ_CESS_AMT) else 0.00 end ) as itc_CESS_AMT
	,'Inputs Services' as descr
	--from #GSTR3TBL6_2 WHERE Entry_ty  IN('PT','P1','E1','PR','C6','D6','GC','GD','J6','J8','UB') AND Trantype = 'INWARD' AND gstype = 'Input Services'  --Commented by Priyanka B on 16102017
	--Modified by Priyanka B on 16102017 Start
	from (SELECT ENTRY_TY,TRANSTATUS,Trantype,gstype,rate1 AS PER ,Taxableamt ,IGST_AMT ,CGST_AMT ,SGST_AMT,CESS_AMT,ADJ_TAXABLE,ADJ_CGST_AMT,ADJ_SGST_AMT,ADJ_IGST_AMT,ADJ_CESS_AMT  
			FROM #GSTR3TBL6_2 WHERE (ISNULL(CGST_AMT,0)+ISNULL(SGST_AMT,0)+ISNULL(IGST_AMT,0)+ISNULL(CESS_AMT,0)) > 0
			UNION ALL
		  SELECT ENTRY_TY,TRANSTATUS,Trantype,gstype,rate1 AS PER ,Taxableamt ,IGSRT_AMT ,CGSRT_AMT ,SGSRT_AMT,CESSR_AMT,ADJ_TAXABLE,ADJ_CGSRT_AMT,ADJ_SGSRT_AMT,ADJ_IGSRT_AMT,ADJ_CESSRT_AMT  
			FROM #GSTR3TBL6_2 WHERE (ISNULL(CGSRT_AMT,0)+ISNULL(SGSRT_AMT,0)+ISNULL(IGSRT_AMT,0)+ISNULL(CESSR_AMT,0)) > 0)aa
		WHERE Entry_ty  IN('PT','P1','E1','PR','C6','D6','GC','GD','J6','J8','UB','BP','CP') AND Trantype = 'INWARD' AND gstype = 'Input Services'
	--Modified by Priyanka B on 16102017 End
	
	IF NOT EXISTS(SELECT PART,PARTSR FROM #GSTR3 WHERE PART= 6  AND PARTSR = 6.1 AND srno = 'B' and section = 1 )
	begin
		Insert Into #GSTR3(PART,PARTSR,SECTION,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(6,6.1,1,'B','Inputs Services',0,0,0,0,0 ,0,0,0,0,0)
	end
	--Captial goods
	--select sum((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB') then + ISNULL(Taxableamt,0)  else -ISNULL(Taxableamt,0) end)-ADJ_TAXABLE) as TAXABLEAMT
	-- from (SELECT ENTRY_TY,TRANSTATUS,Trantype,gstype,rate1 AS PER ,Taxableamt ,IGST_AMT ,CGST_AMT ,SGST_AMT,CESS_AMT,ADJ_TAXABLE,ADJ_CGST_AMT,ADJ_SGST_AMT,ADJ_IGST_AMT,ADJ_CESS_AMT  
	--		FROM #GSTR3TBL6_2 WHERE (ISNULL(CGST_AMT,0)+ISNULL(SGST_AMT,0)+ISNULL(IGST_AMT,0)+ISNULL(CESS_AMT,0)) > 0
	--		UNION ALL
	--	  SELECT ENTRY_TY,TRANSTATUS,Trantype,gstype,rate1 AS PER ,Taxableamt ,IGSRT_AMT ,CGSRT_AMT ,SGSRT_AMT,CESSR_AMT,ADJ_TAXABLE,ADJ_CGST_AMT,ADJ_SGST_AMT,ADJ_IGST_AMT,ADJ_CESS_AMT  
	--		FROM #GSTR3TBL6_2 WHERE (ISNULL(CGSRT_AMT,0)+ISNULL(SGSRT_AMT,0)+ISNULL(IGSRT_AMT,0)+ISNULL(CESSR_AMT,0)) > 0
	--		)aa
	--		WHERE Entry_ty  IN('PT','P1','E1','PR','C6','D6','GC','GD','J6','J8','UB') AND Trantype = 'INWARD' AND gstype = 'Capital Goods'
			
	INSERT INTO #GSTR3(PART,PARTSR,SECTION,srno,RATE,TAXABLEAMT,IGST_AMT,CGST_AMT,SGST_AMT,CESS_AMT,itc_igst_amt,itc_cgst_amt ,itc_sgst_amt ,itc_cess_amt,descr)
	SELECT 6 AS PART,6.1 AS PARTSR,1 AS SECTION,'C' AS SRNO,0.00 as PER
	,sum((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(Taxableamt,0)  else -ISNULL(Taxableamt,0) end)-ADJ_TAXABLE) as TAXABLEAMT
	,sum((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(IGST_AMT,0) else - ISNULL(IGST_AMT,0) end)-ADJ_IGST_AMT) as IGST_AMT
	,sum((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(CGST_AMT,0) else - ISNULL(CGST_AMT,0) end)-ADJ_CGST_AMT) as CGST_AMT
	,sum((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(SGST_AMT,0) else - ISNULL(SGST_AMT,0) end)-ADJ_SGST_AMT) as SGST_AMT
	,sum((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(cess_amt,0)  else -ISNULL(cess_amt,0) end)-ADJ_CESS_AMT) as CESS_AMT
	,sum(case when TRANSTATUS = 1  then ((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(IGST_AMT,0) else - ISNULL(IGST_AMT,0) end)-ADJ_IGST_AMT) else 0.00 end ) as itc_IGST_AMT
	,sum(case when TRANSTATUS = 1  then ((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(CGST_AMT,0) else - ISNULL(CGST_AMT,0) end)-ADJ_CGST_AMT) else 0.00 end ) as itc_CGST_AMT
	,sum(case when TRANSTATUS = 1  then ((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(SGST_AMT,0) else - ISNULL(SGST_AMT,0) end)-ADJ_SGST_AMT) else 0.00 end) as itc_SGST_AMT
	,sum(case when TRANSTATUS = 1  then ((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(cess_amt,0)  else -ISNULL(cess_amt,0) end)-ADJ_CESS_AMT) else 0.00 end ) as itc_CESS_AMT
	,'Captial goods' as descr
	--from #GSTR3TBL6_2 WHERE Entry_ty  IN('PT','P1','E1','PR','C6','D6','GC','GD','J6','J8','UB') AND Trantype = 'INWARD' AND gstype = 'Capital Goods'   --Commented by Priyanka B on 16102017
	--Modified by Priyanka B on 16102017 Start
	from (SELECT ENTRY_TY,TRANSTATUS,Trantype,gstype,rate1 AS PER ,Taxableamt ,IGST_AMT ,CGST_AMT ,SGST_AMT,CESS_AMT,ADJ_TAXABLE,ADJ_CGST_AMT,ADJ_SGST_AMT,ADJ_IGST_AMT,ADJ_CESS_AMT  
			FROM #GSTR3TBL6_2 WHERE (ISNULL(CGST_AMT,0)+ISNULL(SGST_AMT,0)+ISNULL(IGST_AMT,0)+ISNULL(CESS_AMT,0)) > 0
			UNION ALL
		  SELECT ENTRY_TY,TRANSTATUS,Trantype,gstype,rate1 AS PER ,Taxableamt ,IGSRT_AMT ,CGSRT_AMT ,SGSRT_AMT,CESSR_AMT,ADJ_TAXABLE,ADJ_CGSRT_AMT,ADJ_SGSRT_AMT,ADJ_IGSRT_AMT,ADJ_CESSRT_AMT  
			FROM #GSTR3TBL6_2 WHERE (ISNULL(CGSRT_AMT,0)+ISNULL(SGSRT_AMT,0)+ISNULL(IGSRT_AMT,0)+ISNULL(CESSR_AMT,0)) > 0)aa
		WHERE Entry_ty  IN('PT','P1','E1','PR','C6','D6','GC','GD','J6','J8','UB','BP','CP') AND Trantype = 'INWARD' AND gstype = 'Capital Goods'
	--Modified by Priyanka B on 16102017 End
	
	IF NOT EXISTS(SELECT PART,PARTSR FROM #GSTR3 WHERE PART= 6  AND PARTSR = 6.1 AND srno = 'C' and SECTION = 1 )
	begin
		Insert Into #GSTR3(PART,PARTSR,SECTION,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(6,6.1,1,'C','Captial goods',0,0,0,0,0 ,0,0,0,0,0)
	END
	---(II)On account of amendments made (of the details furnished in earlier tax periods) 
	----
		SELECT *  INTO #GSTR3TBLAMD6  FROM (SELECT * FROM #GSTR3TBLAMD
		WHERE ENTRY_TY not in('UB')
		AND tranType = 'INWARD' AND SUPP_TYPE NOT IN('UNREGISTERED')  AND AVL_ITC = 1
		AND (ISNULL(CGST_AMT,0)+ISNULL(SGST_AMT,0)+ISNULL(IGST_AMT,0)+ISNULL(CESS_AMT,0)) > 0
		UNION ALL 
		SELECT * FROM #GSTR3TBLAMD 
		WHERE ENTRY_TY='UB' AND tranType = 'INWARD' AND (entry_ty +QUOTENAME(Tran_cd)) in (select (entry_ALL +QUOTENAME(MAIN_TRAN)) from  Mainall_vw)
		UNION ALL 
		SELECT * FROM #GSTR3TBLAMD 
		WHERE ENTRY_TY not in('UB')
		AND tranType = 'INWARD' AND SUPP_TYPE NOT IN('UNREGISTERED')  AND AVL_ITC = 1
		AND (ISNULL(CGSRT_AMT,0)+ISNULL(SGSRT_AMT,0)+ISNULL(IGSRT_AMT,0)+ISNULL(CESSR_AMT,0)) > 0
		AND (entry_ty +QUOTENAME(Tran_cd)) in (select (entry_ALL +QUOTENAME(MAIN_TRAN)) from  Mainall_vw			
					where entry_ty='GB')
					
		--SELECT * FROM #GSTR3TBLAMD 
		--WHERE ENTRY_TY='E1' AND tranType = 'INWARD' 
		--AND (entry_ty +QUOTENAME(Tran_cd)) in (select (entry_ALL +QUOTENAME(MAIN_TRAN)) from  Mainall_vw
		--			where entry_ty='GB')   --Added by Priyanka B on 28102017
		--AND SUPP_TYPE = 'Registered' AND (ISNULL(CGSRT_AMT,0)+ISNULL(SGSRT_AMT,0)+ISNULL(IGSRT_AMT,0)) > 0
		)AA 
	
	--Inputs
	INSERT INTO #GSTR3(PART,PARTSR,SECTION,srno,RATE,TAXABLEAMT,IGST_AMT,CGST_AMT,SGST_AMT,CESS_AMT,itc_igst_amt,itc_cgst_amt ,itc_sgst_amt ,itc_cess_amt,descr)
	SELECT 6 AS PART,6.1 AS PARTSR,2 AS SECTION,'A' AS SRNO,0.00 as PER
	,sum((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(Taxableamt,0)  else - ISNULL(Taxableamt,0)end)-ADJ_TAXABLE) as TAXABLEAMT
	,sum((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(IGST_AMT,0) else -ISNULL(IGST_AMT,0) end)-ADJ_IGST_AMT) as IGST_AMT
	,sum((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(CGST_AMT,0) else -ISNULL(CGST_AMT,0) end)-ADJ_CGST_AMT) as CGST_AMT
	,sum((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(SGST_AMT,0) else - ISNULL(SGST_AMT,0) end)-ADJ_SGST_AMT) as SGST_AMT
	,sum((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(cess_amt,0)  else -ISNULL(cess_amt,0) end)-ADJ_CESS_AMT) as CESS_AMT
	,sum(case when TRANSTATUS = 1  then ((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(IGST_AMT,0) else -ISNULL(IGST_AMT,0) end)-ADJ_IGST_AMT) else 0.00 end ) as itc_IGST_AMT
	,sum(case when TRANSTATUS = 1  then ((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(CGST_AMT,0) else -ISNULL(CGST_AMT,0) end)-ADJ_CGST_AMT)  else 0.00 end ) as itc_CGST_AMT
	,sum(case when TRANSTATUS = 1  then ((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(SGST_AMT,0) else - ISNULL(SGST_AMT,0) end)-ADJ_SGST_AMT)  else 0.00 end ) as itc_SGST_AMT
	,sum(case when TRANSTATUS = 1  then ((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + ISNULL(cess_amt,0)  else -ISNULL(cess_amt,0) end)-ADJ_CESS_AMT)  else 0.00 end ) as itc_CESS_AMT
	,'Inputs' as descr
	--from #GSTR3TBLAMD6 WHERE Entry_ty  IN('PT','P1','E1','PR','C6','D6','GC','GD','J6','J8')  AND Trantype = 'INWARD' AND gstype = 'Inputs'  --Commented by Priyanka B on 16102017
	--Modified by Priyanka B on 16102017 Start
	from (SELECT ENTRY_TY,TRANSTATUS,Trantype,gstype,rate1 AS PER ,Taxableamt ,IGST_AMT ,CGST_AMT ,SGST_AMT,CESS_AMT,ADJ_TAXABLE,ADJ_CGST_AMT,ADJ_SGST_AMT,ADJ_IGST_AMT,ADJ_CESS_AMT  
			FROM #GSTR3TBLAMD6 WHERE (ISNULL(CGST_AMT,0)+ISNULL(SGST_AMT,0)+ISNULL(IGST_AMT,0)+ISNULL(CESS_AMT,0)) > 0
			UNION ALL
		  SELECT ENTRY_TY,TRANSTATUS,Trantype,gstype,rate1 AS PER ,Taxableamt ,IGSRT_AMT ,CGSRT_AMT ,SGSRT_AMT,CESSR_AMT,ADJ_TAXABLE,ADJ_CGSRT_AMT,ADJ_SGSRT_AMT,ADJ_IGSRT_AMT,ADJ_CESSRT_AMT  
			FROM #GSTR3TBLAMD6 WHERE (ISNULL(CGSRT_AMT,0)+ISNULL(SGSRT_AMT,0)+ISNULL(IGSRT_AMT,0)+ISNULL(CESSR_AMT,0)) > 0)aa
		WHERE Entry_ty  IN('PT','P1','E1','PR','C6','D6','GC','GD','J6','J8','UB','BP','CP')  AND Trantype = 'INWARD' AND gstype = 'Inputs'
	--Modified by Priyanka B on 16102017 End
	
	IF NOT EXISTS(SELECT PART,PARTSR FROM #GSTR3 WHERE PART= 6  AND PARTSR = 6.1 AND srno = 'A' and SECTION = 2 )
	begin
		Insert Into #GSTR3(PART,PARTSR,SECTION,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(6,6.1,2,'A','Inputs',0,0,0,0,0 ,0,0,0,0,0)
	END 
	--Input Services
	INSERT INTO #GSTR3(PART,PARTSR,SECTION,srno,RATE,TAXABLEAMT,IGST_AMT,CGST_AMT,SGST_AMT,CESS_AMT,itc_igst_amt,itc_cgst_amt ,itc_sgst_amt ,itc_cess_amt,descr)
	SELECT 6 AS PART,6.1 AS PARTSR,2 AS SECTION,'B' AS SRNO,0.00 as PER
	,sum((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + isnull(Taxableamt,0)  else -isnull(Taxableamt,0)  end)-ADJ_TAXABLE) as TAXABLEAMT
	,sum((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + isnull(IGST_AMT,0) else - isnull(IGST_AMT,0) end)-ADJ_IGST_AMT) as IGST_AMT
	,sum((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + isnull(CGST_AMT,0) else - isnull(CGST_AMT,0) end)-ADJ_CGST_AMT) as CGST_AMT
	,sum((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + isnull(SGST_AMT,0) else - isnull(SGST_AMT,0) end)-ADJ_SGST_AMT) as SGST_AMT
	,sum((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + isnull(cess_amt,0)  else - isnull(cess_amt,0) end)) as CESS_AMT
	,sum(case when TRANSTATUS = 1  then ((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + isnull(IGST_AMT,0) else - isnull(IGST_AMT,0) end)-ADJ_IGST_AMT) else 0.00 end ) as itc_IGST_AMT
	,sum(case when TRANSTATUS = 1  then ((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + isnull(CGST_AMT,0) else - isnull(CGST_AMT,0) end)-ADJ_CGST_AMT) else 0.00 end ) as itc_CGST_AMT
	,sum(case when TRANSTATUS = 1  then ((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + isnull(SGST_AMT,0) else - isnull(SGST_AMT,0) end)-ADJ_SGST_AMT) else 0.00 end ) as itc_SGST_AMT
	,sum(case when TRANSTATUS = 1  then ((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + isnull(cess_amt,0)  else - isnull(cess_amt,0) end)) else 0.00 end ) as itc_CESS_AMT
	,'Input Services' as descr	
	--from #GSTR3TBLAMD6 WHERE Entry_ty  IN('PT','P1','E1','PR','C6','D6','GC','GD','J6','J8','UB')  AND Trantype = 'INWARD' AND gstype = 'Input Services'  --Commented by Priyanka B on 16102017
	--Modified by Priyanka B on 16102017 Start
	from (SELECT ENTRY_TY,TRANSTATUS,Trantype,gstype,rate1 AS PER ,Taxableamt ,IGST_AMT ,CGST_AMT ,SGST_AMT,CESS_AMT,ADJ_TAXABLE,ADJ_CGST_AMT,ADJ_SGST_AMT,ADJ_IGST_AMT,ADJ_CESS_AMT  
			FROM #GSTR3TBLAMD6 WHERE (ISNULL(CGST_AMT,0)+ISNULL(SGST_AMT,0)+ISNULL(IGST_AMT,0)+ISNULL(CESS_AMT,0)) > 0
			UNION ALL
		  SELECT ENTRY_TY,TRANSTATUS,Trantype,gstype,rate1 AS PER ,Taxableamt ,IGSRT_AMT ,CGSRT_AMT ,SGSRT_AMT,CESSR_AMT,ADJ_TAXABLE,ADJ_CGSRT_AMT,ADJ_SGSRT_AMT,ADJ_IGSRT_AMT,ADJ_CESSRT_AMT  
			FROM #GSTR3TBLAMD6 WHERE (ISNULL(CGSRT_AMT,0)+ISNULL(SGSRT_AMT,0)+ISNULL(IGSRT_AMT,0)+ISNULL(CESSR_AMT,0)) > 0)aa
		WHERE Entry_ty  IN('PT','P1','E1','PR','C6','D6','GC','GD','J6','J8','UB','BP','CP')  AND Trantype = 'INWARD' AND gstype = 'Input Services'
	--Modified by Priyanka B on 16102017 End
	
	IF NOT EXISTS(SELECT PART,PARTSR FROM #GSTR3 WHERE PART= 6  AND PARTSR = 6.1 AND srno = 'B' and SECTION = 2)
	begin
		Insert Into #GSTR3(PART,PARTSR,SECTION,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(6,6.1,2,'B','Input Services',0,0,0,0,0 ,0,0,0,0,0)
	END 
	--Captial goods
	INSERT INTO #GSTR3(PART,PARTSR,SECTION,srno,RATE,TAXABLEAMT,IGST_AMT,CGST_AMT,SGST_AMT,CESS_AMT,itc_igst_amt,itc_cgst_amt ,itc_sgst_amt ,itc_cess_amt,descr)
	SELECT 6 AS PART,6.1 AS PARTSR,2 AS SECTION,'C' AS SRNO,0.00 as PER
	,sum((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + isnull(Taxableamt,0)  else - isnull(Taxableamt,0)end)-ADJ_TAXABLE) as TAXABLEAMT
	,sum((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + isnull(IGST_AMT,0) else - isnull(IGST_AMT,0) end)-ADJ_IGST_AMT) as IGST_AMT
	,sum((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + isnull(CGST_AMT,0) else - isnull(CGST_AMT,0) end)-ADJ_CGST_AMT) as CGST_AMT
	,sum((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + isnull(SGST_AMT,0) else - isnull(SGST_AMT,0) end)-ADJ_SGST_AMT) as SGST_AMT
	,sum((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + isnull(cess_amt,0)  else - isnull(cess_amt,0) end)-ADJ_CESS_AMT) as CESS_AMT
	,sum(case when TRANSTATUS = 1  then ((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + isnull(IGST_AMT,0) else - isnull(IGST_AMT,0) end)-ADJ_IGST_AMT) else 0.00 end ) as itc_IGST_AMT
	,sum(case when TRANSTATUS = 1  then ((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + isnull(CGST_AMT,0) else - isnull(CGST_AMT,0) end)-ADJ_CGST_AMT) else 0.00 end ) as itc_CGST_AMT
	,sum(case when TRANSTATUS = 1  then ((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + isnull(SGST_AMT,0) else - isnull(SGST_AMT,0) end)-ADJ_SGST_AMT) else 0.00 end ) as itc_SGST_AMT
	,sum(case when TRANSTATUS = 1  then ((case when ENTRY_TY IN('PT','P1','E1','C6','GC','J6','J8','UB','BP','CP') then + isnull(cess_amt,0)  else - isnull(cess_amt,0) end)-ADJ_CESS_AMT)else 0.00 end ) as itc_CESS_AMT
	,'Captial goods' as descr
	--from #GSTR3TBLAMD6 WHERE Entry_ty  IN('PT','P1','E1','PR','C6','D6','GC','GD','J6','J8','UB') AND Trantype = 'INWARD' AND gstype = 'Capital Goods'  --Commented by Priyanka B on 16102017
	--Modified by Priyanka B on 16102017 Start
	from (SELECT ENTRY_TY,TRANSTATUS,Trantype,gstype,rate1 AS PER ,Taxableamt ,IGST_AMT ,CGST_AMT ,SGST_AMT,CESS_AMT,ADJ_TAXABLE,ADJ_CGST_AMT,ADJ_SGST_AMT,ADJ_IGST_AMT,ADJ_CESS_AMT  
			FROM #GSTR3TBLAMD6 WHERE (ISNULL(CGST_AMT,0)+ISNULL(SGST_AMT,0)+ISNULL(IGST_AMT,0)+ISNULL(CESS_AMT,0)) > 0
			UNION ALL
		  SELECT ENTRY_TY,TRANSTATUS,Trantype,gstype,rate1 AS PER ,Taxableamt ,IGSRT_AMT ,CGSRT_AMT ,SGSRT_AMT,CESSR_AMT,ADJ_TAXABLE,ADJ_CGSRT_AMT,ADJ_SGSRT_AMT,ADJ_IGSRT_AMT,ADJ_CESSRT_AMT  
			FROM #GSTR3TBLAMD6 WHERE (ISNULL(CGSRT_AMT,0)+ISNULL(SGSRT_AMT,0)+ISNULL(IGSRT_AMT,0)+ISNULL(CESSR_AMT,0)) > 0)aa
		WHERE Entry_ty  IN('PT','P1','E1','PR','C6','D6','GC','GD','J6','J8','UB','BP','CP') AND Trantype = 'INWARD' AND gstype = 'Capital Goods'
	--Modified by Priyanka B on 16102017 End
	
	IF NOT EXISTS(SELECT PART,PARTSR FROM #GSTR3 WHERE PART= 6  AND PARTSR = 6.1 AND srno = 'C'  AND SECTION = 2)
	begin
		Insert Into #GSTR3(PART,PARTSR,SECTION,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(6,6.1,2,'C','Captial goods',0,0,0,0,0 ,0,0,0,0,0)
	END
   /*
	7.Addition and reduction of amount in output tax for mismatch and other reasons
   */
   --(a)ITC claimed on mismatched/duplication of invoices/debit notes
	set @amt1 = 0.00 
	set @amt2 = 0.00 
	set @amt3 = 0.00  
	set @amt4 = 0.00 
	select @amt1= isnull(sum(CGST_AMT),0),@amt2 =isnull(sum(SGST_AMT),0),@amt3=isnull(sum(IGST_AMT),0),@amt4 =isnull(sum(COMPCESS),0) from JVMAIN 
	where entry_ty = 'j7' and (date between @SDATE and @EDATE ) 
	and RevsType = 'ITC claimed on mismatched/duplication of invoices/debit notes'
	and AGAINSTTY = 'Addition' and RRGST = 'Output Tax'
	Insert Into #GSTR3(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE,add_type)
				VALUES(7,7,'A','ITC claimed on mismatched/duplication of invoices/debit notes',0,0,@amt1,@amt2,@amt3 ,@amt4,0,0,0,0,'Add')
				
   --(b)Tax liability on mismatched credit notes
	set @amt1 = 0.00 
	set @amt2 = 0.00 
	set @amt3 = 0.00  
	set @amt4 = 0.00 
	select @amt1= isnull(sum(CGST_AMT),0),@amt2 =isnull(sum(SGST_AMT),0),@amt3=isnull(sum(IGST_AMT),0),@amt4 =isnull(sum(COMPCESS),0) from JVMAIN 
	where entry_ty = 'j7' and (date between @SDATE and @EDATE ) 
	and RevsType = 'Tax liability on mismatched credit notes'
	and AGAINSTTY = 'Addition' and RRGST = 'Output Tax'
	Insert Into #GSTR3(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE,add_type)
				VALUES(7,7,'B','Tax liability on mismatched credit notes',0,0,@amt1,@amt2,@amt3 ,@amt4,0,0,0,0,'Add')
   --(c)Reclaim on rectification of mismatched invoices/debit notes
	set @amt1 = 0.00 
	set @amt2 = 0.00 
	set @amt3 = 0.00  
	set @amt4 = 0.00 
	select @amt1= isnull(sum(CGST_AMT),0),@amt2 =isnull(sum(SGST_AMT),0),@amt3=isnull(sum(IGST_AMT),0),@amt4 =isnull(sum(COMPCESS),0) from JVMAIN 
	where entry_ty = 'j7' and (date between @SDATE and @EDATE ) 
	and RevsType = 'Reclaim on rectification of mismatched invoices/debit notes'
	and AGAINSTTY = 'Reduction' and RRGST = 'Output Tax'
	Insert Into #GSTR3(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE,add_type)
				VALUES(7,7,'C','Reclaim on rectification of mismatched invoices/debit notes',0,0,@amt1,@amt2,@amt3 ,@amt4,0,0,0,0,'Reduce')
				
   --(d)Reclaim on rectification of mismatch credit Note
	set @amt1 = 0.00 
	set @amt2 = 0.00 
	set @amt3 = 0.00  
	set @amt4 = 0.00 
	select @amt1= isnull(sum(CGST_AMT),0),@amt2 =isnull(sum(SGST_AMT),0),@amt3=isnull(sum(IGST_AMT),0),@amt4 =isnull(sum(COMPCESS),0) from JVMAIN 
	where entry_ty = 'j7' and (date between @SDATE and @EDATE ) 
	and RevsType = 'Reclaim on rectification of mismatch credit note'
	and AGAINSTTY = 'Reduction' and RRGST = 'Output Tax'
	Insert Into #GSTR3(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE,add_type)
				VALUES(7,7,'D','Reclaim on rectification of mismatch credit note',0,0,@amt1,@amt2,@amt3 ,@amt4,0,0,0,0,'Reduce')
				
   --(E)Negative tax liability from previous tax periods
	set @amt1 = 0.00 
	set @amt2 = 0.00 
	set @amt3 = 0.00  
	set @amt4 = 0.00 
	select @amt1= isnull(sum(CGST_AMT),0),@amt2 =isnull(sum(SGST_AMT),0),@amt3=isnull(sum(IGST_AMT),0),@amt4 =isnull(sum(COMPCESS),0) from JVMAIN 
	where entry_ty = 'j7' and (date between @SDATE and @EDATE ) 
	and RevsType = 'Negative tax liability from previous tax periods'
	and AGAINSTTY = 'Reduction' and RRGST = 'Output Tax'
	Insert Into #GSTR3(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE,add_type)
				VALUES(7,7,'E','Negative tax liability from previous tax periods',0,0,@amt1,@amt2,@amt3 ,@amt4,0,0,0,0,'Reduce')
				
   --(F)Tax paid on advace in earlier tax periods and adjusted with tax on supplies made in current tax period.
	set @amt1 = 0.00 
	set @amt2 = 0.00 
	set @amt3 = 0.00  
	set @amt4 = 0.00 
	select @amt1= isnull(sum(CGST_AMT),0),@amt2 =isnull(sum(SGST_AMT),0),@amt3=isnull(sum(IGST_AMT),0),@amt4 =isnull(sum(COMPCESS),0) from JVMAIN 
	where entry_ty = 'j7' and (date between @SDATE and @EDATE ) 
	and RevsType = 'Tax paid on advance in earlier tax periods and adjusted with tax on supplies made in current tax period'
	and AGAINSTTY = 'Reduction' and RRGST = 'Output Tax'
	Insert Into #GSTR3(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE,add_type)
				VALUES(7,7,'F','Tax paid on advance in earlier tax periods and adjusted with tax on supplies made in current tax period',0,0,@amt1,@amt2,@amt3 ,@amt4,0,0,0,0,'Reduce')
				
   --(G)Input tax credit reversal/reclaim
	set @amt1 = 0.00 
	set @amt2 = 0.00 
	set @amt3 = 0.00  
	set @amt4 = 0.00 
	
	----For :-Addition
	select 
	 @amt1= isnull(sum(case when againstty = 'Addition' then +CGST_AMT else -CGST_AMT end),0)
	,@amt2 =isnull(sum(case when againstty = 'Addition' then +SGST_AMT else -SGST_AMT end),0)
	,@amt3=isnull(sum(case when againstty = 'Addition' then +IGST_AMT else -IGST_AMT end),0)
	,@amt4 =isnull(sum(case when againstty = 'Addition' then +COMPCESS else -COMPCESS end),0) 
	 from JVMAIN 
	where entry_ty = 'j7' and (date between @SDATE and @EDATE ) and RevsType = 'Input tax credit reversal/reclaim'
	and AGAINSTTY in('Addition','reduction') and RRGST = 'Input Tax'	
	
	--select @amt1,@amt2,@amt3,@amt4
	
	set @Taxtype = ''
	IF(ISNULL(@amt1,0)+ISNULL(@amt2,0) + ISNULL(@amt3,0)+ ISNULL(@amt4,0)) > 0 
	BEGIN 
		set @Taxtype = 'Add'
	END
	IF(ISNULL(@amt1,0)+ISNULL(@amt2,0) + ISNULL(@amt3,0)+ ISNULL(@amt4,0))  < 0 
	BEGIN 
		set @Taxtype = 'Reduce'
	END
	IF(ISNULL(@amt1,0)+ISNULL(@amt2,0) + ISNULL(@amt3,0)+ ISNULL(@amt4,0))  = 0 
	BEGIN 
		set @Taxtype = 'Add/Reduce'
	END
	Insert Into #GSTR3(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE,add_type)
				VALUES(7,7,'G','Input tax credit reversal/reclaim',0,0,abs(@amt1),abs(@amt2),abs(@amt3) ,abs(@amt4),0,0,0,0,@Taxtype)
   /*
	8.Total Tax liability
   */
    ---8A.On outward supplies
    ----select * into aa8a  FROM #GSTR3TBL WHERE ENTRY_TY IN('ST','S1','SR','C6','D6','GC','GD','BR','CR') AND Trantype = 'OUTWARD' AND (ISNULL(CGST_AMT,0)+ ISNULL(SGST_AMT,0) + ISNULL(IGST_AMT,0)) > 0  order by rate1
	Insert Into #GSTR3(PART,PARTSR,Section,srno,descr,rate,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)    
	Select * from (  --Added by Priyanka B on 31102017 for Bug-30661
	SELECT 8 AS PART,8 PARTSR,1 AS SECTION,'A' AS SRNO,'' AS descr,rate1,0 AS NET_AMT
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then + ISNULL(Taxableamt,0)  else - ISNULL(Taxableamt,0)  end)-ADJ_TAXABLE) AS Taxableamt
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then +ISNULL(CGST_AMT,0) else -ISNULL(CGST_AMT,0) end)-ADJ_CGST_AMT)  AS CGST_AMT
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then +ISNULL(SGST_AMT,0) else -ISNULL(SGST_AMT,0) end)-ADJ_SGST_AMT)  AS SGST_AMT
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then +ISNULL(IGST_AMT,0) else -ISNULL(IGST_AMT,0) end)-ADJ_IGST_AMT)  AS IGST_AMT
	,sum((case when ENTRY_TY IN('ST','S1','D6','GD','BR','CR') then +ISNULL(cess_amt,0)  else -ISNULL(cess_amt,0) end)-ADJ_CESS_AMT) AS cess_amt
	,0 AS TAX_PAID,0 AS CESS_PAID,0 AS INTEREST,0 AS LATE_FEE
	FROM #GSTR3TBL WHERE ENTRY_TY IN('ST','S1','SR','C6','D6','GC','GD','BR','CR','RV') AND Trantype = 'OUTWARD' AND (ISNULL(CGST_AMT,0)+ ISNULL(SGST_AMT,0) + ISNULL(IGST_AMT,0)) > 0 group by rate1 
	--order by rate1  --Commented by Priyanka B on 31102017 for Bug-30661
	)aa where (ISNULL(CGST_AMT,0)+ ISNULL(SGST_AMT,0) + ISNULL(IGST_AMT,0)) > 0    --Added by Priyanka B on 31102017 for Bug-30661
    IF NOT EXISTS(SELECT TOP 1 SRNO FROM #GSTR3 WHERE PART = 8 AND PARTSR = 8 AND SRNO = 'A' AND SECTION = 1)
    BEGIN
		Insert Into #GSTR3(PART,PARTSR,Section,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(8,8,1,'A','',0,0,0,0,0 ,0,0,0,0,0)
	END
	
    ---8B.On inward supplies attracting reverse charge
	Insert Into #GSTR3(PART,PARTSR,Section,srno,rate,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
	SELECT 8 AS PART,8 AS PARTSR,2 AS SECTION,'B' AS SRNO,PER,'' AS DESCR ,0.00 AS NET_AMT
	,sum((case when ENTRY_TY IN('UB','PT','P1','E1','C6','GC','CP','BP') then + ISNULL(Taxableamt,0)  else -ISNULL(Taxableamt,0)end)-ADJ_TAXABLE) as TAXABLEAMT
	,sum((case when ENTRY_TY IN('UB','PT','P1','E1','C6','GC','CP','BP') then +ISNULL(CGST_AMT,0) else -ISNULL(CGST_AMT,0) end-ADJ_CGST_AMT)) as CGST_AMT
	,sum((case when ENTRY_TY IN('UB','PT','P1','E1','C6','GC','CP','BP') then +ISNULL(SGST_AMT,0) else -ISNULL(SGST_AMT,0) end)-ADJ_SGST_AMT) as SGST_AMT
	,sum((case when ENTRY_TY IN('UB','PT','P1','E1','C6','GC','CP','BP') then +ISNULL(IGST_AMT,0) else -ISNULL(IGST_AMT,0) end)-ADJ_IGST_AMT) as IGST_AMT
	,sum((case when ENTRY_TY IN('UB','PT','P1','E1','C6','GC','CP','BP') then + ISNULL(cess_amt,0)  else -ISNULL(cess_amt,0) end)-ADJ_CESS_AMT) as CESS_AMT
	,0 as TAX_PAID,0 as CESS_PAID,0 as INTEREST,0 as LATE_FEE
	FROM (
	SELECT ENTRY_TY,RATE1 AS PER ,Taxableamt ,IGST_AMT ,CGST_AMT ,SGST_AMT,CESS_AMT,ADJ_TAXABLE,ADJ_CGST_AMT,ADJ_SGST_AMT,ADJ_IGST_AMT,ADJ_CESS_AMT,ADJ_GRO_AMT
	FROM #GSTR3TBL  WHERE ENTRY_TY='UB'  AND Trantype = 'INWARD' AND (ISNULL(CGST_AMT,0)+ ISNULL(SGST_AMT,0) + ISNULL(IGST_AMT,0)) > 0
	union all 
	SELECT ENTRY_TY,RATE1 AS PER ,Taxableamt ,IGSRT_AMT,CGSRT_AMT,SGSRT_AMT,CESSR_AMT,ADJ_TAXABLE,ADJ_CGSRT_AMT,ADJ_SGSRT_AMT,ADJ_IGSRT_AMT,ADJ_CESSRT_AMT,ADJ_GRO_AMT
	FROM #GSTR3TBL  WHERE ENTRY_TY IN('PT','P1','E1','PR','C6','D6','GC','GD','CP','BP') AND Trantype = 'INWARD'  
	--AND SUPP_TYPE NOT IN('UNREGISTERED','')  --Commented by Priyanka B on 13102017
	AND SUPP_TYPE NOT IN('UNREGISTERED')  --Modified by Priyanka B on 13102017
	AND (ISNULL(CGSRT_AMT,0) + ISNULL(SGSRT_AMT,0) + ISNULL(IGSRT_AMT,0))> 0 )AA WHERE ENTRY_TY IN('UB','PT','P1','E1','PR','C6','D6','GC','GD','CP','BP') 
	GROUP BY PER  ORDER BY PER 
    IF NOT EXISTS(SELECT TOP 1 SRNO FROM #GSTR3 WHERE PART = 8 AND PARTSR = 8 AND SRNO = 'B' AND SECTION = 2)
    BEGIN
		Insert Into #GSTR3(PART,PARTSR,Section,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
				VALUES(8,8,2,'B','',0,0,0,0,0 ,0,0,0,0,0)
	END
    ---8C.On account of input tax credit reversal/reclaim
		set @amt1 = 0.00 
		set @amt2 = 0.00 
		set @amt3 = 0.00  
		set @amt4 = 0.00  
		select 
		 @amt1= isnull(sum(case when AGAINSTTY = 'Addition' then +CGST_AMT else -CGST_AMT end),0)
		,@amt2 =isnull(sum(case when AGAINSTTY = 'Addition' then +SGST_AMT else -SGST_AMT end),0)
		,@amt3=isnull(sum(case when AGAINSTTY = 'Addition' then +IGST_AMT else -IGST_AMT end),0)
		,@amt4 =isnull(sum(case when AGAINSTTY = 'Addition' then +COMPCESS else -COMPCESS end),0)
		 from JVMAIN  where entry_ty = 'j7' and ( date between @SDATE and @EDATE ) and RevsType = 'On account of input tax credit reversal/reclaim'
		and RRGST = 'Input Tax' and AGAINSTTY in('Addition','Reduction')
	Insert Into #GSTR3(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
				VALUES(8,8.2,'C','On account of input tax credit reversal/reclaim',0 ,0,abs(@amt1),abs(@amt2),abs(@amt3),abs(@amt4),0,0,0,0)
    ---8D.On account of mismatch/rectification/other reasons
		set @amt1 = 0.00 
		set @amt2 = 0.00 
		set @amt3 = 0.00  
		set @amt4 = 0.00  
		select 
		@amt1= isnull(sum(case when AGAINSTTY = 'Addition' then +CGST_AMT else -CGST_AMT end),0)
		,@amt2 =isnull(sum(case when AGAINSTTY = 'Addition' then +SGST_AMT else -SGST_AMT end),0)
		,@amt3=isnull(sum(case when AGAINSTTY = 'Addition' then +IGST_AMT else -IGST_AMT end),0)
		,@amt4 =isnull(sum(case when AGAINSTTY = 'Addition' then +COMPCESS else -COMPCESS end),0) from JVMAIN
		where entry_ty = 'j7' and ( date between @SDATE and @EDATE ) and RevsType = 'On account of mismatch/rectification/other reasons'
		and RRGST = 'Input Tax' and AGAINSTTY in('Addition','Reduction')
	Insert Into #GSTR3(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
				VALUES(8,8.2,'D','On account of mismatch/rectification/other reasons',0,0,abs(@amt1),abs(@amt2),abs(@amt3) ,abs(@amt4),0,0,0,0)
	/*
		Credit of TDS and TCS
	*/			
	---(A)TDS
	Insert Into #GSTR3(PART,PARTSR,Section,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
				VALUES(9,9,1,'A','TDS',0,0,0,0,0 ,0,0,0,0,0)
	---(A)TCS
	Insert Into #GSTR3(PART,PARTSR,Section,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
				VALUES(9,9,1,'B','TCS',0,0,0,0,0 ,0,0,0,0,0)
   /*
	10.Interest liability(Interest as on .......)
	*/
	---(a)Integrated Tax
	set @amt1 = 0.00
	set @amt2 = 0.00
	set @amt3 = 0.00
	set @amt4 = 0.00
	set @amt5 = 0.00
	set @amt6 = 0.00
	set @amt7 = 0.00
	Insert Into #GSTR3(PART,PARTSR,Section,srno,descr,NET_AMT,TAXABLEAMT,IGST_AMT ,CGST_AMT,SGST_AMT,CESS_AMT,INTEREST,LATE_FEE,TAX_PAID,CESS_PAID)
				VALUES(10,10,1,'A','Integrated Tax',0,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6,@amt7,(isnull(@amt1,0)+isnull(@amt2,0)+isnull(@amt3,0)+isnull(@amt4,0)+isnull(@amt5,0)+isnull(@amt6,0)+isnull(@amt7,0)),0)
	---(b)Central Tax
	set @amt1 = 0.00
	set @amt2 = 0.00
	set @amt3 = 0.00
	set @amt4 = 0.00
	set @amt5 = 0.00
	set @amt6 = 0.00
	set @amt7 = 0.00
	Insert Into #GSTR3(PART,PARTSR,Section,srno,descr,NET_AMT,TAXABLEAMT,IGST_AMT ,CGST_AMT,SGST_AMT,CESS_AMT,INTEREST,LATE_FEE,TAX_PAID,CESS_PAID)
				VALUES(10,10,1,'B','Central Tax',0,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6,@amt7,(isnull(@amt1,0)+isnull(@amt2,0)+isnull(@amt3,0)+isnull(@amt4,0)+isnull(@amt5,0)+isnull(@amt6,0)+isnull(@amt7,0)),0)
	---(c)State/UT Tax
	set @amt1 = 0.00
	set @amt2 = 0.00
	set @amt3 = 0.00
	set @amt4 = 0.00
	set @amt5 = 0.00
	set @amt6 = 0.00
	set @amt7 = 0.00
	Insert Into #GSTR3(PART,PARTSR,Section,srno,descr,NET_AMT,TAXABLEAMT,IGST_AMT ,CGST_AMT,SGST_AMT,CESS_AMT,INTEREST,LATE_FEE,TAX_PAID,CESS_PAID)
				VALUES(10,10,1,'C','State/UT Tax',0,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6,@amt7,(isnull(@amt1,0)+isnull(@amt2,0)+isnull(@amt3,0)+isnull(@amt4,0)+isnull(@amt5,0)+isnull(@amt6,0)+isnull(@amt7,0)),0)
	---(d)Cess
	set @amt1 = 0.00
	set @amt2 = 0.00
	set @amt3 = 0.00
	set @amt4 = 0.00
	set @amt5 = 0.00
	set @amt6 = 0.00
	set @amt7 = 0.00
	Insert Into #GSTR3(PART,PARTSR,Section,srno,descr,NET_AMT,TAXABLEAMT,IGST_AMT ,CGST_AMT,SGST_AMT,CESS_AMT,INTEREST,LATE_FEE,TAX_PAID,CESS_PAID)
 					VALUES(10,10,1,'D','Cess',0,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6,@amt7,(isnull(@amt1,0)+isnull(@amt2,0)+isnull(@amt3,0)+isnull(@amt4,0)+isnull(@amt5,0)+isnull(@amt6,0)+isnull(@amt7,0)),0)
	/*
	11.Late Fee
	*/
	---Late Fee
	set @amt1 = 0.00
	set @amt2 = 0.00 
	Insert Into #GSTR3(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
 					VALUES(11,11,'A','Late Fee',0,0,@amt1,@amt2,0 ,0,0,0,0,0)

	/* 12. Tax payable and paid */
 /*Tax Payable Details */
DECLARE @IGST_PAY DECIMAL(18,2),@SGST_PAY DECIMAL(18,2),@CGST_PAY DECIMAL(18,2),@cess_PAY DECIMAL(18,2)
SET @IGST_PAY = 0
SET @CGST_PAY = 0
SET @SGST_PAY = 0
set @cess_PAY = 0
/*
SELECT @IGST_PAY= SUM(CASE WHEN ac_name ='Integrated GST Payable A/C' THEN (case when amt_ty ='cr'  then + AMOUNT else -AMOUNT  end)  ELSE 0.00 END)
		,@SGST_PAY= SUM(CASE WHEN ac_name ='State GST Payable A/C' THEN (case when amt_ty ='cr'  then + AMOUNT else -AMOUNT  end) ELSE 0.00 END)
		,@CGST_PAY= SUM(CASE WHEN ac_name ='Central GST Payable A/C' THEN (case when amt_ty ='cr'  then + AMOUNT else -AMOUNT  end) ELSE 0.00 END)
		,@cess_PAY= SUM(CASE WHEN ac_name ='Compensation Cess Payable A/C' THEN (case when amt_ty ='cr'  then + AMOUNT else -AMOUNT  end) ELSE 0.00 END) 
		FROM lac_vw 
		WHERE ac_name IN('Central GST Payable A/C','State GST Payable A/C','Integrated GST Payable A/C','Compensation Cess Payable A/C')
		and (ltrim(rtrim(entry_ty))+QUOTENAME(Tran_cd)) not in(select (ltrim(rtrim(entry_ty))+QUOTENAME(Tran_cd)) FROM lac_vw WHERE ac_name IN('Central GST Payable A/C','State GST Payable A/C','Integrated GST Payable A/C','Compensation Cess Payable A/C')
		AND entry_ty  IN('GA','GB')  and date between @SDATE and @EDATE)
		AND DATE < = @EDATE  and year(isnull(date,''))>2000 
		*/
		
		SELECT a.ac_id,a.ac_name,a.amount,a.amt_ty
				iNTO #TBL1
				FROM lac_vw a
				inner join lmain_vw b on (a.Entry_ty=b.Entry_ty and a.Tran_cd=b.tran_cd)
				WHERE a.ac_name IN('Central GST Payable A/C','State GST Payable A/C','Integrated GST Payable A/C','Compensation Cess Payable A/C') 
				and b.entry_ty not in ('GA','GB')
				AND b.DATE < = @EDATE 
		UNION ALL
			SELECT a.ac_id,a.ac_name,a.amount,a.amt_ty
				FROM jvacdet a
				inner join jvmain b on (a.Entry_ty=b.Entry_ty and a.Tran_cd=b.tran_cd)
				WHERE a.ac_name IN('Central GST Payable A/C','State GST Payable A/C','Integrated GST Payable A/C','Compensation Cess Payable A/C') 
				and b.entry_ty IN ('GA')
				AND b.U_CLDT <  @SDATE AND YEAR(b.U_CLDT) > 2000
		UNION ALL
			SELECT a.ac_id,a.ac_name,a.amount,a.amt_ty
				FROM bpacdet a
				inner join bpmain b on (a.Entry_ty=b.Entry_ty and a.Tran_cd=b.tran_cd)
				WHERE a.ac_name IN('Central GST Payable A/C','State GST Payable A/C','Integrated GST Payable A/C','Compensation Cess Payable A/C') 
				and b.entry_ty IN ('GB')
				AND b.U_CLDT <  @SDATE AND YEAR(b.U_CLDT) > 2000
			
	
		SELECT @IGST_PAY= SUM(CASE WHEN ac_name ='Integrated GST Payable A/C' THEN (case when amt_ty ='cr'  then + AMOUNT else -AMOUNT  end)  ELSE 0.00 END)
				,@SGST_PAY= SUM(CASE WHEN ac_name ='State GST Payable A/C' THEN (case when amt_ty ='cr'  then + AMOUNT else -AMOUNT  end) ELSE 0.00 END)
				,@CGST_PAY= SUM(CASE WHEN ac_name ='Central GST Payable A/C' THEN (case when amt_ty ='cr'  then + AMOUNT else -AMOUNT  end) ELSE 0.00 END)
				,@cess_PAY= SUM(CASE WHEN ac_name ='Compensation Cess Payable A/C' THEN (case when amt_ty ='cr'  then + AMOUNT else -AMOUNT  end) ELSE 0.00 END) --- Added by Suraj Kumawat Date on 19-08-2017 
				FROM #TBL1 		
/*Paid Through ITC  Details */
DECLARE @IGST_IGST DECIMAL(18,3),@IGST_CGST DECIMAL(18,3),@IGST_SGST DECIMAL(18,3),@CGST_CGST_ADJ DECIMAL(18,3),@CGST_IGST_Adj  DECIMAL(18,3),@SGST_SGST_ADJ DECIMAL(18,3),@SGST_IGST_Adj DECIMAL(18,3),@CCESS_CCESS_Adj DECIMAL(18,3)
		---IGST ADJUSTMENT 
		SET @IGST_IGST = 0.00 
		SET @IGST_CGST = 0.00 
		SET @IGST_SGST = 0.00
		--- CGST ADJUSTMENT 
		SET @CGST_CGST_ADJ =0.00 
		SET @CGST_IGST_Adj =0.00 
		--- SGST ADJUSTMENT
		SET @SGST_SGST_ADJ = 0.00 
		SET @SGST_IGST_Adj = 0.00
		set @CCESS_CCESS_Adj = 0.00 
		select @IGST_IGST =ISNULL(SUM(IGST_IGST_ADJ),0),@IGST_CGST = ISNULL(SUM(CGST_IGST_Adj),0),@IGST_SGST = ISNULL(SUM(SGST_IGST_Adj),0)
		--- CGST ADJUSTMENT 
		,@CGST_CGST_ADJ=ISNULL(SUM(CGST_CGST_ADJ),0),@CGST_IGST_Adj=ISNULL(SUM(IGST_CGST_Adj),0)
		---SGST ADJUSTMENT
		,@SGST_SGST_ADJ=ISNULL(SUM(SGST_SGST_ADJ),0),@SGST_IGST_Adj =ISNULL(SUM(IGST_SGST_Adj),0)  
		,@CCESS_CCESS_Adj=ISNULL(SUM(CCESS_CCESS_Adj),0)
		from JVMAIN    where entry_ty = 'GA'  and (date between @SDATE and @EDATE)
		
	 ---Cash Paid details 
	 DECLARE @IGST_CASHPAID DECIMAL(18,2),@SGST_CASHPAID DECIMAL(18,2),@CGST_CASHPAID DECIMAL(18,2),@CCESS_CASHPAID DECIMAL(18,2)
	  set @IGST_CASHPAID = 0
	  set @SGST_CASHPAID = 0
	  set @CGST_CASHPAID = 0
	  SET @CCESS_CASHPAID = 0
	  select @IGST_CASHPAID = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Integrated GST Payable A/C' and a.entry_ty ='GB' AND (B.u_cldt BETWEEN @SDATE AND @EDATE)
	  select @CGST_CASHPAID = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Central GST Payable A/C' and a.entry_ty ='GB' AND (B.u_cldt BETWEEN @SDATE AND @EDATE) 
	  select @SGST_CASHPAID = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='State GST Payable A/C' and a.entry_ty ='GB' AND (B.u_cldt BETWEEN @SDATE AND @EDATE) 
	  select @CCESS_CASHPAID = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Compensation Cess Payable A/C' and a.entry_ty ='GB' AND (B.u_cldt BETWEEN @SDATE AND @EDATE)
	  
	---(a)Integrated Tax
	Insert Into #GSTR3(PART,PARTSR,Section,srno,descr,NET_AMT,TAXABLEAMT,IGST_AMT ,CGST_AMT,SGST_AMT,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
				VALUES(12,12,1,'A','Integrated Tax',@IGST_PAY,@IGST_CASHPAID,@IGST_IGST,@IGST_CGST,@IGST_SGST ,0,(isnull(@IGST_CASHPAID,0)+isnull(@IGST_IGST,0)+isnull(@IGST_CGST,0)+isnull(@IGST_SGST,0)),0,0,0)
	---(b)Central Tax
	Insert Into #GSTR3(PART,PARTSR,Section,srno,descr,NET_AMT,TAXABLEAMT,IGST_AMT,CGST_AMT,SGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
				VALUES(12,12,1,'B','Central Tax',@CGST_PAY,@CGST_CASHPAID,@CGST_IGST_Adj,@CGST_CGST_ADJ,0 ,0,(isnull(@CGST_CASHPAID,0)+isnull(@CGST_IGST_Adj,0)+isnull(@CGST_CGST_ADJ,0)),0,0,0)
	---(c)State/UT Tax
	Insert Into #GSTR3(PART,PARTSR,Section,srno,descr,NET_AMT,TAXABLEAMT,IGST_AMT,CGST_AMT,SGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
				VALUES(12,12,1,'C','State/UT Tax',@SGST_PAY,@SGST_CASHPAID,@SGST_IGST_Adj,0,@SGST_SGST_ADJ ,0,(isnull(@SGST_CASHPAID,0)+isnull(@SGST_IGST_Adj,0)+isnull(@SGST_SGST_ADJ,0)),0,0,0)
	---(d)Cess
	Insert Into #GSTR3(PART,PARTSR,Section,srno,descr,NET_AMT,TAXABLEAMT,IGST_AMT,CGST_AMT,SGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
 					VALUES(12,12,1,'D','Cess',@cess_PAY,@CCESS_CASHPAID,0,0,0 ,@CCESS_CCESS_Adj,(isnull(@CCESS_CASHPAID,0)+isnull(@CCESS_CCESS_Adj,0)),0,0,0)
 					
	/* 13. Interest,Late fee and any other amount(other than tax) payable and paid */
	---(I)Interest on account of
	  DECLARE @IGST_INT DECIMAL(18,2),@SGST_INT DECIMAL(18,2),@CGST_INT DECIMAL(18,2),@IGST_FEE DECIMAL(18,2),@SGST_FEE DECIMAL(18,2),@CGST_FEE DECIMAL(18,2),@cess_INT DECIMAL(18,2)
	  DECLARE @CESS_FEE DECIMAL(18,2)  --Added by Priyanka B on 16102017
	  ----Interest Payable A/c 
	 set @IGST_INT = 0
	 set @SGST_INT = 0
	 set @CGST_INT = 0
	 set @amt1 = 0.00
	 set @amt2 = 0.00 
	 set @amt3 = 0.00 
	 set @amt4 = 0.00 
	---(a)Integrated Tax
	Insert Into #GSTR3(PART,PARTSR,Section,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
 					VALUES(13,13.1,1,'A','Integrated Tax',@amt3,@IGST_INT,0,0,0 ,0,0,0,0,0)
	---(b)Central Tax
	Insert Into #GSTR3(PART,PARTSR,Section,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
 					VALUES(13,13.1,1,'B','Central Tax',@amt1,@CGST_INT,0,0,0 ,0,0,0,0,0)
	---(c)State/UT Tax
	Insert Into #GSTR3(PART,PARTSR,Section,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
 					VALUES(13,13.1,1,'C','State/UT Tax',@amt2,@SGST_INT,0,0,0 ,0,0,0,0,0)
	---(d)Cess
	Insert Into #GSTR3(PART,PARTSR,Section,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
 					VALUES(13,13.1,1,'D','Cess',@amt4,0,0,0,0 ,0,0,0,0,0)
	---(II)Late Fee
		  ----Late fee Payable A/c
		  set @SGST_FEE = 0
		  set @CGST_FEE = 0
	 set @amt1 = 0.00
	 set @amt2 = 0.00 
	---(a)Central Tax
	Insert Into #GSTR3(PART,PARTSR,Section,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
 					VALUES(13,13.2,2,'A','Central Tax',@amt1,@CGST_FEE,0,0,0 ,0,0,0,0,0)
	---(b)State/UT Tax
	Insert Into #GSTR3(PART,PARTSR,Section,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
 					VALUES(13,13.2,2,'B','State/UT Tax',@amt2,@SGST_FEE,0,0,0 ,0,0,0,0,0)
 					
	/*
	14. Refund claimed from electronic cash ledger
	*/
	---(a)Integrated Tax
	Insert Into #GSTR3(PART,PARTSR,Section,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
				VALUES(14,14,1,'A','Integrated Tax',0,0,0,0,0 ,0,0,0,0,0)
	---(b)Central Tax
	Insert Into #GSTR3(PART,PARTSR,Section,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
				VALUES(14,14,1,'B','Central Tax',0,0,0,0,0 ,0,0,0,0,0)
	---(c)State/UT Tax
	Insert Into #GSTR3(PART,PARTSR,Section,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
				VALUES(14,14,1,'C','State/UT Tax',0,0,0,0,0 ,0,0,0,0,0)
	---(d)Cess
	Insert Into #GSTR3(PART,PARTSR,Section,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
 					VALUES(14,14,1,'D','Cess',0,0,0,0,0 ,0,0,0,0,0)
	---Bank Account Details
	Insert Into #GSTR3(PART,PARTSR,Section,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
 					VALUES(14,14.1,2,'A',' ',0,0,0,0,0 ,0,0,0,0,0)
	
	/*
	15.Debit entries in electronic cash/credit ledger for tax /interest payment [be to populated after payment of tax and submission of return]
	*/
	 ---Cash Paid details 
	  set @IGST_CASHPAID = 0
	  set @SGST_CASHPAID = 0
	  set @CGST_CASHPAID = 0
	  SET @CCESS_CASHPAID = 0
	  select @IGST_CASHPAID = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Integrated GST Payable A/C' and a.entry_ty ='GB' AND (B.u_cldt BETWEEN @SDATE AND @EDATE) 
	  select @CGST_CASHPAID = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Central GST Payable A/C' and a.entry_ty ='GB' AND (B.u_cldt BETWEEN @SDATE AND @EDATE) 
	  select @SGST_CASHPAID = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='State GST Payable A/C' and a.entry_ty ='GB' AND (B.u_cldt BETWEEN @SDATE AND @EDATE) 
	  select @CCESS_CASHPAID = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Compensation Cess Payable A/C' and a.entry_ty ='GB' AND (B.u_cldt BETWEEN @SDATE AND @EDATE)

	/*Paid Through ITC  Details */
	 ---IGST ADJUSTMENT 
		SET @IGST_IGST = 0.00 
		SET @IGST_CGST = 0.00 
		SET @IGST_SGST = 0.00
		--- CGST ADJUSTMENT 
		SET @CGST_CGST_ADJ =0.00 
		SET @CGST_IGST_Adj =0.00 
		--- SGST ADJUSTMENT
		SET @SGST_SGST_ADJ = 0.00 
		SET @SGST_IGST_Adj = 0.00
		set @CCESS_CCESS_Adj = 0.00 
		select @IGST_IGST =ISNULL(SUM(IGST_IGST_ADJ),0),@IGST_CGST = ISNULL(SUM(CGST_IGST_Adj),0),@IGST_SGST = ISNULL(SUM(SGST_IGST_Adj),0)
		--- CGST ADJUSTMENT 
		,@CGST_CGST_ADJ=ISNULL(SUM(CGST_CGST_ADJ),0),@CGST_IGST_Adj=ISNULL(SUM(IGST_CGST_Adj),0)
		---SGST ADJUSTMENT
		,@SGST_SGST_ADJ=ISNULL(SUM(SGST_SGST_ADJ),0),@SGST_IGST_Adj =ISNULL(SUM(IGST_SGST_Adj),0)  
		,@CCESS_CCESS_Adj=ISNULL(SUM(CCESS_CCESS_Adj),0)
		from JVMAIN    where entry_ty = 'GA'  and (date between @SDATE and @EDATE)

	/*Late Fee & Interest Details */ 
	   ----Interest & Fee Declaration variables 
---		  DECLARE @IGST_INT DECIMAL(18,2),@SGST_INT DECIMAL(18,2),@CGST_INT DECIMAL(18,2),@IGST_FEE DECIMAL(18,2),@SGST_FEE DECIMAL(18,2),@CGST_FEE DECIMAL(18,2)
		  ----Interest Payable A/c
		  set @IGST_INT = 0
		  set @SGST_INT = 0
		  set @CGST_INT = 0
		  set @cess_INT = 0
		  select @IGST_INT = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Integrated GST Interest Payable A/C' and a.entry_ty ='GB' AND (b.u_cldt BETWEEN @SDATE AND @EDATE)
		  select @CGST_INT = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Central GST Interest Payable A/C' and a.entry_ty ='GB' AND (b.u_cldt BETWEEN @SDATE AND @EDATE) 
		  select @SGST_INT = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='State GST Interest Payable A/C' and a.entry_ty ='GB' AND (b.u_cldt BETWEEN @SDATE AND @EDATE) 
		  select @cess_INT = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Compensation Cess Interest Payable A/C' and a.entry_ty ='GB' AND (b.u_cldt BETWEEN @SDATE AND @EDATE)
		  
		  ----Late fee Payable A/c
		  set @IGST_FEE = 0
		  set @SGST_FEE = 0
		  set @CGST_FEE = 0
		  set @CESS_FEE = 0  --Added by Priyanka B on 16102017
		  select @IGST_FEE = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Integrated GST Late Fee Payable A/C' and a.entry_ty ='GB' AND (B.u_cldt BETWEEN @SDATE AND @EDATE) 
		  select @CGST_FEE = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Central GST Late Fee Payable A/C' and a.entry_ty ='GB' AND (B.u_cldt BETWEEN @SDATE AND @EDATE) 
		  select @SGST_FEE = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='State GST Late Fee Payable A/C' and a.entry_ty ='GB' AND (b.u_cldt BETWEEN @SDATE AND @EDATE) 
		  select @CESS_FEE = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Compensation Cess Late Fee Payable A/C' and a.entry_ty ='GB' AND (b.u_cldt BETWEEN @SDATE AND @EDATE)   --Added by Priyanka B on 16102017
		  
		  --select IGST_FEE = @IGST_FEE,CGST_FEE = @CGST_FEE,SGST_FEE = @SGST_FEE,CESS_FEE = @CESS_FEE
		  
	/*Tax details (Integrated,central,state/ut,cess) */	
	---(a)Integrated Tax
	Insert Into #GSTR3(PART,PARTSR,Section,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
				VALUES(15,15,1,'A','Integrated Tax',0,@IGST_CASHPAID,@IGST_CGST,@IGST_SGST,@IGST_IGST,0,0,0,@IGST_INT,@IGST_FEE)
	---(b)Central Tax
	Insert Into #GSTR3(PART,PARTSR,Section,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
				VALUES(15,15,1,'B','Central Tax',0,@CGST_CASHPAID,@CGST_CGST_ADJ,0,@CGST_IGST_Adj ,0,0,0,@CGST_INT,@CGST_FEE)
	---(c)State/UT Tax
	Insert Into #GSTR3(PART,PARTSR,Section,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
				VALUES(15,15,1,'C','State/UT Tax',0,@SGST_CASHPAID,0,@SGST_SGST_ADJ,@SGST_IGST_Adj,0,0,0,@SGST_INT,@SGST_FEE)
	---(d)Cess
	Insert Into #GSTR3(PART,PARTSR,Section,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
 					--VALUES(15,15,1,'D','Cess',0,@CCESS_CASHPAID,0,0,0 ,@CCESS_CCESS_Adj,0,0,@cess_INT,0)  --Commented by Priyanka B on 16102017
 					VALUES(15,15,1,'D','Cess',0,@CCESS_CASHPAID,0,0,0 ,@CCESS_CCESS_Adj,0,0,@cess_INT,@CESS_FEE)  --Modified by Priyanka B on 16102017
	
	--SELECT rtrim(ltrim(cast(isnull(PARTSR,0)+isnull(SECTION,0) as varchar(10))))+rtrim(ltrim(isnull(srno,''))) as rpsection, * FROM #GSTR3 ORDER BY PART,PARTSR,SECTION,srno
	
	update #GSTR3 set rptmonth =datename(mm,@SDATE),rptyear =year(@SDATE) 	
	SELECT rtrim(ltrim(cast(isnull(PARTSR,0) as varchar(10))+cast(isnull(SECTION,0) as varchar(10))))+rtrim(ltrim(isnull(srno,''))) as rpsection, * 
	INTO #GSTR3_TMP FROM #GSTR3		ORDER BY PART,PARTSR,SECTION,srno
	
IF ISNULL(@EXPARA,'') = ''
BEGIN
	SELECT * FROM  #GSTR3_TMP 
END
ELSE  
BEGIN
----Section 3
	Select 3 as Section,
	---'Sr.No.' + '|' + 
	'Type of Turnover' + '|' + 
	'Amount'  as ColumnDetails
	Union all 
	select 3 as Section,
	---rtrim(ltrim(ISNULL(SR_NO,''))) + '|'  +
	rtrim(ltrim(isnull(descr,''))) + '|'  +
	CAST(isnull(NET_AMT,0) AS VARCHAR) 
	FROM  #GSTR3_TMP where PARTSR = 3.00
----Section 4.1
	uNION ALL 
	Select 4.1 as Section,
	'Section' + '|' + 
	'GSTIN of e-commerce operator' + '|' + 
	'Rate' + '|' + 
	'Taxable Value' + '|' + 
	'Integrated Tax' + '|' + 
	'CESS'  as ColumnDetails
	Union all 
	select 4.1 as Section,
	rtrim(ltrim(ISNULL(srno,''))) + '|'  +
	rtrim(ltrim(ISNULL(Ecom_gstin,''))) + '|'  +
	CAST(isnull(RATE,0) AS VARCHAR) + '|'  +
	CAST(isnull(TAXABLEAMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(IGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(CESS_AMT,0) AS VARCHAR) 
	FROM  #GSTR3_TMP where PARTSR = 4.1
----Section 4.2
	uNION ALL 
	Select 4.2 as Section,
	'Section' + '|' + 
	'GSTIN of e-commerce operator' + '|' + 
	'Rate' + '|' + 
	'Taxable Value' + '|' + 
	'Central Tax' + '|' + 
	'State/UT Tax' + '|' + 
	'CESS'  as ColumnDetails
	Union all 
	select 4.2 as Section,
	rtrim(ltrim(ISNULL(srno,''))) + '|'  +
	rtrim(ltrim(ISNULL(Ecom_gstin,''))) + '|'  +
	CAST(isnull(RATE,0) AS VARCHAR) + '|'  +
	CAST(isnull(TAXABLEAMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(CGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(SGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(CESS_AMT,0) AS VARCHAR)
	FROM  #GSTR3_TMP where PARTSR = 4.2
----Section 4.3
	uNION ALL 
	Select 4.31 as Section,
	'Section' + '|' + 
	'Rate' + '|' + 
	'Net Differential value' + '|' + 
	'Integrated Tax' + '|' + 
	'Central Tax' + '|' + 
	'State/UT Tax' + '|' + 
	'CESS'  as ColumnDetails
	Union all 
	select 4.31 as Section,
	rtrim(ltrim(ISNULL(srno,''))) + '|'  +
	CAST(isnull(RATE,0) AS VARCHAR) + '|'  +
	CAST(isnull(TAXABLEAMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(IGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(CGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(SGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(CESS_AMT,0) AS VARCHAR)
	FROM  #GSTR3_TMP where PARTSR = 4.31
	uNION ALL 
	Select 4.32 as Section,
	'Section' + '|' + 
	'Rate' + '|' + 
	'Net Differential value' + '|' + 
	'Integrated Tax' + '|' + 
	'Central Tax' + '|' + 
	'State/UT Tax' + '|' + 
	'CESS'  as ColumnDetails
	Union all 
	select 4.32 as Section,
	rtrim(ltrim(ISNULL(srno,''))) + '|'  +
	CAST(isnull(RATE,0) AS VARCHAR) + '|'  +
	CAST(isnull(TAXABLEAMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(IGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(CGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(SGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(CESS_AMT,0) AS VARCHAR)
	FROM  #GSTR3_TMP where PARTSR = 4.32

----Section 5.1
	uNION ALL 
	Select 5.1 as Section,
	'Section' + '|' +
	'Rate of Tax' + '|' + 
	'Taxable Value' + '|' + 
	'Integrated Tax' + '|' + 
	'Central Tax' + '|' + 
	'State/UT Tax' + '|' + 
	'CESS'  as ColumnDetails
	Union all 
	select 5.1 as Section,
	---rtrim(ltrim((case when isnull(SECTION,'1') = 1 then 'A' ELSE 'B' END ))) + '|'  +
	rtrim(ltrim((case when isnull(SECTION,'1') = 1 then 'I' ELSE 'II' END ))) + '|'  +
	CAST(isnull(RATE,0) AS VARCHAR) + '|'  +
	CAST(isnull(TAXABLEAMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(IGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(CGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(SGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(CESS_AMT,0) AS VARCHAR)
	FROM  #GSTR3_TMP where PARTSR = 5.1
----Section 5.2
	uNION ALL 
	Select 5.2 as Section,
	'Section' + '|' +
	'Rate of Tax' + '|' + 
	'Differential Taxable Value' + '|' + 
	'Integrated Tax' + '|' + 
	'Central Tax' + '|' + 
	'State/UT Tax' + '|' + 
	'CESS'  as ColumnDetails
	Union all 
	select 5.2 as Section,
	--rtrim(ltrim((case when isnull(SECTION,'1') = 1 then 'A' ELSE 'B' END ))) + '|'  +
	rtrim(ltrim((case when isnull(SECTION,'1') = 1 then 'I' ELSE 'II' END ))) + '|'  +
	CAST(isnull(RATE,0) AS VARCHAR) + '|'  +
	CAST(isnull(TAXABLEAMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(IGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(CGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(SGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(CESS_AMT,0) AS VARCHAR) 
	FROM  #GSTR3_TMP where PARTSR = 5.2
----Section 6
	uNION ALL 
	Select 6.1 as Section,
	'Section' + '|' +
	'Description' + '|' +
	'Taxable Value' + '|' + 
	'Integrated Tax' + '|' + 
	'Central Tax' + '|' + 
	'State/UT Tax' + '|' + 
	'CESS' + '|' + 
	'Integrated Tax Amount of ITC' + '|' + 
	'Central Tax Amount of ITC ' + '|' + 
	'State/UT Tax Amount of ITC' + '|' + 
	'CESS Amount of ITC'  as ColumnDetails
	Union all 
	select 6.1 as Section,
	---rtrim(ltrim((case when isnull(SECTION,'1') = 1 then 'A' ELSE 'B' END ))) + '|'  +
	rtrim(ltrim((case when isnull(SECTION,'1') = 1 then 'I' ELSE 'II' END ))) + '|'  +
	rtrim(ltrim(isnull(descr,''))) + '|'  +
	CAST(isnull(TAXABLEAMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(IGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(CGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(SGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(CESS_AMT,0) AS VARCHAR)+ '|'  +
	CAST(isnull(ITC_IGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(ITC_CGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(ITC_SGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(ITC_CESS_AMT,0) AS VARCHAR)
	
	FROM  #GSTR3_TMP where PARTSR = 6.1
----Section 7
	uNION ALL 
	Select 7 as Section,
	'Description' + '|' +
	'Add to or reduce from output liability' + '|' +
	'Integrated Tax' + '|' + 
	'Central Tax' + '|' + 
	'State/UT Tax' + '|' + 
	'CESS' + '|' as ColumnDetails
	Union all 
	select 7 as Section,
	rtrim(ltrim(isnull(descr,''))) + '|'  +
	rtrim(ltrim(isnull(add_type,''))) + '|'  +
	CAST(isnull(IGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(CGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(SGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(CESS_AMT,0) AS VARCHAR)
	FROM  #GSTR3_TMP where PARTSR = 7
----Section 8
	uNION ALL 
	Select 8 as Section,
	'Section' + '|' +
	'Rate of Tax' + '|' +
	'Taxable value' + '|' +
	'Integrated Tax' + '|' + 
	'Central Tax' + '|' + 
	'State/UT Tax' + '|' + 
	'CESS' + '|' as ColumnDetails
	Union all 
	select 8 as Section,
	rtrim(ltrim(isnull(srno,''))) + '|'  +
	rtrim(ltrim(isnull(rate,0))) + '|'  +
	rtrim(ltrim(isnull(TAXABLEAMT,0))) + '|'  +
	CAST(isnull(IGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(CGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(SGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(CESS_AMT,0) AS VARCHAR)
	FROM  #GSTR3_TMP where PARTSR = 8 and srno in('A','B')
----Section 8.2
	uNION ALL 
	Select 8.2 as Section,
	'Section' + '|' +
	'Description' + '|' +
	'Integrated Tax' + '|' + 
	'Central Tax' + '|' + 
	'State/UT Tax' + '|' + 
	'CESS' + '|' as ColumnDetails
	Union all 
	select 8.2 as Section,
	rtrim(ltrim(isnull(srno,''))) + '|'  +
	rtrim(ltrim(isnull(descr,''))) + '|'  +
	CAST(isnull(IGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(CGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(SGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(CESS_AMT,0) AS VARCHAR)
	FROM  #GSTR3_TMP where PARTSR = 8.2 and srno in('C','D')

----Section 9
	uNION ALL 
	Select 9 as Section,
	'Description' + '|' +
	'Integrated Tax' + '|' + 
	'Central Tax' + '|' + 
	'State/UT Tax'  as ColumnDetails
	Union all 
	select 9 as Section,
	rtrim(ltrim(isnull(descr,''))) + '|'  +
	CAST(isnull(IGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(CGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(SGST_AMT,0) AS VARCHAR) 
	FROM  #GSTR3_TMP where PARTSR =9 

----Section 10
	uNION ALL 
	Select 10 as Section,
	'On account of' + '|' +
	'Output liability on mismatch' + '|' + 
	'ITC claimed on mismatched invoice' + '|' + 
	'On account of other ITC reversal' + '|' + 
	'Undue excess claims or excess reduction[refer sec(50)3]' + '|' + 
	'Credit of interest on rectification of mismatch' + '|' + 
	'Interest liability carry forward' + '|' + 
	'Delay in payment of tax' + '|' + 
	'Total interest liability'  as ColumnDetails
	Union all 
	select 10 as Section,
	rtrim(ltrim(isnull(descr,''))) + '|'  +
	CAST(isnull(TAXABLEAMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(IGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(CGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(SGST_AMT,0) AS VARCHAR) +'|'+
	CAST(isnull(CESS_AMT,0) AS VARCHAR) +'|'+
	CAST(isnull(INTEREST,0) AS VARCHAR) +'|'+
	CAST(isnull(LATE_FEE,0) AS VARCHAR) +'|'+
	CAST(isnull(TAX_PAID,0) AS VARCHAR) 
	FROM  #GSTR3_TMP where PARTSR =10 
----Section 11
	uNION ALL 
	Select 11 as Section,
	'On account of' + '|' +
	'Central Tax' + '|' + 
	'State/UT Tax'  as ColumnDetails
	Union all 
	select 11 as Section,
	rtrim(ltrim(isnull(descr,''))) + '|'  +
	CAST(isnull(CGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(SGST_AMT,0) AS VARCHAR) 
	FROM  #GSTR3_TMP where PARTSR =11
----Section 12
	uNION ALL 
	Select 12 as Section,
	'Description' + '|' +
	'Tax payable' + '|' + 
	'Paid in Cash'  + '|' + 
	'Integrated Tax'  + '|' + 
	'Central Tax'  + '|' + 
	'State/UT Tax'  + '|' + 
	'Cess'  + '|' + 
	'Tax Paid'  as ColumnDetails
	Union all 
	select 12 as Section,
	rtrim(ltrim(isnull(descr,''))) + '|'  +
	CAST(isnull(NET_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(TAXABLEAMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(IGST_AMT,0) AS VARCHAR)+ '|'  +
	CAST(isnull(CGST_AMT,0) AS VARCHAR)+ '|'  + 
	CAST(isnull(SGST_AMT,0) AS VARCHAR)+ '|'  + 
	CAST(isnull(CESS_AMT,0) AS VARCHAR)+ '|'  + 
	CAST(isnull(TAX_PAID,0) AS VARCHAR)	FROM  #GSTR3_TMP where PARTSR =12
----Section 13.1
	uNION ALL 
	Select 13.1 as Section,
	'Section' + '|' +
	'Description' + '|' +
	'Amount payable' + '|' + 
	'Amount Paid' as ColumnDetails
	Union all 
	select 13.1 as Section,
	'I' + '|'  +
	rtrim(ltrim(isnull(descr,''))) + '|'  +
	CAST(isnull(NET_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(TAXABLEAMT,0) AS VARCHAR) 	FROM  #GSTR3_TMP where PARTSR =13.1
------Section 13.2
--	uNION ALL 
--	Select 13.2 as Section,
--	'Description' + '|' +
--	'Amount payable' + '|' + 
--	'Amount Paid' as ColumnDetails
	Union all 
	select 13.1 as Section,
	'II' + '|'  +
	rtrim(ltrim(isnull(descr,''))) + '|'  +
	CAST(isnull(NET_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(TAXABLEAMT,0) AS VARCHAR) 	FROM  #GSTR3_TMP where PARTSR =13.2
----Section 14
	uNION ALL 
	Select 14 as Section,
	'Description' + '|' +
	'Tax' + '|' + 
	'Interest' + '|' + 
	'Penalty' + '|' + 
	'Fee' + '|' + 
	'Other' + '|' + 
	'Debit Entry Nos.' as ColumnDetails
	Union all 
	select 14 as Section,
	rtrim(ltrim(isnull(descr,''))) + '|'  +
	CAST(isnull(NET_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(TAXABLEAMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(INTEREST,0) AS VARCHAR) + '|'  +
	CAST(isnull(IGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(CGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(SGST_AMT,0) AS VARCHAR) FROM  #GSTR3_TMP where PARTSR =14
----Section 14.1 Bank details
	uNION ALL 
	Select 14.1 as Section,
	'Description' + '|' +
	'Penalty' + '|' + 
	'Fee' + '|' + 
	'Other' + '|' + 
	'Debit Entry Nos.' as ColumnDetails
	Union all 
	select 14.1 as Section,
	rtrim(ltrim(isnull(descr,''))) + '|'  +
	CAST(isnull(IGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(CGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(SGST_AMT,0) AS VARCHAR)+ '|'  +
	CAST(isnull(CESS_AMT,0) AS VARCHAR)
	 FROM  #GSTR3_TMP where PARTSR =14.1
----Section 15
	uNION ALL 
	Select 15 as Section,
	'Description' + '|' +
	'Tax paid in cash' + '|' + 
	'Integrated Tax' + '|' + 
	'Central Tax' + '|' + 
	'State/UT Tax' + '|' + 
	'Cess' + '|' + 
	'Interest' + '|' + 
	'Late fee' as ColumnDetails
	Union all 
	select 15 as Section,
	rtrim(ltrim(isnull(descr,''))) + '|'  +
	CAST(isnull(TAXABLEAMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(IGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(CGST_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(SGST_AMT,0) AS VARCHAR)+ '|'  +
	CAST(isnull(CESS_AMT,0) AS VARCHAR) + '|'  +
	CAST(isnull(INTEREST,0) AS VARCHAR) + '|'  +
	CAST(isnull(LATE_FEE,0) AS VARCHAR) FROM  #GSTR3_TMP where PARTSR =15
END
END
GO
