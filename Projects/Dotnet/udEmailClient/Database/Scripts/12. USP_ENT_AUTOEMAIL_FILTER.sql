IF EXISTS(SELECT * FROM SYSOBJECTS WHERE [NAME]='USP_ENT_AUTOEMAIL_FILTER' AND XTYPE='P')
BEGIN
	DROP PROCEDURE USP_ENT_AUTOEMAIL_FILTER
END
GO
--==========================================--
-- PROCEDURE NAME : USP_ENT_AUTOEMAIL_FILTER
-- PARAMETERS : @INVPRINT - Bit value (0 - If records are not linked to any particular transaction , 1 - Query linked to Lcode
--				@CUSTOM	  - Can be used for calling customised filter query
--				@TRANTYPE - Transaction type if InvPrint is True
--				@CURRDATE - Whether to filter on Today's Date (Bit Value)
--				@SDATE	  - Start date filter
--				@EDATE	  - End date filter
--				@SINVSR	  - Start Invoice Series
--				@EINVSR   - End Invoice Series
--				@SINVNO   - Start Invoice No.
--				@EINVNO	  - End Invoice No.
--==========================================--
Create Procedure [dbo].[USP_ENT_AUTOEMAIL_FILTER]
@INVPRINT BIT, @CUSTOM VARCHAR(20), @TRANTYPE VARCHAR(2), @CURRDATE BIT,
@SDATE SMALLDATETIME, @EDATE SMALLDATETIME,
@SINVSR VARCHAR(20), @EINVSR VARCHAR(20),
@SINVNO VARCHAR(15), @EINVNO VARCHAR(15)
As
	DECLARE @SQLCMD VARCHAR(4000), @BCODE VARCHAR(2), @SQLCOND VARCHAR(4000)
	SELECT @SQLCMD='', @BCODE='', @SQLCOND=''
	IF @INVPRINT = 1
		BEGIN
			SELECT @BCODE=CASE WHEN BCODE_NM='' THEN ENTRY_TY ELSE BCODE_NM END FROM LCODE WHERE ENTRY_TY=@TRANTYPE
			SET @SQLCMD = 'SELECT *, Party_nm as Ac_Name FROM '+@BCODE+'MAIN '
			IF @CURRDATE = 1
				BEGIN
					SET @SQLCOND = @SQLCOND + ' DATE = GETDATE() '
				END
			ELSE
				BEGIN
					IF @SDATE<>'01-01-1900' AND @EDATE<>'01-01-1900'
						BEGIN
							SET @SQLCOND = @SQLCOND + CASE WHEN @SQLCOND='' THEN '' ELSE ' AND ' END + ' DATE BETWEEN '''+CAST(@SDATE AS VARCHAR)+''' AND '''+CAST(@EDATE AS VARCHAR)+'''' 
						END
				END
			IF (@SINVSR='' AND @EINVSR<>'') OR (@SINVSR<>'' AND @EINVSR='') OR (@SINVSR<>'' AND @EINVSR<>'')
				BEGIN
					SET @SQLCOND = @SQLCOND + ' INV_SR BETWEEN '''+CAST(@SINVSR AS VARCHAR)+''' AND '''+CAST(@EINVSR AS VARCHAR)+'''' 
				END
			IF (@SINVNO='' AND @EINVNO<>'') OR (@SINVNO<>'' AND @EINVNO='') OR (@SINVNO<>'' AND @EINVNO<>'')
				BEGIN
					SET @SQLCOND = @SQLCOND + ' INV_NO BETWEEN '''+CAST(@SINVNO AS VARCHAR)+''' AND '''+CAST(@EINVNO AS VARCHAR)+'''' 
				END
			SELECT @SQLCMD = @SQLCMD + ' WHERE ' + @SQLCOND
			EXECUTE sp_executesql @SQLCMD 
		END
--	ELSE
--		BEGIN
--			--// Customised Query
--		END
