if slipno = 0
	retu
endif
set exac off
set near on
sele brtemp
set orde to tag slipno
isexist=0
mbentry = brtemp.entry_ty
mbdate  = brtemp.date
mbamt   = brtemp.amt_ty
mbslip  = brtemp.slipno
mdocno  = brtemp.doc_no
mr = recno()
count for date == mbdate and entry_ty==mbentry and amt_ty == mbamt ;
     and alltr(str(slipno)) = alltr(str(mbslip)) to isexist
if isexist=1
	go mr
	delete
	sele breco
	set orde to tag slipno
 	seek(dtos(mbdate)+mbentry+mbamt+str(mbslip,6))
 	do while dtos(date)==dtos(mbdate) and entry_ty==mbentry and amt_ty==mbamt and str(slipno,6)==str(mbslip,6) and not eof()
 		scatte memvar
 	    sele brtemp
     	appe blan
   		gather memvar
  		sele breco
   		skip
 	endd
 	sele brtemp
 	set orde to tag slipno
 	seek(dtos(mbdate)+mbentry+mbamt+str(mbslip,6))
else
	set talk on
*!*		select entry_ty,date,doc_no,dept,cate,ac_name,amt_ty,sum(amount),oac_name,type,clause,cl_date,cheq_no,slipno,count(entry_ty+dtoc(date)+amt_ty+str(slipno)) as 'Cntcount' from brtemp ;
*!*	 	where !empty(slipno) and betwe(date,sdate,edate) and empty(clause) group by entry_ty,date,amt_ty,slipno ;
*!*	 	union ;
*!*	 	  (select entry_ty,date,doc_no,dept,cate,ac_name,amt_ty,amount,oac_name,type,clause,cl_date,cheq_no,slipno,0 as cntcount from brtemp where empty(slipno) and betwe(date,sdate,edate) and empty(clause)) ;
*!*	 	union ;
*!*	 	(select entry_ty,date,doc_no,dept,cate,ac_name,amt_ty,amount,oac_name,type,clause,cl_date,cheq_no,slipno,0 as cntcount from brtemp where !empty(slipno) and betwe(date,sdate,edate) and !empty(clause)) into cursor brrec1

	select entry_ty,date,doc_no,dept,cate,ac_name,amt_ty,sum(amount),oac_name,type,clause,cl_date,cheq_no,slipno,count(entry_ty+dtoc(date)+amt_ty+str(slipno)) as 'Cntcount' from brtemp ;
		where !empty(slipno) and (betwe(date,sdate,edate) or betwe(cl_date,sdate,edate)) group by entry_ty,date,amt_ty,slipno ;
 		UNION (select entry_ty,date,doc_no,dept,cate,ac_name,amt_ty,amount,oac_name,type,clause,cl_date,cheq_no,slipno,0 as cntcount ;
 		from brtemp where empty(slipno) and (betwe(date,sdate,edate) or betwe(cl_date,sdate,edate))) into cursor brrec1

 	set talk off
 	if _tally>0
 		sele brtemp
 		dele all 
 		set dele on
*!*			brow fiel cl_date :V=cl_date>=date OR (empty(cl_date) and !empty(clause)) OR (cl_Date > edate and !empt(clause))  :E = prop(Iif(cl_date<date, "Clear On date can not be less than Date", "Clause Can not be empty"));
*!*			 ,slipno, entry_ty:r:H="Type",date:r,cheq_no :H="Chq.No.",oac_name:r :H="Description",amount:r,amt_ty,clause, dept:r, cate:r nomenu nodele noappe prefere bankrec title [ Alt+D ->Date, Alt+1 ->+1, Alt+2 -> +2,... ] FONT "ARIAL",8 nowai

		brow fiel cl_date :V=cl_date>=date OR (empty(cl_date) and !empty(clause)) OR (cl_Date > edate and !empt(clause))  :E = prop(Iif(cl_date<date, "Clear On date can not be less than Date", "Clause Can not be empty"));
    	,slipno :R, entry_ty :R:H="Entry", date :R, cheq_no :R :H="Chq.No.", oac_name :R :H="Description", amount :R, amt_ty :R :H= "Type",Clause, dept :R, cate :R nomenu nodele noappe prefere bankrec ;
    	title [Reco:] + upper(allt(snam)) + " [Alt+0 ->Date,Alt+1,2,3->+1,2,3 {ENTER) F3->Detail,<Esc>-Exit]" FONT "ARIAL",8   &&wind brwind

    	sele brrec1
    	go top
    	do while not eof()
         	scatte memvar
         	sele brtemp
         	appe blan
         	gather memvar
         	repl amount with brrec1.sum_amount
         	if brrec1.cntcount>1
               sele brtemp
			   repl oac_name with spac(35),cheq_no with spac(10)
		 	endif
      		sele brrec1
      		skip
		endd
	endif
	sele brtemp
	go mr
endif
sele brtemp
*!*	brow fiel cl_date :V=cl_date>=date OR (empty(cl_date) and !empty(clause)) OR (cl_Date > edate and !empt(clause))  :E = prop(Iif(cl_date<date, "Clear On date can not be less than Date", "Clause Can not be empty"));
*!*		 ,slipno, entry_ty:r:H="Type",date:r,cheq_no :H="Chq.No.",oac_name:r :H="Description",amount:r,amt_ty,clause, dept:r, cate:r nomenu nodele noappe prefere bankrec title [ Alt+D ->Date, Alt+1 ->+1, Alt+2 -> +2,... ] FONT "ARIAL",8 nowai

brow fiel cl_date :V=cl_date>=date OR (empty(cl_date) and !empty(clause)) OR (cl_Date > edate and !empt(clause))  :E = prop(Iif(cl_date<date, "Clear On date can not be less than Date", "Clause Can not be empty"));
   	,slipno :R, entry_ty :R:H="Entry", date :R, cheq_no :R :H="Chq.No.", oac_name :R :H="Description", amount :R, amt_ty :R :H= "Type",Clause, dept :R, cate :R nomenu nodele noappe prefere bankrec ;
   	title [Reco:] + upper(allt(snam)) + " [Alt+0 ->Date,Alt+1,2,3->+1,2,3 {ENTER) F3->Detail,<Esc>-Exit]" FONT "ARIAL",8   &&wind brwind
return
