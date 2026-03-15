---
applyTo: 'InfoportOneAdmin.Front/src/app/modules/**/components/**/*-list/**/*.ts,InfoportOneAdmin.Front/src/app/modules/**/components/**/*-grid/**/*.ts,InfoportOneAdmin.Front/src/app/modules/**/services/**/*.ts'
---

# Helix6 Front: Especificacion para Grid Server-Side

## Objetivo

Estas instrucciones definen como implementar nuevas grids en modo servidor en el front de Helix6,
tomando como referencia funcional la grid de organizaciones y los ajustes realizados durante su estabilizacion.

La implementacion debe evitar regresiones conocidas en:

- Filtros
- Configurador de columnas y configuraciones de grid
- Exportacion a Excel
- Ordenacion y reordenacion de columnas
- Flujos de baja logica (DeleteUndeleteLogic)

## Regla principal de referencia

Antes de cerrar una implementacion de grid server-side, comparar el comportamiento con el patron de SintraportV4.Front.
Si hay discrepancias en filtros, llamada al backend o payload de estado, prevalece el patron validado de SintraportV4.Front.

## Arquitectura base obligatoria

1. El componente de grid debe usar `mode: 'server-side'`.
2. El `State` completo de Kendo debe enviarse al backend sin transformaciones destructivas.
3. El servicio debe encapsular el payload con la forma esperada por el cliente generado:
	- Si llega `state` plano, enviar `{ data: state }`.
	- Si ya llega envuelto, respetar la forma existente.
4. En respuestas de backend, normalizar estructuras heterogeneas:
	- datos: `list || items || data || []`
	- total: `count || totalCount || total || 0`
5. Mapear propiedades `camelCase` y `PascalCase` para robustez en grids reutilizables.

## Filtros: requisitos no negociables

### Filtro por defecto de baja logica

Debe existir en el estado inicial de la grid:

- campo: `AuditDeletionDate`
- operador: `isnull`
- valor: `null`

Sin este filtro, el listado no respeta el comportamiento esperado en entidades con baja logica.

### Filtro de fecha con formato espanol

Las columnas de fecha (incluida `AuditDeletionDate`) deben definir:

- `filter: 'date'`
- formato visual `dd/MM/yyyy`
- editor de tipo fecha

### DataStateChange obligatorio

Cada cambio de filtros/orden/paginacion debe disparar llamada al backend.

Regla:

- Implementar `onDataStateChange(state)`
- Actualizar `this.state`
- Invocar `loadData(state)`

No se acepta grid con filtros de UI que no provoquen refresco remoto.

## Columnas: reglas de UX y comportamiento

1. Todas las columnas visibles por defecto deben permitir:
	- ordenacion (`sortable: true`)
	- reordenacion de columnas (config global `reorderable: true`)
2. La columna de `AuditDeletionDate` no debe quedar oculta por error de configuracion.
3. El componente de columnas (mostrar/ocultar) debe actualizar el array real de columnas de la grid y forzar deteccion de cambios.

## Toolbar y acciones

### Refresco

El boton de refresco personalizado debe ejecutar la misma carga server-side usando el estado actual.
Este comportamiento ya esta validado y no debe alterarse.

### Configuraciones de grid

La persistencia de configuraciones de usuario debe conectarse mediante endpoints de configurador de grid.
Verificar que:

- crear/actualizar/eliminar configuracion funciona
- recuperar configuraciones de usuario funciona
- la configuracion aplicada impacta columnas/filtros/orden sin romper el flujo de backend

## Exportacion a Excel

Error historico detectado: se generaba el archivo sin datos.

Reglas para evitarlo:

1. La exportacion debe usar endpoint remoto que devuelva datos reales.
2. Debe mapear el resultado de backend igual que la grid visual (mismo normalizador de datos).
3. No dar por valida la funcionalidad solo porque descarga un `.xlsx`; validar tambien contenido.

## Baja logica (DeleteUndeleteLogic)

Para entidades con baja logica, la grid debe incluir accion explicita para alta/baja.

Patron obligatorio:

1. Accion de papelera al final (menu de acciones por fila).
2. Invocacion a `DeleteUndeleteLogicById`.
3. Mostrar accion de baja o alta segun `AuditDeletionDate`:
	- si `null`: mostrar desactivar
	- si tiene valor: mostrar reactivar
4. Al completar accion:
	- mostrar mensaje de exito
	- recargar grid con el estado actual

## Criterios de aceptacion funcional (DoD minimo)

Una grid server-side se considera completada solo si cumple TODO:

1. Carga inicial llama backend con estado de Kendo.
2. Filtro por defecto de `AuditDeletionDate is null` aplicado en primera carga.
3. Cambiar cualquier filtro dispara nueva llamada remota.
4. Filtro de fecha visualizado en formato `dd/MM/yyyy`.
5. Boton refrescar vuelve a pedir datos sin perder estado.
6. Configurador de columnas funciona (mostrar/ocultar y persistencia).
7. Configurador de grid de usuario funciona extremo a extremo.
8. Exportacion Excel descarga archivo con filas reales.
9. Todas las columnas base soportan ordenacion.
10. Reordenacion de columnas habilitada.
11. Si aplica baja logica: acciones de alta/baja operativas con `DeleteUndeleteLogicById`.
12. Pruebas unitarias minimas para:
	- transformacion de payload de consulta
	- mapeo de respuesta
	- construccion de estado inicial con filtro por defecto
	- comportamiento de exportacion

## Checklist de comparacion obligatoria con SintraportV4.Front

Antes de cerrar PR, validar paridad en:

1. Forma del payload de consulta (`State` completo).
2. Momento de llamada backend al cambiar filtros/orden/pagina.
3. Ubicacion/flujo de acciones de toolbar (filtros, columnas, refresco, excel, configuraciones).
4. Estrategia de mapeo de respuesta (soporte camelCase/PascalCase).

Si hay duda funcional, replicar el patron de SintraportV4.Front y documentar la razon del cambio.

## Nota de implementacion

Para futuras grids, reutilizar helpers de normalizacion de datos/estado para evitar duplicidad y errores ya corregidos en organizaciones.

