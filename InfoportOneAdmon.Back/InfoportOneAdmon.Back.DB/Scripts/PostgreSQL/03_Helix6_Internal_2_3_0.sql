DO $$

BEGIN
	RAISE NOTICE 'Creating schema Helix6_Internal...';

	CREATE SCHEMA IF NOT EXISTS "Helix6_Internal";
		EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Error creating Helix6_Internal: %'
			,SQLERRM;
END $$;

CREATE OR REPLACE PROCEDURE "Helix6_Internal"."UpdateFieldDescription"(
    p_esquema TEXT,
    p_tabla TEXT,
    p_columna TEXT,
    p_descripcion TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    EXECUTE format(
        'COMMENT ON COLUMN %I.%I.%I IS %L',
        p_esquema,
        p_tabla,
        p_columna,
        p_descripcion
    );
END;
$$;

CREATE OR REPLACE PROCEDURE "Helix6_Internal"."UpdateStructure"()
LANGUAGE plpgsql
AS $$
DECLARE
    rec_tabla RECORD;
    rec_columna RECORD;
    nuevo_nombre TEXT;
BEGIN
    FOR rec_tabla IN
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_type = 'BASE TABLE'
          AND table_schema NOT IN ('Helix6_Internal', 'pg_catalog', 'information_schema', 'public')
        ORDER BY table_name
    LOOP
        -- Add columns
        EXECUTE format('ALTER TABLE %I.%I ADD COLUMN IF NOT EXISTS "AuditCreationUser" VARCHAR(70)', rec_tabla.table_schema, rec_tabla.table_name);
        EXECUTE format('ALTER TABLE %I.%I ADD COLUMN IF NOT EXISTS "AuditModificationUser" VARCHAR(70)', rec_tabla.table_schema, rec_tabla.table_name);
        EXECUTE format('ALTER TABLE %I.%I ADD COLUMN IF NOT EXISTS "AuditCreationDate" TIMESTAMPTZ', rec_tabla.table_schema, rec_tabla.table_name);
        EXECUTE format('ALTER TABLE %I.%I ADD COLUMN IF NOT EXISTS "AuditModificationDate" TIMESTAMPTZ', rec_tabla.table_schema, rec_tabla.table_name);
        EXECUTE format('ALTER TABLE %I.%I ADD COLUMN IF NOT EXISTS "AuditDeletionDate" TIMESTAMPTZ', rec_tabla.table_schema, rec_tabla.table_name);

        -- Update comment
        CALL "Helix6_Internal"."UpdateFieldDescription"(rec_tabla.table_schema, rec_tabla.table_name, 'Id', 'ID#Table identifier');
        CALL "Helix6_Internal"."UpdateFieldDescription"(rec_tabla.table_schema, rec_tabla.table_name, 'AuditCreationUser', 'Audit - Creation User#Registry creation user');
        CALL "Helix6_Internal"."UpdateFieldDescription"(rec_tabla.table_schema, rec_tabla.table_name, 'AuditModificationUser', 'Audit - Modification User#Registry modification User');
        CALL "Helix6_Internal"."UpdateFieldDescription"(rec_tabla.table_schema, rec_tabla.table_name, 'AuditCreationDate', 'Audit - Creation Date#Registry creation date');
        CALL "Helix6_Internal"."UpdateFieldDescription"(rec_tabla.table_schema, rec_tabla.table_name, 'AuditModificationDate', 'Audit - Modification Date#Last registry modification date');
        CALL "Helix6_Internal"."UpdateFieldDescription"(rec_tabla.table_schema, rec_tabla.table_name, 'AuditDeletionDate', 'Audit - Deletion Date#Logic registry deletion date');

        -- Capitalize columns
        FOR rec_columna IN
            SELECT column_name
            FROM information_schema.columns
            WHERE table_schema = rec_tabla.table_schema
              AND table_name = rec_tabla.table_name
        LOOP
            IF substring(rec_columna.column_name,1,1) = lower(substring(rec_columna.column_name,1,1)) THEN
                nuevo_nombre := upper(substring(rec_columna.column_name,1,1)) || substring(rec_columna.column_name,2);
                EXECUTE format('ALTER TABLE %I.%I RENAME COLUMN %I TO %I',
                               rec_tabla.table_schema, rec_tabla.table_name,
                               rec_columna.column_name, nuevo_nombre);
            END IF;
        END LOOP;
    END LOOP;
END;
$$;

