IF EXISTS(SELECT XTYPE,NAME FROM SYSOBJECTS WHERE XTYPE ='p' AND NAME ='Usp_Rep_GSTR2')
BEGIN
	DROP PROCEDURE Usp_Rep_GSTR2
END
GO 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	Author : Suraj Kumawat 
	Date created : 08-06-2017	
	Modify By :  
	Modify Date : 
	 
	EXECUTE Usp_Rep_GSTR2'','','','02/01/2017','02/28/2017','','','','',0,0,'','','','','','','','','2015-2016',''
	EXECUTE Usp_Rep_GSTR2'','','','07/01/2017','07/30/2017','','','','',0,0,'','','','','','','','','2015-2016',''
	
*/

Create Procedure [dbo].[Usp_Rep_GSTR2]
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
	SELECT  PART=0,PARTSR='AAAA',SRNO= SPACE(2),H.INV_NO, H.DATE,H.INV_NO AS ORG_INVNO, H.DATE AS ORG_DATE, D .QTY,D.RATE,d.u_asseamt AS Taxableamt
	, D.CGST_AMT, D.SGST_AMT, D.IGST_AMT, D.IGST_AMT AS CESS_AMT, D.GRO_AMT, h.Net_Amt , IT.IT_NAME, cast(IT.IT_DESC as varchar(250)) as IT_DESC
	, IT.HSNCODE, gstin = ac.gstin, location = ac.state,Inputtype =space(50),descr =space(250),uqc =space(30),org_gstin=ac.gstin
	  ,D.CGST_AMT as Av_CGST_AMT, D.SGST_AMT as Av_sGST_AMT, D.IGST_AMT as Av_iGST_AMT, D.IGST_AMT AS av_CESS_AMT
	  ,rptmonth=SPACE(15),rptyear =SPACE(15) into #GSTR2 FROM  PTMAIN H INNER JOIN
						  PTITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
						  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
						  ac_mast ac ON (h.cons_id = ac.ac_id)  WHERE 1=2

	/* GSTR_VW DATA STORED IN TEMPORARY TABLE*/
	Declare @amt1 decimal(18,2),@amt2 decimal(18,2),@amt3 decimal(18,2),@amt4 decimal(18,2),@amt5 decimal(18,2),@amt6 decimal(18,2)
	SELECT * INTO #GSTR2TMP FROM GSTR2_VW WHERE (DATE BETWEEN @SDATE AND @EDATE)
	SELECT * INTO #GSTR2AMD1 FROM GSTR2_VW WHERE (AmendDate BETWEEN @SDATE AND @EDATE)
	----- Without Amend Details Table Rate wise data .....
	SELECT * INTO #GSTR2TBL FROM (
		SELECT RATE1=CGST_PER,CGST_AMT1=CGST_AMT,CGSRT_AMT1=CGSRT_AMT,sGST_AMT1=0,sGSRT_AMT1=0,IGST_AMT1=0,IGSRT_AMT1=0,Cess_amt1=0,* FROM #GSTR2TMP WHERE (CGST_AMT + CGSRT_AMT)> 0 
		UNION ALL
		SELECT RATE1=SGST_PER,CGST_AMT1=0,CGSRT_AMT1=0,sGST_AMT1=sGST_AMT,sGSRT_AMT1=sGSRT_AMT,IGST_AMT1=0,IGSRT_AMT1=0,Cess_amt1=0,* FROM #GSTR2TMP WHERE (SGST_AMT + SGSRT_AMT)> 0 
		UNION ALL 
		SELECT RATE1=IGST_PER,CGST_AMT1=0,CGSRT_AMT1=0,sGST_AMT1=0,sGSRT_AMT1=0,IGST_AMT1=IGST_AMT,IGSRT_AMT1=IGSRT_AMT,Cess_amt1=0,* FROM #GSTR2TMP WHERE (IGST_AMT + IGSRT_AMT)> 0 
		UNION ALL 
		SELECT RATE1=0,CGST_AMT1=0,CGSRT_AMT1=0,sGST_AMT1=0,sGSRT_AMT1=0,IGST_AMT1=0,IGSRT_AMT1=0,Cess_amt1=0,* FROM #GSTR2TMP  WHERE (CGST_AMT + CGSRT_AMT+SGST_AMT + SGSRT_AMT+IGST_AMT + IGSRT_AMT)= 0 )AA ORDER BY DATE,INV_NO,RATE1
		----Amend Details Table 
	  SELECT * INTO #GSTR2AMD FROM (
		SELECT RATE1=CGST_PER,CGST_AMT1=CGST_AMT,CGSRT_AMT1=CGSRT_AMT,sGST_AMT1=0,sGSRT_AMT1=0,IGST_AMT1=0,IGSRT_AMT1=0,Cess_amt1=0,* FROM #GSTR2AMD1 WHERE (CGST_AMT + CGSRT_AMT)> 0 
		UNION ALL
		SELECT RATE1=SGST_PER,CGST_AMT1=0,CGSRT_AMT1=0,sGST_AMT1=sGST_AMT,sGSRT_AMT1=sGSRT_AMT,IGST_AMT1=0,IGSRT_AMT1=0,Cess_amt1=0,* FROM #GSTR2AMD1 WHERE (SGST_AMT + SGSRT_AMT)> 0 
		UNION ALL 
		SELECT RATE1=IGST_PER,CGST_AMT1=0,CGSRT_AMT1=0,sGST_AMT1=0,sGSRT_AMT1=0,IGST_AMT1=IGST_AMT,IGSRT_AMT1=IGSRT_AMT,Cess_amt1=0,* FROM #GSTR2AMD1 WHERE (IGST_AMT + IGSRT_AMT)> 0 
		UNION ALL 
		SELECT RATE1=0,CGST_AMT1=0,CGSRT_AMT1=0,sGST_AMT1=0,sGSRT_AMT1=0,IGST_AMT1=0,IGSRT_AMT1=0,Cess_amt1=0,* FROM #GSTR2AMD1  WHERE (CGST_AMT + CGSRT_AMT+SGST_AMT + SGSRT_AMT+IGST_AMT + IGSRT_AMT)= 0 )AA  WHERE HSNCODE <> '' ORDER BY DATE,INV_NO,RATE1
		
	/*3. Inward supplies received from a registered person other than the supplies attracting reverse charge*/
	----SELECT * FROM #GSTR2TBL WHERE pinvno = '01'
	Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,net_amt,RATE,Taxableamt,
	CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,gstin,location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
	Select 3 as part,'3' as partsr ,'A' srno,pinvno,pinvdt,Net_amt,Rate1,SUM(TaxableAmt)TaxableAmt,SUM(CGST_AMT1)CGST_AMT1,SUM(SGST_AMT1)SGST_AMT1,SUM(IGST_AMT1)IGST_AMT1
	,SUM(Cess_amt1)Cess_amt1,gstin,location,gstype,Av_CGST_AMT1=SUM((Case When TRANSTATUS = 1 then CGST_AMT1 else 0.00 end))
	,Av_sGST_AMT1=SUM((Case When TRANSTATUS = 1 then sGST_AMT1 else 0.00 end)),Av_iGST_AMT1=SUM((Case When TRANSTATUS = 1 then iGST_AMT1 else 0.00 end)),av_CESS_AMT1 = SUM((Case When TRANSTATUS = 1 then CESS_AMT1 else 0.00 end))
	FROM #GSTR2TBL where ENTRY_TY IN ('E1','PT','P1') AND ST_TYPE <> 'Out of Country' and SUPP_TYPE = 'Registered' and HSNCODE <>'' And gstin not in('Unregistered','') 
	AND (CGSRT_AMT1 + SGSRT_AMT1 + IGSRT_AMT1) = 0 AND LineRule = 'Taxable'
	GROUP BY pinvno,pinvdt,Net_amt,Rate1,gstin,location,gstype ORDER BY pinvdt,pinvno,Rate1
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '3' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(3,'3','A','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
	END
	/* 4.Inward supplies on which tax is to be paid on reverse charge*/
	/* 4A. Inward supplies received from a registered supplier (attracting reverse charge) */
	Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,net_amt,RATE,Taxableamt,
	CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,gstin,location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
	Select 4 as part,'4A' as partsr ,'A' srno,pinvno,pinvdt,Net_amt,Rate1,SUM(TaxableAmt)TaxableAmt,SUM(CGSRT_AMT1)CGSRT_AMT1,SUM(SGSRT_AMT1)SGSRT_AMT1,SUM(IGSRT_AMT1)IGSRT_AMT1
	,0.00 CessRtAmt,gstin,location,gstype,Av_CGST_AMT1=SUM((Case When TRANSTATUS = 1 then CGSRT_AMT1 else 0.00 end))
	,Av_sGST_AMT1=SUM((Case When TRANSTATUS = 1 then SGSRT_AMT1 else 0.00 end)),Av_iGST_AMT1=SUM((Case When TRANSTATUS = 1 then IGSRT_AMT1 else 0.00 end)),av_CESS_AMT1 = 0.00 
	FROM #GSTR2TBL where ENTRY_TY IN ('E1','PT','P1') AND ST_TYPE <> 'Out of Country' and SUPP_TYPE = 'Registered' and HSNCODE <>'' And gstin not in('Unregistered','') AND LineRule = 'Taxable'
	AND (CGSRT_AMT1 + SGSRT_AMT1 + IGSRT_AMT1) > 0 GROUP BY pinvno,pinvdt,Net_amt,Rate1,gstin,location,gstype ORDER BY pinvdt,pinvno,Rate1
	
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '4A' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(4,'4A','A','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
	END
	/*4B. Inward supplies received from an unregistered supplier*/
	Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,net_amt,RATE,Taxableamt,
	CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,gstin,location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
	Select 4 as part,'4B' as partsr ,'A' srno,pinvno,pinvdt,Net_amt,Rate1,SUM(TaxableAmt)TaxableAmt,SUM(CGSRT_AMT1)CGSRT_AMT1,SUM(SGSRT_AMT1)SGSRT_AMT1,SUM(IGSRT_AMT1)IGSRT_AMT1
	,0.00 CessRtAmt,gstin,location,gstype,Av_CGST_AMT1=SUM((Case When TRANSTATUS = 1 then CGSRT_AMT1 else 0.00 end))
	,Av_sGST_AMT1=SUM((Case When TRANSTATUS = 1 then SGSRT_AMT1 else 0.00 end)),Av_iGST_AMT1=SUM((Case When TRANSTATUS = 1 then IGSRT_AMT1 else 0.00 end)),av_CESS_AMT1 = 0.00 
	FROM #GSTR2TBL where ENTRY_TY IN ('E1','PT','P1') AND ST_TYPE <> 'Out of Country' and SUPP_TYPE = 'Unregistered' and HSNCODE <>'' And gstin in('Unregistered','') AND LineRule = 'Taxable'
	AND (CGSRT_AMT1 + SGSRT_AMT1 + IGSRT_AMT1) > 0 GROUP BY pinvno,pinvdt,Net_amt,Rate1,gstin,location,gstype ORDER BY pinvdt,Rate1
	
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '4B' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(4,'4B','A','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
	END
	/*4C. Import of service*/
	Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,net_amt,RATE,Taxableamt,
	CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,gstin,location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
	Select 4 as part,'4C' as partsr ,'A' srno,pinvno,pinvdt,Net_amt,Rate1,SUM(TaxableAmt)TaxableAmt
	,SUM(CGST_AMT1)CGST_AMT1,SUM(SGST_AMT1)SGST_AMT1,SUM(IGST_AMT1)IGST_AMT1
	,0.00 CessRtAmt,gstin,location,gstype,Av_CGST_AMT1=SUM((Case When TRANSTATUS = 1 then CGST_AMT1 else 0.00 end))
	,Av_sGST_AMT1=SUM((Case When TRANSTATUS = 1 then SGST_AMT1 else 0.00 end)),Av_iGST_AMT1=SUM((Case When TRANSTATUS = 1 then IGST_AMT1 else 0.00 end)),av_CESS_AMT1 = 0.00 
	FROM #GSTR2TBL where ENTRY_TY ='E1' AND ST_TYPE IN('Out of Country','Interstate','Intrastate') and SUPP_TYPE in('Import','SEZ') and HSNCODE <>'' AND LineRule = 'Taxable' ----And gstin in('Unregistered','')
	GROUP BY pinvno,pinvdt,Net_amt,Rate1,gstin,location,gstype ORDER BY pinvdt,pinvno,Rate1
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '4C' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(4,'4C','A','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
	END
	/*5. Inputs/Capital goods received from Overseas or from SEZ units on a Bill of Entry*/
	 -----5A. Imports
	Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,net_amt,RATE,Taxableamt,
	CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,gstin,location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
	Select 5 as part,'5A' as partsr ,'A' srno,pinvno,pinvdt,Net_amt,Rate1,SUM(TaxableAmt)TaxableAmt
	,SUM(CGST_AMT1)CGST_AMT1,SUM(SGST_AMT1)SGST_AMT1,SUM(IGST_AMT1)IGST_AMT1
	,0.00 CessRtAmt,gstin,location,gstype,Av_CGST_AMT1=SUM((Case When TRANSTATUS = 1 then CGST_AMT1 else 0.00 end))
	,Av_sGST_AMT1=SUM((Case When TRANSTATUS = 1 then SGST_AMT1 else 0.00 end)),Av_iGST_AMT1=SUM((Case When TRANSTATUS = 1 then IGST_AMT1 else 0.00 end))
	,av_CESS_AMT1 = 0.00 
	FROM #GSTR2TBL where ENTRY_TY IN('PT','P1') AND ST_TYPE IN('Out of Country','Interstate','Intrastate') and SUPP_TYPE ='Import' and HSNCODE <>'' AND LineRule = 'Taxable'
	GROUP BY pinvno,pinvdt,Net_amt,Rate1,gstin,location,gstype ORDER BY pinvdt,pinvno,Rate1

	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '5A' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(5,'5A','A','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
	END
	-----5B. Received from SEZ
	Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,net_amt,RATE,Taxableamt,
	CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,gstin,location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
	Select 5 as part,'5B' as partsr ,'A' srno,pinvno,pinvdt,Net_amt,Rate1,SUM(TaxableAmt)TaxableAmt
	,SUM(CGST_AMT1)CGST_AMT1,SUM(SGST_AMT1)SGST_AMT1,SUM(IGST_AMT1)IGST_AMT1
	,0.00 CessRtAmt,gstin,location,gstype,Av_CGST_AMT1=SUM((Case When TRANSTATUS = 1 then CGST_AMT1 else 0.00 end))
	,Av_sGST_AMT1=SUM((Case When TRANSTATUS = 1 then SGST_AMT1 else 0.00 end)),Av_iGST_AMT1=SUM((Case When TRANSTATUS = 1 then IGST_AMT1 else 0.00 end))
	,av_CESS_AMT1 = 0.00 
	FROM #GSTR2TBL where ENTRY_TY IN('PT','P1') AND ST_TYPE IN('Out of Country','Interstate','Intrastate') and SUPP_TYPE ='SEZ' and HSNCODE <>'' AND LineRule = 'Taxable'
	GROUP BY pinvno,pinvdt,Net_amt,Rate1,gstin,location,gstype,net_amt ORDER BY pinvdt,pinvno,Rate1
	
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '5B' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(5,'5B','A','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
	END
	----- Port code +No of BE=13 digits (This section will be use for Details section in report)
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '5B' AND SRNO ='B')
	BEGIN
		SET @amt1 = 0
		SET @amt2 = 0
		SET @amt3 = 0
		SET @amt4 = 0
		SET @amt5 = 0
	    SELECT @AMT1= ISNULL(SUM(Taxableamt),0),@amt2 =ISNULL(SUM(IGST_AMT),0),@amt3 =ISNULL(SUM(CESS_AMT),0),@amt4= sum(Av_iGST_AMT),@amt5= sum(av_CESS_AMT)   FROM #GSTR2 WHERE PARTSR = '5B' AND SRNO ='A'
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(5,'5B','B','','','','',0,0,@amt1,0,0,@amt2,@amt3,0,'','','','',0,0,@amt4,@amt5)
	END
	/*6. Amendments to details of inward supplies furnished in returns for earlier tax periods in Tables 3, 4 and 5 
		[including debit notes/credit notes issued and their subsequent amendments]*/
		SELECT *  into #gstr2amd3 FROM (
		-----Section 3a
		SELECT * FROM #GSTR2AMD where ENTRY_TY IN ('E1','PT','P1') AND ST_TYPE <> 'Out of Country' and SUPP_TYPE = 'Registered' and HSNCODE <>'' And gstin not in('Unregistered','') 
		AND (CGSRT_AMT1 + SGSRT_AMT1 + IGSRT_AMT1) = 0 AND LineRule = 'Taxable'
		----Section 4a
		UNION ALL 
		SELECT * FROM #GSTR2AMD where ENTRY_TY IN ('E1','PT','P1') AND ST_TYPE <> 'Out of Country' and SUPP_TYPE = 'Registered' and HSNCODE <>'' And gstin not in('Unregistered','') AND LineRule = 'Taxable'
		AND (CGSRT_AMT1 + SGSRT_AMT1 + IGSRT_AMT1) > 0 		
		----Section 4b
		UNION ALL 
	    SELECT  * 	FROM #GSTR2AMD where ENTRY_TY IN ('E1','PT','P1') AND ST_TYPE <> 'Out of Country' and SUPP_TYPE = 'Unregistered' and HSNCODE <>'' And gstin in('Unregistered','') AND LineRule = 'Taxable'AND (CGSRT_AMT1 + SGSRT_AMT1 + IGSRT_AMT1) > 0
	   ---- Section 4c
		UNION ALL 
		SELECT * FROM #GSTR2AMD where ENTRY_TY ='E1' AND ST_TYPE IN('Out of Country','Interstate','Intrastate') and SUPP_TYPE in('Import','SEZ') and HSNCODE <>'' AND LineRule = 'Taxable' )AA

	 ----6A. Supplies other than import of goods or goods received from SEZ [Information furnished in Table 3 and 4 of earlier returns]-If details furnished earlier were incorrect
	Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,net_amt,RATE,Taxableamt,
	CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,gstin,location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,ORG_INVNO,ORG_DATE,org_gstin)
	Select 6 as part,'6A' as partsr ,'A' srno,pinvno,pinvdt,Net_amt,Rate1,SUM(TaxableAmt)TaxableAmt
	,SUM(CGST_AMT1)CGST_AMT1,SUM(SGST_AMT1)SGST_AMT1,SUM(IGST_AMT1)IGST_AMT1
	,0.00 CessRtAmt,gstin,location,gstype,Av_CGST_AMT1=SUM((Case When TRANSTATUS = 1 then CGST_AMT1 else 0.00 end))
	,Av_sGST_AMT1=SUM((Case When TRANSTATUS = 1 then SGST_AMT1 else 0.00 end)),Av_iGST_AMT1=SUM((Case When TRANSTATUS = 1 then IGST_AMT1 else 0.00 end))
	,av_CESS_AMT1 =SUM((Case When TRANSTATUS = 1 then Cess_amt1 else 0.00 end)),ORG_INVNO,ORG_DATE,gstin
	FROM #gstr2amd3 where ENTRY_TY IN('PT','P1','E1')  and HSNCODE <>'' AND LineRule = 'Taxable'
	GROUP BY pinvno,pinvdt,Net_amt,Rate1,gstin,location,gstype,net_amt,ORG_INVNO,ORG_DATE ORDER BY pinvdt,pinvno,Rate1
	
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '6A' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(6,'6A','A','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
	END

	/*6B. Supplies by way of import of goods or goods received from SEZ [Information furnished in Table 5 of earlier returns]-If details furnished earlier were incorrect*/	
	Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,net_amt,RATE,Taxableamt,
	CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,gstin,location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,ORG_INVNO,ORG_DATE,org_gstin)
	Select 6 as part,'6B' as partsr ,'A' srno,pinvno,pinvdt,Net_amt,Rate1,SUM(TaxableAmt)TaxableAmt
	,SUM(CGST_AMT1)CGST_AMT1,SUM(SGST_AMT1)SGST_AMT1,SUM(IGST_AMT1)IGST_AMT1
	,0.00 CessRtAmt,gstin,location,gstype,Av_CGST_AMT1=SUM((Case When TRANSTATUS = 1 then CGST_AMT1 else 0.00 end))
	,Av_sGST_AMT1=SUM((Case When TRANSTATUS = 1 then SGST_AMT1 else 0.00 end)),Av_iGST_AMT1=SUM((Case When TRANSTATUS = 1 then IGST_AMT1 else 0.00 end))
	,av_CESS_AMT1 =SUM((Case When TRANSTATUS = 1 then Cess_amt1 else 0.00 end)),ORG_INVNO,ORG_DATE,gstin
	FROM #GSTR2AMD where ENTRY_TY IN('PT','P1') AND ST_TYPE IN('Out of Country','Interstate','Intrastate') and SUPP_TYPE IN('SEZ','IMPORT') and HSNCODE <>'' AND LineRule = 'Taxable'
	GROUP BY pinvno,pinvdt,Net_amt,Rate1,gstin,location,gstype,net_amt,ORG_INVNO,ORG_DATE ORDER BY pinvdt,pinvno,Rate1
	
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '6B' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(6,'6B','A','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
	END
	/*6C. Debit Notes/Credit Notes [original]*/
	Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,net_amt,RATE,Taxableamt,
	CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,gstin,location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,ORG_INVNO,ORG_DATE,org_gstin)
	Select 6 as part,'6C' as partsr ,'A' srno,pinvno,pinvdt,Net_amt,Rate1,SUM(TaxableAmt)TaxableAmt
	,SUM(CGST_AMT1)CGST_AMT1,SUM(SGST_AMT1)SGST_AMT1,SUM(IGST_AMT1)IGST_AMT1
	,0.00 CessRtAmt,gstin,location,gstype,Av_CGST_AMT1=SUM((Case When TRANSTATUS = 1 then CGST_AMT1 else 0.00 end))
	,Av_sGST_AMT1=SUM((Case When TRANSTATUS = 1 then SGST_AMT1 else 0.00 end)),Av_iGST_AMT1=SUM((Case When TRANSTATUS = 1 then IGST_AMT1 else 0.00 end))
	,av_CESS_AMT1 = 0.00 ,ORG_INVNO,ORG_DATE,gstin
	FROM #GSTR2TBL where ENTRY_TY IN('C6','D6','GC','GD') and HSNCODE <>'' AND LineRule = 'Taxable'  and supp_type <> 'Compounding'
	GROUP BY pinvno,pinvdt,Net_amt,Rate1,gstin,location,gstype,net_amt,ORG_INVNO,ORG_DATE ORDER BY pinvdt,pinvno,Rate1
	
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '6C' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(6,'6C','A','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
	END
	/*6D. Debit Notes/ Credit Notes [amendment of debit notes/credit notes furnished in earlier tax periods]*/
	Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,net_amt,RATE,Taxableamt,
	CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,gstin,location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,ORG_INVNO,ORG_DATE,org_gstin)
	Select 6 as part,'6D' as partsr ,'A' srno,pinvno,pinvdt,Net_amt,Rate1,SUM(TaxableAmt)TaxableAmt
	,SUM(CGST_AMT1)CGST_AMT1,SUM(SGST_AMT1)SGST_AMT1,SUM(IGST_AMT1)IGST_AMT1
	,0.00 CessRtAmt,gstin,location,gstype,Av_CGST_AMT1=SUM((Case When TRANSTATUS = 1 then CGST_AMT1 else 0.00 end))
	,Av_sGST_AMT1=SUM((Case When TRANSTATUS = 1 then SGST_AMT1 else 0.00 end)),Av_iGST_AMT1=SUM((Case When TRANSTATUS = 1 then IGST_AMT1 else 0.00 end))
	,av_CESS_AMT1 = 0.00 ,ORG_INVNO,ORG_DATE,gstin
	FROM #GSTR2AMD where ENTRY_TY IN('C6','D6','GC','GD') and HSNCODE <>'' AND LineRule = 'Taxable' and supp_type <> 'Compounding'
	GROUP BY pinvno,pinvdt,Net_amt,Rate1,gstin,location,gstype,net_amt,ORG_INVNO,ORG_DATE ORDER BY pinvdt,pinvno,Rate1
	
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '6D' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(6,'6D','A','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
	END
	/*7. Supplies received from composition taxable person and other exempt/Nil rated/Non GST supplies received*/
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '7' AND SRNO ='A')
	BEGIN
		SET @amt1 = 0
		SET @amt2 = 0
		SET @amt3 = 0
		SET @amt3 = 0
		
		SELECT @amt1 = sum(case when supp_type = 'Compounding' and hsncode <> '' then  GRO_AMT else 0.00  end)
		 ,@amt2 = sum(case when LineRule = 'Exempted' and hsncode <> '' and supp_type <> 'Compounding' then  GRO_AMT else 0.00  end)
		 ,@amt3 =sum (case when LineRule = 'Nill Rated' and hsncode <> '' and supp_type <> 'Compounding' then  GRO_AMT else 0.00  end )
		 ,@amt4 = sum(case when hsncode = '' and supp_type <> 'Compounding' then  GRO_AMT else 0.00 end)
		 FROM #GSTR2tbl WHERE st_type ='Interstate' 
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(7,'7','A','','','','',0,0,0,@amt1,@amt2,@amt3,@amt4,0,'','','',0,0,0,0,'7A. Inter-State supplies')
	END
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '7' AND SRNO ='B')
	BEGIN
		SET @amt1 = 0
		SET @amt2 = 0
		SET @amt3 = 0
		SET @amt3 = 0
		SELECT @amt1 = sum(case when supp_type = 'Compounding' and hsncode <> '' then  GRO_AMT else 0.00  end)
		 ,@amt2 = sum(case when LineRule = 'Exempted' and hsncode <> '' and supp_type <> 'Compounding' then  GRO_AMT else 0.00  end)
		 ,@amt3 =sum (case when LineRule = 'Nill Rated' and hsncode <> '' and supp_type <> 'Compounding' then  GRO_AMT else 0.00  end )
		 ,@amt4 = sum(case when hsncode = '' and supp_type <> 'Compounding' then  GRO_AMT else 0.00 end)
		 FROM #GSTR2tbl WHERE st_type ='Intrastate' 
	
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(7,'7','B','','','','',0,0,0,@amt1,@amt2,@amt3,@amt4,0,'','','',0,0,0,0,'7B. Intra-state supplies')
	END
	-----8. ISD credit received 
	----8A. ISD Invoice
	Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,net_amt,RATE,Taxableamt,
	CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,gstin,location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
	Select 8 as part,'8A' as partsr ,'A' srno,pinvno,pinvdt,0.00 as Net_amt,0 as Rate1,SUM(TaxableAmt) as TaxableAmt,SUM(CGST_AMT1)as CGST_AMT1,SUM(SGST_AMT1) as SGSRT_AMT1,SUM(IGST_AMT1)as IGST_AMT1
	,0.00 CessRtAmt,'' as gstin,'' as location,'' as gstype,Av_CGST_AMT1=SUM((Case When TRANSTATUS = 1 then CGST_AMT1 else 0.00 end))
	,Av_sGST_AMT1=SUM((Case When TRANSTATUS = 1 then SGST_AMT1 else 0.00 end)),Av_iGST_AMT1=SUM((Case When TRANSTATUS = 1 then IGST_AMT1 else 0.00 end)),av_CESS_AMT1 = 0.00 
	FROM #GSTR2TBL where ENTRY_TY ='J6'
	GROUP BY pinvno,pinvdt ORDER BY pinvdt,pinvno

	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '8A' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(8,'8A','A','','','','',0,0,0,0,0,0,0,0,'','','',0,0,0,0,'')
	END
	---8B. ISD Credit Note
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '8B' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(8,'8B','A','','','','',0,0,0,0,0,0,0,0,'','','',0,0,0,0,'')
	END
	----9. TDS and TCS Credit received 
	----9A. TDS
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '9A' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(9,'9A','A','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
	END
	---9B. TCS
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '9B' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(9,'9B','A','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
	END
	----10. Consolidated Statement of Advances paid/Advance adjusted on account of receipt of supply
		-----10A. Advance amount paid for reverse charge supplies in the tax period (tax amount to be added to output tax liability)
		 SELECT * INTO #BkPayDet FROM 
			(SELECT ENTRY_TY,TRAN_CD,DATE,DATE_ALL ,ENTRY_ALL ,MAIN_TRAN  FROM PTMALL 
			UNION ALL 
			SELECT ENTRY_TY,TRAN_CD,DATE,DATE_ALL ,ENTRY_ALL ,MAIN_TRAN FROM EPMALL )AA WHERE AA.entry_ty IN('PT','P1','E1') and AA.date between @SDATE and @EDATE 
		---10A (1). Intra-State supplies (Rate Wise)
  			Insert Into #GSTR2(PART,PARTSR,SRNO,gstin,inv_no,date,location,gro_amt,rate,taxableamt
			,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt)
			 select 10 AS PART ,'10AA' AS PARTSR,'A' AS SRNO,'' as gstin, '' as inv_no, '' as date,location,0.00 AS net_amt 
			,rate1,taxableamt = sum(taxableamt),CGST_AMT = sum(CGST_AMT1),SGST_AMT = sum(SGST_AMT1),IGST_AMT = sum(IGST_AMT1),cess_amt = sum(cess_amt1)
			from #GSTR2TBL where Entry_ty in('BP','CP') and (SGSRT_AMT + CGSRT_AMT+IGSRT_AMT) > 0  and st_type ='Intrastate' AND (ENTRY_TY+CAST(TRAN_CD AS VARCHAR)) NOT IN(SELECT (ENTRY_ALL+CAST(MAIN_TRAN AS VARCHAR))  FROM #BkpayDet where DATE BETWEEN @SDATE AND @EDATE )
			group by rate1,location order by Rate1,location
		

	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '10AA' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(10,'10AA','A','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
	END
	----10A (2). Inter-State Supplies (Rate Wise)
		Insert Into #GSTR2(PART,PARTSR,SRNO,gstin,inv_no,date,location,gro_amt,rate,taxableamt
		,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt)
		 select 10 AS PART ,'10AB' AS PARTSR,'A' AS SRNO,'' as gstin, '' as inv_no, '' as date,location,0.00 AS net_amt 
		,rate1,taxableamt = sum(taxableamt),CGST_AMT = sum(CGST_AMT1),SGST_AMT = sum(SGST_AMT1),IGST_AMT = sum(IGST_AMT1),cess_amt = sum(cess_amt1)
		from #GSTR2TBL where Entry_ty in('BP','CP')  and (SGSRT_AMT + CGSRT_AMT+IGSRT_AMT) > 0 and st_type ='Interstate' AND (ENTRY_TY+CAST(TRAN_CD AS VARCHAR)) NOT IN(SELECT (ENTRY_ALL+CAST(MAIN_TRAN AS VARCHAR))  FROM #BkpayDet where DATE BETWEEN @SDATE AND @EDATE )
		group by rate1,location order by Rate1,location
	
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '10AB' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(10,'10AB','A','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
	END
	---10B. Advance amount on which tax was paid in earlier period but invoice has been received in the current period [ reflected in Table 4 above] 	
	---10B (1). Intra-State Supplies (Rate Wise)
		Insert Into #GSTR2(PART,PARTSR,SRNO,gstin,inv_no,date,location,gro_amt,rate,taxableamt
		,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt)
		 select 10 AS PART ,'10BA' AS PARTSR,'A' AS SRNO,'' as gstin, '' as inv_no, '' as date,location,0.00 AS net_amt 
		,rate1,taxableamt = sum(taxableamt),CGST_AMT = sum(CGST_AMT1),SGST_AMT = sum(SGST_AMT1),IGST_AMT = sum(IGST_AMT1),cess_amt = sum(cess_amt1)
		from #GSTR2TBL where Entry_ty in('BP','CP') and (SGSRT_AMT + CGSRT_AMT+IGSRT_AMT) > 0  and st_type ='Intrastate' AND (ENTRY_TY+CAST(TRAN_CD AS VARCHAR)) NOT IN(SELECT (ENTRY_ALL+CAST(MAIN_TRAN AS VARCHAR))  FROM #BkpayDet where Date_all < @sdate AND ENTRY_ALL IN('BR','CR') and DATE BETWEEN @SDATE AND @EDATE )
		group by rate1,location order by Rate1,location
	
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '10BA' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(10,'10BA','A','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
	END
	-----10B (2). Intra-State Supplies (Rate Wise)
		Insert Into #GSTR2(PART,PARTSR,SRNO,gstin,inv_no,date,location,gro_amt,rate,taxableamt
		,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt)
		 select 10 AS PART ,'10BB' AS PARTSR,'B' AS SRNO,'' as gstin, '' as inv_no, '' as date,location,0.00 AS net_amt 
		,rate1,taxableamt = sum(taxableamt),CGST_AMT = sum(CGST_AMT1),SGST_AMT = sum(SGST_AMT1),IGST_AMT = sum(IGST_AMT1),cess_amt = sum(cess_amt1)
		from #GSTR2TBL where Entry_ty in('BP','CP') and (SGSRT_AMT + CGSRT_AMT+IGSRT_AMT) > 0  and st_type ='Interstate' AND (ENTRY_TY+CAST(TRAN_CD AS VARCHAR)) NOT IN(SELECT (ENTRY_ALL+CAST(MAIN_TRAN AS VARCHAR))  FROM #BkpayDet where Date_all < @sdate AND ENTRY_ALL IN('BR','CR') and DATE BETWEEN @SDATE AND @EDATE )
		group by rate1,location order by Rate1,location
	
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '10BB' AND SRNO ='B')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(10,'10BB','B','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
	END
	----II Amendments of information furnished in Table No. 10 (I) in an earlier month [Furnish revised information]
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '10C' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(10,'10C','A','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
	END
	-----11. Input Tax Credit Reversal / Reclaim 		
		---(a) Amount in terms of rule 2(2) of ITC Rules
		set @amt1 = 0.00 
		set @amt2 = 0.00 
		set @amt3 = 0.00  
		select @amt1= isnull(sum(CGST_AMT),0),@amt2 =isnull(sum(SGST_AMT),0),@amt3=isnull(sum(IGST_AMT),0) from JVMAIN 
		where entry_ty = 'j7' and ( date between @SDATE and @EDATE ) and RevsType = 'Amount in terms of rule 2(2) of ITC Rules'
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(11,'11A','A','','','','',0,0,0,@amt1,@amt2,@amt3,0,0,'','','To be added',0,0,0,0,'(a) Amount in terms of rule 2(2) of ITC Rules')
		---(b) Amount in terms of rule 4(1)(j)(ii) of ITC Rules
		set @amt1 = 0.00 
		set @amt2 = 0.00 
		set @amt3 = 0.00  
		select @amt1= isnull(sum(CGST_AMT),0),@amt2 =isnull(sum(SGST_AMT),0),@amt3=isnull(sum(IGST_AMT),0) from JVMAIN 
		where entry_ty = 'j7' and ( date between @SDATE and @EDATE ) and RevsType = 'Amount in terms of rule 4(1)(j)(ii) of ITC Rules'
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(11,'11A','B','','','','',0,0,0,@amt1,@amt2,@amt3,0,0,'','','To be added',0,0,0,0,'(b) Amount in terms of rule 4(1)(j)(ii) of ITC Rules')
		---(c) Amount in terms of rule 7 (1) (m) of ITC 
		set @amt1 = 0.00 
		set @amt2 = 0.00 
		set @amt3 = 0.00  
		select @amt1= isnull(sum(CGST_AMT),0),@amt2 =isnull(sum(SGST_AMT),0),@amt3=isnull(sum(IGST_AMT),0) from JVMAIN 
		where entry_ty = 'j7' and ( date between @SDATE and @EDATE ) and RevsType = 'Amount in terms of rule 7 (1) (m) of ITC'
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(11,'11A','C','','','','',0,0,0,@amt1,@amt2,@amt3,0,0,'','','To be added',0,0,0,0,'(c) Amount in terms of rule 7 (1) (m) of ITC ')
		---(d) Amount in terms of rule 8(1) (h) of the ITC Rules
		set @amt1 = 0.00 
		set @amt2 = 0.00 
		set @amt3 = 0.00  
		select @amt1= isnull(sum(CGST_AMT),0),@amt2 =isnull(sum(SGST_AMT),0),@amt3=isnull(sum(IGST_AMT),0) from JVMAIN 
		where entry_ty = 'j7' and ( date between @SDATE and @EDATE ) and RevsType = 'Amount in terms of rule 8(1) (h) of the ITC Rules'
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(11,'11A','D','','','','',0,0,0,@amt1,@amt2,@amt3,0,0,'','','To be added',0,0,0,0,'(d) Amount in terms of rule 8(1) (h) of the ITC Rules')
		---(e) Amount in terms of rule 7 (2)(a) of ITC Rules
		set @amt1 = 0.00 
		set @amt2 = 0.00 
		set @amt3 = 0.00  
		select @amt1= isnull(sum(CGST_AMT),0),@amt2 =isnull(sum(SGST_AMT),0),@amt3=isnull(sum(IGST_AMT),0) from JVMAIN 
		where entry_ty = 'j7' and ( date between @SDATE and @EDATE ) and RevsType = 'Amount in terms of rule 7 (2)(a) of ITC Rules'
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(11,'11A','E','','','','',0,0,0,@amt1 ,@amt2,@amt4,0,0,'','','To be added',0,0,0,0,'(e) Amount in terms of rule 7 (2)(a) of ITC Rules')
		---(f) Amount in terms of rule 7(2)(b) of ITC Rules
		set @amt1 = 0.00 
		set @amt2 = 0.00 
		set @amt3 = 0.00  
		select @amt1= isnull(sum(CGST_AMT),0),@amt2 =isnull(sum(SGST_AMT),0),@amt3=isnull(sum(IGST_AMT),0) from JVMAIN 
		where entry_ty = 'j7' and ( date between @SDATE and @EDATE ) and RevsType = 'Amount in terms of rule 7(2)(b) of ITC Rules'
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(11,'11A','F','','','','',0,0,0,@amt1,@amt2,@amt3,0,0,'','','To be reduced',0,0,0,0,'(f) Amount in terms of rule 7(2)(b) of ITC Rules')
		---(g) On account of amount paid subsequent to reversal of ITC
		set @amt1 = 0.00 
		set @amt2 = 0.00 
		set @amt3 = 0.00  
		select @amt1= isnull(sum(CGST_AMT),0),@amt2 =isnull(sum(SGST_AMT),0),@amt3=isnull(sum(IGST_AMT),0) from JVMAIN 
		where entry_ty = 'j7' and ( date between @SDATE and @EDATE ) and RevsType = 'On account of amount paid subsequent to reversal of ITC'
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(11,'11A','G','','','','',0,0,0,@amt1,@amt2,@amt3,0,0,'','','To be reduced',0,0,0,0,'(g) On account of amount paid subsequent to reversal of ITC')
		----(h) Any other liability (Specify)
		set @amt1 = 0.00 
		set @amt2 = 0.00 
		set @amt3 = 0.00  
		select @amt1= isnull(sum(CGST_AMT),0),@amt2 =isnull(sum(SGST_AMT),0),@amt3=isnull(sum(IGST_AMT),0) from JVMAIN 
		where entry_ty = 'j7' and ( date between @SDATE and @EDATE ) and RevsType = 'Any other liability (Specify)'
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(11,'11A','H','','','','',0,0,0,@amt1,@amt2,@amt3,0,0,'','','',0,0,0,0,'(h) Any other liability (Specify)')
		----B. Amendment of information furnished in Table No 11 at S. No A in an earlier return
		---Amendment is in respect of information furnished in the Month
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(11,'11B','A','','','','',0,0,0,0,0,0,0,0,'','','',0,0,0,0,'Amendment is in respect of information furnished in the Month')
		---Specify the information you wish to amend (Drop down)
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(11,'11B','B','','','','',0,0,0,0,0,0,0,0,'','','',0,0,0,0,'')
		
		---12. Addition and reduction of amount in output tax for mismatch and other reasons			
		---ITC claimed on mismatched/duplication of invoices/debit notes
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(12,'12','A','','','','',0,0,0,0,0,0,0,0,'','','',0,0,0,0,'ITC claimed on mismatched/duplication of invoices/debit notes')
		 --- Tax liability on mismatched credit notes
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(12,'12','B','','','','',0,0,0,0,0,0,0,0,'','','Add',0,0,0,0,'Tax liability on mismatched credit notes')
		----Reclaim on account of rectification of mismatched invoices/debit notes
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(12,'12','C','','','','',0,0,0,0,0,0,0,0,'','','Add',0,0,0,0,'Reclaim on account of rectification of mismatched invoices/debit notes')
		---) Reclaim on account of rectification of mismatched credit note
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(12,'12','D','','','','',0,0,0,0,0,0,0,0,'','','Reduce',0,0,0,0,'Reclaim on account of rectification of mismatched credit note')
		----) Negative tax liability from previous tax periods
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(12,'12','E','','','','',0,0,0,0,0,0,0,0,'','','Reduce',0,0,0,0,'Negative tax liability from previous tax periods')
		----Tax paid on advance in earlier tax periods and adjusted with tax on supplies made in current tax period
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(12,'12','F','','','','',0,0,0,0,0,0,0,0,'','','Reduce',0,0,0,0,'Tax paid on advance in earlier tax periods and adjusted with tax on supplies made in current tax period')
		----13. HSN summary of inward supplies
		--
		Insert into #GSTR2(PART,PARTSR,SRNO,QTY,Taxableamt,GRO_AMT,CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,HSNCODE,uqc)
		SELECT 13 AS PART ,'13' AS PARTSR ,'A'AS SRNO,SUM(CASE WHEN ENTRY_TY IN('PT','P1') THEN +QTY ELSE -QTY END) AS QTY,SUM(CASE WHEN ENTRY_TY IN('PT','P1') THEN +Taxableamt ELSE -Taxableamt END)Taxableamt,SUM(CASE WHEN ENTRY_TY IN('PT','P1') THEN +GRO_AMT ELSE -GRO_AMT END)GRO_AMT,
		SUM(CASE WHEN ENTRY_TY IN('PT','P1') THEN +CGST_AMT ELSE -CGST_AMT END)CGST_AMT,SUM(CASE WHEN ENTRY_TY IN('PT','P1') THEN +SGST_AMT ELSE -SGST_AMT END)SGST_AMT,SUM(CASE WHEN ENTRY_TY IN('PT','P1') THEN +IGST_AMT ELSE -IGST_AMT END)IGST_AMT,SUM(CASE WHEN ENTRY_TY IN('PT','P1') THEN +CESS_AMT ELSE -CESS_AMT END)CESS_AMT,
		HSNCODE,uqc FROM #GSTR2TBL WHERE Entry_ty IN('PT','P1','PR') AND HSNCODE <> '' 
		group by HSNCODE,uqc order by HSNCODE,uqc
		IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PART = 13 AND PARTSR = '13' AND SRNO = 'A')
		BEGIN
			Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
			CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
			values(13,'13','A','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
		eND
	update #gstr2 set rptmonth =datename(mm,@SDATE),rptyear =year(@SDATE) 		
	Select * From #GSTR2 order by PART,PARTSR,SRNO 
	drop table #GSTR2AMD
	drop table #GSTR2TBL 
	drop table #gstr2amd3
END



