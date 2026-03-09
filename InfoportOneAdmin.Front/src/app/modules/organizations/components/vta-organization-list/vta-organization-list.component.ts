import { ChangeDetectorRef, Component, OnInit, ViewChild, TemplateRef, inject, OnDestroy } from '@angular/core';
import { TranslateService } from '@ngx-translate/core';
import { CommonModule } from '@angular/common';
import { ClGridComponent, ClGridConfig, ClGridColumn, ClGridState, IClGridConfiguratorEndpoints, ClFilterableSettings, ClExcelExport } from '@cl/common-library/cl-grid';
import { ClModalConfig, ClModalService } from '@cl/common-library/cl-modal';
import { State } from '@progress/kendo-data-query';
import { TranslateModule } from '@ngx-translate/core';
import { GridDataResult } from '@progress/kendo-angular-grid';
import { take, Subject, debounceTime, distinctUntilChanged, map } from 'rxjs';
import { VtaOrganizationService } from '../../services/vta-organization.service';
import { VTA_OrganizationClient } from '../../../../../webServicesReferences/api/apiClients';
import { SharedMessageService } from '@app/theme/services/shared-message.service';
import { SecurityUserGridConfigurationClient } from '@restApi/api/apiClients';
import { ClGridConfiguratorEndpointsRequestMapToHelix } from '@app/theme/modules/common-library/models/cl-grid-config.model';
import { GridConfiguratorMapperServiceService } from '@app/services/grid-configurator-mapper-service.service';
import { ReactiveFormsModule, FormsModule } from '@angular/forms';
import { ClButtonComponent } from '@cl/common-library/cl-buttons';
import { Router } from '@angular/router';

@Component({
  selector: 'app-vta-organization-list',
  standalone: true,
  imports: [CommonModule, ClGridComponent, TranslateModule, ReactiveFormsModule, FormsModule, ClButtonComponent],
  providers: [VTA_OrganizationClient, VtaOrganizationService, SecurityUserGridConfigurationClient],
  templateUrl: './vta-organization-list.component.html',
  styleUrls: ['./vta-organization-list.component.scss']
})
export class VtaOrganizationListComponent implements OnInit, OnDestroy {
  private readonly orgService = inject(VtaOrganizationService);
  private readonly cdRef = inject(ChangeDetectorRef);
  private readonly sharedMessageService = inject(SharedMessageService);
  private readonly translate = inject(TranslateService);
  private readonly router = inject(Router);
  private readonly clModalService = inject(ClModalService);
  private readonly securityUserGridConfigurationClient = inject(SecurityUserGridConfigurationClient);
  private readonly gridConfiguratorMapperService = inject(GridConfiguratorMapperServiceService);

  // search removed to match Sintraport viajes toolbar (filters handled by grid)

  @ViewChild('noRecordsTemplate', { static: true }) noRecordsTemplate!: TemplateRef<any>;
  @ViewChild('columnsTemplate', { static: true }) columnsTemplate!: TemplateRef<any>;
  @ViewChild('toolbarRight', { static: true }) toolbarRight!: TemplateRef<any>;
  @ViewChild('footerTemplate', { static: true }) footerTemplate!: TemplateRef<any>;

  gridConfig: ClGridConfig;
  gridData: GridDataResult = { data: [], total: 0 };
  public state!: State | ClGridState;
  public showSpinner = false;
  public columnsConfigurator: { field: string; title: string; hidden?: boolean }[] = [];

  ngOnInit(): void {
    const idGrid = 'organizationsGrid';
    // grid configurator endpoints for persisting column configuration
    const gridConfiguratorEndpoints: IClGridConfiguratorEndpoints = {
      create: this.gridConfiguratorMapperService.create,
      update: this.gridConfiguratorMapperService.update,
      deleteById: this.gridConfiguratorMapperService.deleteById,
      getUserGridConfigurations: this.gridConfiguratorMapperService.getUserGridConfigurations
    };

    this.gridConfig = new ClGridConfig({
      idGrid,
      selectBy: 'Id',
      mode: 'server-side',
      pageable: true,
      persistState: false,
      filterable: new ClFilterableSettings({ hideToolbarFilter: false, hideSearcherFilter: true }),
      footerTemplate: this.footerTemplate,
      showColumnsConfigurator: true,
      // Place a text refresh button on the right (like Viajes) and hide the default refresh placed at the end
      showRefreshButton: false,
      exportToExcel: new ClExcelExport({
        fileName: 'Organizaciones.xlsx',
        endpoint: (s: State) =>
          this.orgService.getAll(s).pipe(
            map((res: any) => {
              const raw = res.list || res.items || res.data || [];
              return this.mapRawToGridItems(raw);
            })
          )
      }),
      sortable: { hideToolbarOrder: true },
      toolbarTemplates: {
        templateLeft: null,
        templateRight: null
      },
      gridConfiguratorEndpoints: gridConfiguratorEndpoints,
      columns: this.buildColumns(),
      rowClassCallback: (ctx) => {
        const item = (ctx as any).dataItem;
        return { 'row-inactive': !!item?.AuditDeletionDate, 'row-pending': item?.ModuleCount === 0 };
      }
    });
    // wire toolbarRight template (templateRef available via static ViewChild)
    if (this.toolbarRight) this.gridConfig.toolbarTemplates.templateRight = this.toolbarRight;
    // initialize state and load first page (pass full Kendo state to backend)
    this.state = { data: this.gridConfig.state } as ClGridState;

    this.loadData(this.state as State);
  }

  private mapRawToGridItems(raw: any[]): any[] {
    return (raw || []).map((it: any) => ({
      Id: it.id ?? it.Id,
      SecurityCompanyId: it.securityCompanyId ?? it.SecurityCompanyId,
      GroupId: it.groupId ?? it.GroupId,
      GroupName: it.groupName ?? it.GroupName ?? (it.groupId ?? ''),
      Name: it.name ?? it.Name,
      TaxId: it.taxId ?? it.TaxId,
      ContactEmail: it.contactEmail ?? it.ContactEmail,
      ContactPhone: it.contactPhone ?? it.ContactPhone,
      AuditCreationUser: it.auditCreationUser ?? it.AuditCreationUser,
      AuditCreationDate: it.auditCreationDate ?? it.AuditCreationDate,
      AuditModificationUser: it.auditModificationUser ?? it.AuditModificationUser,
      AuditModificationDate: it.auditModificationDate ?? it.AuditModificationDate,
      ModuleCount: it.moduleCount ?? it.ModuleCount ?? 0,
      AppCount: it.appCount ?? it.AppCount ?? 0,
      _raw: it
    }));
  }

  buildColumns(): ClGridColumn[] {
    const cols = [
      {
        field: 'SecurityCompanyId',
        title: this.translate.instant('ORGANIZATIONS.COLUMNS.COMPANY'),
        width: 120,
        filterable: true,
        filter: 'numeric'
      },
      { field: 'Name', title: this.translate.instant('ORGANIZATIONS.COLUMNS.NAME'), width: 250, filterable: true, filter: 'text' },
      { field: 'TaxId', title: this.translate.instant('ORGANIZATIONS.COLUMNS.TAXID'), width: 140, filterable: true, filter: 'text' },
      { field: 'ContactEmail', title: this.translate.instant('ORGANIZATIONS.COLUMNS.EMAIL'), width: 200, filterable: true, filter: 'text' },
      { field: 'ContactPhone', title: this.translate.instant('ORGANIZATIONS.COLUMNS.PHONE'), width: 140, filterable: true, filter: 'text' },
      { field: 'GroupName', title: this.translate.instant('ORGANIZATIONS.COLUMNS.GROUP'), width: 160, filterable: true, filter: 'text' },
      { field: 'AppCount', title: this.translate.instant('ORGANIZATIONS.COLUMNS.APPS'), width: 100, filterable: true, filter: 'numeric' },
      { field: 'ModuleCount', title: this.translate.instant('ORGANIZATIONS.COLUMNS.MODULES'), width: 100, filterable: true, filter: 'numeric' },
      { field: 'Actions', title: this.translate.instant('ORGANIZATIONS.COLUMNS.ACTIONS'), width: 160, filterable: false }
    ] as any;

    // Keep a simple mirror for the columns configurator UI
    this.columnsConfigurator = cols.map((c: any) => ({ field: c.field, title: c.title, hidden: !!c.hidden }));

    return cols;
  }

  openColumnsModal() {
    const modal = new ClModalConfig({
      title: this.translate.instant('ORGANIZATIONS.COLUMN_MODAL.TITLE'),
      content: this.columnsTemplate,
      size: 'S',
      type: 'info',
      closeButton: { hidden: false, text: this.translate.instant('CANCEL') },
      submitButton: {
        hidden: false,
        text: this.translate.instant('ACCEPT'),
        action: () => {
          // Apply column visibility
          if (this.columnsConfigurator && this.gridConfig && Array.isArray(this.gridConfig.columns)) {
            this.columnsConfigurator.forEach((c) => {
              const col = (this.gridConfig.columns as any).find((x: any) => x.field === c.field);
              if (col) col.hidden = !!c.hidden;
            });
            this.cdRef.detectChanges();
          }
          return true; // close modal
        }
      }
    });

    this.clModalService.openModal(modal);
  }

  onDataStateChange(state: any) {
    this.state = state;
    this.loadData(state as State);
  }

  loadData(state: State | ClGridState) {
    const kState = state as State;
    console.log('[VtaOrganization] loadData state', kState);
    // Send the full Kendo `state` directly to the generated client (Sintraport pattern)
    this.showSpinner = true;
    this.orgService
      .getAll(kState)
      .pipe(take(1))
      .subscribe({
        next: (res: any) => {
          // Normalize possible backend response shapes: prefer `list`/`count` like Sintraport
          const raw = res.list || res.items || res.data || [];
          // Map API camelCase properties to grid expected PascalCase fields
          const data = (raw || []).map((it: any) => ({
            Id: it.id ?? it.Id,
            SecurityCompanyId: it.securityCompanyId ?? it.SecurityCompanyId,
            GroupId: it.groupId ?? it.GroupId,
            GroupName: it.groupName ?? it.GroupName ?? (it.groupId ?? ''),
            Name: it.name ?? it.Name,
            TaxId: it.taxId ?? it.TaxId,
            ContactEmail: it.contactEmail ?? it.ContactEmail,
            ContactPhone: it.contactPhone ?? it.ContactPhone,
            AuditCreationUser: it.auditCreationUser ?? it.AuditCreationUser,
            AuditCreationDate: it.auditCreationDate ?? it.AuditCreationDate,
            AuditModificationUser: it.auditModificationUser ?? it.AuditModificationUser,
            AuditModificationDate: it.auditModificationDate ?? it.AuditModificationDate,
            ModuleCount: it.moduleCount ?? it.ModuleCount ?? 0,
            AppCount: it.appCount ?? it.AppCount ?? 0,
            // keep original payload for advanced scenarios
            _raw: it
          }));

          this.gridData = {
            data,
            total: res.count ?? res.totalCount ?? res.total ?? 0
          };
          this.cdRef.detectChanges();
          this.showSpinner = false;
        },
        error: (err) => {
          this.sharedMessageService.showError(err);
          this.showSpinner = false;
        }
      });
  }

  // Keep helper for compatibility: return the state as-is so generated client receives full Kendo state
  buildKendoFilterFromState(state: State) {
    return state;
  }

  onSearch(value: string) {
    // deprecated; search handled via grid filters. Keep method to avoid template errors if referenced.
  }

  editItem(id: number) {
    // Navigate to edit page if route exists; fallback: show message
    if (id && id > 0) {
      try {
        this.router.navigate(['organizations', id]);
      } catch (e) {
        this.sharedMessageService.showMessage(this.translate.instant('NAVIGATE_TO_EDIT'));
      }
    }
  }

  toggleActive(item: any) {
    const active = !item?.AuditDeletionDate;
    const ok = confirm(active ? 'Confirm deactivate?' : 'Confirm reactivate?');
    if (!ok) return;
    // TODO: call backend endpoints for deactivate/reactivate when available
    this.sharedMessageService.showMessage(
      this.translate.instant(active ? 'ORGANIZATIONS.BUTTONS.DEACTIVATE' : 'ORGANIZATIONS.BUTTONS.REACTIVATE')
    );
  }

  ngOnDestroy(): void {}

  getRowClass({ dataItem }: any): string {
    if (dataItem?.AuditDeletionDate) return 'row-inactive';
    if (dataItem?.ModuleCount === 0) return 'row-pending';
    return '';
  }
}
