using System.Security.Claims;
using InfoportOneAdmon.Back.Api.Security;
using Xunit;

namespace InfoportOneAdmon.Back.Api.Tests.Security;

public class KeyCloakUserClaimsMappingTests
{
    /// <summary>
    /// Verifica que el mapper de Keycloak combina roles de realm_access y resource_access,
    /// y que el filtrado por prefijos aplica sobre el conjunto combinado.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public void GetRoles_MergesRealmAndClientRoles_AndFiltersByPrefix()
    {
        var realmAccess = "{\"roles\":[\"HLX_IsAdmin\",\"APP_READ\"]}";
        var resourceAccess = "{\"infoportoneadmon\":{\"roles\":[\"APP_WRITE\",\"OTHER\"]}}";

        var principal = BuildPrincipal(
            ("realm_access", realmAccess),
            ("resource_access", resourceAccess));

        var sut = new KeyCloakUserClaimsMapping();

        var roles = sut.GetRoles(principal, "APP_");

        Assert.Equal(2, roles.Count);
        Assert.Contains("APP_READ", roles);
        Assert.Contains("APP_WRITE", roles);
        Assert.DoesNotContain("HLX_IsAdmin", roles);
        Assert.DoesNotContain("OTHER", roles);
    }

    /// <summary>
    /// Verifica que se detecta administrador cuando el rol HLX_IsAdmin está presente
    /// en los roles del realm de Keycloak.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public void GetIsAdmin_ReturnsTrue_WhenRealmContainsAdminRole()
    {
        var realmAccess = "{\"roles\":[\"HLX_IsAdmin\",\"APP_READ\"]}";
        var principal = BuildPrincipal(("realm_access", realmAccess));

        var sut = new KeyCloakUserClaimsMapping();

        Assert.True(sut.GetIsAdmin(principal));
    }

    /// <summary>
    /// Verifica el fallback de SecurityCompanyId a 1 cuando no existe claim c_ids.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public void GetSecurityCompanyId_ReturnsDefaultOne_WhenClaimIsMissing()
    {
        var principal = BuildPrincipal(("sub", "user-1"));
        var sut = new KeyCloakUserClaimsMapping();

        var companyId = sut.GetSecurityCompanyId(principal);

        Assert.Equal(1, companyId);
    }

    /// <summary>
    /// Verifica que SecurityCompanyId se toma del claim c_ids cuando está presente.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public void GetSecurityCompanyId_ReturnsClaimValue_WhenClaimExists()
    {
        var principal = BuildPrincipal(("c_ids", "45"));
        var sut = new KeyCloakUserClaimsMapping();

        var companyId = sut.GetSecurityCompanyId(principal);

        Assert.Equal(45, companyId);
    }

    /// <summary>
    /// Verifica que GetRoles sin prefijos devuelve la unión de roles de realm y cliente.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public void GetRoles_ReturnsMergedRoles_WhenPrefixIsNull()
    {
        var realmAccess = "{\"roles\":[\"HLX_IsAdmin\",\"APP_READ\"]}";
        var resourceAccess = "{\"infoportoneadmon\":{\"roles\":[\"APP_WRITE\",\"OTHER\"]}}";
        var principal = BuildPrincipal(("realm_access", realmAccess), ("resource_access", resourceAccess));
        var sut = new KeyCloakUserClaimsMapping();

        var roles = sut.GetRoles(principal, null);

        Assert.Contains("HLX_IsAdmin", roles);
        Assert.Contains("APP_READ", roles);
        Assert.Contains("APP_WRITE", roles);
        Assert.Contains("OTHER", roles);
    }

    /// <summary>
    /// Verifica que GetIsAdmin devuelve false cuando no existe el rol HLX_IsAdmin.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public void GetIsAdmin_ReturnsFalse_WhenAdminRoleIsMissing()
    {
        var realmAccess = "{\"roles\":[\"APP_READ\"]}";
        var principal = BuildPrincipal(("realm_access", realmAccess));
        var sut = new KeyCloakUserClaimsMapping();

        Assert.False(sut.GetIsAdmin(principal));
    }

    /// <summary>
    /// Verifica el contrato actual: no se envían claims al frontend.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public void GetSendClaimsToFront_ReturnsFalse_ByDesign()
    {
        var sut = new KeyCloakUserClaimsMapping();

        Assert.False(sut.GetSendClaimsToFront());
    }

    /// <summary>
    /// Verifica lectura de claims de organización definidos para la integración con Keycloak.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public void OrganizationClaims_AreReadCorrectly()
    {
        var principal = BuildPrincipal(
            ("o_cif", "B12345678"),
            ("o_code", "0045"),
            ("o_name", "Company"));

        var sut = new KeyCloakUserClaimsMapping();

        Assert.Equal("B12345678", sut.GetOrganizationCif(principal));
        Assert.Equal("0045", sut.GetOrganizationCode(principal));
        Assert.Equal("Company", sut.GetOrganizationName(principal));
    }

    private static ClaimsPrincipal BuildPrincipal(params (string Type, string Value)[] claims)
    {
        var identity = new ClaimsIdentity(claims.Select(c => new Claim(c.Type, c.Value)), "TestAuth");
        return new ClaimsPrincipal(identity);
    }
}
