DROP PROCEDURE [USP_REP_AC_ANAL]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [USP_REP_AC_ANAL]
@TMPAC NVARCHAR(60),@TMPIT NVARCHAR(60),@SPLCOND NVARCHAR(500),
@SDATE SMALLDATETIME,@EDATE SMALLDATETIME,
@SNAME NVARCHAR(60),@ENAME NVARCHAR(60),
@SITEM NVARCHAR(60),@EITEM NVARCHAR(60),
@SAMT NUMERIC,@EAMT NUMERIC,
@SDEPT NVARCHAR(60),@EDEPT NVARCHAR(60),
@SCAT NVARCHAR(60),@ECAT NVARCHAR(60),@SINVSR NVARCHAR(60),@EINVSR NVARCHAR(60),
@SWARE NVARCHAR(60),@EWARE NVARCHAR(60),
@FINYR NVARCHAR(20), @EXTPAR NVARCHAR(60)
AS
	SET NOCOUNT ON
	--------- STORED PROC FOR ACCOUNT ANALYSIS ----------
	DECLARE @QryStr NVARCHAR(4000)

	SET @QryStr='SELECT VW.ac_name,'+CHAR(13)
		+'Sales=isnull(sum(case when VW.entry_ty ='+char(39)+'ST'+char(39)+' and VW.amt_ty='+char(39)+'DR'+char(39)+ ' then VW.amount END),0)'+CHAR(13)
		+	'-	isnull(sum(case when VW.entry_ty ='+char(39)+'ST'+char(39)+' and VW.amt_ty='+char(39)+'CR'+char(39)+ ' then VW.amount END),0),'+CHAR(13)

		+'SalesRetu=isnull(sum(case when VW.entry_ty ='+char(39)+'SR'+char(39)+' and VW.amt_ty='+char(39)+'DR'+char(39)+ ' then VW.amount END),0)'+CHAR(13)
		+	'-	isnull(sum(case when VW.entry_ty ='+char(39)+'SR'+char(39)+' and VW.amt_ty='+char(39)+'CR'+char(39)+ ' then VW.amount END),0),'+CHAR(13)

		+'Purchase=isnull(sum(case when VW.entry_ty ='+char(39)+'PT'+char(39)+' and VW.amt_ty='+char(39)+'DR'+char(39)+ ' then VW.amount END),0)'+CHAR(13)
		+	'-	isnull(sum(case when VW.entry_ty ='+char(39)+'PT'+char(39)+' and VW.amt_ty='+char(39)+'CR'+char(39)+ ' then VW.amount END),0),'+CHAR(13)

		+'PurchaseRetu=isnull(sum(case when VW.entry_ty ='+char(39)+'PR'+char(39)+' and VW.amt_ty='+char(39)+'DR'+char(39)+ ' then VW.amount END),0)'+CHAR(13)
		+	'-	isnull(sum(case when VW.entry_ty ='+char(39)+'PR'+char(39)+' and VW.amt_ty='+char(39)+'CR'+char(39)+ ' then VW.amount END),0),'+CHAR(13)

		+'CashRec=isnull(sum(case when VW.entry_ty ='+char(39)+'CR'+char(39)+' and VW.amt_ty='+char(39)+'DR'+char(39)+ ' then VW.amount END),0)'+CHAR(13)
		+	'-	isnull(sum(case when VW.entry_ty ='+char(39)+'CR'+char(39)+' and VW.amt_ty='+char(39)+'CR'+char(39)+ ' then VW.amount END),0),'+CHAR(13)

		+'CashPay=isnull(sum(case when VW.entry_ty ='+char(39)+'CP'+char(39)+' and VW.amt_ty='+char(39)+'DR'+char(39)+ ' then VW.amount END),0)'+CHAR(13)
		+	'-	isnull(sum(case when VW.entry_ty ='+char(39)+'CP'+char(39)+' and VW.amt_ty='+char(39)+'CR'+char(39)+ ' then VW.amount END),0),'+CHAR(13)

		+'BankRece=isnull(sum(case when VW.entry_ty ='+char(39)+'BR'+char(39)+' and VW.amt_ty='+char(39)+'DR'+char(39)+ ' then VW.amount END),0)'+CHAR(13)
		+	'-	isnull(sum(case when VW.entry_ty ='+char(39)+'BR'+char(39)+' and VW.amt_ty='+char(39)+'CR'+char(39)+ ' then VW.amount END),0),'+CHAR(13)

		+'BankPay=isnull(sum(case when VW.entry_ty ='+char(39)+'BP'+char(39)+' and VW.amt_ty='+char(39)+'DR'+char(39)+ ' then VW.amount END),0)'+CHAR(13)
		+	'-	isnull(sum(case when VW.entry_ty ='+char(39)+'BP'+char(39)+' and VW.amt_ty='+char(39)+'CR'+char(39)+ ' then VW.amount END),0),'+CHAR(13)

		+'CreditNote=isnull(sum(case when VW.entry_ty ='+char(39)+'CN'+char(39)+' and VW.amt_ty='+char(39)+'DR'+char(39)+ ' then VW.amount END),0)'+CHAR(13)
		+	'-	isnull(sum(case when VW.entry_ty ='+char(39)+'CN'+char(39)+' and VW.amt_ty='+char(39)+'CR'+char(39)+ ' then VW.amount END),0),'+CHAR(13)

		+'DebitNote=isnull(sum(case when VW.entry_ty ='+char(39)+'DN'+char(39)+' and VW.amt_ty='+char(39)+'DR'+char(39)+ ' then VW.amount END),0)'+CHAR(13)
		+	'-	isnull(sum(case when VW.entry_ty ='+char(39)+'DN'+char(39)+' and VW.amt_ty='+char(39)+'CR'+char(39)+ ' then VW.amount END),0),'+CHAR(13)

		+'IntDeptRec=isnull(sum(case when VW.entry_ty ='+char(39)+'IR'+char(39)+' and VW.amt_ty='+char(39)+'DR'+char(39)+ ' then VW.amount END),0)'+CHAR(13)
		+	'-	isnull(sum(case when VW.entry_ty ='+char(39)+'IR'+char(39)+' and VW.amt_ty='+char(39)+'CR'+char(39)+ ' then VW.amount END),0),'+CHAR(13)

		+'IntDepIssue=isnull(sum(case when VW.entry_ty ='+char(39)+'DN'+char(39)+' and VW.amt_ty='+char(39)+'DR'+char(39)+ ' then VW.amount END),0)'+CHAR(13)
		+	'-	isnull(sum(case when VW.entry_ty ='+char(39)+'DN'+char(39)+' and VW.amt_ty='+char(39)+'CR'+char(39)+ ' then VW.amount END),0),'+CHAR(13)

		+'JV=isnull(sum(case when VW.entry_ty ='+char(39)+'JV'+char(39)+' and VW.amt_ty='+char(39)+'DR'+char(39)+ ' then VW.amount END),0)'+CHAR(13)
		+	'-	isnull(sum(case when VW.entry_ty ='+char(39)+'JV'+char(39)+' and VW.amt_ty='+char(39)+'CR'+char(39)+ ' then VW.amount END),0),'+CHAR(13)

		+'PettyCash=isnull(sum(case when VW.entry_ty ='+char(39)+'PC'+char(39)+' and VW.amt_ty='+char(39)+'DR'+char(39)+ ' then VW.amount END),0)'+CHAR(13)
		+	'-	isnull(sum(case when VW.entry_ty ='+char(39)+'PC'+char(39)+' and VW.amt_ty='+char(39)+'CR'+char(39)+ ' then VW.amount END),0),'+CHAR(13)

		+'OpenBal=isnull(sum(case when VW.entry_ty ='+char(39)+'OB'+char(39)+' and VW.amt_ty='+char(39)+'DR'+char(39)+ ' then VW.amount END),0)'+CHAR(13)
		+	'-	isnull(sum(case when VW.entry_ty ='+char(39)+'OB'+char(39)+' and VW.amt_ty='+char(39)+'CR'+char(39)+ ' then VW.amount END),0)'+CHAR(13)

		+'from UVW_LAC_BAL VW'+CHAR(13)
		+'where VW.date between '+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+' and '+CHAR(39)+CAST(@EDATE AS VARCHAR)+CHAR(39)+CHAR(13)

	IF @EDEPT<>''
	BEGIN
		SET @QryStr=rtrim(@QryStr)+'and DEPT between @SDEPT and @EDEPT'+CHAR(13)
	END
	IF @ECAT<>''
	BEGIN
		SET @QryStr=rtrim(@QryStr)+'and CATE between @SCAT and @ECAT'+CHAR(13)
	END
	IF @EINVSR<>''
	BEGIN
		SET @QryStr=rtrim(@QryStr)+'and INV_SR between @SINVSR and @EINVSR'+CHAR(13)
	END

	IF @TMPAC<>''
	BEGIN
		SET @QryStr=rtrim(@QryStr)+'group by VW.ac_name'+CHAR(13)+'having VW.ac_name in (select ac_name from '+@TMPAC+')'+CHAR(13)
			+'order by VW.ac_name'
	END
	ELSE
	BEGIN
		SET @QryStr=rtrim(@QryStr)+'group by VW.ac_name'+CHAR(13)+'having VW.ac_name between '+CHAR(39)+@SNAME+CHAR(39)+' and '+CHAR(39)+@ENAME+CHAR(39)+CHAR(13)
			+'order by VW.ac_name'
	END

--	PRINT @QryStr
	execute sp_executesql @QryStr
GO
