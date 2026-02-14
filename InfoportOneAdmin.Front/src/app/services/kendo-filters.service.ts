import { Injectable } from '@angular/core';
import { KendoDataFilter, KendoFilter, KendoGridFilter } from '@restApi/api/apiClients';

@Injectable({
  providedIn: 'root'
})
export class KendoFiltersService {
  clLookUpFilter(field: string, value: string): KendoGridFilter {
    const filter = new KendoFilter({
      filters: [
        new KendoFilter({
          field,
          operator: 'contains',
          value
        })
      ],
      logic: 'and'
    });
    return new KendoGridFilter({ data: new KendoDataFilter({ filter: filter }) });
  }

  clLookUpOrFilter(field1: string, field2: string, value: string): KendoGridFilter {
    const filter = new KendoFilter({
      filters: [
        new KendoFilter({
          field: field1,
          operator: 'contains',
          value
        }),
        new KendoFilter({
          field: field2,
          operator: 'contains',
          value
        })
      ],
      logic: 'or'
    });
    return new KendoGridFilter({ data: new KendoDataFilter({ filter: filter }) });
  }

  /**
   *
   * @param searchField Campo de búsqueda, por ejemplo, 'matricula'
   * @param searchValue  Valor de buscar en el campo de búsqueda, por ejemplo, '6783FKX'
   * @param idField Campo de búsqueda por id, por ejemplo: 'TipoVehiculoId'
   * @param idValue  Valor del id para filtrar
   * @returns new KendoGridFilter()
   */
  clLookUpFilterById(searchField: string, searchValue: string, idField: string, idValue: number): KendoGridFilter {
    const filter = new KendoFilter({
      filters: [
        new KendoFilter({
          field: searchField,
          operator: 'contains',
          value: searchValue
        }),
        new KendoFilter({
          field: idField,
          operator: 'eq',
          value: idValue
        })
      ],
      logic: 'and'
    });
    return new KendoGridFilter({ data: new KendoDataFilter({ filter: filter }) });
  }

  clLookUpKendoFilter(
    conditions: { field?: string; operator?: string; value?: any; logic?: string; filters?: any[] }[] = []
  ): KendoGridFilter {
    const createFilter = (condition: { field?: string; operator?: string; value?: any; logic?: string; filters?: any[] }) => {
      if (condition.filters) {
        return new KendoFilter({
          filters: condition.filters.map(createFilter),
          logic: condition.logic
        });
      } else {
        return new KendoFilter({
          field: condition.field,
          operator: condition.operator,
          value: condition.value
        });
      }
    };

    const filters = conditions.map(createFilter);

    const filter = new KendoFilter({
      filters: filters,
      logic: 'and'
    });

    return new KendoGridFilter({ data: new KendoDataFilter({ filter: filter }) });
  }
}
