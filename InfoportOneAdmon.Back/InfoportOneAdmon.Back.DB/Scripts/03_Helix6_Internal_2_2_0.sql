/*
Helix 6 - Internal - 2.2.0
*/
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
SET XACT_ABORT ON
GO
SET TRANSACTION ISOLATION LEVEL Serializable
GO
BEGIN TRANSACTION
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating schemas'
GO
CREATE SCHEMA [Helix6_Internal]
AUTHORIZATION [dbo]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [Helix6_Internal].[UpdateFieldDescription]'
GO


CREATE PROCEDURE [Helix6_Internal].[UpdateFieldDescription]
	@p_esquema AS NVARCHAR(1000),
	@p_tabla AS NVARCHAR(1000),
	@p_columna AS NVARCHAR(1000),
	@p_descripcion as NVARCHAR(4000)
AS
BEGIN

SET NOCOUNT ON;

	DECLARE @existeMetadato INT
	SELECT @existeMetadato = COUNT(*)
	FROM sys.extended_properties INNER JOIN
	(SELECT TABLAS.object_id AS tabla_id, COLUMNAS.column_id as columna_id
	FROM            INFORMATION_SCHEMA.COLUMNS AS CAMPOS INNER JOIN
								sys.tables AS TABLAS ON TABLAS.name = CAMPOS.TABLE_NAME INNER JOIN
								sys.columns AS COLUMNAS ON TABLAS.object_id = COLUMNAS.object_id AND COLUMNAS.name = CAMPOS.COLUMN_NAME
	WHERE CAMPOS.TABLE_SCHEMA = @p_esquema AND TABLAS.name = @p_tabla AND CAMPOS.COLUMN_NAME = @p_columna) AS identificadores ON sys.extended_properties.major_id = identificadores.tabla_id and sys.extended_properties.minor_id = identificadores.columna_id

	IF (@existeMetadato = 0)
		EXEC sp_addextendedproperty   
				@name = N'MS_Description'  
				,@value = @p_descripcion 
				,@level0type = N'Schema', @level0name = @p_esquema  
				,@level1type = N'Table',  @level1name = @p_tabla  
				,@level2type = N'Column', @level2name = @p_columna;  
	ELSE
		EXEC sp_updateextendedproperty   
				@name = N'MS_Description'  
				,@value = @p_descripcion
				,@level0type = N'Schema', @level0name = @p_esquema 
				,@level1type = N'Table',  @level1name = @p_tabla  
				,@level2type = N'Column', @level2name = @p_columna;  

END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [Helix6_Internal].[UpdateStructure]'
GO


CREATE PROCEDURE [Helix6_Internal].[UpdateStructure]
AS
BEGIN

SET NOCOUNT ON;

BEGIN TRANSACTION
	
	DECLARE @TABLA VARCHAR(1000)
	DECLARE @ESQUEMA VARCHAR(1000)
	DECLARE @CONSULTASQL varchar(4000)
	
	-- REVISAMOS LAS ENTIDADES PARA COMPLETAR SUS CAMPOS SI SE REQUIERE
	DECLARE CURSOR_TABLAS CURSOR FOR
	SELECT TABLE_NAME, TABLE_SCHEMA FROM INFORMATION_SCHEMA.TABLES 
	WHERE table_type='BASE TABLE'  and TABLE_SCHEMA <> 'Helix6_Internal' and TABLE_SCHEMA <> 'dbo'
	ORDER BY table_name;
    
    OPEN CURSOR_TABLAS 
	FETCH NEXT FROM CURSOR_TABLAS INTO @TABLA, @ESQUEMA

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF (NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = @ESQUEMA AND TABLE_NAME = @TABLA AND COLUMN_NAME = 'AuditCreationUser'))
		BEGIN
			SET @CONSULTASQL = 'ALTER TABLE ' + @ESQUEMA + '.' + @TABLA + ' add AuditCreationUser varchar(70) null'
			EXEC (@CONSULTASQL)
		END
		IF (NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = @ESQUEMA AND TABLE_NAME = @TABLA AND COLUMN_NAME = 'AuditModificationUser'))
		BEGIN
			SET @CONSULTASQL = 'ALTER TABLE ' + @ESQUEMA + '.' + @TABLA + ' add AuditModificationUser varchar(70) null'
			EXEC (@CONSULTASQL)
		END
		IF (NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = @ESQUEMA AND TABLE_NAME = @TABLA AND COLUMN_NAME = 'AuditCreationDate'))
		BEGIN
			SET @CONSULTASQL = 'ALTER TABLE ' + @ESQUEMA + '.' + @TABLA + ' add AuditCreationDate datetime null'
			EXEC (@CONSULTASQL)
		END
		IF (NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = @ESQUEMA AND TABLE_NAME = @TABLA AND COLUMN_NAME = 'AuditModificationDate'))
		BEGIN
			SET @CONSULTASQL = 'ALTER TABLE ' + @ESQUEMA + '.' + @TABLA + ' add AuditModificationDate datetime null'
			EXEC (@CONSULTASQL)
		END
		IF (NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = @ESQUEMA AND TABLE_NAME = @TABLA AND COLUMN_NAME = 'AuditDeletionDate'))
		BEGIN
			SET @CONSULTASQL = 'ALTER TABLE ' + @ESQUEMA + '.' + @TABLA + ' add AuditDeletionDate datetime null'
			EXEC (@CONSULTASQL)
		END

		-- Actualización de los metadatos de los campos genéricos de ID y campos de miniauditoria
		EXEC Helix6_Internal.[UpdateFieldDescription] @ESQUEMA, @TABLA, 'Id', 'ID#Table identifier';
		EXEC Helix6_Internal.[UpdateFieldDescription] @ESQUEMA, @TABLA, 'AuditCreationUser', 'Audit - Creation User#Registry creation user';
		EXEC Helix6_Internal.[UpdateFieldDescription] @ESQUEMA, @TABLA, 'AuditModificationUser', 'Audit - Modification User#Registry modification User';
		EXEC Helix6_Internal.[UpdateFieldDescription] @ESQUEMA, @TABLA, 'AuditCreationDate', 'Audit - Creation Date#Registry creation date';
		EXEC Helix6_Internal.[UpdateFieldDescription] @ESQUEMA, @TABLA, 'AuditModificationDate', 'Audit - Modification Date#Last registry modification date';
		EXEC Helix6_Internal.[UpdateFieldDescription] @ESQUEMA, @TABLA, 'AuditDeletionDate', 'Audit - Deletion Date#Logic registry deletion date';
		
		-- Recorremos los campos de la tabla para cambiar el nombre del campo si no empieza por mayúscula
		DECLARE @COLUMNA VARCHAR(1000)
		DECLARE CURSOR_COLUMNAS CURSOR FOR
		SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @TABLA AND TABLE_SCHEMA = @ESQUEMA;
    
		OPEN CURSOR_COLUMNAS 
		FETCH NEXT FROM CURSOR_COLUMNAS INTO @COLUMNA

		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			IF (LEFT(@COLUMNA,1) = LOWER(LEFT(@COLUMNA,1)))
			BEGIN

				DECLARE @NUEVONOMBRE VARCHAR(1000)
				SET @NUEVONOMBRE = UPPER(LEFT(@COLUMNA,1)) + RIGHT(@COLUMNA,LEN(@COLUMNA)-1)
				SET @COLUMNA = @ESQUEMA + '.' + @TABLA + '.' + @COLUMNA
				EXEC sp_RENAME @COLUMNA, @NUEVONOMBRE, 'COLUMN'
			END


		FETCH NEXT FROM CURSOR_COLUMNAS INTO @COLUMNA
		END
		-- Cierre y liberación del cursor
		CLOSE CURSOR_COLUMNAS
		DEALLOCATE CURSOR_COLUMNAS

	FETCH NEXT FROM CURSOR_TABLAS INTO @TABLA, @ESQUEMA
	END
	-- Cierre y liberación del cursor
	CLOSE CURSOR_TABLAS
	DEALLOCATE CURSOR_TABLAS

	
IF @@ERROR <> 0
BEGIN
    ROLLBACK TRANSACTION
    RETURN -1
END

COMMIT TRANSACTION

END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
COMMIT TRANSACTION
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
DECLARE @Success AS BIT
SET @Success = 1
SET NOEXEC OFF
IF (@Success = 1) PRINT 'The database update succeeded'
ELSE BEGIN
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	PRINT 'The database update failed'
END
GO
