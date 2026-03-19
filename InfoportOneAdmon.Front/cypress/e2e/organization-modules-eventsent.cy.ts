describe('Organization modules update should set eventSent=true', () => {
  it('updates organization modules and validates eventSent from real backend response', () => {
    const organizationId = Number(Cypress.env('organizationId') || 1);
    const targetModuleId = Number(Cypress.env('targetModuleId') || 5);
    const appOrigin = new URL((Cypress.config('baseUrl') as string) || 'http://localhost:4200').origin;
    const keycloakUrl = (Cypress.env('keycloakUrl') as string) || 'http://localhost:8080';
    const keycloakRealm = (Cypress.env('keycloakRealm') as string) || 'infoportone';
    const keycloakClientId = (Cypress.env('keycloakClientId') as string) || 'infoportoneadmon';
    const oidcStorageKey = `oidc.user:${keycloakUrl}/realms/${keycloakRealm}:${keycloakClientId}`;
    const runtimeErrors: string[] = [];
    let originalAssignmentsSignature = '';
    let uiBeforeSignature = '';
    let uiAfterSignature = '';
    let targetCheckedBefore: boolean | null = null;
    let targetCheckedAfter: boolean | null = null;

    cy.on('window:before:load', (win) => {
      win.addEventListener('error', (event) => {
        const message = event?.error?.message || event?.message || 'Unknown window error';
        runtimeErrors.push(String(message));
      });
      win.addEventListener('unhandledrejection', (event: PromiseRejectionEvent) => {
        const reason = (event?.reason as any)?.message || String(event?.reason || 'Unknown promise rejection');
        runtimeErrors.push(reason);
      });
    });

    cy.loginByKeycloak();

    cy.intercept('GET', '**/api/Security/GetPermissions*').as('getPermissions');
    cy.intercept('GET', '**/api/Organization/GetById*').as('getOrganizationById');
    cy.intercept('PUT', '**/api/Organization/Update*').as('updateOrganization');

    cy.visit(`/protected/organizations/${organizationId}`);

    cy.url({ timeout: 30000 }).then((currentUrl) => {
      if (currentUrl.includes('/unauthorized')) {
        throw new Error('Authenticated user does not have Organization access permissions.');
      }
    });

    cy.location('origin', { timeout: 30000 }).should('eq', appOrigin);
    cy.location('pathname', { timeout: 30000 }).should('eq', `/protected/organizations/${organizationId}`);

    cy.wait('@getPermissions', { timeout: 45000 }).then((interception) => {
      const status = interception.response?.statusCode;
      expect(status, `GetPermissions status code`).to.be.oneOf([200, 204]);
    });

    cy.wait('@getOrganizationById', { timeout: 45000 }).then((interception) => {
      const assignments = (interception.response?.body?.organization_ApplicationModule || []) as Array<{ applicationModuleId?: number }>;
      originalAssignmentsSignature = assignments
        .map((item) => Number(item.applicationModuleId || 0))
        .filter((id) => id > 0)
        .sort((a, b) => a - b)
        .join(',');
    });

    cy.get('body', { timeout: 20000 }).then(($body) => {
      const hasForm = $body.find('[data-testid="organization-form-page"]').length > 0;
      if (!hasForm) {
        const visibleText = ($body.text() || '').replace(/\s+/g, ' ').trim().slice(0, 600);
        const appWindow = $body[0].ownerDocument.defaultView;
        const currentUrl = appWindow?.location.href || 'unknown';
        const pathName = appWindow?.location.pathname || 'unknown';
        const oidcValue = appWindow?.localStorage.getItem(oidcStorageKey) || appWindow?.sessionStorage.getItem(oidcStorageKey);
        const hasOidcSession = Boolean(oidcValue);
        const isOnKeycloak = currentUrl.startsWith(keycloakUrl);
        const localOidcKeys = appWindow
          ? Object.keys(appWindow.localStorage).filter((key) => key.startsWith('oidc.user:')).join(',')
          : '';
        const sessionOidcKeys = appWindow
          ? Object.keys(appWindow.sessionStorage).filter((key) => key.startsWith('oidc.user:')).join(',')
          : '';

        throw new Error(
          `Organization form not rendered. URL=${currentUrl}; PATH=${pathName}; hasOidcSession=${hasOidcSession}; isOnKeycloak=${isOnKeycloak}; localOidcKeys=[${localOidcKeys}]; sessionOidcKeys=[${sessionOidcKeys}]; runtimeErrors=[${runtimeErrors.join(' | ')}]; Visible page text: ${visibleText}`
        );
      }
    });

    cy.get('[data-testid="organization-form-page"]').should('be.visible');

    cy.get('[data-testid="organization-save"]').should('be.visible').then(($btn) => {
      const disabled = $btn.is(':disabled') || $btn.attr('aria-disabled') === 'true';
      if (disabled) {
        throw new Error('Organization save button is disabled. User likely lacks organization edit/modules edit permissions.');
      }
    });

    cy.get('[data-testid="organization-tabs"] [role="tab"]', { timeout: 15000 })
      .eq(1)
      .click({ force: true });

    cy.get('[data-testid="organization-modules"]', { timeout: 20000 }).should('be.visible');

    cy.get('[data-testid^="modules-edit-app-"]', { timeout: 20000 }).first().then(($btn) => {
      const disabled = $btn.is(':disabled') || $btn.attr('aria-disabled') === 'true';
      if (disabled) {
        throw new Error('Modules edit button is disabled. User likely lacks module view/edit permissions.');
      }
      cy.wrap($btn).click();
    });

    cy.get('[data-testid="modules-modal-overlay"]', { timeout: 15000 }).should('be.visible');
    cy.get('[data-testid^="module-checkbox-"]', { timeout: 15000 }).should('have.length.greaterThan', 0);

    const targetSelector = `[data-testid="module-checkbox-${targetModuleId}"]`;
    cy.get(targetSelector, { timeout: 15000 }).should('exist');
    cy.get(targetSelector).should('not.be.disabled');

    const getCheckedSignature = () =>
      cy.get('[data-testid^="module-checkbox-"]').then(($list) =>
        Array.from($list)
          .filter((el) => (el as HTMLInputElement).checked)
          .map((el) => Number(((el as HTMLElement).getAttribute('data-testid') || '').replace('module-checkbox-', '')))
          .filter((id) => Number.isFinite(id) && id > 0)
          .sort((a, b) => a - b)
          .join(',')
      );

    getCheckedSignature().then((beforeSignature) => {
      uiBeforeSignature = beforeSignature;
      cy.get(targetSelector).then(($el) => {
        const isChecked = ($el[0] as HTMLInputElement).checked;
        targetCheckedBefore = isChecked;
        if (isChecked) {
          cy.get(targetSelector).uncheck();
        } else {
          cy.get(targetSelector).check();
        }
      });

      cy.get(targetSelector).then(($el) => {
        targetCheckedAfter = ($el[0] as HTMLInputElement).checked;
      });

      getCheckedSignature().then((afterSignature) => {
        uiAfterSignature = afterSignature;
        expect(afterSignature, `Module selection signature should change after toggling module id ${targetModuleId}`).not.to.eq(beforeSignature);
      });
    });

    cy.get('[data-testid="modules-modal-save"]').should('not.be.disabled').click();
    cy.get('[data-testid="modules-modal-overlay"]', { timeout: 15000 }).should('not.exist');
    cy.get('[data-testid="organization-save"]').should('not.be.disabled').click();

    cy.wait('@updateOrganization', { timeout: 30000 }).then((interception) => {
      const requestAssignments = (interception.request?.body?.organization_ApplicationModule || []) as Array<{ applicationModuleId?: number }>;
      const requestAssignmentsSignature = requestAssignments
        .map((item) => Number(item.applicationModuleId || 0))
        .filter((id) => id > 0)
        .sort((a, b) => a - b)
        .join(',');

      if (requestAssignmentsSignature === originalAssignmentsSignature) {
        const requestBody = interception.request?.body as Record<string, unknown>;
        const bodyKeys = requestBody ? Object.keys(requestBody).join(',') : 'none';
        throw new Error(
          `Updated assignments must differ from original assignments. original=[${originalAssignmentsSignature}] request=[${requestAssignmentsSignature}] uiBefore=[${uiBeforeSignature}] uiAfter=[${uiAfterSignature}] module${targetModuleId}CheckedBefore=[${targetCheckedBefore}] module${targetModuleId}CheckedAfter=[${targetCheckedAfter}] requestBodyKeys=[${bodyKeys}]`
        );
      }
      expect(interception.response?.statusCode).to.eq(200);
      expect(interception.response?.body).to.have.property('eventSent', true);
    });

    cy.get('[data-testid="organization-save"]').should('be.visible');
  });
});
