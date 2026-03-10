import { Routes } from '@angular/router';
import { VtaOrganizationListComponent } from './components/vta-organization-list/vta-organization-list.component';
import { OrganizationFormPageComponent } from './components/organization-form-page/organization-form-page.component';

export const ORGANIZATIONS_ROUTES: Routes = [
  {
    path: '',
    pathMatch: 'full',
    component: VtaOrganizationListComponent
  },
  {
    path: 'new',
    component: OrganizationFormPageComponent,
    title: 'ORGANIZATIONS.FORM.TITLE_NEW'
  },
  {
    path: ':id',
    component: OrganizationFormPageComponent,
    title: 'ORGANIZATIONS.FORM.TITLE_EDIT'
  }
];
