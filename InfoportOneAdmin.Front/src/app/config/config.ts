/**
 * api/Security/GerPermissions
 * appName:se gasta para comprobar los permisos de la app,
 * el back devuelve en la propiedad application "Helix6.Back"
 * y nosotros utilizamos el appName, en la función hasPermissions
 * del authentication.service.ts
 * El appName debe condicir con el que pone el back,
 * está ubicado InfoportOneAdmin.Back.Api\appsettings.Development.json (HelixConfiguration.ApplicationName) */
export const appName = 'InfoportOneAdmin';
