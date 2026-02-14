import { ChangeDetectorRef, Component, OnInit, TemplateRef, ViewChild, inject } from '@angular/core';
import { GeneralConfigurationComponent } from '@app/modules/system-options/components/security/general-configuration/general-configuration.component';
import { SecurityService } from '@app/modules/system-options/services/security.service';
import { AccessService } from '@app/theme/access/access.service';
import { ClGridConfiguratorEndpointsRequestMapToHelix } from '@app/theme/modules/common-library/models/cl-grid-config.model';
import { ThemeAttachmentsService } from '@app/theme/services/theme-attachments.service';
import { ClButtonComponent } from '@cl/common-library/cl-buttons';
import {
  ClFilterableSettings,
  ClGridComponent,
  ClGridConfig,
  ClGridState,
  ClPageableSettings,
  ClSelectableSettings,
  ClSortableSettings,
  IClGridConfiguratorEndpoints
} from '@cl/common-library/cl-grid';
import { TranslateModule, TranslateService } from '@ngx-translate/core';

import { GridDataResult } from '@progress/kendo-angular-grid';
import { State } from '@progress/kendo-data-query';
import {
  AttachmentClient,
  SecurityProfileClient,
  SecurityUserGridConfigurationClient,
  VTA_AttachmentClient
} from '@restApi/api/apiClients';
import { map, take } from 'rxjs';
import { SharedMessageService } from '@app/theme/services/shared-message.service';

@Component({
  selector: 'theme-attachments-management',
  standalone: true,
  imports: [ClGridComponent, TranslateModule, ClButtonComponent],
  providers: [VTA_AttachmentClient, SecurityProfileClient, SecurityUserGridConfigurationClient, AttachmentClient],
  templateUrl: './theme-attachments-management.component.html'
})
export class ThemeAttachmentsManagementComponent implements OnInit {
  accessService = inject(AccessService);
  securityService = inject(SecurityService);
  private readonly translate = inject(TranslateService);
  securityProfileClient = inject(SecurityProfileClient);
  private readonly securityUserGridConfigurationClient = inject(SecurityUserGridConfigurationClient);
  private readonly themeAttachmentsService = inject(ThemeAttachmentsService);
  private readonly vtaAtachmentClient = inject(VTA_AttachmentClient);
  private readonly attachmentClient = inject(AttachmentClient);
  private readonly sharedMessageService = inject(SharedMessageService);
  private readonly cdRef = inject(ChangeDetectorRef);

  dataGridRemote: GridDataResult = { data: null, total: 0 };
  gridConfigRemote!: ClGridConfig;

  public state!: State | ClGridState;

  selectedKeys: number[] = [];

  @ViewChild('rightButtonsTemplate', { static: true }) rightButtonsTemplate!: TemplateRef<any>;

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
    this.loadAttachmentsManagementGrid();
  }

  callApi(state?: any) {
    this.state = this.state ?? state;
    this.vtaAtachmentClient
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

  /**
   * click(change selection) */
  selectionChanged(event: number[]) {
    this.selectedKeys = event;
  }

  loadAttachmentsManagementGrid() {
    const idGrid: string = 'attachmentsManagementGridConfig';

    this.gridConfigRemote = new ClGridConfig({
      idGrid,
      selectBy: 'id',
      mode: 'server-side',
      reorderable: true,
      footerTemplate: this.rightButtonsTemplate,
      pageable: new ClPageableSettings({ pageSizes: [1, 5, 10, 25, 50, 100, 500] }),
      sortable: new ClSortableSettings({
        mode: 'multiple',
        allowUnsort: true
      }),
      toolbarTemplates: {
        templateLeft: null,
        templateRight: this.rightButtonsTemplate
      },
      showRefreshButton: false,
      persistState: false, // No persiste el estado de la grid en el sesión storage
      // gridConfiguratorEndpoints: this.gridConfiguratorEndpoints, // TODO: Desactivado temporal mente, si existe, persistState se pone a true
      selectable: new ClSelectableSettings({
        mode: 'multiple'
      }),
      filterable: new ClFilterableSettings({
        hideToolbarFilter: true,
        hideSearcherFilter: true
      }),
      exportToExcel: {
        fileName: 'adjuntos',
        endpoint: (state: State) => {
          return this.vtaAtachmentClient.getAllKendoFilter
            .bind(this.vtaAtachmentClient)({ data: state })
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
          field: 'entityName',
          title: this.translate.instant('ATTACHMENTS.ENTITY_NAME'),
          width: 200,
          filterable: true,
          filter: 'text',
          sortable: true,
          hidden: false
        },
        {
          field: 'entityDescription',
          title: this.translate.instant('ATTACHMENTS.DESCRIPTION'),
          width: 200,
          filterable: true,
          filter: 'text',
          sortable: true,
          hidden: false
        },
        {
          field: 'fileName',
          title: this.translate.instant('ATTACHMENTS.FILE_NAME'),
          width: 200,
          filterable: true,
          filter: 'text',
          sortable: true,
          hidden: false
        },
        {
          field: 'fileExtension',
          title: this.translate.instant('ATTACHMENTS.FILE_EXTENSION'),
          width: 150,
          filterable: true,
          filter: 'text',
          sortable: true,
          hidden: false
        },
        {
          field: 'fileSizeKb',
          title: this.translate.instant('ATTACHMENTS.FILE_SIZE'),
          width: 150,
          filterable: true,
          filter: 'numeric',
          sortable: true,
          hidden: false
        },
        {
          field: 'attachmentType',
          title: this.translate.instant('ATTACHMENTS.TYPE'),
          width: 180,
          filterable: true,
          filter: 'text',
          sortable: true,
          hidden: false
        },
        {
          field: 'attachmentDescription',
          title: this.translate.instant('ATTACHMENTS.DESCRIPTION'),
          width: 500,
          filterable: true,
          filter: 'text',
          sortable: true,
          hidden: false
        }
      ]
    });

    this.callApi({ data: this.gridConfigRemote.state });
  }

  download(selectedKeys: number[]) {
    if (selectedKeys.length > 0) {
      selectedKeys.forEach((key) => {
        this.themeAttachmentsService.downloadFile(key, this.attachmentClient.getAttachmentContent.bind(this.attachmentClient));
      });
    } else {
      this.sharedMessageService.showMessage(this.translate.instant('ATTACHMENTS.MESSAGES.ANY_ELEMENT_SELECTED'), 'warning');
    }
  }
}
