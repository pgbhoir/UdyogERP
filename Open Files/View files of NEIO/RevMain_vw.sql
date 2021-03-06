DROP VIEW [RevMain_vw]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Shrikant S.
-- Create date: 
-- Description:	This View is used in Reversal gst.
-- Remark: 
-- =============================================
CREATE view [RevMain_vw]
as
select entry_ty,tran_cd,ac_id,Pinvno,Pinvdt,date,u_cldt,inv_no,gro_amt,tot_deduc,tot_tax,net_amt,Narr,inv_sr from epmain		
union all
select entry_ty,tran_cd,ac_id,Pinvno,Pinvdt,date,u_cldt,inv_no,gro_amt,tot_deduc,tot_tax,net_amt,Narr,inv_sr from bpmain
union all
select entry_ty,tran_cd,ac_id,Pinvno,Pinvdt,date,u_cldt,inv_no,gro_amt,tot_deduc,tot_tax,net_amt,Narr,inv_sr from cpmain
union all
select entry_ty,tran_cd,ac_id,Pinvno,Pinvdt,date,u_cldt=space(1),inv_no,gro_amt,tot_deduc,tot_tax,net_amt,Narr,inv_sr from PTmain
union all
select entry_ty,tran_cd,ac_id,Pinvno,Pinvdt,date,u_cldt=space(1),inv_no,gro_amt,tot_deduc,tot_tax,net_amt,Narr,inv_sr from STmain
GO
