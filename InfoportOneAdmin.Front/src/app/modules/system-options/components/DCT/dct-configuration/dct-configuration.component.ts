import { Component, inject, OnInit, ViewEncapsulation, ViewChild } from '@angular/core';
import { AttachmentClient, AttachmentTypeClient, InformeDCTClient, InformeDCTView } from '@restApi/api/apiClients';
import { map, of, switchMap, take } from 'rxjs';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { ClCheckboxComponent, ClInputTextAreaComponent } from '@cl/common-library/cl-form-fields';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { ClBreadcrumbComponent, ClBreadcrumbItem, ClBreadcrumbService } from '@cl/common-library/cl-breadcrumb';
import { KENDO_EDITOR, FontFamilyItem, EditorComponent } from '@progress/kendo-angular-editor';
import { KENDO_LABEL } from '@progress/kendo-angular-label';
import { KENDO_TOOLBAR } from '@progress/kendo-angular-toolbar';
import { ClButtonComponent } from '@cl/common-library/cl-buttons';
import { ThemeLoadingComponent } from '@app/theme/components/theme-loading/theme-loading.component';
import { SharedMessageService } from '@app/theme/services/shared-message.service';
import { ThemeAttachmentsComponent } from '@app/theme/components/theme-attachments/theme-attachments.component';
import { ThemeAttachmentsConfiguration, AtthachmentsDialogConfig } from '@app/theme/models/theme-attachments.model';
import { AttachmentType } from '@app/theme/enums/attachment-type.enum';
import { AccessService } from '@app/theme/access/access.service';

@Component({
  selector: 'dct-configuration',
  imports: [
    CommonModule,
    ReactiveFormsModule,
    ClCheckboxComponent,
    ClInputTextAreaComponent,
    ClBreadcrumbComponent,
    ClButtonComponent,
    TranslateModule,
    ThemeLoadingComponent,
    KENDO_EDITOR,
    KENDO_LABEL,
    KENDO_TOOLBAR,
    ThemeAttachmentsComponent
  ],
  templateUrl: './dct-configuration.component.html',
  styleUrls: ['./dct-configuration.component.scss'],
  providers: [InformeDCTClient, AttachmentTypeClient, AttachmentClient],
  encapsulation: ViewEncapsulation.None
})
export class DCTConfigurationComponent implements OnInit {
  private readonly informeDCTClient = inject(InformeDCTClient);
  private readonly fb = inject(FormBuilder);
  private readonly breadcrumbService = inject(ClBreadcrumbService);
  private readonly translate = inject(TranslateService);
  private readonly sharedMessageService = inject(SharedMessageService);
  private attachmentTypeClient = inject(AttachmentTypeClient);
  private attachmentClient = inject(AttachmentClient);
  public readonly accessService = inject(AccessService);

  public attachmentsConfiguration: ThemeAttachmentsConfiguration;
  showSpinner: boolean = false;

  DCTForm: FormGroup;

  maxBreadcrumbItems: number = 3;
  breadcrumbItems: ClBreadcrumbItem[] = [];

  @ViewChild(EditorComponent) editor: EditorComponent;

  // Configuración de fuentes disponibles
  fontFamilyOptions: FontFamilyItem[] = [
    { text: 'Arial', fontName: 'Arial, Helvetica, sans-serif' },
    { text: 'Courier New', fontName: '"Courier New", Courier, monospace' },
    { text: 'Georgia', fontName: 'Georgia, serif' },
    { text: 'Impact', fontName: 'Impact, Charcoal, sans-serif' },
    { text: 'Inter', fontName: 'Inter, sans-serif' },
    { text: 'Lucida Console', fontName: '"Lucida Console", Monaco, monospace' },
    { text: 'Tahoma', fontName: 'Tahoma, Geneva, sans-serif' },
    { text: 'Times New Roman', fontName: '"Times New Roman", Times, serif' },
    { text: 'Trebuchet MS', fontName: '"Trebuchet MS", Helvetica, sans-serif' },
    { text: 'Verdana', fontName: 'Verdana, Geneva, sans-serif' }
  ];

  // REVISAR (D A C)
  // // Computed signal - se actualiza automáticamente cuando cambia la delegación activa
  // delegacionActiva = this.delegacionService.delegacionActiva;

  constructor() {
    // REVISAR (D A C)
    // effect(() => {
    //   const delegacion = this.delegacionActiva();
    //   if (delegacion) {
    //     this.updateBreadcrumbItems(delegacion.name);
    //     this.showSpinner = true;
    //     this.informeDCTClient
    //       .getConfiguracion()
    //       .pipe(
    //         take(1),
    //         switchMap((data) => (data?.id > 0 ? of(data) : this.informeDCTClient.getNewEntity()))
    //       )
    //       .subscribe({
    //         next: (dct) => {
    //           this.showSpinner = false;
    //           if (!this.DCTForm) {
    //             this.setDCTFormValues(dct, delegacion.id);
    //             this.attachmentsConfiguration = this.getAttachmnetsConfig(dct?.id);
    //           }
    //         }
    //       });
    //   }
    // });
  }
  ngOnInit(): void {
    this.updateBreadcrumbItems();
    this.showSpinner = true;
    this.informeDCTClient
      .getConfiguracion()
      .pipe(
        take(1),
        switchMap((data) => (data?.id > 0 ? of(data) : this.informeDCTClient.getNewEntity()))
      )
      .subscribe({
        next: (dct) => {
          this.showSpinner = false;
          if (!this.DCTForm) {
            this.setDCTFormValues(dct, dct.securityCompanyId);
            this.attachmentsConfiguration = this.getAttachmnetsConfig(dct?.id);
          }
        }
      });
  }

  updateBreadcrumbItems(nombreSecurityCompany?: string) {
    this.breadcrumbItems = [
      { text: this.translate.instant('SYSTEM_OPTIONS.DCT.CONFIGURATION'), url: null }
      //{ text: nombreSecurityCompany, icon: { name: 'house-simple', classes: null }, url: null }
    ];
  }

  setDCTFormValues(DCT: InformeDCTView, securityCompanyId: number) {
    this.DCTForm = this.fb.group({
      id: [DCT?.id, [Validators.required]],
      securityCompanyId: [securityCompanyId, [Validators.required]],
      mostrarDireccion: [DCT.mostrarDireccion],
      mostrarLogo: [DCT.mostrarLogo],
      observaciones: [DCT.observaciones],
      pieDeInforme: [DCT.pieDeInforme],
      pieDePagina: [DCT.pieDePagina, [Validators.maxLength(500)]]
    });

    // Deshabilitar formulario si no tiene permisos de modificación
    if (!this.viajesModificacion) {
      this.DCTForm.disable();
    }
  }

  get viajesModificacion() {
    return this.accessService.maestroViajesModificacion();
  }

  getAttachmnetsConfig(entityId: number): ThemeAttachmentsConfiguration {
    return new ThemeAttachmentsConfiguration({
      endpoints: {
        getAll: () =>
          this.attachmentTypeClient
            .getAll()
            .pipe(map((items) => items.filter((item) => item.id === AttachmentType['Logo DCT']))), // 4
        insert: this.attachmentClient.insert.bind(this.attachmentClient),
        update: this.attachmentClient.update.bind(this.attachmentClient),
        deleteById: (id: number) => this.attachmentClient.deleteById(id, 'Defecto'),
        getById: (id: number) => this.attachmentClient.getById(id, 'Defecto'),
        getAttachmentContent: this.attachmentClient.getAttachmentContent.bind(this.attachmentClient),
        getAllVTAAttachmentsKendoFilter: this.informeDCTClient.getAllVTAAttachmentsKendoFilter.bind(this.informeDCTClient),
        getNewAttachmentEntity: (id: number) =>
          this.informeDCTClient.getNewAttachmentEntity(id).pipe(
            map((attachment: any) => ({
              ...attachment,
              attachmentTypeId: AttachmentType['Logo DCT'], // 4
              attachmentType: {
                id: AttachmentType['Logo DCT'], // 4
                description: AttachmentType[AttachmentType['Logo DCT']] // 'Logo DCT'
              }
            }))
          )
      },
      entityId: entityId,
      idGrid: 'DCTAttachmentsGrid',
      dialogConfig: new AtthachmentsDialogConfig({ width: 1200, height: 'auto' })
    });
  }

  onSubmit() {
    if (this.DCTForm.invalid) {
      return;
    }

    const DATA = this.DCTForm.getRawValue();
    const api$ = DATA.id > 0 ? this.informeDCTClient.update(DATA) : this.informeDCTClient.insert(DATA);
    this.showSpinner = true;
    api$.pipe(take(1)).subscribe({
      next: (data: any) => {
        const MESSAGE = DATA.id > 0 ? 'UPDATE_SUCCESS' : 'INSERT_SUCCESS';
        this.sharedMessageService.showMessage(this.translate.instant(MESSAGE));
        this.DCTForm.patchValue(data);
        this.showSpinner = false;
      },
      error: (err) => {
        this.showSpinner = false;
        this.sharedMessageService.showError(err);
      }
    });
  }
}
