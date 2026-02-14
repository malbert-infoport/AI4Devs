import { ChangeDetectorRef, Component, Input, TemplateRef, ViewChild, inject } from '@angular/core';

import { ClGridComponent, ClGridConfig, ClGridExternalFilterDirective, ClGridState } from '@cl/common-library/cl-grid';
import { TranslateModule } from '@ngx-translate/core';
import { GridDataResult } from '@progress/kendo-angular-grid';
import { take } from 'rxjs';
import { SharedMessageService } from '@app/theme/services/shared-message.service';
import { ClButtonComponent } from '@cl/common-library/cl-buttons';

import { ClInputComponent } from '@cl/common-library/cl-form-fields';
import { FormBuilder, FormGroup, FormsModule, ReactiveFormsModule } from '@angular/forms';

import { State } from '@progress/kendo-data-query';
import { ThemeLookupConfig } from '../models/theme-lookup.model';

@Component({
  selector: 'theme-lookup-grid',
  imports: [
    ClGridComponent,
    TranslateModule,
    ClButtonComponent,
    ClInputComponent,
    FormsModule,
    ReactiveFormsModule,
    ClGridExternalFilterDirective
  ],
  templateUrl: './theme-lookup-grid.component.html',
  styles: `
    :host {
      kendo-dialog.cl-modal .k-dialog .k-dialog-content {
        padding: 0px;
      }

      .k-window-content {
        padding-block: 0px;
        padding-inine: 0px;
      }
      .bg-white {
        background-color: white;
      }
      .min-height-89 {
        min-height: 89px;
      }

      .padding-16 {
        padding-inline: 16px;
        padding-block: 16px;
      }
    }
  `,
  providers: []
})
export class ThemeLookupGridComponent {
  private readonly cdRef = inject(ChangeDetectorRef);
  private readonly sharedMessageService = inject(SharedMessageService);
  private readonly fb = inject(FormBuilder);

  @Input() public lookUpConfig: ThemeLookupConfig;

  public state!: State | ClGridState;
  public gridConfig!: ClGridConfig;
  public dataGrid: GridDataResult = { data: null, total: 0 };

  selectedKeys: number[] = [];
  selectedItems: any[] = [];
  sellectedAll: any[] = [];

  @ViewChild('noRecordsTemplate', { static: true }) noRecordsTemplate: TemplateRef<any>;

  lookupForm: FormGroup;

  ngOnInit(): void {
    this.loadGrid();

    /**
     * Creamos los elementos del formulario, por los valores que nos pasan dede el configurador del Lookup
     */
    this.lookupForm = this.fb.group({});
    this.lookUpConfig?.clInputs?.forEach((field) => {
      this.lookupForm.addControl(field.fieldName, this.fb.control(''));
    });
  }

  loadGrid() {
    this.gridConfig = this.lookUpConfig;

    if (!this.gridConfig?.noRecordsTemplate) {
      this.gridConfig.noRecordsTemplate = this.noRecordsTemplate;
    }

    this.callApi({ data: this.gridConfig.state });
  }

  callApi(state: any) {
    this.state = state ?? this.state;
    this.lookUpConfig
      .endpoint(this.state)
      .pipe(take(1))
      .subscribe({
        next: (res: any) => {
          this.dataGrid = { data: res.list ?? res, total: res.count ?? res.length ?? 0 };
          this.cdRef.detectChanges();
        },
        error: (err) => this.sharedMessageService.showError(err)
      });
  }

  /** El grid local emite los dataItems de todas las filas seleccionadas.
   *  El grid remoto emite las claves (selectBy) de los dataItems seleccionados.
   */
  selectionChanged(selectedItems: any[]) {
    // TODO: Implementar para grid mode: 'server-side
    this.selectedKeys = selectedItems;
    this.selectedItems = this.dataGrid.data.filter((item) => selectedItems.includes(item.id));
    this.updateSelectedItems();
  }

  /**
   * Actualiza la lista de todos los items seleccionados.
   */
  updateSelectedItems() {
    const selectedIdsSet = new Set(this.selectedKeys);

    // Añade nuevos elementos seleccionamos
    this.selectedItems.forEach((item) => {
      if (!this.sellectedAll.some((existingItem) => existingItem.id === item.id)) {
        this.sellectedAll.push(item);
      }
    });

    //  Eliminar los elementos que ya no están seleccionados
    this.sellectedAll = this.sellectedAll.filter((item) => selectedIdsSet.has(item.id));
  }

  getAllSelectedItems() {
    return this.sellectedAll;
  }
}
