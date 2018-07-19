*:*****************************************************************************
*:        Program: Main
*:         System: Udyog Software
*:         Added By: Rupesh
*:  Last modified:
*:			AIM  : Call HR and Payroll Related Masters
*:*****************************************************************************
Parameters cApp,pRange
If Vartype(Company) <> "O"
	Return .F.
Endif
cApp=Upper(cApp)
oWSHELL = Createobject("WScript.Shell")
If Vartype(oWSHELL) <> "O"
	Messagebox("WScript.Shell Object Creation Error...",16,VuMess)
	Return .F.
Endif

Declare Integer GetCurrentProcessId  In kernel32

tcCompId = Company.CompId
tcCompdb =Company.Dbname
tcCompNm=Company.co_name
SqlConObj = Newobject('SqlConnUdObj','SqlConnection',xapps)

*!*	mvu_user1 = SqlConObj.dec(SqlConObj.ondecrypt(mvu_user))			&& Commented by Shrikant S. on 26/04/2018 for Bug-31488
*!*	mvu_pass1 = SqlConObj.dec(SqlConObj.ondecrypt(mvu_pass))			&& Commented by Shrikant S. on 26/04/2018 for Bug-31488

&& Added by Shrikant S. on 26/04/2018 for Bug-31488		&& Start
IF mvu_nenc=1
	mvu_user1 =SqlConObj.newdecry(strconv(mvu_user,16),"Ud*yog+1993Uid")
	mvu_pass1 =SqlConObj.newdecry(STRCONV(mvu_pass,16),"Ud*yog+1993Pwd")
else
	mvu_user1 = SqlConObj.dec(SqlConObj.ondecrypt(mvu_user))
	mvu_pass1 = SqlConObj.dec(SqlConObj.ondecrypt(mvu_pass))
ENDIF
&& Added by Shrikant S. on 26/04/2018 for Bug-31488		&& End


vicopath=Strtran(icopath,' ','<*#*>')
pApplCaption=Strtran(VuMess,' ','<*#*>')
appNm=""
Do Case
	Case cApp=="ATTANDANCEREADER"
		appNm="udAttendanceIntegration.exe"
	Case cApp=="DAYTODAYMUSTER"
		appNm="udAttendanceApproval.exe"

	Case cApp=="LOANADVANCEDETAILS"
		appNm="udEmpLoanDetails.exe"
	Case cApp=="LOANADVANCEREQUEST"
		appNm="udEmpLoanRequest.exe"

	Case cApp=="MONTHLYMUSTER"
		appNm="udEmpMonthlyMuster.exe"
	Case cApp=="MONTHLYPAYROLL"
		appNm="udEmpMonthlyPayroll.exe"

	Case cApp=="PAYROLLDECLARATION"
		appNm="udEmpPayrollDeclaration.exe"
	Case cApp=="PROCESSMONTH"
		appNm="udEmpProcessingMonth.exe"

	Case cApp=="TDSPROJECTION"
		appNm="udEmpTdsProjection.exe"

****** Added by Sachin N. S. on 26/06/2014 for Bug-21114 -- Start
	Case cApp=="DAILYHOURMUSTER"
		appNm="udDailyHourWiseMuster.exe"
****** Added by Sachin N. S. on 26/06/2014 for Bug-21114 -- End
&&Added for Bug-31240,31241 & 31242 Start
	Case cApp=="EWAYBILLGEN"
		appNm="ugstEWayBill.exe"
	Case cApp=="EWBITMASTJSON"
		appNm="ugstEWB_ItMast_JSON.exe"
	Case cApp=="EWBACMASTJSON"
		appNm="ugstEWB_AcMast_JSON.exe"
&&Added for Bug-31240,31241 & 31242 End
	Otherwise
		appNm=""
Endcase
If !Empty(appNm)
	_ShellExec =appNm+" "+Transform(tcCompId)+" "+Alltrim(tcCompdb)+" "+Alltrim(mvu_server)+" "+Alltrim(mvu_user1)+" "+Alltrim(mvu_pass1) +" "+Alltrim(pRange)+" "+Alltrim(musername)+" "+Alltrim(vicopath)+" "+Alltrim(pApplCaption)+" "+Alltrim(pApplName)+" "+Alltrim(Str(pApplId))  +" "+Alltrim(pApplCode)+" "
*!*		MESSAGEBOX(_ShellExec)
	oWSHELL.Exec(_ShellExec)
Else
	Messagebox(cApp+" not found",16,VuMess)
Endif
*oWSHELL.Run(_ShellExec,1,.t.)
SqlConObj = Null
mvu_user1 = Null
mvu_pass1 = Null
Release SqlConObj,mvu_user1,mvu_pass1
