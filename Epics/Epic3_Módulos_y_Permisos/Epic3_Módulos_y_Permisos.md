# Épica 3: Configuración de Módulos y Permisos de Acceso

## Objetivo de Negocio
Permitir configuración granular de qué organizaciones tienen acceso a qué módulos funcionales de cada aplicación.

## Valor que aporta
- Modelo de negocio flexible (venta por módulos, no por aplicación completa)
- Control preciso de funcionalidades por cliente
- Sincronización automática de permisos a aplicaciones satélite
- Facilita ventas incrementales (activar módulos adicionales sin redeployment)

## Criterios de aceptación de la épica
- Matriz de permisos organización-módulo completamente funcional
- Asignación masiva y granular de accesos operativa
- Sincronización de permisos mediante OrganizationEvent validada
- Aplicaciones satélite respetan permisos sin consultas adicionales
