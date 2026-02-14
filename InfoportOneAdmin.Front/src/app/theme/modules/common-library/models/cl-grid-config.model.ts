export class ClGridConfiguratorEndpointsRequestMapToHelix {
  id?: number;
  entity?: string; // idGrid
  description?: string; // configurationName
  configuration?: any; // gridPersistedState
  defaultConfiguration?: boolean;
  constructor(values?: {
    id?: number;
    idGrid?: string;
    configurationName?: string;
    gridPersistedState?: any;
    defaultConfiguration?: boolean;
  }) {
    this.id = values?.id ?? 0;
    this.entity = values?.idGrid;
    this.description = values?.configurationName;
    this.configuration = values?.gridPersistedState ? JSON.stringify(values.gridPersistedState) : undefined;
    this.defaultConfiguration = values?.defaultConfiguration === undefined ? false : values.defaultConfiguration;
  }
}
