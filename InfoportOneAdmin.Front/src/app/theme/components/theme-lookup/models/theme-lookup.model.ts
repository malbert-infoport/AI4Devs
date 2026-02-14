import { TemplateRef } from '@angular/core';
import {
  ClExcelExport,
  ClFilterableSettings,
  ClGridActionsMenuConfig,
  ClGridColumn,
  ClGridConfig,
  ClGridHistoricalValuesConfig,
  ClGridState,
  ClGroupableSettings,
  ClPageableSettings,
  ClSelectableSettings,
  ClSortableSettings,
  IClGridConfiguratorEndpoints,
  IClGridHighlightConfig,
  IClGridToolbarTemplates
} from '@cl/common-library/cl-grid';

import { ColumnMenuSettings, RowArgs, RowClassArgs } from '@progress/kendo-angular-grid';
import { State } from '@progress/kendo-data-query';
import { Observable } from 'rxjs';

export class ThemeLookupConfig extends ClGridConfig {
  /**
   * Es el título que se mostrará en el modal,del buscador
   */
  title?: string;
  /**
   * Es el tamaño del modal del buscado
   */
  size?: 'S' | 'M' | 'L' | 'XL' | 'XXL';

  /**
   * Listado de elementos de tipo input que se mostrarán en el buscador
   * Se mostrarán tantos inputs como elementos tenga la lista
   */
  clInputs?: ClInputsSettings[];

  /**
   * Endpoint que se llamará para obtener los datos del grid,del buscador.
   */
  endpoint?: (state: State | ClGridState) => Observable<any>;
  constructor(values?: {
    idGrid: string;
    mode: 'client-side' | 'server-side';
    selectBy: string | ((context: RowArgs) => any);
    columns: ClGridColumn[];
    pageable?: boolean | ClPageableSettings;
    selectable?: ClSelectableSettings;
    sortable?: boolean | ClSortableSettings;
    resizable?: boolean;
    filterable?: boolean | ClFilterableSettings;
    showColumnsConfigurator?: boolean;
    reorderable?: boolean;
    expandTemplate?: TemplateRef<any>;
    noRecordsTemplate?: TemplateRef<any>;
    toolbarTemplates?: IClGridToolbarTemplates;
    columnMenu?: ColumnMenuSettings;
    state?: State;
    actionsMenu?: ClGridActionsMenuConfig;
    selectedItems?: any[];
    hightlightConfig?: IClGridHighlightConfig;
    showHistoricalValues?: ClGridHistoricalValuesConfig;
    groupable?: ClGroupableSettings;
    exportToExcel?: ClExcelExport;
    persistState?: boolean;
    gridConfiguratorEndpoints?: IClGridConfiguratorEndpoints;
    navigable?: boolean;
    footerTemplate?: TemplateRef<any>;
    showRefreshButton?: boolean;
    fitHeightToContent?: boolean;
    rowClassCallback?: (context: RowClassArgs) => any;
    title?: string;
    size?: 'S' | 'M' | 'L' | 'XL' | 'XXL';
    clInputs?: ClInputsSettings[];
    endpoint?: (state: State | ClGridState) => Observable<any>;
  }) {
    super(values);
    this.title = values.title;
    this.size = values.size;
    this.clInputs = values.clInputs;
    this.endpoint = values.endpoint;
  }
}

export class ClInputsSettings {
  /**
   * Título del input
   */
  label: string;
  /**
   * operator (FilterOperator (Kendo)): Operador que se va a querer aplicar para el filtrado.
   */
  operator: 'eq' | 'neq' | 'contains' | 'doesnotcontain' | 'startswith' | 'endswith';
  /**
   * Campo sobre el que se quiere hacer el filtrado.
   * Si la columna contiene una plantilla será la concatenación del campo 'field' de la columna y el campo 'filterField' de la plantilla, como en el ejemplo.
   */
  fieldName: string;
}
