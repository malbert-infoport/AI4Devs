import { CommonModule, Location } from '@angular/common';
import { Component, OnInit, TemplateRef, ViewChild, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { ClButtonComponent } from '@cl/common-library/cl-buttons';
import { ClTabsComponent, IClTabData } from '@cl/common-library/cl-tabs';
import { SelectEvent } from '@progress/kendo-angular-layout';
import { ClComboBoxComponent, ClInputComponent } from '@cl/common-library/cl-form-fields';
import { MatIconModule } from '@angular/material/icon';
import { ThemeLoadingComponent } from '@app/theme/components/theme-loading/theme-loading.component';
import { SharedMessageService } from '@app/theme/services/shared-message.service';
import { OrganizationClient, OrganizationGroupClient, OrganizationGroupView, OrganizationView } from '../../../../../webServicesReferences/api/apiClients';
import { take } from 'rxjs';

@Component({
  selector: 'app-organization-form-page',
  standalone: true,
  imports: [
    CommonModule,
    TranslateModule,
    ReactiveFormsModule,
    ClTabsComponent,
    ClButtonComponent,
    ClComboBoxComponent,
    ClInputComponent,
    MatIconModule,
    ThemeLoadingComponent
  ],
  providers: [OrganizationClient, OrganizationGroupClient],
  templateUrl: './organization-form-page.component.html',
  styleUrls: ['./organization-form-page.component.scss']
})
export class OrganizationFormPageComponent implements OnInit {
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly location = inject(Location);
  private readonly translate = inject(TranslateService);
  private readonly fb = inject(FormBuilder);
  private readonly organizationClient = inject(OrganizationClient);
  private readonly organizationGroupClient = inject(OrganizationGroupClient);
  private readonly sharedMessageService = inject(SharedMessageService);

  @ViewChild('generalDataTab', { static: true }) generalDataTab!: TemplateRef<any>;
  @ViewChild('modulesTab', { static: true }) modulesTab!: TemplateRef<any>;
  @ViewChild('auditTab', { static: true }) auditTab!: TemplateRef<any>;

  tabsData: IClTabData[] = [];
  selectedTabIndex = 0;
  organizationId = 0;
  loading = false;
  saving = false;
  organizationGroups: OrganizationGroupView[] = [];
  readonly emptyGroupItem: OrganizationGroupView = new OrganizationGroupView({ id: null as any, groupName: '' });

  readonly organizationForm = this.fb.group({
    id: [0],
    securityCompanyId: [1, [Validators.required]],
    groupId: [null as number | null],
    name: ['', [Validators.required, Validators.maxLength(250)]],
    acronym: ['', [Validators.maxLength(50)]],
    taxId: ['', [Validators.required, Validators.maxLength(25)]],
    address: ['', [Validators.maxLength(250)]],
    city: ['', [Validators.maxLength(100)]],
    postalCode: ['', [Validators.maxLength(20)]],
    country: ['', [Validators.maxLength(100)]],
    contactEmail: ['', [Validators.email, Validators.maxLength(120)]],
    contactPhone: ['', [Validators.maxLength(50)]]
  });

  get isNew(): boolean {
    return this.organizationId <= 0;
  }

  ngOnInit(): void {
    const idParam = this.route.snapshot.paramMap.get('id');
    this.organizationId = idParam ? Number(idParam) : 0;

    this.buildTabs();
    this.loadGroupOptions();
    this.loadGeneralData();
  }

  onTabSelected(tabSelected: SelectEvent): void {
    this.selectedTabIndex = tabSelected.index;
  }

  onBack(): void {
    if (window.history.length > 1) {
      this.location.back();
      return;
    }

    this.router.navigate(['/protected/organizations']);
  }

  onSave(): void {
    if (this.organizationForm.invalid || this.saving) {
      this.organizationForm.markAllAsTouched();
      return;
    }

    this.saving = true;
    const rawValue = this.organizationForm.getRawValue() as any;
    const payload = new OrganizationView({
      ...rawValue,
      groupId: this.normalizeGroupId(rawValue.groupId)
    });
    const endpoint = payload.id && payload.id > 0
      ? this.organizationClient.update(payload, 'OrganizationComplete', true)
      : this.organizationClient.insert(payload, 'OrganizationComplete', true);

    endpoint.pipe(take(1)).subscribe({
      next: (saved) => {
        this.saving = false;
        this.organizationId = Number(saved?.id ?? this.organizationId ?? 0);
        this.patchForm(saved);

        const messageKey = (saved?.id ?? 0) > 0 && (payload.id ?? 0) > 0 ? 'UPDATE_SUCCESS' : 'INSERT_SUCCESS';
        this.sharedMessageService.showMessage(this.translate.instant(messageKey));

        if (this.organizationId > 0 && this.route.snapshot.paramMap.get('id') !== String(this.organizationId)) {
          this.router.navigate(['/protected/organizations', this.organizationId]);
        }
      },
      error: (err) => {
        this.saving = false;
        this.sharedMessageService.showError(err);
      }
    });
  }

  private buildTabs(): void {
    this.tabsData = [
      {
        title: this.translate.instant('ORGANIZATIONS.FORM.TABS.GENERAL_DATA'),
        content: this.generalDataTab
      },
      {
        title: this.translate.instant('ORGANIZATIONS.FORM.TABS.MODULES'),
        content: this.modulesTab
      },
      {
        title: this.translate.instant('ORGANIZATIONS.FORM.TABS.AUDIT'),
        content: this.auditTab
      }
    ];
  }

  private loadGeneralData(): void {
    this.loading = true;

    // Single call for initial load: new entity or current entity by id.
    const endpoint = this.isNew ? this.organizationClient.getNewEntity() : this.organizationClient.getById(this.organizationId, 'OrganizationComplete');

    endpoint.pipe(take(1)).subscribe({
      next: (organization) => {
        this.patchForm(organization);
        this.loading = false;
      },
      error: (err) => {
        this.loading = false;
        this.sharedMessageService.showError(err);
      }
    });
  }

  private patchForm(organization?: OrganizationView): void {
    this.organizationForm.patchValue({
      id: Number(organization?.id ?? 0),
      securityCompanyId: Number(organization?.securityCompanyId ?? 1),
      groupId: organization?.groupId ?? null,
      name: organization?.name ?? '',
      acronym: organization?.acronym ?? '',
      taxId: organization?.taxId ?? '',
      address: organization?.address ?? '',
      city: organization?.city ?? '',
      postalCode: organization?.postalCode ?? '',
      country: organization?.country ?? '',
      contactEmail: organization?.contactEmail ?? '',
      contactPhone: organization?.contactPhone ?? ''
    });
  }

  private loadGroupOptions(): void {
    this.organizationGroupClient
      .getAll(undefined, false)
      .pipe(take(1))
      .subscribe({
        next: (groups) => {
          this.organizationGroups = groups ?? [];
        },
        error: (err) => {
          this.sharedMessageService.showError(err);
          this.organizationGroups = [];
        }
      });
  }

  private normalizeGroupId(groupId: unknown): number | null {
    if (groupId == null) {
      return null;
    }

    if (typeof groupId === 'number') {
      return Number.isFinite(groupId) ? groupId : null;
    }

    if (typeof groupId === 'string') {
      const parsed = Number(groupId);
      return Number.isFinite(parsed) ? parsed : null;
    }

    if (typeof groupId === 'object' && 'id' in (groupId as Record<string, unknown>)) {
      const idValue = (groupId as Record<string, unknown>)['id'];
      const parsed = Number(idValue);
      return Number.isFinite(parsed) ? parsed : null;
    }

    return null;
  }
}
