���   $7 �6 o                     �10   m                   PLATFORM   C                  UNIQUEID   C	   
               TIMESTAMP  N   
               CLASS      M                  CLASSLOC   M!                  BASECLASS  M%                  OBJNAME    M)                  PARENT     M-                  PROPERTIES M1                  PROTECTED  M5                  METHODS    M9                  OBJCODE    M=                 OLE        MA                  OLE2       ME                  RESERVED1  MI                  RESERVED2  MM                  RESERVED3  MQ                  RESERVED4  MU                  RESERVED5  MY                  RESERVED6  M]                  RESERVED7  Ma                  RESERVED8  Me                  USER       Mi                                                                                                                                                                                                                                                                                          COMMENT Screen                                                                                              WINDOWS _0S90ZWJZ4 776963677      /  F      ]                          �      �                       WINDOWS _0S90ZWJZ51254323649�      �  �      �      �  ��                  �w                           WINDOWS _0XW11KNGY1115903827�w      �w  �w  �w  Wu      �q  gX                                               WINDOWS _1FB0XAJ0S1010993288�q      �q  }q  lq  q      �p  �W  Dy  �p                                       WINDOWS _20G0N889W1010993288�p      rp  ep  Tp  wo      �k  V                                               WINDOWS _20G0NJBFP1010993288�k      �k  �k  �k  �j      �i  �T                                               WINDOWS _20G0W429H 910719498�i      �i  �i  �i  �h                                                           WINDOWS _2UU11PFUB1010993288�h      �h  �h  �h  h      ~g  �S                                               WINDOWS _3R40N2OD31115903421lg      Zg  Gg  6g  �f              �Z  �Z                                       COMMENT RESERVED                                `Z                                                            �                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 VERSION =   3.00      dataenvironment      dataenvironment      Dataenvironment      _Top = 220
Left = 1
Width = 520
Height = 200
DataSource = .NULL.
Name = "Dataenvironment"
      1      1      form      form      	Frmgetpop     �ScaleMode = 3
Top = 22
Left = 26
Height = 510
Width = 442
ShowWindow = 1
DoCreate = .T.
ShowTips = .T.
BorderStyle = 0
Caption = ""
ControlBox = .T.
Closable = .T.
FontSize = 8
MaxButton = .F.
MinButton = .F.
ClipControls = .F.
DrawMode = 15
DrawStyle = 6
DrawWidth = 2
KeyPreview = .T.
WindowType = 1
LockScreen = .F.
AlwaysOnTop = .T.
BackColor = 240,240,240
Themes = .F.
dblclicked = .F.
objgpop = 
frmcapt = 
psearchcol = 
psearchdef = 
Name = "Frmgetpop"
     N�PROCEDURE entr
On Key Label Enter
Thisform.Release

ENDPROC
PROCEDURE gridfill
Private colc
colc = 1

With Thisform.Grdgetpop
	.RecordSourceType=1
	.RecordSource="curSrch"
	.ScrollBars = Iif(.ColumnCount = 1,2,3)
	.BackColor = Rgb(255,255,255)
	.ColumnCount = Thisform.totfieldproc()

	Do While colc <= .ColumnCount
	
		colObject = "."+"column"+Alltrim(Str(colc))
		Colwidth  = "."+"column"+Alltrim(Str(colc))+[.width=]+Str(Iif(Thisform.fieldsizeproc(colc,1)+5 < 40 And .ColumnCount = 1,40 * 5,Thisform.fieldsizeproc(colc,1)+5) * 5)
		Colcapt = Thisform.assigncaption(colc)
		ColHdcapt = "."+"column"+Alltrim(Str(colc))+".Header1.caption ="+"'"+Proper(Alltrim(Colcapt))+"'"
		ColHdCapp = "."+"column"+Alltrim(Str(colc))+".Header1.caption"
		ColHdFont = "."+"column"+Alltrim(Str(colc))+".Header1.fontsize = 8"
		ColHdAlig = "."+"column"+Alltrim(Str(colc))+".Header1.alignment = 2"
*!*			ColHdFnBd = "."+"column"+Alltrim(Str(colc))+".Header1.fontbold = .t."	&& Commented By Sachin N. S. on 01/02/2010 for TKT-250
		ColSource = "."+"column"+Alltrim(Str(colc))+".controlsource="+"'"+Alltrim(Thisform.fieldsizeproc(colc,2))+"'"
		ColFont   = "."+"column"+Alltrim(Str(colc))+[.fontsize=8]
		ColTXTAlig = "."+"column"+Alltrim(Str(colc))+".Text1.alignment = 0"
		ColAlig = "."+"column"+Alltrim(Str(colc))+".alignment = 0"
		&Colwidth
		&ColHdcapt
		listOpt = Alltrim(Upper(Thisform.cList))
*!*			If Inlist(Alltrim(Upper(Thisform.fieldsizeproc(colc,2))),&listOpt)		&& Changed By Sachin N. S. on 01/02/2010 for TKT-250
		If Alltrim(Upper(Thisform.fieldsizeproc(colc,2))) $ listOpt
*!*				ColHdFrCr = "."+"column"+Alltrim(Str(colc))+".Header1.forecolor = rgb(255,0,0)"		&& Changed By Sachin N. S. on 03/07/2009
			ColHdFrCr = "."+"column"+Alltrim(Str(colc))+".Header1.forecolor = rgb(0,0,255)"
			ColHdFnBd = "."+"column"+Alltrim(Str(colc))+".Header1.fontbold = .t."
			&ColTXTAlig
			&ColAlig
		Else
			ColHdFrCr = "."+"column"+Alltrim(Str(colc))+".Header1.forecolor = rgb(0,0,0)"
			ColHdFnBd = "."+"column"+Alltrim(Str(colc))+".Header1.fontbold = .f."
		Endif
		&ColHdFont
		&ColHdAlig
		&ColHdFrCr
		&ColHdFnBd
		&ColFont
		&ColSource
		Thisform.FormWidth = Thisform.FormWidth + Iif(Thisform.fieldsizeproc(colc,1)+5 < 40 And .ColumnCount = 1,40,Thisform.fieldsizeproc(colc,1)+10)
		colc = colc + 1
	Enddo
	.Refresh
Endwith
If Thisform.FormWidth < 60
	Thisform.FormWidth = 61
Endif

Thisform.columnbindevents()
Thisform.Resize
Thisform.Refresh

ENDPROC
PROCEDURE esc
On Key Label Esc
mEsckey="YES"
Thisform.Release

ENDPROC
PROCEDURE columnbindevents
mColCount = Thisform.Grdgetpop.ColumnCount
If mColCount > 0
	With Thisform.Grdgetpop
		For i= 1 To mColCount
			=Bindevent(.Columns(i).Text1,"keypress",Thisform,"KeyPress")
			=Bindevent(.Columns(i).Text1,"DblClick",Thisform.Grdgetpop,"DblClick")
*!*				=Bindevent(.Columns(i).Header1,"Click",Thisform,"HdrClick")
			=Bindevent(.Columns(i).Header1,"Click",Thisform,"HdrClick") &&Rup 01/02/10
		Endfor
	Endwith
Endif

ENDPROC
PROCEDURE assigncaption
Lparameters colc As Integer
Private colc,Y,Yesno,nFndstr
nTotcap = Alen(Thisform.objgpop.caparry)
Y = ""
Y = Thisform.fieldSizeProc(colc,2)	&& Added By Default Field Name
For nI = 1 To nTotcap To 1
*!*		If Atc(Thisform.fieldsizeproc(colc,2),Thisform.objgpop.caparry(nI)) <> 0 &&Rup 01/02/10 for TKT-250 to Check exact field name for case like EIT_NAME,IT_NAME
	x1=Thisform.fieldSizeProc(colc,2)
	y1=Subst(  Thisform.objgpop.caparry(nI),1,Rat(":", Thisform.objgpop.caparry(nI) )-1)
	y2=UPPER(ALLTRIM(Subst(y1,Rat(".",y1)+1)))
*!*		If x1=y2				&& Commented by Shrikant S. on 09/06/2016 for Bug-28221
	If LOWER(x1)==LOWER(y2)		&& Added by Shrikant S. on 09/06/2016 for Bug-28221
		Y = Strextract(Thisform.objgpop.caparry(nI),[:],[,])
		Exit
	Endif
Endfor
Y = Iif(Empty(Y),'',Y)
Return Y

ENDPROC
PROCEDURE udfindchar
Lparameters nFromchar As Integer,cSearchin As String


ENDPROC
PROCEDURE searchcapfind
Lparameters colc As String
Private colc,Y,Yesno,nFndstr,B,a
nTotcap = Alen(Thisform.objgpop.capArry)
Y = ""
B = ""
*!*	For nI = 1 To nTotcap To 1
*!*	*!*		If Atc(Allt(colc),Thisform.objgpop.caparry(nI)) <> 0
*!*		a = Left(Thisform.objgpop.capArry(nI),At([:],Thisform.objgpop.capArry(nI))-1)	&& Added By Sachin N. S. on 01/09/2009
*!*		If Inlist(Alltrim(Upper(a)),&listOpt)
*!*			Y = Strextract(Thisform.objgpop.capArry(nI),[:],[,])
*!*	*!*			Exit
*!*			B = B + Iif(!Empty(B),'+','') + Y
*!*		Endif

*!*	Endfor
*!*	Y = Iif(Empty(B),Allt(colc),B)
*!*	Return Y

listOpt = Alltrim(Upper(Thisform.cList))
listOpt = Strtran(listOpt,'"','')
listOpt = listOpt + ','
Do While .T.
	If !Empty(listOpt)
		a = Upper(Left(listOpt,At(',',listOpt)-1))
		For nI = 1 To nTotcap To 1
*!*				If Upper(a) $ Upper(Thisform.objgpop.capArry(nI))	&& Changed By Sachin N. S. on 01/02/2010 for TKT-250
			If Strextract(Thisform.objgpop.capArry(nI),[],[:]) $ Upper(a)
				Y = Strextract(Thisform.objgpop.capArry(nI),[:],[,])
				Exit
			Endif
		Endfor
		B = B + Iif(!Empty(B),'+','') + Y
		listOpt = Strtran(listOpt,a+',','')
	Else
		Exit
	Endif
Enddo
Y = Iif(Empty(B),Allt(colc),B)
Return Y

ENDPROC
PROCEDURE captioninit
*!*	If mSrchAny = .T.
*!*		Thisform.Chksearchtype.Picture = APath+'BMP\INCSEARCH.BMP'
*!*		Thisform.Chksearchtype.ToolTipText = [Incremental Search]
*!*		Thisform.Caption = Alltrim(Thisform.frmcapt) + Space(02)+ [- Incremental Search ]
*!*		mSrchAny =.F.  &&Added by Archana K. on 08/11/12 for Bug-7177
*!*	Else
*!*		Thisform.Chksearchtype.Picture = APath+'BMP\SEARCHANY.BMP'
*!*		Thisform.Chksearchtype.ToolTipText = [Search Anywhere]
*!*		Thisform.Caption = Alltrim(Thisform.frmcapt) + Space(02)+ [- Search Anywhere ]
*!*		mSrchAny =.T.  &&Added by Archana K. on 08/11/12 for Bug-7177
*!*	Endif
*!*	Thisform.Chksearchtype.Refresh()
&&changes by sandeep for the bug-14038 on 24-MAy-12-->Start
If mSrchAny = .T.
	Thisform.Chksearchtype.Picture = APath+'BMP\SEARCHANY.BMP'
	Thisform.Chksearchtype.ToolTipText = [Search Anywhere]
	Thisform.Caption = Alltrim(Thisform.frmcapt) + Space(02)+ [- Search Anywhere ]
	mSrchAny =.F.  &&Added by Archana K. on 08/11/12 for Bug-7177
Else
	Thisform.Chksearchtype.Picture = APath+'BMP\INCSEARCH.BMP'
	Thisform.Chksearchtype.ToolTipText = [Incremental Search]
	Thisform.Caption = Alltrim(Thisform.frmcapt) + Space(02)+ [- Incremental Search ]
	mSrchAny =.T.  &&Added by Archana K. on 08/11/12 for Bug-7177
Endif
Thisform.Chksearchtype.Refresh()
&&changes by sandeep for the bug-14038 on 24-MAy-12-->End
ENDPROC
PROCEDURE setsplkeys
Parameters Splkeys,RorL
Local Y
Y = Iif(Atc('"',Splkeys) <> 0 And Atc("'",Splkeys) = 0,['],Iif(Atc("'",Splkeys) <> 0 And Atc('"',Splkeys) = 0,["],Iif(Atc("'",Splkeys) <> 0 And Atc('"',Splkeys) <> 0,Iif(RorL=1,"[","]"),['])))
Return Y


ENDPROC
PROCEDURE totfieldproc
Priv lcfldstr,lnfldstr
lcfldstr = Thisform.objgpop.seShowFlds
lnfldstr = Occurs('<<',lcfldstr)
Return lnfldstr

ENDPROC
PROCEDURE fieldsizeproc
Lparameters tnFldnum As Integer,tnTYPE As Integer
Private lcField
lcField = Strextract(Thisform.objgpop.seShowFlds,"<<",">>",tnFldnum)
Return Iif(tnTYPE=1,Fsize(lcField),Field(lcField,"curSrch"))
*!*	Return Iif(tnTYPE=1,Fsize(Field(lcField,"curSrch")),Field(lcField,"curSrch"))

ENDPROC
PROCEDURE hdrclick
*!*	gnobjects = Amouseobj(gaSelected)
*!*	If gnobjects > 0
*!*		With Thisform
*!*			_curobjname = gaSelected(1)
*!*			If !Empty(_curobjname.ControlSource)
*!*				mPara2 = Justext(Alltrim(_curobjname.ControlSource))
*!*			Endif
*!*		Endwith
*!*	Endif
&&Rup 01/02/10

******** Added By Sachin N. S. on 01/02/2010 for TKT-250 ******** Start
gnobjects = Amouseobj(gaSelected)
If gnobjects > 0
	With Thisform
		_curobjname = gaSelected(1)
		If !Empty(_curobjname.ControlSource)
*!*				mPara2 = Justext(Alltrim(_curobjname.ControlSource))
			mPara2 = Alltrim(_curobjname.ControlSource)
			Do Case
				Case Type(_curobjname.ControlSource) = 'D'
					mPara2 = "DTOC("+mPara2+")"
				Case Type(_curobjname.ControlSource) = 'T'
					mPara2 = "TTOC("+mPara2+")"
				Case Type(_curobjname.ControlSource) = 'N'
					mPara2 = "allt(str("+mPara2+",20,4))"
				Case Type(_curobjname.ControlSource) = 'I'
					mPara2 = "allt(str("+mPara2+"))"
			Endcase
		Endif

		Thisform.setsearchparam()
		.chkSearch.Value = .F.
		.chkSearch.Enabled = .T.
		.text1.SetFocus
	Endwith
Endif
******** Added By Sachin N. S. on 01/02/2010 for TKT-250 ******** End

ENDPROC
PROCEDURE refreshrcrd
ShowFlds = Thisform.objgpop.ShowFlds
_Tally = 0
&&mtext = Thisform.setsplkeys(ThisForm.Text1.Value,1)+Iif(mSrchAny = .F.,"%"+Allt(Upper(ThisForm.Text1.Value))+"%",Allt(Upper(ThisForm.Text1.Value))+"%")+Thisform.setsplkeys(ThisForm.Text1.Value,2)&&commented by satish pal for bug-7537 date 22/12/2012
If ! Empty(mSearchValue)
	Store "" To mSearchValue
ENDIF
&&added and commented by satish pal for bug-7537 date 22/12/2012-Start
&&SELECT &ShowFlds FROM &mpara1 WHERE UPPER(&mpara2) LIKE &mtext INTO CURSOR curSrch
IF TYPE(mpara2)<>'L'
	mtext = THISFORM.setsplkeys(THISFORM.Text1.VALUE,1)+IIF(mSrchAny = .F.,"%"+ALLT(UPPER(THISFORM.Text1.VALUE))+"%",ALLT(UPPER(THISFORM.Text1.VALUE))+"%")+THISFORM.setsplkeys(THISFORM.Text1.VALUE,2)
	SELECT &ShowFlds FROM &mpara1 WHERE UPPER(&mpara2) LIKE &mtext INTO CURSOR curSrch
ELSE
	IF !EMPTY(ALLT(UPPER(THISFORM.Text1.VALUE))) 
		mtext = "."+ALLT(UPPER(THISFORM.Text1.VALUE))+"."
		IF INLIST(mtext,'.T.','.F.')
			SELECT &ShowFlds FROM &mpara1 WHERE &mpara2 = &mtext INTO CURSOR curSrch
		ELSE
			SELECT &ShowFlds FROM &mpara1 WHERE 1=2 INTO CURSOR curSrch
		ENDIF
	ELSE
		SELECT &ShowFlds FROM &mpara1 INTO CURSOR curSrch
	ENDIF
ENDIF
&&added and commented by satish pal for bug-7537 date 22/12/2012-End

*!*	Thisform.Panel.panels(2).Text="Records Found : "+Alltrim(Str(_Tally)) && Commented by Archana K. on 08/11/12 for Bug-7177
Thisform.Panel.panels(2).Text="Records Found : "+Alltrim(Str(_Tally))+" | F12- Toggle for Search option " && Changed by Archana k. on 08/11/12 for Bug-7177
Thisform.gridfill()
Thisform.Resize

ENDPROC
PROCEDURE setsearchparam
With Thisform
	Local cTy,cOldSearchexp
	cTy = 1
	.cList = []

	Do While .T.
		cSearchexp = At('+',mPara2,cTy)
		If cSearchexp = 0
			If cTy = 1
				cOldSearchexp = Len(mPara2)
				.cList = ["]+.cList + Substr(mPara2,Iif(cSearchexp=0,1,cOldSearchexp+1),Len(mPara2))+["]
			Else
				.cList = .cList + [,"]+Substr(mPara2,cOldSearchexp+1,Len(mPara2))+["]
			Endif
			Exit
		Else
			If cTy = 1
				.cList = ["]+.cList + Substr(mPara2,1,cSearchexp-1)+["]
				cOldSearchexp = cSearchexp
			Else
				.cList = .cList + [,"]+Substr(mPara2,cOldSearchexp+1,cSearchexp-cOldSearchexp-1)+["]
				cOldSearchexp = cSearchexp
			Endif
		Endif
		cTy = cTy + 1
	Enddo
	.Grdgetpop.RecordSource = ""
	.Panel.panels(3).Text="Search Fields : "+.searchCapFind(mPara2)
	.refreshrcrd()
Endwith

ENDPROC
PROCEDURE createnode
*Birendra : Bug-7753 on 01/04/2013 :Start:
this.oletreeView.Nodes.Clear 
thisform.oletreeView.singleSel= .T.
thisform.oletreeView.Enabled= .F. 
SELECT &mTreeview
GO top
SCAN
	IF EMPTY(zparent)
		this.oletreeView.Nodes.Add(,1,ALLTRIM(zkey),ALLTRIM(ztext),0)
	ELSE
		this.oletreeView.Nodes.Add(ALLTRIM(zparent),4,ALLTRIM(zkey),ALLTRIM(ztext),0)
	ENDIF 
ENDSCAN
SELECT curSrch
GO TOP 
*Birendra : Bug-7753 on 01/03/2013 :End:

ENDPROC
PROCEDURE treesearch
*Birendra : Bug-7753 on 01/04/2013 :start
FOR n=1 TO thisform.oleTreeView.Nodes.Count 
	z1=UPPER(ALLTRIM(thisform.oleTreeView.Nodes.Item(n).Text))
	z2=ALLTRIM(UPPER(&mPara2))
 IF  z1 = z2 
 	thisform.oleTreeView.Nodes.Item(n).Selected= .T. 
 ENDIF  
ENDFOR 
*Birendra : Bug-7753 on 01/04/2013 :End

ENDPROC
PROCEDURE QueryUnload
*!*	KEYBOARD '{ESC}'
Thisform.esc()

ENDPROC
PROCEDURE Unload
On Key Label Enter
On Key Label esc

&& Added by Archana K. on 08/11/12 for Bug-7177 start
On Key Label f12 
Pop Key			 
&& Added by Archana K. on 08/11/12 for Bug-7177 end

If mesckey="YES"
	Rele mpara3,mpara1,mpara2,mesckey,retvalue,msplitbar,mxtrafield,mxtracaption,msrchany,msearchvalue
	Return .F.
Else
	Select cursrch
	pCretVal = Iif(Type('retvalue') = 'L',[],Iif(Empty(retvalue),[],retvalue))
	Rele mpara3,mpara1,mpara2,mesckey,msplitbar,mxtrafield,mxtracaption,msrchany,msearchvalue
	If Atc([,],pCretVal) <> 0
		Scatter Fields &pCretVal Name Curobj
		Return Curobj
	Else
		Return Iif(!Empty(pCretVal),&pCretVal,[])
	Endif
Endif

ENDPROC
PROCEDURE Activate
If Vartype(Tbrdesktop) = 'O'
	=barstat(.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.T.,.F.)
Endif
On Key Label Enter  _Screen.ActiveForm.entr
On Key Label esc  _Screen.ActiveForm.esc
Thisform.Grdgetpop.Refresh

*Birendra : Bug-7753 on 01/04/2013 :Start:
IF thisform.treeview
	this.oletreeView.Visible=.t.
	this.createnode() 
ELSE
	this.oletreeView.Visible=.F.
ENDIF 
*Birendra : Bug-7753 on 01/04/2013 :End:

ENDPROC
PROCEDURE KeyPress
Lparameters nKeyCode, nShiftAltCtrl

Do Case
	Case nKeyCode=13
		Return &retvalue
		Thisform.Release
	Case nKeyCode=27
		mEsckey="YES"
		Return " "
		Thisform.Release
Endcase

ENDPROC
PROCEDURE Init
*Birendra : Bug-7753 on 01/04/2013 :added more parameter for pTreeview:
LParameter para1,mCaption,pSearch,pRetvalue,pSearchValue,pSplitBar,pxTraField,PxTraCaption,pSrchAny,objgpop,pTreeview
*Parameter para1,mCaption,pSearch,pRetvalue,pSearchValue,pSplitBar,pxTraField,PxTraCaption,pSrchAny,objgpop
Rele  mpara3,mpara1,mpara2,mEsckey,retvalue,mSplitbar
*Birendra : Bug-7753 on 01/04/2013 :added more parameter for mTreeview:
Public mpara3,mpara1,mpara2,mEsckey,retvalue,mSplitbar,mxTraField,mxTraCaption,mSrchAny,mSearchValue,mTreeview
*Public mpara3,mpara1,mpara2,mEsckey,retvalue,mSplitbar,mxTraField,mxTraCaption,mSrchAny,mSearchValue


mEsckey=" "
mpara1=para1
mpara2=pSearch
mSplitbar = pSplitBar
mxTraField = pxTraField
mxTraCaption = PxTraCaption
mSrchAny = pSrchAny
mSearchValue = pSearchValue
*Birendra : Bug-7753 on 01/04/2013 :added more parameter for pTreeview:Start :
mTreeview=pTreeview
thisform.AddProperty("TreeView")
IF TYPE('&mTreeview..zkey')<>'U' AND TYPE('&mTreeview..ztext')<>'U' AND TYPE('&mTreeview..zparent')<>'U'
Thisform.treeview=.t.
ENDIF 
*Birendra : Bug-7753 on 01/04/2013 :added more parameter for pTreeview:End :

&& Added by Archana K. on 08/11/12 for Bug-7177 start
Push Key			
On Key Label f12  _Screen.ActiveForm.captioninit  
&& Added by Archana K. on 08/11/12 for Bug-7177 end

******** Added By Sachin N. S. on 01/02/2010 for TKT-250 ******** Start
Thisform.psearchcol=pSearch
Thisform.chkSearch.Value=.T.
ThisForm.ChkSearch.Enabled = .F.
******** Added By Sachin N. S. on 01/02/2010 for TKT-250 ******** End
With Thisform
	If Type("_stuff") = "O"
		.AddObject("_stuffObject","_stuff")
		._stuffObject._objectPaint()
	Endif
	.frmcapt = mCaption
	.objgpop = objgpop
	.cList = ''
	.Icon = icopath
	.BackColor = .objgpop.nBACKCOLOR
	.captioninit()
Endwith

If !"\_htextbox."$Lower(Set("Classlib"))
	Set Classlib To _hTextBox Additive
Endif

retvalue =Iif(Type('pRetvalue')="L",mpara2,pRetvalue)
pSearchValue = Iif(Type('pSearchvalue')="L","",pSearchValue)

Local cTy,cOldSearchexp
cTy = 1

With Thisform
	Do While .T.
		cSearchexp = At('+',pSearch,cTy)
		If cSearchexp = 0
			If cTy = 1
				cOldSearchexp = Len(pSearch)
				.cList = ["]+.cList + Substr(pSearch,Iif(cSearchexp=0,1,cOldSearchexp+1),Len(pSearch))+["]
			Else
				.cList = .cList + [,"]+Substr(pSearch,cOldSearchexp+1,Len(pSearch))+["]
			Endif
			Exit
		Else
			If cTy = 1
				.cList = ["]+.cList + Substr(pSearch,1,cSearchexp-1)+["]
				cOldSearchexp = cSearchexp
			Else
				.cList = .cList + [,"]+Substr(pSearch,cOldSearchexp+1,cSearchexp-cOldSearchexp-1)+["]
				cOldSearchexp = cSearchexp
			Endif
		Endif
		cTy = cTy + 1
	Enddo
	.formwidth = 0
	ShowFlds = .objgpop.ShowFlds
	Sele (mpara1)
	Select &ShowFlds From (mpara1) Into Cursor curSrch
	.Panel.panels(2).Text="Records found : "+Alltrim(Str(_Tally))
	.gridfill()
	
*!*		.Width = (.formwidth* IIF(thisform.grdgetpop.ColumnCount>1,2,1)) * 5
	.Width = .formwidth * 5 && Changed By Sachin N. S. on 19/02/2010 for Form Width based on Fields TKT-110

	If (.Width+20)  > Sysmetric(1)		&& Added by Shrikant S. on 03/06/2017 for GST	
*!*		If .Width  > Sysmetric(1)		&& Commented by Shrikant S. on 03/06/2017 for GST
		.Width = (.Width - (.Width - Sysmetric(1)))- 100
	Else
		If .Width = 800
			.Width = .Width - 200
		Endif
	Endif

	If !Empty(pSearch)
		If .Grdgetpop.ColumnCount = 1
			.Panel.panels(2).Width = .Width - 10
			.Panel.panels(3).Visible = .F.
		Else
			.Panel.panels(3).Width = (.Width / 1.50)
			.Panel.panels(3).Text="Search Fields : "+.searchcapfind(pSearch)
		Endif
	Endif
Endwith

* added class for display field Vertical
If !Empty(pxTraField) And !Empty(PxTraCaption)
* Textbox Controlsource
	Local pParam1,pParam2,tLstFlag
	Store '' To pParam1,pParam2
	Store 1 To ccnt
	For ccnt = 1 To 10
		cSearchexp = At('+',mxTraField,ccnt)
		If cSearchexp = 0
			If ccnt = 1
				cOldSearchexp = Len(mxTraField)
				pParam1 = ["]+pParam1 + Substr(mxTraField,Iif(cSearchexp=0,1,cOldSearchexp+1),Len(mxTraField))+["]
			Else
				If tLstFlag = .F.
					pParam1 = pParam1 + [,"]+Substr(mxTraField,cOldSearchexp+1,Len(mxTraField))+[",]
					tLstFlag = .T.
				Else
					pParam1 = pParam1 + [,]
				Endif
			Endif
		Else
			If ccnt = 1
				pParam1 = ["]+pParam1 + Substr(mxTraField,1,cSearchexp-1)+["]
				cOldSearchexp = cSearchexp
			Else
				pParam1 = pParam1 + [,"]+Substr(mxTraField,cOldSearchexp+1,cSearchexp-cOldSearchexp-1)+["]
				cOldSearchexp = cSearchexp
			Endif
		Endif
	Endfor

* Label Caption
	Store 1 To ccnt
	Store .F. To tLstFlag
	For ccnt = 1 To 10
		cSearchexp = At('+',mxTraCaption,ccnt)
		If cSearchexp = 0
			If ccnt = 1
				cOldSearchexp = Len(mxTraCaption)
				pParam2 = ["]+pParam2 + Substr(mxTraCaption,Iif(cSearchexp=0,1,cOldSearchexp+1),Len(mxTraField))+["]
			Else
				If tLstFlag = .F.
					pParam2 = pParam2 + [,"]+Substr(mxTraCaption,cOldSearchexp+1,Len(mxTraCaption))+["]
					tLstFlag = .T.
				Else
					pParam2 = pParam2 + [,]
				Endif
			Endif
		Else
			If ccnt = 1
				pParam2 = ["]+pParam2 + Substr(mxTraCaption,1,cSearchexp-1)+["]
				cOldSearchexp = cSearchexp
			Else
				pParam2 = pParam2 + [,"]+Substr(mxTraCaption,cOldSearchexp+1,cSearchexp-cOldSearchexp-1)+["]
				cOldSearchexp = cSearchexp
			Endif
		Endif
	Endfor

	ObjParameter = pParam1+pParam2

	With Thisform
		.AddObject("_TextBox","_hXtraTextBox",[],&ObjParameter)
		With Thisform._TextBox
			.Visible = .T.
			.Top    = Thisform.Grdgetpop.Top
			.Left   = Thisform.Grdgetpop.Width + 5
			.Height = Thisform.Grdgetpop.Height
			If (Thisform.Width - Thisform.Grdgetpop.Width - 8) > .Width
				.Width  = Thisform.Width - Thisform.Grdgetpop.Width - 8
			Else
				Thisform.Width = ( Thisform.Width + 10 )+ Thisform._TextBox.Width - ( Thisform.Width - Thisform.Grdgetpop.Width)
			Endif
			.shape1.Width  = .Width  - 10
			.shape1.Height = .Height - 08
		Endwith
	Endwith
Endif

*!*	THISFORM.text1.WIDTH = THISFORM.WIDTH - 50
Thisform.Panel.Width = Thisform.Width - 10
Thisform.AutoCenter = .T.
Thisform.text1.Value = pSearchValue
Thisform.text1.InteractiveChange()

ENDPROC
PROCEDURE Resize
Private mColCnt
With Thisform.Grdgetpop
	mColCnt=.ColumnCount
*!*		.Columns(mColCnt).Width=Thisform.Width-2

	If Empty(mxTraField) And Empty(mxTraCaption)
		.Width = Thisform.Width-2
	Endif

	Thisform.Panel.Width = Thisform.Width - 10

	If .ColumnCount = 1
		Thisform.Panel.panels(2).Width = (Thisform.Width / 1.20)
	Else
		Thisform.Panel.panels(3).Width = (Thisform.Width / 1.51)
	Endif

	If Thisform.Height <> 310
*		Thisform.Height = 310
		Thisform.Height = IIF(thisform.treeview,thisform.height,310)&&Birendra : Bug-7753 on 01/03/2013 
	Endif
Endwith

ENDPROC
     7���                              �   %   �       �      �           �  U  D  %��  � a��0 � T� �� � �� T�  � �-�� � ��C� � �� U  THIS VALUE MPARA2 THISFORM
 PSEARCHCOL ENABLED SETSEARCHPARAM Click,     ��1 !� A � 3                       ~       )                          8���                              �   %   �       �      �           �  U  A  ��C�  � �� ��C�  � � �� T�  � � �-�� ��C�  � � �� U  THISFORM CAPTIONINIT TEXT1 INTERACTIVECHANGE SELECTONENTRY SETFOCUS Valid,     ��1 � 3                       �       )                          ����    �  �                        �   %   �       5               �  U  A  ��  � � %�C�  �����: � T� �� YES��
 �� � � � U  NKEYCODE NSHIFTALTCTRL MESCKEY THISFORM RELEASE(  %��  � YES��! � ��C� � �� � U  MESCKEY THISFORM REFRESHRCRD KeyPress,     �� InteractiveChange�     ��1 � Q� A 3 A� B 2                       �         �   �  	    )   �                        ����    �   �                         q^   %   3       H      D           �  U    U   Refresh,     ��1 3                       3       )   �                        ����    �  �                        w   %   6           c          �  U    T�  � �a�� ��C�  � �� U  THISFORM
 DBLCLICKED RELEASEe  ��  � %�� � -��Q � %�C� �
� C� �
	��C � ��C� � � �� �
 �� � � � ��C� � �� U	 	 NCOLINDEX THISFORM
 DBLCLICKED
 MXTRAFIELD MXTRACAPTION _TEXTBOX REFRESH THIS
 TREESEARCH DblClick,     �� AfterRowColChangem     ��1 � � 01 q "�A � B � 1                       �        �  �      )   �                        BArial, 0, 8, 5, 14, 11, 29, 3, 0
Arial, 1, 8, 5, 14, 11, 29, 3, 0
      .OLEObject = c:\Windows\SysWOW64\MSCOMCTL.OCX
      ��ࡱ�                >  ��	                               ����        ������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������   ����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������R o o t   E n t r y                                               ��������                               �d�J��   @       O l e O b j e c t D a t a                                            ����                                        j        A c c e s s O b j S i t e D a t a                             &  ������������                                       \        C h a n g e d P r o p s                                         ������������                                       %            ����   ����         ��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������Aǉ���j ��(6(!C4   �,  �  �<�j  "   ��u	  �y�u   �ͫ\                          $   8                       9368265E-85FE-11d1-8BE3-0000F8754DA1�����\W�� ��  ��  �w  ���x  �n  �  �   HideSelection    L      Indentation    N             `� ��      ���    \ ��  8� ��*��"������}��"�  $@
   LineStyle 	   I
          MousePointer 	   I
          PathSeparator 
   H       \   Style 	   I
         OLEDragMode 	   I
          OLEDropMode 	   I
          Appearance 	   I
         FullRowSelect    L                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     FTop = 290
Left = 5
Height = 192
Width = 432
Name = "OleTreeView"
      	Frmgetpop      OleTreeView      
olecontrol      
olecontrol      �PROCEDURE Click
If This.Value = .T.
	mPara2 = Thisform.psearchcol
	This.Enabled = .F.
Endif
ThisForm.setSearchParam()


ENDPROC
      �Top = 29
Left = 42
Height = 16
Width = 90
FontSize = 8
AutoSize = .T.
Alignment = 0
BackStyle = 0
Caption = "Default Search"
Name = "ChkSearch"
      	Frmgetpop      	ChkSearch      checkbox      checkbox      �AutoSize = .T.
FontBold = .T.
FontSize = 8
BackStyle = 0
Caption = "\<Search"
Height = 16
Left = 3
Top = 7
Width = 40
TabIndex = 1
ForeColor = 0,0,130
Name = "Label1"
      	Frmgetpop      Label1      label      label      �PROCEDURE Valid
Thisform.captioninit()
Thisform.text1.InteractiveChange()
Thisform.text1.SelectOnEntry = .F.
Thisform.text1.SetFocus()


ENDPROC
     	Top = 2
Left = 403
Height = 26
Width = 35
FontBold = .T.
FontSize = 8
Anchor = 8
AutoSize = .F.
Alignment = 1
BackStyle = 0
Caption = ""
ControlSource = "mSrchAny"
SpecialEffect = 2
Style = 1
TabIndex = 5
ForeColor = 0,0,160
Name = "Chksearchtype"
      	Frmgetpop      Chksearchtype      checkbox      checkbox     �PROCEDURE KeyPress
LPARAMETERS nKeyCode, nShiftAltCtrl
IF INLIST(nKeyCode,13,27)
	mesckey = "YES"
	THISFORM.RELEASE
ENDIF

ENDPROC
PROCEDURE InteractiveChange
If mEsckey != "YES"
************ Commented By Sachin N. S. on 01/02/2010 for TKT-250 ************ Start
*!*		ShowFlds = THISFORM.objgpop.ShowFlds
*!*		_TALLY = 0
*!*		mtext = THISFORM.setsplkeys(THIS.VALUE,1)+IIF(mSrchAny = .F.,"%"+ALLT(UPPER(THIS.VALUE))+"%",ALLT(UPPER(THIS.VALUE))+"%")+THISFORM.setsplkeys(THIS.VALUE,2)
*!*		IF ! EMPTY(mSearchValue)
*!*			STORE "" TO mSearchValue
*!*		ENDIF
*!*		SELECT &ShowFlds FROM &mpara1 WHERE UPPER(&mpara2) LIKE &mtext INTO CURSOR curSrch
*!*		THISFORM.PANEL.panels(2).TEXT="Records Found : "+ALLTRIM(STR(_TALLY))
*!*		THISFORM.gridfill()
*!*		THISFORM.RESIZE

	Thisform.refreshrcrd()
************ Commented By Sachin N. S. on 01/02/2010 for TKT-250 ************ End
Endif

ENDPROC
      �FontBold = .T.
FontSize = 8
Anchor = 10
Format = ""
Height = 26
Left = 42
SelectOnEntry = .T.
SpecialEffect = 2
TabIndex = 2
Top = 2
Width = 360
BorderColor = 192,192,192
Themes = .F.
Name = "Text1"
      	Frmgetpop      Text1      textbox      textbox      .OLEObject = c:\Windows\SysWOW64\MSCOMCTL.OCX
      >PROCEDURE Refresh
*** ActiveX Control Method ***

ENDPROC
      XTop = 489
Left = 0
Height = 21
Width = 442
TabIndex = 4
Align = 2
Name = "Panel"
      	Frmgetpop      Panel      
olecontrol      
olecontrol     �PROCEDURE DblClick
THISFORM.DblClicked = .T.
THISFORM.RELEASE()

*!*	ON KEY LABEL ENTER
*!*	ON KEY LABEL esc
*!*	IF mesckey="YES"
*!*		RELE mpara3,mpara1,mpara2,mesckey,retvalue,msplitbar,mxtrafield,mxtracaption,msrchany,msearchvalue
*!*		RETURN .F.
*!*	ELSE
*!*		SELECT cursrch
*!*		pCretVal = IIF(TYPE('retvalue') = 'L',[],IIF(EMPTY(retvalue),[],retvalue))
*!*		RELE mpara3,mpara1,mpara2,mesckey,msplitbar,mxtrafield,mxtracaption,msrchany,msearchvalue
*!*		IF ATC([,],pCretVal) <> 0
*!*			SCATTER FIELDS &pCretVal NAME Curobj
*!*			RETURN Curobj
*!*		ELSE
*!*			RETURN IIF(!EMPTY(pCretVal),&pCretVal,[])
*!*		ENDIF
*!*	ENDIF

ENDPROC
PROCEDURE AfterRowColChange
LPARAMETERS nColIndex

IF THISFORM.DblClicked = .F.

	IF !EMPTY(mxTraField) AND !EMPTY(mxTraCaption)
		THISFORM._TextBox.REFRESH()
	ENDIF

	THIS.REFRESH

ENDIF

*Birendra : Bug-7753 on 01/04/2013
thisform.treesearch ()
ENDPROC
     DFontSize = 8
AllowAddNew = .F.
AllowHeaderSizing = .F.
AllowRowSizing = .F.
DeleteMark = .F.
GridLines = 3
Height = 238
Highlight = .T.
HighlightRowLineWidth = 0
Left = 3
Panel = 1
RecordMark = .F.
RecordSource = ""
RecordSourceType = 1
RowHeight = 17
SplitBar = .T.
TabIndex = 3
Top = 48
Width = 435
BackColor = 255,255,255
GridLineColor = 249,242,238
HighlightBackColor = 235,235,235
HighlightForeColor = 128,0,64
SelectedItemBackColor = 228,228,228
SelectedItemForeColor = 128,0,64
HighlightStyle = 2
Themes = .F.
Optimize = .T.
Name = "Grdgetpop"
      	Frmgetpop      	Grdgetpop      grid      grid     _formwidth
clist
oldclasslib
dblclicked
objgpop External getpop object
frmcapt Form Caption
psearchcol
psearchdef
*entr 
*gridfill 
*esc 
*columnbindevents 
*assigncaption 
*udfindchar 
*searchcapfind 
*captioninit 
*setsplkeys 
*totfieldproc 
*fieldsizeproc 
*hdrclick 
*refreshrcrd 
*setsearchparam 
*createnode 
*treesearch 
     ;f��ࡱ�                >  ��	                               ����        ����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������            	   
                                                         ����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������R o o t   E n t r y                                               ��������                               �d�J��   �        O l e O b j e c t D a t a                                            ����                                       f1       A c c e s s O b j S i t e D a t a                             &  ������������                                        \        C h a n g e d P r o p s                                         ������������                                                 ����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������\                          $   8                       9368265E-85FE-11d1-8BE3-0000F8754DA1                                      �                                                            �g8�����j ��(6(!C4   �-  ,  �~��   i�\'  ~�� �ͫ          ��������              �  �       ��p  p      �  �  �      !� +  +        C A P S �ޣ i  	        1 4 : 4 6   A    lt  h0    h0                                          ������  ��   ��  ��        �     � �   � �  � �g8�����j ��(6(!C4   �-  ,  �~��   �     ~�� �ͫ          ��������              �  �       ��p  p      �  �  �      !� +  +        C A P S �ޣ i  	        1 4 : 4 6       lt  h0           (  �         h  �       �          �  �         �  �          �  �  00     h  V  00      �  �!  (                �                            �   �� �   � � ��  ��� ���   �      �� �   � � ��  ��� wwqx���qx�DD���D�LD�q�L�t�Oqx����LO�LLt������������������̏|��x�t�|O�����Oq������qx�����x���qwwq��q��L��̀�q���  �|  �q  ��  ��  �q  L̀���q�L������(                @                      ���     ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� SFE ��� ��� ��� ��� ��� ��� ��� ��� ��� �ǽ ﲜ ޺� ��� ��� ��� ��� ��� ��� Ɔk ��� Ƣ� ��� ��� �]1 �i9 �e9 �qB �qB �mB �yJ �uJ ��k ޚ{ 戴 ֞� 箔 ު� �ǵ ��� ��� ��� ��� ��� �e1 �a1 �m9 �i9 �i9 �uB �e9 �}J �qB �R �R ��Z �Z ��c �c ��k �uR ��s �}Z ֊c ��{ ޒk Άc �{ ��k ֚{ Ǝs ��� ��{ ޲� �í �ӽ �˽ ��� �]) �i1 �e1 �q9 �m9 �yB �uB �J ��Z ւR ��c ֆZ �s Ίc Ύk ��c ֖s ��� ޞ{ Ɩ{ ֦� �ǭ �ϵ ޾� �ǵ �Ͻ ��� �Z ��k ��{ ��s ��� Φ� ��� ��� ��� �ǽ ��{ ��� ��� ��� �ǔ ��� ��� ��� �׭ �Ӝ �ץ �߭ ��� �� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ���                                                                                                                                                                                                                                                                                                                                                                                                                 V"~$$v~55v%Wp~Z5 T\\W\\1v�5+\\#D\\l�~5n\::=M::\\Z
�	;\:\Pv'\:\BZ�\::\e2\\:\�::::\3	h\:\�$�['::\\\':=�I'j e\lw\H��CD��)_��z0$�NE7����������������\i��X:�::�#�  ::  :-    X:  ::  (�M:�:-��r_�?::(      0         �                           �   �� �   � � ��  ��� ���   �      �� �   � � ��  ��� wwwqw����qw������q���DD���x��Lw|D��q�LG��LO�q�����������LLL��LLO�x�D������H�q���ď�L���q���̏��LD�q��L̏�����q������|���q����̏����qx�L�����H�q�LǇ����H�����|�����G����G�qx��O��D��q���DD���w������qw����qwwwq���� �� �� q� �� ̀ ̀   �  �  �    L  w  ̀ � L� �� �� � �� �������(      0         �                      ���     ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� SFE ��� ��� ��� ��� ��� ��� ��� ��� ��� �ǽ ﲜ ޺� ��� ��� ��� ��� ��� ��� Ɔk ��� Ƣ� ��� ��� �]1 �i9 �e9 �qB �qB �mB �yJ �uJ ��k ޚ{ 戴 ֞� 箔 ު� �ǵ ��� ��� ��� ��� ��� �e1 �a1 �m9 �i9 �i9 �uB �e9 �}J �qB �R �R ��Z �Z ��c �c ��k �uR ��s �}Z ֊c ��{ ޒk Άc �{ ��k ֚{ Ǝs ��� ��{ ޲� �í �ӽ �˽ ��� �]) �i1 �e1 �q9 �m9 �yB �uB �J ��Z ւR ��c ֆZ �s Ίc Ύk ��c ֖s ��� ޞ{ Ɩ{ ֦� �ǭ �ϵ ޾� �ǵ �Ͻ ��� �Z ��k ��{ ��s ��� Φ� ��� ��� ��� �ǽ ��{ ��� ��� ��� �ǔ ��� ��� ��� �׭ �Ӝ �ץ �߭ ��� �� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ���                                                                                                                                                                                                                                                                                                                                                                                                                 5�%��9��9#p�$$5$p@\+L\&Ps�	$5B\\@�1\\\S(\^:J�::\\j�B;:::^pue:::;\p	3\:]:::=*:::::\(
-;]]::>sO;::::\3[:]]:::>�W:::::\i�X:=]::::#�M:::]:-
X:<]::::(M:]]:-
r_*<:::::>�-:']e	A?_]:::::B
2:<'lQC)-}/:::X'?'4��dE,�e:13_?H	�q.d1��HcC7��{K����$0dGr����U{ym8 9������������� '� :� ^� ~� <� �   7  <  :  :    _      � _� � :� � ?� ��(       @         �                           �   �� �   � � ��  ��� ���   �      �� �   � � ��  ��� wwwqw����wx������wx��������q���DDDH�����D�w��H��q��DLx�|LDO�wx�����t�����q�LLLx�|LLLO�q��D���w����H�w���LLLLL�LLD���t���Ȉ|L��ď�x�L�����|�L�LO�q�L�����|��L�O�q�L����������O�q�L�����L���O�q�L����������O�q�L������L��O�qx�L������|��O�q����w|�x�|�ď���������|�ď���L���w��L�H���L�������O�qx�������w����q��D�www��O����D����H��q���DDDH���x��������qx������ww����wwwwq�������  ��  �  ?�  �  �  �  �  �  �                       �  �  �  �  �  �  �  �  ?�  �  �����������(       @         �                      ���     ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� SFE ��� ��� ��� ��� ��� ��� ��� ��� ��� �ǽ ﲜ ޺� ��� ��� ��� ��� ��� ��� Ɔk ��� Ƣ� ��� ��� �]1 �i9 �e9 �qB �qB �mB �yJ �uJ ��k ޚ{ 戴 ֞� 箔 ު� �ǵ ��� ��� ��� ��� ��� �e1 �a1 �m9 �i9 �i9 �uB �e9 �}J �qB �R �R ��Z �Z ��c �c ��k �uR ��s �}Z ֊c ��{ ޒk Άc �{ ��k ֚{ Ǝs ��� ��{ ޲� �í �ӽ �˽ ��� �]) �i1 �e1 �q9 �m9 �yB �uB �J ��Z ւR ��c ֆZ �s Ίc Ύk ��c ֖s ��� ޞ{ Ɩ{ ֦� �ǭ �ϵ ޾� �ǵ �Ͻ ��� �Z ��k ��{ ��s ��� Φ� ��� ��� ��� �ǽ ��{ ��� ��� ��� �ǔ ��� ��� ��� �׭ �Ӝ �ץ �߭ ��� �� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ���                                                                                                                                                                                                                                                                                                                                                                                                                 VV�%�~ 
��
v%������� %  �%9TJLJjp�v5 ���pB\\&PB\\\P���v5���%P\\\(#�
M\\\&p�vs ��>\;;:k�u;;;\\j�s�>;;:::+�p:::;;\S�
s�P;^:::::P4p:::::;;\��sX\;:::::::::::::::^;B�
sv�P;:]]::::SXX-::::::;\�%s$^:]]]::::9O;::::::\Ps�;]']:::::90:::::]:;B$�vs3:=']:::::RM::::]]:>% s1]<<]:::::>5�M:::]]:=} s0<_<]::::::^9�M::]=]= s_?_':::::::^�~`:'<]+v s	7aA?<]:::::::BO:<_]M	vs[HCA_`T3-::::'_?]0sqECA-��X;::B$p<aa?}s	KGdA#�-eZ�O?A?0 sv8xxGM�	��CCCH�}s�{{xn����hdGG8 9s���{mX��Xyxxy�	69s����������{��9sv���������9s~	s9ssv��s9ss~ 	v�ssssssssss�������� �� ��  �  ?�  �  �  �  �  �                                �  �  �  �  �  �  ?�  � �� ����(   0   `                                     �   �� �   � � ��  ��� ���   �      �� �   � � ��  ���       �����  ��������� ������������������������x����DDDDH��������DLLLLDD����x���D��DD���H������DLLD��LLLDO���x������������ď�����LLLL���LLLLH���������������������x��LLLLLG��|LLLLLO����D�����ww������H�����LLLL�LLLLLLLLLD�����D����L�DDL������O����LL�LL����L���LLLO����L�L������LL�L���H��x�����L�L�������L�����x��L�����G����L��LLD�������LL����L�����ď�����L������������ď��������������L����ď������������������ď���������������L���ď�x�������������L���ď�x������������������ď���L���������������H����L���ww|���������H����L���������������H�������������������ď����L�����ww�����H����L������������H��������������L�Ĉ�����L����������H��������������L�Ĉ�����D���www|��H������L�������D���q����D�����D��������DDDDH����q�������������w�����������qw���������qww�����wqwwwwq������  ������  �����  �� ��  ��  �  ��  �  ��  �  �   �  �   �  �   �  �    �  �      �    ?  �    ?  �      �      �      �      �      �                                                                     �      �      �      �      �      �      �    ?  �    ?  �      �    �  �   �  �   �  �   �  ��  �  ��  �  ��  �  �� ��  �����  ������  (   0   `         �
                      ���     ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� SFE ��� ��� ��� ��� ��� ��� ��� ��� ��� �ǽ ﲜ ޺� ��� ��� ��� ��� ��� ��� Ɔk ��� Ƣ� ��� ��� �]1 �i9 �e9 �qB �qB �mB �yJ �uJ ��k ޚ{ 戴 ֞� 箔 ު� �ǵ ��� ��� ��� ��� ��� �e1 �a1 �m9 �i9 �i9 �uB �e9 �}J �qB �R �R ��Z �Z ��c �c ��k �uR ��s �}Z ֊c ��{ ޒk Άc �{ ��k ֚{ Ǝs ��� ��{ ޲� �í �ӽ �˽ ��� �]) �i1 �e1 �q9 �m9 �yB �uB �J ��Z ւR ��c ֆZ �s Ίc Ύk ��c ֖s ��� ޞ{ Ɩ{ ֦� �ǭ �ϵ ޾� �ǵ �Ͻ ��� �Z ��k ��{ ��s ��� Φ� ��� ��� ��� �ǽ ��{ ��� ��� ��� �ǔ ��� ��� ��� �׭ �Ӝ �ץ �߭ ��� �� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ���                                                                                                                                                                                                                                                                                                                                                                                                                 7777777777777 ����  7777v������  77	�������������  77~	������������	v 7������#TkLLLi1���� 7	���$!@&\\\\\\\&(j$���	 7	���tP\\\;;(j1j;;\\\\Ps���	  	���p>\;;;;>#��W;;;;\\@S$���	7��$j\;;;;;^R��	O;;;;;\\P%����7�$P;;;;;:::V��3::^;;;;\L%��~7	�j;;;;:::::R9�l::::^;;;\P$��	��p;;;^::::::+5��W::::::^;;;\S��[7��(;;^::::::::+p/]::::::::;;;@s��	7~���j;;::::::::::::::::::::::::;;;P�7	��Z^;^:::]::::::`bbb<:::::::::^;;;s��7�S;^::]]::::::+#7::::::::::^;;P��	7~�B^:]]]]::::::+9�:::::::::::;;(%��^:]]]]]::::::+9`:::::::]:::;;W�73:]==]]:::::::`5�g:::::::]]::^;S��	/]==']]::::::::"�6b::::::]]]:^^P�	M=`<<']::::::::J9�uB:::::]]]]:^g
�	g`<<<']:::::::::k9u-::::]]]]]:g
�M<__<<]::::::::::k�ub:::]]===:g�7�O_**_<]:::::::::::k��4=::]=<<==g		0???)<']:::::::::::Rn::]<<<`=O�qa,a?_<]::::::::::::o6`]'<<<<`2DAA,?<']:::::::::::Be]<<__<<u[~hCCc,)<-l1WXn::::::=��O'<))*_e	YFFCca_i���[-:::::+�O<)???b07IddFcae��:::::l
%e)?aaa,8	~�ffGECa#�	-]Bl$,aAAA,�mxx.dCM��v6}��2,cCCDH	�yzKfE|�wCFEFF8	���{yKIW��%QdGGGdr	������z��������uN.xxx.r������mUXttttXmzyyyyy�[����������{{������������������������	����������	�	[		[�				v~������  �����  ��  ��  ��  ?�  ��  �  ��  �  ��  �  �   �  �    �  �      �    ?  �      �      �      �      �      �      �      �      �                                                                            �      �      �      �      �      �      �      �    ?  �      �    �  �   �  �   �  �   �  ��  �  ��  ?�  ��  ��  �� ��  �����    ��     R������ � K�Q   �DB Arial     6V���    =6  =6                        �/   %   O/      �4  �  �0          �  U    {2� Enter�  �
 �� � � U  ENTER THISFORM RELEASE� 5�  � T�  ���� ��� � ��W� T�� ���� T�� �� curSrch��! T�� �C�� �� �� �6�� T�� �C�������^�� T�� �C� � �� +��  �� ��K�  T�	 �� .� columnCC�  Z���r T�
 �� .� columnCC�  Z�� .width=CCC �  �� � ��(�	 �� �	� �� � C �  �� � �6�Z�� T� �C �  � � ��H T� �� .� columnCC�  Z�� .Header1.caption =� 'CC� ��� '��4 T� �� .� columnCC�  Z�� .Header1.caption��9 T� �� .� columnCC�  Z�� .Header1.fontsize = 8��: T� �� .� columnCC�  Z�� .Header1.alignment = 2��N T� �� .� columnCC�  Z�� .controlsource=� 'CC �  �� � �� '��/ T� �� .� columnCC�  Z�� .fontsize=8��8 T� �� .� columnCC�  Z�� .Text1.alignment = 0��2 T� �� .� columnCC�  Z�� .alignment = 0�� &Colwidth
 &ColHdcapt
 T� �CC� � f���  %�CCC �  �� � f�� ���E T� �� .� columnCC�  Z��! .Header1.forecolor = rgb(0,0,255)��; T� �� .� columnCC�  Z�� .Header1.fontbold = .t.�� &ColTXTAlig
 &ColAlig
 ���C T� �� .� columnCC�  Z�� .Header1.forecolor = rgb(0,0,0)��; T� �� .� columnCC�  Z�� .Header1.fontbold = .f.�� � &ColHdFont
 &ColHdAlig
 &ColHdFrCr
 &ColHdFnBd
 &ColFont
 &ColSource
S T� � �� � CC �  �� � ��(�	 �� �	� �(� C �  �� � �
6�� T�  ��  ��� � ��� � �� %�� � �<��� T� � ��=�� � ��C� � ��
 �� � �
 �� � � U  COLC THISFORM	 GRDGETPOP RECORDSOURCETYPE RECORDSOURCE
 SCROLLBARS COLUMNCOUNT	 BACKCOLOR TOTFIELDPROC	 COLOBJECT COLWIDTH FIELDSIZEPROC COLCAPT ASSIGNCAPTION	 COLHDCAPT	 COLHDCAPP	 COLHDFONT	 COLHDALIG	 COLSOURCE COLFONT
 COLTXTALIG COLALIG LISTOPT CLIST	 COLHDFRCR	 COLHDFNBD	 FORMWIDTH REFRESH COLUMNBINDEVENTS RESIZE,  {2� Esc�  � T� �� YES��
 �� � � U  ESC MESCKEY THISFORM RELEASE�  T�  �� � � �� %��  � ��� � ��� � ��� � �� ���(��  ��� �. ��CC � �� � � keypress� � KeyPress��1 ��CC � �� � � DblClick� � � DblClick��+ ��CC � �� � � Click� � HdrClick�� �� �� � U 	 MCOLCOUNT THISFORM	 GRDGETPOP COLUMNCOUNT I COLUMNS TEXT1 HEADER1P ��  Q� INTEGER� 5�  � � � � T� �C� � � ��� T� ��  �� T� �C �  �� � �� ��	 ���(�� ��#� T�
 �C �  �� � ��5 T� �CC �	 � � � �C� :C �	 � � � ��\��  T� �CCC� C� .� ��\�f�� %�C�
 @C� @���# T� �CC �	 � � � � :� ,���� !� � �� T� �CC� �� �  � � 6��	 B�� �� U  COLC Y YESNO NFNDSTR NTOTCAP THISFORM OBJGPOP CAPARRY FIELDSIZEPROC NI X1 Y1 Y2#   ��  Q� INTEGER� Q� STRING� U 	 NFROMCHAR	 CSEARCHIN� ��  Q� STRING� 5�  � � � � � � T� �C� � �	 ��� T� ��  �� T� ��  �� T�
 �CC� � f��� T�
 �C�
 � "�  ��� T�
 ��
 � ,�� +�a���� %�C�
 �
���� T� �CC�
 C� ,�
 �=f�� �� ���(�� ��;�( %�CC � � � �	 �  � :��C� f��7�# T� �CC � � � �	 � :� ,���� !� � ��' T� �� CC� �
� � +� �  6� �� T�
 �C�
 � � ,�  ��� ��� !� � � T� �CC� �� C�  �� � 6��	 B�� �� U  COLC Y YESNO NFNDSTR B A NTOTCAP THISFORM OBJGPOP CAPARRY LISTOPT CLIST NI@ %��  a��� �( T� � � �� � BMP\SEARCHANY.BMP��" T� � � �� Search Anywhere��1 T� � �C� � �C�X� - Search Anywhere �� T�  �-�� �)�( T� � � �� � BMP\INCSEARCH.BMP��% T� � � �� Incremental Search��4 T� � �C� � �C�X� - Incremental Search �� T�  �a�� � ��C� � � �� U	  MSRCHANY THISFORM CHKSEARCHTYPE PICTURE APATH TOOLTIPTEXT CAPTION FRMCAPT REFRESH�  4�  � � �� �� T� �CC� "�  �� � C� '�  �� 	� � '�k CC� '�  �� � C� "�  �� 	� � "�A CC� '�  �� � C� "�  �� 	� C� �� � [� � ]6� � '666��	 B�� �� U  SPLKEYS RORL Y>  5�  � � T�  �� � � �� T� �C� <<�  ���	 B�� �� U  LCFLDSTR LNFLDSTR THISFORM OBJGPOP
 SESHOWFLDSw ! ��  Q� INTEGER� Q� INTEGER� 5� �# T� �C� � � � <<� >>�  ����) B�C� �� C� �� C� � curSrch/6�� U  TNFLDNUM TNTYPE LCFIELD THISFORM OBJGPOP
 SESHOWFLDS� T�  �C�� ���� %��  � ���� ��� ���� T� �C�� �� %�C� � �
��N� T� �C� � ��� H�s �J� �C� � b� D��� � T� �� DTOC(� � )�� �C� � b� T��� � T� �� TTOC(� � )�� �C� � b� N���% T� ��	 allt(str(� � ,20,4))�� �C� � b� I��J�  T� ��	 allt(str(� � ))�� � � ��C� � �� T�� � �-�� T�� �	 �a�� ���
 � � �� � U 	 GNOBJECTS
 GASELECTED THISFORM _CUROBJNAME CONTROLSOURCE MPARA2 SETSEARCHPARAM	 CHKSEARCH VALUE ENABLED TEXT1 SETFOCUS� T�  �� � �  �� T� �� �� %�C� �
��< � J��  �(� � � %�C� b� L���h T� �C� � � �� � C�	 -� � %CC� � � f�� %� CC� � � f�� %6C� � � �� � ��V SELECT &ShowFlds FROM &mpara1 WHERE UPPER(&mpara2) LIKE &mtext INTO CURSOR curSrch
 �H� %�CCC� � � f��
���! T� �� .CC� � � f�� .�� %�C� � .T.� .F.�����L SELECT &ShowFlds FROM &mpara1 WHERE &mpara2 = &mtext INTO CURSOR curSrch
 ��? SELECT &ShowFlds FROM &mpara1 WHERE 1=2 INTO CURSOR curSrch
 � �D�5 SELECT &ShowFlds FROM &mpara1 INTO CURSOR curSrch
 � �X T� �
 � ���� �� Records Found : CC� Z��!  | F12- Toggle for Search option �� ��C� � ��
 �� � � U  SHOWFLDS THISFORM OBJGPOP MSEARCHVALUE MPARA2 MTEXT
 SETSPLKEYS TEXT1 VALUE MSRCHANY PANEL PANELS TEXT GRIDFILL RESIZE	 ���  ��� �� � � T� ���� T�� ��  �� +�a���� T� �C� +� � �� %�� � ��� � %�� ���� � T� �C� >��= T�� �� "�� C� C� � � �� � �6C� >\� "�� �� �, T�� ��� � ,"C� � �C� >\� "�� � !� ��� %�� ���N�) T�� �� "�� C� �� �\� "�� T� �� �� ���2 T�� ��� � ,"C� � �� � �\� "�� T� �� �� � � T� �� ��� � T�� � ��  ��4 T�� �	 ����
 �� Search Fields : C � �� �� ��C�� �� �� U  THISFORM CTY COLDSEARCHEXP CLIST
 CSEARCHEXP MPARA2	 GRDGETPOP RECORDSOURCE PANEL PANELS TEXT SEARCHCAPFIND REFRESHRCRD�  ��  � � � � T� � � �a�� T� � � �-�� SELECT &mTreeview
 #)� ~�� � %�C� ���� �$ ��C��C�	 �C�
 �� �  � � � �� �� �( ��CC� ��C�	 �C�
 �� �  � � � �� � � F� � #)� U  THIS OLETREEVIEW NODES CLEAR THISFORM	 SINGLESEL ENABLED ZPARENT ADD ZKEY ZTEXT CURSRCH�   ��  ���(�� � � � ��� �" T� �CCC �  � � � � � �f�� z2=ALLTRIM(UPPER(&mPara2))
 %�� � ��� � T� � � � ��  ��	 �a�� � �� U
  N THISFORM OLETREEVIEW NODES COUNT Z1 ITEM TEXT Z2 SELECTED  ��C�  � �� U  THISFORM ESCr {2� Enter�  � {2� esc�  � {2� f12�  � �� %�� � YES��z �+ <� � � � � � �	 �
 � � � B�-�� �k� F� �: T� �CC� retvalueb� L� �  � CC� �� �  � � 66��' <� � � � � �	 �
 � � � %�C� ,� �� ��2�( Scatter Fields &pCretVal Name Curobj
	 B�� �� �g�- Return Iif(!Empty(pCretVal),&pCretVal,[])
 � � U  ENTER ESC F12 MESCKEY MPARA3 MPARA1 MPARA2 RETVALUE	 MSPLITBAR
 MXTRAFIELD MXTRACAPTION MSRCHANY MSEARCHVALUE CURSRCH PCRETVAL CUROBJ�  %�C�  ��� O��- � ��C------------a-� �� �( 12� Enter� _Screen.ActiveForm.entr�% 12� esc� _Screen.ActiveForm.esc� �� � � � %�� � ��� � T� �	 �
 �a�� ��C� � �� �� � T� �	 �
 �-�� � U 
 TBRDESKTOP BARSTAT ENTER ESC THISFORM	 GRDGETPOP REFRESH TREEVIEW THIS OLETREEVIEW VISIBLE
 CREATENODE�  ��  � � H� �| � ��  ���G � Return &retvalue

 �� � � ��  ���| � T� �� YES��
 B��  ��
 �� � � � U  NKEYCODE NSHIFTALTCTRL THISFORM RELEASE MESCKEY4/ ��  � � � � � � � � �	 �
 � <� � � � � � �/ 7� � � � � � � � � � � � T� ��  �� T� ��  �� T� �� �� T� �� �� T� �� �� T� �� �� T� �� �� T� �� �� T� ��
 �� ��C� TreeView� � ��p IF TYPE('&mTreeview..zkey')<>'U' AND TYPE('&mTreeview..ztext')<>'U' AND TYPE('&mTreeview..zparent')<>'U'��� T� � �a�� � ��/ 12� f12�  _Screen.ActiveForm.captioninit  � T� � �� �� T� � � �a�� T� � � �-�� ��� ���� %�C� _stuffb� O��G�# ��C� _stuffObject� _stuff�� �� ��C�� �  �� � T��! �� �� T��	 ��	 �� T��" ��  �� T��# ��$ �� T��% ���	 �& �� ��C��' �� ��) %�� \_htextbox.CC� Classlibv@
���� G~(�	 _hTextBox� �+ T� �CC�	 pRetvalueb� L� � � � 6��. T� �CC� pSearchvalueb� L� �  � � 6�� ��) �* � T�) ���� ��� ���� +�a���� T�+ �C� +� �) �� %��+ � ��.� %��) ����� T�* �C� >��= T��" �� "��" C� C�+ � � �� �* �6C� >\� "�� �&�, T��" ���" � ,"C� �* �C� >\� "�� � !� ��� %��) ���}�) T��" �� "��" C� ��+ �\� "�� T�* ��+ �� ���2 T��" ���" � ,"C� �* ��+ �* �\� "�� T�* ��+ �� � � T�) ��) ��� � T��, �� �� T�- ���	 �- ��
 F�� ��6 Select &ShowFlds From (mpara1) Into Cursor curSrch
1 T��. �/ ����0 �� Records found : CC� Z��� ��C��1 �� T��2 ���, ��� %���2 �C��%����! T��2 ���2 ��2 C��%�d�� ��� %���2 � ���� T��2 ���2 ���� � � %�C� �
���� %���3 �4 ���\� T��. �/ ����2 ���2 �
�� T��. �/ ����5 �-�� ���( T��. �/ ����2 ���2 �      �?��4 T��. �/ ����0 �� Search Fields : C � ��6 �� � � �� %�C� �
� C� �
	���� ��7 �8 �9 � J��  �(�7 �8 � J���(�: � ��: ���(��
���� T�+ �C� +� �: �� %��+ � ��� %��: ����� T�* �C� >��; T�7 �� "�7 C� C�+ � � �� �* �6C� >\� "�� �� %��9 -����+ T�7 ��7 � ,"C� �* �C� >\� ",�� T�9 �a�� �� T�7 ��7 � ,�� � � ��� %��: ���h�' T�7 �� "�7 C� ��+ �\� "�� T�* ��+ �� ���0 T�7 ��7 � ,"C� �* ��+ �* �\� "�� T�* ��+ �� � � �� J���(�: � J�-�(�9 � ��: ���(��
��r
� T�+ �C� +� �: �� %��+ � ���	� %��: ���j	� T�* �C� >��; T�8 �� "�8 C� C�+ � � �� �* �6C� >\� "�� ��	� %��9 -���	�* T�8 ��8 � ,"C� �* �C� >\� "�� T�9 �a�� ��	� T�8 ��8 � ,�� � � �n
� %��: ���%
�' T�8 �� "�8 C� ��+ �\� "�� T�* ��+ �� �j
�0 T�8 ��8 � ,"C� �* ��+ �* �\� "�� T�* ��+ �� � � �� T�; ��7 �8 �� ��� ����; .AddObject("_TextBox","_hXtraTextBox",[],&ObjParameter)
 ��� �< ���� T��5 �a�� T��= �� �3 �= �� T��> �� �3 �2 ��� T��? �� �3 �? ��$ %�� �2 � �3 �2 ���2 ��n� T��2 �� �2 � �3 �2 ��� ���4 T� �2 �� �2 �
� �< �2 � �2 � �3 �2 �� � T��@ �2 ���2 �
�� T��@ �? ���? ��� �� �� � T� �. �2 �� �2 �
�� T� �A �a�� T� �B � �� �� ��C� �B �C �� UD  PARA1 MCAPTION PSEARCH	 PRETVALUE PSEARCHVALUE	 PSPLITBAR
 PXTRAFIELD PXTRACAPTION PSRCHANY OBJGPOP	 PTREEVIEW MPARA3 MPARA1 MPARA2 MESCKEY RETVALUE	 MSPLITBAR
 MXTRAFIELD MXTRACAPTION MSRCHANY MSEARCHVALUE	 MTREEVIEW THISFORM ADDPROPERTY TREEVIEW F12
 PSEARCHCOL	 CHKSEARCH VALUE ENABLED	 ADDOBJECT _STUFFOBJECT _OBJECTPAINT FRMCAPT CLIST ICON ICOPATH	 BACKCOLOR
 NBACKCOLOR CAPTIONINIT	 _HTEXTBOX CTY COLDSEARCHEXP
 CSEARCHEXP	 FORMWIDTH SHOWFLDS PANEL PANELS TEXT GRIDFILL WIDTH	 GRDGETPOP COLUMNCOUNT VISIBLE SEARCHCAPFIND PPARAM1 PPARAM2 TLSTFLAG CCNT OBJPARAMETER _TEXTBOX TOP LEFT HEIGHT SHAPE1
 AUTOCENTER TEXT1 INTERACTIVECHANGE+ 5�  � ��� � ��$� T�  ��� �� %�C� �� C� �	��R � T�� �� � ��� � T� � � �� � �
�� %��� ���� �, T� � � ���� �� � �333333�?�� �� �, T� � � ���� �� � �)\���(�?�� � %�� �	 �6�� �% T� �	 �C� �
 �	 � �	 � �66�� � �� U  MCOLCNT THISFORM	 GRDGETPOP COLUMNCOUNT
 MXTRAFIELD MXTRACAPTION WIDTH PANEL PANELS HEIGHT TREEVIEW entr,     �� gridfillh     �� esce    �� columnbindevents�    �� assigncaption�    ��
 udfindchar�
    �� searchcapfind�
    �� captioninit�    ��
 setsplkeys�    �� totfieldprocb    �� fieldsizeproc�    �� hdrclick�    �� refreshrcrd�    �� setsearchparam�    ��
 createnode{    ��
 treesearch�    �� QueryUnload�    �� Unload�    �� Activate�    �� KeyPress    �� Init�    �� Resize�-    ��1 � 3 q � � Qq!2!Q�A�����!� � AR�� � � 1�A � � � � � � 1A � A AA � � � 3 � � 3 1q��A A A 3 !1Q� �q�QR1A A A �� 3 4 �Q� � Na!� �q�1A A A q�� A A A �� 3 � �!� � �QA� A 3 � q �	� 4 � 1A� 3 q 1�4 -� 1"� q�q�qQqA A � � � � A A 4 1� � A C�a� ���� �A � QA A �� � 3 � � � � � a� �� �A A � �� � !� A A A A� A 3 QQ � � A� �A A q Q 4 !��A A 4 � 3 � � Q C�q � q �qq�� � �A A 3 Q�A �Q� � � A 4 � � A� � � A 3 ���� � � � � � � � � �� A T �� �1� A � � � � !� A �1A ��� � � � a� �� �A A � �� � !� A A A � � a� 3�� 11A A Q��� �AA A A �� � qa� �� � �� � !A A � q� � � A A A � � qa� �� � �� � !A A � q� � � A A A � �� A�AA�� AA aaA A A �� 13 q � �QA �"�� �A RRA A 2                       6         U   �	     6   �	  
  A   :   6
  �  G   E     '  U   V   H  �  j   X   �  W  o   r   y  �  �      �  �  �   �   �  r  �   �   �  �  �   �   �  _!  �   �   �!  �'  �   �   �'  �*    �   +  �,  6  �   �,  '.  I  �   I.  o.  U  �   �.  1  Z    =1  �2  s    3  �3  �     �3  $L  �  �  AL  �N  X   )   =6                    %   �  ;  �  �   U  =d�J   ��; ��  � � � � � � � � �	 �
 � � � � �� � � � T� ��  �� T� �� NO�� T� �� 10.0.0.0�� ��� �# T� �C� GETPOP � CC�]��� �� �(� �� � T� �� NO�� �� %�C�
 _VerRetValb� L��m�# T� �� Version Error occured!��N T� �� C� �  Kindly update latest version of C� ProductTitle� � �� ��C� �@� �x�� B�-�� � %�� � NO���� B�-�� � �� �
 F��  ��S T� �CC� ��� L� � � �  6CC� �
�! CCC� ��R� ,� � ,� �  6� �  6�� T� �C�
 _adjgetpop�N��2 ��C �	  �
  � CC� ��� C� �  � � 6� � �� T� � ��9� � �� �� � %�C� � �
����? � frmsrch(� ��  � � � � � � � � � � � �	 B�� �� U  PFILENM PCAPTION PFIELD PRETURN PSEARCHV PSPLIT
 PXTRAFIELD PXTRACAPTION PSRCHANY PEXCLUDE PINCLUDE CAPCOL PEXCLCAP	 PTREEVIEW _VERVALIDERR
 _VERRETVAL _CURRVERVAL	 APPVERCHK CMSGSTR	 GLOBALOBJ GETPROPERTYVAL VUMESS OBJGPOP RUNME
 NBACKCOLOR
 ACTIVEFORM	 BACKCOLOR MVAL SHOWFLDS FRMSRCH�; ��  Q� STRING� Q� STRING� Q� STRING� Q� STRING� T� �� �� T� � �� �� � ����& %�C� pIncludeb� L� C� �
	��� � T� �C � � �� � �� ��& %�C� pExcludeb� L� C�  �
	��� � T� �C �  � �� � �� �� T� �C�  � �� � �� � � %�C� �
��v� �� ���(�� ������^� ��CC � � � �	 �� �� T� �
 �C� � �� �- T� � �CC� capcolb� L� C� �� �  6�� ��C� � �� ��C� � �� U  PEXCLUDE PINCLUDE CAPCOL PEXCLCAP MTOTFLDS THIS MFLDS	 GETFIELDS _IUD	 SETSTRING SHOWFLDS	 GETSTRING SETCAPARRAY SETSESHOWFLDSL ��  � � �. T� � �� <<CC� � �� ,� >><<�� >>�� %�C� � �
��� �7 T� � �C� � �CCC� � ��R� ,� �  � � ,6�� � T�  �C� ,� � ���@ T� � �C�  � �$ � <<CC� � �� ,� >><<�� >>� �  6�� �� ���(��  ������E�, T� �� <<C� � � <<� >>� ��� >>�� T� � �C� � � �  ��� �� U  LNEXCAP I LCEXCAP THIS
 SESHOWFLDS SHOWFLDS PEXCLCAP�. ��  Q� STRING� Q� STRING� Q� INTEGER� �� � � � � H�N ��� �C�  �
� � �	��R� T� ���� J�� �(� � � +�a��N� T� �� �� T� �C� ,�  � �� � �� �� %�� � ��� � T� �� ��C�  � �\�� � �( T� �� ��C�  � �� �� \�� � T� �� ��� %�� � ��J� !� � � �C�  �
� � �	��"� � ���� T� ���� T� �C�� ��� � �� �� �� ���(�� ������� %�CC � �� �  �� ��� � �� �� T� �� ��C � �� �� T� �� ��� � �� 2��� � ���� T� �C�� ��� � �� �� �� ���(�� �������� T� �� ��C � �� �� �� � B�C�� ��� U  PINCLUDE PMARR EXORIN MCTR MPOS MPREV MAFLDS MI^  ��  Q� STRING� %�C� � ���3 � T� � ��  �� �W � T� � �� � � ,�  �� � U  SSTR THIS STRFILEJ  5�  � %�C� � �
��C � T�  �� � �� T� � ��  ��	 B��  �� � U  RTNSTR THIS STRFILE�  5�  � � � � T� �� � ��1 T� �CC� ,� � �� � C� ,� � �� �6�� ��  ���(�� ������� � T� �C� �C� :� ��\��  T� �C� C� � �C� ,� �\�� T� �C� � �  ��� � � ��  �� T� � ��  ��� �� �� U  NFROMFLD X Y FLDNAME THIS CAPCOL TOTCAP CAPARRY Runme      SetseShowFldsm     	 getfields�     	 setstring�
     	 GetstringP      SetCaparray�     �  T�  ��  �� T� ��  �� T� ��  �� T� ��  �� T� ��  �� T� ��  �� � ����
 ��    �
 ��    �
 ��    �
 ��    �
 ��    �
 ��    � U  SHOWFLDS STRFILE CAPCOL PEXCLCAP
 SESHOWFLDS
 NBACKCOLOR CAPARRY
 _adjgetpop CUSTOMW    �0� � � Q� 1� � A �1�!q A 1q A r � 1�!Qq 1�B � 1 �� � a�� a�� �A A �QA AA �� � 3 � �2qA b���A 4 �1� �� � � a� �� �A A A A �� � !� ��� �A A � � !� ��A A � 2 !� �A 2 q 1� A 2 1��QaA 2 � � � � � � � � �� � �� � � <                 !   c  �  N   8   %  %  h   D   J  �  z   n   �  y  �   u   �    �   |   &  q  �   �   �  {  E   0   m                   PLATFORM   C                  UNIQUEID   C	   
               TIMESTAMP  N   
               CLASS      M                  CLASSLOC   M!                  BASECLASS  M%                  OBJNAME    M)                  PARENT     M-                  PROPERTIES M1                  PROTECTED  M5                  METHODS    M9                  OBJCODE    M=                 OLE        MA                  OLE2       ME                  RESERVED1  MI                  RESERVED2  MM                  RESERVED3  MQ                  RESERVED4  MU                  RESERVED5  MY                  RESERVED6  M]                  RESERVED7  Ma                  RESERVED8  Me                  USER       Mi                                                                                                                                                                                                                                                                                          COMMENT Class                                                                                               WINDOWS _1TS0MRO0E 890733780z      �  �      �        �          d  q              V               COMMENT RESERVED                        C                                                                 WINDOWS _1HA0Q83JV 910647765{      	  �      ~      �  �          d  q              V               WINDOWS _1HA0QKVWJ 891052122q      d  V  A  �                                                           WINDOWS _1HA0Q83JV 846760187�      �  �  �  �                                                           WINDOWS RESERVED   846760187�      �  �  �  �                                                           WINDOWS _1HA0Q83JV 846760187�      �  �  �                                                             WINDOWS _1HA0Q83JV 891052143�      �  �  �  �                                                           WINDOWS RESERVED   891052143�      �  �  �  �                                                           WINDOWS _1HA0Q83JV 891052143�      �  t  _  n                                                           WINDOWS _1HA0Q83JV 891052143_      P  C  .  =                                                           WINDOWS _1HA0QEXOY 891052143.          �                                                             WINDOWS _1HA0QEXPC 891052143�      �  �  �  �                                                           WINDOWS _1HA0Q83JV 891052143�      �  �  �  �                                                           WINDOWS RESERVED   891052143�      �  |  g  u                                                           WINDOWS _1HA0QEXQH 891052143f      W  J  5  C
                                                           WINDOWS _1HA0QEXQV 8910521434
      %
  
  
  	                                                           WINDOWS _1HA0Q83JV 846760187	      �  �  �  %                                                           WINDOWS _1HA0QEXRP 846760187        �  �  :                                                           WINDOWS _1HA0QEXS5 846760187-           �  O                                                           WINDOWS _1HA0Q83JV 846760187B      5  '    d                                                           WINDOWS RESERVED   846760187W      J  <  '  y                                                           WINDOWS _1HA0QEXTG 846760187l      _  Q  <  �                                                           WINDOWS _1HA0QEXTW 846760187�      t  e  P  �                                                           COMMENT RESERVED                        A                                                                  #�                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 VERSION =   3.00      !Arial, 1, 8, 5, 14, 11, 29, 3, 0
      _hxtratextbox      Pixels      Class      22      	container      _hxtratextbox      �AutoSize = .T.
FontBold = .T.
FontSize = 8
BackStyle = 0
Caption = "Label1"
Height = 16
Left = 16
Top = 234
Width = 38
ForeColor = 0,0,255
Name = "Label10"
      _hxtratextbox      Label10      label      label      �AutoSize = .T.
FontBold = .T.
FontSize = 8
BackStyle = 0
Caption = "Label1"
Height = 16
Left = 16
Top = 209
Width = 38
ForeColor = 0,0,255
Name = "Label9"
      _hxtratextbox      Label9      label      label      �AutoSize = .T.
FontBold = .T.
FontSize = 8
BackStyle = 0
Caption = "Label1"
Height = 16
Left = 16
Top = 189
Width = 38
ForeColor = 0,0,255
Name = "Label8"
      _hxtratextbox      Label8      label      label      �AutoSize = .T.
FontBold = .T.
FontSize = 8
BackStyle = 0
Caption = "Label1"
Height = 16
Left = 16
Top = 164
Width = 38
ForeColor = 0,0,255
Name = "Label7"
      _hxtratextbox      Label7      label      label      �AutoSize = .T.
FontBold = .T.
FontSize = 8
BackStyle = 0
Caption = "Label1"
Height = 16
Left = 16
Top = 138
Width = 38
ForeColor = 0,0,255
Name = "Label6"
      _hxtratextbox      Label6      label      label      �AutoSize = .T.
FontBold = .T.
FontSize = 8
BackStyle = 0
Caption = "Label1"
Height = 16
Left = 16
Top = 115
Width = 38
ForeColor = 0,0,255
Name = "Label5"
      _hxtratextbox      Label5      label      label      �AutoSize = .T.
FontBold = .T.
FontSize = 8
BackStyle = 0
Caption = "Label1"
Height = 16
Left = 16
Top = 90
Width = 38
ForeColor = 0,0,255
Name = "Label4"
      _hxtratextbox      Label4      label      label      �FontBold = .T.
FontSize = 8
Enabled = .F.
Height = 23
Left = 85
SpecialEffect = 2
Top = 227
Width = 149
DisabledBackColor = 255,255,223
DisabledForeColor = 255,128,64
BorderColor = 192,192,192
Themes = .F.
Name = "Text10"
      _hxtratextbox      Text10      textbox      textbox      �FontBold = .T.
FontSize = 8
Enabled = .F.
Height = 23
Left = 85
SpecialEffect = 2
Top = 203
Width = 149
DisabledBackColor = 255,255,223
DisabledForeColor = 255,128,64
BorderColor = 192,192,192
Themes = .F.
Name = "Text9"
      _hxtratextbox      Text9      textbox      textbox      �FontBold = .T.
FontSize = 8
Enabled = .F.
Height = 23
Left = 85
SpecialEffect = 2
Top = 179
Width = 149
DisabledBackColor = 255,255,223
DisabledForeColor = 255,128,64
BorderColor = 192,192,192
Themes = .F.
Name = "Text8"
      _hxtratextbox      Text8      textbox      textbox      �FontBold = .T.
FontSize = 8
Enabled = .F.
Height = 23
Left = 85
SpecialEffect = 2
Top = 155
Width = 149
DisabledBackColor = 255,255,223
DisabledForeColor = 255,128,64
BorderColor = 192,192,192
Themes = .F.
Name = "Text7"
      _hxtratextbox      Text7      textbox      textbox      �FontBold = .T.
FontSize = 8
Enabled = .F.
Height = 23
Left = 85
SpecialEffect = 2
Top = 131
Width = 149
DisabledBackColor = 255,255,223
DisabledForeColor = 255,128,64
BorderColor = 192,192,192
Themes = .F.
Name = "Text6"
      _hxtratextbox      Text6      textbox      textbox      �FontBold = .T.
FontSize = 8
Enabled = .F.
Height = 23
Left = 85
SpecialEffect = 2
Top = 107
Width = 149
DisabledBackColor = 255,255,223
DisabledForeColor = 255,128,64
BorderColor = 192,192,192
Themes = .F.
Name = "Text5"
      _hxtratextbox      Text5      textbox      textbox      �FontBold = .T.
FontSize = 8
Enabled = .F.
Height = 23
Left = 85
SpecialEffect = 2
Top = 83
Width = 149
DisabledBackColor = 255,255,223
DisabledForeColor = 255,128,64
BorderColor = 192,192,192
Themes = .F.
Name = "Text4"
      _hxtratextbox      Text4      textbox      textbox      �FontBold = .T.
FontSize = 8
Enabled = .F.
Height = 23
Left = 85
SpecialEffect = 2
Top = 59
Width = 149
DisabledBackColor = 255,255,223
DisabledForeColor = 255,128,64
BorderColor = 192,192,192
Themes = .F.
Name = "Text3"
      _hxtratextbox      Text3      textbox      textbox      �FontBold = .T.
FontSize = 8
Enabled = .F.
Height = 23
Left = 85
SpecialEffect = 2
Top = 35
Width = 149
DisabledBackColor = 255,255,223
DisabledForeColor = 255,128,64
BorderColor = 192,192,192
Themes = .F.
Name = "Text2"
      _hxtratextbox      Text2      textbox      textbox      �FontBold = .T.
FontSize = 8
Enabled = .F.
Height = 23
Left = 85
SpecialEffect = 2
Top = 11
Width = 149
DisabledBackColor = 255,255,223
DisabledForeColor = 255,128,64
BorderColor = 192,192,192
Themes = .F.
Name = "Text1"
      _hxtratextbox      Text1      textbox      textbox      �AutoSize = .T.
FontBold = .T.
FontSize = 8
BackStyle = 0
Caption = "Label1"
Height = 16
Left = 16
Top = 65
Width = 38
ForeColor = 0,0,255
Name = "Label3"
      _hxtratextbox      Label3      label      label      �AutoSize = .T.
FontBold = .T.
FontSize = 8
BackStyle = 0
Caption = "Label1"
Height = 16
Left = 16
Top = 39
Width = 38
ForeColor = 0,0,255
Name = "Label2"
      _hxtratextbox      Label2      label      label      �AutoSize = .T.
FontBold = .T.
FontSize = 8
BackStyle = 0
Caption = "Label1"
Height = 16
Left = 16
Top = 16
Width = 38
ForeColor = 0,0,255
Name = "Label1"
      _hxtratextbox      Label1      label      label      zTop = 4
Left = 4
Height = 268
Width = 249
BackStyle = 0
SpecialEffect = 0
BackColor = 240,240,240
Name = "Shape1"
      _hxtratextbox      Shape1      shape      shape      �Width = 258
Height = 277
BackStyle = 0
SpecialEffect = 0
BackColor = 240,240,240
BorderColor = 0,0,0
Name = "_hxtratextbox"
      	container      !Arial, 0, 8, 5, 14, 11, 29, 3, 0
      gridtextbox      Pixels      Class      1      textbox      gridtextbox     ���    �   �                         ��   %   j       �      �           �  U    R,�� reach double click�� U    R,��
 rightclick�� U   DblClick,     ��
 RightClickO     ��1 �2 A1                       4         U   m       )   �                         >FontSize = 8
Height = 23
Width = 100
Name = "gridtextbox"
      textbox      xPROCEDURE DblClick
WAIT WINDOW "reach double click"
ENDPROC
PROCEDURE RightClick
WAIT WINDOW "rightclick"
ENDPROC
     I���    0  0                        x�   %   �      �     �          �  U  yS ��  � � � � � � � � �	 �
 � � � � � � � � � � �� � � � � � � ��� ��r� �� ���(��
��n� T� �� pTextCC� Z��� T� �� pLabelCC� Z���, T� �� .TextCC� Z�� .visible = .f.��- T� �� .LabelCC� Z�� .visible = .f.��k IF (EMPTY(&pLabelVar) OR EMPTY(&pTextvar)) OR (TYPE('&pLabelvar') = 'L' OR TYPE('&pTextvar') = 'L')��� &pTextvisible
 &pLabelvisible
 �j�G pLabelCaption = ".Label"+ALLTRIM(STR(pCtr))+".Caption = &pLabelVar"
K pTextsource   = ".Text"+ALLTRIM(STR(pCtr))+".controlsource = &pTextVar"
 &pLabelCaption
 &pTextsource
 � �� �� U  PLABEL1 PLABEL2 PLABEL3 PLABEL4 PLABEL5 PLABEL6 PLABEL7 PLABEL8 PLABEL9 PLABEL10 PTEXT1 PTEXT2 PTEXT3 PTEXT4 PTEXT5 PTEXT6 PTEXT7 PTEXT8 PTEXT9 PTEXT10 PTEXTVAR	 PLABELVAR PTEXTVISIBLE PLABELVISIBLE PLABELCAPTION PTEXTSOURCE THIS PCTR Init,     ��1 1�� q�����!� q�!B A A 2                       �      )   0                       �PROCEDURE Init
LPARAMETER pLabel1,pLabel2,pLabel3,pLabel4,pLabel5,pLabel6,pLabel7,pLabel8,pLabel9,pLabel10,pText1,pText2,pText3,pText4,pText5,pText6,pText7,pText8,pText9,pText10

LOCAL pTextvar,pLabelVar,pTextvisible,pLabelvisible,pLabelCaption,pTextsource
WITH THIS
	FOR pCtr = 1 TO 10
		pTextvar      = "pText"+ALLTRIM(STR(pCtr))
		pLabelVar     = "pLabel"+ALLTRIM(STR(pCtr))
		pTextvisible  = ".Text"+ALLTRIM(STR(pCtr))+".visible = .f."
		pLabelvisible = ".Label"+ALLTRIM(STR(pCtr))+".visible = .f."
		IF (EMPTY(&pLabelVar) OR EMPTY(&pTextvar)) OR (TYPE('&pLabelvar') = 'L' OR TYPE('&pTextvar') = 'L')
			&pTextvisible
			&pLabelvisible
		ELSE
			pLabelCaption = ".Label"+ALLTRIM(STR(pCtr))+".Caption = &pLabelVar"
			pTextsource   = ".Text"+ALLTRIM(STR(pCtr))+".controlsource = &pTextVar"
			&pLabelCaption
			&pTextsource
*!*			  	pCheck = 'substr(&pLabelvar,1,+.left+&pLabelVar+.width = &pTextvar+.left'
		ENDIF
	ENDFOR
ENDWITH

ENDPROC
.\ frmsrch.scx frmsrch.sct main.prg c:\users\shrikant\appdata\local\temp\ main.fxp _htextbox.vcx _htextbox.vct 	)   �                 �  ��                  ��  � $   J           �      S            �6     a           