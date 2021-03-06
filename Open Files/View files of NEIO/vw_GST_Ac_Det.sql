DROP VIEW [vw_GST_Ac_Det]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [vw_GST_Ac_Det]
AS

SELECT     ac.entry_ty, ac.Tran_cd, ac.AcSerial, ac.date, ac.Ac_id, ac.Amount, ac.Amt_Ty, ac.L_Yn
FROM         BPAcDet ac 
UNION ALL
SELECT     ac.entry_ty, ac.Tran_cd, ac.AcSerial, ac.date, ac.Ac_id, ac.Amount, ac.Amt_Ty, ac.L_Yn
FROM         BRAcdet ac
UNION ALL
SELECT     ac.entry_ty, ac.Tran_cd, ac.AcSerial, ac.date, ac.Ac_id, ac.Amount, ac.Amt_Ty, ac.L_Yn
FROM         CNAcdet ac
UNION ALL
SELECT     ac.entry_ty, ac.Tran_cd, ac.AcSerial, ac.date, ac.Ac_id, ac.Amount, ac.Amt_Ty, ac.L_Yn
FROM         CPAcdet ac
UNION ALL
SELECT     ac.entry_ty, ac.Tran_cd, ac.AcSerial, ac.date, ac.Ac_id, ac.Amount, ac.Amt_Ty, ac.L_Yn
FROM         CRAcdet ac
UNION ALL
SELECT     ac.entry_ty, ac.Tran_cd, ac.AcSerial, ac.date, ac.Ac_id, ac.Amount, ac.Amt_Ty, ac.L_Yn
FROM         DNAcdet ac
UNION ALL
SELECT     ac.entry_ty, ac.Tran_cd, ac.AcSerial, ac.date, ac.Ac_id, ac.Amount, ac.Amt_Ty, ac.L_Yn
FROM         EPAcdet ac
UNION ALL
SELECT     ac.entry_ty, ac.Tran_cd, ac.AcSerial, ac.date, ac.Ac_id, ac.Amount, ac.Amt_Ty, ac.L_Yn
FROM         JVAcdet ac
UNION ALL
SELECT     ac.entry_ty, ac.Tran_cd, ac.AcSerial, ac.date, ac.Ac_id, ac.Amount, ac.Amt_Ty, ac.L_Yn
FROM         OBAcdet ac
UNION ALL
SELECT     ac.entry_ty, ac.Tran_cd, ac.AcSerial, ac.date, ac.Ac_id, ac.Amount, ac.Amt_Ty, ac.L_Yn
FROM         OSAcdet ac
UNION ALL
SELECT     ac.entry_ty, ac.Tran_cd, ac.AcSerial, ac.date, ac.Ac_id, ac.Amount, ac.Amt_Ty, ac.L_Yn
FROM         PCAcdet ac
UNION ALL
SELECT     ac.entry_ty, ac.Tran_cd, ac.AcSerial, ac.date, ac.Ac_id, ac.Amount, ac.Amt_Ty, ac.L_Yn
FROM         PRAcdet ac
UNION ALL
SELECT     ac.entry_ty, ac.Tran_cd, ac.AcSerial, ac.date, ac.Ac_id, ac.Amount, ac.Amt_Ty, ac.L_Yn
FROM         PTAcdet ac
UNION ALL
SELECT     ac.entry_ty, ac.Tran_cd, ac.AcSerial, ac.date, ac.Ac_id, ac.Amount, ac.Amt_Ty, ac.L_Yn
FROM         SRAcdet ac
UNION ALL
SELECT     ac.entry_ty, ac.Tran_cd, ac.AcSerial, ac.date, ac.Ac_id, ac.Amount, ac.Amt_Ty, ac.L_Yn
FROM         STAcdet ac
UNION ALL
SELECT     ac.entry_ty, ac.Tran_cd, ac.AcSerial, ac.date, ac.Ac_id, ac.Amount, ac.Amt_Ty, ac.L_Yn
FROM         SBAcdet ac
GO
