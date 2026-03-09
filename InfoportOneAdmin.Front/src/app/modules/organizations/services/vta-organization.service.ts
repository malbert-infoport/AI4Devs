import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { VTA_OrganizationClient } from '../../../../webServicesReferences/api/apiClients';

@Injectable()
export class VtaOrganizationService {
  private readonly client = inject(VTA_OrganizationClient);

  getAll(kendoFilter: any): Observable<any> {
    // The generated client expects a payload shaped as { data: State }
    const payload = kendoFilter && kendoFilter.data ? kendoFilter : { data: kendoFilter };
    return this.client.getAllKendoFilter(payload);
  }
}
