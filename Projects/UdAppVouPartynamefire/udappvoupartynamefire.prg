If Type('_screen.ActiveForm.txtpartyname')=='O' And Type('_screen.ActiveForm.currentpartyname')<>'U' && Birendra : Bug-21315 on 10/01/2014 :Added condition:

	mAlias = Alias()

&& Added by Shrikant S. on 21/06/2012 for Bug-4744		&& Start
	If Vartype(oGlblPrdFeat)='O'
		If oGlblPrdFeat.UdChkProd('openord')
			If Type('lcode_vw.allowzeroqty')!='U'
				If lcode_Vw.allowzeroqty=.T.
					If Inlist(Main_Vw.Entry_ty,'OO')
						With _Screen.ActiveForm
							tot_grd_col=.voupage.page1.grditem.ColumnCount
							For i = 1 To tot_grd_col
								Do Case
									Case .voupage.page1.grditem.Columns(i).header1.Caption='Quantity'
										.voupage.page1.grditem.Columns(i).Visible=.F.
										.voupage.page1.grditem.Columns(i).ReadOnly=.T.
								Endcase
							Endfor
						Endwith
					Endif
				Endif
			Endif
		Endif
	Endif
&& Added by Shrikant S. on 21/06/2012 for Bug-4744		&& End

*------------------------------------------FOR DEBIT NOTE --------------------------------------------------
	If Used('main_vw') And (_Screen.ActiveForm.addmode Or _Screen.ActiveForm.editmode) && Birendra : Bug-21315 on 10/01/2014 :Added condition:
		If Inlist(Main_Vw.Entry_ty,'ST','PT')
*IF INLIST(MAIN_VW.ENTRY_tY,'ST','PT')
			Select Main_Vw
			If Type('U_INTR_PER')#'U'
				_curfrmobj = _Screen.ActiveForm
				If Type( "_curfrmobj.sqlconobj")='O'
*!*				nRet = _curfrmobj.sqlconobj.DataConn([EXE],Company.DbName,"select ac_name,i_rate,i_days,intpay from ac_mast where ac_name='"+main_vw.party_nm+"'",[tmp_acmast],;
*!*						"_curfrmobj.nHandle",_curfrmobj.DataSessionId,.f.)   && Commented by Archana K. on 2/1/2013 for Bug-7858
					nRet = _curfrmobj.sqlconobj.DataConn([EXE],Company.DbName,"select ac_name,i_rate,i_days,intpay from ac_mast where ac_name=?main_vw.party_nm",[tmp_acmast],;
						"_curfrmobj.nHandle",_curfrmobj.DataSessionId,.F.)  && Changes by Archana K. on 2/1/2013 for Bug-7858
					If nRet <= 0
						Return .F.
					Endif
					If Main_Vw.u_intr_per=0
						Replace Main_Vw.u_intr_per With tmp_acmast.i_rate In Main_Vw
					Endif
					If Used("tmp_acmast")
						Use In tmp_acmast
					Endif
				Endif
				Select Main_Vw
			Endif
		Endif
	Endif
*!*	IF INLIST(MAIN_VW.ENTRY_tY,'D1','D2','D3','D4','D5','C3','C2','C4','C5') AND (_screen.ActiveForm.addmode OR _screen.ActiveForm.editmode)		&& Commented by Shrikant S. on 17/03/2012 for Bug-2276
	If Inlist(Main_Vw.Entry_ty,'D2','D3','D4','D5','C3','C2','C4','C5') And (_Screen.ActiveForm.addmode Or _Screen.ActiveForm.editmode)			&& Added by Shrikant S. on 17/03/2012 for Bug-2276
		With _Screen.ActiveForm
			tot_grd_col=.voupage.page1.grditem.ColumnCount
			For i = 1 To tot_grd_col
				Do Case
					Case .voupage.page1.grditem.Columns(i).header1.Caption='Ass. Value'
						.voupage.page1.grditem.Columns(i).Visible=.F.

					Case .voupage.page1.grditem.Columns(i).header1.Caption='Rate'
						.voupage.page1.grditem.Columns(i).Visible=.F.

					Case .voupage.page1.grditem.Columns(i).header1.Caption='Quantity'
						.voupage.page1.grditem.Columns(i).Visible=Iif(Inlist(Main_Vw.Entry_ty,'D5','D4','C4','C5'),.T.,.F.)		&& Added by Shrikant S. on 17/03/2012 for Bug-2276
*!*					 		.voupage.page1.grditem.columns(i).visible=IIF(INLIST(main_vw.entry_ty,'D1','D5','D4','C4','C5'),.t.,.f.)	&& Commented by Shrikant S. on 17/03/2012 for Bug-2276

					Case .voupage.page1.grditem.Columns(i).header1.Caption='Sale Bill No.'
						.voupage.page1.grditem.Columns(i).Width=70

					Case .voupage.page1.grditem.Columns(i).header1.Caption='Item Name'
						.voupage.page1.grditem.Columns(i).Width=120
						.voupage.page1.grditem.Columns(i).Visible=.F.		&& Added by Shrikant S. on 04/01/2013 for Bug-7269
*!*					.voupage.page1.grditem.Columns(i).Visible=Iif(Inlist(_Screen.ActiveForm.pcvtype,'D3','C3'),.T.,.F.)		&& Added by Shrikant S. on 17/03/2012 for Bug-2276	&& Commented by Shrikant S. on 04/01/2013 for Bug-7269
*!*							.voupage.page1.grditem.columns(i).visible=IIF(INLIST(_screen.ActiveForm.pcvtype,'D3','D1','C3'),.t.,.f.)		&& Commented by Shrikant S. on 17/03/2012 for Bug-2276


*				   CASE .voupage.page1.grditem.columns(i).header1.caption='Payment Recd. Date'
					Case .voupage.page1.grditem.Columns(i).header1.Caption=Iif(Inlist(Main_Vw.Entry_ty,'C3'),'Payment Made Date','Payment Recd. Date')
						.voupage.page1.grditem.Columns(i).header1.Caption=Iif(Inlist(Main_Vw.Entry_ty,'C3'),'Payment Made Date','Payment Recd. Date')
						.voupage.page1.grditem.Columns(i).Visible=Iif(Inlist(Main_Vw.Entry_ty,'D3','C3'),.T.,.F.)

*				   CASE .voupage.page1.grditem.columns(i).header1.caption='Recd. Amount'
					Case .voupage.page1.grditem.Columns(i).header1.Caption=Iif(Inlist(Main_Vw.Entry_ty,'C3'),'Made Amount','Recd. Amount')
						.voupage.page1.grditem.Columns(i).header1.Caption=Iif(Inlist(Main_Vw.Entry_ty,'C3'),'Made Amount','Recd. Amount')
						.voupage.page1.grditem.Columns(i).Visible=Iif(Inlist(Main_Vw.Entry_ty,'D3','C3'),.T.,.F.)

					Case .voupage.page1.grditem.Columns(i).header1.Caption='Late Days'
						.voupage.page1.grditem.Columns(i).Visible=Iif(Inlist(Main_Vw.Entry_ty,'D3','C3'),.T.,.F.)

					Case .voupage.page1.grditem.Columns(i).header1.Caption='Interest %'
						.voupage.page1.grditem.Columns(i).Visible=Iif(Inlist(Main_Vw.Entry_ty,'D3','C3'),.T.,.F.)

					Case .voupage.page1.grditem.Columns(i).header1.Caption='Interest Amount'
						.voupage.page1.grditem.Columns(i).Visible=Iif(Inlist(Main_Vw.Entry_ty,'D3','C3'),.T.,.F.)
						.voupage.page1.grditem.Refresh
				Endcase
			Endfor
		Endwith
		Select item_vw
		If Main_Vw.Entry_ty='D3'   And _Screen.ActiveForm.addmode
* Check for Interest Pay Party :Start
			_curfrmobj = _Screen.ActiveForm
			nRet = _curfrmobj.sqlconobj.DataConn([EXE],Company.DbName,"select ac_name,i_rate,i_days,intpay from ac_mast where ac_name='"+Main_Vw.party_nm+"'",[tmp_acmast],;
				"_curfrmobj.nHandle",_curfrmobj.DataSessionId,.F.)
			If nRet <= 0
				Return .F.
			Endif
			If tmp_acmast.intpay

				Select tmp_acmast
				_curfrmobj.intbaseday=tmp_acmast.i_days

				If Used("tmp_acmast")
					Use In tmp_acmast
				Endif

* Check for Interest Pay Party :End

				Do Form frmgetdate With Date()
				nRet=0
				mAlias = Alias()
				_curfrmobj = _Screen.ActiveForm
* Cash Receipt
				sqlstr1="select stmain.inv_no as sbillno,stmain.inv_sr as sinvsr,'Interest' as item ,crmall.new_all as recdamt,stmain.date as sdate,stmain.due_dt as sduedt,crmain.date as brdate,stmain.net_amt as sbillamt ,crmain.net_amt , "
				sqlstr2="ltdays=convert(int,(crmain.date-stmain.due_dt)),stmain.U_INTR_PER as intper from crmain inner join crmall on crmain.tran_cd=crmall.tran_cd "
				sqlstr3="left join stacdet on stacdet.tran_cd=crmall.main_tran and stacdet.acserial=crmall.acseri_all "
				sqlstr4="inner join stmain on stmain.tran_cd=stacdet.tran_cd where  crmain.date BETWEEN  ?brsdate and ?bredate AND CRMAIN.AC_ID = ?MAIN_VW.AC_ID"

				nRet = _curfrmobj.sqlconobj.DataConn([EXE],Company.DbName,sqlstr1+sqlstr2+sqlstr3+sqlstr4,[tmp_sdetail_vw1],;
					"_curfrmobj.nHandle",_curfrmobj.DataSessionId,.F.)
* Bank Receipt
				sqlstr1="select stmain.inv_no as sbillno,stmain.inv_sr as sinvsr,'Interest' as item ,brmall.new_all as recdamt,stmain.date as sdate,stmain.due_dt as sduedt,brmain.date as brdate,stmain.net_amt as sbillamt ,brmain.net_amt , "
				sqlstr2="ltdays=convert(int,(brmain.date-stmain.due_dt)),stmain.U_INTR_PER as intper from brmain inner join brmall on brmain.tran_cd=brmall.tran_cd "
				sqlstr3="left join stacdet on stacdet.tran_cd=brmall.main_tran and stacdet.acserial=brmall.acseri_all "
				sqlstr4="inner join stmain on stmain.tran_cd=stacdet.tran_cd where  brmain.date BETWEEN  ?brsdate and ?bredate AND BRMAIN.AC_ID = ?MAIN_VW.AC_ID"

*!*					nRet = _curfrmobj.sqlconobj.DataConn([EXE],Company.DbName,"select ac_name,i_rate,i_days from ac_mast where ac_name='"+main_vw.party_nm+"'",[tmp_acmast],;
*!*							"_curfrmobj.nHandle",_curfrmobj.DataSessionId,.f.)
*!*						If nRet <= 0
*!*						RETURN .f.
*!*						ENDIF

*!*					IF USED("tmp_acmast")
*!*					USE IN tmp_acmast
*!*					ENDIF

				nRet = _curfrmobj.sqlconobj.DataConn([EXE],Company.DbName,"select it_code from it_mast where it_name='Interest'",[tmp_itcode],;
					"_curfrmobj.nHandle",_curfrmobj.DataSessionId,.F.)
				If nRet <= 0
					Return .F.
				Endif
				Select tmp_itcode
				ztmpitcode =''
				ztmpitcode=tmp_itcode.it_code

				nRet = _curfrmobj.sqlconobj.DataConn([EXE],Company.DbName,sqlstr1+sqlstr2+sqlstr3+sqlstr4,[tmp_sdetail_vw],;
					"_curfrmobj.nHandle",_curfrmobj.DataSessionId,.F.)



				ztmpintbaseday=365
				If _curfrmobj.intbaseday>0
					ztmpintbaseday=_curfrmobj.intbaseday
				Endif

				If nRet > 0 And Used('tmp_sdetail_vw')
					If Used('tmp_sdetail_vw1')
						Select tmp_sdetail_vw
						Append From  Dbf('tmp_sdetail_vw1')
						Select tmp_sdetail_vw1
						Use In tmp_sdetail_vw1
					Endif
					Select item_vw
					mitem_no=0
					Count To mitem_no
					Select item_vw
					Delete All
					Select tmp_sdetail_vw
					Delete All For ltdays <= 0
					Go Top
					Scan
						mitem_no=mitem_no+1
						Select item_vw
*						LOCATE FOR ALLTRIM(item_vw.sinvsr) = ALLTRIM(tmp_sdetail_vw.sinvsr) AND item_vw.sbdate = tmp_sdetail_vw.sdate ;
AND ALLTRIM(item_vw.sbillno) = ALLTRIM(tmp_sdetail_vw.sbillno) AND ALLTRIM(item_vw.item) = ALLTRIM(tmp_sdetail_vw.item)
*						IF NOT FOUND()
						Append Blank
						Replace item_vw.sinvsr With tmp_sdetail_vw.sinvsr In item_vw
						Replace item_vw.sbdate With tmp_sdetail_vw.sdate In item_vw
						Replace item_vw.sbillno With tmp_sdetail_vw.sbillno In item_vw
						Replace item_vw.sbillamt With tmp_sdetail_vw.sbillamt In item_vw
						Replace item_vw.ltdays With tmp_sdetail_vw.ltdays In item_vw
						Replace item_vw.Item With tmp_sdetail_vw.Item In item_vw
						Replace item_vw.brdate With tmp_sdetail_vw.brdate In item_vw
						Replace item_vw.recdamt With tmp_sdetail_vw.recdamt In item_vw
						Replace item_vw.sduedt With tmp_sdetail_vw.sduedt In item_vw
						Replace item_vw.intper With tmp_sdetail_vw.intper In item_vw
						Replace item_no With Str(mitem_no,4),itserial With Padl(Alltrim(Str(mitem_no)),Len(itserial),'0') In item_vw
*			ENDIF
					Endscan
					Select item_vw
					Replace All item_vw.Entry_ty With Main_Vw.Entry_ty In item_vw
					Replace All item_vw.Date With Main_Vw.Date In item_vw
					Replace All item_vw.doc_no With Main_Vw.doc_no In item_vw
					Replace All item_vw.qty With 1 In item_vw
					Replace All item_vw.intamt With Round(((item_vw.recdamt*(item_vw.intper/100))/ztmpintbaseday)*item_vw.ltdays,0) In item_vw
					Replace All item_vw.rate With item_vw.intamt In item_vw
					Replace All item_vw.gro_amt With item_vw.rate*item_vw.qty In item_vw
					Replace All it_code With ztmpitcode
					_Screen.ActiveForm.voupage.page1.grditem.Refresh
				Else
					nRet = 0
				Endif
			Endif
		Endif

**************************************** FORWARDING ***************************************************
*--------------------------------------- FOR DEBIT NOTE -----------------------------------------------
		If Main_Vw.Entry_ty='D2'   And _Screen.ActiveForm.addmode  &&Birendra
			nRet=0
			_curfrmobj = _Screen.ActiveForm

			sqlstr1="select stmain.inv_no as sbillno,stmain.inv_sr as sinvsr,'Interest' as item ,stmain.date as sdate,stmain.due_dt as sduedt,stmain.net_amt as sbillamt, "
			sqlstr2="stmain.U_INTR_PER as intper from stmain where stmain.ac_id = ?MAIN_VW.AC_ID and stmain.date = ?main_vw.date and stmain.frwdn = 'YES'"
			sqlstr3=""
			sqlstr4=""

			nRet = _curfrmobj.sqlconobj.DataConn([EXE],Company.DbName,"select it_code from it_mast where it_name='Interest'",[tmp_itcode],;
				"_curfrmobj.nHandle",_curfrmobj.DataSessionId,.F.)
			If nRet <= 0
				Return .F.
			Endif
			Select tmp_itcode
			ztmpitcode=tmp_itcode.it_code

			nRet = _curfrmobj.sqlconobj.DataConn([EXE],Company.DbName,sqlstr1+sqlstr2,[tmp_sdetail_vw],;
				"_curfrmobj.nHandle",_curfrmobj.DataSessionId,.F.)

			If nRet > 0 And Used('tmp_sdetail_vw')
				Select item_vw
				mitem_no=0
				Count To mitem_no
				Select tmp_sdetail_vw
				Scan
					mitem_no=mitem_no+1
					Select item_vw
					Append Blank
					Replace item_vw.sinvsr With tmp_sdetail_vw.sinvsr In item_vw
					Replace item_vw.sbdate With tmp_sdetail_vw.sdate In item_vw
					Replace item_vw.sbillno With tmp_sdetail_vw.sbillno In item_vw
					Replace item_vw.sbillamt With tmp_sdetail_vw.sbillamt In item_vw
					Replace item_vw.Item With tmp_sdetail_vw.Item In item_vw
					Replace item_vw.sduedt With tmp_sdetail_vw.sduedt In item_vw
					Replace item_no With Str(mitem_no,4),itserial With Padl(Alltrim(Str(mitem_no)),Len(itserial),'0') In item_vw
				Endscan
				Select item_vw
				Replace All item_vw.Entry_ty With Main_Vw.Entry_ty In item_vw
				Replace All item_vw.Date With Main_Vw.Date In item_vw
				Replace All item_vw.doc_no With Main_Vw.doc_no In item_vw
				Replace All item_vw.qty With 1 In item_vw
				Replace All it_code With ztmpitcode

				_Screen.ActiveForm.voupage.page1.grditem.Refresh
			Else
				nRet = 0
			Endif

		Endif

***credit note late payment***

		If Inlist(Main_Vw.Entry_ty,'C3') And _Screen.ActiveForm.addmode
* Check for Interest Pay Party :Start
			_curfrmobj = _Screen.ActiveForm
			nRet = _curfrmobj.sqlconobj.DataConn([EXE],Company.DbName,"select ac_name,i_rate,i_days,intpay from ac_mast where ac_name='"+Main_Vw.party_nm+"'",[tmp_acmast],;
				"_curfrmobj.nHandle",_curfrmobj.DataSessionId,.F.)
			If nRet <= 0
				Return .F.
			Endif
			If tmp_acmast.intpay

				Select tmp_acmast
				_curfrmobj.intbaseday=tmp_acmast.i_days

				If Used("tmp_acmast")
					Use In tmp_acmast
				Endif

* Check for Interest Pay Party :End

				Do Form frmgetdate With Date()
				nRet=0
				mAlias = Alias()
				_curfrmobj = _Screen.ActiveForm
* Cash payment
				sqlstr1="select ptmain.u_pinvno as sbillno,'Interest' as item ,cpmall.new_all as recdamt,ptmain.date as sdate,ptmain.due_dt as sduedt,cpmain.date as brdate,ptmain.net_amt as sbillamt ,cpmain.net_amt , "
				sqlstr2="ltdays=convert(int,(cpmain.date-ptmain.due_dt)),ptmain.U_INTR_PER as intper from cpmain inner join cpmall on cpmain.tran_cd=cpmall.tran_cd "
				sqlstr3="left join ptacdet on ptacdet.tran_cd=cpmall.main_tran and ptacdet.acserial=cpmall.acseri_all "
				sqlstr4="inner join ptmain on ptmain.tran_cd=ptacdet.tran_cd where  cpmain.date BETWEEN  ?brsdate and ?bredate AND CPMAIN.AC_ID = ?MAIN_VW.AC_ID"

				nRet = _curfrmobj.sqlconobj.DataConn([EXE],Company.DbName,sqlstr1+sqlstr2+sqlstr3+sqlstr4,[tmp_sdetail_vw1],;
					"_curfrmobj.nHandle",_curfrmobj.DataSessionId,.F.)
* Bank Payment

				sqlstr1="select ptmain.u_pinvno as sbillno,'Interest' as item ,bpmall.new_all as recdamt,ptmain.date as sdate,ptmain.due_dt as sduedt,bpmain.date as brdate,ptmain.net_amt as sbillamt ,bpmain.net_amt , "
				sqlstr2="ltdays=convert(int,(bpmain.date-ptmain.due_dt)),ptmain.U_INTR_PER as intper from bpmain inner join bpmall on bpmain.tran_cd=bpmall.tran_cd "
				sqlstr3="left join ptacdet on ptacdet.tran_cd=bpmall.main_tran and ptacdet.acserial=bpmall.acseri_all "
				sqlstr4="inner join ptmain on ptmain.tran_cd=ptacdet.tran_cd where bpmain.date BETWEEN  ?brsdate and ?bredate AND BpMAIN.AC_ID = ?MAIN_VW.AC_ID"

*!*			nRet = _curfrmobj.sqlconobj.DataConn([EXE],Company.DbName,"select ac_name,i_rate,i_days from ac_mast where ac_name='"+main_vw.party_nm+"'",[tmp_acmast],;
*!*					"_curfrmobj.nHandle",_curfrmobj.DataSessionId,.f.)
*!*				If nRet <= 0
*!*				RETURN .f.
*!*				ENDIF
*!*			SELECT tmp_acmast
*!*			_curfrmobj.intbaseday=tmp_acmast.i_days

*!*			IF USED("tmp_acmast")
*!*			USE IN tmp_acmast
*!*			ENDIF

				nRet = _curfrmobj.sqlconobj.DataConn([EXE],Company.DbName,"select it_code from it_mast where it_name='Interest'",[tmp_itcode],;
					"_curfrmobj.nHandle",_curfrmobj.DataSessionId,.F.)
				If nRet <= 0
					Return .F.
				Endif

				Select tmp_itcode
				ztmpitcode =''
				ztmpitcode=tmp_itcode.it_code

				nRet = _curfrmobj.sqlconobj.DataConn([EXE],Company.DbName,sqlstr1+sqlstr2+sqlstr3+sqlstr4,[tmp_sdetail_vw],;
					"_curfrmobj.nHandle",_curfrmobj.DataSessionId,.F.)

				ztmpintbaseday=365
				If _curfrmobj.intbaseday>0
					ztmpintbaseday=_curfrmobj.intbaseday
				Endif


				If nRet > 0 And Used('tmp_sdetail_vw')
					If Used('tmp_sdetail_vw1')
						Select tmp_sdetail_vw
						Append From  Dbf('tmp_sdetail_vw1')
						Select tmp_sdetail_vw1
						Use In tmp_sdetail_vw1
					Endif

					Select item_vw
					mitem_no=0
					Count To mitem_no
					Select item_vw
					Delete All
					Select tmp_sdetail_vw
					Delete All For ltdays <= 0
					Go Top
					Scan
						mitem_no=mitem_no+1
						Select item_vw
*					LOCATE FOR ALLTRIM(item_vw.sinvsr) = ALLTRIM(tmp_sdetail_vw.sinvsr) AND item_vw.sbdate = tmp_sdetail_vw.sdate ;
AND ALLTRIM(item_vw.sbillno) = ALLTRIM(tmp_sdetail_vw.sbillno) AND ALLTRIM(item_vw.item) = ALLTRIM(tmp_sdetail_vw.item)
*					IF NOT FOUND()
						Append Blank
						Replace item_vw.sbdate With tmp_sdetail_vw.sdate In item_vw
						Replace item_vw.sbillno With tmp_sdetail_vw.sbillno In item_vw
						Replace item_vw.sbillamt With tmp_sdetail_vw.sbillamt In item_vw
						Replace item_vw.ltdays With tmp_sdetail_vw.ltdays In item_vw
						Replace item_vw.Item With tmp_sdetail_vw.Item In item_vw
						Replace item_vw.brdate With tmp_sdetail_vw.brdate In item_vw
						Replace item_vw.recdamt With tmp_sdetail_vw.recdamt In item_vw
						Replace item_vw.sduedt With tmp_sdetail_vw.sduedt In item_vw
						Replace item_vw.intper With tmp_sdetail_vw.intper In item_vw
						Replace item_no With Str(mitem_no,4),itserial With Padl(Alltrim(Str(mitem_no)),Len(itserial),'0') In item_vw
*					ENDIF
					Endscan
					Select item_vw
					Replace All item_vw.Entry_ty With Main_Vw.Entry_ty In item_vw
					Replace All item_vw.Date With Main_Vw.Date In item_vw
					Replace All item_vw.doc_no With Main_Vw.doc_no In item_vw
					Replace All item_vw.qty With 1 In item_vw
					Replace All item_vw.intamt With Round(((item_vw.recdamt*(item_vw.intper/100))/ztmpintbaseday)*item_vw.ltdays,0) In item_vw
					Replace All item_vw.rate With item_vw.intamt In item_vw
					Replace All item_vw.gro_amt With item_vw.rate*item_vw.qty In item_vw
					Replace All it_code With ztmpitcode

					_Screen.ActiveForm.voupage.page1.grditem.Refresh
				Else
					nRet = 0
				Endif
			Endif
		Endif
*end credit note late payment

***for forwarding credit note***

		If Main_Vw.Entry_ty='C2'   And _Screen.ActiveForm.addmode  &&Birendra

			nRet=0
			_curfrmobj = _Screen.ActiveForm

			sqlstr1="select ptmain.u_pinvno as sbillno,'Interest' as item ,ptmain.date as sdate,ptmain.due_dt as sduedt,ptmain.net_amt as sbillamt, "
			sqlstr2="ptmain.U_INTR_PER as intper from ptmain where ptmain.ac_id = ?MAIN_VW.AC_ID and ptmain.date = ?main_vw.date and ptmain.frwdn = 'YES'"
			sqlstr3=""
			sqlstr4=""

			nRet = _curfrmobj.sqlconobj.DataConn([EXE],Company.DbName,"select it_code from it_mast where it_name='Interest'",[tmp_itcode],;
				"_curfrmobj.nHandle",_curfrmobj.DataSessionId,.F.)
			If nRet <= 0
				Return .F.
			Endif

			Select tmp_itcode
			ztmpitcode =''
			ztmpitcode=tmp_itcode.it_code


			nRet = _curfrmobj.sqlconobj.DataConn([EXE],Company.DbName,sqlstr1+sqlstr2,[tmp_sdetail_vw],;
				"_curfrmobj.nHandle",_curfrmobj.DataSessionId,.F.)

			If nRet > 0 And Used('tmp_sdetail_vw')
				Select item_vw
				mitem_no=0
				Count To mitem_no
				Select tmp_sdetail_vw

				Scan
					mitem_no=mitem_no+1
					Select item_vw
					Append Blank
					Replace item_vw.sbdate With tmp_sdetail_vw.sdate In item_vw
					Replace item_vw.sbillno With tmp_sdetail_vw.sbillno In item_vw
					Replace item_vw.sbillamt With tmp_sdetail_vw.sbillamt In item_vw
					Replace item_vw.Item With tmp_sdetail_vw.Item In item_vw
					Replace item_vw.sduedt With tmp_sdetail_vw.sduedt In item_vw
					Replace item_no With Str(mitem_no,4),itserial With Padl(Alltrim(Str(mitem_no)),Len(itserial),'0') In item_vw
				Endscan
				Select item_vw
				Replace All item_vw.Entry_ty With Main_Vw.Entry_ty In item_vw
				Replace All item_vw.Date With Main_Vw.Date In item_vw
				Replace All item_vw.doc_no With Main_Vw.doc_no In item_vw
				Replace All item_vw.qty With 1 In item_vw
				Replace All item_vw.it_code With ztmpitcode In item_vw
				_Screen.ActiveForm.voupage.page1.grditem.Refresh
			Else
				nRet = 0
			Endif
		Endif

*!*	*end forwarding credit note


	Endif

&&Added by Priyanka B on 28042018 for UERP Installer 1.0.0 Start
	If Used('Main_vw') And (_Screen.ActiveForm.addmode Or _Screen.ActiveForm.editmode)
		If ALLTRIM(_Screen.ActiveForm.FldVals) <> ALLTRIM(Main_Vw.party_nm)
			mewbdist=Iif(Type('Main_vw.EWBDIST')='N','Main_vw',Iif(Type('Lmc_vw.EWBDIST')='N','Lmc_vw',Iif(Type('MainAdd_vw.EWBDIST')='N','MainAdd_vw','')))

			If !Empty(mewbdist)
				nRet=0
				_curfrmobj = _Screen.ActiveForm

				msqlstr="SELECT ISNULL(EWBDIST,0) AS EWBDIST FROM AC_MAST WHERE AC_NAME=?MAIN_VW.PARTY_NM"

				nRet = _curfrmobj.sqlconobj.DataConn([EXE],Company.DbName,msqlstr,[tmpewbdist],;
					"_curfrmobj.nHandle",_curfrmobj.DataSessionId,.F.)
				If nRet <= 0
					Return .F.
				Else
					Select tmpewbdist
					Replace ewbdist With tmpewbdist.ewbdist In &mewbdist
				Endif
			Endif
		Endif
	Endif
&&Added by Priyanka B on 28042018 for UERP Installer 1.0.0 End
Endif


*-------------------------------------------------------------------------------------------------------------


*!*	* -----------------------------------------------------------------------------------------------------------------

*!*	*credit note discount
*!*		IF MAIN_VW.DEPT = 'DISCOUNT' AND main_vw.entry_ty='CI'
*!*			WITH _screen.ActiveForm
*!*				tot_grd_col=.voupage.page1.grditem.columncount
*!*					FOR i = 1 TO tot_grd_col
*!*				DO CASE
*!*			       CASE .voupage.page1.grditem.columns(i).header1.caption='Rate'
*!*						.voupage.page1.grditem.columns(i).visible=.F.
*!*
*!*				   CASE .voupage.page1.grditem.columns(i).header1.caption='Quantity'
*!*				 		.voupage.page1.grditem.columns(i).visible=.t.
*!*
*!*		           CASE .voupage.page1.grditem.columns(i).header1.caption='Purchase Bill No.'
*!*				  		.voupage.page1.grditem.columns(i).width=80
*!*
*!*				   CASE .voupage.page1.grditem.columns(i).header1.caption='Item Name'
*!*				 		.voupage.page1.grditem.columns(i).width=120
*!*
*!*				   CASE .voupage.page1.grditem.columns(i).header1.caption='Payment Paid Date'
*!*				 		.voupage.page1.grditem.columns(i).visible=.f.
*!*
*!*				   CASE .voupage.page1.grditem.columns(i).header1.caption='Paid Amount'
*!*				 		.voupage.page1.grditem.columns(i).visible=.f.
*!*
*!*				   CASE .voupage.page1.grditem.columns(i).header1.caption='Late Days'
*!*				 		.voupage.page1.grditem.columns(i).visible=.f.

*!*				   CASE .voupage.page1.grditem.columns(i).header1.caption='Interest %'
*!*				 		.voupage.page1.grditem.columns(i).visible=.f.

*!*				   CASE .voupage.page1.grditem.columns(i).header1.caption='Interest Amount'
*!*				 		.voupage.page1.grditem.columns(i).visible=.f.
*!*
*!*					 	.voupage.page1.grditem.refresh
*!*
*!*				   ENDCASE
*!*				ENDFOR
*!*			ENDWITH
*!*		ENDIF

*!*	*end credit note discount

*!*	*----------------------------------------------------------------------------------------------------------------------

*!*	*credit note rate difference

*!*		IF MAIN_VW.DEPT = 'RATE DIFFERENCE' AND main_vw.entry_ty='CI'
*!*				WITH _screen.ActiveForm
*!*					tot_grd_col=.voupage.page1.grditem.columncount
*!*					FOR i = 1 TO tot_grd_col
*!*					DO CASE
*!*				       CASE .voupage.page1.grditem.columns(i).header1.caption='Rate'
*!*							.voupage.page1.grditem.columns(i).visible=.F.
*!*
*!*					   CASE .voupage.page1.grditem.columns(i).header1.caption='Quantity'
*!*					 		.voupage.page1.grditem.columns(i).visible=.T.
*!*
*!*			           CASE .voupage.page1.grditem.columns(i).header1.caption='Purchase Bill No.'
*!*					  		.voupage.page1.grditem.columns(i).width=70
*!*
*!*					   CASE .voupage.page1.grditem.columns(i).header1.caption='Item Name'
*!*					 		.voupage.page1.grditem.columns(i).width=120
*!*
*!*					   CASE .voupage.page1.grditem.columns(i).header1.caption='Payment Paid Date'
*!*					 		.voupage.page1.grditem.columns(i).visible=.f.
*!*
*!*					   CASE .voupage.page1.grditem.columns(i).header1.caption='Paid Amount'
*!*					 		.voupage.page1.grditem.columns(i).visible=.f.
*!*
*!*					   CASE .voupage.page1.grditem.columns(i).header1.caption='Late Days'
*!*					 		.voupage.page1.grditem.columns(i).visible=.f.
*!*
*!*					   CASE .voupage.page1.grditem.columns(i).header1.caption='Interest %'
*!*					 		.voupage.page1.grditem.columns(i).visible=.f.
*!*
*!*					   CASE .voupage.page1.grditem.columns(i).header1.caption='Interest Amount'
*!*					 		.voupage.page1.grditem.columns(i).visible=.f.

*!*						 	.voupage.page1.grditem.refresh
*!*			    	ENDCASE
*!*				ENDFOR
*!*			ENDWITH
*!*		ENDIF

*!*	*end credit note rate difference

*!*	*-------------------------------------------------------------------------------------------------------------------

*!*	*credit note weight difference

*!*		IF MAIN_VW.DEPT = 'WEIGHT DIFFERENCE'  AND main_vw.entry_ty='CI'

*!*			WITH _screen.ActiveForm
*!*				tot_grd_col=.voupage.page1.grditem.columncount
*!*				FOR i = 1 TO tot_grd_col
*!*
*!*				DO CASE
*!*			       CASE .voupage.page1.grditem.columns(i).header1.caption='Rate'
*!*						.voupage.page1.grditem.columns(i).visible=.F.
*!*
*!*				   CASE .voupage.page1.grditem.columns(i).header1.caption='Quantity'
*!*				 		.voupage.page1.grditem.columns(i).visible=.T.
*!*
*!*		           CASE .voupage.page1.grditem.columns(i).header1.caption='Purchase Bill No.'
*!*				  		.voupage.page1.grditem.columns(i).width=80
*!*
*!*				   CASE .voupage.page1.grditem.columns(i).header1.caption='Item Name'
*!*				 		.voupage.page1.grditem.columns(i).width=120
*!*
*!*				   CASE .voupage.page1.grditem.columns(i).header1.caption='Payment Paid Date'
*!*				 		.voupage.page1.grditem.columns(i).visible=.f.
*!*
*!*				   CASE .voupage.page1.grditem.columns(i).header1.caption='Paid Amount'
*!*				 		.voupage.page1.grditem.columns(i).visible=.f.
*!*
*!*				   CASE .voupage.page1.grditem.columns(i).header1.caption='Late Days'
*!*				 		.voupage.page1.grditem.columns(i).visible=.f.
*!*
*!*				   CASE .voupage.page1.grditem.columns(i).header1.caption='Interest %'
*!*				 		.voupage.page1.grditem.columns(i).visible=.f.
*!*
*!*				   CASE .voupage.page1.grditem.columns(i).header1.caption='Interest Amount'
*!*				 		.voupage.page1.grditem.columns(i).visible=.f.

*!*					 	.voupage.page1.grditem.refresh
*!*
*!*		    	ENDCASE
*!*
*!*			ENDFOR
*!*		ENDWITH
*!*		ENDIF

*!*	**end credit note weight difference
*!*	endif
*!*	SELECT (mAlias)




*!*	**--** (Start) Added patch for "Grace Period Checking for Sales Transaction" = (12 01 2010)

*!*	*!*	If (Type('_screen.activeform.PCVTYPE')='C' And Used('MAIN_VW'))
*!*	*!*		If MAIN_VW.ENTRY_TY='ST'
*!*	*!*			_curvouobj = _Screen.ActiveForm
*!*	*!*			sqlconobj=Newobject('sqlconnudobj',"sqlconnection",xapps)
*!*	*!*			nHandle=0
*!*	*!*			mAllow = .F.
*!*	*!*			sq1="select u_grpd from Ac_Mast where Ac_name='"+ MAIN_VW.party_nm +"'"
*!*	*!*			nRetval = sqlconobj.dataconn([EXE],company.dbname,sq1,"AC","nHandle",_Screen.ActiveForm.DataSessionId)
*!*	*!*			If EMPTY(nRetval)
*!*	*!*				Return .F.
*!*	*!*			Endif
*!*	*!*			If Used("AC")
*!*	*!*				Select AC
*!*	*!*				Go Top
*!*	*!*				If Reccount() > 0
*!*	*!*					If !empty(AC.u_grpd) Then
*!*	*!*						Messagebox(" "+ Alltrim(MAIN_VW.party_nm) +" has "+Alltrim(AC.U_GRPD)+" days Grace Period.",64+0,"Grace Period Alert")
*!*	*!*					Endif
*!*	*!*				Endif
*!*	*!*			ENDIF
*!*	*!*		ENDIF
*!*	*!*	ENDIF

*!*	**--** (End)
