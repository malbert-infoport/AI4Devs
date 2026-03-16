import { Injectable, inject } from '@angular/core';
import { Router } from '@angular/router';
import { HttpRequest, HttpHandler, HttpEvent, HttpInterceptor } from '@angular/common/http';

import { TranslateService } from '@ngx-translate/core';

import { AuthenticationService } from '@app/theme/services/authentication.service';
import { SharedMessageService } from '@app/theme/services/shared-message.service';

import { Observable, throwError, throwError as _observableThrow } from 'rxjs';
import { catchError, switchMap, take } from 'rxjs/operators';
@Injectable({
  providedIn: 'root'
})
export class OidcInterceptorService implements HttpInterceptor {
  private authService = inject(AuthenticationService);
  private router = inject(Router);
  private sharedMessageService = inject(SharedMessageService);
  private translate = inject(TranslateService);

  public static readonly OidcInterceptorService: any;

  nexHandle(authReq: HttpRequest<any>, next: HttpHandler) {
    const token = this.authService.getAccessToken();
    const headers = authReq.headers.set('Authorization', `Bearer ${token}`);
    const newReq = authReq.clone({ headers });
    return next.handle(newReq);
  }

  intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    const accessToken = this.authService.getAccessToken();
    const lang = localStorage.getItem('language') || '';

    const headers = req.headers.set('Authorization', `Bearer ${accessToken}`).set('Accept-Language', lang);
    const authReq = req.clone({ headers });
    return next.handle(authReq).pipe(
      catchError((err) => {
        switch (err.status) {
          case 401:
            return this.authService.refreshTokenParallel(authReq.headers.get('Authorization')).pipe(
              take(1),
              switchMap(() => {
                return this.nexHandle(authReq, next);
              }),
              catchError((error) => {
                this.authService.logout();
                this.router.navigate(['/']);
                return throwError(() => error);
              })
            );
          case 403:
            this.sharedMessageService.showError(this.translate.instant('ERRORS.UNATHORIZED'));
            break;
          default:
            return throwError(() => err);
        }
      })
    );
  }
}
