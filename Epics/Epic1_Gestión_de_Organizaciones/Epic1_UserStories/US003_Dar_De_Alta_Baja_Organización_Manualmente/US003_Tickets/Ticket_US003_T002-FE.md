# TASK-002-FE: Implementar UI para alta/baja manual con modal y grid trash

=============================================================
**TICKET ID:** TASK-002-FE  
**EPIC:** Gestión del Portfolio de Organizaciones Clientes  
**USER STORY:** US-003 - Dar de alta / baja organización manualmente  
**COMPONENT:** Frontend - Angular  
**PRIORITY:** Alta  
**ESTIMATION:** 4 horas  
=============================================================

## TÍTULO
Implementar acciones de baja/alta manual con modal de confirmación y una columna fija de papelera en la grid que invoque el endpoint genérico Helix6 `DeleteUndeleteLogicById`.

## DESCRIPCIÓN
Añadir UI para permitir a `SecurityManager` dar de baja o dar de alta una organización usando el mismo endpoint backend genérico. Requisitos:

- En la grid de organizaciones añadir una columna fija a la derecha con un icono de papelera por fila; el icono siempre será visible.
-- Al pulsar la papelera abrir modal de confirmación; tras confirmar, el frontend realizará una petición `DELETE` al endpoint Helix6 `DeleteUndeleteLogicById` pasando `id` como query param (por ejemplo `DELETE /api/Organization/DeleteUndeleteLogicById?id=123`). La operación en backend decidirá si aplica baja o alta según el estado actual.
- En la ficha de organización añadir botones de `Dar de baja` y `Dar de alta` que abran el mismo modal y realicen la misma llamada genérica.

## CONTEXTO TÉCNICO
- **Grid action (papelera)**: columna fija a la derecha con botón que abre `ConfirmDialogComponent`.
- **Permisos**: solo `SecurityManager` verá/ejecutará la acción.
- **Llamada backend**: `DELETE /api/Organization/DeleteUndeleteLogicById?id=<id>` (query param). El frontend debe incluir `X-Correlation-Id` cuando esté disponible y manejar respuestas `403/404/200`.
- **UI handling**: mostrar snackbar con resultado; actualizar grid/ficha tras éxito.

## EJEMPLO DE IMPLEMENTACIÓN (TypeScript)

Service call (ejemplo minimal):

```typescript
// organization.service.ts
toggleDelete(id: number, del: boolean, configurationName?: string): Observable<void> {
    const url = `/api/Organization/DeleteUndeleteLogicById`;
    let params = new HttpParams().set('id', id.toString());
    if (configurationName) params = params.set('configurationName', configurationName);
    const headers = new HttpHeaders({ 'X-Correlation-Id': this.getCorrelationId() || '' });
    return this.http.delete<void>(url, { headers, params });
}
```

Componente grid (simplificado):

```typescript
onTrashClick(row: OrganizationView) {
  const dialogRef = this.dialog.open(ConfirmDialogComponent, { data: { title: row.auditDeletionDate ? 'Dar de alta' : 'Dar de baja', message: '¿Confirmar?' } });
  dialogRef.afterClosed().subscribe(confirmed => {
    if (!confirmed) return;
    this.orgService.toggleDelete(row.id, !row.auditDeletionDate).subscribe({
      next: () => this.loadGrid(),
      error: (err) => this.snackBar.open('Error', 'Cerrar')
    });
  });
}
```

## CRITERIOS DE ACEPTACIÓN TÉCNICOS
- [ ] Columna de papelera visible siempre a la derecha en la grid.
- [ ] Modal de confirmación obligatorio.
- [ ] Llamada al endpoint genérico con payload `{ id, delete }`.
- [ ] UI actualiza estado tras éxito y muestra mensajes.
- [ ] Tests unitarios de visibilidad y comportamiento.
