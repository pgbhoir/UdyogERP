���    .�  ��  �                     �I    %           �     �  Ms�L    � ��  � %�C� ��� O��� %�C� pos� � ���. %�C� _screen.ActiveForm.pcvTypeb� C��� %��9� � � PS��� �- %�� udClsPointOfSaleC� Classlibv
��� � G~(� udClsPointOfSale� �% %�� VouclassC� Classlibv
��� � G~(� Vouclass� � � � � � U  _NDATASESSION OGLBLPRDFEAT	 UDCHKPROD
 ACTIVEFORM PCVTYPE UDCLSPOINTOFSALE VOUCLASSq Rq����A Q!A A A A A 1                 0   m                   PLATFORM   C                  UNIQUEID   C	   
               TIMESTAMP  N   
               CLASS      M                  CLASSLOC   M!                  BASECLASS  M%                  OBJNAME    M)                  PARENT     M-                  PROPERTIES M1                  PROTECTED  M5                  METHODS    M9                  OBJCODE    M=                 OLE        MA                  OLE2       ME                  RESERVED1  MI                  RESERVED2  MM                  RESERVED3  MQ                  RESERVED4  MU                  RESERVED5  MY                  RESERVED6  M]                  RESERVED7  Ma                  RESERVED8  Me                  USER       Mi                                                                                                                                                                                                                                                                                          COMMENT Class                                                                                               WINDOWS _4LM0VQLPS1216436892      s  "      �      7   
          �                �               COMMENT RESERVED                        �      �                                                           WINDOWS _4LM0VNI4L1283815498T      �  b      z      �
  8          >  K  �          0               COMMENT RESERVED                                                                                            a                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 VERSION =   3.00      udclspointofsale      Pixels      Class      1      custom      udclspointofsale      Name = "udclspointofsale"
      custom      !Arial, 0, 8, 5, 14, 11, 29, 3, 0
      cmdpaymentdet      Pixels      Class      1      commandbutton      cmdpaymentdet      4PROCEDURE Click
DO FORM udFrmPointOfSale
ENDPROC
      commandbutton      C*_uetrigvourefresh 
*_uetrigvouitemnew 
*_uetrigvouaftactivate 
      ]Height = 27
Width = 110
FontSize = 8
Caption = "Payment Details"
Name = "cmdpaymentdet"
     ����    �  �                        �   %   �      ^  *   
          �  U  e %�C�  ��� O��^� %�C� pos�  � ��Z� %�� � � a��V�n T� ��a  select * from PSPayDetail a where a.entry_ty=?main_vw.Entry_ty and a.Tran_cd = ?main_vw.Tran_cd ��R T� �C� EXE�	 �
  � � PSPayDet_Vw� Thisform.nHandle� � � -� � � � �� ��� � ��R� T�� �-�� T�� �-�� T�� �-�� T�� �-�� T� � � �-�� �� � � � U  OGLBLPRDFEAT	 UDCHKPROD THIS PARENT GETCHILD SQL_STR SQL_CON	 SQLCONOBJ DATACONN COMPANY DBNAME DATASESSIONID	 ADDBUTTON
 EDITBUTTON DELETEBUTTON PRINTBUTTON
 TBRDESKTOP BTNVIEW ENABLED %�C�  ��� O��� %�C� pos�  � ��� ��� � ��� T� ��� � ��+ %�C� Thisform._cmdPaymentDetb� O��� �, ��C� _cmdPaymentDet� cmdPaymentDet�� �� � T�� �	 �a�� T�� �
 ��n�� T�� � �� �� T� ��� �
 �� �
 �� T�� � �� �� �� � � U  OGLBLPRDFEAT	 UDCHKPROD THIS PARENT _NTOP VOUPAGE TOP	 ADDOBJECT _CMDPAYMENTDET VISIBLE WIDTH _NLEFT LEFTb  ���  � ��Q � T�� �-�� T�� �-�� T�� �-�� T�� �-�� T� � � �-�� ��
 �� �	 � U
  THIS PARENT	 ADDBUTTON
 EDITBUTTON DELETEBUTTON PRINTBUTTON
 TBRDESKTOP BTNVIEW ENABLED REFRESH _uetrigvourefresh,     �� _uetrigvouitemnew]    �� _uetrigvouaftactivate�    ��1 QqQ�!� � � � A C A A 4 Qq��A � �A A A 3 � � � � A � 2                       �        �  �     !   �  R  +    )   �                        ����    �   �                         E�   %   ]       r      l           �  U    � udFrmPointOfSale� U  UDFRMPOINTOFSALE Click,     ��1 �1                       )       )   �                        ]PROCEDURE _uetrigvourefresh
If Vartype(oGlblPrdFeat)='O'
	If oGlblPrdFeat.UdChkProd('pos')
		If This.Parent.GetChild=.T.
			sql_str  = " select * from PSPayDetail a where a.entry_ty=?main_vw.Entry_ty and a.Tran_cd = ?main_vw.Tran_cd "
			sql_con = This.Parent.sqlconobj.dataconn([EXE],company.dbname,sql_str,[PSPayDet_Vw],"Thisform.nHandle",This.Parent.DataSessionId,.F.)
*!*				This.Parent.sqlconobj.SqlConclose("Thisform.nHandle")
*!*				This.Parent.Activate()
			With This.Parent
				.AddButton = .F.
				.EditButton = .F.
				.DeleteButton = .F.
				.PrintButton = .F.
				tbrDesktop.btnView.Enabled=.F.
			Endwith
*!*				tbrDesktop.Refresh

		Endif
	Endif
Endif


ENDPROC
PROCEDURE _uetrigvouitemnew
If Vartype(oGlblPrdFeat)='O'
	If oGlblPrdFeat.UdChkProd('pos')
		With This.Parent
			_nTop = .vouPage.Top
			
			If Type('Thisform._cmdPaymentDet')!='O'
				.AddObject("_cmdPaymentDet","cmdPaymentDet")
			Endif
			._cmdPaymentDet.Visible=.T.
			._cmdPaymentDet.Width = 110
			._cmdPaymentDet.Top = _nTop
			_nLeft = .vouPage.Width - ._cmdPaymentDet.Width
			._cmdPaymentDet.Left = _nLeft
		Endwith
	Endif
Endif

ENDPROC
PROCEDURE _uetrigvouaftactivate
With This.Parent
	.AddButton = .F.
	.EditButton = .F.
	.DeleteButton = .F.
	.PrintButton = .F.
	tbrDesktop.btnView.Enabled=.F.
Endwith
tbrDesktop.Refresh

ENDPROC
0D   m                   PLATFORM   C                  UNIQUEID   C	   
               TIMESTAMP  N   
               CLASS      M                  CLASSLOC   M!                  BASECLASS  M%                  OBJNAME    M)                  PARENT     M-                  PROPERTIES M1                  PROTECTED  M5                  METHODS    M9                  OBJCODE    M=                 OLE        MA                  OLE2       ME                  RESERVED1  MI                  RESERVED2  MM                  RESERVED3  MQ                  RESERVED4  MU                  RESERVED5  MY                  RESERVED6  M]                  RESERVED7  Ma                  RESERVED8  Me                  USER       Mi                                                                                                                                                                                                                                                                                          COMMENT Screen                                                                                              WINDOWS _4LM12PSLM1216254076      /  F      ]                          �      �                       WINDOWS _4LM12PSLN1221547501�      �  �             �  �I                                               WINDOWS _4LN0REQZB1216318914        ,  <  T                                                           WINDOWS _4LM13LA431216318914�      �  �    &                                                           WINDOWS _4LM13LA441216315515�      �  �  �  �                                                           WINDOWS _4LM12PSLM1216318466"      .  :  I  a                                                           WINDOWS _4LN0NKVTB1216315515�      �  �  �  �                                                           WINDOWS _4LN0NKVTC1216318466"      1  @  M  u                                                           WINDOWS _4LN0NKVTD1216315515�            F                                                           WINDOWS _4LN0NKVTE1216318466�      �  �  �  �                                                           WINDOWS _4LN0NKVTF1216315515`       n   |   �   �                                                            WINDOWS _4LN0NKVTG1216318466�       !  !  )!  Q!                                                           WINDOWS _4LM12PSLN1216318466�!      �!  �!  �!  "                                                           WINDOWS _4LN0NKVTH1216315515H%      V%  d%  s%  �%                                                           WINDOWS _4LN0NKVTI1216318466�%      �%  &  &  >&                                                           WINDOWS _4LN0NKVTJ1216315515�&      �&  �&  �&  '                                                           WINDOWS _4LN0NKVTK1216318466a'      p'  '  �'  �'                                                           WINDOWS _4LN0NKVTL12163155154(      B(  P(  _(  �(                                                           WINDOWS _4LN0NKVTM1216318466�(      �(  �(  )  -)                                                           WINDOWS _4LN0NKVTN1216315515�)      �)  �)  �)   *                                                           WINDOWS _4LN0NKVTO1216318466Q*      `*  o*  |*  �*                                                           WINDOWS _4LN0NKVTP1216315515$+      2+  @+  O+  y+                                                           WINDOWS _4LN0NKVTQ1216318466�+      �+  �+  �+  ,                                                           WINDOWS _4LN0NKVTR1216315515�,      �,  �,  �,  �,                                                           WINDOWS _4LN0NKVTS1216318466;-      J-  Y-  f-  �-                                                           WINDOWS _4LM13LA461216318466.      .  &.  5.  M.                                                           WINDOWS _4LN0NKVTT1216315515y1      �1  �1  �1  �1                                                           WINDOWS _4LN0NKVTU1216318466	2      2  '2  42  \2                                                           WINDOWS _4LN0NKVTV1216315515�2      �2  �2  3  -3                                                           WINDOWS _4LN0NKVTW1216318466�3      �3  �3  �3  �3                                                           WINDOWS _4LN0NKVTX1216315515Q4      _4  m4  |4  �4                                                           WINDOWS _4LN0NKVTY1216318466�4       5  5  5  D5                                                           WINDOWS _4LN0NKVTZ1216315515�5      �5  �5  �5  6                                                           WINDOWS _4LN0NKVU01216318466c6      r6  �6  �6  �6                                                           WINDOWS _4LN0NKVU1121631551547      B7  P7  _7  �7                                                           WINDOWS _4LN0NKVU21216318466�7      �7  �7  8  )8                                                           WINDOWS _4LN0NKVU31216315515�8      �8  �8  �8  �8                                                           WINDOWS _4LN0NKVU41216318466E9      T9  c9  p9  �9                                                           WINDOWS _4LM13LA471216318466:      ":  .:  ?:  W:                                                           WINDOWS _4LN0NKVU51216315515)=      7=  E=  T=  ~=                                                           WINDOWS _4LN0NKVU61216318466�=      �=  �=  �=  >                                                           WINDOWS _4LN0NKVU71216315515�>      �>  �>  �>  �>                                                           WINDOWS _4LN0NKVU812163184661?      @?  O?  \?  �?                                                           WINDOWS _4LN0NKVU91216315515@      @   @  /@  Y@                                                           WINDOWS _4LN0NKVUA1216318466�@      �@  �@  �@  �@                                                           WINDOWS _4LN0NKVUB1216315515{A      �A  �A  �A  �A                                                           WINDOWS _4LN0NKVUC1216318466B      .B  =B  JB  tB                                                           WINDOWS _4LN0NKVUD1216315515�B       C  C  C  GC                                                           WINDOWS _4LN0NKVUE1216318466�C      �C  �C  �C  �C                                                           WINDOWS _4LM12PSLM1216315515eD      rD  D  �D  �D                                                           WINDOWS _4LM12PSLM1216315515lE      yE  �E  �E  �E                                                           WINDOWS _4LM12PSLM1216315515{F      �F  �F  �F  �F                                                           WINDOWS _4LN0NKVUF1216315515�G      �G  �G  �G  �G                                                           WINDOWS _4LN0REQZK1216318914�H      �H  �H  �H  �H                                                           WINDOWS _4LM12PSLM1216315515�I      �I  �I  �  �                                                           WINDOWS _4LM12PSLM1216315515�      �  �  n  $                                                           WINDOWS _4LM12PSLM1216315515      
  �  �  �                                                           WINDOWS _4LM12PSLM1216315515�      }  m  U  
                                                           WINDOWS _4LN0REQZL1216318914�      �  �  �  }                                                           WINDOWS _4LM12PSLM1216315515p      c  Q  9  �                                                           WINDOWS _4LM12PSLM1216315515w      j  V  >  �                                                           WINDOWS _4LM12PSLM1216315515y      l  Z  B  �                                                           WINDOWS _4LM12PSLM1216318914      r  a  I  �                                                           WINDOWS _4LN0REQZM1216318914�      z  i  Q  �                                                           WINDOWS _4LN122U521216318914�      �  q  Y  �                                                           WINDOWS _4LN122U531216318977�      �  �  �  2      �  �                                               COMMENT RESERVED                                �                                                            T                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 VERSION =   3.00      dataenvironment      dataenvironment      Dataenvironment      YTop = 0
Left = 0
Width = 0
Height = 0
DataSource = .NULL.
Name = "Dataenvironment"
      1      1      form      form      udFrmPointOfSale      �Height = 510
Width = 817
ShowWindow = 1
DoCreate = .T.
AutoCenter = .T.
BorderStyle = 2
Caption = "Payment Details"
MaxButton = .F.
MinButton = .F.
WindowType = 1
Name = "udFrmPointOfSale"
     PROCEDURE Init

Thisform.grdCash.RecordSource=""
Thisform.grdcoupon.RecordSource=""
Thisform.grdCard.RecordSource=""
Thisform.grdCheque.RecordSource=""

Select Recno() As SrNo,'CASH' As CashDet, TotalValue From PSPayDet_Vw Where PayMode='CASH' Into Cursor _curCashDet
Select Recno() As SrNo,CouponNm,CouponNo,CouponVal,CouponQty,TotalValue From PSPayDet_Vw Where PayMode='COUPON' Into Cursor _curCoupDet
Select Recno() As SrNo,CardNm,CardNo,CardType,IsDebitCard,CardAmt As TotalValue From PSPayDet_Vw Where PayMode='CARD' Into Cursor _curCardDet
Select Recno() As SrNo,BankNm,ChequeNo,ChequeDt,ChequeAmt As TotalValue From PSPayDet_Vw Where PayMode='CHEQUE' Into Cursor _curCheqDet

With Thisform.grdCash
	.RecordSource="_curCashDet"
	.Column1.ControlSource = "_curCashDet.SrNo"
	.Column2.ControlSource = "_curCashDet.CashDet"
	.Column3.ControlSource = "_curCashDet.TotalValue"
Endwith
With Thisform.grdcoupon
	.RecordSource="_curCoupDet"
	.Column1.ControlSource = "_curCoupDet.SrNo"
	.Column2.ControlSource = "_curCoupDet.CouponNm"
	.Column3.ControlSource = "_curCoupDet.CouponNo"
	.Column4.ControlSource = "_curCoupDet.CouponVal"
	.Column5.ControlSource = "_curCoupDet.CouponQty"
	.Column6.ControlSource = "_curCoupDet.TotalValue"
Endwith
With Thisform.grdCard
	.RecordSource="_curCardDet"
	.Column1.ControlSource = "_curCardDet.SrNo"
	.Column2.ControlSource = "_curCardDet.CardNm"
	.Column3.ControlSource = "_curCardDet.CardNo"
	.Column4.ControlSource = "_curCardDet.CardType"
	.Column5.ControlSource = "_curCardDet.IsDebitCard"
	.Column6.ControlSource = "_curCardDet.TotalValue"
Endwith
With Thisform.grdCheque
	.RecordSource="_curCheqDet"
	.Column1.ControlSource = "_curCheqDet.SrNo"
	.Column2.ControlSource = "_curCheqDet.BankNm"
	.Column3.ControlSource = "_curCheqDet.ChequeNo"
	.Column4.ControlSource = "_curCheqDet.ChequeDt"
	.Column5.ControlSource = "_curCheqDet.TotalValue"
Endwith

Thisform.Icon = icopath

ENDPROC
PROCEDURE Refresh
Select Sum(TotalValue) As TotalValue From _curCashDet Into Cursor _curTemp
nTotAmt = _curTemp.TotalValue
Thisform.lblcashAmt.Caption = Transform(_curTemp.TotalValue)
Select Sum(TotalValue) As TotalValue From PSPayDet_Vw Where PayMode='COUPON' Into Cursor _curTemp
nTotAmt = nTotAmt+_curTemp.TotalValue
Thisform.lblcouponAmt.Caption = Transform(_curTemp.TotalValue)
Select Sum(TotalValue) As TotalValue From PSPayDet_Vw Where PayMode='CARD' Into Cursor _curTemp
nTotAmt = nTotAmt+_curTemp.TotalValue
Thisform.lblCardAmt.Caption = Transform(_curTemp.TotalValue)
Select Sum(TotalValue) As TotalValue From PSPayDet_Vw Where PayMode='CHEQUE' Into Cursor _curTemp
nTotAmt = nTotAmt+_curTemp.TotalValue
Thisform.lblChqAmt.Caption = Transform(_curTemp.TotalValue)
Thisform.lbltotAmt.Caption = Transform(nTotAmt)

ENDPROC
      ����    �   �                         �   %   S       h      b           �  U    ��C�  � �� U  THISFORM RELEASE Click,     ��1 � 2                       %       )   �                         BArial, 0, 9, 5, 15, 12, 32, 3, 0
Arial, 0, 8, 5, 14, 11, 29, 3, 0
      0PROCEDURE Click
Thisform.Release()

ENDPROC
      aTop = 480
Left = 553
Height = 27
Width = 84
FontSize = 8
Caption = "Close"
Name = "cmdOk"
      udFrmPointOfSale      cmdOk      commandbutton      commandbutton      gTop = 478
Left = 2
Height = 32
Width = 657
BackStyle = 0
SpecialEffect = 0
Name = "shpHoriBott"
      udFrmPointOfSale      shpHoriBott      shape      shape      �FontBold = .T.
FontSize = 12
Alignment = 2
BackStyle = 0
Caption = "Label2"
Height = 19
Left = 664
Top = 483
Width = 145
ForeColor = 0,255,0
Name = "lblTotAmt"
      udFrmPointOfSale      	lblTotAmt      label      label      �FontBold = .T.
FontSize = 12
Alignment = 2
BackStyle = 0
Caption = "Label2"
Height = 17
Left = 664
Top = 408
Width = 145
ForeColor = 0,128,128
Name = "lblChqAmt"
      udFrmPointOfSale      	lblChqAmt      label      label      �FontBold = .T.
FontSize = 12
Alignment = 2
BackStyle = 0
Caption = "Label2"
Height = 17
Left = 664
Top = 282
Width = 145
ForeColor = 0,128,128
Name = "lblCardAmt"
      udFrmPointOfSale      
lblCardAmt      label      label      �FontBold = .T.
FontSize = 12
Alignment = 2
BackStyle = 0
Caption = "Label2"
Height = 17
Left = 664
Top = 151
Width = 145
ForeColor = 0,128,128
Name = "lblCouponAmt"
      udFrmPointOfSale      lblCouponAmt      label      label      �FontBold = .T.
FontSize = 12
Alignment = 2
BackStyle = 0
Caption = "Label2"
Height = 17
Left = 664
Top = 46
Width = 145
ForeColor = 0,128,128
Name = "lblCashAmt"
      udFrmPointOfSale      
lblCashAmt      label      label      CTop = 476
Left = 673
Height = 1
Width = 133
Name = "shpHori5"
      udFrmPointOfSale      shpHori5      shape      shape      CTop = 356
Left = 673
Height = 1
Width = 133
Name = "shpHori4"
      udFrmPointOfSale      shpHori4      shape      shape      CTop = 224
Left = 673
Height = 1
Width = 133
Name = "shpHori3"
      udFrmPointOfSale      shpHori3      shape      shape      BTop = 92
Left = 673
Height = 1
Width = 133
Name = "shphori2"
      udFrmPointOfSale      shphori2      shape      shape      BTop = 24
Left = 673
Height = 1
Width = 133
Name = "shphori1"
      udFrmPointOfSale      shape      shape      shpVerti      udFrmPointOfSale      �Top = 3
Left = 659
Height = 505
Width = 156
BorderWidth = 3
BackColor = 192,192,192
BorderColor = 128,128,128
Name = "shpVerti"
      shape      shape      shpOuter      udFrmPointOfSale      cTop = 2
Left = 2
Height = 476
Width = 814
BackStyle = 0
SpecialEffect = 0
Name = "shpOuter"
      shape      shape      shpVertical      udFrmPointOfSale      DTop = 2
Left = 659
Height = 475
Width = 1
Name = "shpVertical"
      grid      grid      grdCash      udFrmPointOfSale     ColumnCount = 3
FontSize = 8
AllowHeaderSizing = .F.
AllowRowSizing = .F.
DeleteMark = .F.
Enabled = .F.
Height = 54
Left = 7
Panel = 1
RowHeight = 17
ScrollBars = 2
SplitBar = .F.
Top = 27
Width = 647
GridLineColor = 212,212,212
Name = "grdCash"
Column1.FontSize = 8
Column1.Enabled = .F.
Column1.Width = 40
Column1.Name = "Column1"
Column2.FontSize = 8
Column2.Enabled = .F.
Column2.Width = 300
Column2.Name = "Column2"
Column3.FontSize = 8
Column3.Enabled = .F.
Column3.Width = 150
Column3.Name = "Column3"
      header      header      Header1       udFrmPointOfSale.grdCash.Column1      DFontSize = 8
Alignment = 2
Caption = "Sr. No."
Name = "Header1"
      textbox      textbox      Text1       udFrmPointOfSale.grdCash.Column1      vFontSize = 8
BorderStyle = 0
Enabled = .F.
Margin = 0
ForeColor = 0,0,0
BackColor = 255,255,255
Name = "Text1"
      header      header      Header1       udFrmPointOfSale.grdCash.Column2      AFontSize = 8
Alignment = 2
Caption = "Cash"
Name = "Header1"
      textbox      textbox      Text1       udFrmPointOfSale.grdCash.Column2      vFontSize = 8
BorderStyle = 0
Enabled = .F.
Margin = 0
ForeColor = 0,0,0
BackColor = 255,255,255
Name = "Text1"
      header      header      Header1       udFrmPointOfSale.grdCash.Column3      CFontSize = 8
Alignment = 2
Caption = "Amount"
Name = "Header1"
      textbox      textbox      Text1       udFrmPointOfSale.grdCash.Column3      vFontSize = 8
BorderStyle = 0
Enabled = .F.
Margin = 0
ForeColor = 0,0,0
BackColor = 255,255,255
Name = "Text1"
      grid      grid      	grdCoupon      udFrmPointOfSale     0ColumnCount = 6
FontSize = 8
AllowHeaderSizing = .F.
AllowRowSizing = .F.
DeleteMark = .F.
Enabled = .F.
Height = 106
Left = 7
Panel = 1
RowHeight = 17
ScrollBars = 2
SplitBar = .F.
Top = 106
Width = 647
GridLineColor = 212,212,212
Name = "grdCoupon"
Column1.FontSize = 8
Column1.Enabled = .F.
Column1.Width = 40
Column1.Name = "Column1"
Column2.FontSize = 8
Column2.Enabled = .F.
Column2.Width = 150
Column2.Name = "Column2"
Column3.FontSize = 8
Column3.Enabled = .F.
Column3.Width = 115
Column3.Name = "Column3"
Column4.FontSize = 8
Column4.Enabled = .F.
Column4.Width = 80
Column4.Name = "Column4"
Column5.FontSize = 8
Column5.Enabled = .F.
Column5.Width = 75
Column5.Name = "Column5"
Column6.FontSize = 8
Column6.Enabled = .F.
Column6.Width = 150
Column6.Name = "Column6"
      header      header      Header1      "udFrmPointOfSale.grdCoupon.Column1      DFontSize = 8
Alignment = 2
Caption = "Sr. No."
Name = "Header1"
      textbox      textbox      Text1      "udFrmPointOfSale.grdCoupon.Column1      vFontSize = 8
BorderStyle = 0
Enabled = .F.
Margin = 0
ForeColor = 0,0,0
BackColor = 255,255,255
Name = "Text1"
      header      header      Header1      "udFrmPointOfSale.grdCoupon.Column2      HFontSize = 8
Alignment = 2
Caption = "Coupon Name"
Name = "Header1"
      textbox      textbox      Text1      "udFrmPointOfSale.grdCoupon.Column2      vFontSize = 8
BorderStyle = 0
Enabled = .F.
Margin = 0
ForeColor = 0,0,0
BackColor = 255,255,255
Name = "Text1"
      header      header      Header1      "udFrmPointOfSale.grdCoupon.Column3      GFontSize = 8
Alignment = 2
Caption = "Coupon No."
Name = "Header1"
      textbox      textbox      Text1      "udFrmPointOfSale.grdCoupon.Column3      vFontSize = 8
BorderStyle = 0
Enabled = .F.
Margin = 0
ForeColor = 0,0,0
BackColor = 255,255,255
Name = "Text1"
      header      header      Header1      "udFrmPointOfSale.grdCoupon.Column4      IFontSize = 8
Alignment = 2
Caption = "Coupon Value"
Name = "Header1"
      textbox      textbox      Text1      "udFrmPointOfSale.grdCoupon.Column4      vFontSize = 8
BorderStyle = 0
Enabled = .F.
Margin = 0
ForeColor = 0,0,0
BackColor = 255,255,255
Name = "Text1"
      header      header      Header1      "udFrmPointOfSale.grdCoupon.Column5      GFontSize = 8
Alignment = 2
Caption = "Coupon Qty"
Name = "Header1"
      textbox      textbox      Text1      "udFrmPointOfSale.grdCoupon.Column5      vFontSize = 8
BorderStyle = 0
Enabled = .F.
Margin = 0
ForeColor = 0,0,0
BackColor = 255,255,255
Name = "Text1"
      header      header      Header1      "udFrmPointOfSale.grdCoupon.Column6      CFontSize = 8
Alignment = 2
Caption = "Amount"
Name = "Header1"
      textbox      textbox      Text1      "udFrmPointOfSale.grdCoupon.Column6      vFontSize = 8
BorderStyle = 0
Enabled = .F.
Margin = 0
ForeColor = 0,0,0
BackColor = 255,255,255
Name = "Text1"
      grid      grid      grdCard      udFrmPointOfSale     $ColumnCount = 6
FontSize = 8
AllowHeaderSizing = .F.
AllowRowSizing = .F.
DeleteMark = .F.
Enabled = .F.
Height = 106
Left = 7
RowHeight = 17
ScrollBars = 2
SplitBar = .F.
Top = 237
Width = 647
GridLineColor = 212,212,212
Name = "grdCard"
Column1.FontSize = 8
Column1.Enabled = .F.
Column1.Width = 40
Column1.Name = "Column1"
Column2.FontSize = 8
Column2.Enabled = .F.
Column2.Width = 150
Column2.Name = "Column2"
Column3.FontSize = 8
Column3.Enabled = .F.
Column3.Width = 120
Column3.Name = "Column3"
Column4.FontSize = 8
Column4.Enabled = .F.
Column4.Width = 100
Column4.Name = "Column4"
Column5.FontSize = 8
Column5.Enabled = .F.
Column5.Width = 50
Column5.Name = "Column5"
Column6.FontSize = 8
Column6.Enabled = .F.
Column6.Width = 150
Column6.Name = "Column6"
      header      header      Header1       udFrmPointOfSale.grdCard.Column1      5FontSize = 8
Caption = "Sr. No."
Name = "Header1"
      textbox      textbox      Text1       udFrmPointOfSale.grdCard.Column1      vFontSize = 8
BorderStyle = 0
Enabled = .F.
Margin = 0
ForeColor = 0,0,0
BackColor = 255,255,255
Name = "Text1"
      header      header      Header1       udFrmPointOfSale.grdCard.Column2      KFontSize = 8
Alignment = 2
Caption = "Card/Bank Name"
Name = "Header1"
      textbox      textbox      Text1       udFrmPointOfSale.grdCard.Column2      vFontSize = 8
BorderStyle = 0
Enabled = .F.
Margin = 0
ForeColor = 0,0,0
BackColor = 255,255,255
Name = "Text1"
      header      header      Header1       udFrmPointOfSale.grdCard.Column3      EFontSize = 8
Alignment = 2
Caption = "Card No."
Name = "Header1"
      textbox      textbox      Text1       udFrmPointOfSale.grdCard.Column3      vFontSize = 8
BorderStyle = 0
Enabled = .F.
Margin = 0
ForeColor = 0,0,0
BackColor = 255,255,255
Name = "Text1"
      header      header      Header1       udFrmPointOfSale.grdCard.Column4      FFontSize = 8
Alignment = 2
Caption = "Card Type"
Name = "Header1"
      textbox      textbox      Text1       udFrmPointOfSale.grdCard.Column4      vFontSize = 8
BorderStyle = 0
Enabled = .F.
Margin = 0
ForeColor = 0,0,0
BackColor = 255,255,255
Name = "Text1"
      header      header      Header1       udFrmPointOfSale.grdCard.Column5      GFontSize = 8
Alignment = 2
Caption = "Debit Card"
Name = "Header1"
      textbox      textbox      Text1       udFrmPointOfSale.grdCard.Column5      vFontSize = 8
BorderStyle = 0
Enabled = .F.
Margin = 0
ForeColor = 0,0,0
BackColor = 255,255,255
Name = "Text1"
      header      header      Header1       udFrmPointOfSale.grdCard.Column6      CFontSize = 8
Alignment = 2
Caption = "Amount"
Name = "Header1"
      textbox      textbox      Text1       udFrmPointOfSale.grdCard.Column6      vFontSize = 8
BorderStyle = 0
Enabled = .F.
Margin = 0
ForeColor = 0,0,0
BackColor = 255,255,255
Name = "Text1"
      grid      grid      	grdCheque      udFrmPointOfSale     �ColumnCount = 5
FontSize = 8
AllowHeaderSizing = .F.
AllowRowSizing = .F.
DeleteMark = .F.
Enabled = .F.
Height = 106
Left = 7
RowHeight = 17
ScrollBars = 2
SplitBar = .F.
Top = 368
Width = 647
GridLineColor = 212,212,212
Name = "grdCheque"
Column1.FontSize = 8
Column1.Enabled = .F.
Column1.Width = 40
Column1.Name = "Column1"
Column2.FontSize = 8
Column2.Enabled = .F.
Column2.Width = 210
Column2.Name = "Column2"
Column3.FontSize = 8
Column3.Enabled = .F.
Column3.Width = 120
Column3.Name = "Column3"
Column4.FontSize = 8
Column4.Enabled = .F.
Column4.Width = 90
Column4.Name = "Column4"
Column5.FontSize = 8
Column5.Enabled = .F.
Column5.Width = 150
Column5.Name = "Column5"
      header      header      Header1      "udFrmPointOfSale.grdCheque.Column1      5FontSize = 8
Caption = "Sr. No."
Name = "Header1"
      textbox      textbox      Text1      "udFrmPointOfSale.grdCheque.Column1      vFontSize = 8
BorderStyle = 0
Enabled = .F.
Margin = 0
ForeColor = 0,0,0
BackColor = 255,255,255
Name = "Text1"
      header      header      Header1      "udFrmPointOfSale.grdCheque.Column2      FFontSize = 8
Alignment = 2
Caption = "Bank Name"
Name = "Header1"
      textbox      textbox      Text1      "udFrmPointOfSale.grdCheque.Column2      vFontSize = 8
BorderStyle = 0
Enabled = .F.
Margin = 0
ForeColor = 0,0,0
BackColor = 255,255,255
Name = "Text1"
      header      header      Header1      "udFrmPointOfSale.grdCheque.Column3      GFontSize = 8
Alignment = 2
Caption = "Cheque No."
Name = "Header1"
      textbox      textbox      Text1      "udFrmPointOfSale.grdCheque.Column3      vFontSize = 8
BorderStyle = 0
Enabled = .F.
Margin = 0
ForeColor = 0,0,0
BackColor = 255,255,255
Name = "Text1"
      header      header      Header1      "udFrmPointOfSale.grdCheque.Column4      GFontSize = 8
Alignment = 2
Caption = "Cheque Dt."
Name = "Header1"
      textbox      textbox      Text1      "udFrmPointOfSale.grdCheque.Column4      vFontSize = 8
BorderStyle = 0
Enabled = .F.
Margin = 0
ForeColor = 0,0,0
BackColor = 255,255,255
Name = "Text1"
      header      header      Header1      "udFrmPointOfSale.grdCheque.Column5      CFontSize = 8
Alignment = 2
Caption = "Amount"
Name = "Header1"
      textbox      textbox      Text1      "udFrmPointOfSale.grdCheque.Column5      vFontSize = 8
BorderStyle = 0
Enabled = .F.
Margin = 0
ForeColor = 0,0,0
BackColor = 255,255,255
Name = "Text1"
      label      label      lblCash      udFrmPointOfSale      �AutoSize = .T.
FontBold = .T.
FontItalic = .T.
FontSize = 12
BackStyle = 0
Caption = "Cash Details"
Height = 21
Left = 19
Top = 8
Width = 98
ForeColor = 0,0,255
Name = "lblCash"
      label      label      	lblCoupon      udFrmPointOfSale      �AutoSize = .T.
FontBold = .T.
FontItalic = .T.
FontSize = 12
BackStyle = 0
Caption = "Coupon Details"
Height = 21
Left = 12
Top = 84
Width = 119
ForeColor = 0,0,255
Name = "lblCoupon"
      label      label      lblCard      udFrmPointOfSale      �AutoSize = .T.
FontBold = .T.
FontItalic = .T.
FontSize = 12
BackStyle = 0
Caption = "Credit/Debit Card Details"
Height = 21
Left = 12
Top = 216
Width = 187
ForeColor = 0,0,255
Name = "lblCard"
      label      label      	lblCheque      udFrmPointOfSale      �AutoSize = .T.
FontBold = .T.
FontItalic = .T.
FontSize = 12
BackStyle = 0
Caption = "Cheque Details"
Height = 21
Left = 12
Top = 348
Width = 117
ForeColor = 0,0,255
Name = "lblCheque"
      label      label      lblTotalAmt      udFrmPointOfSale      �AutoSize = .T.
FontBold = .T.
FontItalic = .T.
FontSize = 12
BackStyle = 0
Caption = "Total Amount"
Height = 21
Left = 684
Top = 5
Width = 105
ForeColor = 0,0,255
Name = "lblTotalAmt"
      shape      shape      shphori1     
.���    
  
                        U   %   +	      �	  9   J	          �  U  E T�  � � ��  �� T�  � � ��  �� T�  � � ��  �� T�  � � ��  ��M o� PSPayDet_Vw�CO�Q� �� CASH�Q� �� ����
 � CASH���� _curCashDet�Y o� PSPayDet_Vw�CO�Q� �� ��� ��� ��� ��� ����
 � COUPON���� _curCoupDet�[ o� PSPayDet_Vw�CO�Q� �� ��� ��� ��� ��� �Q� ���
 � CARD���� _curCardDet�W o� PSPayDet_Vw�CO�Q� �� ��� ��� ��� �Q� ���
 � CHEQUE���� _curCheqDet� ���  � ��9� T�� �� _curCashDet��! T�� � �� _curCashDet.SrNo��$ T�� � �� _curCashDet.CashDet��' T�� � �� _curCashDet.TotalValue�� �� ���  � ��D� T�� �� _curCoupDet��! T�� � �� _curCoupDet.SrNo��% T�� � �� _curCoupDet.CouponNm��% T�� � �� _curCoupDet.CouponNo��& T��  � �� _curCoupDet.CouponVal��& T��! � �� _curCoupDet.CouponQty��' T��" � �� _curCoupDet.TotalValue�� �� ���  � ��L� T�� �� _curCardDet��! T�� � �� _curCardDet.SrNo��# T�� � �� _curCardDet.CardNm��# T�� � �� _curCardDet.CardNo��% T��  � �� _curCardDet.CardType��( T��! � �� _curCardDet.IsDebitCard��' T��" � �� _curCardDet.TotalValue�� �� ���  � ��.� T�� �� _curCheqDet��! T�� � �� _curCheqDet.SrNo��# T�� � �� _curCheqDet.BankNm��% T�� � �� _curCheqDet.ChequeNo��% T��  � �� _curCheqDet.ChequeDt��' T��! � �� _curCheqDet.TotalValue�� �� T�  �# ��$ �� U%  THISFORM GRDCASH RECORDSOURCE	 GRDCOUPON GRDCARD	 GRDCHEQUE SRNO CASHDET
 TOTALVALUE PSPAYDET_VW PAYMODE _CURCASHDET COUPONNM COUPONNO	 COUPONVAL	 COUPONQTY _CURCOUPDET CARDNM CARDNO CARDTYPE ISDEBITCARD CARDAMT _CURCARDDET BANKNM CHEQUENO CHEQUEDT	 CHEQUEAMT _CURCHEQDET COLUMN1 CONTROLSOURCE COLUMN2 COLUMN3 COLUMN4 COLUMN5 COLUMN6 ICON ICOPATH�, o� _curCashDet�C� ���Q� ��� _curTemp� T� �� � �� T� � � �C� � _��< o� PSPayDet_Vw�C� ���Q� ���	 � COUPON���� _curTemp� T� �� � � �� T� �
 � �C� � _��: o� PSPayDet_Vw�C� ���Q� ���	 � CARD���� _curTemp� T� �� � � �� T� � � �C� � _��< o� PSPayDet_Vw�C� ���Q� ���	 � CHEQUE���� _curTemp� T� �� � � �� T� � � �C� � _�� T� � � �C� _�� U  SUM
 TOTALVALUE _CURCASHDET _CURTEMP NTOTAMT THISFORM
 LBLCASHAMT CAPTION PSPAYDET_VW PAYMODE LBLCOUPONAMT
 LBLCARDAMT	 LBLCHQAMT	 LBLTOTAMT Init,     �� Refresh�    ��1 2111���q�AqA �QQaaqA �11Q�qA �1QQqA 3 ���A��A��A�Q2                       �     +   �  �
  1    )   
                  udvoupointofsale.prg c:\users\adaequ~1\appdata\local\temp\ udvoupointofsale.fxp .\ udclspointofsale.vcx udclspointofsale.vct udfrmpointofsale.scx udfrmpointofsale.sct  )   �     ;           �    P   S             w  P   h           	w  t9  P   }           t9  ��  P   �           