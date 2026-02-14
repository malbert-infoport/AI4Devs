import { Component, OnInit, ViewChild, inject } from '@angular/core';
import { NgForm, FormsModule } from '@angular/forms';

import { MAT_DIALOG_DATA, MatDialogRef, MatDialogTitle, MatDialogContent, MatDialogActions } from '@angular/material/dialog';
import { MatButton } from '@angular/material/button';
import { MatCheckbox } from '@angular/material/checkbox';
import { MatAccordion, MatExpansionPanel, MatExpansionPanelHeader, MatExpansionPanelTitle } from '@angular/material/expansion';
import { MatInput } from '@angular/material/input';
import { MatFormField, MatLabel } from '@angular/material/form-field';

import { TranslateModule } from '@ngx-translate/core';

import { SecurityProfileClient, SecurityProfileView } from '@restApi/api/apiClients';

import { AccessService } from '@app/theme/access/access.service';
import { ThemeLoadingComponent } from '@app/theme/components/theme-loading/theme-loading.component';

import { Observable, take } from 'rxjs';
@Component({
  selector: 'app-profile-detail',
  templateUrl: './profile-detail.component.html',
  styles: `
    .mat-mdc-form-field + .mat-form-field {
      margin-left: 8px;
    }
  `,
  providers: [SecurityProfileClient],
  imports: [
    MatDialogTitle,
    FormsModule,
    MatDialogContent,
    ThemeLoadingComponent,
    MatFormField,
    MatLabel,
    MatInput,
    MatAccordion,
    MatExpansionPanel,
    MatExpansionPanelHeader,
    MatExpansionPanelTitle,
    MatCheckbox,
    MatDialogActions,
    MatButton,
    TranslateModule
  ]
})
export class ProfileDetailComponent implements OnInit {
  dialogRef = inject<MatDialogRef<ProfileDetailComponent>>(MatDialogRef);
  data = inject(MAT_DIALOG_DATA);
  private securityProfileClient = inject(SecurityProfileClient);
  accessService = inject(AccessService);

  @ViewChild('form') form!: NgForm;
  model!: SecurityProfileView;
  panelOpenState = false;

  get modificacionPerfiles() {
    return this.accessService.profilesModification();
  }

  get id() {
    return this.data.data.id;
  }

  ngOnInit() {
    const profileObservable: Observable<SecurityProfileView> =
      this.id > 0
        ? this.securityProfileClient.getById(this.id, 'ProfileWithModules')
        : this.securityProfileClient.getNewEntity();

    profileObservable.pipe(take(1)).subscribe((profile: SecurityProfileView) => {
      this.model = profile;
    });
  }

  onSubmit(form: NgForm) {
    const dialogRef = this.dialogRef;
    const data = this.model;

    const insertOrUpdateAction =
      this.id > 0
        ? this.securityProfileClient.update(this.model, 'ProfileWithModules')
        : this.securityProfileClient.insert(this.model, 'ProfileWithModules');

    insertOrUpdateAction.pipe(take(1)).subscribe({
      complete() {
        dialogRef.close({ accepted: true, data });
      }
    });
  }
  cancel(): void {
    this.dialogRef.close({ accepted: false });
  }
}
