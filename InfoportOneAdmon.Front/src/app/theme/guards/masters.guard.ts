import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { map } from 'rxjs';
import { AccessService } from '@app/theme/access/access.service';

export const mastersGuard: CanActivateFn = () => {
  const accessService = inject(AccessService);
  const router = inject(Router);

  return accessService
    .hasPermission(() => accessService.mastersAccess())
    .pipe(
      map((hasAccess) => {
        if (!hasAccess) {
          router.navigate(['/unauthorized']);
          return false;
        }
        return true;
      })
    );
};

// export const mastersGuard: CanActivateFn =  (route: ActivatedRouteSnapshot, state: RouterStateSnapshot) => {
//   return  inject(AccessService).mastersAccess();
// };
