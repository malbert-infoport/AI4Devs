## Instrucciones de Uso

### 1. Preparación

Contexto importante antes de realizar cualquier acción: #file:prompt_test_services_logic.md

MODIFICAR: Pegar aquí el código del servicio a testear

```typescript
// Código del servicio
```

MODIFICAR: Pegar aquí las interfaces de los API Clients usados

```typescript
// Ejemplo:
// - EntityClient: getAllKendoFilter, getById, getNewEntity, insert, update, deleteById
// - CatalogClient: getAll
// - OtherClient: specificMethod
```

### 2. Generación

Genera el archivo `[service-name].service.spec.ts` siguiendo esta estructura:

1. Incluir TODOS los imports necesarios
2. Crear spies de TODAS las dependencias
3. Configurar valores de retorno por defecto
4. Implementar tests de:
   - Validadores personalizados
   - Construcción de formularios
   - Manejo de cambios de campos
   - Preparación de datos para submit
   - Operaciones CRUD
   - Carga de entidades
   - Propagación de errores
   - Configuración de grid (si aplica)
   - Control de acceso
   - Búsquedas y filtros
   - Concurrencia (opcional)
5. Usar `done()` callback para tests async
6. Testear TODOS los métodos públicos
7. Verificar conversión de objetos a IDs en submit data
8. Verificar que campos innecesarios se eliminan
9. Definir constantes para valores de test
10. Añadir comentarios en casos complejos

### 3. Validación

- Sin errores de compilación
- Todos los tests deben pasar
- Cobertura completa de métodos públicos
- Manejo correcto de errores
- Código limpio y mantenible

---

## Notas Adicionales

MODIFICAR: Añadir información específica del servicio

- Este servicio tiene validadores: [listar si hay]
- Construye formularios con: [describir estructura]
- Maneja catálogos de: [listar]
- Otras consideraciones: [añadir si es necesario]

/\*
EJEMPLO REAL
\*/

## Instrucciones de Uso

### 1. Preparación

Contexto importante antes de realizar cualquier acción: #file:prompt_test_services_logic.md

Código del servicio a testear

#file:recargos-general-dialog.service.ts
#file:recargos-general-grid.service.ts

### 2. Generación

Genera el archivo `recargos-general-grid.service.spec.ts` y `recargos-general-dialog.service.spec.ts` siguiendo esta estructura:

1. Incluir TODOS los imports necesarios
2. Crear spies de TODAS las dependencias
3. Configurar valores de retorno por defecto
4. Implementar tests de:
   - Validadores personalizados
   - Construcción de formularios
   - Manejo de cambios de campos
   - Preparación de datos para submit
   - Operaciones CRUD
   - Carga de entidades
   - Propagación de errores
   - Configuración de grid (si aplica)
   - Control de acceso
   - Búsquedas y filtros
   - Concurrencia (opcional)
5. Usar `done()` callback para tests async
6. Testear TODOS los métodos públicos
7. Verificar conversión de objetos a IDs en submit data
8. Verificar que campos innecesarios se eliminan
9. Definir constantes para valores de test
10. Añadir comentarios en casos complejos

### 3. Validación

- Sin errores de compilación
- Todos los tests deben pasar
- Cobertura completa de métodos públicos
- Manejo correcto de errores
- Código limpio y mantenible
