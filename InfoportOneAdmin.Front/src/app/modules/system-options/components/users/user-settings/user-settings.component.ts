import { Component, OnInit, ViewChild, inject, EventEmitter, Output } from '@angular/core';
import { FormsModule, ReactiveFormsModule, FormBuilder, FormGroup } from '@angular/forms';

import { TranslateService, TranslateModule } from '@ngx-translate/core';

import { Kendoi18nMessageService } from '@app/theme/modules/kendo-ui/services/kendo-i18n-message.service';
import { SharedMessageService } from '@app/theme/services/shared-message.service';
import { TranslateConfigService } from '@app/theme/services/translate-config.service';
import { AuthenticationService } from '@app/theme/services/authentication.service';
import { ThemeLoadingComponent } from '@app/theme/components/theme-loading/theme-loading.component';

import {
  ISecurityUserConfigurationView,
  SecurityUserConfigurationClient,
  SecurityUserConfigurationView
} from '@restApi/api/apiClients';

import { take } from 'rxjs';
import { ClComboBoxComponent } from '@cl/common-library/cl-form-fields';
import { DateAdapter } from '@angular/material/core';
@Component({
  selector: 'user-settings',
  templateUrl: 'user-settings.component.html',
  providers: [SecurityUserConfigurationClient],
  imports: [FormsModule, ThemeLoadingComponent, TranslateModule, ReactiveFormsModule, ClComboBoxComponent]
})
export class UserSettingsComponent implements OnInit {
  private translate = inject(TranslateService);
  private kendoService = inject(Kendoi18nMessageService);
  private authService = inject(AuthenticationService);
  private dateAdapter = inject<DateAdapter<any>>(DateAdapter);
  private sharedMessageService = inject(SharedMessageService);
  translateConfigService = inject(TranslateConfigService);
  private securityUserConfigurationClient = inject(SecurityUserConfigurationClient);
  private fb = inject(FormBuilder);

  @Output() formReady = new EventEmitter<void>();
  @Output() closeDialog = new EventEmitter<void>();

  @ViewChild('form')
  userSettingsForm: FormGroup;

  model!: SecurityUserConfigurationView;

  ngOnInit() {
    this.securityUserConfigurationClient
      .getUserConfiguration()
      .pipe(take(1))
      .subscribe({
        next: (securityUser: SecurityUserConfigurationView) => {
          this.setUsserSettingsFormValues(securityUser);
        },
        error: (err) => this.sharedMessageService.showError(err)
      });
  }

  setUsserSettingsFormValues(securityUser: ISecurityUserConfigurationView) {
    this.userSettingsForm = this.fb.group({
      id: [securityUser.id],
      language: [{ culture: securityUser.language, description: securityUser.language }],
      lastConnectionDate: [securityUser.lastConnectionDate],
      modalPagination: [securityUser.modalPagination],
      pagination: [securityUser.pagination]
    });
    // Avisa de que el formulario, ya ha sido cargado.
    this.formReady.emit();
  }

  changeLang() {
    const currentLang = this.translate.currentLang === 'es' ? 'en' : 'es';
    this.translate.use(currentLang);
    localStorage.setItem('cl-lang', currentLang + '-cl');
    this.dateAdapter.setLocale(currentLang);
    this.kendoService.setLanguage(currentLang);
  }

  onSubmit() {
    const DATA = this.userSettingsForm.getRawValue();
    DATA.language = DATA.language.culture;
    this.securityUserConfigurationClient
      .update(DATA)
      .pipe(take(1))
      .subscribe({
        next: () => {
          this.authService.refreshToken();
          this.changeLang();
          localStorage.setItem('language', DATA.language);
          this.sharedMessageService.showMessage(this.translate.instant('SAVE_CHANGE'));
          this.closeDialog.emit();
          window.location.reload();
        },
        error: (err) => this.sharedMessageService.showError(err)
      });
  }
}
