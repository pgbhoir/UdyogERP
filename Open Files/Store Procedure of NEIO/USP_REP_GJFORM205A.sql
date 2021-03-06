If Exists(Select [name] From SysObjects Where xtype='P' and [Name]='USP_REP_GJFORM205A')
Begin
	Drop Procedure USP_REP_GJFORM205A
End
GO
-- =============================================
-- Author:		Gaurav R. Tanna 
-- Create date: 29/11/2014 (Bug-24842)
-- Description:	 Gujarat VAT Form - 205A
-- Modified By:  

-- Remark:
-- ============================================= 
CREATE Procedure [dbo].[USP_REP_GJFORM205A]
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
AS
BEGIN
Declare @sqlcommand nvarchar(4000)

set @sqlcommand = 'select IT_MAST.it_name, IT_MAST.HSNCODE, SUM(opitem.qty) As UNITQTY, SUM(gro_amt) As Value from OPITEM
inner join It_mast ON It_Mast.It_code = OPITEM.It_code'

set @sqlcommand = @sqlcommand + ' WHERE (OPITEM.DATE BETWEEN '''+convert(varchar(50),@sdate)+''' AND '''+convert(varchar(50),@edate)+'''  )'
+@EXPARA+'
GROUP BY IT_MAST.it_name, IT_MAST.HSNCODE ORDER BY IT_MAST.it_name'

Execute sp_executesql @sqlcommand
END
GO
