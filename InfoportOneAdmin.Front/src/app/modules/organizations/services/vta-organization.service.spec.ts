import { TestBed } from '@angular/core/testing';
import { of } from 'rxjs';
import { VtaOrganizationService } from './vta-organization.service';
import { VTA_OrganizationClient } from '../../../../webServicesReferences/api/apiClients';

describe('VtaOrganizationService', () => {
  let service: VtaOrganizationService;
  const mockClient = {
    getAllKendoFilter: jasmine.createSpy('getAllKendoFilter').and.returnValue(of({ list: [], count: 0 }))
  };

  beforeEach(() => {
    TestBed.configureTestingModule({ providers: [{ provide: VTA_OrganizationClient, useValue: mockClient }, VtaOrganizationService] });
    service = TestBed.inject(VtaOrganizationService);
  });

  it('should call client.getAllKendoFilter with { data: state } when state provided', (done) => {
    const state = { skip: 0, take: 10 };
    service.getAll(state).subscribe(() => {
      expect(mockClient.getAllKendoFilter).toHaveBeenCalledWith({ data: state });
      done();
    });
  });
});
