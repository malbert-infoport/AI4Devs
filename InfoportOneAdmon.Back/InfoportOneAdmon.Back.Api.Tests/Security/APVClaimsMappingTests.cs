using System.Security.Claims;
using InfoportOneAdmon.Back.Api.Security;
using Xunit;

namespace InfoportOneAdmon.Back.Api.Tests.Security;

public class APVClaimsMappingTests
{
    /// <summary>
    /// Verifica que los métodos de lectura de identidad y organización obtienen exactamente
    /// los valores esperados desde los claims del token APV.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public void Getters_ReadExpectedClaims_FromPrincipal()
    {
        var principal = BuildPrincipal(
            ("user_id", "1134"),
            ("name", "afersa"),
            ("preferred_username", "Adolfo"),
            ("sub", "afersa@infoport.es"),
            ("organizationcif", "12345678Z"),
            ("organization", "Company"),
            ("organizationapvcode", "0045"));

        var sut = new APVClaimsMapping();

        Assert.Equal("1134", sut.GetUserId(principal));
        Assert.Equal("afersa", sut.GetUserName(principal));
        Assert.Equal("Adolfo", sut.GetDisplayName(principal));
        Assert.Equal("afersa", sut.GetLogin(principal));
        Assert.Equal("afersa@infoport.es", sut.GetMail(principal));
        Assert.Equal("12345678Z", sut.GetOrganizationCif(principal));
        Assert.Equal("Company", sut.GetOrganizationName(principal));
        Assert.Equal("0045", sut.GetOrganizationCode(principal));
    }

    /// <summary>
    /// Verifica que el filtrado por prefijos devuelve solo los roles cuyo nombre
    /// empieza por alguno de los prefijos proporcionados.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public void GetRoles_FiltersByPrefixes_WhenPrefixListIsProvided()
    {
        var principal = BuildPrincipal(("groups", "APP_READ,APP_WRITE,OTHER_ROLE"));
        var sut = new APVClaimsMapping();

        var roles = sut.GetRoles(principal, "APP_");

        Assert.Equal(2, roles.Count);
        Assert.Contains("APP_READ", roles);
        Assert.Contains("APP_WRITE", roles);
        Assert.DoesNotContain("OTHER_ROLE", roles);
    }

    /// <summary>
    /// Verifica que, con múltiples prefijos, se devuelven los roles que empiecen
    /// por cualquiera de ellos.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public void GetRoles_FiltersByMultiplePrefixes_WhenPrefixListContainsMoreThanOne()
    {
        var principal = BuildPrincipal(("groups", "APP_READ,KENDO_READ,OTHER_ROLE"));
        var sut = new APVClaimsMapping();

        var roles = sut.GetRoles(principal, "APP_,KENDO_");

        Assert.Equal(2, roles.Count);
        Assert.Contains("APP_READ", roles);
        Assert.Contains("KENDO_READ", roles);
    }

    /// <summary>
    /// Verifica que la detección de administrador se basa en la presencia del rol
    /// literal "admin" en los grupos del token.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public void GetIsAdmin_ReturnsTrue_WhenAdminRoleExists()
    {
        var principal = BuildPrincipal(("groups", "test,admin,other"));
        var sut = new APVClaimsMapping();

        var isAdmin = sut.GetIsAdmin(principal);

        Assert.True(isAdmin);
    }

    /// <summary>
    /// Verifica que GetIsAdmin devuelve false cuando no existe el rol admin.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public void GetIsAdmin_ReturnsFalse_WhenAdminRoleDoesNotExist()
    {
        var principal = BuildPrincipal(("groups", "test,viewer,other"));
        var sut = new APVClaimsMapping();

        var isAdmin = sut.GetIsAdmin(principal);

        Assert.False(isAdmin);
    }

    /// <summary>
    /// Verifica que en ausencia de principal no se devuelve ningún rol.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public void GetRoles_ReturnsEmpty_WhenPrincipalIsNull()
    {
        var sut = new APVClaimsMapping();

        var roles = sut.GetRoles(null, "APP_");

        Assert.Empty(roles);
    }

    /// <summary>
    /// Verifica que APV usa SecurityCompanyId fijo a 1 por contrato.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public void GetSecurityCompanyId_ReturnsOne_ByDesign()
    {
        var principal = BuildPrincipal(("user_id", "1134"));
        var sut = new APVClaimsMapping();

        var result = sut.GetSecurityCompanyId(principal);

        Assert.Equal(1, result);
    }

    /// <summary>
    /// Verifica el contrato de backend actual: APVClaimsMapping no envía claims al frontend.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public void GetSendClaimsToFront_ReturnsFalse_ByDesign()
    {
        var sut = new APVClaimsMapping();

        Assert.False(sut.GetSendClaimsToFront());
    }

    private static ClaimsPrincipal BuildPrincipal(params (string Type, string Value)[] claims)
    {
        var identity = new ClaimsIdentity(claims.Select(c => new Claim(c.Type, c.Value)), "TestAuth");
        return new ClaimsPrincipal(identity);
    }
}
