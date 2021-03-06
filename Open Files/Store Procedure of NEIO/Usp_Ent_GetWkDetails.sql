DROP PROCEDURE [Usp_Ent_GetWkDetails]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [Usp_Ent_GetWkDetails]
@Entry_ty Varchar(2),@Tran_cd Numeric(10,0),@Itserial VArchar(5),@It_code Numeric(10,0)
as 
DECLARE @LookupID int


SET @LookupID = 1;

WITH cteSelectedWorkOrder  AS
(
        SELECT   a.Entry_ty,a.Tran_cd,a.Itserial,a.RQty,a.Rentry_ty,a.Itref_tran,a.RItserial,a.It_code, @LookupID AS LookupId
        FROM     reference_vw AS a
        WHERE    a.Entry_ty=@Entry_ty and a.Tran_cd =@Tran_cd and a.Itserial=@Itserial and a.It_code=@It_code 
    UNION ALL
        SELECT  a.Entry_ty,a.Tran_cd,a.Itserial,a.RQty,a.Rentry_ty,a.Itref_tran,a.RItserial,a.It_code, (c.LookupID + 1) as LookupId
        FROM     reference_vw AS a
        INNER JOIN cteSelectedWorkOrder AS c ON a.Entry_ty=c.Rentry_ty and a.Tran_cd=c.Itref_tran and a.Itserial=c.RItserial and a.It_code=@It_code 
)
Select a.* From projectitref a
	Inner Join cteSelectedWorkOrder b On (a.entry_ty=b.Entry_ty and a.tran_cd =b.Tran_cd and a.itserial=b.Itserial)
	Where b.REntry_ty='Wk'
GO
