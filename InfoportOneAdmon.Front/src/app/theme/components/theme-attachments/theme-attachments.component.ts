import { coerceBooleanProperty } from '@angular/cdk/coercion';
import { Component, Input, inject } from '@angular/core';

import { AtthachmentsDialogConfig, ThemeAttachmentsConfiguration } from '@app/theme/models/theme-attachments.model';
import { ThemeAttachmentsGridComponent } from '@app/theme/components/theme-attachments/theme-attachments-grid/theme-attachments-grid.component';
import { DialogNavigationService } from '@app/services/dialog-navigation.service';

import { DialogRef } from '@progress/kendo-angular-dialog';
import { ClButtonComponent } from '@cl/common-library/cl-buttons';
import { ClModalConfig, ClModalService } from '@cl/common-library/cl-modal';
import { AccessService } from '@app/theme/access/access.service';
import { TranslateService } from '@ngx-translate/core';

@Component({
  selector: 'theme-attachments',
  imports: [ClButtonComponent],
  templateUrl: './theme-attachments.component.html',
  providers: [DialogNavigationService]
})
export class ThemeAttachmentsComponent {
  private readonly clModalService = inject(ClModalService);
  private readonly accessService = inject(AccessService);
  private readonly translate = inject(TranslateService);
  private readonly dialogNavigationService = inject(DialogNavigationService);

  /**
   * Configuración de la grid que mostrará en el componente de adjuntos
   */
  @Input() attachmentsConfiguration?: ThemeAttachmentsConfiguration;

  @Input()
  get disabled() {
    return this._disabled;
  }
  set disabled(value: boolean) {
    this._disabled = coerceBooleanProperty(value);
  }

  _disabled: boolean = false;

  dialogRef: DialogRef;

  get dialogConfig(): AtthachmentsDialogConfig {
    return this.attachmentsConfiguration.dialogConfig || new AtthachmentsDialogConfig({});
  }

  openDialog() {
    const modal = new ClModalConfig({
      title: this.translate.instant('ATTACHMENTS.ATTACHMENTS_MANAGEMENT'),
      content: ThemeAttachmentsGridComponent,
      size: this.dialogConfig.size,
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
        disabled: !this.accessService.maestroVehiculosModificacion(),
        action: () => {
          return true; // cerrar modal
        }
      }
    });

    const args = new Map<string, any>();

    args.set('attachmentsGridConfiguration', this.attachmentsConfiguration);
    args.set('size', this.dialogConfig.size);

    modal.componentInputs = args;

    this.clModalService.openModal<ThemeAttachmentsGridComponent>(modal).then((value) => {
      // Configurar el DialogNavigationService para el primer modal
      this.dialogNavigationService.setup(value.dialogRef);
      // Pasar el servicio al grid para que lo use en el segundo modal
      if (value.component) {
        value.component.dialogNavigationService = this.dialogNavigationService;
      }
    });
  }
}
