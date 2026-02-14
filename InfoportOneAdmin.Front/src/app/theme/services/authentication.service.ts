import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';

import { TranslateService } from '@ngx-translate/core';

import { UserConfiguration } from '@app/theme/models/user-configuration.model';
import { Application } from '@app/theme/models/get-permissions.model';
import { Access } from '@app/theme/access/access';
import { EnvConfigurationService } from '@app/theme/services/env-configuration.service';
import { appName } from '@app/config/config';

import { AuthApplication, AuthClaim, AuthUserConfiguration, IAuthUser } from '@restApi/api/apiClients';

import { UserManager, User, UserManagerSettings } from 'oidc-client-ts';

import { BehaviorSubject, Observable, Subject } from 'rxjs';
import { filter, take } from 'rxjs/operators';

@Injectable({
  providedIn: 'root'
})
export class AuthenticationService {
  private httpClient = inject(HttpClient);
  private envConfigurationService = inject(EnvConfigurationService);
  private translate = inject(TranslateService);
  private router = inject(Router);

  private userManager!: UserManager;
  private user!: User | null;
  private userContext!: User;

  private userConfig!: UserConfiguration;
  private userConfiguration!: AuthUserConfiguration;

  private allPermissionsSubject = new BehaviorSubject<AuthApplication[]>([]);
  public allPermissionsObs = this.allPermissionsSubject.asObservable();

  private userSubject = new BehaviorSubject<IAuthUser>({});
  public userObs = this.userSubject.asObservable();

  private claimSubject = new BehaviorSubject<AuthClaim[]>([]);
  public claimObs = this.claimSubject.asObservable();

  private loginChangedSubject = new Subject<boolean>();
  loginChanged = this.loginChangedSubject.asObservable();

  private token = 'token';
  private $refresh = new BehaviorSubject('token');

  init(): Promise<void> {
    /**
     * Usamos el servicio EnvConfigurationService, que lee del archivo de configuración
     * config.json (src\assets\config\config.json), esto se hace para el tema del despliegue
     * ya que una vez buildeado, no se puede modificar el archivo environment de angular,
     * pero este lo exponemos para su posterior modificación
     */
    const settings: UserManagerSettings = this.envConfigurationService.readConfig();
    this.userManager = new UserManager(settings);

    /**
     * CHECK IF IdentityServer IS ONLINE,
     * Comprueba si el IdentityServer está en línea
     *
     */
    this.isIdentityServerOnline(this.userManager).subscribe({
      error: () => {
        const ERROR_MESSAGE = this.translate.instant('COULD_NOT_CONNECT_IDENTITY_SERVER', {
          address: this.userManager.settings.authority
        });
        this.router.navigate(['/oidc-offline'], { queryParams: { error: ERROR_MESSAGE } });
      }
    });

    return this.loadUser();
  }

  private loadUser(): Promise<void> {
    return this.getUser().then((user) => {
      this.setUser(user, true);
    });
  }

  private setUser(user: User | null, isFirstLoad: boolean) {
    if (user && !user.expired) {
      this.userContext = user;
      this.userContext.profile['role'] = this.userContext.profile['role'] || [];
      if (isFirstLoad) {
        this.loadPermissions();
      }
    }
  }

  /** OIDC-CLIENT-TS  */
  logout(): Promise<void> {
    return this.userManager.signoutRedirect();
  }

  completeLogout() {
    this.user = null;
    this.loginChangedSubject.next(false);
    return this.userManager.signoutRedirectCallback();
  }

  login(): Promise<void> {
    return this.userManager.signinRedirect();
  }

  completeLogin() {
    return this.userManager.signinRedirectCallback().then((user) => {
      this.user = user;
      this.addUserLoaded();
      this.setUser(user, true);

      // emite true o false, dependiendo si el usuario está logueado o no
      this.loginChangedSubject.next(!!user && !user.expired);
      return user;
    });
  }

  isLoggedIn(): Promise<boolean> {
    return this.userManager.getUser().then((user) => {
      const userCurrent = !!user && !user.expired;
      this.user = user;
      return userCurrent;
    });
  }

  getUserName(): string | null | undefined {
    return !!this.user && !this.user.expired ? this.user.profile.name : null;
  }

  getUser() {
    return this.userManager.getUser();
  }
  getAccessToken(): string {
    return this.userContext ? this.userContext.access_token : '';
  }

  refreshToken(): Promise<any> {
    return this.userManager.signinSilent().then(() => this.loadUser());
  }

  /** ADAPTACIÓN CADUCIDAD TOKEN : USADO EN (OidcInterceptorService) */
  refreshTokenParallel(token: string): Observable<any> {
    if (token !== this.token) {
      this.token = token;
      this.refreshToken()
        .then(() => {
          this.$refresh.next(token);
        })
        .catch((err) => {
          this.$refresh.error(err);
        });
    }
    return this.$refresh.pipe(filter((t) => t === token));
  }

  /** COMPROBAR SI EL IDENTITY SERVER ESTÁ ONLINE */
  private isIdentityServerOnline(userManager: UserManager) {
    return this.httpClient.get(userManager.settings.authority + '/.well-known/openid-configuration').pipe(take(1));
  }

  /** userManager (EVENTS) */
  private addUserLoaded() {
    this.userManager.events.addUserLoaded((user: User) => this.setUser(user, false));
  }
  /** end userManager (EVENTS) */

  /** end OIDC-CLIENT-TS  */

  getUserConfiguration(key: 'language') {
    return (this.userConfiguration !== null && this.userConfiguration[key]) || '';
  }

  getUserConfig(): UserConfiguration {
    return this.userConfig || new UserConfiguration();
  }

  getRol(rolName: string) {
    let Includes: boolean;
    this.allPermissionsObs.subscribe((permissions) => {
      // OBTENEMOS EL LISTADO DE ROLES, OPTAMOS POR USAR EL OBSERVABLE QUE EMITIMOS ANTERIORMENTE
      // EN LUGAR DE USAR  EL LOCALSTORAGE
      // COMO LOS ROLES VIENEN A NIVEL DE APLICACIÓN(APP EN LA QUE TE ENCUENTRAS ACTUALMENTE),
      // NO NECESITAMOS BUSCAR DEL LISTADO ALMACENADO EN EL LOCALSTORAGE
      let Roles: string[] = permissions[0].roles ?? [];
      if (Roles) {
        // TRANSFORMAMOS A MAYUSCULAS PARA MINIMIZAR LOS ERRORES DE ESCRITURA DEL USUARIO
        // TRIM ELIMINA ESPACIOS EN BLANCO
        Roles = Roles.map((item: string) => item.toUpperCase());
        Includes = Roles.includes(rolName.toUpperCase().trim());
      }
      return Includes;
    });
  }

  getClaims(claim: string) {
    let Claim: AuthClaim | undefined;
    this.claimObs.subscribe((res: AuthClaim[]) => {
      // TRANSFORMAMOS A MAYUSCULAS PARA MINIMIZAR LOS ERRORES DE ESCRITURA DEL USUARIO
      // TRIM ELIMINA ESPACIOS EN BLANCO
      Claim = res.find((item) => item?.claim?.toUpperCase() === claim.toUpperCase().trim());
    });
    return Claim ? Claim.value : null;
  }

  /** Función de obtención de permisos */
  loadPermissions() {
    this.httpClient.get(this.envConfigurationService.readConfig().urlAuthorize).subscribe((res: any) => {
      this.userConfiguration = res.user.userConfiguration;
      /** Emitimos los datos del usuario */

      this.userSubject.next(res.user);
      /** Los claims vendrán si desde el back, se ha activvado la propiedad
       * SEND_CLAIMS_TO_FRONT = true (Helix6Back\Helix6.Back.Api\Security\APVClaimsMapping.cs)
       */
      if (res.claims) {
        /** Emitimos los claims del usuario */
        this.claimSubject.next(res.claims);
      }
      this.localStoragePermissions(res.applications, res.user.userConfiguration.language);
    });
  }

  localStoragePermissions(permissions: AuthApplication[], language: string) {
    // OBTENEMOS LOS PERMISOS DEL API
    // GetPermissions
    const permission = permissions[0];

    // OBTENEMOS LOS PERMISOS ALMACENADOS EN EL LOCALSTORAGE
    const localStoragePermissions: AuthApplication[] = localStorage.getItem('permissions')
      ? JSON.parse(localStorage.getItem('permissions')!)
      : [];

    // COMPROBAMOS SI EL PERMISO QUE ESTAMOS RECIBIENDO
    // EXISTE EN EL LOCALSTORAGE
    if (localStoragePermissions.length >= 1) {
      // COMPROBAMOS SI EXISTE PERMISO
      // SI LO ENCUENTRA DEVUELVE EL INDICE
      // EN CASO CONTRARIO DEVUELVE -1
      const INDEX = localStoragePermissions.findIndex((x) => x.application === permission.application);

      // SI EXISTE ACTUALIZAMOS EL PERMISO
      // SI NO EXISTE LO AÑADIMOS
      INDEX >= 0 ? localStoragePermissions.splice(INDEX, 1, permission) : localStoragePermissions.push(permission);
    } else {
      localStoragePermissions.push(permission);
    }

    // ACTUALIZAMOS EL LOCAL STORAGE
    this.removeLocalStorageValues();
    this.setLocalStorageValues(localStoragePermissions, language);

    // EMITIMOS EL OBSERVABLE
    this.allPermissionsSubject.next(localStoragePermissions);
  }

  hasPermissions(permissions: Array<Application>, acceso: Access) {
    const findPermissions = permissions.find((item) => item.application === appName);
    const hasPermission = findPermissions ? findPermissions.permissions.includes(acceso) : false;
    return hasPermission;
  }

  setLocalStorageValues(permissions: any, language: string) {
    localStorage.setItem('permissions', JSON.stringify(permissions));
    localStorage.setItem('language', language);
  }
  removeLocalStorageValues() {
    localStorage.removeItem('permissions');
    localStorage.removeItem('language');
  }
}
