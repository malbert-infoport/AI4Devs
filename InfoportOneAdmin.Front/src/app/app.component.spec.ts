import { TestBed } from '@angular/core/testing';
import { AppComponent } from './app.component';
import { TranslateService } from '@ngx-translate/core';
import { HttpClientTestingModule, provideHttpClientTesting } from '@angular/common/http/testing';
import { MatNativeDateModule } from '@angular/material/core'; // <-- Importa esto
import { EnvConfigurationService } from './theme/services/env-configuration.service';
import { provideHttpClient } from '@angular/common/http';

// Mock básico para TranslateService
class MockTranslateService {
  setDefaultLang(lang: string) {}
  getBrowserLang() {
    return 'es';
  }
  use(lang: string) {
    return { subscribe: () => {} };
  }
}

class MockEnvConfigurationService {
  configuration = {
    apiUrl: 'https://localhost:42000',
    authority: 'http://docker-devipv.digitainer.com:8091/auth/realms/Sintra4',
    client_id: 'angularclient',
    scope: 'angularClientScope',
    response_type: 'code',
    redirect_uri: 'http://localhost:4200/signin-callback',
    post_logout_redirect_uri: 'http://localhost:4200/signout-callback',
    silent_redirect_uri: 'http://localhost:4200/silent-callback.html',
    automaticSilentRenew: false,
    urlAuthorize: 'https://localhost:42000/api/Security/GetPermissions',
    environment: 'Test',
    color_environment: ''
  };

  async setConfig() {
    return this.configuration;
  }

  readConfig() {
    return this.configuration;
  }
}

describe('AppComponent', () => {
  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [AppComponent, MatNativeDateModule],
      providers: [
        { provide: TranslateService, useClass: MockTranslateService },
        { provide: EnvConfigurationService, useClass: MockEnvConfigurationService },
        provideHttpClientTesting(),
        provideHttpClient()
      ]
    }).compileComponents();
  });

  it('should create the app', () => {
    const fixture = TestBed.createComponent(AppComponent);
    const app = fixture.componentInstance;
    expect(app).toBeTruthy();
  });

  it(`should have the 'InfoportOneAdmin 1.0' title`, () => {
    const fixture = TestBed.createComponent(AppComponent);
    const app = fixture.componentInstance;
    expect(app.title).toEqual('InfoportOneAdmin 1.0');
  });
});
