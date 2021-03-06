
/****** Object:  View [dbo].[vat_item_vw]    Script Date: 05/10/2011 17:33:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vat_item_vw]
as
select entry_ty,tran_cd,itserial,ac_id,it_code,date,tax_name,taxamt,GRO_AMT,TOT_DEDUC,TOT_ADD,TOT_EXAMT,TOT_NONTAX,TOT_FDISC,ADDLVAT1,VATTYPE='OUTPUT' from stitem
union
select entry_ty,tran_cd,itserial, ac_id,it_code,date,tax_name,taxamt,GRO_AMT,TOT_DEDUC,TOT_ADD,TOT_EXAMT,TOT_NONTAX,TOT_FDISC,0 as ADDLVAT1,VATTYPE='OUTPUT' from dcitem
union
select entry_ty,tran_cd,itserial,ac_id,it_code,date,tax_name,taxamt,GRO_AMT,TOT_DEDUC,TOT_ADD,TOT_EXAMT,TOT_NONTAX,TOT_FDISC,ADDLVAT1,VATTYPE='INPUT' from sritem
union
select entry_ty,tran_cd,itserial, ac_id,it_code,date,tax_name,taxamt,GRO_AMT,TOT_DEDUC,TOT_ADD,TOT_EXAMT,TOT_NONTAX,TOT_FDISC,ADDLVAT1,VATTYPE='INPUT' from ptitem
union
select entry_ty,tran_cd,itserial, ac_id,it_code,date,tax_name,taxamt,GRO_AMT,TOT_DEDUC,TOT_ADD,TOT_EXAMT,TOT_NONTAX,TOT_FDISC,0 as ADDLVAT1,VATTYPE='INPUT' from aritem
union
select entry_ty,tran_cd,itserial, ac_id,it_code,date,tax_name,taxamt,GRO_AMT,TOT_DEDUC,TOT_ADD,TOT_EXAMT,TOT_NONTAX,TOT_FDISC,ADDLVAT1,VATTYPE='OUTPUT' from pritem
union
select entry_ty,tran_cd,itserial,ac_id,it_code,date,tax_name,taxamt,GRO_AMT,TOT_DEDUC,TOT_ADD,TOT_EXAMT,TOT_NONTAX,TOT_FDISC,0 as ADDLVAT1,VATTYPE='OUTPUT' from dnitem
union
select entry_ty,tran_cd,itserial, ac_id,it_code,date,tax_name,taxamt,GRO_AMT,TOT_DEDUC,TOT_ADD,TOT_EXAMT,TOT_NONTAX,TOT_FDISC,0 as ADDLVAT1,VATTYPE='INPUT' from cnitem

