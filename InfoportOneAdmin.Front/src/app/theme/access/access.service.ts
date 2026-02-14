import { Injectable, inject } from '@angular/core';
import { BehaviorSubject, Observable, filter, map, take } from 'rxjs';
import { Access } from '@app/theme/access/access';
import { AuthenticationService } from '@app/theme/services/authentication.service';
import { AuthApplication } from '@restApi/api/apiClients';
import { appName } from '@app/config/config';

@Injectable({
  providedIn: 'root'
})
export class AccessService {
  private readonly authService = inject(AuthenticationService);

  permissions: any[] = [];

  private readonly emitPermissionsSubject = new BehaviorSubject<boolean>(false);
  public emitPermissionsObs = this.emitPermissionsSubject.asObservable();

  // Observable que emite cuando los permisos están listos
  public permissionsReady$: Observable<boolean> = this.emitPermissionsObs.pipe(filter((ready) => ready === true));

  init() {
    // Suscribirse al observable de permisos del AuthenticationService
    this.authService.allPermissionsObs.subscribe((allPermissions: AuthApplication[]) => {
      if (allPermissions && allPermissions.length > 0) {
        // Obtener los permisos de la aplicación actual
        const currentAppPermissions = allPermissions.find((app) => app.application === appName);

        if (currentAppPermissions) {
          this.permissions = [
            {
              application: currentAppPermissions.application,
              permissions: currentAppPermissions.permissions || []
            }
          ];
          this.emitPermissionsSubject.next(true);
        } else {
          this.emitPermissionsSubject.next(false);
        }
      }
    });
  }

  hasPermission(permissionCheck: () => boolean): Observable<boolean> {
    return this.permissionsReady$.pipe(
      map(() => permissionCheck()),
      take(1)
    );
  }

  /********** USUARIO *******/
  // PERSONALIZACIÓN DE USUARIO
  userCustomization() {
    return this.authService.hasPermissions(this.permissions, Access['User customization']);
  }
  /********** END USUARIO *******/

  /********** PERFILES *******/
  // Profile query
  profilesQuery() {
    return this.authService.hasPermissions(this.permissions, Access['Profile query'] || Access['Profile modification']);
  }
  //  MODIFICACIÓN DE PERFILES
  profilesModification() {
    return this.authService.hasPermissions(this.permissions, Access['Profile modification']);
  }
  /********** END  PERFILES *******/

  /********** EMPRESA *******/
  // CONSULTA DE CONFIGURACIÓN GENERAL DE EMPRESA
  companyConfigurationQuery() {
    return this.authService.hasPermissions(
      this.permissions,
      Access['General company configuration query'] || Access['General company configuration modification']
    );
  }
  //  MODIFICACIÓN DE CONFIGURACIÓN GENERAL DE EMPRESA
  companyConfigurationModification() {
    return this.authService.hasPermissions(this.permissions, Access['General company configuration modification']);
  }
  /********** END EMPRESA *******/

  /********** ADJUNTOS  *******/
  // CONSULTA, MODIFICACIÓN, DESCARGAR-VISUALIZAR
  attachmentAll() {
    return this.authService.hasPermissions(
      this.permissions,
      Access['Attachment query'] && Access['Attachment modification'] && Access['View or download attachments']
    );
  }

  // CONSULTA ADJUNTOS
  atachmentAllQueryDownload() {
    return this.authService.hasPermissions(this.permissions, Access['View or download attachments']);
  }

  // CONSULTA ADJUNTOS
  atachmentQuery() {
    return this.authService.hasPermissions(this.permissions, Access['Attachment query'] || Access['Attachment modification']);
  }

  // MODIFICACIÓN ADJUNTOS
  atachmentModify() {
    return this.authService.hasPermissions(this.permissions, Access['Attachment modification']);
  }

  // Attachment masters query
  atachmentsMasterQuery() {
    return this.authService.hasPermissions(
      this.permissions,
      Access['Attachment masters query'] || Access['Attachment masters modification']
    );
  }

  // MODIFICACIÓN MAESTROS ADJUNTOS
  atachmentsMasterModify() {
    return this.authService.hasPermissions(this.permissions, Access['Attachment masters modification']);
  }

  /********** END ADJUNTOS  *******/

  /********** MAESTROS  *******/

  // MAESTROS GENERAL
  mastersAccess() {
    return this.authService.hasPermissions(this.permissions, Access['Masters access']);
  }

  /********** END MAESTROS  *******/

  /********** GENÉRICOS *******/
  // CONSULTA
  consultaGenerico() {
    return this.authService.hasPermissions(
      this.permissions,
      Access['Permiso lectura generico'] || Access['Permiso escritura generico']
    );
  }
  //  MODIFICACIÓN
  modificacionGenerico() {
    return this.authService.hasPermissions(this.permissions, Access['Permiso escritura generico']);
  }

  /********** END TRABAJADORES *******/

  /********** EMPLEADOS *******/
  // CONSULTA EMPLEADOS
  maestroEmpleadosConsulta() {
    return this.authService.hasPermissions(
      this.permissions,
      Access['Acceso de Maestro de Empleados'] || Access['Modificación de Maestro de Empleados']
    );
  }
  //  MODIFICACIÓN EMPLEADOS
  maestroEmpleadosModificacion() {
    return this.authService.hasPermissions(this.permissions, Access['Modificación de Maestro de Empleados']);
  }
  /********** END EMPLEADOS *******/

  /********** MAESTROS: EMPRESAS *******/
  // CONSULTA MAESTRO EMPRESA
  maestroEmpresasConsulta() {
    return this.authService.hasPermissions(
      this.permissions,
      Access['Acceso de Maestro de Empresas'] || Access['Modificación de Maestro de Empresas']
    );
  }
  //  MODIFICACIÓN DE MAESTRO EMPRESA
  maestroEmpresasModificacion() {
    return this.authService.hasPermissions(this.permissions, Access['Modificación de Maestro de Empresas']);
  }
  /********** END  MAESTROS: EMPRESAS *******/

  /********** MAESTROS: VEHÍCULOS *******/
  // CONSULTA MAESTRO VEHÍCULO
  maestroVehiculosConsulta() {
    return this.authService.hasPermissions(
      this.permissions,
      Access['Acceso de Maestro de Vehículos'] || Access['Modificación de Maestro de Vehículos']
    );
  }
  //  MODIFICACIÓN DE MAESTRO VEHÍCULO
  maestroVehiculosModificacion() {
    return this.authService.hasPermissions(this.permissions, Access['Modificación de Maestro de Vehículos']);
  }
  /********** END PROYECTOS *******/

  /********** MAESTROS: VIAJES *******/
  // CONSULTA MAESTRO VIAJES
  maestroViajesConsulta() {
    return this.authService.hasPermissions(
      this.permissions,
      Access['Acceso de Maestro de Viajes'] || Access['Modificación de Maestro de Viajes']
    );
  }
  //  MODIFICACIÓN DE MAESTRO VIAJES
  maestroViajesModificacion() {
    return this.authService.hasPermissions(this.permissions, Access['Modificación de Maestro de Viajes']);
  }
  /********** END MAESTROS: VIAJES *******/

  /********** MAESTROS: GEOGRÁFICOS *******/
  // CONSULTA MAESTRO GEOGRÁFICO
  maestroGeograficosConsulta() {
    return this.authService.hasPermissions(
      this.permissions,
      Access['Acceso de Maestros Geográficos'] || Access['Modificación de Maestros Geográficos']
    );
  }
  //  MODIFICACIÓN DE MAESTRO GEOGRÁFICO
  maestroGeofragicoModificacion() {
    return this.authService.hasPermissions(this.permissions, Access['Modificación de Maestros Geográficos']);
  }
  /********** END MAESTROS:GEOGRÁFICOS *******/

  /********** AUDITORIA MENSAJES *******/
  // CONSULTA AUDOTIRIA MENSAJES
  auditoriaMensajesConsulta() {
    return this.authService.hasPermissions(
      this.permissions,
      Access['Acceso de Mensajes'] || Access['Modificación de Mensajes']
    );
  }
  //  MODIFICACIÓN AUDOTIRIA MENSAJES
  auditoriaMensajesModificacion() {
    return this.authService.hasPermissions(this.permissions, Access['Modificación de Mensajes']);
  }
  /********** END EMPLEADOS *******/

  /********** INTERCAMBIOS *******/
  // CONSULTA INTERCAMBIOS
  intercambiosConsulta() {
    return this.authService.hasPermissions(
      this.permissions,
      Access['Acceso de Intercambios'] || Access['Modificación de Intercambios']
    );
  }
  //  MODIFICACIÓN INTERCAMBIOS
  intercambiosModificacion() {
    return this.authService.hasPermissions(this.permissions, Access['Modificación de Intercambios']);
  }
  /********** END INTERCAMBIOS *******/

  /********** TARIFAS *******/
  // CONSULTA TARIFAS
  tarifasConsulta() {
    return this.authService.hasPermissions(
      this.permissions,
      Access['Consulta de Tarifas'] || Access['Modificación de Tarifas']
    );
  }
  //  MODIFICACIÓN TARIFAS
  tarifasModificacion() {
    return this.authService.hasPermissions(this.permissions, Access['Modificación de Tarifas']);
  }

  /********** FACTURADOR *******/
  // CONSULTA FACTURADOR
  facturadorConsulta() {
    return this.authService.hasPermissions(
      this.permissions,
      Access['Consulta facturador externo'] || Access['Modificación facturador externo']
    );
  }
  //  MODIFICACIÓN FACTURADOR
  facturadorModificacion() {
    return this.authService.hasPermissions(this.permissions, Access['Modificación facturador externo']);
  }

  /********** LIQUIDACION *******/
  // CONSULTA LIQUIDACION
  liquidacionConsulta() {
    return this.authService.hasPermissions(
      this.permissions,
      Access['Consulta de Tarifas'] || Access['Modificación de Tarifas']
    );
  }
  //  MODIFICACIÓN LIQUIDACION
  liquidacionModificacion() {
    return this.authService.hasPermissions(this.permissions, Access['Modificación de Tarifas']);
  }

  /********** INTEGRACIONES *******/
  // CONSULTA INTEGRACIONES
  integracionesConsulta() {
    return this.authService.hasPermissions(
      this.permissions,
      Access['Consulta de integraciones'] || Access['Modificación de integraciones']
    );
  }
  //  MODIFICACIÓN INTEGRACIONES
  integracionesModificacion() {
    return this.authService.hasPermissions(this.permissions, Access['Modificación de integraciones']);
  }

  // CONSULTA B2BRouter
  B2BRouterConsulta() {
    return this.authService.hasPermissions(this.permissions, Access['Consulta B2BRouter'] || Access['Modificación B2BRouter']);
  }
  //  MODIFICACIÓN B2BRouter
  B2BRouterModificacion() {
    return this.authService.hasPermissions(this.permissions, Access['Modificación B2BRouter']);
  }

  // CONSULTA Sage
  SageConsulta() {
    return this.authService.hasPermissions(this.permissions, Access['Consulta Sage'] || Access['Modificación Sage']);
  }
  //  MODIFICACIÓN Sage
  SageModificacion() {
    return this.authService.hasPermissions(this.permissions, Access['Modificación Sage']);
  }

  // CONSULTA Email Configurador
  emailConfiguradorConsulta() {
    return this.authService.hasPermissions(
      this.permissions,
      Access['Consulta Email Configurador'] || Access['Modificación Email Configurador']
    );
  }
  //  MODIFICACIÓN Email Configurador
  emailConfiguradorModificacion() {
    return this.authService.hasPermissions(this.permissions, Access['Modificación Email Configurador']);
  }
}
