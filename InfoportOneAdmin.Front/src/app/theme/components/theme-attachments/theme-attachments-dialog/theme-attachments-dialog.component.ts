import { CommonModule } from '@angular/common';
import { Component, EventEmitter, Input, OnInit, Output, inject, Optional } from '@angular/core';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { IAttachmentTypeView, IAttachmentView, IVehiculoView } from '@restApi/api/apiClients';
import { Observable, take } from 'rxjs';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatSelectModule } from '@angular/material/select';
import { MatInputModule } from '@angular/material/input';
import { ThemeFilesService } from '@app/theme/services/theme-files.service';
import { ThemeLoadingComponent } from '@app/theme/components/theme-loading/theme-loading.component';
import { AttachmentsConfigEndpoints } from '@app/theme/models/theme-attachments.model';
import { SharedMessageService } from '@app/theme/services/shared-message.service';
import { ThemeAttachmentsService } from '@app/theme/services/theme-attachments.service';
import { MatIconModule } from '@angular/material/icon';
import { MatTooltipModule } from '@angular/material/tooltip';
import { DialogModule, DialogRef } from '@progress/kendo-angular-dialog';

import { ClButtonComponent } from '@cl/common-library/cl-buttons';
import { ClComboBoxComponent, ClInputComponent, ClInputTextAreaComponent } from '@cl/common-library/cl-form-fields';

@Component({
  selector: 'app-theme-attachments-dialog',
  imports: [
    ReactiveFormsModule,
    CommonModule,
    ThemeLoadingComponent,
    TranslateModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatIconModule,
    MatTooltipModule,
    DialogModule,
    ClButtonComponent,
    ClInputComponent,
    ClComboBoxComponent,
    ClInputTextAreaComponent
  ],
  templateUrl: './theme-attachments-dialog.component.html',
  styleUrl: './theme-attachments-dialog.component.scss'
})
export class ThemeAttachmentsDialogComponent implements OnInit {
  private fb = inject(FormBuilder);
  private themeFilesService = inject(ThemeFilesService);
  private themeAttachmentsService = inject(ThemeAttachmentsService);
  private sharedMessageService = inject(SharedMessageService);
  private dialogRef = inject(DialogRef, { optional: true });
  private readonly translate = inject(TranslateService);

  @Input() public id: number;
  @Input() public endpoints: AttachmentsConfigEndpoints;
  @Input() public entityId: number;
  @Input() public width: number | string;
  @Input() public height: number | string;
  @Input() public size: 'XS' | 'S' | 'M' | 'L' | 'XL' | 'XXL';

  @Output() formReady = new EventEmitter<void>();
  @Output() refreshGrid = new EventEmitter<IAttachmentView>();

  attachmentsForm: FormGroup;

  loading: boolean = false;
  disableDownload: boolean = false;

  attachmentTypeList$: Observable<IAttachmentTypeView[]>;

  get attachmentDescriptionCtrl() {
    return this.attachmentsForm.controls['attachmentDescription'];
  }

  get attachmentType() {
    return this.attachmentsForm.get('attachmentType').value;
  }

  get isNew() {
    return this.id === 0;
  }

  ngOnInit(): void {
    this.attachmentTypeList$ = this.endpoints.getAll();
    const ENDPOINS = this.id > 0 ? this.endpoints.getById(this.id) : this.endpoints.getNewAttachmentEntity(this.entityId);
    ENDPOINS.pipe(take(1)).subscribe((attachment: IAttachmentView) => {
      /**
       * Rellenamos los datos de nuestro form
       */
      this.setAttachmentFormValues(attachment);
    });
  }

  setAttachmentFormValues(attachment: IAttachmentView) {
    this.attachmentsForm = this.fb.group({
      id: [attachment.id],
      fileName: [{ value: attachment.fileName, disabled: true }],
      fileExtension: [{ value: attachment.fileExtension, disabled: true }],
      fileSizeKb: [{ value: attachment.fileSizeKb, disabled: true }],
      attachmentTypeId: [attachment.attachmentTypeId],
      attachmentType: [attachment.attachmentType, [Validators.required]],
      attachmentDescription: [attachment.attachmentDescription, [Validators.maxLength(2000)]],
      fileContent: [attachment.fileContent],
      entityDescription: [attachment.entityDescription],
      entityId: [attachment.entityId],
      entityName: [attachment.entityName],
      attachmentFileId: [attachment.attachmentFileId],
      attachmentFile: [attachment.attachmentFile]
    });

    this.onAttachmentsTypeChange();

    // Avisa de que el formulario, ya ha sido cargado.
    this.formReady.emit();
  }

  onAttachmentsTypeChange() {
    this.attachmentsForm.get('attachmentType').valueChanges.subscribe((event) => {
      if (event?.id) {
        this.attachmentsForm.patchValue({ attachmentTypeId: event.id });
      }
    });
  }

  async uploadFile(event: any) {
    if (event?.target?.files) {
      this.uploadAttachmentsFormPropertiesFromEvent(event);
      try {
        const archivoBase64 = await this.themeFilesService.uploadFile(event);
        this.attachmentsForm.patchValue({ fileContent: archivoBase64 });
        this.disableDownload = true;
        this.attachmentsForm.markAsDirty();
      } catch (e) {
        this.sharedMessageService.showError(e);
      }
    }
  }

  uploadAttachmentsFormPropertiesFromEvent(event: any) {
    const fichero = event.target.files[0];
    const isExtension = fichero.name.includes('.');

    let extension = 'unknown';
    let name = fichero.name;

    if (isExtension) {
      const split = fichero.name.split('.');
      extension = split[split.length - 1];
      name = fichero.name.replace(/\.[^.]*$/, '');
    }

    this.attachmentsForm.patchValue({
      fileExtension: extension,
      fileName: name,
      fileSizeKb: this.themeFilesService.convertBytesToKB(fichero.size)
    });
  }

  downloadFile() {
    this.themeAttachmentsService.downloadFile(this.id, this.endpoints.getAttachmentContent);
  }

  onSubmit() {
    const DATA = this.attachmentsForm.getRawValue();
    this.loading = true;
    const ENDPOINT = DATA.id > 0 ? this.endpoints.update(DATA) : this.endpoints.insert(DATA);
    ENDPOINT.pipe(take(1)).subscribe({
      next: (res) => {
        this.loading = false;
        const MESSAGE = DATA.id > 0 ? 'UPDATE_SUCCESS' : 'INSERT_SUCCESS';
        this.sharedMessageService.showMessage(this.translate.instant(MESSAGE));
        this.refreshGrid.emit(res);
      },
      error: (err) => {
        this.sharedMessageService.showError(err);
        this.loading = false;
      }
    });
  }

  cancel() {
    if (this.dialogRef) {
      this.dialogRef.close({ accepted: false });
    }
  }
}
