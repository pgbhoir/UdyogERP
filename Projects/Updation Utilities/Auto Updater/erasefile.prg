LPARAMETERS _mEraseFldrNm,_mEraseFileNm
IF DIRECTORY(_mEraseFldrNm,1)
	_ErrMsg = ''
	CREATE CURSOR tmpFldrList (FldrName Memo,Srched Logical)
	APPEND BLANK IN tmpFldrList
	REPLACE FldrName WITH _mEraseFldrNm IN tmpFldrList
	DO WHILE .t.
		SELECT * FROM tmpFldrList WITH (buffering = .t.) WHERE Srched = .f. INTO cursor tmpFldrL1
		SELECT tmpFldrL1
		IF RECCOUNT() < 1
			EXIT
		ELSE
			SCAN
				_mRmFldrName = ALLTRIM(tmpFldrL1.FldrName)
				_mfcount  = ADIR(_mflist,Addbs(_mRmFldrName)+"*.*","D")
				FOR i1 = 1 TO _mfcount 
					_mRmFileName = Addbs(_mRmFldrName)+_mflist(i1,1)
					IF "D"$_mflist[i1,5] AND _mflist[i1,1] <> "." AND _mflist[i1,1] <> ".."
						SELECT tmpFldrList
						APPEND BLANK IN tmpFldrList
						REPLACE FldrName WITH _mRmFileName IN tmpFldrList
					Endif	
				ENDFOR
				RELEASE _mflist

				_mfcount  = ADIR(_mflist,Addbs(_mRmFldrName)+_mEraseFileNm,"D")
				FOR i1 = 1 TO _mfcount 
					_mRmFileName = Addbs(_mRmFldrName)+_mflist(i1,1)
					IF !"D"$_mflist[i1,5] 
						Try
							ERASE (_mRmFileName) RECYCLE
						CATCH TO m_errMsg
							_ErrMsg = ALLTRIM(m_errMsg.Message)
						ENDTRY
						IF FILE(_mRmFileName) AND EMPTY(_ErrMsg)
							_ErrMsg = "Unable to Delete "+_mRmFileName+" File."
						Endif	
					Endif
				ENDFOR
				RELEASE _mflist
				
				UPDATE tmpFldrList SET Srched = .t. WHERE ALLTRIM(FldrName) == ALLTRIM(_mRmFldrName)
				SELECT tmpFldrL1
			Endscan	
		Endif
	Enddo

	IF USED('tmpFldrList')
		USE IN tmpFldrList
	Endif	
	IF USED('tmpFldrL1')
		USE IN tmpFldrL1
	Endif	
	IF !EMPTY(_ErrMsg)
		*=Messagebox(_ErrMsg+CHR(13)+CHR(13)+'Check Folder '+_mEraseFldrNm,0+16,vuMess)
		*RETURN .f.
		=ErrLog(_ErrMsg+CHR(13)+CHR(13)+'Check Folder '+_mEraseFldrNm,'E')
		RETURN .f.
	Endif
Endif
