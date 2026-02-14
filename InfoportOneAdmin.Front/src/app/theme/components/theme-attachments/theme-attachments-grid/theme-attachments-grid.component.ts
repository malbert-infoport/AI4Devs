import { ChangeDetectorRef, Component, Input, OnInit, TemplateRef, ViewChild, inject } from '@angular/core';
import {
  ClFilterableSettings,
  ClGridComponent,
  ClGridConfig,
  ClGridEdition,
  ClGridState,
  ClPageableSettings,
  ClSelectableSettings,
  ClSortableSettings,
  IClGridEditionEndpoints
} from '@cl/common-library/cl-grid';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { SharedMessageService } from '@app/theme/services/shared-message.service';
import { ThemeAttachmentsService } from '@app/theme/services/theme-attachments.service';
import { GridDataResult } from '@progress/kendo-angular-grid';
import { State } from '@progress/kendo-data-query';
import { MatButtonModule } from '@angular/material/button';
import { take } from 'rxjs';
import { ThemeAttachmentsDialogComponent } from '@app/theme/components/theme-attachments/theme-attachments-dialog/theme-attachments-dialog.component';
import { IAttachmentView, SecurityUserGridConfigurationClient } from '@restApi/api/apiClients';
import { ThemeAttachmentsConfiguration } from '@app/theme/models/theme-attachments.model';
import { DialogNavigationService } from '@app/services/dialog-navigation.service';
import { ClButtonComponent } from '@cl/common-library/cl-buttons';
import { DialogModule, DialogRef } from '@progress/kendo-angular-dialog';
import { ClModalComponent, ClModalConfig, ClModalService } from '@cl/common-library/cl-modal';

@Component({
  selector: 'theme-attachments-grid',
  imports: [MatButtonModule, ClGridComponent, TranslateModule, ClButtonComponent, DialogModule],
  providers: [SecurityUserGridConfigurationClient],
  templateUrl: './theme-attachments-grid.component.html'
})
export class ThemeAttachmentsGridComponent implements OnInit {
  private translate = inject(TranslateService);
  private sharedMessageService = inject(SharedMessageService);
  private themeAttachmentsService = inject(ThemeAttachmentsService);
  private cdRef = inject(ChangeDetectorRef);
  private readonly clModalService = inject(ClModalService);

  // Servicio compartido que se pasa desde el componente padre
  public dialogNavigationService: DialogNavigationService;

  dataGridRemote: GridDataResult = { data: null, total: 0 };
  gridConfigRemote!: ClGridConfig;
  public state!: State | ClGridState;

  get endpoints() {
    return this.attachmentsGridConfiguration?.endpoints;
  }
  get entityId() {
    return this.attachmentsGridConfiguration?.entityId;
  }

  get idGrid() {
    return this.attachmentsGridConfiguration?.idGrid;
  }

  @Input() public attachmentsGridConfiguration: ThemeAttachmentsConfiguration;
  @Input() public size?: 'XS' | 'S' | 'M' | 'L' | 'XL' | 'XXL';
  @ViewChild('addButtonTemplate', { static: true }) addButtonTemplate!: TemplateRef<any>;

  themeAttachmentsDialogRef: DialogRef = null;
  themeAttachmentsComponent: ThemeAttachmentsDialogComponent = null;

  selectedKey;

  gridEditionEndpoints: IClGridEditionEndpoints = {
    delete: (body) => {
      return this.endpoints.deleteById(body.id);
    }
  };

  opened: boolean = true;
  ngOnInit(): void {
    this.loadAttachmentsGrid();
  }

  /**
   * dblclick   */
  rowSelected(e: IAttachmentView) {
    this.insertOrUpdateAction(e.id);
  }

  /**
   * click(change selection) */
  selectionChanged(event: number[]) {
    this.selectedKey = event[0];
  }

  insertOrUpdateAction(id: number) {
    const modal = new ClModalConfig({
      title: this.translate.instant('ATTACHMENTS.ATTACHMENTS_MANAGEMENT'),
      content: ThemeAttachmentsDialogComponent,
      size: 'M', // TODO: Common.Library, va a hacer un modal informativo, sin botones y con una X para cerrar
      closeButton: {
        text: this.translate.instant('CANCEL'),
        hidden: false,
        action: (): boolean => {
          return true; // cerrar modal
        }
      },
      submitButton: {
        text: this.translate.instant('ACCEPT'),
        hidden: false,
        disabled: false,
        action: () => {
          this.themeAttachmentsComponent.onSubmit();
          /**Refrescamos la grid, cuando acabe de hacer la llamada al api */
          this.themeAttachmentsComponent.refreshGrid.subscribe((data) => {
            this.clModalService.closeDialog();
            this.callApi(this.state);
          });
          return false; // cerrar modal
        }
      }
    });

    const args = new Map<string, any>();

    args.set('id', id ?? 0);
    args.set('endpoints', this.endpoints);
    args.set('entityId', this.entityId);
    args.set('size', this.size);

    modal.componentInputs = args;

    this.clModalService.openModal<ThemeAttachmentsDialogComponent>(modal).then((value) => {
      this.themeAttachmentsComponent = value.component;
      this.themeAttachmentsDialogRef = value.dialogRef;
      // Configurar DialogNavigationService con el dialogRef si el servicio está disponible
      if (this.dialogNavigationService) {
        this.dialogNavigationService.setup(value.dialogRef);
      }
      if (this.themeAttachmentsComponent) {
        this.themeAttachmentsComponent.formReady.subscribe(() => {
          (this.themeAttachmentsDialogRef.content.instance as ClModalComponent).submitButton.disabled =
            this.themeAttachmentsComponent.attachmentsForm.invalid ||
            this.themeAttachmentsComponent.loading ||
            !this.themeAttachmentsComponent.attachmentsForm.dirty;

          this.themeAttachmentsComponent.attachmentsForm.valueChanges.subscribe((x) => {
            (this.themeAttachmentsDialogRef.content.instance as ClModalComponent).submitButton.disabled =
              this.themeAttachmentsComponent.attachmentsForm.invalid ||
              (this.themeAttachmentsComponent.isNew &&
                !this.themeAttachmentsComponent.attachmentsForm.get('fileContent')?.value);
          });
        });
      }
    });
  }

  addAction() {
    this.insertOrUpdateAction(0);
  }

  loadAttachmentsGrid() {
    const idGrid: string = `atachmentGridConfig${this.idGrid.replace(/\s/g, '')}`;

    this.gridConfigRemote = new ClGridConfig({
      idGrid,
      selectBy: 'id',
      mode: 'server-side',
      reorderable: true,
      footerTemplate: this.addButtonTemplate,
      pageable: new ClPageableSettings({ pageSizes: [5, 10, 25, 50], showRowsPerPage: false }),
      persistState: false, // No persiste el estado de la grid en el sesión storage
      showRefreshButton: false,
      sortable: new ClSortableSettings({
        mode: 'multiple',
        allowUnsort: true
      }),
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
      state: {
        skip: 0,
        take: 5,
        sort: [
          {
            field: 'fileName',
            dir: 'asc'
          }
        ],
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
          field: 'fileName',
          title: this.translate.instant('ATTACHMENTS.FILE_NAME'),
          width: 75,
          filterable: true,
          filter: 'text',
          sortable: true,
          hidden: false
        },
        {
          field: 'fileExtension',
          title: this.translate.instant('ATTACHMENTS.FILE_EXTENSION'),
          width: 25,
          filterable: true,
          filter: 'text',
          sortable: true,
          hidden: false
        },
        {
          field: 'fileSizeKb',
          title: this.translate.instant('ATTACHMENTS.FILE_SIZE'),
          width: 25,
          filterable: true,
          filter: 'numeric',
          sortable: true,
          hidden: false
        },
        {
          field: 'attachmentType',
          title: this.translate.instant('ATTACHMENTS.TYPE'),
          width: 25,
          filterable: true,
          filter: 'text',
          sortable: true,
          hidden: false
        },
        {
          field: 'attachmentDescription',
          title: this.translate.instant('ATTACHMENTS.DESCRIPTION'),
          width: 100,
          filterable: true,
          filter: 'text',
          sortable: true,
          hidden: false
        }
      ]
    });

    this.callApi({ data: this.gridConfigRemote.state });
  }

  download() {
    if (this.selectedKey) {
      this.themeAttachmentsService.downloadFile(this.selectedKey, this.endpoints.getAttachmentContent);
    } else {
      this.sharedMessageService.showMessage(this.translate.instant('ATTACHMENTS.MESSAGES.NO_ELEMENT_SELECTED'), 'warning');
    }
  }
  callApi(state?: any) {
    this.state = this.state ?? state;
    this.endpoints
      .getAllVTAAttachmentsKendoFilter(this.entityId, undefined, undefined, undefined, state)
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
