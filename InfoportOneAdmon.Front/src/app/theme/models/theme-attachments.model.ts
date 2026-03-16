import { KendoGridFilter } from '@restApi/api/apiClients';
import { Observable } from 'rxjs';

export declare type Direction = 'ltr' | 'rtl';

export class ThemeAttachmentsConfiguration {
  endpoints: AttachmentsConfigEndpoints;
  entityId: number;
  idGrid: string;
  dialogConfig?: AtthachmentsDialogConfig;

  constructor(values?: {
    endpoints: AttachmentsConfigEndpoints;
    entityId: number;
    idGrid: string;
    dialogConfig?: AtthachmentsDialogConfig;
  }) {
    this.endpoints = values.endpoints;
    this.entityId = values.entityId;
    this.idGrid = values.idGrid;
    this.dialogConfig = values.dialogConfig || new AtthachmentsDialogConfig({});
  }
}

export interface AttachmentsConfigEndpoints {
  getAll?: (configurationName?: string) => Observable<any>;
  getAttachmentContent?: (id: number) => Observable<any>;
  insert?: (body: any, configurationName?: string) => Observable<any>;
  update?: (body: any, configurationName?: string) => Observable<any>;
  deleteById?: (id: number, configurationName?: string) => Observable<any>;
  getNewAttachmentEntity?: (id: number) => Observable<any>;
  getAllVTAAttachmentsKendoFilter?: (
    id: number,
    configurationName?: string | undefined,
    includeDeleted?: boolean | undefined,
    accept_LanguageHeader?: string | undefined,
    body?: KendoGridFilter | undefined
  ) => Observable<any>;
  getById?: (id, configurationName?: string) => Observable<any>;
}

export class AtthachmentsDialogConfig {
  size?: 'XS' | 'S' | 'M' | 'L' | 'XL' | 'XXL';

  constructor(values?: { width?: number | string; height?: number | string; size?: 'XS' | 'S' | 'M' | 'L' | 'XL' | 'XXL' }) {
    this.size = values?.size || 'M';
  }
}
