# Épica 5: Sincronización y Consolidación de Usuarios Multi-Organización

## Objetivo de Negocio
Gestionar usuarios que trabajan para múltiples organizaciones clientes, consolidando su identidad y permisos.

## Valor que aporta
- Usuarios acceden a datos de todas sus organizaciones con un solo login (SSO real)
- Consolidación automática de roles de múltiples aplicaciones
- Optimización de experiencia de usuario (consultores, auditores, multi-empresa)
- Reducción de cuentas duplicadas y confusión de identidades

## Criterios de aceptación de la épica
- Detección automática de usuarios duplicados por email funcionando
- Claim `c_ids` con todas las organizaciones del usuario en token JWT
- Consolidación de roles multi-aplicación con prefijos únicos
- Sincronización directa con Keycloak sin eventos adicionales
