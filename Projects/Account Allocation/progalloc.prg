Para ac_name1,amount1,fcamount1,top1,left1,height1,width1,_mpcvtype,_maddmode,_meditmode	&&atlas1604
malias=Alias()
If !Empty(malias)
	nRecnoCr=Recno()
*Birendra : Bug-7873 on 16/12/2012 :Start:
	If Between(nRecnoCr,1,Reccount())
		Go nRecnoCr
	Else
		Go Top
	Endif
	nRecnoCr=Recno()
*Birendra : Bug-7873 on 16/12/2012 :End:

ENDIF
* Added by Amrendra for TKT 8121 Verioning 11-06-2011  Start 
****Versioning****
Local _VerValidErr,_VerRetVal,_CurrVerVal
_VerValidErr = ""
_VerRetVal  = 'NO'
_CurrVerVal='10.0.0.0' &&[VERSIONNUMBER]
Try
	_VerRetVal = AppVerChk('ALLOC',_CurrVerVal,Justfname(Sys(16)))
Catch To _VerValidErr
	_VerRetVal  = 'NO'
Endtry
If Type("_VerRetVal")="L"
	cMsgStr="Version Error occured!"
	cMsgStr=cMsgStr+Chr(13)+"Kindly update latest version of "+GlobalObj.getPropertyval("ProductTitle")
	Messagebox(cMsgStr,64,VuMess)
	Return .F.
Endif

If !Empty(malias)
	Select (malias)
	If Type('nRecnoCr')#"U"
		Goto nRecnoCr
	Endif
Endif
If _VerRetVal  = 'NO'
	RETURN 0			&& expect some value instead of Return .F.
Endif
****Versioning**** 
* Added by Amrendra for TKT 8121 Verioning 11-06-2011 End 

Local lcValue
lcValue = 0
If File('UETrigAllocate.fxp')
	Do UETrigAllocate With 'INIT'
Endif
&&vasant170809a
_lckeyctrls = On('key','ctrl+s')
_lckeyctrlz = On('key','ctrl+z')
On Key Label CTRL+S
On Key Label CTRL+Z
&&vasant170809a
Do Form frmAlloc With ac_name1,amount1,fcamount1,top1,left1,height1,width1,_mpcvtype,_maddmode,_meditmode To lcValue	&&atlas1604
&&vasant170809a
On Key Label CTRL+S &_lckeyctrls
On Key Label CTRL+Z &_lckeyctrlz
&&vasant170809a
Return lcValue