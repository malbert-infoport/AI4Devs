import { ComponentFixture, TestBed } from '@angular/core/testing';
import { Subject } from 'rxjs';
import { TranslateService } from '@ngx-translate/core';
import { MatDialog } from '@angular/material/dialog';

import { ThemeLeftSidebarComponent } from './theme-left-sidebar.component';
import { HighlightedElementService } from '@app/theme/services/highlighted-element.service';
import { AuthenticationService } from '@app/theme/services/authentication.service';
import { ClModalService } from '@cl/common-library/cl-modal';
import { AccessService } from '@app/theme/access/access.service';

describe('ThemeLeftSidebarComponent', () => {
  let fixture: ComponentFixture<ThemeLeftSidebarComponent>;
  let component: ThemeLeftSidebarComponent;

  const collapseSubject = new Subject<void>();

  const highlightedElementServiceMock = {
    collpaseSidebarNodes: collapseSubject.asObservable(),
    closeSidenav: { emit: jasmine.createSpy('emit') },
    getParentSelectedElement: jasmine.createSpy('getParentSelectedElement').and.returnValue(null),
    removeParentSelectedElement: jasmine.createSpy('removeParentSelectedElement'),
    setSidebarClosed: jasmine.createSpy('setSidebarClosed'),
    getSelectedElement: jasmine.createSpy('getSelectedElement').and.returnValue(null),
    setSelectedElement: jasmine.createSpy('setSelectedElement'),
    setParentSelectedElement: jasmine.createSpy('setParentSelectedElement'),
  };

  const authServiceMock = {
    logout: jasmine.createSpy('logout'),
  };

  const matDialogMock = {
    open: jasmine.createSpy('open'),
  };

  const clModalServiceMock = {
    openModal: jasmine.createSpy('openModal').and.returnValue(Promise.resolve({ component: {}, dialogRef: {} })),
    closeDialog: jasmine.createSpy('closeDialog'),
  };

  const accessServiceMock = {
    maestroVehiculosModificacion: jasmine.createSpy('maestroVehiculosModificacion').and.returnValue(false),
  };

  const translateServiceMock = {
    instant: jasmine.createSpy('instant').and.callFake((key: string) => key),
  };

  beforeEach(async () => {
    TestBed.overrideComponent(ThemeLeftSidebarComponent, {
      set: {
        template: '<div></div>',
        imports: [],
      },
    });

    await TestBed.configureTestingModule({
      imports: [ThemeLeftSidebarComponent],
      providers: [
        { provide: HighlightedElementService, useValue: highlightedElementServiceMock },
        { provide: AuthenticationService, useValue: authServiceMock },
        { provide: MatDialog, useValue: matDialogMock },
        { provide: ClModalService, useValue: clModalServiceMock },
        { provide: AccessService, useValue: accessServiceMock },
        { provide: TranslateService, useValue: translateServiceMock },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(ThemeLeftSidebarComponent);
    component = fixture.componentInstance;

    component.titleInput = [{ appName: 'App' } as any];
    component.menuInput = [
      { translateKey: 'ENABLED', disabled: false },
      { translateKey: 'DISABLED', disabled: true },
    ] as any;
    component.usermenuInput = [] as any;
    component.contactinfoInput = [] as any;

    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('getMenu should filter disabled entries from main menu', () => {
    component.getMenu();

    expect(component.menu.length).toBe(1);
    expect(component.menu[0].translateKey).toBe('ENABLED');
  });

  it('toggleSideBar should collapse trees when closing expanded sidebar', () => {
    spyOn(component.menuTreeControl, 'collapseAll');
    spyOn(component.contactTreeControl, 'collapseAll');
    spyOn(component.usermenuTreeControl, 'collapseAll');

    component.sidebarClosed = false;
    component.toggleSideBar();

    expect(component.menuTreeControl.collapseAll).toHaveBeenCalled();
    expect(component.contactTreeControl.collapseAll).toHaveBeenCalled();
    expect(component.usermenuTreeControl.collapseAll).toHaveBeenCalled();
  });

  it('openSettings should open modal with submit disabled when user lacks modification permission', async () => {
    accessServiceMock.maestroVehiculosModificacion.and.returnValue(false);

    component.openSettings();
    await Promise.resolve();

    expect(clModalServiceMock.openModal).toHaveBeenCalled();
    const cfg = clModalServiceMock.openModal.calls.mostRecent().args[0] as any;
    expect(cfg.submitButton.disabled).toBeTrue();
  });
});
