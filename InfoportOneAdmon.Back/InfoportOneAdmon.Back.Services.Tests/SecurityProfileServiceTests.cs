using System.Security.Claims;
using Helix6.Base.Application;
using Helix6.Base.Domain.Security;
using Helix6.Base.Repository;
using Helix6.Base.Service;
using InfoportOneAdmon.Back.DataModel.Base;
using InfoportOneAdmon.Back.Entities;
using InfoportOneAdmon.Back.Entities.View.Base;
using InfoportOneAdmon.Back.Entities.Views.Base;
using InfoportOneAdmon.Back.Entities.Views.Base.Metadata;
using InfoportOneAdmon.Back.Services.Base;
using Moq;
using Xunit;

namespace InfoportOneAdmon.Back.Services.Tests;

public class SecurityProfileServiceTests
{
    /// <summary>
    /// Verifica que GetNewEntity inicializa la empresa de seguridad del usuario
    /// y carga los módulos con las opciones marcadas fuera del perfil por defecto.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public async Task GetNewEntity_LoadsModulesAndMarksAllOptionsAsNotIncluded()
    {
        var repository = new Mock<IBaseRepository<SecurityProfile>>();

        var modules = new List<SecurityModuleView>
        {
            new()
            {
                Id = 1,
                Description = "Module A",
                SecurityAccessOption =
                [
                    new SecurityAccessOptionView { Id = 1, Description = "Read" },
                    new SecurityAccessOptionView { Id = 2, Description = "Write" }
                ]
            }
        };

        var securityModuleService = new Mock<IBaseService<SecurityModuleView, SecurityModule, SecurityProfileViewMetadata>>();
        securityModuleService
            .Setup(x => x.GetAll(Consts.LoadingConfigurations.SecurityModule.MODULE_WITH_SECURITYOPTIONS))
            .ReturnsAsync(modules);

        var sut = CreateSut(repository, securityModuleService);

        var result = await sut.GetNewEntity();

        Assert.NotNull(result);
        Assert.Equal(1, result!.SecurityCompanyId);
        Assert.Single(result.SecurityModule);
        Assert.False(result.SecurityModule[0].SecurityAccessOption.First(x => x.Id == 1).includedInProfile);
        Assert.False(result.SecurityModule[0].SecurityAccessOption.First(x => x.Id == 2).includedInProfile);
    }

    /// <summary>
    /// Verifica que GetNewEntity solicita al servicio de módulos la configuración
    /// MODULE_WITH_SECURITYOPTIONS para poblar la vista inicial.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public async Task GetNewEntity_RequestsModulesUsingExpectedLoadingConfiguration()
    {
        var repository = new Mock<IBaseRepository<SecurityProfile>>();
        var securityModuleService = new Mock<IBaseService<SecurityModuleView, SecurityModule, SecurityProfileViewMetadata>>();
        securityModuleService
            .Setup(x => x.GetAll(Consts.LoadingConfigurations.SecurityModule.MODULE_WITH_SECURITYOPTIONS))
            .ReturnsAsync(new List<SecurityModuleView>());

        var sut = CreateSut(repository, securityModuleService);

        _ = await sut.GetNewEntity();

        securityModuleService.Verify(
            x => x.GetAll(Consts.LoadingConfigurations.SecurityModule.MODULE_WITH_SECURITYOPTIONS),
            Times.Once);
    }

    private static SecurityProfileService CreateSut(
        Mock<IBaseRepository<SecurityProfile>> repository,
        Mock<IBaseService<SecurityModuleView, SecurityModule, SecurityProfileViewMetadata>> securityModuleService)
    {
        var appContext = BuildApplicationContext();
        var userContext = BuildUserContext("profile-user");

        return new SecurityProfileService(
            appContext.Object,
            userContext.Object,
            repository.Object,
            securityModuleService.Object);
    }

    private static Mock<IApplicationContext> BuildApplicationContext()
    {
        var appContext = new Mock<IApplicationContext>();
        appContext.SetupGet(x => x.ApplicationName).Returns("InfoportOneAdmon");
        appContext.SetupGet(x => x.RolPrefixes).Returns("APP_");
        appContext.SetupGet(x => x.PermisionsMinutesCache).Returns(30);
        return appContext;
    }

    private static Mock<IUserContext> BuildUserContext(string userId)
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
