Usamos la librería `oidc-client-ts` para la autenticación, en el archivo `config.json` está indicado a que ruta debemos redirigir cuando cerramos sesión en nuestra app.

```json
{
  "apiUrl": "https://localhost:42000",
  "authority": "https://localhost:9444/oauth2/oidcdiscovery",
  "client_id": "5icygwEftVyZmmm_hYAUSr4WvkIa",
  "scope": "openid apv",
  "response_type": "code",
  "redirect_uri": "http://localhost:4200/signin-callback",
  "post_logout_redirect_uri": "http://localhost:4200/signout-callback",
  "silent_redirect_uri": "http://localhost:4200/silent-callback.html",
  "automaticSilentRenew": false,
  "urlAuthorize": "https://localhost:42000/api/Security/GetPermissions",
  "environment": "Test",
  "color_environment": ""
}
```

La ruta `http://localhost:4200/signout-callback`, redirige a nuestro componente `ThemeSignoutComponent`

```ts
  { path: 'signout-callback', component: ThemeSignoutComponent }
```
