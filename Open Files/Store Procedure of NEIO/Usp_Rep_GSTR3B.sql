IF EXISTS(Select name  from sysobjects where xtype = 'P' and name = 'Usp_Rep_GSTR3B')
begin
	drop procedure Usp_Rep_GSTR3B
end
go 
/****** Object:  StoredProcedure [dbo].[Usp_Rep_GSTR3B]    Script Date: 12/08/2017 17:48:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	Author : Suraj Kumawat 
	--Date created : 02-02-2017
	Modify By :  SURAJ K. ON Date 02-01-2018 for Bug-31114(Consider Export Sales)
	Modify Date : 
	set dateformat dmy EXECUTE Usp_Rep_GSTR3B '','','','01/12/2017 ','31/12/2017','','','','',0,0,'','','','','','','','','2017-2018',''
*/
create Procedure [dbo].[Usp_Rep_GSTR3B]
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
	SELECT  PART=0,PARTSR=D.RATE,srno ='A',descr=SPACE(200),D.gro_amt  AS NET_AMT,D.gro_amt AS TAXABLEAMT,D.CGST_AMT,D.SGST_AMT,D.IGST_AMT ,D.IGST_AMT AS CESS_AMT
	,D.IGST_AMT AS TAX_PAID,D.IGST_AMT AS CESS_PAID,D.IGST_AMT AS INTEREST,D.IGST_AMT AS LATE_FEE,LOCATION =SPACE(100),RPT_YEAR=SPACE(25),RPT_MTH=SPACE(25) into #GSTR3B FROM  PTMAIN H INNER JOIN
	PTITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) WHERE 1=2
	Declare @Taxableamt decimal(18,2),@CGST_AMT decimal(18,2),@SGST_AMT decimal(18,2),@IGST_AMT decimal(18,2) ,@CESS_AMT decimal(18,2),@TAX_PAID decimal(18,2),@CESS_PAID decimal(18,2),@INTEREST decimal(18,2), @LATE_FEE decimal(18,2)
	--- Views data in Temporary Table
	----- ADJ_CESS_AMT =(cess_amt * RIO) Changed by suraj kumawat for tkt -30590
	SELECT ADJ_TAXABLE =(Taxableamt * RIO),ADJ_CGST_AMT =(CGST_AMT * RIO),ADJ_SGST_AMT =(SGST_AMT * RIO),ADJ_IGST_AMT =(IGST_AMT * RIO),ADJ_CESS_AMT =(cess_amt * RIO),* INTO #GSTR3BTBL FROM GSTR3B_VW   WHERE DATE BETWEEN @SDATE AND @EDATE
		
 	UPDATE #GSTR3BTBL SET SUPP_TYPE = '' WHERE ST_TYPE = 'OUT OF COUNTRY' 
	----- Eligiable or Eneligiable for ITC
	/* 3.1 Details of Outward Supplies and inward supplies liable to reverse charge*/
		SET @Taxableamt =0.00
		SET @CGST_AMT =0.00
		SET @SGST_AMT =0.00
		SET @IGST_AMT =0.00
		SET @CESS_AMT =0.00
		SELECT @Taxableamt =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR','EI') then +Taxableamt else -Taxableamt end) - ADJ_TAXABLE)
		,@IGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR','EI') then +IGST_AMT else -IGST_AMT end)- ADJ_IGST_AMT )
		,@CGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR','EI') then +CGST_AMT else - CGST_AMT end)- ADJ_CGST_AMT )
		,@SGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR','EI') then +SGST_AMT else - SGST_AMT end) - ADJ_SGST_AMT )
		,@CESS_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR','EI') then +cess_amt else - cess_amt end) - ADJ_cess_amt ) --Added by Suraj Kumawat date on 19-09-2017 
		FROM #GSTR3BTBL 
		--WHERE ENTRY_TY IN('ST','SR','GC','GD','C6','D6','S1','BR','CR','EI')   --Commented by Priyanka B on 28042018 for UERP Installer 1.0.0
		WHERE ENTRY_TY IN('ST','SR','GC','GD','C6','D6','S1','BR','CR','EI','RV')   --Modified by Priyanka B on 28042018 for UERP Installer 1.0.0
		AND st_type IN('INTRASTATE','INTERSTATE') AND SUPP_TYPE not IN('SEZ','EXPORT','EOU','Import','') and LineRule not in('Nill Rated','Nil Rated','Exempted','Non GST')
		and AGAINSTGS in('','SALES','SERVICE INVOICE') 
		---and hsncode <> '' Commented by Suraj Kumawat for Bug-31114  
		AND (IGST_AMT + CGST_AMT + SGST_AMT ) > 0
		----AND (st_type ='INTRASTATE' OR (st_type ='INTERSTATE' AND SUPP_TYPE not IN('Unregistered','SEZ','Compounding') and UID = '')) and LineRule not in('Nill Rated','Exempted')
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
		VALUES(3,3.1,'A','(a) Outward taxable supplies (other than zero rated,nil rated and exempted)',0,@Taxableamt,@CGST_AMT,@SGST_AMT,@IGST_AMT ,@CESS_AMT,0,0,0,0)

		---(b) Outward taxable supplies (zero rated )
		SET @Taxableamt =0.00
		SET @CGST_AMT =0.00
		SET @SGST_AMT =0.00
		SET @IGST_AMT =0.00
		SET @CESS_AMT =0.00 --Added by Suraj Kumawat date on 19-09-2017 
		SELECT @Taxableamt =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR','EI') then +Taxableamt else -Taxableamt end) - ADJ_TAXABLE)
		,@IGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR','EI') then +IGST_AMT else -IGST_AMT end)- ADJ_IGST_AMT )
		,@CGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR','EI') then +CGST_AMT else - CGST_AMT end)- ADJ_CGST_AMT )
		,@SGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR','EI') then +SGST_AMT else - SGST_AMT end) - ADJ_SGST_AMT )
		,@CESS_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR','EI') then +CESS_AMT else - CESS_AMT end) - ADJ_CESS_AMT )
		FROM #GSTR3BTBL WHERE ENTRY_TY IN('ST','SR','GC','GD','C6','D6','S1','BR','CR','EI') and st_type IN('OUT OF COUNTRY','INTERSTATE','INTRASTATE') and SUPP_TYPE IN('Export','SEZ','EOU','Import','')
		---and HSNCODE <> '' && Commented by Suraj Kumawat for Bug-31114
		and AGAINSTGS IN('SALES', 'SERVICE INVOICE','')
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(3,3.1,'B','(b) Outward taxable supplies (zero rated )',0,@Taxableamt,@CGST_AMT,@sGST_AMT,@IGST_AMT ,@CESS_AMT,0,0,0,0)
		---(c) Other outward supplies (Nil rated, exempted)
		SET @Taxableamt =0.00
		SET @CGST_AMT =0.00
		SET @SGST_AMT =0.00
		SET @IGST_AMT =0.00
		SET @CESS_AMT =0.00 
		SELECT @Taxableamt =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR','EI') then +Taxableamt else -Taxableamt end) - ADJ_TAXABLE)
		,@IGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR','EI') then +IGST_AMT else -IGST_AMT end)- ADJ_IGST_AMT )
		,@CGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR','EI') then +CGST_AMT else - CGST_AMT end)- ADJ_CGST_AMT )
		,@SGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR','EI') then +SGST_AMT else - SGST_AMT end) - ADJ_SGST_AMT )
		,@CESS_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR','EI') then +CESS_AMT else - CESS_AMT end) - ADJ_CESS_AMT )
		FROM #GSTR3BTBL WHERE ENTRY_TY IN('ST','SR','GC','GD','C6','D6','S1','BR','CR','EI') and st_type IN('INTERSTATE','INTRASTATE') and SUPP_TYPE NOT IN('Export','SEZ','EOU','Import')
		AND LineRule in('Exempted','Nill Rated','Nil Rated') and AGAINSTGS IN('SALES', 'SERVICE INVOICE','') 
		---AND HSNCODE <> '' && Commented by Suraj Kumawat for Bug-31114
		AND (IGST_AMT + CGST_AMT +SGST_AMT )  = 0
		
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(3,3.1,'C','(c) Other outward supplies (Nil rated, exempted)',0,@Taxableamt,@IGST_AMT,@CGST_AMT,@SGST_AMT ,@CESS_AMT,0,0,0,0)
		----(d) Inward supplies (liable to reverse charge)
			SET @Taxableamt =0.00
			SET @CGST_AMT =0.00
			SET @SGST_AMT =0.00
			SET @IGST_AMT =0.00
			SET @CESS_AMT =0.00 --Added by Suraj Kumawat date on 19-09-2017 
			SELECT @Taxableamt =isnull(SUM(Taxableamt),0)
			,@IGST_AMT =isnull(SUM(IGST_AMT),0)
			,@CGST_AMT =isnull(SUM(CGST_AMT ),0) 
			,@SGST_AMT =isnull(SUM(SGST_AMT),0)
			,@CESS_AMT =isnull(SUM(CESS_AMT),0) --Added by Suraj Kumawat date on 19-09-2017 
			FROM #GSTR3BTBL WHERE ENTRY_TY IN('UB')
		 ----Reverse change 
			SELECT @Taxableamt = @Taxableamt +  isnull(SUM(Case when Entry_ty in('E1','PT','P1','GC','C6','BP','CP') then +Taxableamt else -(Taxableamt) end),0)
			,@IGST_AMT =  @IGST_AMT +  isnull(SUM(Case when Entry_ty in('E1','PT','P1','GC','C6','BP','CP') then +IGSRT_AMT else -(IGSRT_AMT ) end),0)
			,@CGST_AMT = @CGST_AMT + isnull(SUM(Case when Entry_ty in('E1','PT','P1','GC','C6','BP','CP') then +CGSRT_AMT else -(CGSRT_AMT ) end),0)
			,@SGST_AMT = @SGST_AMT + isnull(SUM(Case when Entry_ty in('E1','PT','P1','GC','C6','BP','CP') then +SGSRT_AMT else -(SGSRT_AMT) end),0)
			,@CESS_AMT = @CESS_AMT + isnull(SUM(Case when Entry_ty in('E1','PT','P1','GC','C6','BP','CP') then +CESSRT_AMT else -(CESSRT_AMT) end),0) 
			FROM #GSTR3BTBL WHERE ENTRY_TY IN('E1','PT','P1','GC','C6','PR','GD','D6','BP','CP') AND st_type IN('INTRASTATE','INTERSTATE','OUT OF COUNTRY') AND SUPP_TYPE not in('Unregistered') AND AGAINSTGS in('','PURCHASES','SERVICE PURCHASE BILL','GOODS','SERVICES')
			and LineRule not in('Nill Rated','Nil Rated','Exempted') AND (isnull(CGSRT_AMT,0) + isnull(SGSRT_AMT,0) + isnull(IGSRT_AMT,0)) > 0  AND GSTIN NOT IN('Unregistered')
			
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(3,3.1,'D','(d) Inward supplies (liable to reverse charge)',0,@Taxableamt,@CGST_AMT,@SGST_AMT,@IGST_AMT,@CESS_AMT,0,0,0,0)
		----(e) Non-GST outward supplies					
		SET @Taxableamt =0.00
		SET @CGST_AMT =0.00
		SET @SGST_AMT =0.00
		SET @IGST_AMT =0.00
		SET @CESS_AMT =0.00
		SELECT @Taxableamt =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR','EI') then +Taxableamt else -Taxableamt end) - ADJ_TAXABLE)
		,@IGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR','EI') then +IGST_AMT else -IGST_AMT end)- ADJ_IGST_AMT )
		,@CGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR','EI') then +CGST_AMT else - CGST_AMT end)- ADJ_CGST_AMT )
		,@SGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR','EI') then +SGST_AMT else - SGST_AMT end) - ADJ_SGST_AMT )
		,@CESS_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR','EI') then +CESS_AMT else - CESS_AMT end) - ADJ_CESS_AMT ) --Added by Suraj Kumawat date on 19-09-2017 
		FROM #GSTR3BTBL WHERE ENTRY_TY IN('ST','SR','GC','GD','C6','D6','S1','CR','BR','EI') 
		and st_type IN('INTERSTATE','INTRASTATE') and SUPP_TYPE NOT IN('Export','SEZ','EOU','Import')
		and AGAINSTGS IN('SALES', 'SERVICE INVOICE','') AND ( HSNCODE = '' or LineRule ='Non GST') AND (IGST_AMT + CGST_AMT +SGST_AMT )  = 0
		
		
		
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(3,3.1,'E','(e) Non-GST outward supplies',@Taxableamt,@CGST_AMT,@SGST_AMT,@IGST_AMT ,@CESS_AMT,0,0,0,0)

	/* 3.2*/--- Of the supplies shown in 3.1 (a) above, details of inter-State supplies made to unregistered persons, composition taxable persons and UIN holders
		----Supplies made to Unregistered Persons
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,location )
		 SELECT 3 AS PART,3.2 AS PARTSR,'A' AS SRNO,'Supplies made to Unregistered Persons' AS DESCR, Taxableamt =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR') then +Taxableamt else -(Taxableamt) end) -ADJ_TAXABLE )
		,CGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR','EI') then +CGST_AMT else -CGST_AMT end)-ADJ_CGST_AMT)
		,SGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR','EI') then +SGST_AMT else -SGST_AMT end)-ADJ_SGST_AMT)
		,IGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR','EI') then +IGST_AMT else -IGST_AMT end)-ADJ_IGST_AMT)
		,CESS_AMT =0.00,POS FROM #GSTR3BTBL WHERE ENTRY_TY IN('ST','SR','GC','GD','C6','D6','S1','BR','CR','EI') and uid = ''  AND LineRule not in('Exempted','Nill Rated','Nil Rated')  and AGAINSTGS IN('SALES', 'SERVICE INVOICE','')
		 AND st_type ='INTERSTATE' AND  SUPP_TYPE = 'Unregistered' AND gstin = 'Unregistered' AND UID = ''  AND (ISNULL(IGST_AMT,0)) > 0 group by POS
		IF NOT EXISTS(SELECT SRNO FROM #GSTR3B WHERE PART = 3 AND PARTSR = 3.2 AND srno = 'A')
		begin
			Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
						VALUES(3,3.2,'A','Supplies made to Unregistered Persons',0,0,0,0,0 ,0,0,0,0,0)
		end
		----Supplies made to Composition Taxable Persons
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,location )
		 SELECT 3 AS PART,3.2 AS PARTSR,'B' AS SRNO,'Supplies made to Composition Taxable Persons' AS DESCR, Taxableamt =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR') then +Taxableamt else -(Taxableamt) end)- ADJ_TAXABLE)
		,CGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR','EI') then +CGST_AMT else -CGST_AMT end)-ADJ_CGST_AMT)
		,SGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR','EI') then +SGST_AMT else -SGST_AMT end)- ADJ_SGST_AMT)
		,IGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR','EI') then +IGST_AMT else -IGST_AMT end) -ADJ_IGST_AMT )
		,CESS_AMT =0.00,POS FROM #GSTR3BTBL WHERE ENTRY_TY IN('ST','SR','GC','GD','C6','D6','S1','BR','CR','EI') and uid = ''  AND LineRule not in('Exempted','Nill Rated','Nil Rated','Non GST') AND (IGST_AMT + CGST_AMT +SGST_AMT )  > 0
		 and AGAINSTGS IN('SALES', 'SERVICE INVOICE','') AND st_type ='INTERSTATE' AND  SUPP_TYPE = 'Compounding'  AND (ISNULL(IGST_AMT,0)) > 0 group by POS
		IF NOT EXISTS(SELECT SRNO FROM #GSTR3B WHERE PART = 3 AND PARTSR = 3.2 AND srno = 'B')
		begin
			Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
						VALUES(3,3.2,'B','Supplies made to Composition Taxable Persons',0,0,0,0,0 ,0,0,0,0,0)
		end
		
		----Supplies Supplies made to UIN holders
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,location)
		 SELECT 3 AS PART,3.2 AS PARTSR,'C' AS SRNO,'Supplies made to UIN holders' AS DESCR
		 ,Taxableamt =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR','EI') then +Taxableamt else -(Taxableamt) end) -ADJ_TAXABLE)
		,CGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR','EI') then +CGST_AMT else -CGST_AMT end) -ADJ_CGST_AMT)
		,SGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR','EI') then +SGST_AMT else -SGST_AMT end)- ADJ_SGST_AMT)
		,IGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR','EI') then +IGST_AMT else -IGST_AMT end)- ADJ_IGST_AMT)
		,CESS_AMT =0.00,POS FROM #GSTR3BTBL WHERE ENTRY_TY IN('ST','SR','GC','GD','C6','D6','S1','BR','CR','EI') and uid <> ''  AND LineRule not in('Exempted','Nill Rated','Nil Rated','Non GST')  and AGAINSTGS IN('SALES', 'SERVICE INVOICE','') 
		 AND st_type ='INTERSTATE'   AND (ISNULL(IGST_AMT,0)) > 0  group by POS
		IF NOT EXISTS(SELECT SRNO FROM #GSTR3B WHERE PART = 3 AND PARTSR = 3.2 AND srno = 'C')
		begin
			Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
						VALUES(3,3.2,'C','Supplies made to UIN holders',0,0,0,0,0 ,0,0,0,0,0)
		end
		
	/* 4.Eligible ITC*/
		---(A) ITC Available (whether in full or part)
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4,'A','(A) ITC Available (whether in full or part)',0,0,0,0,0 ,0,0,0,0,0)
		
		--Commented by Priyanka B on 22032018 for Bug-31364 Start
		--SELECT *  INTO #PTEPRCMTBL FROM (select entry_ty,tran_cd,scons_id,DATE  from EPMAIN  union all select entry_ty,tran_cd,scons_id,DATE from PtMAIN )A  where entry_ty in('PT','P1','E1') AND DATE BETWEEN @SDATE AND @EDATE /*Added by Suraj Kumawat for Bug-30998 date on 28-12-2017 */
		--SELECT *  INTO #BPRCM FROM (select entry_ty,tran_cd,AC_ID,DATE  from CPMAIN union all select entry_ty,tran_cd,Ac_id, DATE from BPMAIN )A  where entry_ty in('CP','BP') AND DATE BETWEEN @SDATE AND @EDATE /*Added by Suraj Kumawat for Bug-30998 date on 28-12-2017 */
		--Commented by Priyanka B on 22032018 for Bug-31364 End
		
		--Added by Priyanka B on 22032018 for Bug-31364 Start
		SELECT *  INTO #PTEPRCMTBL FROM (select entry_ty,tran_cd,scons_id,DATE,u_cldt  from EPMAIN  union all select entry_ty,tran_cd,scons_id,DATE,u_cldt from PtMAIN )A  where entry_ty in('PT','P1','E1') AND u_cldt <= @EDATE/*Added by Suraj Kumawat for Bug-30998 date on 28-12-2017 */
		SELECT *  INTO #BPRCM FROM (select entry_ty,tran_cd,AC_ID,DATE,u_cldt  from CPMAIN union all select entry_ty,tran_cd,Ac_id, DATE,u_cldt from BPMAIN )A  where entry_ty in('CP','BP') AND u_cldt <= @EDATE /*Added by Suraj Kumawat for Bug-30998 date on 28-12-2017 */
		--Added by Priyanka B on 22032018 for Bug-31364 End
		
		---(1) Import of goods
			SET @Taxableamt =0.00
			SET @CGST_AMT =0.00
			SET @SGST_AMT =0.00
			SET @IGST_AMT =0.00
			SET @CESS_AMT =0.00
			SELECT @Taxableamt =SUM(Case when Entry_ty in('PT','P1','GC') then +Taxableamt else -(Taxableamt) end)
			,@IGST_AMT =SUM(Case when Entry_ty in('PT','P1','GC') then +IGST_AMT else -(IGST_AMT ) end)
			,@CGST_AMT =SUM(Case when Entry_ty in('PT','P1','GC') then +CGST_AMT else -(CGST_AMT ) end)
			,@SGST_AMT =SUM(Case when Entry_ty in('PT','P1','GC') then +SGST_AMT else -(SGST_AMT) end)
			,@CESS_AMT =SUM(Case when Entry_ty in('PT','P1','GC') then +CESS_AMT else -(CESS_AMT) end) ---Added by suraj Kumawat for date on 19-08-2017
			FROM #GSTR3BTBL WHERE ENTRY_TY IN('PT','P1','PR','GC','GD') 
			AND Isservice  ='GOODS'
			AND ((st_type ='OUT OF COUNTRY' AND SUPP_TYPE IN('IMPORT','')) OR ( st_type IN('INTRASTATE','INTERSTATE') AND SUPP_TYPE IN('SEZ','IMPORT','EOU','EXPORT'))) AND AGAINSTGS in('','PURCHASES','GOODS')  and isnull(ITCSEC,'') = ''
			---and LineRule not in('Nill Rated','Exempted') AND (CGSRT_AMT +SGSRT_AMT + IGSRT_AMT) = 0 and isnull(ITCSEC,'') = '' AND (rentry_ty + org_no) NOT IN(SELECT (Entry_ty + PINVNO) FROM #Enelig_REC  where isnull(ITCSEC,'') <>'')
		    Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4,'A',space(4)+'(1) Import of goods',0,@Taxableamt,@CGST_AMT,@SGST_AMT,@IGST_AMT,@CESS_AMT,0,0,0,0)
		---(2) Import of services
			SET @Taxableamt =0.00
			SET @CGST_AMT =0.00
			SET @SGST_AMT =0.00
			SET @IGST_AMT =0.00
			SET @CESS_AMT =0.00
		   select @IGST_AMT = isnull(sum((case when b.typ = 'IGST Payable' then a.new_all else 0.00 end)),0)
		   ,@CESS_AMT = isnull(sum((case when b.typ = 'COMP CESS PAYABLE' then a.new_all else 0.00 end)),0)  ---Added by suraj Kumawat for date on 19-08-2017
		   from mainall_vw  a left outer join AC_MAST b on a.Ac_id = b.Ac_id  
		   left outer join bpmain c on (a.entry_ty=c.entry_ty and a.tran_cd=c.tran_cd)  --Added by Priyanka B on 23032018 for Bug-31364
		   ---where entry_ty = 'GB' and (a.ENTRY_ALL+ quotename(a.Main_tran)) in  (select  a.entry_ty+ quotename(a.Tran_cd)  from epmain a LEFT OUTER JOIN shipto b ON (b.shipto_id = a.scons_id) where b.Supp_type in('import','sez','Eou','','Export')) and b.typ in('CGST Payable','SGST Payable','IGST Payable','COMP CESS PAYABLE') and  a.date between @SDATE and @EDATE /*Commented by Suraj Kumawat for Bug-30998 date on 28-12-2017 */
		   where a.entry_ty = 'GB' 
		   --and  a.date between @SDATE and @EDATE  --Commented by Priyanka B on 23032018 for Bug-31364
		   and c.u_cldt between @SDATE and @EDATE --Modified by Priyanka B on 23032018 for Bug-31364
		   and b.typ in('CGST Payable','SGST Payable','IGST Payable','COMP CESS PAYABLE') and ((a.ENTRY_ALL+ quotename(a.Main_tran))  in (select  a.entry_ty+ quotename(a.Tran_cd)  from #PTEPRCMTBL a LEFT OUTER JOIN shipto c ON (c.shipto_id = a.scons_id) where c.Supp_type in('import','sez','Eou','','Export')) or  (a.ENTRY_ALL+ quotename(a.Main_tran)) in (select  a.entry_ty+ quotename(a.Tran_cd)  from #BPRCM a LEFT OUTER JOIN AC_MAST  c ON (c.Ac_id  = a.Ac_id ) where c.Supp_type in('import','sez','Eou','','Export'))) /*Added by Suraj Kumawat for Bug-30998 date on 28-12-2017 */
		   
		   Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4,'A',space(4)+'(2) Import of services',0,@Taxableamt,@CGST_AMT,@SGST_AMT,@IGST_AMT ,@CESS_AMT,0,0,0,0)
					
		 ----(3) Inward supplies liable to reverse charge (other than 1 & 2 above)
			SET @Taxableamt =0.00
			SET @CGST_AMT =0.00
			SET @SGST_AMT =0.00
			SET @IGST_AMT =0.00
			SET @CESS_AMT =0.00
		 select @IGST_AMT = isnull(sum((case when b.typ = 'IGST Payable' then a.new_all else 0.00 end)),0)
		     ,@SGST_AMT = isnull(sum((case when b.typ = 'SGST Payable' then a.new_all else 0.00 end)),0) 
		     ,@CGST_AMT = isnull(sum((case when b.typ = 'CGST Payable' then a.new_all else 0.00 end)),0) 
		     ,@CESS_AMT = isnull(sum((case when b.typ = 'COMP CESS PAYABLE' then a.new_all else 0.00 end)),0)  ---Added by suraj Kumawat for date on 19-08-2017
		 from mainall_vw  a left outer join AC_MAST b on a.Ac_id = b.Ac_id  
		 left outer join bpmain c on (a.entry_ty=c.entry_ty and a.tran_cd=c.tran_cd)  --Added by Priyanka B on 23032018 for Bug-31364
		 where a.entry_ty = 'GB' 
		   and b.typ in('CGST Payable','SGST Payable','IGST Payable','COMP CESS PAYABLE') 
		   --and  a.date between @SDATE and @EDATE   --Commented by Priyanka B on 26032018 for Bug-31364
		   and c.u_cldt between @SDATE and @EDATE  --Modified by Priyanka B on 26032018 for Bug-31364
		   and ((a.ENTRY_ALL+ quotename(a.Main_tran))  not in (select  a.entry_ty+ quotename(a.Tran_cd)  from #PTEPRCMTBL a LEFT OUTER JOIN shipto c ON (c.shipto_id = a.scons_id) where c.Supp_type in('import','sez','Eou','','Export')) and (a.ENTRY_ALL+ quotename(a.Main_tran)) not in (select  a.entry_ty+ quotename(a.Tran_cd)  from #BPRCM a LEFT OUTER JOIN AC_MAST  c ON (c.Ac_id  = a.Ac_id ) where c.Supp_type in('import','sez','Eou','','Export'))) /*added by Suraj Kumawat for Bug-30998 date on 28-12-2017 */ 
		---and (a.ENTRY_ALL+ quotename(a.Main_tran))  not in  (select  a.entry_ty+ quotename(a.Tran_cd)  from epmain a LEFT OUTER JOIN shipto b ON (b.shipto_id = a.scons_id) where b.Supp_type in('import','sez','Eou','export','')) and b.typ in('CGST Payable','SGST Payable','IGST Payable','COMP CESS PAYABLE') and  a.date between @SDATE and @EDATE  /*Commented by Suraj Kumawat for Bug-30998 date on 28-12-2017 */ 
		   
		 Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4,'A',space(4)+'(3) Inward supplies liable to reverse charge (other than 1 & 2 above)',0,@Taxableamt,@CGST_AMT,@SGST_AMT,@IGST_AMT,@CESS_AMT,0,0,0,0)
		-----(4) Inward Supplies  from ISD
		SET @Taxableamt =0.00
		SET @CGST_AMT =0.00
		SET @SGST_AMT =0.00
		SET @IGST_AMT =0.00
		SET @CESS_AMT =0.00 ---Added by suraj Kumawat for date on 19-08-2017
		select @CGST_AMT = ISNULL(SUM(A.CGST_AMT),0)
		,@SGST_AMT=ISNULL(SUM(A.SGST_AMT),0)
		,@IGST_AMT=ISNULL(SUM(A.IGST_AMT),0) 
		,@CESS_AMT=ISNULL(SUM(A.COMPCESS),0)  ---Added by suraj Kumawat for date on 19-08-2017
		from JVITEM a left outer join JVMAIN b on (a.entry_ty =b.entry_ty and a.Tran_cd =b.Tran_cd)
		WHERE A.entry_ty IN('J6' ,'J8') AND  (A.date BETWEEN @SDATE AND @EDATE)
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4,'A',space(4)+'(4) Inward supplies from ISD',0,0 ,@CGST_AMT,@SGST_AMT,@IGST_AMT,@CESS_AMT,0,0,0,0)
		---(5)ALL OTHER ITC
			SET @Taxableamt =0.00
			SET @CGST_AMT =0.00
			SET @SGST_AMT =0.00
			SET @IGST_AMT =0.00
			SET @CESS_AMT =0.00
			--Commented by Priyanka B on 04052018 for UERP Installer 1.0.0 Start
			/*SELECT @Taxableamt =ISNULL(SUM(Case when Entry_ty in('E1','PT','P1','GC','C6') then +Taxableamt else -(Taxableamt) end),0)
			,@IGST_AMT =ISNULL(SUM(Case when Entry_ty in('E1','PT','P1','GC','C6') then +IGST_AMT else -(IGST_AMT ) end),0)
			,@CGST_AMT =ISNULL(SUM(Case when Entry_ty in('E1','PT','P1','GC','C6') then +CGST_AMT else -(CGST_AMT ) end),0)
			,@SGST_AMT =ISNULL(SUM(Case when Entry_ty in('E1','PT','P1','GC','C6') then +SGST_AMT else -(SGST_AMT) end),0)
			,@CESS_AMT =ISNULL(SUM(Case when Entry_ty in('E1','PT','P1','GC','C6') then +CESS_AMT else -(CESS_AMT) end),0) ---Added by suraj Kumawat for date on 19-08-2017
			FROM #GSTR3BTBL WHERE ENTRY_TY IN('E1','PT','P1','GC','C6','PR','GD','D6') AND st_type IN('INTRASTATE','INTERSTATE') AND SUPP_TYPE in('Registered','Compounding','E-commerce') AND AGAINSTGS in('','PURCHASES','SERVICE PURCHASE BILL')
			and LineRule not in('Nill Rated','Nil Rated','Exempted') AND (CGSRT_AMT +SGSRT_AMT + IGSRT_AMT) = 0 and isnull(ITCSEC,'') =''			
			----and (rentry_ty + org_no) NOT IN(SELECT (Entry_ty + PINVNO) FROM #Enelig_REC  where isnull(ITCSEC,'') <>'') 
			*/
			--Commented by Priyanka B on 04052018 for UERP Installer 1.0.0 End
			
			--Modified by Priyanka B on 08052018 for UERP Installer 1.0.0 Start
			SELECT @Taxableamt =ISNULL(SUM(Case when A.Entry_ty in('E1','PT','P1','GC','C6') then +Taxableamt else -(Taxableamt) end),0)
			,@IGST_AMT =(ISNULL(SUM(Case when A.Entry_ty in('E1','PT','P1','GC','C6') then +IGST_AMT else -(IGST_AMT ) end),0)
				- ISNULL(SUM(Case when A.Entry_ty in('E1','PT','P1','GC','C6') then +IIGST_AMT else -(IIGST_AMT ) end),0))
			,@CGST_AMT =(ISNULL(SUM(Case when A.Entry_ty in('E1','PT','P1','GC','C6') then +CGST_AMT else -(CGST_AMT ) end),0)
				- ISNULL(SUM(Case when A.Entry_ty in('E1','PT','P1','GC','C6') then +ICGST_AMT else -(ICGST_AMT ) end),0))
			,@SGST_AMT =(ISNULL(SUM(Case when A.Entry_ty in('E1','PT','P1','GC','C6') then +SGST_AMT else -(SGST_AMT ) end),0)
				- ISNULL(SUM(Case when A.Entry_ty in('E1','PT','P1','GC','C6') then +ISGST_AMT else -(ISGST_AMT ) end),0))
			,@CESS_AMT =(ISNULL(SUM(Case when A.Entry_ty in('E1','PT','P1','GC','C6') then +CESS_AMT else -(CESS_AMT ) end),0)
				- ISNULL(SUM(Case when A.Entry_ty in('E1','PT','P1','GC','C6') then +ICESS_AMT else -(ICESS_AMT ) end),0)) ---Added by suraj Kumawat for date on 19-08-2017
			FROM #GSTR3BTBL A
			LEFT OUTER JOIN EPAYMENT B ON (A.ENTRY_TY=B.ENTRY_TY AND A.TRAN_CD=B.TRAN_CD AND A.ITSERIAL=B.ITSERIAL)
			WHERE A.ENTRY_TY IN('E1','PT','P1','GC','C6','PR','GD','D6') AND st_type IN('INTRASTATE','INTERSTATE') AND SUPP_TYPE in('Registered','Compounding','E-commerce') AND AGAINSTGS in('','PURCHASES','SERVICE PURCHASE BILL')
			and LineRule not in('Nill Rated','Nil Rated','Exempted') AND (CGSRT_AMT +SGSRT_AMT + IGSRT_AMT) = 0 
			--Modified by Priyanka B on 08052018 for UERP Installer 1.0.0 End
			
		 	
		Select @CGST_AMT = @CGST_AMT + ISNULL(SUM(A.CGST_AMT),0)
		,@SGST_AMT = @SGST_AMT + ISNULL(SUM(A.SGST_AMT),0)
		,@IGST_AMT = @IGST_AMT + ISNULL(SUM(A.IGST_AMT),0)
		,@CESS_AMT = @CESS_AMT + ISNULL(SUM(A.COMPCESS),0) ---Added by suraj Kumawat for date on 19-08-2017
		From JVMAIN A WHERE A.entry_ty ='J7' 
		--AND  A.AGAINSTTY ='Excess'  --Commented by Priyanka B on 14052018 for UERP Installer 1.0.0
		AND  A.AGAINSTTY in ('Excess','Addition') --Modified by Priyanka B on 14052018 for UERP Installer 1.0.0
		AND  (A.date BETWEEN @SDATE AND @EDATE)  
		
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4,'A',space(4)+'(5) All other ITC',0,0,@CGST_AMT,@SGST_AMT,@IGST_AMT ,@CESS_AMT,0,0,0,0)
		-----(B) ITC Reversed					
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4,'B','(B) ITC Reversed',0,0,0,0,0 ,0,0,0,0,0)
		----(1) As per rules 42 & 43 of CGST Rules
		SET @Taxableamt =0.00
		SET @CGST_AMT =0.00
		SET @SGST_AMT =0.00
		SET @IGST_AMT =0.00
		SET @CESS_AMT =0.00
		--select @CGST_AMT = ISNULL(SUM(A.CGST_AMT),0),@SGST_AMT=ISNULL(SUM(A.SGST_AMT),0),@IGST_AMT=ISNULL(SUM(A.IGST_AMT),0) from JVMAIN A WHERE A.entry_ty ='J7' AND  (A.date BETWEEN @SDATE AND @EDATE) and A.RevsType = 'GST Rules 42 & 43 '  AND  A.AGAINSTTY ='Shortage' ----COMMENTED by Prajakta B. on 10/08/2017
		select @CGST_AMT = ISNULL(SUM(A.CGST_AMT),0)
		,@SGST_AMT=ISNULL(SUM(A.SGST_AMT),0)
		,@IGST_AMT=ISNULL(SUM(A.IGST_AMT),0)
		,@CESS_AMT=ISNULL(SUM(A.COMPCESS),0) 
		from JVMAIN A WHERE A.entry_ty ='J7' AND  (A.date BETWEEN @SDATE AND @EDATE) and A.RevsType = 'GST Rules 42 & 43'  
		--AND  A.AGAINSTTY ='Shortage'   ----Modified by Prajakta B. on 10/08/2017  --Commented by Priyanka B on 05052018 for UERP Installer 1.0.0
		AND  A.AGAINSTTY in ('Shortage','Reduction')   ----Modified by Prajakta B. on 10/08/2017  --Modified by Priyanka B on 05052018 for UERP Installer 1.0.0
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					--VALUES(4,4,'B',space(4)+'(1) As per rules 42 & 43 of CGST Rules',0,0,@CGST_AMT,@SGST_AMT,@iGST_AMT,0,0,0,0,0)----COMMENTED by Prajakta B. on 10/08/2017
										VALUES(4,4,'B',space(4)+'(1) As per rules 42 & 43 of CGST Rules',0,0,@CGST_AMT,@SGST_AMT,@iGST_AMT,@CESS_AMT,0,0,0,0)   ---Modified by Prajakta B. on 10/08/2017
		----(2) Others					
		SET @Taxableamt =0.00
		SET @CGST_AMT =0.00
		SET @SGST_AMT =0.00
		SET @IGST_AMT =0.00
		SET @CESS_AMT =0.00
		----select @CGST_AMT = ISNULL(SUM(A.CGST_AMT),0),@SGST_AMT=ISNULL(SUM(A.SGST_AMT),0),@IGST_AMT=ISNULL(SUM(A.IGST_AMT),0) from JVMAIN A WHERE A.entry_ty ='J7' AND  (A.date BETWEEN @SDATE AND @EDATE) and A.RevsType NOT IN('GST Rules 42 & 43 ')  AND  A.AGAINSTTY ='Shortage' --- Commented by  Suraj Kumawat 19-08-2017 
		select @CGST_AMT = ISNULL(SUM(A.CGST_AMT),0),@SGST_AMT=ISNULL(SUM(A.SGST_AMT),0),@IGST_AMT=ISNULL(SUM(A.IGST_AMT),0),@CESS_AMT =ISNULL(SUM(A.COMPCESS),0) from JVMAIN A WHERE A.entry_ty ='J7' AND  (A.date BETWEEN @SDATE AND @EDATE) 
		--and A.RevsType NOT IN('GST Rules 42 & 43 ') AND  A.AGAINSTTY ='Shortage'   --Commented by Priyanka B on 11052018 for UERP Installer 1.0.0
		and A.RevsType IN ('Others') AND  A.AGAINSTTY in ('Shortage','Reduction') 	--Modified by Priyanka B on 11052018 for UERP Installer 1.0.0
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4,'B',space(4)+'(2) Others',0,0,@CGST_AMT,@SGST_AMT,@IGST_AMT ,@CESS_AMT,0,0,0,0)
		----(C) Net ITC Available (A) – (B)
		SET @CGST_AMT =0.00
		SET @SGST_AMT =0.00
		SET @IGST_AMT =0.00
		SET @CESS_AMT =0.00
		SELECT @CGST_AMT =isnull(sum(case when srno = 'A' then +CGST_AMT else -CGST_AMT end),0)
		,@SGST_AMT =isnull(sum(case when srno = 'A' then +SGST_AMT else -SGST_AMT end),0)
		,@IGST_AMT =isnull(sum(case when srno = 'A' then +IGST_AMT else -IGST_AMT end),0)   
		,@CESS_AMT =isnull(sum(case when srno = 'A' then +CESS_AMT else -CESS_AMT end),0)    ---Added by suraj Kumawat for date on 19-08-2017
		FROM #GSTR3B WHERE PART = 4 AND PARTSR = 4  and srno IN('A','B') 
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4,'C','(C) Net ITC Available (A) - (B)',0,0,@CGST_AMT,@SGST_AMT,@IGST_AMT ,@CESS_AMT,0,0,0,0)
		----Ineligible ITC
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4,'D','(D) Ineligible ITC',0,0,0,0,0 ,0,0,0,0,0)
		----As per section 17(5)
			SET @Taxableamt =0.00
			SET @CGST_AMT =0.00
			SET @SGST_AMT =0.00
			SET @IGST_AMT =0.00
			SET @CESS_AMT =0.00 ---Added by suraj Kumawat for date on 19-08-2017
			--Commented by Priyanka B on 28042018 for UERP Installer 1.0.0 Start
			/*SELECT @Taxableamt =SUM(Case when Entry_ty in('E1','PT','P1','GC') then +Taxableamt else -(Taxableamt) end)
			,@IGST_AMT =SUM(Case when Entry_ty in('E1','PT','P1','GC','C6') then +IGST_AMT else -(IGST_AMT ) end)
			,@CGST_AMT =SUM(Case when Entry_ty in('E1','PT','P1','GC','C6') then +CGST_AMT else -(CGST_AMT ) end)
			,@SGST_AMT =SUM(Case when Entry_ty in('E1','PT','P1','GC','C6') then +SGST_AMT else -(SGST_AMT) end)
			,@CESS_AMT =SUM(Case when Entry_ty in('E1','PT','P1','GC','C6') then +CESS_AMT else -(CESS_AMT) end) ---Added by suraj Kumawat for date on 19-08-2017
			FROM #GSTR3BTBL	WHERE ENTRY_TY IN('E1','PT','P1','GC','C6','PR','GD','D6') AND st_type IN('INTRASTATE','INTERSTATE','OUT OF COUNTRY') AND SUPP_TYPE in('EOU','SEZ','IMPORT','Registered','Compounding','E-Commerce','','Export') AND AGAINSTGS in('','PURCHASES','SERVICE PURCHASE BILL') and isnull(ITCSEC,'') = 'Section 17(5)'
			---AND (rentry_ty + org_no) IN(SELECT (Entry_ty + PINVNO) FROM #Enelig_REC  where isnull(ITCSEC,'') = 'Section 17(5)')
			*/
			--Commented by Priyanka B on 28042018 for UERP Installer 1.0.0 End

			--Modified by Priyanka B on 28042018 for UERP Installer 1.0.0 Start
			SELECT @Taxableamt =SUM(Case when A.Entry_ty in('E1','PT','P1','GC') then +Taxableamt else -(Taxableamt) end)
			,@IGST_AMT =SUM(Case when A.Entry_ty in('E1','PT','P1','GC','C6') then +IIGST_AMT else -(IIGST_AMT ) end)
			,@CGST_AMT =SUM(Case when A.Entry_ty in('E1','PT','P1','GC','C6') then +ICGST_AMT else -(ICGST_AMT ) end)
			,@SGST_AMT =SUM(Case when A.Entry_ty in('E1','PT','P1','GC','C6') then +ISGST_AMT else -(ISGST_AMT) end)
			,@CESS_AMT =SUM(Case when A.Entry_ty in('E1','PT','P1','GC','C6') then +ICESS_AMT else -(ICESS_AMT) end) ---Added by suraj Kumawat for date on 19-08-2017
			FROM #GSTR3BTBL A
			INNER JOIN EPAYMENT B ON (A.ENTRY_TY=B.ENTRY_TY AND A.TRAN_CD=B.TRAN_CD AND A.ITSERIAL=B.ITSERIAL)
			WHERE A.ENTRY_TY IN('E1','PT','P1','GC','C6','PR','GD','D6') AND st_type IN('INTRASTATE','INTERSTATE','OUT OF COUNTRY') AND SUPP_TYPE in('EOU','SEZ','IMPORT','Registered','Compounding','E-Commerce','','Export') AND AGAINSTGS in('','PURCHASES','SERVICE PURCHASE BILL') and isnull(ITCSEC,'') = 'Section 17(5)'
			---AND (rentry_ty + org_no) IN(SELECT (Entry_ty + PINVNO) FROM #Enelig_REC  where isnull(ITCSEC,'') = 'Section 17(5)')
			--Modified by Priyanka B on 28042018 for UERP Installer 1.0.0 Emd
						
			Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4,'D',space(4)+'(1) As per section 17(5)',0,@Taxableamt,@CGST_AMT,@SGST_AMT,@IGST_AMT ,@CESS_AMT,0,0,0,0)
		---(2) Others
			SET @Taxableamt =0.00
			SET @CGST_AMT =0.00
			SET @SGST_AMT =0.00
			SET @IGST_AMT =0.00
			SET @CESS_AMT =0.00 ---Added by suraj Kumawat for date on 19-08-2017
			--Commented by Priyanka B on 28042018 for UERP Installer 1.0.0 Start
			/*SELECT @Taxableamt =SUM(Case when Entry_ty in('E1','PT','P1','GC') then +Taxableamt else -(Taxableamt) end)
			,@IGST_AMT =SUM(Case when Entry_ty in('E1','PT','P1','GC','C6') then +IGST_AMT else -(IGST_AMT ) end)
			,@CGST_AMT =SUM(Case when Entry_ty in('E1','PT','P1','GC','C6') then +CGST_AMT else -(CGST_AMT ) end)
			,@SGST_AMT =SUM(Case when Entry_ty in('E1','PT','P1','GC','C6') then +SGST_AMT else -(SGST_AMT) end)
			,@CESS_AMT =SUM(Case when Entry_ty in('E1','PT','P1','GC','C6') then +CESS_AMT else -(CESS_AMT) end) ---Added by suraj Kumawat for date on 19-08-2017
			FROM #GSTR3BTBL WHERE ENTRY_TY IN('E1','PT','P1','GC','C6','PR','GD','D6') AND st_type IN('INTRASTATE','INTERSTATE','OUT OF COUNTRY') AND SUPP_TYPE in('EOU','IMPORT','SEZ','Registered','Compounding','E-Commerce','','Export') AND AGAINSTGS in('','PURCHASES','SERVICE PURCHASE BILL')  and isnull(ITCSEC,'') = 'Others'
			---AND (rentry_ty + org_no) IN(SELECT (Entry_ty + PINVNO) FROM #Enelig_REC  where isnull(ITCSEC,'') = 'Others')
			*/
			--Commented by Priyanka B on 28042018 for UERP Installer 1.0.0 End
			
			--Modified by Priyanka B on 28042018 for UERP Installer 1.0.0 Start
			SELECT @Taxableamt =SUM(Case when A.Entry_ty in('E1','PT','P1','GC') then +Taxableamt else -(Taxableamt) end)
			,@IGST_AMT =SUM(Case when A.Entry_ty in('E1','PT','P1','GC','C6') then +IIGST_AMT else -(IIGST_AMT ) end)
			,@CGST_AMT =SUM(Case when A.Entry_ty in('E1','PT','P1','GC','C6') then +ICGST_AMT else -(ICGST_AMT ) end)
			,@SGST_AMT =SUM(Case when A.Entry_ty in('E1','PT','P1','GC','C6') then +ISGST_AMT else -(ISGST_AMT) end)
			,@CESS_AMT =SUM(Case when A.Entry_ty in('E1','PT','P1','GC','C6') then +ICESS_AMT else -(ICESS_AMT) end) ---Added by suraj Kumawat for date on 19-08-2017
			FROM #GSTR3BTBL A
			INNER JOIN EPAYMENT B ON (A.ENTRY_TY=B.ENTRY_TY AND A.TRAN_CD=B.TRAN_CD AND A.ITSERIAL=B.ITSERIAL)
			WHERE A.ENTRY_TY IN('E1','PT','P1','GC','C6','PR','GD','D6') AND st_type IN('INTRASTATE','INTERSTATE','OUT OF COUNTRY') AND SUPP_TYPE in('EOU','IMPORT','SEZ','Registered','Compounding','E-Commerce','','Export') AND AGAINSTGS in('','PURCHASES','SERVICE PURCHASE BILL')  and isnull(ITCSEC,'') = 'Others'
			---AND (rentry_ty + org_no) IN(SELECT (Entry_ty + PINVNO) FROM #Enelig_REC  where isnull(ITCSEC,'') = 'Others')
			--Modified by Priyanka B on 28042018 for UERP Installer 1.0.0 End
			
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4,'D',space(4)+'(2) Others',0,@Taxableamt,@CGST_AMT,@SGST_AMT,@IGST_AMT ,@CESS_AMT,0,0,0,0)

	/* 5*/
		----From a supplier under composition scheme, Exempt and Nil rated supply
		SET @Taxableamt =0.00
		SET @SGST_AMT =0.00
		SET @CGST_AMT = 0
		SET @IGST_AMT = 0
		select @IGST_AMT=SUM((Case when Entry_ty in('PT','P1','GC','C6','E1','BP','CP') then +(CASE WHEN ST_TYPE = 'INTERSTATE' THEN GRO_AMT ELSE 0.00 END) ELSE -(CASE WHEN ST_TYPE = 'INTERSTATE' THEN GRO_AMT ELSE 0.00 END) END)) ,
		@CGST_AMT =SUM((Case when Entry_ty in('PT','P1','GC','C6','E1','BP','CP') then +(CASE WHEN ST_TYPE = 'INTRASTATE' THEN GRO_AMT ELSE 0.00 END) ELSE -(CASE WHEN ST_TYPE = 'INTRASTATE' THEN GRO_AMT ELSE 0.00 END) END))
		from #GSTR3BTBL  where ENTRY_TY IN('PT','P1','PR','GC','GD','C6','D6','E1','CP','BP') AND  st_type in('INTERSTATE','INTRASTATE' )  AND supp_type not in('SEZ','EOU','IMPORT','Export','') AND ( LineRule IN('Exempted','Nill Rated','Nil Rated') or SUPP_TYPE = 'COMPOUNDING')
		AND HSNCODE <> '' AND AGAINSTGS IN('PURCHASES','SERVICE PURCHASE BILL','','GOODS','SERVICES')
		
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(5,5,'A','From a supplier under composition scheme, Exempt and Nil rated supply',0,0,@CGST_AMT,0,@IGST_AMT ,0,0,0,0,0)
		----Non GST supply
		SET @CGST_AMT = 0
		SET @IGST_AMT = 0
		select @IGST_AMT=SUM((Case when Entry_ty in('PT','P1','GC','C6','E1','BP','CP') then +(CASE WHEN ST_TYPE = 'INTERSTATE' THEN GRO_AMT ELSE 0.00 END) ELSE -(CASE WHEN ST_TYPE = 'INTERSTATE' THEN GRO_AMT ELSE 0.00 END) END)) ,
		@CGST_AMT =SUM((Case when Entry_ty in('PT','P1','GC','C6','E1','BP','CP') then +(CASE WHEN ST_TYPE = 'INTRASTATE' THEN GRO_AMT ELSE 0.00 END) ELSE -(CASE WHEN ST_TYPE = 'INTRASTATE' THEN GRO_AMT ELSE 0.00 END) END))
		---from #GSTR3BTBL  where ENTRY_TY IN('PT','P1','PR','GC','GD','C6','D6','E1','CP','BP') AND  st_type in('INTERSTATE','INTRASTATE' )  AND supp_type not in('SEZ','EOU','IMPORT','Export','') AND HSNCODE = '' AND AGAINSTGS IN('PURCHASES','SERVICE PURCHASE BILL','','GOODS','SERVICES') /*Commented by suraj Kumawat date on 02-01-2018 for bug-31114 */
		from #GSTR3BTBL  where ENTRY_TY IN('PT','P1','PR','GC','GD','C6','D6','E1','CP','BP') AND  st_type in('INTERSTATE','INTRASTATE' )  AND supp_type not in('SEZ','EOU','IMPORT','Export','') AND  (HSNCODE = '' OR LineRule ='Non GST') AND AGAINSTGS IN('PURCHASES','SERVICE PURCHASE BILL','','GOODS','SERVICES') /*Added by suraj Kumawat date on 02-01-2018 for bug-31114 */
		
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(5,5,'B','Non GST supply',0,0,@CGST_AMT,0,@IGST_AMT,0,0,0,0,0)

	/* 6.1*/
	---- SALES 
	
		DECLARE @IGST_PAY DECIMAL(18,2),@SGST_PAY DECIMAL(18,2),@CGST_PAY DECIMAL(18,2),@cess_PAY DECIMAL(18,2)
		SET @IGST_PAY = 0
		SET @CGST_PAY = 0
		SET @SGST_PAY = 0
		set @cess_PAY = 0 
	-- Added by Shrikant S. on 12/09/2017 for GST		--Start
		SELECT a=1,a.ac_id,a.ac_name,a.amount,a.amt_ty
		,a.entry_ty,a.date,a.u_cldt
				iNTO #TBL1
				FROM lac_vw a
				inner join lmain_vw b on (a.Entry_ty=b.Entry_ty and a.Tran_cd=b.tran_cd)
				left outer join mainall_vw mv on (b.entry_ty=mv.entry_ty and b.tran_cd=mv.tran_cd)   --Added by Priyanka B on 26032018 for Bug-31364
				WHERE a.ac_name IN('Central GST Payable A/C','State GST Payable A/C','Integrated GST Payable A/C','Compensation Cess Payable A/C')
				--and b.entry_ty not in ('GA','GB')  --Commented by Priyanka B on 27032018 for Bug-31364
				--and b.entry_ty not in ('GA','GB','UB','PT','P1')  --Modified by Priyanka B on 27032018 for Bug-31364  --Commented by Priyanka B on 23042018 for UERP Installer 1.0.0
				and b.entry_ty not in ('GA','GB','UB','PT','P1','BP','CP')  --Modified by Priyanka B on 27032018 for Bug-31364  --Modified by Priyanka B on 23042018 for UERP Installer 1.0.0
				and b.againstgs not in ('PURCHASES')  --Added by Priyanka B on 28052018 for Bug-31569
				--AND b.DATE < = @EDATE   --Commented by Priyanka B on 26032018 for Bug-31364
				--AND a.u_cldt <= @EDATE    --Modified by Priyanka B on 26032018 for Bug-31364  --Commented by Priyanka B on 09052018 for UERP Installer 1.0.0
				AND (Case when YEAR(a.u_cldt)>2000 then a.u_cldt else a.date end) <= @EDATE --Modified by Priyanka B on 26032018 for Bug-31364  --Modified by Priyanka B on 09052018 for UERP Installer 1.0.0
				and (a.entry_ty+QUOTENAME(a.tran_cd)) not in (select (mv.entry_all+quotename(mv.main_tran)) from mainall_vw mv inner join bpmain b on (b.entry_ty=mv.entry_ty and b.tran_cd=mv.tran_cd))   --Added by Priyanka B on 26032018 for Bug-31364
		UNION ALL
			SELECT a=2,a.ac_id,a.ac_name,a.amount,a.amt_ty
			,a.entry_ty,a.date,a.u_cldt
				FROM jvacdet a
				inner join jvmain b on (a.Entry_ty=b.Entry_ty and a.Tran_cd=b.tran_cd)
				WHERE a.ac_name IN('Central GST Payable A/C','State GST Payable A/C','Integrated GST Payable A/C','Compensation Cess Payable A/C') 
				and b.entry_ty IN ('GA')
				AND b.U_CLDT <  @SDATE AND YEAR(b.U_CLDT) > 2000
		UNION ALL
			SELECT a=3,a.ac_id,a.ac_name,a.amount,a.amt_ty
			,a.entry_ty,a.date,a.u_cldt
				FROM bpacdet a
				inner join bpmain b on (a.Entry_ty=b.Entry_ty and a.Tran_cd=b.tran_cd)
				WHERE a.ac_name IN('Central GST Payable A/C','State GST Payable A/C','Integrated GST Payable A/C','Compensation Cess Payable A/C') 
				and b.entry_ty IN ('GB')
				--AND b.U_CLDT <  @SDATE AND YEAR(b.U_CLDT) > 2000	--Commented by Priyanka B on 26032018 for Bug-31364
				AND b.date <= @EDATE  --Modified by Priyanka B on 26032018 for Bug-31364
				and (b.entry_ty+QUOTENAME(b.tran_cd)) not in (select (mv.entry_ty+quotename(mv.tran_cd)) from mainall_vw mv inner join bpmain b on (b.entry_ty=mv.entry_ty and b.tran_cd=mv.tran_cd))   --Added by Priyanka B on 26032018 for Bug-31364		
			
			--select * from #TBL1
			
		SELECT @IGST_PAY= SUM(CASE WHEN ac_name ='Integrated GST Payable A/C' THEN (case when amt_ty ='cr'  then + AMOUNT else -AMOUNT  end)  ELSE 0.00 END)
				,@SGST_PAY= SUM(CASE WHEN ac_name ='State GST Payable A/C' THEN (case when amt_ty ='cr'  then + AMOUNT else -AMOUNT  end) ELSE 0.00 END)
				,@CGST_PAY= SUM(CASE WHEN ac_name ='Central GST Payable A/C' THEN (case when amt_ty ='cr'  then + AMOUNT else -AMOUNT  end) ELSE 0.00 END)
				,@cess_PAY= SUM(CASE WHEN ac_name ='Compensation Cess Payable A/C' THEN (case when amt_ty ='cr'  then + AMOUNT else -AMOUNT  end) ELSE 0.00 END) --- Added by Suraj Kumawat Date on 19-08-2017 
				FROM #TBL1 
 -- Added by Shrikant S. on 12/09/2017 for GST		--End
				
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
	---,@CGST_CGST_ADJ=ISNULL(SUM(CGST_CGST_ADJ),0),@CGST_IGST_Adj=ISNULL(SUM(CGST_IGST_Adj),0)
	,@CGST_CGST_ADJ=ISNULL(SUM(CGST_CGST_ADJ),0),@CGST_IGST_Adj=ISNULL(SUM(IGST_CGST_Adj),0)
	---SGST ADJUSTMENT
	---,@SGST_SGST_ADJ=ISNULL(SUM(SGST_SGST_ADJ),0),@SGST_IGST_Adj =ISNULL(SUM(SGST_IGST_Adj),0)  
	,@SGST_SGST_ADJ=ISNULL(SUM(SGST_SGST_ADJ),0),@SGST_IGST_Adj =ISNULL(SUM(IGST_SGST_Adj),0)  
	,@CCESS_CCESS_Adj=ISNULL(SUM(CCESS_CCESS_Adj),0)
	from JVMAIN    where entry_ty = 'GA'  and (u_cldt between @SDATE and @EDATE)
	
   ----Interest & Fee Declaration variables 
      DECLARE @IGST_INT DECIMAL(18,2),@SGST_INT DECIMAL(18,2),@CGST_INT DECIMAL(18,2),@IGST_FEE DECIMAL(18,2),@SGST_FEE DECIMAL(18,2),@CGST_FEE DECIMAL(18,2)
	  ----Interest Payable A/c
	  set @IGST_INT = 0
	  set @SGST_INT = 0
	  set @CGST_INT = 0
	  select @IGST_INT = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Integrated GST Interest Payable A/C' and a.entry_ty ='GB' AND (b.u_cldt BETWEEN @SDATE AND @EDATE)
	  select @CGST_INT = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Central GST Interest Payable A/C' and a.entry_ty ='GB' AND (b.u_cldt BETWEEN @SDATE AND @EDATE) 
	  select @SGST_INT = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='State GST Interest Payable A/C' and a.entry_ty ='GB' AND (b.u_cldt BETWEEN @SDATE AND @EDATE) 
	  
	  ----Late fee Payable A/c
	  set @IGST_FEE = 0
	  set @SGST_FEE = 0
	  set @CGST_FEE = 0
	  select @IGST_FEE = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Integrated GST Late Fee Payable A/C' and a.entry_ty ='GB' AND (B.u_cldt BETWEEN @SDATE AND @EDATE) 
	  select @CGST_FEE = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Central GST Late Fee Payable A/C' and a.entry_ty ='GB' AND (B.u_cldt BETWEEN @SDATE AND @EDATE) 
	  select @SGST_FEE = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='State GST Late Fee Payable A/C' and a.entry_ty ='GB' AND (b.u_cldt BETWEEN @SDATE AND @EDATE) 

	 ---TAX paid cess  
     DECLARE @IGST_TAX DECIMAL(18,2),@SGST_TAX DECIMAL(18,2),@CGST_TAX DECIMAL(18,2),@CCESS_TAX DECIMAL(18,2)
	  set @IGST_TAX = 0
	  set @SGST_TAX = 0
	  set @CGST_TAX = 0
	  SET @CCESS_TAX = 0 ---Added by suraj Kumawat for date on 19-08-2017
	  --Commented by Priyanka B on 26032018 for Bug-31364 Start
	  /*select @IGST_TAX = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Integrated GST Payable A/C' and a.entry_ty ='GB' AND (B.u_cldt BETWEEN @SDATE AND @EDATE) 
	  select @CGST_TAX = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Central GST Payable A/C' and a.entry_ty ='GB' AND (B.u_cldt BETWEEN @SDATE AND @EDATE) 
	  select @SGST_TAX = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='State GST Payable A/C' and a.entry_ty ='GB' AND (B.u_cldt BETWEEN @SDATE AND @EDATE) 
	  select @CCESS_TAX = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Compensation Cess Payable A/C' and a.entry_ty ='GB' AND (B.u_cldt BETWEEN @SDATE AND @EDATE) 
	  */--Commented by Priyanka B on 26032018 for Bug-31364 End
	  
	  --Modified by Priyanka B on 26032018 for Bug-31364 Start
	  select @IGST_TAX = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Integrated GST Payable A/C' and a.entry_ty ='GB' AND (B.u_cldt BETWEEN @SDATE AND @EDATE) 
	  and (b.entry_ty+QUOTENAME(b.tran_cd)) not in (select (mv.entry_ty+quotename(mv.tran_cd)) from mainall_vw mv inner join bpmain b on (b.entry_ty=mv.entry_ty and b.tran_cd=mv.tran_cd))
	  select @CGST_TAX = isnull(sum(a.amount),0) from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Central GST Payable A/C' and a.entry_ty ='GB' AND (B.u_cldt BETWEEN @SDATE AND @EDATE) 
	  and (b.entry_ty+QUOTENAME(b.tran_cd)) not in (select (mv.entry_ty+quotename(mv.tran_cd)) from mainall_vw mv inner join bpmain b on (b.entry_ty=mv.entry_ty and b.tran_cd=mv.tran_cd))
	  select @SGST_TAX = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='State GST Payable A/C' and a.entry_ty ='GB' AND (B.u_cldt BETWEEN @SDATE AND @EDATE) 
	  and (b.entry_ty+QUOTENAME(b.tran_cd)) not in (select (mv.entry_ty+quotename(mv.tran_cd)) from mainall_vw mv inner join bpmain b on (b.entry_ty=mv.entry_ty and b.tran_cd=mv.tran_cd))
	  select @CCESS_TAX = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Compensation Cess Payable A/C' and a.entry_ty ='GB' AND (B.u_cldt BETWEEN @SDATE AND @EDATE) 
	  and (b.entry_ty+QUOTENAME(b.tran_cd)) not in (select (mv.entry_ty+quotename(mv.tran_cd)) from mainall_vw mv inner join bpmain b on (b.entry_ty=mv.entry_ty and b.tran_cd=mv.tran_cd))
	  --Modified by Priyanka B on 26032018 for Bug-31364 End
	  
	---(A) other than reverse change
	  Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE,LOCATION)
					VALUES(6,6.1,'A','Integrated Tax',0,@IGST_PAY,@IGST_CGST,@IGST_SGST,@IGST_IGST ,0,0,@IGST_TAX,@IGST_INT,@IGST_FEE,'A')

		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE,LOCATION)
					VALUES(6,6.1,'B','Central Tax',0,@CGST_PAY,@CGST_CGST_ADJ,0,@CGST_IGST_Adj,0,0,@CGST_TAX,@CGST_INT,@CGST_FEE,'A')
		
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE,LOCATION)
					VALUES(6,6.1,'C','State/UT Tax',0,@SGST_PAY,0,@SGST_SGST_ADJ,@SGST_IGST_Adj ,0,0,@SGST_TAX,@SGST_INT,@SGST_FEE,'A')
		
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE,LOCATION)
					VALUES(6,6.1,'D','Cess',0,@cess_PAY,0,0,0 ,@CCESS_CCESS_Adj,0,@CCESS_TAX,0,0,'A')
					
	---(B) Reverse change 
   /*Added by Suraj Kumawat for Bug-30998 date on 12-12-2017 Start ... */
   declare @entry_ty varchar(2),@tran_cd int ,@date smalldatetime ,@sqlcommand nvarchar(4000),@whcon nvarchar(1000)
   set @entry_ty='GB'
   set @date =@EDATE 
   set @tran_cd =0 
   
   --Commented by Priyanka B on 22032018 for Bug-31364 Start
	/*select date as malldate,entry_all,main_tran,acseri_all,new_all=sum(new_all) 
	into #mall3B 
	from mainall_vw 
		inner join ac_mast a on (a.ac_id=mainall_vw.ac_id)	where
		 (a.typ Like '%GST Pay%' or a.typ Like  '%Cess payable%') and date <= @edate
		 group by Date,entry_all,main_tran,acseri_all
		 */
	--Commented by Priyanka B on 22032018 for Bug-31364 End
	
	--Modified by Priyanka B on 22032018 for Bug-31364 Start
	select mv.date as malldate,mv.entry_all,mv.main_tran,mv.acseri_all,new_all=sum(mv.new_all),b.u_cldt 
	into #mall3B 
	from mainall_vw mv
		inner join ac_mast a on (a.ac_id=mv.ac_id)	
		left outer join bpmain b on (mv.entry_ty=b.entry_ty and mv.tran_cd=b.tran_cd)
		where (a.typ Like '%GST Pay%' or a.typ Like  '%Cess payable%') 
		 --and (case when mv.entry_ty ='GB' then b.u_cldt else mv.date end) <= @edate
		 --and b.u_cldt between @sdate and @edate  --Commented by Priyanka B on 09052018 for UERP Installer 1.0.0
		 and b.u_cldt <= @edate  --Modified by Priyanka B on 09052018 for UERP Installer 1.0.0
		 group by mv.Date,mv.entry_all,mv.main_tran,mv.acseri_all,b.u_cldt
	--Modified by Priyanka B on 22032018 for Bug-31364 End

---( entry_ty+rtrim(cast(tran_cd as varchar)) ) <> ( @entry_ty+rtrim(cast(@tran_cd as varchar)))	and
	
	select sel=cast(0 as bit),m.entry_ty,m.tran_cd,ac.acserial,ac_name=ac_mast.ac_name,ac.amount,new_all=isnull(ac.amount,0),ac.amt_ty,ac_mast.typ
	,ac.Serty,party_nm=ac_mast.mailName,m.inv_no,m.date,tpayment=cast(0 as decimal(17,2)),m.l_yn,ac.ac_id,m.inv_sr,isused=0,m.net_amt,compid=0
	,TrnType=L.code_nm	Into #tmpsdata3B 	from SerTaxMain_vw m	INNER JOIN SerTaxAcDet_vw ac on (m.entry_ty=ac.entry_ty and m.tran_cd=ac.tran_cd)
	inner join ac_mast on (ac_mast.ac_id=m.ac_id) 	inner join lcode l on (l.entry_ty=m.entry_ty) 	WHERE 1=2
	
	insert Into #tmpsdata3B
	select sel=cast(0 as bit),m.entry_ty,m.tran_cd,ac.acserial,a.ac_name,ac.amount,new_all=isnull(mall.new_all,0),ac.amt_ty,a.typ
	,ac.Serty,party_nm=ac_mast.mailName,m.inv_no,m.date,tpayment=cast(0 as decimal(17,2)),m.l_yn,ac.ac_id,m.inv_sr,isused=0,m.net_amt,compid=0
	,TrnType=l.code_nm
	from SerTaxMain_vw m
	INNER JOIN SerTaxAcDet_vw ac on (m.entry_ty=ac.entry_ty and m.tran_cd=ac.tran_cd)
	inner join ac_mast on (ac_mast.ac_id=m.ac_id)
	inner join ac_mast a on (a.ac_id=ac.ac_id)
	inner join lcode l on (l.entry_ty=m.entry_ty)
	left join #mall3B mall on(ac.entry_ty=mall.entry_all and ac.tran_cd=main_tran and ac.acserial=acseri_all)
	-- and mall.malldate<@sdate)  --Commented by Priyanka B on 09052018 for UERP Installer 1.0.0
	where (a.typ  Like '%GST Pay%' or a.typ Like  '%Cess payable%')
	and ac.amt_ty='CR'
	---and ac.amount<>isnull(mall.new_all,0)----30998
	--and ac.date<=@date  --Commented by Priyanka B on 26032018 for Bug-31364
	--and ac.date between @sdate and @edate  --Modified by Priyanka B on 26032018 for Bug-31364  --Commented by Priyanka B on 09052018 for UERP Installer 1.0.0
	and ac.date <= @edate  --Modified by Priyanka B on 26032018 for Bug-31364  --Modified by Priyanka B on 09052018 for UERP Installer 1.0.0
	and (l.entry_ty in ('BP','CP','B1','C1','IF','OF') or l.bcode_nm in ('BP','CP','B1','C1','IF','OF'))
	AND AC.amount-(CASE WHEN MALL.U_CLDT BETWEEN @SDATE AND @EDATE THEN 0 ELSE ISNULL(MALL.NEW_ALL,0) END) > 0  --Added by Priyanka B on 09052018 for UERP Installer 1.0.0
	order by m.date,inv_no
	
	insert Into #tmpsdata3B
	select sel=cast(0 as bit),rm.entry_ty,rm.tran_cd,ac.acserial,a.ac_name,ac.amount,new_all=isnull(mall.new_all,0),ac.amt_ty,a.typ
	,Serty=ac.serty,party_nm=ac_mast.mailName,rm.inv_no,rm.date,tpayment=cast(0 as decimal(17,2)),l_yn='',ac.ac_id,rm.inv_sr,isused=0,rm.net_amt,compid=0
	,TrnType=l.code_nm
	from RevMain_vw rm 
	INNER JOIN SerTaxAcDet_vw ac on (rm.entry_ty=ac.entry_ty and rm.tran_cd=ac.tran_cd)
	inner join ac_mast on (ac_mast.ac_id=rm.ac_id)
	inner join ac_mast a on (a.ac_id=ac.ac_id)
	inner join lcode l on (l.entry_ty=rm.entry_ty)
	left join #mall3B mall on(ac.entry_ty=mall.entry_all and ac.tran_cd=main_tran and ac.acserial=acseri_all)
	-- and mall.malldate<@sdate)  --Commented by Priyanka B on 09052018 for UERP Installer 1.0.0
	where (a.typ  Like '%GST Pay%' or a.typ Like  '%Cess payable%')
	and ac.amt_ty='CR'
	--and ac.date <=@date  --Commented by Priyanka B on 26032018 for Bug-31364
	--and ac.date between @sdate and @edate  --Modified by Priyanka B on 26032018 for Bug-31364  --Commented by Priyanka B on 09052018 for UERP Installer 1.0.0
	and ac.date <=@edate  --Modified by Priyanka B on 26032018 for Bug-31364  --Modified by Priyanka B on 09052018 for UERP Installer 1.0.0
	and (l.entry_ty in ('PT','P1','E1','UB') or l.bcode_nm in ('PT','P1','E1'))
	AND AC.amount-(CASE WHEN MALL.U_CLDT BETWEEN @SDATE AND @EDATE THEN 0 ELSE ISNULL(MALL.NEW_ALL,0) END) > 0  --Added by Priyanka B on 09052018 for UERP Installer 1.0.0
	order by rm.date,rm.inv_no
	
	insert Into #tmpsdata3B
	select sel=cast(0 as bit),rm.entry_ty,rm.tran_cd,ac.acserial,a.ac_name,ac.amount,new_all=isnull(mall.new_all,0),ac.amt_ty,a.typ
	,Serty=ac.serty,party_nm=ac_mast.mailName,rm.inv_no,rm.date,tpayment=cast(0 as decimal(17,2)),l_yn='',ac.ac_id,rm.inv_sr,isused=0,rm.net_amt,compid=0
	,TrnType=l.code_nm
	from cnmain rm 
	INNER JOIN cnacdet ac on (rm.entry_ty=ac.entry_ty and rm.tran_cd=ac.tran_cd)
	inner join ac_mast on (ac_mast.ac_id=rm.ac_id)
	inner join ac_mast a on (a.ac_id=ac.ac_id)
	inner join lcode l on (l.entry_ty=rm.entry_ty)
	left join #mall3B mall on(ac.entry_ty=mall.entry_all and ac.tran_cd=main_tran and ac.acserial=acseri_all)
	-- and mall.malldate<@sdate)  --Commented by Priyanka B on 09052018 for UERP Installer 1.0.0
	where (a.typ  Like '%GST Pay%' or a.typ Like  '%Cess payable%')
	and ac.amt_ty='CR'
	and ac.date<=@date
	--and l.entry_ty ='C6'  --Commented by Priyanka B on 23032018 for Bug-31364
	and l.entry_ty in ('C6','GC')  --Modified by Priyanka B on 23032018 for Bug-31364
	--and rm.AGAINSTGS='SERVICE PURCHASE BILL'  --Commented by Priyanka B on 23032018 for Bug-31364
	and rm.AGAINSTGS in ('SERVICE PURCHASE BILL','PURCHASES')  --Modified by Priyanka B on 23032018 for Bug-31364
	AND AC.amount-(CASE WHEN MALL.U_CLDT BETWEEN @SDATE AND @EDATE THEN 0 ELSE ISNULL(MALL.NEW_ALL,0) END) > 0  --Added by Priyanka B on 09052018 for UERP Installer 1.0.0
	order by rm.date,rm.inv_no
	
	Select Entry_ty,Tran_cd,Rentry_ty,Itref_tran Into #Othref3B from Othitref group by Entry_ty,Tran_cd,Rentry_ty,Itref_tran 
	
	select sel=cast(0 as bit),rm.entry_ty,rm.tran_cd,ac.acserial,a.ac_name,ac.amount,new_all=isnull(mall.new_all,0),ac.amt_ty,a.typ
	,Serty=ac.serty,party_nm=ac_mast.mailName,rm.inv_no,rm.date,tpayment=cast(0 as decimal(17,2)),l_yn='',ac.ac_id,rm.inv_sr,isused=0,rm.net_amt,compid=0
	,TrnType=l.code_nm
	,o.itref_tran,o.rentry_ty
	Into #debit3B
	from Dnmain rm 
	INNER JOIN Dnacdet ac on (rm.entry_ty=ac.entry_ty and rm.tran_cd=ac.tran_cd)		
	inner join ac_mast on (ac_mast.ac_id=rm.ac_id)
	inner join ac_mast a on (a.ac_id=ac.ac_id)
	inner join lcode l on (l.entry_ty=rm.entry_ty)
	Inner Join #Othref3B o on (o.entry_ty=rm.entry_ty and o.Tran_cd=rm.Tran_cd)
	left join #mall3B mall on(ac.entry_ty=mall.entry_all and ac.tran_cd=main_tran and ac.acserial=acseri_all and mall.malldate<@sdate)
	where (a.typ  Like '%GST Pay%' or a.typ Like  '%Cess payable%')
	and ac.amt_ty='DR'
	and ac.date<=@date
	--and l.entry_ty ='D6'  --Commented by Priyanka B on 23032018 for Bug-31364
	and l.entry_ty in ('D6','GD')  --Modified by Priyanka B on 23032018 for Bug-31364
	--and rm.AGAINSTGS='SERVICE PURCHASE BILL'  --Modified by Priyanka B on 23032018 for Bug-31364
	and rm.AGAINSTGS in ('SERVICE PURCHASE BILL','PURCHASES')  --Commented by Priyanka B on 23032018 for Bug-31364
	order by rm.date,rm.inv_no
		
	Update #tmpsdata3B set amount=a.amount-b.amount 
		from #tmpsdata3B a 
		inner join #debit3B b on (a.entry_ty=b.rentry_ty and a.tran_cd=b.itref_tran and a.ac_id=b.ac_id and a.serty=b.serty)
		
	Delete from #tmpsdata3B where amount<=0
	
	SET @IGST_PAY = 0
	SET @CGST_PAY = 0
	SET @SGST_PAY = 0
	set @cess_PAY = 0
	
	select 
	--Commented by Priyanka B on 09052018 for UERP Installer 1.0.0 Start
	/*@IGST_PAY = sum((case when typ = 'IGST Payable'  then ( amount -(case when DATE NOT between @SDATE and @EDATE  then new_all else 0 end ))else 0 end)) ,
	@CGST_PAY = sum((case when typ = 'CGST Payable'  then  ( amount -(case when DATE NOT between @SDATE and @EDATE  then new_all else 0 end ))    else 0 end)) ,
	@SGST_PAY = sum((case when typ = 'SGST Payable'  then  ( amount -(case when DATE NOT between @SDATE and @EDATE  then new_all else 0 end ))   else 0 end)) ,
	@cess_PAY = sum((case when typ = 'COMP CESS PAYABLE'  then  ( amount -(case when DATE NOT between @SDATE and @EDATE  then new_all else 0 end ))    else 0 end)) 
	*/
	--Commented by Priyanka B on 09052018 for UERP Installer 1.0.0 End
	
	--Modified by Priyanka B on 09052018 for UERP Installer 1.0.0 Start
	@IGST_PAY = sum((case when typ = 'IGST Payable'  then (amount) else 0 end)) ,
	@CGST_PAY = sum((case when typ = 'CGST Payable'  then  (amount) else 0 end)) ,
	@SGST_PAY = sum((case when typ = 'SGST Payable'  then  (amount) else 0 end)) ,
	@cess_PAY = sum((case when typ = 'COMP CESS PAYABLE'  then  (amount) else 0 end)) 
	--Modified by Priyanka B on 09052018 for UERP Installer 1.0.0 End
	from #tmpsdata3B
	WHERE DATE <= @EDATE
		
	set @IGST_TAX =0
	set @SGST_TAX =0
	set @CGST_TAX =0
	SET @CCESS_TAX=0 
		
	select 	@IGST_TAX = sum((case when typ = 'IGST Payable'  then mall.new_all else 0 end)) ,
		@CGST_TAX = sum((case when typ = 'CGST Payable'  then  mall.new_all else 0 end)) ,
		@SGST_TAX = sum((case when typ = 'SGST Payable'  then mall.new_all else 0 end)) ,
		@CCESS_TAX = sum((case when typ = 'COMP CESS PAYABLE'  then mall.new_all else 0 end)) 
	from #tmpsdata3B ac
		--left outer join #mall3B mall on(ac.entry_ty=mall.entry_all and ac.tran_cd=main_tran and ac.acserial=acseri_all and mall.malldate between @SDATE and @EDATE)  --Commented by Priyanka B on 23032018 for Bug-31364
		left outer join #mall3B mall on(ac.entry_ty=mall.entry_all and ac.tran_cd=main_tran and ac.acserial=acseri_all and mall.u_cldt between @SDATE and @EDATE)  --Modified by Priyanka B on 23032018 for Bug-31364
	--WHERE DATE between @sdate and @EDATE 
	

	
	----Integrated Tax
	Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE,LOCATION)
					VALUES(6,6.1,'E','Integrated Tax',0,@IGST_PAY,0,0,0 ,0,0,@IGST_TAX,0,0,'B')
	----Central Tax
	Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE,LOCATION)
					VALUES(6,6.1,'F','Central Tax',0,@CGST_PAY,0,0,0,0,0,@CGST_TAX,0,0,'B')
	----State/UT Tax	
	Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE,LOCATION)
					VALUES(6,6.1,'G','State/UT Tax',0,@SGST_PAY,0,0,0 ,0,0,@SGST_TAX,0,0,'B')
	----Cess Tax 
	Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE,LOCATION )
					VALUES(6,6.1,'H','Cess',0,@cess_PAY,0,0,0 ,0,0,@CCESS_TAX,0,0,'B')
					
--Commented by Priyanka B on 23032018 for Bug-31364 Start
	---Other than RCM details. 
	/*update #GSTR3B set TAXABLEAMT = (ISNULL(TAXABLEAMT,0)- ISNULL(@IGST_PAY,0)),CESS_PAID =(isnull(CESS_PAID,0) - isnull(@IGST_TAX,0))	where PART=6 and PARTSR =6.1 and srno = 'A'
	update #GSTR3B set TAXABLEAMT = (ISNULL(TAXABLEAMT,0)- ISNULL(@CGST_PAY,0)),CESS_PAID =(isnull(CESS_PAID,0) - isnull(@CGST_TAX,0))	where PART=6 and PARTSR =6.1 and srno = 'B'
	update #GSTR3B set TAXABLEAMT = (ISNULL(TAXABLEAMT,0)- ISNULL(@SGST_PAY,0)),CESS_PAID =(isnull(CESS_PAID,0) - isnull(@SGST_TAX,0))	where PART=6 and PARTSR =6.1 and srno = 'C'
	update #GSTR3B set TAXABLEAMT = (ISNULL(TAXABLEAMT,0)- ISNULL(@cess_PAY,0)),CESS_PAID =(isnull(CESS_PAID,0) - isnull(@CCESS_TAX,0))	where PART=6 and PARTSR =6.1 and srno = 'D'
	*/
	--Commented by Priyanka B on 23032018 for Bug-31364 End
	
	----Drop Temproiry tables 
	drop table #mall3B
	drop table #tmpsdata3B
	drop table #Othref3B
	drop table #debit3B
  /*Added by Suraj Kumawat for Bug-30998 date on 12-12-2017 End ... */

	/* 6.2*/
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(6,6.2,'A','TDS',0,0,0,0,0 ,0,0,0,0,0)
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(6,6.2,'B','TCS',0,0,0,0,0 ,0,0,0,0,0)

		UPDATE #GSTR3B SET RPT_YEAR =YEAR(@SDATE),RPT_MTH=DATENAME(MM,@SDATE)

		IF ISNULL(@EXPARA,'') = ''
		   BEGIN
			SELECT  * FROM #GSTR3B ORDER BY PART,PARTSR,srno
		   END
		ELSE
		   BEGIN
			update  #GSTR3B set LOCATION =(select top 1 (CASE WHEN isnull(LetrCode,'')= '' THEN isnull(Code,'') ELSE isnull(LetrCode,'') END) from [state]  where [state] = #GSTR3B.location)
			--- Section 3.1 
				select  '3.1'  as section , 'Nature of Supplies' + '|' + 'Total Taxable value' + '|' + 'Integrated Tax'+ '|' + 'Central Tax'+ '|' +  'State/UT Tax' + '|' + 'Cess'  As ColumnDetails
				Union all 
				select '3.1' , rtrim(ltrim(descr))+ '|' + cast(ISNULL(TAXABLEAMT,0) as varchar)+ '|' + cast(ISNULL(IGST_AMT,0) as varchar)+ '|' + cast(ISNULL(CGST_AMT,0) as varchar)+ '|'+ cast(ISNULL(SGST_AMT,0) as varchar)+ '|' + cast(ISNULL(CESS_AMT,0)  as varchar)  as colun from #GSTR3B  WHERE PARTSR = '3.10'
				Union all 
				--- Section 3.2 
				select  '3.2'  as section , 'Description' + '|' + 'Place of Supply(State/UT)' + '|' + 'Total Taxable value' + '|' + 'Amount of Integrated Tax'  As ColumnDetails
				Union all 
				select '3.2' as section , rtrim(ltrim(descr))+ '|' + rtrim(ltrim(isnull(LOCATION,'')))+ '|' + cast(ISNULL(TAXABLEAMT,0) as varchar)+ '|' + cast(ISNULL(IGST_AMT,0) as varchar)  as ColumnDetails from #GSTR3B  WHERE PARTSR = '3.20'
				--- Section 4 
				Union all
				select  '4'  as section , 'Details' + '|' + 'Integrated Tax' + '|' + 'Central Tax' + '|' + 'State/UT Tax' + '|' + 'Cess' As ColumnDetails 
				Union all 
				select '4' as section, descr + '|' + cast(ISNULL(IGST_AMT,0) as varchar)+ '|' + cast(ISNULL(CGST_AMT,0) as varchar) + '|'  + cast(ISNULL(SGST_AMT,0) as varchar) + '|' + cast(ISNULL(CESS_AMT,0) as varchar) as ColumnDetails from #GSTR3B  WHERE PARTSR = '4'
				--- Section 5 
				Union all
				select  '5'  as section , 'Nature of Supplies' + '|' + 'Inter-State Supplies' + '|' + 'Intra-State Supplies' As Colum 
				Union all 
				select '5' as section ,descr + '|' + cast(ISNULL(IGST_AMT,0) as varchar)+ '|' + cast(ISNULL(CGST_AMT,0) as varchar)  as colun from #GSTR3B  WHERE PARTSR = '5'
				--- Section 6.1 
				Union all
				select  '6.1'  as section , 'Description' + '|' + 'Tax Payable' + '|' + 'Paid Through ITC Integrated Tax' + '|' + 'Paid Through ITC Central Tax' + '|' + 'Paid Through ITC State/UT Tax' + '|' + 'Paid Through ITC Cess' + '|' + 'Tax paid TDS/TCS' + '|' + 'Tax/Cess paid in cash' + '|' + 'Interest' + '|' + 'Late Fee' As ColumnDetails 
				Union all 
				select '6.1' as section , descr + '|' + cast(ISNULL(TAXABLEAMT,0) as varchar)+ '|' + cast(ISNULL(IGST_AMT,0) as varchar) + '|' + cast(ISNULL(CGST_AMT,0) as varchar)+ '|' + cast(ISNULL(SGST_AMT,0) as varchar)+ '|' + cast(ISNULL(CESS_AMT,0) as varchar)+ '|' + cast(ISNULL(TAX_PAID,0) as varchar)+ '|' + cast(ISNULL(CESS_PAID,0) as varchar)+ '|' + cast(ISNULL(INTEREST,0) as varchar)+ '|' + cast(ISNULL(LATE_FEE,0) as varchar)  as ColumnDetails from #GSTR3B  WHERE PARTSR = '6.1'
				--- Section 6.2 
				Union all
				select  '6.2'  as section , 'Details' + '|' + 'Integrated Tax' + '|' + 'Central Tax' + '|' + 'State/UT Tax'  As Colum 
				Union all 
				select '6.2' as section , descr + '|' + cast(ISNULL(IGST_AMT,0) as varchar) + '|' + cast(ISNULL(CGST_AMT,0) as varchar)+ '|' + cast(ISNULL(SGST_AMT,0) as varchar) as colun from #GSTR3B  WHERE PARTSR = '6.2'
		   END
		END
 


