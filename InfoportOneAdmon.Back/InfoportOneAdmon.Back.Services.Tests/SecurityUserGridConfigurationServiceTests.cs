using System.Security.Claims;
using Helix6.Base.Application;
using Helix6.Base.Domain;
using Helix6.Base.Domain.Parameters;
using Helix6.Base.Domain.Security;
using InfoportOneAdmon.Back.Data.Repository.Base.Interfaces;
using InfoportOneAdmon.Back.DataModel.Base;
using InfoportOneAdmon.Back.Entities;
using InfoportOneAdmon.Back.Entities.Views.Base;
using InfoportOneAdmon.Back.Services.Base;
using Moq;
using Xunit;

namespace InfoportOneAdmon.Back.Services.Tests;

public class SecurityUserGridConfigurationServiceTests
{
    /// <summary>
    /// Verifica que GetNewEntity asigna SecurityUserId con el usuario del contexto
    /// obtenido a través de SecurityUserService.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public async Task GetNewEntity_AssignsSecurityUserId_FromCurrentUser()
    {
        var securityUserRepository = new Mock<ISecurityUserRepository>();
        securityUserRepository
            .Setup(x => x.GetSecurityUserByUserIdentifier(It.IsAny<string?>()))
            .ReturnsAsync(new SecurityUser
            {
                Id = 44,
                SecurityCompanyId = 1,
                UserIdentifier = "grid-user",
                Login = "grid.login",
                Name = "Grid User",
                DisplayName = "Grid User",
                Mail = "grid@test.local",
                OrganizationCif = "B12345678",
                OrganizationCode = "0045",
                OrganizationName = "Company",
                SecurityUserConfiguration = new SecurityUserConfiguration()
            });

        var gridRepository = new Mock<ISecurityUserGridConfigurationRepository>();
        var sut = CreateSut(gridRepository, securityUserRepository);

        var result = await sut.GetNewEntity();

        Assert.NotNull(result);
        Assert.Equal(44, result!.SecurityUserId);
    }

    /// <summary>
    /// Verifica que PreviousActions desactiva la configuración por defecto previa
    /// cuando se inserta/actualiza otra configuración marcada como default.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public async Task PreviousActions_DisablesExistingDefaultConfiguration_WhenIncomingConfigurationIsDefault()
    {
        var securityUserRepository = new Mock<ISecurityUserRepository>();
        securityUserRepository
            .Setup(x => x.GetSecurityUserByUserIdentifier(It.IsAny<string?>()))
            .ReturnsAsync(new SecurityUser
            {
                Id = 8,
                SecurityCompanyId = 1,
                UserIdentifier = "grid-user",
                Login = "grid.login",
                Name = "Grid User",
                DisplayName = "Grid User",
                Mail = "grid@test.local",
                OrganizationCif = "B12345678",
                OrganizationCode = "0045",
                OrganizationName = "Company",
                SecurityUserConfiguration = new SecurityUserConfiguration()
            });

        var existingDefault = new SecurityUserGridConfiguration
        {
            Id = 100,
            SecurityUserId = 8,
            Entity = "Organization",
            DefaultConfiguration = true
        };

        var gridRepository = new Mock<ISecurityUserGridConfigurationRepository>();
        gridRepository
            .Setup(x => x.GetDefaultUserGridConfiguration("Organization", 8))
            .ReturnsAsync(existingDefault);

        var appContext = BuildApplicationContext();
        var userContext = BuildUserContext("grid-user");
        var securityUserService = new SecurityUserService(appContext.Object, userContext.Object, securityUserRepository.Object);

        var sutMock = new Mock<SecurityUserGridConfigurationService>(
            appContext.Object,
            userContext.Object,
            gridRepository.Object,
            securityUserService)
        {
            CallBase = true
        };

        SecurityUserGridConfigurationView? disabledDefault = null;
        SetParamsService? usedParams = null;
        sutMock
            .Setup(x => x.Update(It.IsAny<SecurityUserGridConfigurationView>(), It.IsAny<SetParamsService>()))
            .Callback<SecurityUserGridConfigurationView, SetParamsService>((view, setParams) =>
            {
                disabledDefault = view;
                usedParams = setParams;
            })
            .ReturnsAsync(true);

        var incoming = new SecurityUserGridConfigurationView
        {
            Id = 200,
            Entity = "Organization",
            DefaultConfiguration = true
        };

        await sutMock.Object.PreviousActions(incoming, HelixEnums.EnumActionType.Insert);

        Assert.Equal(8, incoming.SecurityUserId);
        Assert.NotNull(incoming.SecurityUser);
        Assert.NotNull(disabledDefault);
        Assert.Equal(100, disabledDefault!.Id);
        Assert.False(disabledDefault.DefaultConfiguration);
        Assert.NotNull(usedParams);
        Assert.False(usedParams!.ExecutePreviousActions);
    }

    private static SecurityUserGridConfigurationService CreateSut(
        Mock<ISecurityUserGridConfigurationRepository> gridRepository,
        Mock<ISecurityUserRepository> securityUserRepository)
    {
        var appContext = BuildApplicationContext();
        var userContext = BuildUserContext("grid-user");

        var securityUserService = new SecurityUserService(
            appContext.Object,
            userContext.Object,
            securityUserRepository.Object);

        return new SecurityUserGridConfigurationService(
            appContext.Object,
            userContext.Object,
            gridRepository.Object,
            securityUserService);
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
