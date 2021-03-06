DROP PROCEDURE [Usp_Remove_Non_Standard_column]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [Usp_Remove_Non_Standard_column]
(
	@Table_Name Varchar(30)
) As 
Declare @Column_Name Varchar(30),@SQLString nVarchar(1000)
	,@nPrecision Int,@nScale Int,@Data_Type varchar(20)

SELECT @Column_Name = '',@SQLString = ''

IF Db_NAME() = 'MASTER' OR Db_NAME() = 'MODEL' OR Db_NAME() = 'MSDB' OR Db_NAME() = 'TEMPDB'
BEGIN
	Print 'System Database Are Not Allowed For This Process.'
	Print 'Please Use Valid Database...!'
	Return
END

IF @Table_Name IS NULL OR @Table_Name = ''
BEGIN
	PRINT 'Empty Table Not Allowed...!'
	RETURN 
END

IF OBJECT_ID(@Table_Name) IS NULL OR OBJECT_ID(@Table_Name) = ''
BEGIN
	PRINT 'Please Pass Valid Table ...!'
	RETURN 
END

/* Creating Maintain History Table [Start] */
IF OBJECT_ID('RemoveColumnref') IS NULL OR OBJECT_ID('RemoveColumnref') = ''
BEGIN
	Create Table RemoveColumnref (Table_Name Varchar(20),Column_Name Varchar(20)
	,Type_Name Varchar(20),nPrecision Int,nScale Int)
END
/* Creating Maintain History Table [End] */

/* Define Cursor [Start] */
DECLARE ColumnInfo_Cur CURSOR FOR Select [Name] From sysColumns
	Where id = Object_Id(@Table_Name) AND LEFT([Name],2) = 'U_'
/* Define Cursor [End] */

OPEN ColumnInfo_Cur 
FETCH NEXT FROM ColumnInfo_Cur INTO @Column_Name
WHILE @@FETCH_STATUS = 0
BEGIN
	IF NOT EXISTS (Select Fld_nm,Tbl_nm From LOther Where Fld_nm = @Column_Name AND Tbl_nm = @Table_Name)
	BEGIN
		SET NOCOUNT ON

		/*  Assign Variable For Column Empty or Not [Start] */
		SET @SQLString = 'SELECT DISTINCT CONVERT(Varchar(100),'+RTrim(LTrim(@Column_Name))+') as lColumn '
		SET @SQLString = LTrim(RTrim(@SQLString))+' INTO ##TmpColumndet FROM '+LTrim(RTrim(@Table_Name))
		SET @SQLString = LTrim(RTrim(@SQLString))+' WHERE CONVERT(Varchar(100),'+RTrim(LTrim(@Column_Name))+')<>'''''
		SET @SQLString = LTrim(RTrim(@SQLString))+' AND CONVERT(Varchar(100),'+RTrim(LTrim(@Column_Name))+' ) IS NOT NULL'
		EXEC sp_executesql @SQLString 
		/*  Assign Variable For Column Empty or Not [End] */

		IF @@ROWCOUNT = 0
		BEGIN

			/* Find Datatype and Assign in variable [Start] */
			SELECT @Data_Type = TYPE_NAME(c.user_type_id)
				FROM sys.objects o JOIN sys.columns c
				ON o.object_id = c.object_id WHERE o.[name] = LTrim(RTrim(@Table_Name))
				AND c.[Name] = RTrim(LTrim(@Column_Name))
			/* Find Datatype and Assign in variable [End] */

			/* Find Precision and Assign in variable [Start] */
			SET @nPrecision = Columnproperty(Object_Id(@Table_Name),@Column_Name,'Precision')
			SET @nPrecision = CASE WHEN @nPrecision IS NULL THEN 0 ELSE @nPrecision END
			/* Find Precision and Assign in variable [End] */

			/* Find Scale and Assign in variable [Start] */
			SET @nScale = Columnproperty(Object_Id(@Table_Name),@Column_Name,'Scale')
			SET @nScale = CASE WHEN @nScale IS NULL THEN 0 ELSE @nScale END
			/* Find Scale and Assign in variable [End] */

			/* Maintain History [Start] */
			Insert Into RemoveColumnref (Table_Name,Column_Name,Type_Name,nPrecision,nScale)
				Values(@Table_Name,@Column_Name,@Data_Type,@nPrecision,@nScale)
			/* Maintain History [End] */

			Print @SQLString 

		END
		SET NOCOUNT OFF
		SET @SQLString = 'DROP TABLE ##TmpColumndet'
		EXEC sp_executesql @SQLString  
	END
	FETCH NEXT FROM ColumnInfo_Cur INTO @Column_Name
END

CLOSE ColumnInfo_Cur 
DEALLOCATE ColumnInfo_Cur
GO
