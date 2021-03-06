if exists (select [name] from sysobjects where [name]='USP_Ent_AutoBankPayment' AND XTYPE='P')
BEGIN 
	DROP PROCEDURE USP_Ent_AutoBankPayment
END
GO
/****** Object:  StoredProcedure [dbo].[USP_REP_OUTSTANDINGCR_AGEING]    Script Date: 04/28/2016 10:16:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Modified By: Kishor Agarwal
-- Modify date: 28/04/2016
-- =============================================

CREATE PROCEDURE [dbo].[USP_Ent_AutoBankPayment]  
@SDATE  SMALLDATETIME,@Ac_id Numeric(5)
AS
Declare @SQLCOMMAND as NVARCHAR(4000),@WhereCond Varchar(100)
Set @WhereCond=(Case When @Ac_id=0 Then 'AC_ID >0' Else 'AC_ID ='+Cast(@Ac_id as varchar) End)

SET @SQLCOMMAND ='SELECT Cast(0 as BIT) as Sel,*,Cheq_amt=TotalAmt-AdjustedAmt-DNoteAmt-DiscAmt,BalAmt=TotalAmt-AdjustedAmt 
				FROM (SELECT PT.entry_ty,PT.TRAN_CD,PT.[DATE],PT.Ac_id,PT.party_nm,PT.inv_no,
				u_pinvno,u_pinvdt,PT.CompId,APT.acserial,Cheq_no=space(10),TotalAmt=isnull(PT.net_amt,0),
				AdjustedAmt=sum(isnull(BPM.New_All,0)),DNOTEAMT=SUM(ISNULL(CN.NEW_ALL,0)),DiscAmt=sum(isnull(BPM.disc,0))
				FROM PTMAIN PT
				LEFT JOIN BPMALL BPM ON PT.TRAN_CD=BPM.Main_tran AND PT.entry_ty=BPM.entry_all
				LEFT JOIN PTACDET APT ON PT.Tran_cd=APT.Tran_cd AND PT.Ac_id=APT.Ac_id
				LEFT JOIN CNMALL CN ON CN.Main_tran = PT.Tran_cd
				where PT.entry_ty=''PT'' and pt.date <='+CHAR(39)+Cast(@SDATE as varchar)+CHAR(39)+' 
				group by PT.entry_ty,PT.TRAN_CD,PT.[DATE],PT.Ac_id,PT.party_nm,PT.inv_no,
				u_pinvno,u_pinvdt,PT.CompId,APT.acserial,isnull(PT.net_amt,0)) A WHERE TotalAmt-AdjustedAmt-DNoteAmt-DiscAmt>0 and '+@WhereCond+'
				UNION
				SELECT Cast(0 as BIT) as Sel,*,Cheq_amt=TotalAmt-AdjustedAmt-DNoteAmt-DiscAmt,BalAmt=TotalAmt-AdjustedAmt 
				FROM (SELECT EP.entry_ty,EP.TRAN_CD,EP.[DATE],EP.Ac_id,EP.party_nm,EP.inv_no,
				u_pinvno,u_pinvdt,EP.CompId,AEP.acserial,Cheq_no=space(10),TotalAmt=isnull(EP.net_amt,0),
				AdjustedAmt=sum(isnull(BPM.New_All,0)),DNoteAmt=SUM(ISNULL(CN.NEW_ALL,0)),DiscAmt=sum(isnull(BPM.disc,0))
				FROM EPMAIN EP
				LEFT JOIN BPMALL BPM ON EP.TRAN_CD=BPM.Main_tran AND EP.entry_ty=BPM.entry_all
				LEFT JOIN EPACDET AEP ON EP.Tran_cd=AEP.Tran_cd AND EP.Ac_id=AEP.Ac_id
				LEFT JOIN CNMALL CN ON CN.Main_tran = EP.Tran_cd
				where EP.entry_ty=''E1''and EP.date <='+CHAR(39)+Cast(@SDATE as varchar)+CHAR(39)+'
				group by EP.entry_ty,EP.TRAN_CD,EP.[DATE],EP.Ac_id,EP.party_nm,EP.inv_no,
				u_pinvno,u_pinvdt,EP.CompId,AEP.acserial,isnull(EP.net_amt,0)) A WHERE TotalAmt-AdjustedAmt-DNoteAmt-DiscAmt>0 and '+@WhereCond+' order by DATE'

print @SQLCOMMAND				
EXECUTE SP_EXECUTESQL @SQLCOMMAND
