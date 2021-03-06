PARAMETERS pRange

Do Form frmQcInspection WITH pRange
RETURN 

****Versioning**** Added By Amrendra On 01/06/2011
	LOCAL _VerValidErr,_VerRetVal,_CurrVerVal
	_VerValidErr = ""
	_VerRetVal  = 'NO'
	TRY
		_VerRetVal = AppVerChk('QCINSPECTION',GetFileVersion(),JUSTFNAME(SYS(16)))
	CATCH TO _VerValidErr
		_VerRetVal  = 'NO'
	Endtry	
	IF TYPE("_VerRetVal")="L"
		cMsgStr="Version Error occured!"
		cMsgStr=cMsgStr+CHR(13)+"Kindly update latest version of "+GlobalObj.getPropertyval("ProductTitle")
		Messagebox(cMsgStr,64,VuMess)
		Return .F.
	ENDIF
	IF _VerRetVal  = 'NO'
		Return .F.
	Endif
****Versioning****


FUNCTION GetFileVersion
PARAMETERS lcTable
	_CurrVerVal='10.0.0.0' &&[VERSIONNUMBER]
	IF !EMPTY(lcTable)
		SELECT(lcTable)
		APPEND BLANK 
		replace fVersion WITH JUSTFNAME(SYS(16))+'   '+_CurrVerVal
	ENDIF 
RETURN _CurrVerVal