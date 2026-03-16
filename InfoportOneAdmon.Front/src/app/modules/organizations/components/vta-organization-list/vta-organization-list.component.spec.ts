import { Component, Input, Output, EventEmitter } from '@angular/core';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { By } from '@angular/platform-browser';
import { of } from 'rxjs';

import { VtaOrganizationListComponent } from './vta-organization-list.component';
import { VtaOrganizationService } from '../../services/vta-organization.service';
import { SharedMessageService } from '@app/theme/services/shared-message.service';
import { TranslateService } from '@ngx-translate/core';
import { Router } from '@angular/router';
import { ClModalService } from '@cl/common-library/cl-modal';
import { SecurityUserGridConfigurationClient } from '@restApi/api/apiClients';
import { GridConfiguratorMapperServiceService } from '@app/services/grid-configurator-mapper-service.service';

@Component({ selector: 'cl-grid', standalone: true, template: '<ng-content></ng-content>' })
class ClGridStubComponent {
  @Input() config: any;
  @Input() data: any;
  @Output() dataStateChangeEvent = new EventEmitter<any>();
}

@Component({ selector: 'cl-button', standalone: true, template: '<button (click)="onClick()">{{text}}</button>' })
class ClButtonStubComponent {
  @Input() text: string | undefined;
  @Output() clicked = new EventEmitter<void>();
  onClick() {
    this.clicked.emit();
  }
}

describe('VtaOrganizationListComponent', () => {
  let fixture: ComponentFixture<VtaOrganizationListComponent>;
  let component: VtaOrganizationListComponent;

  beforeEach(async () => {
    const orgServiceStub = {
      getAll: jasmine.createSpy('getAll').and.returnValue(of({ list: [], count: 0 }))
    };

    await TestBed.configureTestingModule({
      imports: [VtaOrganizationListComponent, ClGridStubComponent, ClButtonStubComponent],
      providers: [
        { provide: VtaOrganizationService, useValue: orgServiceStub },
        { provide: SharedMessageService, useValue: { showError: () => {}, showMessage: () => {}, showSuccess: () => {} } },
        { provide: TranslateService, useValue: { instant: (k: string) => k } },
        { provide: Router, useValue: { navigate: jasmine.createSpy('navigate') } },
        { provide: ClModalService, useValue: { openModal: () => {} } },
        {
          provide: SecurityUserGridConfigurationClient,
          useValue: { getUserGridConfigurations: () => of([]), insert: () => of({}), update: () => of({}), deleteById: () => of(null) }
        },
        { provide: GridConfiguratorMapperServiceService, useValue: { getUserGridConfigurations: () => of([]), create: () => of({}), update: () => of({}), deleteById: () => of(null) } }
      ]
    }).compileComponents();

    fixture = TestBed.createComponent(VtaOrganizationListComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should render a single + Añadir cl-button in the footer template', () => {
    // look for cl-button elements in the rendered template
    const clButtons = fixture.debugElement.queryAll(By.css('cl-button'));
    expect(clButtons.length).toBe(1);
  });

  it('clicking footer + Añadir calls editItem(0)', () => {
    spyOn(component, 'editItem');
    const btnDebug = fixture.debugElement.query(By.css('cl-button'));
    const nativeBtn = btnDebug.nativeElement.querySelector('button');
    nativeBtn.click();
    fixture.detectChanges();
    expect(component.editItem).toHaveBeenCalledWith(0);
  });
});
