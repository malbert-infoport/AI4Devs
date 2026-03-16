import { TestBed, ComponentFixture } from '@angular/core/testing';
import { of } from 'rxjs';
import { VtaOrganizationListComponent } from './vta-organization-list.component';
import { VtaOrganizationService } from '../../services/vta-organization.service';
import { SharedMessageService } from '@app/theme/services/shared-message.service';
import { TranslateService } from '@ngx-translate/core';
import { Router } from '@angular/router';
import { ClModalService } from '@cl/common-library/cl-modal';
import { SecurityUserGridConfigurationClient } from '@restApi/api/apiClients';
import { GridConfiguratorMapperServiceService } from '@app/services/grid-configurator-mapper-service.service';

describe('mapRawToGridItems helper', () => {
  let fixture: ComponentFixture<VtaOrganizationListComponent>;
  let comp: VtaOrganizationListComponent;

  beforeEach(async () => {
    const orgServiceStub = { getAll: jasmine.createSpy('getAll').and.returnValue(of({ list: [], count: 0 })) };

    await TestBed.configureTestingModule({
      imports: [VtaOrganizationListComponent],
      providers: [
        { provide: VtaOrganizationService, useValue: orgServiceStub },
        { provide: SharedMessageService, useValue: { showError: () => {} } },
        { provide: TranslateService, useValue: { instant: (k: string) => k } },
        { provide: Router, useValue: { navigate: () => {} } },
        { provide: ClModalService, useValue: { openModal: () => {} } },
        { provide: SecurityUserGridConfigurationClient, useValue: { getUserGridConfigurations: () => of([]) } },
        { provide: GridConfiguratorMapperServiceService, useValue: { getUserGridConfigurations: () => of([]) } }
      ]
    }).compileComponents();

    fixture = TestBed.createComponent(VtaOrganizationListComponent);
    comp = fixture.componentInstance;
  });

  it('maps camelCase raw items to PascalCase fields', () => {
    const raw = [
      {
        id: 10,
        securityCompanyId: 5,
        groupId: 2,
        groupName: 'G1',
        name: 'OrgName',
        taxId: 'TAX',
        contactEmail: 'a@b.com',
        contactPhone: '123',
        auditCreationUser: 1,
        auditCreationDate: '2020-01-01',
        auditModificationUser: 2,
        auditModificationDate: '2020-02-01',
        moduleCount: 3,
        appCount: 4
      }
    ];

    // access method via instance
    // @ts-ignore
    const out = (comp as any).mapRawToGridItems(raw);
    expect(out.length).toBe(1);
    expect(out[0].Id).toBe(10);
    expect(out[0].SecurityCompanyId).toBe(5);
    expect(out[0].GroupName).toBe('G1');
    expect(out[0].Name).toBe('OrgName');
    expect(out[0].ModuleCount).toBe(3);
  });
});
