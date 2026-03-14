import { ComponentFixture, TestBed } from '@angular/core/testing';
import { of } from 'rxjs';
import { TranslateService } from '@ngx-translate/core';
import { provideRouter } from '@angular/router';

import { OneComponent } from './one.component';
import { AccessService } from '@app/theme/access/access.service';

describe('OneComponent', () => {
  let component: OneComponent;
  let fixture: ComponentFixture<OneComponent>;

  const accessServiceMock = {
    init: jasmine.createSpy('init'),
    organizationsConsulta: jasmine.createSpy('organizationsConsulta').and.returnValue(true),
    applicationsConsulta: jasmine.createSpy('applicationsConsulta').and.returnValue(false),
    hasPermission: jasmine.createSpy('hasPermission').and.returnValues(of(true), of(false))
  };

  const translateServiceMock = {
    instant: (key: string) => key,
    get: (key: string) => of(key),
    stream: (key: string) => of(key),
    onLangChange: of({ lang: 'es', translations: {} }),
    onTranslationChange: of({ lang: 'es', translations: {} }),
    onDefaultLangChange: of({ lang: 'es', translations: {} }),
  };

  beforeEach(async () => {
    accessServiceMock.init.calls.reset();
    accessServiceMock.organizationsConsulta.calls.reset();
    accessServiceMock.applicationsConsulta.calls.reset();
    accessServiceMock.hasPermission.calls.reset();
    accessServiceMock.hasPermission.and.returnValues(of(true), of(false));

    await TestBed.configureTestingModule({
      imports: [OneComponent],
      providers: [
        provideRouter([]),
        { provide: AccessService, useValue: accessServiceMock },
        { provide: TranslateService, useValue: translateServiceMock }
      ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(OneComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should initialize permissions and set card visibility flags', () => {
    expect(accessServiceMock.init).toHaveBeenCalled();
    expect(component.showOrganizations).toBeTrue();
    expect(component.showApplications).toBeFalse();
  });

  it('onCardClick should block navigation when disabled', () => {
    const preventDefault = jasmine.createSpy('preventDefault');
    const stopPropagation = jasmine.createSpy('stopPropagation');

    component.onCardClick({ preventDefault, stopPropagation } as any, false);

    expect(preventDefault).toHaveBeenCalled();
    expect(stopPropagation).toHaveBeenCalled();
  });

  it('onCardClick should allow navigation when enabled', () => {
    const preventDefault = jasmine.createSpy('preventDefault');
    const stopPropagation = jasmine.createSpy('stopPropagation');

    component.onCardClick({ preventDefault, stopPropagation } as any, true);

    expect(preventDefault).not.toHaveBeenCalled();
    expect(stopPropagation).not.toHaveBeenCalled();
  });
});
