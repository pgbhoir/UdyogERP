IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[EX_VW_ACDET]'))
begin
	DROP VIEW [dbo].[EX_VW_ACDET]
end
go
-- =============================================
-- Author:		Ruepesh Prajapati
-- Create date: 
-- Description:	This View is used in Excise Mfg.  Reports.
-- Modification Date/By/Reason: 08/06/2011 Rupesh Prajapati. Change date as u_cldt for EpAcDet
-- Remark: 
-- =============================================

CREATE view [dbo].[EX_VW_ACDET] as
SELECT     E.Tran_cd, E.entry_ty, E.date, E.doc_no, E.Ac_id, E.acserial,E.amount, E.amt_ty, E.u_cldt, E.l_yn, E.u_rg23no, E.u_rg23cno, E.u_plasr
FROM         dbo.STACDET AS E INNER JOIN
                      dbo.AC_MAST AS F ON E.Ac_id = F.Ac_id
WHERE     (F.typ = 'EXCISE')
UNION
SELECT     E.Tran_cd, E.entry_ty, E.date, E.doc_no, E.Ac_id, E.acserial,E.amount, E.amt_ty, E.u_cldt, E.l_yn, E.u_rg23no, E.u_rg23cno, E.u_plasr
FROM         dbo.SBACDET AS E INNER JOIN
                      dbo.AC_MAST AS F ON E.Ac_id = F.Ac_id
WHERE     (F.typ = 'EXCISE')
UNION
SELECT     E.Tran_cd, E.entry_ty, E.date, E.doc_no, E.Ac_id, E.acserial,E.amount, E.amt_ty, E.u_cldt, E.l_yn, E.u_rg23no, E.u_rg23cno, E.u_plasr
FROM         dbo.SDACDET AS E INNER JOIN
                      dbo.AC_MAST AS F ON E.Ac_id = F.Ac_id
WHERE     (F.typ = 'EXCISE')
UNION
SELECT     E.Tran_cd, E.entry_ty, E.date, E.doc_no, E.Ac_id, E.acserial,E.amount, E.amt_ty, E.u_cldt, E.l_yn, E.u_rg23no, E.u_rg23cno, E.u_plasr
FROM         dbo.PTACDET AS E INNER JOIN
                      dbo.AC_MAST AS F ON E.Ac_id = F.Ac_id
WHERE     (F.typ = 'EXCISE')
UNION
SELECT     E.Tran_cd, E.entry_ty, E.date, E.doc_no, E.Ac_id, E.acserial,E.amount, E.amt_ty, '01/01/1890' AS U_CLDT, E.l_yn, SPACE(1) AS U_RG23NO, SPACE(1) 
                      AS U_RG23CNO, SPACE(1) AS U_PLASR
FROM         dbo.ARACDET AS E INNER JOIN
                      dbo.AC_MAST AS F ON E.Ac_id = F.Ac_id
WHERE     (F.typ = 'EXCISE')
UNION
SELECT     E.Tran_cd, E.entry_ty, E.date, E.doc_no, E.Ac_id, E.acserial,E.amount, E.amt_ty, E.U_CLDT, E.l_yn, E.U_RG23NO, E.U_RG23CNO, E.U_PLASR
FROM         dbo.OBACDET AS E INNER JOIN
                      dbo.AC_MAST AS F ON E.Ac_id = F.Ac_id
WHERE     (F.typ = 'EXCISE')
UNION
SELECT     E.Tran_cd, E.entry_ty, E.date, E.doc_no, E.Ac_id, E.acserial,E.amount, E.amt_ty, E.u_cldt, E.l_yn, E.u_rg23no, E.u_rg23cno, E.u_plasr
FROM         dbo.BPACDET AS E INNER JOIN
                      dbo.AC_MAST AS F ON E.Ac_id = F.Ac_id
WHERE     (F.typ = 'EXCISE')
UNION
SELECT     E.Tran_cd, E.entry_ty, E.date, E.doc_no, E.Ac_id, E.acserial,E.amount, E.amt_ty, E.u_cldt, E.l_yn, E.u_rg23no, E.u_rg23cno, E.u_plasr
FROM         dbo.BRACDET AS E INNER JOIN
                      dbo.AC_MAST AS F ON E.Ac_id = F.Ac_id
WHERE     (F.typ = 'EXCISE')
UNION
SELECT     E.Tran_cd, E.entry_ty, E.date, E.doc_no, E.Ac_id, E.acserial,E.amount, E.amt_ty, '01/01/1890' AS U_CLDT, E.l_yn, SPACE(1) AS U_RG23NO, SPACE(1) 
                      AS U_RG23CNO, SPACE(1) AS U_PLASR
FROM         dbo.CNACDET AS E INNER JOIN
                      dbo.AC_MAST AS F ON E.Ac_id = F.Ac_id
WHERE     (F.typ = 'EXCISE')
UNION
SELECT     E.Tran_cd, E.entry_ty, E.date, E.doc_no, E.Ac_id, E.acserial,E.amount, E.amt_ty, U_CLDT, E.l_yn, SPACE(1) AS U_RG23NO, SPACE(1) 
                      AS U_RG23CNO, SPACE(1) AS U_PLASR
FROM         dbo.CPACDET AS E INNER JOIN
                      dbo.AC_MAST AS F ON E.Ac_id = F.Ac_id
WHERE     (F.typ = 'EXCISE')
UNION
SELECT     E.Tran_cd, E.entry_ty, E.date, E.doc_no, E.Ac_id, E.acserial,E.amount, E.amt_ty, U_CLDT, E.l_yn, U_RG23NO, U_RG23CNO, SPACE(1) AS U_PLASR
FROM         dbo.IIACDET AS E INNER JOIN
                      dbo.AC_MAST AS F ON E.Ac_id = F.Ac_id
WHERE     (F.typ = 'EXCISE')
UNION
SELECT     E.Tran_cd, E.entry_ty, E.date, E.doc_no, E.Ac_id, E.acserial,E.amount, E.amt_ty, '01/01/1890' AS U_CLDT, E.l_yn, SPACE(1) AS U_RG23NO, SPACE(1) 
                      AS U_RG23CNO, SPACE(1) AS U_PLASR
FROM         dbo.PCACDET AS E INNER JOIN
                      dbo.AC_MAST AS F ON E.Ac_id = F.Ac_id
WHERE     (F.typ = 'EXCISE')
UNION
SELECT     E.Tran_cd, E.entry_ty, E.date, E.doc_no, E.Ac_id, E.acserial,E.amount, E.amt_ty, '01/01/1890' AS U_CLDT, E.l_yn, SPACE(1) AS U_RG23NO, SPACE(1) 
                      AS U_RG23CNO, SPACE(1) AS U_PLASR
FROM         dbo.POACDET AS E INNER JOIN
                      dbo.AC_MAST AS F ON E.Ac_id = F.Ac_id
WHERE     (F.typ = 'EXCISE')
UNION
SELECT     E.Tran_cd, E.entry_ty, E.date, E.doc_no, E.Ac_id, E.acserial,E.amount, E.amt_ty, '01/01/1890' AS U_CLDT, E.l_yn, SPACE(1) AS U_RG23NO, SPACE(1) 
                      AS U_RG23CNO, SPACE(1) AS U_PLASR
FROM         dbo.SOACDET AS E INNER JOIN
                      dbo.AC_MAST AS F ON E.Ac_id = F.Ac_id
WHERE     (F.typ = 'EXCISE')
UNION
SELECT     E.Tran_cd, E.entry_ty, E.date, E.doc_no, E.Ac_id, E.acserial,E.amount, E.amt_ty, '01/01/1890' AS U_CLDT, E.l_yn, SPACE(1) AS U_RG23NO, SPACE(1) 
                      AS U_RG23CNO, SPACE(1) AS U_PLASR
FROM         dbo.SQACDET AS E INNER JOIN
                      dbo.AC_MAST AS F ON E.Ac_id = F.Ac_id
WHERE     (F.typ = 'EXCISE')
UNION
SELECT     E.Tran_cd, E.entry_ty, E.date, E.doc_no, E.Ac_id, E.acserial,E.amount, E.amt_ty, E.u_cldt, E.l_yn, E.u_rg23no, E.u_rg23cno, E.u_plasr
FROM         dbo.SRACDET AS E INNER JOIN
                      dbo.AC_MAST AS F ON E.Ac_id = F.Ac_id
WHERE     (F.typ = 'EXCISE')
UNION
SELECT     E.Tran_cd, E.entry_ty, E.date, E.doc_no, E.Ac_id, E.acserial,E.amount, E.amt_ty, '01/01/1890' AS U_CLDT, E.l_yn, SPACE(1) AS U_RG23NO, SPACE(1) 
                      AS U_RG23CNO, SPACE(1) AS U_PLASR
FROM         dbo.DCACDET AS E INNER JOIN
                      dbo.AC_MAST AS F ON E.Ac_id = F.Ac_id
WHERE     (F.typ = 'EXCISE')
UNION
SELECT     E.Tran_cd, E.entry_ty, E.date, E.doc_no, E.Ac_id, E.acserial,E.amount, E.amt_ty, '01/01/1890' AS U_CLDT, E.l_yn, SPACE(1) AS U_RG23NO, SPACE(1) 
                      AS U_RG23CNO, SPACE(1) AS U_PLASR
FROM         dbo.CRACDET AS E INNER JOIN
                      dbo.AC_MAST AS F ON E.Ac_id = F.Ac_id
WHERE     (F.typ = 'EXCISE')
UNION
SELECT     E.Tran_cd, E.entry_ty, E.date, E.doc_no, E.Ac_id, E.acserial,E.amount, E.amt_ty, '01/01/1890' AS U_CLDT, E.l_yn, SPACE(1) AS U_RG23NO, SPACE(1) 
                      AS U_RG23CNO, SPACE(1) AS U_PLASR
FROM         dbo.DNACDET AS E INNER JOIN
                      dbo.AC_MAST AS F ON E.Ac_id = F.Ac_id
WHERE     (F.typ = 'EXCISE')
UNION
SELECT     E.Tran_cd, E.entry_ty, E.date, E.doc_no, E.Ac_id, E.acserial,E.amount, E.amt_ty, date AS U_CLDT, E.l_yn, SPACE(1) AS U_RG23NO, SPACE(1) 
                      AS U_RG23CNO, SPACE(1) AS U_PLASR
FROM         dbo.EPACDET AS E INNER JOIN
                      dbo.AC_MAST AS F ON E.Ac_id = F.Ac_id
WHERE     (F.typ = 'EXCISE')
UNION
SELECT     E.Tran_cd, E.entry_ty, E.date, E.doc_no, E.Ac_id, E.acserial,E.amount, E.amt_ty, '01/01/1890' AS U_CLDT, E.l_yn, SPACE(1) AS U_RG23NO, SPACE(1) 
                      AS U_RG23CNO, SPACE(1) AS U_PLASR
FROM         dbo.ESACDET AS E INNER JOIN
                      dbo.AC_MAST AS F ON E.Ac_id = F.Ac_id
WHERE     (F.typ = 'EXCISE')
UNION
SELECT     E.Tran_cd, E.entry_ty, E.date, E.doc_no, E.Ac_id, E.acserial,E.amount, E.amt_ty, '01/01/1890' AS U_CLDT, E.l_yn, SPACE(1) AS U_RG23NO, SPACE(1) 
                      AS U_RG23CNO, SPACE(1) AS U_PLASR
FROM         dbo.IPACDET AS E INNER JOIN
                      dbo.AC_MAST AS F ON E.Ac_id = F.Ac_id
WHERE     (F.typ = 'EXCISE')
UNION
SELECT     E.Tran_cd, E.entry_ty, E.date, E.doc_no, E.Ac_id, E.acserial,E.amount, E.amt_ty, E.u_cldt, E.l_yn, E.u_rg23no, E.u_rg23cno, E.u_plasr
FROM         dbo.IRACDET AS E INNER JOIN
                      dbo.AC_MAST AS F ON E.Ac_id = F.Ac_id
WHERE     (F.typ = 'EXCISE')
UNION
SELECT     E.Tran_cd, E.entry_ty, E.date, E.doc_no, E.Ac_id, E.acserial,E.amount, E.amt_ty, U_CLDT, E.l_yn,U_RG23NO,
                      U_RG23CNO, SPACE(1) AS U_PLASR
FROM         dbo.JVACDET AS E INNER JOIN
                      dbo.AC_MAST AS F ON E.Ac_id = F.Ac_id
WHERE     (F.typ = 'EXCISE')
UNION
SELECT     E.Tran_cd, E.entry_ty, E.date, E.doc_no, E.Ac_id, E.acserial,E.amount, E.amt_ty, '01/01/1890' AS U_CLDT, E.l_yn, SPACE(1) AS U_RG23NO, SPACE(1) 
                      AS U_RG23CNO, SPACE(1) AS U_PLASR
FROM         dbo.OPACDET AS E INNER JOIN
                      dbo.AC_MAST AS F ON E.Ac_id = F.Ac_id
WHERE     (F.typ = 'EXCISE')
UNION
SELECT     E.Tran_cd, E.entry_ty, E.date, E.doc_no, E.Ac_id, E.acserial,E.amount, E.amt_ty, '01/01/1890' AS U_CLDT, E.l_yn, SPACE(1) AS U_RG23NO, SPACE(1) 
                      AS U_RG23CNO, SPACE(1) AS U_PLASR
FROM         dbo.PRACDET AS E INNER JOIN
                      dbo.AC_MAST AS F ON E.Ac_id = F.Ac_id
WHERE     (F.typ = 'EXCISE')
UNION
SELECT     E.Tran_cd, E.entry_ty, E.date, E.doc_no, E.Ac_id, E.acserial,E.amount, E.amt_ty, '01/01/1890' AS U_CLDT, E.l_yn, SPACE(1) AS U_RG23NO, SPACE(1) 
                      AS U_RG23CNO, SPACE(1) AS U_PLASR
FROM         dbo.SSACDET AS E INNER JOIN
                      dbo.AC_MAST AS F ON E.Ac_id = F.Ac_id
WHERE     (F.typ = 'EXCISE')
UNION
SELECT     E.Tran_cd, E.entry_ty, E.date, E.doc_no, E.Ac_id, E.acserial,E.amount, E.amt_ty, '01/01/1890' AS U_CLDT, E.l_yn, SPACE(1) AS U_RG23NO, SPACE(1) 
                      AS U_RG23CNO, SPACE(1) AS U_PLASR
FROM         dbo.EQACDET AS E INNER JOIN
                      dbo.AC_MAST AS F ON E.Ac_id = F.Ac_id
WHERE     (F.typ = 'EXCISE')
UNION
SELECT     E.Tran_cd, E.entry_ty, E.date, E.doc_no, E.Ac_id, E.acserial,E.amount, E.amt_ty, '01/01/1890' AS U_CLDT, E.l_yn, SPACE(1) AS U_RG23NO, SPACE(1) 
                      AS U_RG23CNO, SPACE(1) AS U_PLASR
FROM         dbo.TRACDET AS E INNER JOIN
                      dbo.AC_MAST AS F ON E.Ac_id = F.Ac_id
WHERE     (F.typ = 'EXCISE')
UNION
SELECT     E.Tran_cd, E.entry_ty, E.date, E.doc_no, E.Ac_id, E.acserial,E.amount, E.amt_ty, '01/01/1890' AS U_CLDT, E.l_yn, SPACE(1) AS U_RG23NO, SPACE(1) 
                      AS U_RG23CNO, SPACE(1) AS U_PLASR
FROM         dbo.OSACDET AS E INNER JOIN
                      dbo.AC_MAST AS F ON E.Ac_id = F.Ac_id
WHERE     (F.typ = 'EXCISE')
UNION
SELECT     E.Tran_cd, E.entry_ty, E.date, E.doc_no, E.Ac_id, E.acserial,E.amount, E.amt_ty, E.u_cldt, E.l_yn, E.u_rg23no, E.u_rg23cno, E.u_plasr
FROM         dbo.ACDET AS E INNER JOIN
                      dbo.AC_MAST AS F ON E.Ac_id = F.Ac_id
WHERE     (F.typ = 'EXCISE')
