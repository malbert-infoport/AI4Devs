# APL006-T001-FE: Frontend — Gestionar Credenciales OAuth / ClientCredentials

**TICKET ID:** APL006-T001-FE
**EPIC:** Administración de Aplicaciones
**COMPONENT:** Frontend - Angular
**PRIORITY:** Alta
**ESTIMATION:** 1 día

## TÍTULO
Desarrollar `application-credentials` para crear, rotar, eliminar y listar credenciales por aplicación.

## DESCRIPCIÓN
- Interfaz para crear credenciales: backend genera `clientSecret` y lo muestra una sola vez en modal.
- Rotación: botón `Rotate` con confirmación y nueva secret mostrada.
- Copiar secret al portapapeles y enmascaramiento por defecto.
- Mostrar metadatos: createdAt, lastRotatedAt, createdBy.

## CONTRATO BACKEND (NSWAG)
- `ApplicationCredentialClient.getAllByApplicationId(applicationId)`
- `ApplicationCredentialClient.create(applicationId, request)` → retorna `{ clientId, clientSecret }` (secret only once)
- `ApplicationCredentialClient.rotate(credentialId)` → retorna `{ clientSecret }`
- `ApplicationCredentialClient.delete(credentialId)`

## UX
- Modal para mostrar secret único con aviso: "Copia este secreto ahora, no se mostrará de nuevo".
- Botón `Rotate` con confirmación y auditoría.

## CASOS DE BORDE
- Crear credencial y perder secret → instrucción para regenerar (rotate) y revocar anterior.
- Verificar permisos `Application credentials modification`.

## TESTS
- Unit: create/rotate flow and clipboard copy.

## CRITERIOS DE ACEPTACIÓN
- [ ] Crear/rotar/eliminar credenciales funcionando.
- [ ] Secret mostrado solo una vez y copy funcional.

***
