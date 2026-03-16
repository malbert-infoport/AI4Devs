import { ChangeDetectorRef, Component, OnInit, TemplateRef, ViewChild, inject } from '@angular/core';

import { GridDataResult } from '@progress/kendo-angular-grid';
import { State } from '@progress/kendo-data-query';
import { TabStripModule } from '@progress/kendo-angular-layout';

import { MatDialog } from '@angular/material/dialog';

import { TranslateService, TranslateModule } from '@ngx-translate/core';

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
import { ClModalService } from '@cl/common-library/cl-modal';
import { ClButtonComponent } from '@cl/common-library/cl-buttons';

import { ProfileDetailComponent } from '@app/modules/system-options/components/security/profile/profile-detail/profile-detail.component';
import { GeneralConfigurationComponent } from '@app/modules/system-options/components/security/general-configuration/general-configuration.component';
import { SecurityService } from '@app/modules/system-options/services/security.service';

import { ClGridConfiguratorEndpointsRequestMapToHelix } from '@app/theme/modules/common-library/models/cl-grid-config.model';
import { AccessService } from '@app/theme/access/access.service';
import { SharedMessageService } from '@app/theme/services/shared-message.service';
import { ThemeSecondaryTopbarComponent } from '@app/theme/components/theme-secondary-topbar/theme-secondary-topbar.component';

import { SecurityProfileClient, SecurityProfileView, SecurityUserGridConfigurationClient } from '@restApi/api/apiClients';

import { map, take } from 'rxjs';
import { IClTabData, ClTabsComponent } from '@cl/common-library/cl-tabs';

@Component({
  selector: 'security-tab',
  templateUrl: './security-tab.component.html',
  styles: `
    :host {
      display: flex;
      flex-direction: column;
      height: 100%;
    }

    theme-secondary-topbar {
      flex-shrink: 0;
    }

    ::ng-deep .k-tabstrip-top > .k-tabstrip-items-wrapper {
      background-color: white;
      flex-shrink: 0;
    }

    ::ng-deep .k-tabstrip-content {
      background-color: #f7fbfb;
      overflow-y: auto !important;
      overflow-x: hidden !important;
      flex: 1 !important;
      padding: 0 !important;
    }

    ::ng-deep .k-tabstrip {
      display: flex !important;
      flex-direction: column !important;
      height: 100% !important;
      overflow: hidden !important;
    }

    ::ng-deep cl-tabs {
      flex: 1;
      display: flex;
      flex-direction: column;
      overflow: hidden;
      min-height: 0;
    }

    .bg-common-theme {
      padding: 16px;
      height: 100%;

      cl-grid {
        height: 100%;
      }
    }
  `,
  providers: [SecurityProfileClient],
  imports: [
    ThemeSecondaryTopbarComponent,
    TabStripModule,
    ClGridComponent,
    GeneralConfigurationComponent,
    TranslateModule,
    ClTabsComponent
  ]
})
export class SecurityTabComponent implements OnInit {
  accessService = inject(AccessService);
  securityService = inject(SecurityService);
  securityProfileClient = inject(SecurityProfileClient);
  private readonly translate = inject(TranslateService);
  sharedMessageService = inject(SharedMessageService);
  private readonly dialog = inject(MatDialog);
  private readonly securityUserGridConfigurationClient = inject(SecurityUserGridConfigurationClient);
  private readonly cdRef = inject(ChangeDetectorRef);

  dataGridRemote: GridDataResult = { data: null, total: 0 };
  gridConfigRemote!: ClGridConfig;

  @ViewChild('rightButtonsTemplate', { static: true }) rightButtonsTemplate!: TemplateRef<any>;
  @ViewChild('addButtonTemplate', { static: true }) addButtonTemplate!: TemplateRef<any>;

  internalTabsData: IClTabData[];

  @ViewChild('profiles', { static: true }) profiles: TemplateRef<any>;
  @ViewChild('generalConfig', { static: true }) generalConfig: TemplateRef<any>;

  public state!: State | ClGridState;

  gridEditionEndpoints: IClGridEditionEndpoints = {
    delete: (body) => {
      return this.securityProfileClient.deleteById.bind(this.securityProfileClient)(body.id);
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
    const idGrid: string = 'profilesGridConfig';
    this.gridConfigRemote = new ClGridConfig({
      idGrid,
      selectBy: 'id',
      mode: 'server-side',
      reorderable: true,
      footerTemplate: this.addButtonTemplate,
      showRefreshButton: false,
      pageable: new ClPageableSettings({
        pageSizes: [5, 10, 15, 20, 25],
        showRowsPerPage: true,
        showTotalResults: true
      }),
      sortable: new ClSortableSettings({
        mode: 'multiple',
        allowUnsort: true
      }),
      toolbarTemplates: {
        templateLeft: null,
        templateRight: this.rightButtonsTemplate
      },
      persistState: false, // No persiste el estado de la grid en el sesión storage
      // gridConfiguratorEndpoints: this.gridConfiguratorEndpoints, // TODO: Desactivado temporal mente, si existe, persistState se pone a true
      edition: new ClGridEdition({
        mode: 'delete-only',
        endpoints: { delete: this.gridEditionEndpoints.delete },
        removeRowConfirmationText: this.translate.instant('REMOVE_ROW_CONFIRMATION')
      }),
      selectable: new ClSelectableSettings({
        mode: 'single'
      }),
      filterable: new ClFilterableSettings({
        hideToolbarFilter: true,
        hideSearcherFilter: true
      }),
      exportToExcel: {
        fileName: 'perfiles',
        endpoint: (state: State) => {
          return this.securityProfileClient.getAllKendoFilter
            .bind(this.securityProfileClient)({ data: state })
            .pipe(map((res: any) => res.list));
        }
      },
      state: {
        skip: 0,
        take: 20,
        sort: [
          {
            field: 'description',
            dir: 'desc'
          }
        ],
        filter: {
          filters: [
            {
              field: 'auditDeletionDate',
              operator: 'isnull',
              value: null
            }
          ],
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
          field: 'description',
          title: this.translate.instant('DESCRIPTION'),
          width: 100,
          filterable: true,
          filter: 'text',
          sortable: true,
          hidden: false
        },
        {
          field: 'rol',
          title: this.translate.instant('ROLE'),
          width: 100,
          sortable: true,
          filterable: true,
          filter: 'text',
          hidden: false
        },
        {
          field: 'auditDeletionDate',
          title: this.translate.instant('AUDIT_FECHA_BAJA'),
          width: 100,
          filterable: true,
          filter: 'date',
          sortable: true,
          hidden: false,
          dateConfig: {
            format: 'dd/MM/yyyy HH:mm'
          },
          editor: {
            type: 'date'
          }
        },
        {
          field: 'securityCompanyId',
          title: this.translate.instant('SECURITY_COMPANY_ID'),
          width: 100,
          filterable: true,
          sortable: true,
          hidden: true,
          filter: 'numeric',
          defaultValue: 1
        }
      ]
    });

    this.callApi({ data: this.gridConfigRemote.state });
  }

  loadTabsData() {
    this.internalTabsData = [
      { title: this.translate.instant('SYSTEM_OPTIONS.SECURITY.PROFILES.TITLE'), content: this.profiles },
      { title: this.translate.instant('SYSTEM_OPTIONS.SECURITY.GENERAL_CONFIGURATION.TITLE'), content: this.generalConfig }
    ];
  }
  ngAfterViewInit(): void {
    this.loadTabsData();
  }

  /**
   * Método que se dispara cuando se hace dblckick en una fila de la grid
   * @param profile : devuelve el elemento de la fila
   */
  rowSelected(profile: SecurityProfileView) {
    this.insertOrUpdateAction(profile.id || 0);
  }

  addAction() {
    this.insertOrUpdateAction(0);
  }

  /**
   * método para limpiar la cache de seguridad
   */
  cleanSecurityCache() {
    this.securityService.cleanSecurityCache();
  }

  /**
   * Método que se encarga de abrir el modal de insertar o actualizar
   * @param id : id del elemento a insertar o actualizar
   */
  insertOrUpdateAction(id: number) {
    // TODO: DE MOMENTO HASTA QUE SE PUEDAN USAR INPUTS, USAMOS MATERIAL
    // this.clModalService.openModal(
    //   new ClModalConfig({
    //     title: 'PROFILES',
    //     content: ProfileDetailComponent as Type<Component>,
    //     size: 'L',
    //     closeButton: { hidden: true },
    //     submitButton: {
    //       action: (): boolean => true, // true: close modal, false: don't close modal
    //       text: 'OK'
    //     }
    //   })
    // );

    /**
     * id:0 elemento nuevo id>0 elemento existente
     */

    const dialogRef = this.dialog.open(ProfileDetailComponent, {
      width: '1200px',
      maxWidth: '90%',
      maxHeight: '100%',
      height: 'auto',
      disableClose: false,
      autoFocus: true,
      data: { data: { id: id }, inputs: { title: 'PROFILES' } }
    });

    dialogRef.afterClosed().subscribe((result) => {
      if (result?.accepted) {
        this.callApi(this.state);
        const MESSAGE = id > 0 ? 'UPDATE_SUCCESS' : 'INSERT_SUCCESS';
        this.sharedMessageService.showMessage(this.translate.instant(MESSAGE));
      }
    });
  }

  callApi(state?: any) {
    this.state = this.state ?? state;
    this.securityProfileClient
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
