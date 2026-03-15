using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Helix6.Base.Application;
using Helix6.Base.Domain;
using Helix6.Base.Domain.Security;
using InfoportOneAdmon.Back.Api.Security;
using InfoportOneAdmon.Back.Entities;

namespace InfoportOneAdmon.Back.Api.IntegrationTests.Infrastructure;

public sealed class IntegrationTestFactory : WebApplicationFactory<Program>
{
    private readonly string _connectionString;
    private readonly bool _enableTestJwtBypass;
    private readonly bool _allowAllPermissions;
    private readonly IReadOnlyCollection<int>? _grantedPermissions;

    public IntegrationTestFactory(
        string connectionString,
        bool enableTestJwtBypass = false,
        bool allowAllPermissions = false,
        IEnumerable<int>? grantedPermissions = null)
    {
        _connectionString = connectionString;
        _enableTestJwtBypass = enableTestJwtBypass;
        _allowAllPermissions = allowAllPermissions;
        _grantedPermissions = grantedPermissions?.Distinct().ToArray();
    }

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Development");

        builder.ConfigureAppConfiguration((_, config) =>
        {
            config.AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["ConnectionStrings:DefaultConnection"] = _connectionString
            });
        });

        if (_enableTestJwtBypass || _allowAllPermissions || _grantedPermissions != null)
        {
            builder.ConfigureTestServices(services =>
            {
                if (_enableTestJwtBypass)
                {
                    services.PostConfigure<JwtBearerOptions>("code", options =>
                    {
                        options.RequireHttpsMetadata = false;
                        options.TokenValidationParameters = new TokenValidationParameters
                        {
                            ValidateIssuer = false,
                            ValidateAudience = false,
                            ValidateLifetime = false,
                            ValidateIssuerSigningKey = false,
                            RequireSignedTokens = false,
                            SignatureValidator = (token, _) => new JwtSecurityToken(token)
                        };
                    });
                }

                if (_allowAllPermissions || _grantedPermissions != null)
                {
                    services.AddAuthorization(options =>
                    {
                        options.DefaultPolicy = new AuthorizationPolicyBuilder()
                            .RequireAssertion(_ => true)
                            .Build();
                    });

                    services.AddScoped<IUserContext>(sp =>
                        new FixedUserContext(sp.GetRequiredService<IApplicationContext>()));

                    if (_allowAllPermissions)
                    {
                        services.AddScoped<IUserPermissions, AllowAllUserPermissions>();
                    }
                    else
                    {
                        var permissions = _grantedPermissions ?? Array.Empty<int>();
                        services.AddScoped<IUserPermissions>(_ => new ConfigurableUserPermissions(permissions));
                    }
                }
            });
        }
    }

    private sealed class FixedUserContext : IUserContext
    {
        public FixedUserContext(IApplicationContext applicationContext)
        {
            var principal = new ClaimsPrincipal(new ClaimsIdentity(new[]
            {
                new Claim("user_id", "1"),
                new Claim("name", "integration"),
                new Claim("preferred_username", "integration.user"),
                new Claim("sub", "integration.user@test.local"),
                new Claim("organizationcif", "B12345678"),
                new Claim("organization", "Company"),
                new Claim("organizationapvcode", "0045"),
                new Claim("groups", "ADMON_admin,admin")
            }, "Integration"));

            var claimsMapping = new APVClaimsMapping();
            User = new AuthUser(principal, claimsMapping, applicationContext);
            Applications = new List<AuthApplication>
            {
                new(principal, claimsMapping, applicationContext)
            };
            AuthenticationType = "JwtBearer";
            Claims = new List<AuthClaim>();
            SendClaimsToFront = false;
        }

        public List<AuthApplication> Applications { get; }
        public string AuthenticationType { get; }
        public List<AuthClaim> Claims { get; set; }
        public bool SendClaimsToFront { get; }
        public AuthUser User { get; }

        public object Clone()
        {
            return this;
        }
    }

    private sealed class AllowAllUserPermissions : IUserPermissions
    {
        public string GetAuthenticationType()
        {
            return "JwtBearer";
        }

        public Task<AuthPermissions> GetUserPermissions()
        {
            var authPermissions = new AuthPermissions
            {
                EndpointLevels = new List<AuthControllerLevel>
                {
                    new() { EndpointName = "SecurityProfile", Level = HelixEnums.SecurityLevel.Modify },
                    new() { EndpointName = "Organization", Level = HelixEnums.SecurityLevel.Modify },
                    new() { EndpointName = "OrganizationGroup", Level = HelixEnums.SecurityLevel.Modify },
                    new() { EndpointName = "VTA_Organization", Level = HelixEnums.SecurityLevel.Modify },
                    new() { EndpointName = "SecurityUserConfiguration", Level = HelixEnums.SecurityLevel.Modify },
                    new() { EndpointName = "SecurityUserGridConfiguration", Level = HelixEnums.SecurityLevel.Modify },
                    new() { EndpointName = "Application", Level = HelixEnums.SecurityLevel.Modify },
                    new() { EndpointName = "AuditLog", Level = HelixEnums.SecurityLevel.Modify }
                },
                Permissions = new List<int>
                {
                    Consts.SecurityAccessOption.OrganizationOptions.ORGANIZATION_DATA_QUERY,
                    Consts.SecurityAccessOption.OrganizationOptions.ORGANIZATION_DATA_MODIFICATION,
                    Consts.SecurityAccessOption.OrganizationOptions.ORGANIZATION_MODULES_QUERY,
                    Consts.SecurityAccessOption.OrganizationOptions.ORGANIZATION_MODULES_MODIFICATION,
                    Consts.SecurityAccessOption.OrganizationOptions.ORGANIZATION_AUDIT_QUERY
                }
            };

            return Task.FromResult(authPermissions);
        }
    }

    private sealed class ConfigurableUserPermissions : IUserPermissions
    {
        private static readonly List<AuthControllerLevel> EndpointLevels = new()
        {
            new() { EndpointName = "SecurityProfile", Level = HelixEnums.SecurityLevel.Modify },
            new() { EndpointName = "Organization", Level = HelixEnums.SecurityLevel.Modify },
            new() { EndpointName = "OrganizationGroup", Level = HelixEnums.SecurityLevel.Modify },
            new() { EndpointName = "VTA_Organization", Level = HelixEnums.SecurityLevel.Modify },
            new() { EndpointName = "SecurityUserConfiguration", Level = HelixEnums.SecurityLevel.Modify },
            new() { EndpointName = "SecurityUserGridConfiguration", Level = HelixEnums.SecurityLevel.Modify },
            new() { EndpointName = "Application", Level = HelixEnums.SecurityLevel.Modify },
            new() { EndpointName = "AuditLog", Level = HelixEnums.SecurityLevel.Modify }
        };

        private readonly List<int> _permissions;

        public ConfigurableUserPermissions(IEnumerable<int> permissions)
        {
            _permissions = permissions.Distinct().ToList();
        }

        public string GetAuthenticationType()
        {
            return "JwtBearer";
        }

        public Task<AuthPermissions> GetUserPermissions()
        {
            var authPermissions = new AuthPermissions
            {
                EndpointLevels = EndpointLevels,
                Permissions = _permissions
            };

            return Task.FromResult(authPermissions);
        }
    }
}
