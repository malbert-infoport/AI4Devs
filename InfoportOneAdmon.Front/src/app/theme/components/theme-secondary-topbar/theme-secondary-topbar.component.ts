import { AfterContentChecked, ChangeDetectorRef, Component, EventEmitter, Input, OnInit, Output, inject } from '@angular/core';
import { Location, UpperCasePipe } from '@angular/common';

import { MatIcon } from '@angular/material/icon';
import { MatIconAnchor, MatButton } from '@angular/material/button';
import { MatToolbar } from '@angular/material/toolbar';

import { ThemeFormService } from '@app/theme/services/theme-form.service';
import { ThemeLoadingComponent } from '@app/theme/components/theme-loading/theme-loading.component';

@Component({
  selector: 'theme-secondary-topbar',
  templateUrl: './theme-secondary-topbar.component.html',
  imports: [MatToolbar, MatIconAnchor, MatIcon, MatButton, ThemeLoadingComponent, UpperCasePipe]
})
export class ThemeSecondaryTopbarComponent implements OnInit, AfterContentChecked {
  private ref = inject(ChangeDetectorRef);
  private themeFormService = inject(ThemeFormService);
  private location = inject(Location);

  /**
   * label: Texto a mostrar
   */
  @Input() label: string = 'Title';

  /**
   * backArrow: Indica si mostrar o no botón de ir atrás
   */
  @Input() backArrow: boolean = false;

  /**
   * buttonAction: Acción del botón
   */
  @Input() buttonAction!: () => void;

  /**
   * buttonText: Texto del botón. El botón se mostrará en caso de estar relleno el campo buttonText
   */
  @Input() buttonText!: string;

  /**
   * buttonDisabled: Habilita/Deshabilita el botón.
   */
  @Input() buttonDisabled!: boolean;

  /**
   * buttonLoading: Muestra un loading de carga, mientras se ejecuta la acción del botón.
   */
  @Input() buttonLoading: boolean = false;

  /**
   * backAction: Emite un evento, cuando
   *  @returns que se ha pulsado el botón de ir atrás.
   */
  @Output() backAction: EventEmitter<any> = new EventEmitter<any>();

  backArrowUrl!: string;
  buttonLoaded = false;

  ngOnInit(): void {
    this.themeFormService.isWorking.subscribe((result) => {
      this.buttonLoading = result;
      this.ref.markForCheck();
    });

    this.themeFormService.saveCompleted.subscribe((result) => {
      this.buttonDisabled = !!result;
      this.ref.markForCheck();
    });
  }

  ngAfterContentChecked(): void {
    if (this.buttonDisabled == undefined || this.buttonLoaded) {
      if (!this.themeFormService.hasForms()) {
        this.buttonDisabled = true;
      } else {
        this.buttonDisabled = !(this.themeFormService.isValid() && this.themeFormService.hasChanges());

        this.ref.markForCheck();
      }

      this.buttonLoaded = true;
    }
  }

  executeGoBackFunction() {
    this.backAction.emit();
  }

  goBack() {
    this.location.back();
  }
}
