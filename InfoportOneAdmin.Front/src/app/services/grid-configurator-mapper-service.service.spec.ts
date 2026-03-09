import { TestBed } from '@angular/core/testing';
import { of } from 'rxjs';
import { GridConfiguratorMapperServiceService } from './grid-configurator-mapper-service.service';
import { SecurityUserGridConfigurationClient } from '@restApi/api/apiClients';

describe('GridConfiguratorMapperServiceService', () => {
  let service: GridConfiguratorMapperServiceService;
  const mockClient = {
    getUserGridConfigurations: jasmine.createSpy('getUserGridConfigurations').and.returnValue(
      of([
        { id: 1, entity: 'organizationsGrid', description: 'Default', configuration: JSON.stringify({}), defaultConfiguration: true }
      ])
    ),
    insert: jasmine.createSpy('insert').and.callFake((x: any) => of(x)),
    update: jasmine.createSpy('update').and.callFake((x: any) => of(x)),
    deleteById: jasmine.createSpy('deleteById').and.returnValue(of(null))
  } as any;

  beforeEach(() => {
    TestBed.configureTestingModule({ providers: [{ provide: SecurityUserGridConfigurationClient, useValue: mockClient }, GridConfiguratorMapperServiceService] });
    service = TestBed.inject(GridConfiguratorMapperServiceService);
  });

  it('getUserGridConfigurations maps server models to ClGridSavedConfig', (done) => {
    service.getUserGridConfigurations('organizationsGrid').subscribe((res) => {
      expect(res.length).toBe(1);
      expect((res[0] as any).configurationName).toBe('Default');
      done();
    });
  });

  it('create calls client.insert and returns mapped config', (done) => {
    const item: any = { id: 0, idGrid: 'organizationsGrid', configurationName: 'X', gridPersistedState: {} };
    service.create(item).subscribe((res) => {
      expect(mockClient.insert).toHaveBeenCalled();
      expect((res as any).configurationName).toBe('X');
      done();
    });
  });
});
