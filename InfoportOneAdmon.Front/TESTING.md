# Testing Guide - InfoportOneAdmon.Front

## Objective
This document defines the critical test pack and the criteria to evolve tests without losing functional coverage for:
- Home
- Left sidebar/menu
- Permissions and guards
- Organizations form and modules

## Critical Test Pack (Block 4)
Run all critical tests with one command:

```bash
npm run test:critical
```

The script executes:
- `src/app/theme/access/access.service.spec.ts`
- `src/app/theme/guards/masters.guard.spec.ts`
- `src/app/theme/services/oidc-guard.service.spec.ts`
- `src/app/modules/one/one.component.spec.ts`
- `src/app/modules/organizations/components/organization-modules/organization-modules.component.spec.ts`
- `src/app/modules/organizations/components/organization-form-page/organization-form-page.component.spec.ts`
- `src/app/theme/services/theme-left-sidebar.service.spec.ts`
- `src/app/theme/components/theme-left-sidebar/theme-left-sidebar.component.spec.ts`
- `src/app/app.routes.spec.ts`

## What this pack guarantees
1. Permission logic for Organizations and Applications is consistent.
2. Route guards block/allow navigation correctly.
3. Home cards visibility follows permissions.
4. Sidebar menu composition and key interactions remain stable.
5. Organization modules behavior follows write-implies-read rules.
6. Organization form handles permission states, payload normalization, save flows, and key edge cases.

## Policy for failing tests
Do not delete failing tests by default.

Use this triage:
1. Keep and fix:
- Tests that protect security, permissions, guards, payload mapping, or save flows.
2. Rewrite:
- Tests that are stale due to API evolution or obsolete mocks.
3. Temporary disable (with issue/task):
- Fragile UI tests that block delivery and have low immediate risk.
4. Delete permanently only when:
- Coverage is duplicated by a more stable test and no unique risk is lost.

## Authoring rules
1. Prefer unit tests for business logic and permissions.
2. Isolate heavy UI dependencies with `TestBed.overrideComponent(...)` when needed.
3. Mock external services explicitly (`AccessService`, `AuthenticationService`, API clients, `TranslateService`).
4. Keep tests deterministic: avoid timing flakiness and hidden async behavior.

## Suggested CI usage
At minimum, run:

```bash
npm run test:critical
npm run build
```

Optional full suite run can be added as a nightly or pre-release validation.
