#### TASK-002-BE: Modificar OrganizationService para soportar edición con validaciones

(Extender UpdateAsync, validar SecurityCompanyId inmutable, auditar GroupChanged solo en AUDIT_LOG simplificada, no publicar OrganizationEvent para cambios básicos.)