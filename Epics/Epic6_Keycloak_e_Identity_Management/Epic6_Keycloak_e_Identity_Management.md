# Épica 6: Integración con Keycloak e Identity Management

## Objetivo de Negocio
Abstraer la complejidad de Keycloak para que administradores gestionen identidad sin acceder directamente a su consola.

## Valor que aporta
- Administradores no necesitan conocer Keycloak
- Registro automático de clientes OAuth2 en Keycloak
- Configuración automática de Protocol Mappers para claims personalizados
- SSO funcional en todo el ecosistema sin configuración manual

## Criterios de aceptación de la épica
- Registro automático de aplicaciones en Keycloak via Admin API funcional
- Configuración de claim `c_ids` como atributo multivalor operativa
- Sincronización CREATE/UPDATE de usuarios sin intervención manual
- PKCE para SPAs y ClientCredentials para APIs correctamente configurados
