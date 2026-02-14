

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