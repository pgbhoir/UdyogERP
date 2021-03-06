DROP VIEW [mainall_vw]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date: 
-- Description:	
-- Modification Date/By/Reason: 15/03/2012 Amrendra : For Multi Currency Bug-1365
-- Guid line to update Bug-1365-->As your view may have some costomization so just manually add following in your view  
--		0 as fcre_all --->(1) for All except for multicurrency enabled transaction 
--		fcre_all      --->(2) for enabling Multicurrency in Taransaction 
-- Example: Add (1) in all select section
--          If you want Multi currency in PT just add (2) in PTMALL Table column list
-- =============================================

CREATE VIEW [mainall_vw]
AS
--Please read instruction above then add it manualy in all select downwards
SELECT     Main_tran, Tran_cd, ENTRY_TY,ACSERIAL, date, doc_no, inv_no, party_nm, new_all, ENTRY_ALL,ACSERI_ALL, inv_sr, tds, disc, l_yn, net_amt, Ac_id, date_all,0 as serbamt,0 as sercamt,0 as serhamt,COMPID,0 as fcre_all
FROM         dbo.ARMALL
UNION ALL
SELECT     Main_tran, Tran_cd, ENTRY_TY,ACSERIAL, date, doc_no, inv_no, party_nm, new_all, ENTRY_ALL,ACSERI_ALL, inv_sr, tds, disc, l_yn, net_amt, Ac_id, date_all,serbamt,sercamt,serhamt,COMPID,0 as fcre_all
FROM         dbo.BPMALL
UNION ALL
SELECT     Main_tran, Tran_cd, ENTRY_TY,ACSERIAL, date, doc_no, inv_no, party_nm, new_all, ENTRY_ALL,ACSERI_ALL, inv_sr, tds, disc, l_yn, net_amt, Ac_id, date_all,serbamt,sercamt,serhamt,COMPID,0 as fcre_all
FROM         dbo.BRMALL
UNION ALL
SELECT     Main_tran, Tran_cd, ENTRY_TY,ACSERIAL, date, doc_no, inv_no, party_nm, new_all, ENTRY_ALL,ACSERI_ALL, inv_sr, tds, disc, l_yn, net_amt, Ac_id, date_all,0 as serbamt,0 as sercamt,0 as serhamt,COMPID,0 as fcre_all
FROM         dbo.CNMALL
UNION ALL
SELECT     Main_tran, Tran_cd, ENTRY_TY,ACSERIAL, date, doc_no, inv_no, party_nm, new_all, ENTRY_ALL,ACSERI_ALL, inv_sr, tds, disc, l_yn, net_amt, Ac_id, date_all,0 as serbamt,0 as sercamt,0 as serhamt,COMPID,0 as fcre_all
FROM         dbo.CPMALL
UNION ALL
SELECT     Main_tran, Tran_cd, ENTRY_TY,ACSERIAL, date, doc_no, inv_no, party_nm, new_all, ENTRY_ALL,ACSERI_ALL, inv_sr, tds, disc, l_yn, net_amt, Ac_id, date_all,0 as serbamt,0 as sercamt,0 as serhamt,COMPID,0 as fcre_all
FROM         dbo.CRMALL
UNION ALL
SELECT     Main_tran, Tran_cd, ENTRY_TY,ACSERIAL, date, doc_no, inv_no, party_nm, new_all, ENTRY_ALL,ACSERI_ALL, inv_sr, tds, disc, l_yn, net_amt, Ac_id, date_all,0 as serbamt,0 as sercamt,0 as serhamt,COMPID,0 as fcre_all
FROM         dbo.DCMALL
UNION ALL
SELECT     Main_tran, Tran_cd, ENTRY_TY,ACSERIAL, date, doc_no, inv_no, party_nm, new_all, ENTRY_ALL,ACSERI_ALL, inv_sr, tds, disc, l_yn, net_amt, Ac_id, date_all,0 as serbamt,0 as sercamt,0 as serhamt,COMPID,0 as fcre_all
FROM         dbo.DNMALL
UNION ALL
SELECT     Main_tran, Tran_cd, ENTRY_TY,ACSERIAL, date, doc_no, inv_no, party_nm, new_all, ENTRY_ALL,ACSERI_ALL, inv_sr, tds, disc, l_yn, net_amt, Ac_id, date_all,0 as serbamt,0 as sercamt,0 as serhamt,COMPID,0 as fcre_all
FROM         dbo.EPMALL
UNION ALL
SELECT     Main_tran, Tran_cd, ENTRY_TY,ACSERIAL, date, doc_no, inv_no, party_nm, new_all, ENTRY_ALL,ACSERI_ALL, inv_sr, tds, disc, l_yn, net_amt, Ac_id, date_all,0 as serbamt,0 as sercamt,0 as serhamt,COMPID,0 as fcre_all
FROM         dbo.EQMALL
UNION ALL
SELECT     Main_tran, Tran_cd, ENTRY_TY,ACSERIAL, date, doc_no, inv_no, party_nm, new_all, ENTRY_ALL,ACSERI_ALL, inv_sr, tds, disc, l_yn, net_amt, Ac_id, date_all,0 as serbamt,0 as sercamt,0 as serhamt,COMPID,0 as fcre_all
FROM         dbo.ESMALL
UNION ALL
SELECT     Main_tran, Tran_cd, ENTRY_TY,ACSERIAL, date, doc_no, inv_no, party_nm, new_all, ENTRY_ALL,ACSERI_ALL, inv_sr, tds, disc, l_yn, net_amt, Ac_id, date_all,0 as serbamt,0 as sercamt,0 as serhamt,COMPID,0 as fcre_all
FROM         dbo.IIMALL
UNION ALL
SELECT     Main_tran, Tran_cd, ENTRY_TY,ACSERIAL, date, doc_no, inv_no, party_nm, new_all, ENTRY_ALL,ACSERI_ALL, inv_sr, tds, disc, l_yn, net_amt, Ac_id, date_all,0 as serbamt,0 as sercamt,0 as serhamt,COMPID,0 as fcre_all
FROM         dbo.IPMALL
UNION ALL
SELECT     Main_tran, Tran_cd, ENTRY_TY,ACSERIAL, date, doc_no, inv_no, party_nm, new_all, ENTRY_ALL,ACSERI_ALL, inv_sr, tds, disc, l_yn, net_amt, Ac_id, date_all,0 as serbamt,0 as sercamt,0 as serhamt,COMPID,0 as fcre_all
FROM         dbo.IRMALL
UNION ALL
SELECT     Main_tran, Tran_cd, ENTRY_TY,ACSERIAL, date, doc_no, inv_no, party_nm, new_all, ENTRY_ALL,ACSERI_ALL, inv_sr, tds, disc, l_yn, net_amt, Ac_id, date_all,0 as serbamt,0 as sercamt,0 as serhamt,COMPID,0 as fcre_all
FROM         dbo.JVMALL
UNION ALL
SELECT     Main_tran, Tran_cd, ENTRY_TY,ACSERIAL, date, doc_no, inv_no, party_nm, new_all, ENTRY_ALL,ACSERI_ALL, inv_sr, tds, disc, l_yn, net_amt, Ac_id, date_all,0 as serbamt,0 as sercamt,0 as serhamt,COMPID,0 as fcre_all
FROM         dbo.OBMALL
UNION ALL
SELECT     Main_tran, Tran_cd, ENTRY_TY,ACSERIAL, date, doc_no, inv_no, party_nm, new_all, ENTRY_ALL,ACSERI_ALL, inv_sr, tds, disc, l_yn, net_amt, Ac_id, date_all,0 as serbamt,0 as sercamt,0 as serhamt,COMPID,0 as fcre_all
FROM         dbo.OPMALL
UNION ALL
SELECT     Main_tran, Tran_cd, ENTRY_TY,ACSERIAL, date, doc_no, inv_no, party_nm, new_all, ENTRY_ALL,ACSERI_ALL, inv_sr, tds, disc, l_yn, net_amt, Ac_id, date_all,0 as serbamt,0 as sercamt,0 as serhamt,COMPID,0 as fcre_all
FROM         dbo.PCMALL
UNION ALL
SELECT     Main_tran, Tran_cd, ENTRY_TY,ACSERIAL, date, doc_no, inv_no, party_nm, new_all, ENTRY_ALL,ACSERI_ALL, inv_sr, tds, disc, l_yn, net_amt, Ac_id, date_all,0 as serbamt,0 as sercamt,0 as serhamt,COMPID,0 as fcre_all
FROM         dbo.POMALL
UNION ALL
SELECT     Main_tran, Tran_cd, ENTRY_TY,ACSERIAL, date, doc_no, inv_no, party_nm, new_all, ENTRY_ALL,ACSERI_ALL, inv_sr, tds, disc, l_yn, net_amt, Ac_id, date_all,0 as serbamt,0 as sercamt,0 as serhamt,COMPID,0 as fcre_all
FROM         dbo.PTMALL
UNION ALL
SELECT     Main_tran, Tran_cd, ENTRY_TY,ACSERIAL, date, doc_no, inv_no, party_nm, new_all, ENTRY_ALL,ACSERI_ALL, inv_sr, tds, disc, l_yn, net_amt, Ac_id, date_all,0 as serbamt,0 as sercamt,0 as serhamt,COMPID,0 as fcre_all
FROM         dbo.PRMALL
UNION ALL
SELECT     Main_tran, Tran_cd, ENTRY_TY,ACSERIAL, date, doc_no, inv_no, party_nm, new_all, ENTRY_ALL,ACSERI_ALL, inv_sr, tds, disc, l_yn, net_amt, Ac_id, date_all,0 as serbamt,0 as sercamt,0 as serhamt,COMPID,0 as fcre_all
FROM         dbo.SOMALL
UNION ALL
SELECT     Main_tran, Tran_cd, ENTRY_TY,ACSERIAL, date, doc_no, inv_no, party_nm, new_all, ENTRY_ALL,ACSERI_ALL, inv_sr, tds, disc, l_yn, net_amt, Ac_id, date_all,0 as serbamt,0 as sercamt,0 as serhamt,COMPID,0 as fcre_all
FROM         dbo.SQMALL
UNION ALL
SELECT     Main_tran, Tran_cd, ENTRY_TY,ACSERIAL, date, doc_no, inv_no, party_nm, new_all, ENTRY_ALL,ACSERI_ALL, inv_sr, tds, disc, l_yn, net_amt, Ac_id, date_all,0 as serbamt,0 as sercamt,0 as serhamt,COMPID,0 as fcre_all
FROM         dbo.SRMALL
UNION ALL
SELECT     Main_tran, Tran_cd, ENTRY_TY,ACSERIAL, date, doc_no, inv_no, party_nm, new_all, ENTRY_ALL,ACSERI_ALL, inv_sr, tds, disc, l_yn, net_amt, Ac_id, date_all,0 as serbamt,0 as sercamt,0 as serhamt,COMPID,0 as fcre_all
FROM         dbo.SSMALL
UNION ALL
SELECT     Main_tran, Tran_cd, ENTRY_TY,ACSERIAL, date, doc_no, inv_no, party_nm, new_all, ENTRY_ALL,ACSERI_ALL, inv_sr, tds, disc, l_yn, net_amt, Ac_id, date_all,0 as serbamt,0 as sercamt,0 as serhamt,COMPID,0 as fcre_all
FROM         dbo.STMALL
UNION ALL
SELECT     Main_tran, Tran_cd, ENTRY_TY,ACSERIAL, date, doc_no, inv_no, party_nm, new_all, ENTRY_ALL,ACSERI_ALL, inv_sr, tds, disc, l_yn, net_amt, Ac_id, date_all,0 as serbamt,0 as sercamt,0 as serhamt,COMPID,0 as fcre_all
FROM         dbo.TRMALL
UNION ALL
SELECT     Main_tran, Tran_cd, ENTRY_TY,ACSERIAL, date, doc_no, inv_no, party_nm, new_all, ENTRY_ALL,ACSERI_ALL, inv_sr, tds, disc, l_yn, net_amt, Ac_id, date_all,0 as serbamt,0 as sercamt,0 as serhamt,COMPID,0 as fcre_all
FROM         dbo.SBMALL
UNION ALL
SELECT     Main_tran, Tran_cd, ENTRY_TY,ACSERIAL, date, doc_no, inv_no, party_nm, new_all, ENTRY_ALL,ACSERI_ALL, inv_sr, tds, disc, l_yn, net_amt, Ac_id, date_all,0 as serbamt,0 as sercamt,0 as serhamt,COMPID,0 as fcre_all
FROM         dbo.SDMALL
UNION ALL
SELECT     Main_tran, Tran_cd, ENTRY_TY,ACSERIAL, date, doc_no, inv_no, party_nm, new_all, ENTRY_ALL,ACSERI_ALL, inv_sr, tds, disc, l_yn, net_amt, Ac_id, date_all,0 as serbamt,0 as sercamt,0 as serhamt,COMPID,0 as fcre_all
FROM         dbo.OSMALL
UNION ALL
SELECT     Main_tran, Tran_cd, ENTRY_TY,ACSERIAL, date, doc_no, inv_no, party_nm, new_all, ENTRY_ALL,ACSERI_ALL, inv_sr, tds, disc, l_yn, net_amt, Ac_id, date_all,0 as serbamt,0 as sercamt,0 as serhamt,COMPID,0 as fcre_all
FROM         dbo.MALL
UNION ALL
SELECT     Main_tran, Tran_cd, ENTRY_TY,ACSERIAL, date, doc_no, inv_no, party_nm, new_all, ENTRY_ALL,ACSERI_ALL, inv_sr, tds, disc, l_yn, net_amt, Ac_id, date_all,0 as serbamt,0 as sercamt,0 as serhamt,COMPID,0 as fcre_all 
FROM         dbo.NEWYEAR_ALLOC
GO
