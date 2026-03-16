import { coerceBooleanProperty } from '@angular/cdk/coercion';
import { Component, EventEmitter, Input, Output, ViewEncapsulation, inject } from '@angular/core';
import { ClButtonComponent } from '@cl/common-library/cl-buttons';
import { ClModalConfig, ClModalService } from '@cl/common-library/cl-modal';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { DialogRef } from '@progress/kendo-angular-dialog';
import { ThemeLookupGridComponent } from './theme-lookup-grid/theme-lookup-grid.component';
import { ThemeLookupConfig } from './models/theme-lookup.model';

@Component({
  selector: 'theme-lookup',
  imports: [ClButtonComponent, TranslateModule],
  providers: [],
  encapsulation: ViewEncapsulation.None,
  templateUrl: './theme-lookup.component.html',
  styleUrl: './theme-lookup.component.scss'
})
export class ThemeLookupComponent {
  private readonly translate = inject(TranslateService);
  private readonly clModalService = inject(ClModalService);

  dialogRef: DialogRef = null;
  component: ThemeLookupGridComponent = null;

  @Input() showLookupButton: boolean = true;
  /**
   * Items seleccionados de la grid.
   */
  @Output() selectedItems = new EventEmitter<any>();

  /**
   * Configuración de la grid que mostrará el look-up
   */
  @Input() lookUpConfig?: ThemeLookupConfig;

  /**
   * Inputs del botón (Lupa),
   * estos inputs se dejan fuera de la configuraicón del ThemeLookupConfig,
   * para facilitar la personalización del botón.
   */
  @Input() tooltipText: string;
  @Input() text: string;
  @Input() theme: 'link' | 'primary' | 'secondary' | 'tertiary' | 'error' = 'secondary';
  @Input()
  get disabled() {
    return this._disabled;
  }
  set disabled(value: boolean) {
    this._disabled = coerceBooleanProperty(value);
  }

  _disabled: boolean = false;

  openModal() {
    const modal = new ClModalConfig({
      title: this.lookUpConfig?.title ?? '',
      content: ThemeLookupGridComponent,
      size: this.lookUpConfig?.size ?? 'XL',
      closeButton: {
        text: this.translate.instant('CANCEL'),
        hidden: false,
        shortcut: ['Esc'],
        action: (): boolean => {
          return true; // cerrar modal
        }
      },
      submitButton: {
        text: this.translate.instant('ACCEPT'),
        hidden: false,
        shortcut: ['Ctrl', 'Enter'],
        action: () => {
          this.selectedItems.emit(this.component.getAllSelectedItems());
          return true; // cerrar modal
        }
      }
    });

    const args = new Map<string, any>();
    args.set('lookUpConfig', this.lookUpConfig);
    modal.componentInputs = args;

    this.clModalService.openModal<ThemeLookupGridComponent>(modal).then((value) => {
      if (value?.component) {
        this.dialogRef = value.dialogRef;
        this.component = value.component;
      } else {
        console.error('El componente del modal no se inicializó correctamente.');
      }
    });
  }
}
