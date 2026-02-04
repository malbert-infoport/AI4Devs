# US003 - Listar Grupos con filtros y paginación

Resumen: Implementar listado de grupos usando Kendo Grid y `GetAllKendoFilter` (PUT con objeto KendoFilter) para que Helix6 haga paginación/ordenado/filtrado.

Requisitos:
- Grid con columnas: Id, Name, Description, Nº Organizaciones, Acciones
- Soportar filtros por nombre y estado (alta/baja)

Definición de hecho:
- FE: grid y filtros funcionando
- BE: `GetAllKendoFilter` Helix6 disponible para `OrganizationGroup`
