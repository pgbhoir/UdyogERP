DROP PROCEDURE [CREATE_DADOS_REP_SCRIPT_GENERATOR]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--*********************************************--
-- Procedure Name : CREATE_DADOS_REP_SCRIPT_GENERATOR
-- Description	  : This procedure is used to generate a Insert script for Dados Report
-- Created by/On/For : Sachin N. S. on 10/04/2014 for Bug-4524
--*********************************************--
CREATE PROCEDURE [CREATE_DADOS_REP_SCRIPT_GENERATOR]
@REPID VARCHAR(10)
AS
BEGIN

	DECLARE @GENSCRIPT NVARCHAR(MAX), @GENSCRIPT1 NVARCHAR(MAX)
	
	SELECT @GENSCRIPT1=' '
	SELECT @GENSCRIPT=REPLICATE(@GENSCRIPT1,10000000)	

	SELECT A.[NAME] AS TBL_NM,B.[NAME] AS FLD_NM, C.[NAME] AS TYP_NM, B.LENGTH, B.XPREC, B.XSCALE INTO #TBLSTRUCT
		FROM SYS.TABLES A
			INNER JOIN SYSCOLUMNS B ON A.OBJECT_ID=B.ID 
			INNER JOIN SYSTYPES C ON B.XTYPE=C.XTYPE
		WHERE A.[NAME] IN ('USREP','USLTY','USQRY','USRLV','USCRL','USCOL','PARA_MASTER','PARA_QUERY_MASTER')
		ORDER BY A.[NAME]

	DECLARE @REPNM VARCHAR(50)
	SELECT @REPNM=LTRIM(RTRIM(REPNM)) FROM USREP WHERE REPID=@REPID

	DECLARE @USREPFLDS NVARCHAR(MAX),@USREPVALS NVARCHAR(MAX)
	SELECT @USREPFLDS='',@USREPVALS=''
	SELECT	@USREPFLDS=@USREPFLDS + CASE WHEN @USREPFLDS='' THEN '' ELSE ',' END + '['+FLD_NM+']',
			@USREPVALS=@USREPVALS + CASE WHEN FLD_NM='REPID' THEN '@RepId' ELSE CASE WHEN @USREPVALS='' THEN '' ELSE ',' END + CASE WHEN TYP_NM='VARCHAR' THEN '''+CHAR(39)+'+FLD_NM+'+CHAR(39)+''' ELSE CASE WHEN TYP_NM='INT' THEN 'CAST('+FLD_NM+' AS VARCHAR)' ELSE 'CAST('+FLD_NM+' AS VARCHAR)' END END END
	FROM #TBLSTRUCT WHERE TBL_NM='USREP'
		

	SELECT @GENSCRIPT = 'Declare @RepId Varchar(6)'+ '\n'
	SELECT @GENSCRIPT = @GENSCRIPT + ' ' + 'Declare @LvlId Int'+ '\n'
	SELECT @GENSCRIPT = @GENSCRIPT + ' ' + 'Declare @QryId Int '+ '\n'
	SELECT @GENSCRIPT = @GENSCRIPT + ' ' + 'Declare @colId int'+ '\n'

	SELECT @GENSCRIPT = @GENSCRIPT + ' ' + '\n'

	SELECT @GENSCRIPT = @GENSCRIPT + ' ' + 'Select @RepId=MAX(RepId)+1 From UsRep'+ '\n' 
	SELECT @GENSCRIPT = @GENSCRIPT + ' ' + 'set @RepId=Replicate(''0'',6-len(@RepId))+@RepId'+ '\n' 

	SELECT @GENSCRIPT = @GENSCRIPT + ' ' + '\n'

	SELECT @GENSCRIPT = @GENSCRIPT + ' ' + 'If Not Exists(Select Top 1 Repid From usrep where repnm='+CHAR(39)+@REPNM+CHAR(39)+') '+ '\n'
	SELECT @GENSCRIPT = @GENSCRIPT + ' ' + 'Begin'+ '\n'
	
	DECLARE @SELECT NVARCHAR(MAX), @INSOUT NVARCHAR(MAX)
	SELECT @SELECT = 'SELECT @INSOUT1=''\tINSERT INTO USREP('+@USREPFLDS+') VALUES ('+@USREPVALS+')\n'' FROM USREP WHERE REPID = @REPID1'

	EXECUTE SP_EXECUTESQL @SELECT,N'@INSOUT1 NVARCHAR(MAX) OUTPUT,@REPID1 VARCHAR(10)',@REPID1=@REPID,@INSOUT1=@INSOUT OUTPUT

	SELECT @GENSCRIPT = @GENSCRIPT + ' ' + @INSOUT
	SELECT @GENSCRIPT = @GENSCRIPT + ' ' + 'End'+ '\n'
--
	SELECT @GENSCRIPT = @GENSCRIPT + ' ' + '\n'

	SELECT @GENSCRIPT = @GENSCRIPT + ' ' + 'delete from uscol where colid in(select colid from uscrl where repid=(Select RepID from Usrep where repnm='+CHAR(39)+@REPNM+CHAR(39)+'))'+ '\n'
	SELECT @GENSCRIPT = @GENSCRIPT + ' ' + 'delete from uscrl where repid=(Select RepID from Usrep where repnm='+CHAR(39)+@REPNM+CHAR(39)+')'+ '\n'

	SELECT @GENSCRIPT = @GENSCRIPT + ' ' + '\n'
	---- Defining Levels ---- Start

	DECLARE @lvlty VARCHAR(50),@lvlnm VARCHAR(100),@lvltid INT,@qryid BIGINT,@REPLVLID BIGINT,@repqry VARCHAR(MAX)
	DECLARE @PryCl VARCHAR(500), @SecCl VARCHAR(500),@LvlId BIGINT
	DECLARE @ColID  bigint, @ColumnNames VARCHAR(8000), @ColumnCaption VARCHAR(8000), @ColumnDataType VARCHAR(8000), @ColumnOrder VARCHAR(8000), @Precision VARCHAR(8000) 
	DECLARE @GroupOrder int, @IsGrouped bit, @IsFreezing bit, @IsSummury bit, @IsDisplayed bit, @ColWidth bigint 

	DECLARE CUR_REPLEVEL CURSOR FOR
	--Commented by Shrikant S. on 10/06/2017 for GST		--Start
	--SELECT lvlty,lvlnm,lvltid,QryID,RepLvlID,RepQry FROM USLTY A
	--INNER JOIN USQRY B ON A.LVLTID=B.REPLVLID
	--WHERE B.REPID=@REPID ORDER BY B.REPLVLID
	--Commented by Shrikant S. on 10/06/2017 for GST		--End
	
	SELECT lvlty,lvlnm,lvltid,B.QryID,RepLvlID,RepQry 
	FROM USQRY B INNER JOIN USRLV C ON (B.QRYID=C.QRYID)
	INNER JOIN USLTY A ON A.LVLTID=C.LVLID
	WHERE B.REPID=@REPID ORDER BY B.REPLVLID

	OPEN CUR_REPLEVEL

	FETCH NEXT FROM CUR_REPLEVEL INTO @lvlty,@lvlnm,@lvltid,@qryid,@replvlid,@repqry

	WHILE @@FETCH_STATUS=0
	BEGIN

		SELECT @GENSCRIPT = @GENSCRIPT + ' ' + '\n'	

		SELECT @GENSCRIPT = @GENSCRIPT + ' ' + 'Select @LvlId=MAX(lvltid)+1 from uslty'+ '\n'
		SELECT @GENSCRIPT = @GENSCRIPT + ' ' + 'If Not Exists(Select Top 1 LvlNm From uslty Where lvlnm='+char(39)+@lvlnm+char(39)+')'+ '\n'
		SELECT @GENSCRIPT = @GENSCRIPT + ' ' + 'Begin'+ '\n'
		SELECT @GENSCRIPT = @GENSCRIPT + ' ' + '\t' +'INSERT INTO uslty([lvlty], [lvlnm], [lvltid]) '+ '\n'
		SELECT @GENSCRIPT = @GENSCRIPT + ' ' + '\t' +'VALUES ('+char(39)+@lvlty+char(39)+', '+char(39)+@lvlnm+char(39)+', @LvlId)'+ '\n'
		SELECT @GENSCRIPT = @GENSCRIPT + ' ' + 'End'+ '\n'

		SELECT @GENSCRIPT = @GENSCRIPT + ' ' + '\n'

		SELECT @GENSCRIPT = @GENSCRIPT + ' ' + 'Select @QryId =MAX(qryid)+1 from usqry'+ '\n'
		--SELECT @GENSCRIPT = @GENSCRIPT + ' ' + 'If Not Exists(Select Top 1 QryId From usqry where RepId =(Select Top 1 RepID from Usrep where repnm='+char(39)+@REPNM+char(39)+' ) and replvlid=@LvlId)'+ '\n'	--Commented by Shrikant S. on 10/06/2017 for GST
		SELECT @GENSCRIPT = @GENSCRIPT + ' ' + 'If Not Exists(Select Top 1 QryId From usqry where RepId =(Select Top 1 RepID from Usrep where repnm='+char(39)+@REPNM+char(39)+' ) and replvlid='+Convert(varchar(50),@replvlid)+')'+ '\n'		--Added by Shrikant S. on 10/06/2017 for GST
		SELECT @GENSCRIPT = @GENSCRIPT + ' ' + 'Begin'+ '\n'
		SELECT @GENSCRIPT = @GENSCRIPT + ' ' + '\t' +'INSERT INTO usqry([QryID], [RepID], [RepLvlID], [RepQry]) '+ '\n'
		SELECT @GENSCRIPT = @GENSCRIPT + ' ' + '\t' +'VALUES (@QryId,@RepId, '+Convert(varchar(50),@replvlid)+', '+CHAR(39)+replace(@repqry,'''','''''')+CHAR(39)+')'+ '\n'
		SELECT @GENSCRIPT = @GENSCRIPT + ' ' + 'end'+ '\n'

		SELECT @GENSCRIPT = @GENSCRIPT + ' ' + '\n'

		
		--SELECT @PryCl=PryCl, @SecCl=SecCl From usrlv Where QryID=(Select top 1 QryID From usqry Where RepID=(Select Top 1 RepID from Usrep where repnm=@REPNM) and replvlid=@LvltId) and lvlid=@LvltId		--Commented by Shrikant S. on 10/06/2017 for GST	
		SELECT @PryCl=PryCl, @SecCl=SecCl From usrlv Where QryID=(Select top 1 QryID From usqry Where RepID=(Select Top 1 RepID from Usrep where repnm=@REPNM) and replvlid=@replvlid) and lvlid=@LvltId		--Added by Shrikant S. on 10/06/2017 for GST		

		
		SELECT @GENSCRIPT = @GENSCRIPT + ' ' + 'If not Exists (Select top 1 QryId From usrlv Where QryID=(Select top 1 QryID From usqry Where RepID=(Select Top 1 RepID from Usrep where repnm='+CHAR(39)+@REPNM+CHAR(39)+') and replvlid=@LvlId) and lvlid=@LvlId)'+ '\n'
		SELECT @GENSCRIPT = @GENSCRIPT + ' ' + 'Begin'+ '\n'
		

		
		SELECT @GENSCRIPT = @GENSCRIPT + ' ' + '\t' +'INSERT INTO usrlv([LvlID], [QryID], [LvlTyp], [PryCl], [SecCl]) '+ '\n'
		SELECT @GENSCRIPT = @GENSCRIPT + ' ' + '\t' +'VALUES (@LvlId, @QryId, @LvlId, '+char(39)+@PryCl+char(39)+', '+char(39)+@SecCl+char(39)+')'+ '\n'
		
		SELECT @GENSCRIPT = @GENSCRIPT + ' ' + 'End'+ '\n'
		

		
		SELECT @GENSCRIPT = @GENSCRIPT + ' ' + '\n'

		SELECT @GENSCRIPT = @GENSCRIPT + ' ' + 'If Not Exists (Select Top 1 repid From uscrl Where RepID=(Select Top 1 RepID from Usrep where repnm='+CHAR(39)+@REPNM+CHAR(39)+' ) and Replvlid=@LvlId)'+ '\n'
		SELECT @GENSCRIPT = @GENSCRIPT + ' ' + 'Begin'+ '\n'

		
	
		
		DECLARE CUR_COLDETAILS CURSOR FOR
		SELECT  A.ColID,ColumnNames,ColumnCaption,ColumnDataType,ColumnOrder,[Precision], GroupOrder,IsGrouped,
				IsFreezing,IsSummury,IsDisplayed,QryID, RepLvlID,ColWidth
		FROM USCRL A
			INNER JOIN USCOL B ON A.COLID=B.COLID
			--WHERE A.REPID=@REPID AND A.REPLVLID=@LVLTID			--Commented by Shrikant S. on 10/06/2017 for GST
			WHERE A.REPID=@REPID AND A.REPLVLID=@replvlid				--Added by Shrikant S. on 10/06/2017 for GST
			ORDER BY A.COLID

		OPEN CUR_COLDETAILS

		FETCH NEXT FROM CUR_COLDETAILS INTO @ColID,@ColumnNames,@ColumnCaption,@ColumnDataType,@ColumnOrder,@Precision,
			@GroupOrder,@IsGrouped,@IsFreezing,@IsSummury,@IsDisplayed,@QryID,@RepLvlID,@ColWidth
		WHILE @@FETCH_STATUS=0
		BEGIN

			SELECT @GENSCRIPT = @GENSCRIPT + ' ' + '\n'

			SELECT @GENSCRIPT = @GENSCRIPT + ' ' + '\t' +'\t' +'select @colId=MAX(colid)+1 From Uscol'+ '\n'
			SELECT @GENSCRIPT = @GENSCRIPT + ' ' + '\t' +'\t' +'INSERT INTO uscol([ColID], [ColumnNames], [ColumnCaption], [ColumnDataType], [ColumnOrder], [Precision]) '+ '\n'
			SELECT @GENSCRIPT = @GENSCRIPT + ' ' + '\t' +'\t' +'\t' +'VALUES (@colId, '+CHAR(39)+@ColumnNames+CHAR(39)+','+CHAR(39)+ @ColumnCaption+CHAR(39)+','+CHAR(39)+ @ColumnDataType+CHAR(39)+','+CHAR(39)+ @ColumnOrder+CHAR(39)+','+CHAR(39)+ @Precision+CHAR(39)+')'+ '\n'

			SELECT @GENSCRIPT = @GENSCRIPT + ' ' + '\t' +'\t' +'INSERT INTO uscrl([ColID], [QryID], [RepID], [RepLvlID], [IsGrouped], [IsFreezing], [ColWidth], [IsSummury], [IsDisplayed], [GroupOrder]) '+ '\n'
			SELECT @GENSCRIPT = @GENSCRIPT + ' ' + '\t' +'\t' +'\t' +'VALUES (@colId, @QryId, @RepId, @LvlId, '+CAST(@IsGrouped AS VARCHAR)+','+CAST(@IsFreezing AS VARCHAR)+','+CAST(@ColWidth AS VARCHAR)+','+CAST(@IsSummury AS VARCHAR)+','+CAST(@IsDisplayed AS VARCHAR)+','+CAST(@GroupOrder AS VARCHAR)+')'+ '\n'

			FETCH NEXT FROM CUR_COLDETAILS INTO @ColID,@ColumnNames,@ColumnCaption,@ColumnDataType,@ColumnOrder,@Precision,@GroupOrder,
				@IsGrouped,@IsFreezing,@IsSummury,@IsDisplayed,@QryID,@RepLvlID,@ColWidth
		END
		CLOSE CUR_COLDETAILS
		DEALLOCATE CUR_COLDETAILS
		
		SELECT @GENSCRIPT = @GENSCRIPT + ' ' + 'End'+ '\n'

		FETCH NEXT FROM CUR_REPLEVEL INTO @lvlty,@lvlnm,@lvltid,@qryid,@replvlid,@repqry
	END
	CLOSE CUR_REPLEVEL
	DEALLOCATE CUR_REPLEVEL
	---- Defining Levels ---- End	


	SELECT @GENSCRIPT = @GENSCRIPT + ' ' + '\n'

	---- Defining Parameter Query Master ---- Start
	SELECT @GENSCRIPT1 = @GENSCRIPT1 + ' ' + 'If Not Exists (Select top 1 Repid From para_query_master Where repId=(Select Top 1 RepID from Usrep where repnm='+CHAR(39)+@REPNM+CHAR(39)+'))'+ '\n'
	SELECT @GENSCRIPT1 = @GENSCRIPT1 + ' ' + 'Begin'+ '\n'
	SELECT @GENSCRIPT1 = @GENSCRIPT1 + ' ' + '\t' +'Declare @QryId1 Int,@ParameterID Int'+ '\n'

--	print @GENSCRIPT1


	
	--SP_COLUMNS PARA_QUERY_MASTER
	DECLARE @PARAMETERID INT, @PARAMNAME VARCHAR(100), @QUERYID INT, @PARAMVALUE VARCHAR(MAX),@PARA_ORDER INT, @DISPLAYORDER INT, @PARACAPTION VARCHAR(256), @ISQUERY BIT, @REP_QRY VARCHAR(5050), @PARAMTYPE INT, @SEARCHFLDS VARCHAR(250)

	DECLARE CUR_PARAMASTER CURSOR FOR
	SELECT A.PARAMETERID, A.PARAMNAME, A.PARACAPTION, A.QUERYID, A.ISQUERY, A.PARAMTYPE, A.SEARCHFLDS, ParamValue, Para_order, DISPLAYORDER
	FROM PARA_MASTER A
		INNER JOIN PARA_QUERY_MASTER B ON A.PARAMETERID=B.PARAMETERID
	WHERE B.REPID=@REPID
	ORDER BY PARA_ORDER,A.PARAMETERID	

	OPEN CUR_PARAMASTER

	FETCH NEXT FROM CUR_PARAMASTER INTO @PARAMETERID, @PARAMNAME, @PARACAPTION, @QUERYID, @ISQUERY, @PARAMTYPE, @SEARCHFLDS, @ParamValue, @Para_order, @DISPLAYORDER

	WHILE @@FETCH_STATUS=0
	BEGIN
		PRINT 'A'

--		SELECT @GENSCRIPT = @GENSCRIPT + CAST(' ' AS VARCHAR(1000))

		SELECT @GENSCRIPT1 = @GENSCRIPT1 + ' ' + '\n'
	
		SELECT @GENSCRIPT1 = @GENSCRIPT1 + ' ' + '\t' +'\t' +'If Not Exists(Select top 1 ParameterId from Para_master where ParamName='+CHAR(39)+@PARAMNAME+CHAR(39)+')'+ '\n'
		SELECT @GENSCRIPT1 = @GENSCRIPT1 + ' ' + '\t' +'\t' +'Begin'+ '\n'
		SELECT @GENSCRIPT1 = @GENSCRIPT1 + ' ' + '\t' +'\t' +'\t' +'Select @ParameterId = Max(ParameterId)+1 from Para_Master'+ '\n'
	
		PRINT @GENSCRIPT1
	
--		PRINT LEN(@GENSCRIPT1)

--		PRINT 'B'
		IF @QUERYID>0
		BEGIN
			SELECT @REP_QRY=REPQRY FROM USQRY WHERE QRYID=@QUERYID
			
			SELECT @GENSCRIPT1 = @GENSCRIPT1 + ' ' + '\t' +'\t' +'\t' +'If Not Exists(Select top 1 QryId from UsQry where RepQry='+CHAR(39)+LTRIM(RTRIM(@REP_QRY))+CHAR(39)+')'+'\n'

--			PRINT @GENSCRIPT1
--			PRINT 'B.1'

			SELECT @GENSCRIPT1 = @GENSCRIPT1 + ' ' + '\t' +'\t' +'\t' +'Begin'+ '\n'

--			PRINT @GENSCRIPT1
--			PRINT 'B.2'
			SELECT @GENSCRIPT1 = @GENSCRIPT1 + ' ' + '\t' +'\t' +'\t' +'\t' +'Select @QryId = Max(@QryId)+1 from UsQry'+ '\n'

--			PRINT @GENSCRIPT1
--			PRINT 'B.3'

			SELECT @GENSCRIPT1 = @GENSCRIPT1 + ' ' + '\t' +'\t' +'\t' +'\t' +'INSERT INTO UsQry([QryID], [RepID], [RepLvlID], [RepQry]) '+ '\n'

--			PRINT @GENSCRIPT1
--			PRINT 'B.4'

			SELECT @GENSCRIPT1 = @GENSCRIPT1 + ' ' + '\t' +'\t' +'\t' +'\t' +'VALUES(@QryID, '''', 1, '+CHAR(39)+@REP_QRY+CHAR(39)+') '+ '\n'
			
--			PRINT @GENSCRIPT1
--			PRINT 'C'

			SELECT @GENSCRIPT1 = @GENSCRIPT1 + ' ' + '\t' +'\t' +'\t' +'End'+ '\n'
			SELECT @GENSCRIPT1 = @GENSCRIPT1 + ' ' + '\t' +'\t' +'\t' +'Else'+ '\n'
			SELECT @GENSCRIPT1 = @GENSCRIPT1 + ' ' + '\t' +'\t' +'\t' +'Begin'+ '\n'
			SELECT @GENSCRIPT1 = @GENSCRIPT1 + ' ' + '\t' +'\t' +'\t' +'\t' +'Select @QryId=QryId from UsQry where RepQry='+CHAR(39)+@REP_QRY+CHAR(39)+ '\n'
			SELECT @GENSCRIPT1 = @GENSCRIPT1 + ' ' + '\t' +'\t' +'\t' +'End'+ '\n'
		END
--		PRINT 'D'

--print @GENSCRIPT1

		SELECT @GENSCRIPT1 = @GENSCRIPT1 + ' ' + '\t' +'\t' +'\t' +'INSERT INTO para_master([ParameterID], [ParamName], [ParaCaption], [QueryId], [IsQuery], [ParamType], [searchflds]) '+ '\n'
		SELECT @GENSCRIPT1 = @GENSCRIPT1 + ' ' + '\t' +'\t' +'\t' +'VALUES (@ParameterId, '+CHAR(39)+@PARAMNAME+CHAR(39)+', '+CHAR(39)+@PARACAPTION+CHAR(39)+', @QryId, '+CHAR(39)+CAST(@ISQUERY AS VARCHAR)+CHAR(39)+', '+CHAR(39)+CAST(@PARAMTYPE AS VARCHAR)+CHAR(39)+', '+CHAR(39)+@SEARCHFLDS+CHAR(39)+')'+ '\n'
		SELECT @GENSCRIPT1 = @GENSCRIPT1 + ' ' + '\t' +'\t' +'End'+ '\n'
		SELECT @GENSCRIPT1 = @GENSCRIPT1 + ' ' + '\t' +'\t' +'Else'+ '\n'
		SELECT @GENSCRIPT1 = @GENSCRIPT1 + ' ' + '\t' +'\t' +'Begin'+ '\n'
		SELECT @GENSCRIPT1 = @GENSCRIPT1 + ' ' + '\t' +'\t' +'\t' +'Select @ParameterId=ParameterId, @QryId=QueryId from Para_master where ParamName='+CHAR(39)+@PARAMNAME+CHAR(39)+''+ '\n'
		SELECT @GENSCRIPT1 = @GENSCRIPT1 + ' ' + '\t' +'\t' +'End'+ '\n'
	
--PRINT 'E'

--print @GENSCRIPT1
	
		SELECT @GENSCRIPT1 = @GENSCRIPT1 + ' ' + '\t' +'\t' +'If Not Exists(Select top 1 ParameterId from Para_Query_Master where RepId=(select Repid from usrep where repnm='+CHAR(39)+@REPNM+CHAR(39)+') and ParameterId=(select parameterid from para_master where ParamName='+CHAR(39)+@PARAMNAME+CHAR(39)+') )'+ '\n'
		SELECT @GENSCRIPT1 = @GENSCRIPT1 + ' ' + '\t' +'\t' +'Begin'+ '\n'
		SELECT @GENSCRIPT1 = @GENSCRIPT1 + ' ' + '\t' +'\t' +'\t' +'Insert into Para_Query_Master (ParameterID,QueryId,ParamValue,repid,para_order,DISPLAYORDER) '+ '\n'
		SELECT @GENSCRIPT1 = @GENSCRIPT1 + ' ' + '\t' +'\t' +'\t' +'Values(@ParameterID,@QryId,'+CHAR(39)+@ParamValue+CHAR(39)+',@repid,'+CAST(@para_order AS VARCHAR)+','+CHAR(39)+CAST(Isnull(@DISPLAYORDER,0) AS VARCHAR)+CHAR(39)+') '+ '\n'
		SELECT @GENSCRIPT1 = @GENSCRIPT1 + ' ' + '\t' +'\t' +'End'+ '\n'

--PRINT 'F'

--print @GENSCRIPT1

		FETCH NEXT FROM CUR_PARAMASTER INTO @PARAMETERID, @PARAMNAME, @PARACAPTION, @QueryId, @ISQUERY, @PARAMTYPE, @SEARCHFLDS, @ParamValue, @Para_order, @DISPLAYORDER
	END
	CLOSE CUR_PARAMASTER
	DEALLOCATE CUR_PARAMASTER
	SELECT @GENSCRIPT1 = @GENSCRIPT1 + ' ' + 'End'+ '\n'
	---- Defining Parameter Query Master ---- End

	SELECT @GENSCRIPT + @GENSCRIPT1

END
GO
