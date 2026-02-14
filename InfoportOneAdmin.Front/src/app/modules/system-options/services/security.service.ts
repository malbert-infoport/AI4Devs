import { Injectable, inject } from '@angular/core';

import { SharedMessageService } from '@app/theme/services/shared-message.service';

import { TranslateService } from '@ngx-translate/core';

import { SecurityClient } from '@restApi/api/apiClients';

import { take } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class SecurityService {
  private sharedMessageService = inject(SharedMessageService);
  private translate = inject(TranslateService);
  private securityClient = inject(SecurityClient);

  cleanSecurityCache() {
    this.securityClient
      .cleanCache()
      .pipe(take(1))
      .subscribe({
        next: () => this.sharedMessageService.showMessage(this.translate.instant('CACHE_CLEAN_SUCCESS')),
        error: (e) => this.sharedMessageService.showError(e)
      });
  }
}
