type KeycloakTokenResponse = {
  access_token: string;
  refresh_token?: string;
  id_token?: string;
  token_type: string;
  expires_in: number;
  scope?: string;
  session_state?: string;
};

declare global {
  namespace Cypress {
    interface Chainable {
      loginByKeycloak(): Chainable<void>;
    }
  }
}

function decodeJwtPayload(token: string): Record<string, unknown> {
  const parts = token.split('.');
  if (parts.length < 2) {
    return {};
  }

  const normalized = parts[1].replace(/-/g, '+').replace(/_/g, '/');
  const padded = normalized.padEnd(Math.ceil(normalized.length / 4) * 4, '=');
  const json = atob(padded);
  return JSON.parse(json);
}

function getOidcStorageKey(authority: string, clientId: string): string {
  return `oidc.user:${authority}:${clientId}`;
}

function hasOidcSession(win: Window): boolean {
  const hasInStorage = (storage: Storage) => Object.keys(storage).some((key) => key.startsWith('oidc.user:'));
  return hasInStorage(win.localStorage) || hasInStorage(win.sessionStorage);
}

Cypress.Commands.add('loginByKeycloak', () => {
  const keycloakUrl = Cypress.env('keycloakUrl') as string;
  const realm = Cypress.env('keycloakRealm') as string;
  const clientId = Cypress.env('keycloakClientId') as string;
  const clientSecret = Cypress.env('keycloakClientSecret') as string;
  const username = Cypress.env('keycloakUsername') as string;
  const password = Cypress.env('keycloakPassword') as string;
  const scope = Cypress.env('keycloakScope') as string;

  if (!username || !password) {
    throw new Error('Missing KEYCLOAK_USERNAME or KEYCLOAK_PASSWORD env vars for Cypress login.');
  }

  const tokenUrl = `${keycloakUrl}/realms/${realm}/protocol/openid-connect/token`;
  const body: Record<string, string> = {
    grant_type: 'password',
    client_id: clientId,
    username,
    password,
    scope
  };

  if (clientSecret) {
    body.client_secret = clientSecret;
  }

  const authority = `${keycloakUrl}/realms/${realm}`;
  const storageKey = getOidcStorageKey(authority, clientId);

  cy.session(
    [realm, clientId, username],
    () => {
    cy.request<KeycloakTokenResponse>({
      method: 'POST',
      url: tokenUrl,
      form: true,
      body,
      failOnStatusCode: false
    }).then((response) => {
      if (response.status === 200) {
        const tokenResponse = response.body as KeycloakTokenResponse;
        const nowInSeconds = Math.floor(Date.now() / 1000);
        const profile = decodeJwtPayload(tokenResponse.access_token);

        const oidcUser = {
          id_token: tokenResponse.id_token || '',
          session_state: tokenResponse.session_state,
          access_token: tokenResponse.access_token,
          refresh_token: tokenResponse.refresh_token || '',
          token_type: tokenResponse.token_type,
          scope: tokenResponse.scope || scope,
          profile,
          expires_at: nowInSeconds + tokenResponse.expires_in
        };

        cy.visit('/', { failOnStatusCode: false });
        cy.window().then((win) => {
          win.localStorage.setItem(storageKey, JSON.stringify(oidcUser));
          win.sessionStorage.setItem(storageKey, JSON.stringify(oidcUser));
        });

        return;
      }

      // Fallback when direct grants are disabled in Keycloak client settings.
      cy.visit('/protected/organizations', { failOnStatusCode: false });
      cy.origin(keycloakUrl, { args: { username, password } }, ({ username, password }) => {
        cy.get('#username', { timeout: 20000 }).clear().type(username);
        cy.get('#password').clear().type(password, { log: false });
        cy.get('#kc-login').click();
      });
      cy.location('pathname', { timeout: 60000 }).should('include', '/protected');
      cy.window().should((win) => {
        expect(hasOidcSession(win)).to.eq(true);
      });
    });
    },
    {
      validate() {
        cy.visit('/protected', { failOnStatusCode: false });
        cy.window().should((win) => {
          expect(hasOidcSession(win)).to.eq(true);
        });
      }
    }
  );
});

export {};
