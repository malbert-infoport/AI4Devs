import { WebStorageStateStore } from 'oidc-client-ts';

export interface EnvConfigInterface {
  apiUrl: string;
  authority: string;
  client_id: string;
  scope: string;
  response_type: string;
  redirect_uri: string;
  post_logout_redirect_uri: string;
  silent_redirect_uri: string;
  automaticSilentRenew: boolean;
  accessTokenExpiringNotificationTime?: number;
  urlAuthorize: string;
  userStore?: WebStorageStateStore;
  environment: string;
  color_environment: string;
}
