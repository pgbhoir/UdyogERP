*:*****************************************************************************
*:        Program: UpdateDebitCredit.PRG
*:         System: Udyog Software
*:         Author: RAGHU
*:  Last modified: 19/09/2006
*:			AIM  : Update Groupwise Opening,Debit And Credit
*:*****************************************************************************
Select Max(Level) As Maxlevel From _CTBAcMast Into Cursor CurMaxLevel
Go Top
If Type('Statdesktop') = 'O'
	Statdesktop.ProgressBar.Value = 60
Endif
mMaxlevel = Maxlevel

For I = mMaxlevel To 1 Step -1
	Select _CTBAcMast
	Set Filter To Level = I And MainFlg = 'G'
	Scan
		mAcId = Ac_Id
*!*			Select Sum(a.Opbal) As Opbal,;
*!*				SUM(a.debit) As debit,;
*!*				SUM(a.credit) As credit;
*!*				FROM _CTBAcMast a;
*!*				ORDER By a.Ac_Group_Id;
*!*				GROUP By a.Ac_Group_Id;
*!*				WHERE a.Ac_Group_Id = mAcId;
*!*				INTO Cursor SumCur

		Select Sum(a.Opbal) As Opbal,;
			SUM(a.debit) As debit,;
			SUM(a.credit) As credit;
			,Sum(OpDebit) As OpDebit;		&& Added by Sachin N. S. on 13/04/2018 for Bug-31398
			,Sum(OpCredit) As OpCredit;		&& Added by Sachin N. S. on 13/04/2018 for Bug-31398
			FROM _CTBAcMast a;
			ORDER By a.Ac_Group_Id;
			GROUP By a.Ac_Group_Id;
			WHERE a.Ac_Group_Id = mAcId;
			INTO Cursor SumCur


		Go Top
		m.Opbal = Iif(Isnull(SumCur.Opbal),0,SumCur.Opbal)
		m.debit = Iif(Isnull(SumCur.debit),0,SumCur.debit)
		m.credit = Iif(Isnull(SumCur.credit),0,SumCur.credit)
		m.ClBal = m.Opbal+m.debit-m.credit

***** Added by Sachin N. S. on 13/04/2018 for Bug-31398 -- Start
		m.Opdebit = Iif(Isnull(SumCur.Opdebit),0,SumCur.Opdebit)
		m.Opcredit = Iif(Isnull(SumCur.Opcredit),0,SumCur.Opcredit)
		m.Cldebit = m.Opdebit+m.debit
		m.Clcredit = m.Opcredit+m.credit
***** Added by Sachin N. S. on 13/04/2018 for Bug-31398 -- End

		Select _CTBAcMast
		Replace Opbal With m.Opbal
		Replace	debit With m.debit
		Replace	credit With m.credit
		Replace	ClBal With m.ClBal
		***** Added by Sachin N. S. on 13/04/2018 for Bug-31398 -- Start
		Replace	Opdebit With m.Opdebit
		Replace	Opcredit With m.Opcredit
		Replace	Cldebit With m.Cldebit
		Replace	Clcredit With m.Clcredit
		***** Added by Sachin N. S. on 13/04/2018 for Bug-31398 -- End
		
	Endscan
Endfor

If Type('Statdesktop') = 'O'
	Statdesktop.ProgressBar.Value = 70
Endif
