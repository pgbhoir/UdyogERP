DROP PROCEDURE [USP_REP_ILEDGER_B_NF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Birendra Prasad
-- Create date: 14/08/2012
-- Description:	This is useful for Itemwise Batchwise Stock Ledger for item type exclude finish and semi-finish.
-- Modify date: 
-- Modified By: 
-- Modify date: 
-- Remark:
-- =============================================


Create PROCEDURE [USP_REP_ILEDGER_B_NF]
	@TMPAC NVARCHAR(60),@TMPIT NVARCHAR(60),@SPLCOND NVARCHAR(500),
	@SDATE SMALLDATETIME,@EDATE SMALLDATETIME,
	@SNAME NVARCHAR(60),@ENAME NVARCHAR(60),
	@SITEM NVARCHAR(60),@EITEM NVARCHAR(60),
	@SAMT NUMERIC,@EAMT NUMERIC,
	@SDEPT NVARCHAR(60),@EDEPT NVARCHAR(60),
	@SCAT NVARCHAR(60),@ECAT NVARCHAR(60),
	@SWARE NVARCHAR(60),@EWARE NVARCHAR(60),
	@SINVSR NVARCHAR(60),@EINVSR NVARCHAR(60),
	@FINYR NVARCHAR(20),@EXTPAR NVARCHAR(60)
	AS
Declare @FCON as NVARCHAR(4000),@SQLCOMMAND as NVARCHAR(4000)
	Declare @OPENTRIES as VARCHAR(50),@OPENTRY_TY as VARCHAR(50)
	Declare @TBLNM as VARCHAR(50),@TBLNAME1 as VARCHAR(50),@TBLNAME2 as VARCHAR(50)
	
	EXECUTE USP_REP_FILTCON 
		@VTMPAC=null,@VTMPIT=@TMPIT,@VSPLCOND=@SPLCOND,
		@VSDATE=null,@VEDATE=@EDATE,
		@VSAC =null,@VEAC =null,
		@VSIT=@SITEM,@VEIT=@EITEM,
		@VSAMT=null,@VEAMT=null,
		@VSDEPT=@SDEPT,@VEDEPT=@EDEPT,
		@VSCATE =@SCAT,@VECATE =@ECAT,
		@VSWARE =@SWARE,@VEWARE  =@EWARE,
		@VSINV_SR =@SINVSR,@VEINV_SR =@EINVSR,
		@VMAINFILE='MVW',@VITFILE='IVW',@VACFILE=null,
		@VDTFLD = 'DATE',@VLYN=null,@VEXPARA=@EXTPAR,
		@VFCON =@FCON OUTPUT

	SELECT IVW.TRAN_CD,IVW.ENTRY_TY,IVW.DATE,IVW.ITSERIAL,IVW.QTY,IVW.DC_NO,IVW.WARE_NM,MVW.INV_NO,LCODE.INV_STK,IVW.BATCHNO,IVW.MFGDT,IVW.EXPDT
	,AC_MAST.AC_ID,AC_MAST.AC_NAME,IT_MAST.IT_CODE,IT_MAST.IT_NAME,IT_MAST.RATEUNIT
	,BEH=(CASE WHEN LCODE.EXT_VOU=1 THEN LCODE.BCODE_NM ELSE LCODE.ENTRY_TY END)
	,it_mast.type
	INTO #TITEM1 FROM STKL_VW_ITEM IVW (NOLOCK)
	INNER JOIN AC_MAST (NOLOCK) ON IVW.AC_ID = AC_MAST.AC_ID
	INNER JOIN IT_MAST (NOLOCK) ON IVW.IT_CODE = IT_MAST.IT_CODE
	INNER JOIN LMAIN_VW MVW (NOLOCK) 
	ON IVW.TRAN_CD = MVW.TRAN_CD AND IVW.ENTRY_TY = MVW.ENTRY_TY
	INNER JOIN LCODE (NOLOCK) 
	ON IVW.ENTRY_TY = LCODE.ENTRY_TY AND LCODE.INV_STK IN ('+','-')
	WHERE 1=2

		

--	SET @SQLCOMMAND = 'INSERT INTO #TITEM1 SELECT IVW.TRAN_CD,IVW.ENTRY_TY,IVW.DATE,IVW.ITSERIAL,IVW.QTY,IVW.DC_NO,IVW.WARE_NM,MVW.INV_NO,LCODE.INV_STK,IVW.BATCHNO,IVW.MFGDT,IVW.EXPDT
--		,AC_MAST.AC_ID,AC_MAST.AC_NAME,IT_MAST.IT_CODE,IT_MAST.IT_NAME,IT_MAST.RATEUNIT
--		,BEH=(CASE WHEN LCODE.EXT_VOU=1 THEN LCODE.BCODE_NM ELSE LCODE.ENTRY_TY END)
--		FROM STKL_VW_ITEM IVW (NOLOCK)
--		INNER JOIN AC_MAST (NOLOCK) ON IVW.AC_ID = AC_MAST.AC_ID
--		INNER JOIN IT_MAST (NOLOCK) ON IVW.IT_CODE = IT_MAST.IT_CODE
--		INNER JOIN LMAIN_VW MVW (NOLOCK) 
--		ON IVW.TRAN_CD = MVW.TRAN_CD AND IVW.ENTRY_TY = MVW.ENTRY_TY
--		INNER JOIN LCODE (NOLOCK) 
--		ON IVW.ENTRY_TY = LCODE.ENTRY_TY AND LCODE.INV_STK IN ('+CHAR(39)+'+'+CHAR(39)+','+CHAR(39)+'-'+CHAR(39)+')'+RTRIM(@FCON) 
--	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' AND IVW.BATCHNO<>'+CHAR(39)+SPACE(1)+CHAR(39)+ ' AND IT_MAST.[TYPE] LIKE '+CHAR(39)+'%FINISHED%'+CHAR(39)+' AND IVW.ENTRY_TY NOT IN('+CHAR(39)+'ST'+CHAR(39)+','+CHAR(39)+'DC'+CHAR(39)+') AND IVW.DC_NO=SPACE(1)'
--Birendra:Start:
	SET @SQLCOMMAND = 'INSERT INTO #TITEM1 SELECT IVW.TRAN_CD,IVW.ENTRY_TY,IVW.DATE,IVW.ITSERIAL,IVW.QTY,IVW.DC_NO,IVW.WARE_NM,MVW.INV_NO,LCODE.INV_STK'
--IVW.BATCHNO,IVW.MFGDT,IVW.EXPDT'
	
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',BATCHNO=case when it_mast.type in (''Raw Material'',''Machinery/Stores'',''Packing Material'')then IVW.supbatchno else IVW.BATCHNO end,
		MFGDT=case when it_mast.type in (''Raw Material'',''Machinery/Stores'',''Packing Material'')then IVW.supMFGDT else IVW.MFGDT end
	,EXPDT=case when it_mast.type in (''Raw Material'',''Machinery/Stores'',''Packing Material'')then IVW.supEXPDT else IVW.EXPDT end'
	
	SET @SQLCOMMAND =@SQLCOMMAND+' '+'	,AC_MAST.AC_ID,AC_MAST.AC_NAME,IT_MAST.IT_CODE,IT_MAST.IT_NAME,IT_MAST.RATEUNIT
		,BEH=(CASE WHEN LCODE.EXT_VOU=1 THEN LCODE.BCODE_NM ELSE LCODE.ENTRY_TY END),it_mast.type
		FROM STKL_VW_ITEM IVW (NOLOCK)
		INNER JOIN AC_MAST (NOLOCK) ON IVW.AC_ID = AC_MAST.AC_ID
		INNER JOIN IT_MAST (NOLOCK) ON IVW.IT_CODE = IT_MAST.IT_CODE
		INNER JOIN LMAIN_VW MVW (NOLOCK) 
		ON IVW.TRAN_CD = MVW.TRAN_CD AND IVW.ENTRY_TY = MVW.ENTRY_TY
		INNER JOIN LCODE (NOLOCK) 
		ON IVW.ENTRY_TY = LCODE.ENTRY_TY AND LCODE.INV_STK IN ('+CHAR(39)+'+'+CHAR(39)+','+CHAR(39)+'-'+CHAR(39)+')'+RTRIM(@FCON) 
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' AND (IVW.BATCHNO<>'+CHAR(39)+SPACE(1)+CHAR(39)+' or IVW.SupBATCHNO<>'+CHAR(39)+SPACE(1)+CHAR(39)+') AND IVW.DC_NO=SPACE(1)'+'AND IT_MAST.[TYPE] Not LIKE '+CHAR(39)+'%FINISHED%'+CHAR(39)
--	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' AND IVW.BATCHNO<>'+CHAR(39)+SPACE(1)+CHAR(39)+ ' AND IT_MAST.[TYPE] LIKE '+CHAR(39)+'%FINISHED%'+CHAR(39)+' AND IVW.ENTRY_TY NOT IN('+CHAR(39)+'ST'+CHAR(39)+','+CHAR(39)+'DC'+CHAR(39)+') AND IVW.DC_NO=SPACE(1)'
--Birendra:End:
	PRINT @SQLCOMMAND
	EXECUTE SP_EXECUTESQL @SQLCOMMAND
	
	SET @SQLCOMMAND = 'INSERT INTO #TITEM1 SELECT IVW.TRAN_CD,IVW.ENTRY_TY,IVW.DATE,IVW.ITSERIAL,PROJECTITREF.QTY,IVW.DC_NO,IVW.WARE_NM,MVW.INV_NO,LCODE.INV_STK,PROJECTITREF.BATCHNO,PROJECTITREF.MFGDT,PROJECTITREF.EXPDT
		,AC_MAST.AC_ID,AC_MAST.AC_NAME,IT_MAST.IT_CODE,IT_MAST.IT_NAME,IT_MAST.RATEUNIT
		,BEH=(CASE WHEN LCODE.EXT_VOU=1 THEN LCODE.BCODE_NM ELSE LCODE.ENTRY_TY END),it_mast.type
		FROM PROJECTITREF
		INNER JOIN STKL_VW_ITEM  IVW ON (IVW.TRAN_CD=PROJECTITREF.TRAN_CD AND IVW.ENTRY_TY=PROJECTITREF.ENTRY_TY AND IVW.ITSERIAL=PROJECTITREF.ITSERIAL)
		INNER JOIN AC_MAST (NOLOCK) ON IVW.AC_ID = AC_MAST.AC_ID
		INNER JOIN IT_MAST (NOLOCK) ON IVW.IT_CODE = IT_MAST.IT_CODE
		INNER JOIN LMAIN_VW MVW (NOLOCK) 
		ON IVW.TRAN_CD = MVW.TRAN_CD AND IVW.ENTRY_TY = MVW.ENTRY_TY
		INNER JOIN LCODE (NOLOCK) 
		ON IVW.ENTRY_TY = LCODE.ENTRY_TY AND LCODE.INV_STK IN ('+CHAR(39)+'+'+CHAR(39)+','+CHAR(39)+'-'+CHAR(39)+')'+RTRIM(@FCON)
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' AND PROJECTITREF.BATCHNO<>'+CHAR(39)+SPACE(1)+CHAR(39)+ ' AND IT_MAST.[TYPE] LIKE '+CHAR(39)+'%FINISHED%'+CHAR(39)+' AND PROJECTITREF.ENTRY_TY IN('+CHAR(39)+'ST'+CHAR(39)+','+CHAR(39)+'DC'+CHAR(39)+') AND IVW.DC_NO=SPACE(1)'+'AND IT_MAST.[TYPE] Not LIKE '+CHAR(39)+'%FINISHED%'+CHAR(39)

	PRINT @SQLCOMMAND
	EXECUTE SP_EXECUTESQL @SQLCOMMAND

--Birendra :Start:
--update #titem1 set batchno= case when it_mast.type in ('Raw Material','Machinery/Stores','Packing Material')then isnull(STKL.supbatchno,'') else isnull(STKL.BATCHNO,'') end
--	,MFGDT= case when it_mast.type in ('Raw Material','Machinery/Stores','Packing Material')then isnull(STKL.supMFGDT,'') else isnull(STKL.MFGDT,'') end
--	,EXPDT= case when it_mast.type in ('Raw Material','Machinery/Stores','Packing Material')then isnull(STKL.supEXPDT,'') else isnull(STKL.EXPDT,'') end
--FROM IPITEM 
--inner join it_mast on (it_mast.it_code=ipitem.it_code)
--left join othitref on (othitref.entry_ty=ipitem.entry_ty and othitref.tran_cd=ipitem.tran_cd and othitref.itserial=ipitem.itserial)
--left join (select a.Entry_ty,a.tran_cd,a.itserial,a.batchno,a.mfgdt,a.expdt,a.supbatchno,a.supmfgdt,a.supexpdt from stkl_vw_item a inner join lcode b on (a.entry_ty=b.entry_ty) where b.inv_stk='+'  ) stkl on (stkl.entry_ty=othitref.rentry_ty and stkl.tran_cd=othitref.itref_tran and stkl.itserial=othitref.ritserial)
--where #titem1.entry_ty='IP'
--select * from #titem1
select 
a.tran_cd,a.entry_ty,a.date,a.itserial,qty=B.rqty,a.dc_no,a.ware_nm,a.inv_no,a.inv_stk,
BATCHNO = case when a.type in ('Raw Material','Machinery/Stores','Packing Material')then isnull(STKL.supbatchno,'') else isnull(STKL.BATCHNO,'') end,
MFGDT = case when a.type in ('Raw Material','Machinery/Stores','Packing Material')then isnull(STKL.supMFGDT,'') else isnull(STKL.MFGDT,'') end,
EXPDT = case when a.type in ('Raw Material','Machinery/Stores','Packing Material')then isnull(STKL.supEXPDT,'') else isnull(STKL.EXPDT,'') end,
a.ac_id,a.ac_name,a.it_code,a.it_name,a.rateunit,a.beh,a.type
into #titem3
from #titem1 a left join othitref b on (a.entry_ty=b.entry_ty and a.tran_cd=b.tran_cd and a.itserial=b.itserial)
left join (select x.Entry_ty,x.tran_cd,x.itserial,x.batchno,x.mfgdt,x.expdt,x.supbatchno,x.supmfgdt,x.supexpdt from stkl_vw_item x inner join lcode y on (x.entry_ty=y.entry_ty) where y.inv_stk='+'  ) stkl on (stkl.entry_ty=b.rentry_ty and stkl.tran_cd=b.itref_tran and stkl.itserial=b.ritserial)
where a.entry_ty='IP'

delete from #titem1  
where rtrim(entry_ty)+ltrim(rtrim(cast(tran_cd as varchar(10))))+rtrim(ltrim(itserial)) in (select rtrim(entry_ty)+ltrim(rtrim(cast(tran_cd as varchar(10))))+rtrim(ltrim(itserial)) from othitref where entry_ty='IP')

insert into #titem1 select * from #titem3

--Birendra :End:



	SELECT TRAN_CD=0,ENTRY_TY=' '
	,DATE=@SDATE
	,QTY=IsNull(sum(CASE WHEN TVW.INV_STK = '+' AND IsNull(TVW.DC_NO,' ') = ' ' THEN TVW.QTY END),0)
	 -IsNull(sum(CASE WHEN TVW.INV_STK = '-' AND IsNull(TVW.DC_NO,' ') = ' ' THEN TVW.QTY END),0)
	,ITSERIAL=' ',WARE_NM=' ',INV_NO=' ',AC_ID=0,AC_NAME='Balance B/f',INV_STK=' '
	,TVW.IT_CODE,TVW.IT_NAME,TVW.RATEUNIT
	,TVW.BATCHNO,TVW.MFGDT,TVW.EXPDT
	INTO #TITEM2 
	FROM  #TITEM1 TVW
	WHERE ((TVW.DATE < @SDATE) OR TVW.BEH IN ('OS')) 
	GROUP BY TVW.IT_CODE,TVW.IT_NAME,TVW.RATEUNIT,TVW.BATCHNO,TVW.MFGDT,TVW.EXPDT
	UNION ALL
	SELECT TVW.TRAN_CD,TVW.ENTRY_TY,TVW.DATE
	,QTY=IsNull(CASE WHEN TVW.INV_STK = '+' AND IsNull(TVW.DC_NO,' ') = ' ' THEN TVW.QTY END,0)
		  -IsNull(CASE WHEN TVW.INV_STK = '-' AND IsNull(TVW.DC_NO,' ') = ' ' THEN TVW.QTY END,0)
	,TVW.ITSERIAL,TVW.WARE_NM,TVW.INV_NO,TVW.AC_ID,TVW.AC_NAME,TVW.INV_STK
	,TVW.IT_CODE,TVW.IT_NAME,TVW.RATEUNIT
	,TVW.BATCHNO,TVW.MFGDT,TVW.EXPDT
	FROM #TITEM1 TVW
	WHERE ((TVW.DATE BETWEEN @SDATE AND @EDATE) AND TVW.ENTRY_TY NOT IN ('OS'))


SELECT TVW.* FROM #TITEM2 TVW	WHERE TVW.QTY <> 0 	ORDER BY TVW.IT_NAME,TVW.BATCHNO,TVW.DATE,TVW.INV_STK
EXECUTE SP_EXECUTESQL @SQLCOMMAND

DROP TABLE #TITEM1
DROP TABLE #TITEM2
DROP TABLE #TITEM3
GO
