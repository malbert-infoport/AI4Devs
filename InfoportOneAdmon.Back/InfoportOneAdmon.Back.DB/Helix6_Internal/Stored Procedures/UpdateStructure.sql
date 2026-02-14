

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