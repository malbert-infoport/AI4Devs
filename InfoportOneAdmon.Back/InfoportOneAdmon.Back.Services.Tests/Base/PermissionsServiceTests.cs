using System.Security.Claims;
using Helix6.Base.Application;
using Helix6.Base.Domain.Security;
using InfoportOneAdmon.Back.Data.Repository.Base.Interfaces;
using InfoportOneAdmon.Back.DataModel.Base;
using InfoportOneAdmon.Back.Services.Base;
using Moq;
using Xunit;

namespace InfoportOneAdmon.Back.Services.Tests.Base;

public class PermissionsServiceTests
{
    /// <summary>
    /// Verifica que, con caché activa, la primera consulta carga permisos desde repositorio,
    /// y la segunda lectura para el mismo usuario se resuelve desde caché sin volver al repositorio.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public async Task GetUserPermissions_UsesCache_WhenCacheIsEnabled()
    {
        PermissionsService.CleanUserPermissionsCache();

        var appContext = BuildApplicationContext(30);
        var userContext = BuildUserContext("user-1", isAdmin: true, authenticationType: "Bearer");
        var repository = BuildRepository(new List<Permissions>
        {
            new() { SecurityAccessOptionId = 200, Controller = "Organization", SecurityLevel = 1 },
            new() { SecurityAccessOptionId = 200, Controller = "Organization", SecurityLevel = 1 },
            new() { SecurityAccessOptionId = 201, Controller = "Organization", SecurityLevel = 2 }
        });

        var sut = new PermissionsService(appContext.Object, userContext.Object, repository.Object);

        var first = await sut.GetUserPermissions();
        var second = await sut.GetUserPermissions();

        Assert.Equal(new[] { 200, 201 }, first.Permissions.OrderBy(x => x));
        Assert.Equal(2, first.EndpointLevels.Count);
        Assert.Equal(first.Permissions.OrderBy(x => x), second.Permissions.OrderBy(x => x));
        repository.Verify(r => r.GetPermissions(), Times.Once);
    }

    /// <summary>
    /// Verifica que, sin caché configurada, cada llamada fuerza lectura en repositorio
    /// para evitar resultados stale entre peticiones.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public async Task GetUserPermissions_DoesNotCache_WhenCacheIsDisabled()
    {
        PermissionsService.CleanUserPermissionsCache();

        var appContext = BuildApplicationContext(null);
        var userContext = BuildUserContext("user-2", isAdmin: false, authenticationType: "Reference");
        var repository = BuildRepository(new List<Permissions>
        {
            new() { SecurityAccessOptionId = 202, Controller = "Organization", SecurityLevel = 1 }
        });

        var sut = new PermissionsService(appContext.Object, userContext.Object, repository.Object);

        await sut.GetUserPermissions();
        await sut.GetUserPermissions();

        repository.Verify(r => r.GetPermissions(), Times.Exactly(2));
    }

    /// <summary>
    /// Verifica que el servicio expone el AuthenticationType del contexto de usuario
    /// sin transformación adicional.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public void GetAuthenticationType_ReturnsUserContextAuthenticationType()
    {
        var appContext = BuildApplicationContext(10);
        var userContext = BuildUserContext("user-3", isAdmin: false, authenticationType: "JwtBearer");
        var repository = BuildRepository(new List<Permissions>());

        var sut = new PermissionsService(appContext.Object, userContext.Object, repository.Object);

        var authType = sut.GetAuthenticationType();

        Assert.Equal("JwtBearer", authType);
    }

    /// <summary>
    /// Verifica que limpiar la caché global obliga a volver a consultar el repositorio,
    /// incluso para el mismo usuario previamente cacheado.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public async Task CleanUserPermissionsCache_ForcesRepositoryReload_OnNextCall()
    {
        PermissionsService.CleanUserPermissionsCache();

        var appContext = BuildApplicationContext(30);
        var userContext = BuildUserContext("user-4", isAdmin: true, authenticationType: "Bearer");
        var repository = BuildRepository(new List<Permissions>
        {
            new() { SecurityAccessOptionId = 204, Controller = "Organization", SecurityLevel = 3 }
        });

        var sut = new PermissionsService(appContext.Object, userContext.Object, repository.Object);

        await sut.GetUserPermissions();
        PermissionsService.CleanUserPermissionsCache();
        await sut.GetUserPermissions();

        repository.Verify(r => r.GetPermissions(), Times.Exactly(2));
    }

    private static Mock<IApplicationContext> BuildApplicationContext(int? permissionsMinutesCache)
    {
        var appContext = new Mock<IApplicationContext>();
        appContext.SetupGet(x => x.PermisionsMinutesCache).Returns(permissionsMinutesCache);
        appContext.SetupGet(x => x.ApplicationName).Returns("InfoportOneAdmon");
        appContext.SetupGet(x => x.RolPrefixes).Returns("APP_");
        return appContext;
    }

    private static Mock<IUserContext> BuildUserContext(string userId, bool isAdmin, string authenticationType)
    {
        var claimsPrincipal = new ClaimsPrincipal(new ClaimsIdentity(new[] { new Claim("sub", userId) }, "TestAuth"));

        var claimsMapping = new Mock<IUserClaimsMapping>();
        claimsMapping.Setup(x => x.GetUserId(It.IsAny<ClaimsPrincipal>())).Returns(userId);
        claimsMapping.Setup(x => x.GetUserName(It.IsAny<ClaimsPrincipal>())).Returns("UserName");
        claimsMapping.Setup(x => x.GetDisplayName(It.IsAny<ClaimsPrincipal>())).Returns("Display Name");
        claimsMapping.Setup(x => x.GetLogin(It.IsAny<ClaimsPrincipal>())).Returns("user.login");
        claimsMapping.Setup(x => x.GetMail(It.IsAny<ClaimsPrincipal>())).Returns("user@test.local");
        claimsMapping.Setup(x => x.GetOrganizationCif(It.IsAny<ClaimsPrincipal>())).Returns("B12345678");
        claimsMapping.Setup(x => x.GetOrganizationCode(It.IsAny<ClaimsPrincipal>())).Returns("0045");
        claimsMapping.Setup(x => x.GetOrganizationName(It.IsAny<ClaimsPrincipal>())).Returns("Company");
        claimsMapping.Setup(x => x.GetSecurityCompanyId(It.IsAny<ClaimsPrincipal>())).Returns(1);
        claimsMapping.Setup(x => x.GetRoles(It.IsAny<ClaimsPrincipal>(), It.IsAny<string>())).Returns(new List<string> { "APP_READ" });
        claimsMapping.Setup(x => x.GetIsAdmin(It.IsAny<ClaimsPrincipal>(), It.IsAny<string>())).Returns(isAdmin);
        claimsMapping.Setup(x => x.GetSendClaimsToFront()).Returns(false);

        var appContext = BuildApplicationContext(30);
        var user = new AuthUser(claimsPrincipal, claimsMapping.Object, appContext.Object);
        var application = new AuthApplication(claimsPrincipal, claimsMapping.Object, appContext.Object);

        var userContext = new Mock<IUserContext>();
        userContext.SetupGet(x => x.User).Returns(user);
        userContext.SetupGet(x => x.AuthenticationType).Returns(authenticationType);
        userContext.SetupGet(x => x.Applications).Returns(new List<AuthApplication> { application });
        userContext.SetupProperty(x => x.Claims, new List<AuthClaim>());
        userContext.SetupGet(x => x.SendClaimsToFront).Returns(false);

        return userContext;
    }

    private static Mock<IPermissionsRepository> BuildRepository(List<Permissions> permissions)
    {
        var repository = new Mock<IPermissionsRepository>();
        repository.Setup(x => x.GetPermissions()).ReturnsAsync(permissions);
        return repository;
    }
}
