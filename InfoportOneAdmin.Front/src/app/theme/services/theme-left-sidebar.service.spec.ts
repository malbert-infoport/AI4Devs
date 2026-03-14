import { TestBed } from '@angular/core/testing';
import { TranslateService } from '@ngx-translate/core';

import { ThemeLeftSidebarService } from './theme-left-sidebar.service';
import { AccessService } from '../access/access.service';

describe('ThemeLeftSidebarService', () => {
  let service: ThemeLeftSidebarService;

  const translateServiceMock = {
    instant: jasmine.createSpy('instant').and.callFake((key: string) => key),
  };

  const accessServiceMock = {
    organizationsConsulta: jasmine.createSpy('organizationsConsulta').and.returnValue(true),
    applicationsConsulta: jasmine.createSpy('applicationsConsulta').and.returnValue(false),
  };

  beforeEach(() => {
    translateServiceMock.instant.calls.reset();
    accessServiceMock.organizationsConsulta.calls.reset();
    accessServiceMock.applicationsConsulta.calls.reset();

    TestBed.configureTestingModule({
      providers: [
        ThemeLeftSidebarService,
        { provide: TranslateService, useValue: translateServiceMock },
        { provide: AccessService, useValue: accessServiceMock },
      ],
    });

    service = TestBed.inject(ThemeLeftSidebarService);
  });

  it('getMenu should disable entries based on permissions', () => {
    const menu = service.getMenu();

    const org = menu.find((x: any) => x.translateKey === 'ORGANIZATIONS.TITLE');
    const apps = menu.find((x: any) => x.translateKey === 'APPLICATIONS.TITLE');

    expect(org?.disabled).toBeFalse();
    expect(apps?.disabled).toBeTrue();
  });

  it('getTitle should include translated version label', () => {
    const title = service.getTitle();

    expect(title.length).toBe(1);
    expect(title[0].appName).toBe('InfoportOneAdmin');
    expect(title[0].version).toContain('VERSION');
  });

  it('getUserMenu should include preferences and sign out options', () => {
    spyOn(service, 'formatDate').and.returnValue('01/01/2026 10:00');

    const menu = service.getUserMenu({
      name: 'John Doe',
      userConfiguration: {
        language: 'es',
        lastConnectionDate: '2026-01-01T10:00:00Z',
      } as any,
    } as any);

    expect(menu.length).toBe(1);
    expect(menu[0].children?.some((x: any) => x.translateKey === 'PREFERENCES')).toBeTrue();
    expect(menu[0].children?.some((x: any) => x.translateKey === 'CORE_SIGN_OUT')).toBeTrue();
  });
});
