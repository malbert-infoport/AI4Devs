import { Logger, UserManagerSettings } from 'oidc-client-ts';

export class OidcConfig {
  constructor(
    public oidc_config: UserManagerSettings,
    public useCallbackFlag?: boolean,
    public log?: {
      logger: Logger;
      level: number;
    }
  ) {}
}
