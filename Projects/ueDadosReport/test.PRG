Qstring = 'SELECT ac_name AS [Account Name] from Ac_mast order by Ac_name'
a=At(' AS ',QString)
?a
b=At("SELECT",QString)
?b
LenWord = At(' AS ',QString)-(At("SELECT",QString)+Len("SELECT")+1)
?lenword
ExWord  = Substr(QString,At("SELECT ",QString)+Len("SELECT")+1,LenWord)
?ExWord
WRDCaption = Substr(QString,At(' [',QString)+2,At('] ',QString)-(At(' [',QString)+2))
?WRDCaption
ExFind  =  Strtran(WRDCaption,' ','_')
?ExFind 
WRDCaption = "["+ExFind+":"+WRDCaption
?WRDCaption

cmdobj='cmd'
a = "thisform."+Strtran(cmdobj,"cmd","txt")+".value"
?a

