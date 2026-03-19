import { defineConfig } from 'cypress';

export default defineConfig({
  e2e: {
    baseUrl: process.env.FRONT_BASE_URL || 'http://localhost:4200',
    setupNodeEvents(on) {
      on('before:browser:launch', (browser, launchOptions) => {
        if (browser.family === 'chromium') {
          launchOptions.args.push('--ignore-certificate-errors');
          launchOptions.args.push('--host-resolver-rules=MAP localhost 127.0.0.1,MAP *.localhost 127.0.0.1');
        }

        return launchOptions;
      });
    },
    supportFile: 'cypress/support/e2e.ts',
    specPattern: 'cypress/e2e/**/*.cy.ts',
    video: true,
    screenshotOnRunFailure: true,
    retries: {
      runMode: 1,
      openMode: 0
    },
    env: {
      keycloakUrl: process.env.KEYCLOAK_URL || 'http://localhost:8080',
      keycloakRealm: process.env.KEYCLOAK_REALM || 'infoportone',
      keycloakClientId: process.env.KEYCLOAK_CLIENT_ID || 'infoportoneadmon',
      keycloakClientSecret: process.env.KEYCLOAK_CLIENT_SECRET || '',
      keycloakUsername: process.env.KEYCLOAK_USERNAME || '',
      keycloakPassword: process.env.KEYCLOAK_PASSWORD || '',
      keycloakScope: process.env.KEYCLOAK_SCOPE || 'openid',
      organizationId: Number(process.env.E2E_ORGANIZATION_ID || 1)
    }
  }
});
