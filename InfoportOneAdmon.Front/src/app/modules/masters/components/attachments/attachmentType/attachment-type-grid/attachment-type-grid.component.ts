import { ChangeDetectorRef, Component, OnInit, inject } from '@angular/core';
import { TranslateModule, TranslateService } from '@ngx-translate/core';

import { GridDataResult } from '@progress/kendo-angular-grid';
import { State } from '@progress/kendo-data-query';

import {
  ClGridConfig,
  ClGridEdition,
  ClPageableSettings,
  ClSelectableSettings,
  ClSortableSettings,
  IClGridConfiguratorEndpoints,
  IClGridEditionEndpoints,
  ClGridComponent,
  ClGridState,
  ClFilterableSettings
} from '@cl/common-library/cl-grid';

import { ClButtonComponent } from '@cl/common-library/cl-buttons';

import { ClGridConfiguratorEndpointsRequestMapToHelix } from '@app/theme/modules/common-library/models/cl-grid-config.model';

import { AttachmentTypeClient, SecurityUserGridConfigurationClient } from '@restApi/api/apiClients';

import { map, take } from 'rxjs';
import { SharedMessageService } from '@app/theme/services/shared-message.service';

@Component({
  selector: 'attachment-type-grid',
  templateUrl: './attachment-type-grid.component.html',
  imports: [ClGridComponent, TranslateModule],
  providers: [AttachmentTypeClient, SecurityUserGridConfigurationClient],
  standalone: true
})
export class AttachmentTypeGridComponent implements OnInit {
  private securityUserGridConfigurationClient = inject(SecurityUserGridConfigurationClient);
  private attachmentTypeClient = inject(AttachmentTypeClient);
  private translate = inject(TranslateService);
  private sharedMessageService = inject(SharedMessageService);
  private cdRef = inject(ChangeDetectorRef);

  dataGridRemote: GridDataResult = { data: null, total: 0 };
  gridConfigRemote!: ClGridConfig;
  public state!: State | ClGridState;

  gridEditionEndpoints: IClGridEditionEndpoints = {
    delete: (body) => {
      return this.attachmentTypeClient.deleteById.bind(this.attachmentTypeClient)(body.id);
    },
    create: (body) => {
      return this.attachmentTypeClient.insert.bind(this.attachmentTypeClient)(body);
    },
    update: (body) => {
      return this.attachmentTypeClient.update.bind(this.attachmentTypeClient)(body);
    }
  };

  gridConfiguratorEndpoints: IClGridConfiguratorEndpoints = {
    create: (body: ClGridConfiguratorEndpointsRequestMapToHelix) => {
      return this.securityUserGridConfigurationClient.insert.bind(this.securityUserGridConfigurationClient)(
        new ClGridConfiguratorEndpointsRequestMapToHelix(body)
      );
    },
    update: (body: ClGridConfiguratorEndpointsRequestMapToHelix) => {
      return this.securityUserGridConfigurationClient.update.bind(this.securityUserGridConfigurationClient)(
        new ClGridConfiguratorEndpointsRequestMapToHelix(body)
      );
    },
    deleteById: (id: number) => {
      return this.securityUserGridConfigurationClient.deleteById.bind(this.securityUserGridConfigurationClient)(id);
    },

    getUserGridConfigurations: (idGrid: string) => {
      return this.securityUserGridConfigurationClient.getUserGridConfigurations
        .bind(this.securityUserGridConfigurationClient)(idGrid)
        .pipe(
          map((array: any) => {
            array.map((x) => (x.configuration = JSON.parse(x.configuration)));
            return array;
          })
        );
    }
  };

  ngOnInit(): void {
    const idGrid: string = 'attachnmentsTypeGridConfig';
    this.gridConfigRemote = new ClGridConfig({
      idGrid,
      selectBy: 'id',
      mode: 'server-side',
      reorderable: true,
      pageable: new ClPageableSettings({ pageSizes: [1, 5, 10, 25, 50, 100, 500] }),
      sortable: new ClSortableSettings({
        mode: 'multiple',
        allowUnsort: true
      }),
      persistState: false, // No persiste el estado de la grid en el sesión storage
      showRefreshButton: false,
      // gridConfiguratorEndpoints: this.gridConfiguratorEndpoints, // TODO: Desactivado temporalmente, si existe, persistState se pone a true
      edition: new ClGridEdition({
        mode: 'row',
        endpoints: {
          delete: this.gridEditionEndpoints.delete,
          create: this.gridEditionEndpoints.create,
          update: this.gridEditionEndpoints.update
        },
        removeRowConfirmationText: this.translate.instant('REMOVE_ROW_CONFIRMATION'),
        hideEditButtons: false
      }),
      selectable: new ClSelectableSettings({
        mode: 'single'
      }),
      filterable: new ClFilterableSettings({
        hideToolbarFilter: true,
        hideSearcherFilter: true
      }),
      exportToExcel: {
        fileName: 'tiposAdjuntos',
        endpoint: (state: State) => {
          return this.attachmentTypeClient.getAllKendoFilter
            .bind(this.attachmentTypeClient)({ data: state })
            .pipe(map((res: any) => res.list));
        }
      },
      state: {
        skip: 0,
        take: 4,
        sort: [],
        filter: {
          filters: [],
          logic: 'and'
        }
      },
      columnMenu: {
        filter: true,
        columnChooser: false,
        sort: true,
        lock: true,
        stick: true
      },
      columns: [
        {
          field: 'id',
          title: 'Id',
          width: 150,
          filterable: false,
          hidden: true,
          defaultValue: () => {
            return 0;
          }
        },
        {
          field: 'description',
          title: 'DESCRIPTION5',
          width: 150,
          filterable: true,
          filter: 'text',
          sortable: true,
          hidden: false,
          editor: { type: 'text' }
        }
      ]
    });

    this.callApi({ data: this.gridConfigRemote.state });
  }

  callApi(state?: any) {
    this.state = this.state ?? state;
    this.attachmentTypeClient
      .getAllKendoFilter(state)
      .pipe(take(1))
      .subscribe({
        next: (res: any) => {
          this.dataGridRemote = { data: res.list, total: res.count };
          this.cdRef.detectChanges();
        },
        error: (err) => this.sharedMessageService.showError(err)
      });
  }
}
