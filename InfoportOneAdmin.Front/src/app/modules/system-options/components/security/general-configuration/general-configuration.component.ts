import { Component, inject } from '@angular/core';
import { FormBuilder, FormGroup, Validators, FormsModule, ReactiveFormsModule } from '@angular/forms';
import { MatDialog } from '@angular/material/dialog';
import { MatButton } from '@angular/material/button';
import { MatInput } from '@angular/material/input';
import { MatFormField, MatLabel, MatError } from '@angular/material/form-field';

import { TranslateService, TranslateModule } from '@ngx-translate/core';

import { SecurityCompanyClient, SecurityCompanyView } from '@restApi/api/apiClients';

import { AccessService } from '@app/theme/access/access.service';
import { SharedMessageService } from '@app/theme/services/shared-message.service';
import { ThemeLoadingComponent } from '@app/theme/components/theme-loading/theme-loading.component';
import { CifValidatorDirective } from '@app/directives/cif-validator.directive';
import { SecurityService } from '@app/modules/system-options/services/security.service';

import { take } from 'rxjs';

@Component({
  selector: 'general-configuration',
  templateUrl: './general-configuration.component.html',
  styles: `
    :host {
      .vh-77 {
        height: 77vh;
      }

      .footer {
        position: absolute;
        width: 100vw;
        min-width: calc(100% - 290px);
        max-width: 100%;
        bottom: 0px;
        right: 0px;
        height: 48px;
        border-top: 1px solid #d5dde0;
      }

      .button-container {
        display: flex;
        justify-content: flex-end;
        align-items: center;
        flex-direction: row;
        min-height: 46px;
        padding-right: 16px;
      }
    }
  `,
  providers: [SecurityCompanyClient],
  imports: [
    FormsModule,
    ReactiveFormsModule,
    MatFormField,
    MatLabel,
    MatInput,
    MatError,
    CifValidatorDirective,
    MatButton,
    TranslateModule,
    ThemeLoadingComponent
  ]
})
export class GeneralConfigurationComponent {
  private readonly securityCompanyClient = inject(SecurityCompanyClient);
  dialog = inject(MatDialog);
  private readonly sharedMessageService = inject(SharedMessageService);
  securityService = inject(SecurityService);
  private readonly translate = inject(TranslateService);
  accessService = inject(AccessService);
  private readonly fb = inject(FormBuilder);

  generalConfigurationForm!: FormGroup;
  loadForm: boolean = false;
  showPassword: boolean = false;

  get nameCtrl() {
    return this.generalConfigurationForm.controls['name'];
  }

  get cifCtrl() {
    return this.generalConfigurationForm.controls['cif'];
  }

  get isEnglish() {
    return localStorage.getItem('language')?.includes('en');
  }

  get permissions() {
    return localStorage.getItem('permissions');
  }

  get securityCompanyId() {
    return this.permissions ? JSON.parse(this.permissions)[0].securityCompanyId : null;
  }

  setGeneralConfigurationFormValues(company: SecurityCompanyView) {
    const disabled = !this.accessService.companyConfigurationModification();
    this.generalConfigurationForm = this.fb.group({
      id: [company.id],
      name: [{ value: company.name, disabled }, [Validators.required]],
      cif: [{ value: company.cif, disabled }, [Validators.required]],
      securityCompanyConfigurationId: [company.securityCompanyConfigurationId],
      securityCompanyConfiguration: [company.securityCompanyConfiguration],
      securityCompanyGroupId: [company.securityCompanyGroupId]
    });
    this.loadForm = true;
  }

  ngOnInit() {
    this.securityCompanyClient
      .getById(this.securityCompanyId, 'CompanyConfiguration')
      .pipe(take(1))
      .subscribe({
        next: (company: SecurityCompanyView) => {
          this.setGeneralConfigurationFormValues(company);
        },
        error: (e) => console.error(e)
      });
  }

  showPasswordInputs() {
    this.showPassword = !this.showPassword;
  }

  resetPasswordFields() {
    this.generalConfigurationForm.patchValue({
      password: null,
      passwordConfirmation: null
    });
  }

  onSubmit() {
    const DATA = this.generalConfigurationForm.getRawValue();
    this.securityCompanyClient.update(DATA, 'CompanyConfiguration').subscribe({
      next: () => {
        this.showPassword = false;
        this.sharedMessageService.showMessage(this.translate.instant('UPDATE_SUCCESS'));
      },
      error: (err) => this.sharedMessageService.showError(err)
    });
  }
}
