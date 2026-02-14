import { inject, Injectable, InjectionToken } from '@angular/core';
import { ClGridSavedConfig } from '@cl/common-library/cl-grid';
import { map, Observable } from 'rxjs';

export const GRID_CONFIG_CLIENT = new InjectionToken<ISecurityUserGridConfigurationClient>('GRID_CONFIG_CLIENT');

import {
  ISecurityUserGridConfigurationClient,
  SecurityUserGridConfigurationClient,
  SecurityUserGridConfigurationView
} from '@restApi/api/apiClients';

@Injectable({
  providedIn: 'root'
})
export class GridConfiguratorMapperServiceService {
  private gridConfigClient = inject(SecurityUserGridConfigurationClient);

  getUserGridConfigurations = (idGrid: string): Observable<ClGridSavedConfig[]> => {
    return this.gridConfigClient
      .getUserGridConfigurations(idGrid)
      .pipe(
        map((configs: SecurityUserGridConfigurationView[]) =>
          configs.map((config: SecurityUserGridConfigurationView) => this.mapGridConfigModelToClGridSavedConfig(config))
        )
      );
  };

  create = (dataItem: ClGridSavedConfig): Observable<ClGridSavedConfig> => {
    return this.gridConfigClient
      .insert(this.mapClGridSavedConfigToGridConfigModel(dataItem))
      .pipe(map((config: SecurityUserGridConfigurationView) => this.mapGridConfigModelToClGridSavedConfig(config)));
  };

  update = (dataItem: ClGridSavedConfig): Observable<ClGridSavedConfig> => {
    return this.gridConfigClient
      .update(this.mapClGridSavedConfigToGridConfigModel(dataItem))
      .pipe(map((config: SecurityUserGridConfigurationView) => this.mapGridConfigModelToClGridSavedConfig(config)));
  };

  deleteById = (id: any): Observable<any> => {
    return this.gridConfigClient.deleteById(id);
  };

  private mapClGridSavedConfigToGridConfigModel(dataItem: ClGridSavedConfig): SecurityUserGridConfigurationView {
    return new SecurityUserGridConfigurationView({
      id: dataItem.id ?? 0,
      entity: dataItem.idGrid,
      description: dataItem.configurationName,
      configuration: JSON.stringify(dataItem.gridPersistedState!),
      defaultConfiguration: dataItem.defaultConfiguration
    });
  }

  private mapGridConfigModelToClGridSavedConfig(dataItem: SecurityUserGridConfigurationView): ClGridSavedConfig {
    return new ClGridSavedConfig({
      id: dataItem.id,
      idGrid: dataItem.entity,
      configurationName: dataItem.description,
      gridPersistedState: JSON.parse(dataItem.configuration!),
      defaultConfiguration: dataItem.defaultConfiguration
    });
  }
}
