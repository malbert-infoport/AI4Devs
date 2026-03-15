using Helix6.Base.Domain.Configuration;
using IdentityModel;
using InfoportOneAdmon.Back.Api.Security;
using Xunit;

namespace InfoportOneAdmon.Back.Api.Tests.Security;

public class APVReferenceTokenValidationTests
{
    /// <summary>
    /// Verifica que ValidateReferenceToken devuelve false cuando el token de referencia es nulo.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public async Task ValidateReferenceToken_ReturnsFalse_WhenReferenceTokenIsNull()
    {
        var sut = new APVReferenceTokenValidation(new AppSettings());

        var result = await sut.ValidateReferenceToken(null, "apv");

        Assert.False(result);
    }

    /// <summary>
    /// Verifica que ValidateReferenceToken devuelve false cuando el esquema no está configurado
    /// en Authentication.ReferenceTokenSchemes.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public async Task ValidateReferenceToken_ReturnsFalse_WhenSchemeIsNotConfigured()
    {
        var appSettings = new AppSettings();
        var sut = new APVReferenceTokenValidation(appSettings);

        var result = await sut.ValidateReferenceToken("token-1", "missing-scheme");

        Assert.False(result);
    }

    /// <summary>
    /// Verifica que CompleteUserInfoFromReferenceToken devuelve null para esquema no configurado,
    /// evitando llamadas de red y resultados inconsistentes.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public async Task CompleteUserInfoFromReferenceToken_ReturnsNull_WhenSchemeIsNotConfigured()
    {
        var appSettings = new AppSettings();
        var sut = new APVReferenceTokenValidation(appSettings);

        var principal = await sut.CompleteUserInfoFromReferenceToken("token-1", "missing-scheme");

        Assert.Null(principal);
    }

    /// <summary>
    /// Verifica que CompleteUserInfoFromReferenceToken devuelve null cuando el token es nulo.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public async Task CompleteUserInfoFromReferenceToken_ReturnsNull_WhenReferenceTokenIsNull()
    {
        var appSettings = new AppSettings();
        appSettings.Authentication.ReferenceTokenSchemes.Add(new HelixReferenceTokenScheme
        {
            AuthenticationScheme = "apv",
            UserInfoEndpoint = string.Empty
        });

        var sut = new APVReferenceTokenValidation(appSettings);

        var principal = await sut.CompleteUserInfoFromReferenceToken(null, "apv");

        Assert.Null(principal);
    }

    /// <summary>
    /// Verifica que, si el esquema está configurado sin UserInfoEndpoint,
    /// se construye un ClaimsPrincipal mínimo sin dependencias externas.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public async Task CompleteUserInfoFromReferenceToken_CreatesEmptyPrincipal_WhenUserInfoEndpointIsEmpty()
    {
        var appSettings = new AppSettings();
        appSettings.Authentication.ReferenceTokenSchemes.Add(new HelixReferenceTokenScheme
        {
            AuthenticationScheme = "apv",
            UserInfoEndpoint = string.Empty,
            MinutesCache = 7
        });

        var sut = new APVReferenceTokenValidation(appSettings);

        var principal = await sut.CompleteUserInfoFromReferenceToken("token-abc", "apv");

        Assert.NotNull(principal);
        Assert.Equal("es-ES", principal!.FindFirst(JwtClaimTypes.Locale)?.Value);
        Assert.Equal("token-abc", principal.FindFirst("user_id")?.Value);
        Assert.Equal("apv", principal.FindFirst(JwtClaimTypes.Name)?.Value);
        Assert.NotNull(principal.FindFirst(JwtClaimTypes.Expiration)?.Value);
    }

    /// <summary>
    /// Verifica que, sin MinutesCache explícito, se aplica el valor por defecto
    /// y se informa un claim de expiración válido.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public async Task CompleteUserInfoFromReferenceToken_UsesDefaultMinutesCache_WhenMinutesCacheIsNotConfigured()
    {
        var appSettings = new AppSettings();
        appSettings.Authentication.ReferenceTokenSchemes.Add(new HelixReferenceTokenScheme
        {
            AuthenticationScheme = "apv",
            UserInfoEndpoint = string.Empty
        });

        var sut = new APVReferenceTokenValidation(appSettings);

        var principal = await sut.CompleteUserInfoFromReferenceToken("token-xyz", "apv");

        Assert.NotNull(principal);
        var expirationValue = principal!.FindFirst(JwtClaimTypes.Expiration)?.Value;
        Assert.False(string.IsNullOrWhiteSpace(expirationValue));
        Assert.True(long.TryParse(expirationValue, out _));
    }
}
