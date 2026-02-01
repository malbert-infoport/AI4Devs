#### TASK-003-BE: Implementar desactivación manual de organización (baja manual)

(Endpoint POST /organizations/{id}/deactivate, usar DeleteUndeleteLogicById de Helix6, registrar en AUDIT_LOG Action="OrganizationDeactivatedManual" con UserId poblado, no publicar OrganizationEvent desde este endpoint.)