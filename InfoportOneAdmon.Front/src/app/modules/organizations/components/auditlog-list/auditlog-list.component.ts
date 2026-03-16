import { ChangeDetectorRef, Component, OnInit, ViewChild, TemplateRef, inject, OnDestroy, Input, OnChanges, SimpleChanges } from '@angular/core';
import { TranslateService } from '@ngx-translate/core';
import { CommonModule } from '@angular/common';
import {
  ClGridComponent,
  ClGridConfig,
  ClGridColumn,
  ClGridState,
  IClGridConfiguratorEndpoints,
  ClFilterableSettings,
  ClExcelExport,
  ClSortableSettings
} from '@cl/common-library/cl-grid';
import { State } from '@progress/kendo-data-query';
import { TranslateModule } from '@ngx-translate/core';
import { GridDataResult } from '@progress/kendo-angular-grid';
import { take, map } from 'rxjs/operators';
import { AuditLogClient, KendoDataFilter, KendoGridFilter } from '../../../../../webServicesReferences/api/apiClients';
import { SecurityUserGridConfigurationClient } from '@restApi/api/apiClients';
import { GridConfiguratorMapperServiceService } from '@app/services/grid-configurator-mapper-service.service';
import { SharedMessageService } from '@app/theme/services/shared-message.service';
import { ReactiveFormsModule, FormsModule } from '@angular/forms';
import { ClButtonComponent } from '@cl/common-library/cl-buttons';

@Component({
  selector: 'app-auditlog-list',
  standalone: true,
  imports: [CommonModule, ClGridComponent, TranslateModule, ReactiveFormsModule, FormsModule, ClButtonComponent],
  providers: [AuditLogClient, SharedMessageService],
  templateUrl: './auditlog-list.component.html',
  styleUrls: ['./auditlog-list.component.scss']
})
export class AuditlogListComponent implements OnInit, OnDestroy, OnChanges {
  private readonly auditLogClient = inject(AuditLogClient);
  private readonly cdRef = inject(ChangeDetectorRef);
  private readonly sharedMessageService = inject(SharedMessageService);
  private readonly translate = inject(TranslateService);

  @ViewChild('noRecordsTemplate', { static: true }) noRecordsTemplate!: TemplateRef<any>;
  @ViewChild('columnsTemplate', { static: true }) columnsTemplate!: TemplateRef<any>;
  @ViewChild('toolbarRight', { static: true }) toolbarRight!: TemplateRef<any>;

  gridConfig: ClGridConfig;
  gridData: GridDataResult = { data: [], total: 0 };
  public state!: State | ClGridState;
  public showSpinner = false;
  public columnsConfigurator: { field: string; title: string; hidden?: boolean }[] = [];
  @Input() organizationId?: number | null;

  private readonly gridConfiguratorMapperService = inject(GridConfiguratorMapperServiceService);
  private readonly securityUserGridConfigurationClient = inject(SecurityUserGridConfigurationClient);

  ngOnInit(): void {
    const idGrid = 'auditLogGrid';

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
      showRefreshButton: false,
      reorderable: true,
      showColumnsConfigurator: true,
      gridConfiguratorEndpoints: gridConfiguratorEndpoints,
      exportToExcel: new ClExcelExport({
        fileName: 'AuditLog.xlsx',
        endpoint: (s: State) =>
          this.auditLogClient
            .getAllKendoFilter(
              this.buildKendoGridFilter(
                this.withOrganizationFilters(
                  this.unwrapGridState((this.state as any) ?? (s as any))
                )
              ),
              '',
              false
            )
            .pipe(
              map((res: any) => {
                const raw = res.list || res.items || res.data || [];
                return (raw || []).map((it: any) => ({
                  Id: it.id ?? it.Id,
                  Timestamp: it.timestamp ?? it.Timestamp,
                  Action: it.action ?? it.Action,
                  UserLogin: it.userLogin ?? it.UserLogin ?? it.userId ?? it.UserId,
                  EntityType: it.entityType ?? it.EntityType,
                  EntityId: it.entityId ?? it.EntityId,
                  Content: it.content ?? it.Content
                }));
              })
            )
      }),
      sortable: new ClSortableSettings({ mode: 'multiple', allowUnsort: true, hideToolbarOrder: true }),
      toolbarTemplates: { templateLeft: null, templateRight: null },
      state: {
        skip: 0,
        take: 10,
        sort: [{ field: 'Timestamp', dir: 'desc' }]
      },
      columns: this.buildColumns()
    });

    if (this.toolbarRight) this.gridConfig.toolbarTemplates.templateRight = this.toolbarRight;

    this.state = { data: this.gridConfig.state } as ClGridState;
    this.loadData(this.state as State);
  }

  ngOnChanges(changes: SimpleChanges): void {
    if (changes['organizationId'] && !changes['organizationId'].isFirstChange()) {
      // refresh grid when organizationId changes
      this.loadData(this.state as State);
    }
  }

  buildColumns(): ClGridColumn[] {
    const cols = [
      { field: 'Timestamp', title: this.translate.instant('AUDITLOG.COLUMNS.TIMESTAMP'), width: 180, filterable: true, filter: 'date', sortable: true, dateConfig: { format: 'dd/MM/yyyy HH:mm' } },
      { field: 'Action', title: this.translate.instant('AUDITLOG.COLUMNS.ACTION'), width: 200, filterable: true, filter: 'text', sortable: true },
      { field: 'UserLogin', title: this.translate.instant('AUDITLOG.COLUMNS.USER'), width: 160, filterable: true, filter: 'text', sortable: true },
      { field: 'EntityType', title: this.translate.instant('AUDITLOG.COLUMNS.ENTITY'), width: 160, filterable: true, filter: 'text', sortable: true },
      { field: 'EntityId', title: this.translate.instant('AUDITLOG.COLUMNS.ENTITY_ID'), width: 120, filterable: true, filter: 'text', sortable: true },
      { field: 'Content', title: this.translate.instant('AUDITLOG.COLUMNS.CONTENT'), width: 400, filterable: true, filter: 'text', sortable: false }
    ] as any;

    this.columnsConfigurator = cols.map((c: any) => ({ field: c.field, title: c.title, hidden: !!c.hidden }));
    return cols;
  }

  onDataStateChange(state: any) {
    this.state = state;
    this.loadData(state as State);
  }

  loadData(state: State | ClGridState) {
    const kState = this.unwrapGridState(state as any);
    this.showSpinner = true;
    const filterState = this.withOrganizationFilters(kState);
    const kendoGridFilter = this.buildKendoGridFilter(filterState);

    this.auditLogClient
      .getAllKendoFilter(kendoGridFilter, '', false)
      .pipe(take(1))
      .subscribe({
        next: (res: any) => {
          const raw = res.list || res.items || res.data || [];
          const data = (raw || []).map((it: any) => ({
            Id: it.id ?? it.Id,
            Timestamp: it.timestamp ?? it.Timestamp,
            Action: it.action ?? it.Action,
            UserLogin: it.userLogin ?? it.UserLogin ?? it.userId ?? it.UserId,
            EntityType: it.entityType ?? it.EntityType,
            EntityId: it.entityId ?? it.EntityId,
            Content: it.content ?? it.Content,
            _raw: it
          }));

          this.gridData = { data, total: res.count ?? res.totalCount ?? res.total ?? 0 };
          this.cdRef.detectChanges();
          this.showSpinner = false;
        },
        error: (err) => {
          this.sharedMessageService.showError(err);
          this.showSpinner = false;
        }
      });
  }

  private unwrapGridState(state: any): State {
    return (state && state.data) ? (state.data as State) : (state as State);
  }

  private withOrganizationFilters(state: State): State {
    const filterState = { ...(state as any) } as any;
    const baseFilters = filterState.filter?.filters ?? [];
    const orgFilters = [{ field: 'EntityType', operator: 'eq', value: 'Organization' }] as any[];
    if (this.organizationId && this.organizationId > 0) {
      orgFilters.push({ field: 'EntityId', operator: 'eq', value: String(this.organizationId) });
    }
    filterState.filter = { logic: 'and', filters: [...baseFilters, ...orgFilters] };
    return filterState as State;
  }

  private buildKendoGridFilter(state: State): KendoGridFilter {
    const kendoDataFilter = KendoDataFilter.fromJS(state as any);
    return new KendoGridFilter({ data: kendoDataFilter });
  }

  ngOnDestroy(): void {}
}
