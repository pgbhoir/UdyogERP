If exists(Select * from sysobjects where [name]='USP_REP_DL_VATFORM31' and xtype='P')
Begin
	Drop Procedure USP_REP_DL_VATFORM31
End
go

/*
EXECUTE USP_REP_DL_VATFORM31 '','','','04/01/2013','03/31/2015','','','','',0,0,'','','','','','','','','2011-2012',''
*/

-- =============================================
-- Author:		Pankaj M Borse.
-- Create date: 26/08/2014
-- Description:	This Stored procedure is useful to generate Delhi VAT Form 31
-- =============================================


create PROCEDURE [dbo].[USP_REP_DL_VATFORM31]
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
Begin


Declare @MCON as NVARCHAR(2000) 
EXECUTE USP_REP_SINGLE_CO_DATA_VAT
 '','','',@SDATE,@EDATE,'','','','',0,0,'','','','','','','','','','"ST","OTHER"',@MFCON = @MCON OUTPUT
 
SELECT A.DATE,A.INV_NO,A.S_TAX,A.AC_NAME,A.PER,per1=space(1)
--   Turnover of Inter-State Sale/Stock Transfer / Export (Deductions) 
,EXPORT=CASE WHEN A.ST_type='OUT OF COUNTRY' AND a.u_imporm='Export Out of India' AND A.BHENT='ST' THEN SUM(A.GRO_AMT)  ELSE 0 END 
,HIGHSEA=CASE WHEN A.ST_type='OUT OF COUNTRY' AND a.u_imporm='High Sea Sales' AND A.BHENT='ST'  THEN SUM(A.GRO_AMT) ELSE 0 END  
,jobwork=CASE WHEN A.ST_type='OUT OF STATE' AND A.BHENT='II' AND A.Rform_nm in ('FORM F','F FORM') AND A.BHENT='ST' AND A.TAX_NAME NOT LIKE '%C.S.T%'   THEN SUM(A.GRO_AMT) ELSE 0 END 
,JOBWORKRET=0
,BRANCHTRANS=CASE when A.ST_type='OUT OF STATE' AND  a.u_imporm='Branch Transfer' and A.Rform_nm in ('FORM F','F FORM') AND  a.Bhent='ST' AND A.TAX_NAME NOT LIKE '%C.S.T%' THEN SUM(A.GRO_AMT) ELSE 0 END
,CONSIGNMENT=CASE when A.ST_type='OUT OF STATE' AND  a.u_imporm='Consignment Transfer' and A.Rform_nm in ('FORM F','F FORM') AND  a.Bhent='ST' AND A.TAX_NAME NOT LIKE '%C.S.T%' THEN SUM(A.GRO_AMT) ELSE 0 END
,HFORM=CASE when A.ST_type='OUT OF STATE' and A.Rform_nm in ('FORM H','H FORM') AND  a.Bhent='ST' AND A.TAX_NAME NOT LIKE '%C.S.T%' THEN SUM(A.GRO_AMT) ELSE 0 END
,IFORM=CASE when A.ST_type='OUT OF STATE' and A.Rform_nm in ('FORM I','I FORM') AND  a.Bhent='ST' AND A.TAX_NAME NOT LIKE '%C.S.T%' THEN SUM(A.GRO_AMT) ELSE 0 END
,JFORM=CASE when A.ST_type='OUT OF STATE' and A.Rform_nm in ('FORM J','J FORM') AND  a.Bhent='ST' AND A.TAX_NAME NOT LIKE '%C.S.T%' THEN SUM(A.GRO_AMT) ELSE 0 END
,CEFORM=CASE when A.ST_type='OUT OF STATE' and A.Rform_nm in ('FORM C','C FORM','FORM E','E FORM') AND  a.Bhent='ST' AND A.TAX_NAME NOT LIKE '%C.S.T%' THEN SUM(A.GRO_AMT) ELSE 0 END
,OUTDELHI=CASE when A.ST_type='OUT OF STATE' and A.TAX_NAME NOT IN ('','EXEMPTED') AND A.RFORM_NM='' AND A.u_imporm='' AND  a.Bhent='ST' AND A.TAX_NAME NOT LIKE '%C.S.T%' THEN SUM(A.GRO_AMT) ELSE 0 END
--  Turnover of Inter-State Sale (Taxable)
,RATECST=CASE WHEN A.ST_type='OUT OF STATE' AND A.TAX_NAME LIKE '%C.S.T%' AND A.BHENT='ST' THEN A.PER ELSE 0 END
,CFORM=CASE WHEN A.ST_type='OUT OF STATE'  and A.Rform_nm in ('FORM C','C FORM') AND A.BHENT='ST' AND A.ITEMTYPE='I' THEN SUM(A.GRO_AMT) ELSE 0 END
,CAPCFORM=CASE WHEN A.ST_type='OUT OF STATE'  and A.Rform_nm in ('FORM C','C FORM') AND A.BHENT='ST' AND A.ITEMTYPE='C' THEN SUM(A.GRO_AMT) ELSE 0 END
,WITHOUTFORM=CASE WHEN A.ST_type='OUT OF STATE' AND A.TAX_NAME NOT LIKE '%C.S.T%' and A.Rform_nm='' AND A.BHENT='ST' THEN SUM(A.GRO_AMT) ELSE 0 END
,TAXCST=CASE WHEN A.ST_type='OUT OF STATE' AND A.TAX_NAME LIKE '%C.S.T%' and A.Rform_nm='' AND A.BHENT='ST' THEN SUM(A.TAXAMT) ELSE 0 END
--  Turnover of Local Sale 
,VATTURNOVER=CASE WHEN A.ST_type='LOCAL' AND A.TAX_NAME LIKE '%VAT%' and A.Rform_nm='' AND A.BHENT='ST' THEN SUM(A.VATONAMT) ELSE 0 END
,WC=0
,TAXVAT=CASE WHEN A.ST_type='LOCAL' AND A.TAX_NAME LIKE '%VAT%' and A.Rform_nm='' AND A.BHENT='ST' THEN SUM(A.TAXAMT) ELSE 0 END
,HFORMLOCAL=CASE WHEN A.ST_type='LOCAL' and A.Rform_nm in ('FORM H','H FORM') AND A.BHENT='ST' THEN SUM(A.GRO_AMT) ELSE 0 END
,PETROL=CASE WHEN (it.it_name like '%Diesel%') or (it.it_name like '%Petrol%') AND a.st_type='LOCAL'  and  a.Bhent='ST' THEN SUM(A.GRO_AMT) ELSE 0 END
,grp=space(1)
FROM VATTBL A
INNER JOIN IT_MAST IT ON (A.IT_CODE=IT.IT_CODE)
GROUP BY A.DATE,A.INV_NO,A.S_TAX,A.AC_NAME,A.PER,A.ST_TYPE,A.U_IMPORM,A.BHENT,A.RFORM_NM,A.TAX_NAME,A.ITEMTYPE,IT.IT_NAME

end
