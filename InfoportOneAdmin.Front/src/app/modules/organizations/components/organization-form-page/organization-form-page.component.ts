import { CommonModule, Location } from '@angular/common';
import { Component, OnInit, TemplateRef, ViewChild, inject } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { ClButtonComponent } from '@cl/common-library/cl-buttons';
import { ClTabsComponent, IClTabData } from '@cl/common-library/cl-tabs';
import { SelectEvent } from '@progress/kendo-angular-layout';

@Component({
  selector: 'app-organization-form-page',
  standalone: true,
  imports: [CommonModule, TranslateModule, ClTabsComponent, ClButtonComponent],
  templateUrl: './organization-form-page.component.html',
  styleUrls: ['./organization-form-page.component.scss']
})
export class OrganizationFormPageComponent implements OnInit {
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly location = inject(Location);
  private readonly translate = inject(TranslateService);

  @ViewChild('generalDataTab', { static: true }) generalDataTab!: TemplateRef<any>;
  @ViewChild('modulesTab', { static: true }) modulesTab!: TemplateRef<any>;
  @ViewChild('auditTab', { static: true }) auditTab!: TemplateRef<any>;

  tabsData: IClTabData[] = [];
  selectedTabIndex = 0;
  organizationId = 0;

  get isNew(): boolean {
    return this.organizationId <= 0;
  }

  ngOnInit(): void {
    const idParam = this.route.snapshot.paramMap.get('id');
    this.organizationId = idParam ? Number(idParam) : 0;

    this.buildTabs();
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
}
