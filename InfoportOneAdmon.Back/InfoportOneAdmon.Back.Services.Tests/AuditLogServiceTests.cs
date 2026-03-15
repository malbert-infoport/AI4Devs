using System.Security.Claims;
using Helix6.Base.Application;
using Helix6.Base.Domain.Parameters;
using Helix6.Base.Domain.Security;
using Helix6.Base.Repository;
using InfoportOneAdmon.Back.DataModel;
using InfoportOneAdmon.Back.Entities.Views;
using InfoportOneAdmon.Back.Services;
using Microsoft.Extensions.Logging;
using Moq;
using Xunit;

namespace InfoportOneAdmon.Back.Services.Tests;

public class AuditLogServiceTests
{
    /// <summary>
    /// Verifica que LogAuditEntry construye el AuditLogView con los datos de entrada,
    /// toma el login del usuario del contexto y ejecuta una inserción sin recarga.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public async Task LogAuditEntry_UsesUserLoginFromContext_AndCallsInsert()
    {
        var appContext = BuildApplicationContext();
        var userContext = BuildUserContext("audit-user", login: "user.login");
        var repository = new Mock<IBaseRepository<AuditLog>>();
        var logger = new Mock<ILogger<AuditLogService>>();

        var sutMock = new Mock<AuditLogService>(appContext.Object, userContext.Object, repository.Object, logger.Object)
        {
            CallBase = true
        };

        AuditLogView? captured = null;
        sutMock
            .Setup(x => x.Insert(It.IsAny<AuditLogView>(), It.IsAny<SetParamsService>()))
            .Callback<AuditLogView, SetParamsService>((view, _) => captured = view)
            .ReturnsAsync(1);

        await sutMock.Object.LogAuditEntry("ActionX", "Organization", "10", "content");

        Assert.NotNull(captured);
        Assert.Equal("ActionX", captured!.Action);
        Assert.Equal("Organization", captured.EntityType);
        Assert.Equal("10", captured.EntityId);
        Assert.Equal("content", captured.Content);
        Assert.Equal("user.login", captured.UserLogin);

        sutMock.Verify(x => x.Insert(It.IsAny<AuditLogView>(), It.IsAny<SetParamsService>()), Times.Once);
    }

    /// <summary>
    /// Verifica que LogAuditEntry propaga excepciones de inserción para que el llamador
    /// pueda gestionar el fallo transaccional/audit de forma explícita.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public async Task LogAuditEntry_Throws_WhenInsertFails()
    {
        var appContext = BuildApplicationContext();
        var userContext = BuildUserContext("audit-user", login: "user.login");
        var repository = new Mock<IBaseRepository<AuditLog>>();
        var logger = new Mock<ILogger<AuditLogService>>();

        var sutMock = new Mock<AuditLogService>(appContext.Object, userContext.Object, repository.Object, logger.Object)
        {
            CallBase = true
        };

        sutMock
            .Setup(x => x.Insert(It.IsAny<AuditLogView>(), It.IsAny<SetParamsService>()))
            .ThrowsAsync(new InvalidOperationException("insert error"));

        await Assert.ThrowsAsync<InvalidOperationException>(() =>
            sutMock.Object.LogAuditEntry("ActionX", "Organization", "10", "content"));
    }

    private static Mock<IApplicationContext> BuildApplicationContext()
    {
        var appContext = new Mock<IApplicationContext>();
        appContext.SetupGet(x => x.ApplicationName).Returns("InfoportOneAdmon");
        appContext.SetupGet(x => x.RolPrefixes).Returns("APP_");
        appContext.SetupGet(x => x.PermisionsMinutesCache).Returns(30);
        return appContext;
    }

    private static Mock<IUserContext> BuildUserContext(string userId, string login)
    {
        var claimsPrincipal = new ClaimsPrincipal(new ClaimsIdentity(new[] { new Claim("sub", userId) }, "TestAuth"));

        var claimsMapping = new Mock<IUserClaimsMapping>();
        claimsMapping.Setup(x => x.GetUserId(It.IsAny<ClaimsPrincipal>())).Returns(userId);
        claimsMapping.Setup(x => x.GetUserName(It.IsAny<ClaimsPrincipal>())).Returns("UserName");
        claimsMapping.Setup(x => x.GetDisplayName(It.IsAny<ClaimsPrincipal>())).Returns("Display Name");
        claimsMapping.Setup(x => x.GetLogin(It.IsAny<ClaimsPrincipal>())).Returns(login);
        claimsMapping.Setup(x => x.GetMail(It.IsAny<ClaimsPrincipal>())).Returns("user@test.local");
        claimsMapping.Setup(x => x.GetOrganizationCif(It.IsAny<ClaimsPrincipal>())).Returns("B12345678");
        claimsMapping.Setup(x => x.GetOrganizationCode(It.IsAny<ClaimsPrincipal>())).Returns("0045");
        claimsMapping.Setup(x => x.GetOrganizationName(It.IsAny<ClaimsPrincipal>())).Returns("Company");
        claimsMapping.Setup(x => x.GetSecurityCompanyId(It.IsAny<ClaimsPrincipal>())).Returns(1);
        claimsMapping.Setup(x => x.GetRoles(It.IsAny<ClaimsPrincipal>(), It.IsAny<string>())).Returns(new List<string> { "APP_READ" });
        claimsMapping.Setup(x => x.GetIsAdmin(It.IsAny<ClaimsPrincipal>(), It.IsAny<string>())).Returns(false);
        claimsMapping.Setup(x => x.GetSendClaimsToFront()).Returns(false);

        var appContext = BuildApplicationContext();
        var user = new AuthUser(claimsPrincipal, claimsMapping.Object, appContext.Object);
        var application = new AuthApplication(claimsPrincipal, claimsMapping.Object, appContext.Object);

        var userContext = new Mock<IUserContext>();
        userContext.SetupGet(x => x.User).Returns(user);
        userContext.SetupGet(x => x.AuthenticationType).Returns("JwtBearer");
        userContext.SetupGet(x => x.Applications).Returns(new List<AuthApplication> { application });
        userContext.SetupProperty(x => x.Claims, new List<AuthClaim>());
        userContext.SetupGet(x => x.SendClaimsToFront).Returns(false);

        return userContext;
    }
}
