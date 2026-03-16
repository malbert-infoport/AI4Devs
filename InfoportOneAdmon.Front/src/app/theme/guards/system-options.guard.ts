import { CanActivateFn } from '@angular/router';
import { inject } from '@angular/core';

import { AccessService } from '@app/theme/access/access.service';

export const systemOptionsGuard: CanActivateFn = () => {
  const accessService = inject(AccessService);
  // TODO: Revisar porque al recargar el accessService.profilesQuery() || accessService.companyConfigurationQuery() devuelve false;
  // Eliminar el setTimeout
  let Access;
  setTimeout(() => {
    Access = accessService.profilesQuery() || accessService.companyConfigurationQuery();
  }, 0);
  return Access;
};
