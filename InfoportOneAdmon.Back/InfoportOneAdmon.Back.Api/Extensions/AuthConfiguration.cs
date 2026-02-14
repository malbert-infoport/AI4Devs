using InfoportOneAdmon.Back.Api.Security;
using Helix6.Base.Domain.Configuration;
using Helix6.Base.Domain.Security;
using Helix6.Base.Security;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authorization;
using Microsoft.IdentityModel.Logging;
using System.IdentityModel.Tokens.Jwt;
using Microsoft.IdentityModel.JsonWebTokens;

namespace InfoportOneAdmon.Back.Api.Extensions
{
    public static class AuthConfiguration
    {
        public static void AddAuthentication(this IServiceCollection services, AppSettings appSettings, string? environment)
        {
            IdentityModelEventSource.ShowPII = true;
            JwtSecurityTokenHandler.DefaultInboundClaimTypeMap.Clear();
            JsonWebTokenHandler.DefaultInboundClaimTypeMap.Clear();

            var builder = services.AddAuthentication(opt =>
            {
                opt.DefaultScheme = appSettings.Authentication.DefaultScheme;
                opt.DefaultChallengeScheme = appSettings.Authentication.DefaultScheme;
            });

            if (appSettings.Authentication.UseJWTSchemes)
            {
                services.AddSingleton<IUserClaimsMapping, KeyCloakUserClaimsMapping>();
                foreach (var scheme in appSettings.Authentication.Schemes)
                {
                    builder.AddJwtBearer(scheme.AuthenticationScheme, o => o.ConfigureJWTBearerOptions(scheme, appSettings.Authentication.DefaultScheme, environment));
                }
                services.AddAuthorization(options =>
                {
                    foreach (var scheme in appSettings.Authentication.Schemes)
                    {
                        var policy = new AuthorizationPolicyBuilder()
                            .RequireAuthenticatedUser()
                            .AddAuthenticationSchemes(scheme.AuthenticationScheme)
                            .Build();
                        options.AddPolicy(scheme.AuthenticationScheme, policy);
                    }
                    options.DefaultPolicy = options.GetPolicy(appSettings.Authentication.DefaultScheme)!;
                });
            }
            else
            {
                services.AddSingleton<IUserClaimsMapping, APVClaimsMapping>();
                services.AddSingleton<IReferenceTokenValidation, APVReferenceTokenValidation>();
                foreach (var scheme in appSettings.Authentication.ReferenceTokenSchemes)
                {
                    builder.AddScheme<AuthenticationSchemeOptions, ReferenceTokenAuthenticationHandler>(scheme.AuthenticationScheme, null);
                }
                services.AddAuthorization(options =>
                {
                    foreach (var scheme in appSettings.Authentication.ReferenceTokenSchemes)
                    {
                        var policy = new AuthorizationPolicyBuilder()
                            .RequireAuthenticatedUser()
                            .AddAuthenticationSchemes(scheme.AuthenticationScheme)
                            .Build();
                        options.AddPolicy(scheme.AuthenticationScheme, policy);
                    }
                    options.DefaultPolicy = options.GetPolicy(appSettings.Authentication.DefaultScheme)!;
                });
            }
        }
    }
}