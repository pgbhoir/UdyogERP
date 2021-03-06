If Exists(Select [Name] from Sysobjects where xType='v' and Id=Object_Id(N'VATITEM_VW'))
Begin
	Drop VIEW VATITEM_VW
End
Go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*-- =============================================
-- Author:		
-- Create date: 
-- Description:	This View is useful for VAT Reports.
-- Modification Date\By\Reason:31/09/2011  sandeep add for TKT-5093
-- Remark:
-- =============================================*/


CREATE VIEW [dbo].[VATITEM_VW] AS
SELECT     Tran_cd, entry_ty, date, doc_no, itserial, dc_no, party_nm, item, qty, inv_no, ware_nm, Ac_id, It_code,re_qty,TAX_NAME,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,TOT_FDISC,RATE,GRO_AMT,COMPID,ADDLVAT1=0,ADVATPER1=0   
FROM         dbo.BPITEM
UNION ALL
SELECT     Tran_cd, entry_ty, date, doc_no, itserial, dc_no, party_nm, item, qty, inv_no, ware_nm, Ac_id, It_code,re_qty,TAX_NAME,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,TOT_FDISC,RATE,GRO_AMT,COMPID,ADDLVAT1=0,ADVATPER1=0   
FROM         dbo.BRITEM
UNION ALL
SELECT     Tran_cd, entry_ty, date, doc_no, itserial, dc_no, party_nm, item, qty, inv_no, ware_nm, Ac_id, It_code,re_qty,TAX_NAME,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,TOT_FDISC,RATE,GRO_AMT,COMPID,ADDLVAT1=0,ADVATPER1=0   
FROM         dbo.CNITEM
UNION ALL
SELECT     Tran_cd, entry_ty, date, doc_no, itserial, dc_no, party_nm, item, qty, inv_no, ware_nm, Ac_id, It_code,re_qty,TAX_NAME,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,TOT_FDISC,RATE,GRO_AMT,COMPID,ADDLVAT1=0,ADVATPER1=0   
FROM         dbo.CPITEM
UNION ALL
SELECT     Tran_cd, entry_ty, date, doc_no, itserial, dc_no, party_nm, item, qty, inv_no, ware_nm, Ac_id, It_code,re_qty,TAX_NAME,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,TOT_FDISC,RATE,GRO_AMT,COMPID,ADDLVAT1=0,ADVATPER1=0   
FROM         dbo.CRITEM
UNION ALL
SELECT     Tran_cd, entry_ty, date, doc_no, itserial, dc_no, party_nm, item, qty, inv_no, ware_nm, Ac_id, It_code,re_qty,TAX_NAME,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,TOT_FDISC,RATE,GRO_AMT,COMPID,ADDLVAT1=0,ADVATPER1=0   
FROM         dbo.DNITEM
UNION ALL
SELECT     Tran_cd, entry_ty, date, doc_no, itserial, dc_no, party_nm, item, qty, inv_no, ware_nm, Ac_id, It_code,re_qty,TAX_NAME,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,TOT_FDISC,RATE,GRO_AMT,COMPID,ADDLVAT1=0,ADVATPER1=0   
FROM         dbo.EPITEM
UNION ALL
SELECT     Tran_cd, entry_ty, date, doc_no, itserial, dc_no, party_nm, item, qty, inv_no, ware_nm, Ac_id, It_code,re_qty,TAX_NAME,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,TOT_FDISC,RATE,GRO_AMT,COMPID,ADDLVAT1=0,ADVATPER1=0   
FROM         dbo.JVITEM
UNION ALL
SELECT     Tran_cd, entry_ty, date, doc_no, itserial, dc_no, party_nm, item, qty, inv_no, ware_nm, Ac_id, It_code,re_qty,TAX_NAME,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,TOT_FDISC,RATE,GRO_AMT,COMPID,ADDLVAT1,ADVATPER1   
FROM         dbo.PTITEM
UNION ALL
SELECT     Tran_cd, entry_ty, date, doc_no, itserial, dc_no, party_nm, item, qty, inv_no, ware_nm, Ac_id, It_code,re_qty,TAX_NAME,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,TOT_FDISC,RATE,GRO_AMT,COMPID,ADDLVAT1,ADVATPER1   
FROM         dbo.PRITEM
UNION ALL
SELECT     Tran_cd, entry_ty, date, doc_no, itserial, dc_no, party_nm, item, qty, inv_no, ware_nm, Ac_id, It_code,re_qty,TAX_NAME,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,TOT_FDISC,RATE,GRO_AMT,COMPID,ADDLVAT1,ADVATPER1 
FROM         dbo.SRITEM
UNION ALL
SELECT     Tran_cd, entry_ty, date, doc_no, itserial, dc_no, party_nm, item, qty, inv_no, ware_nm, Ac_id, It_code,re_qty,TAX_NAME,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,TOT_FDISC,RATE,GRO_AMT,COMPID,ADDLVAT1,ADVATPER1
FROM         dbo.STITEM
