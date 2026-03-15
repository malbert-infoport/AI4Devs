using System.Security.Claims;
using Helix6.Base.Application;
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

public class SecurityUserServiceTests
{
    /// <summary>
    /// Verifica que cuando no existe SecurityUser en repositorio, el servicio lo crea
    /// con configuración por defecto y devuelve LastConnectionDate nula en la respuesta.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public async Task GetOrCreateSecurityUser_CreatesUserWithDefaultConfiguration_WhenUserDoesNotExist()
    {
        var repository = new Mock<ISecurityUserRepository>();
        repository
            .Setup(x => x.GetSecurityUserByUserIdentifier(It.IsAny<string?>()))
            .ReturnsAsync((SecurityUser?)null);

        var sutMock = CreateSutMock(repository);

        SecurityUserView? insertedView = null;
        sutMock
            .Setup(x => x.Insert(It.IsAny<SecurityUserView>(), It.IsAny<SetParamsService>()))
            .Callback<SecurityUserView, SetParamsService>((view, _) => insertedView = view)
            .ReturnsAsync(1);

        var result = await sutMock.Object.GetOrCreateSecurityUser();

        Assert.NotNull(insertedView);
        Assert.NotNull(insertedView!.SecurityUserConfiguration);
        Assert.Equal(20, insertedView.SecurityUserConfiguration.Pagination);
        Assert.Equal(4, insertedView.SecurityUserConfiguration.ModalPagination);
        Assert.Equal("es-ES", insertedView.SecurityUserConfiguration.Language);
        Assert.Null(result.SecurityUserConfiguration.LastConnectionDate);
    }

    /// <summary>
    /// Verifica que GetSecurityUser devuelve nulo cuando el repositorio no encuentra
    /// un usuario asociado al identificador del contexto.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public async Task GetSecurityUser_ReturnsNull_WhenRepositoryDoesNotFindUser()
    {
        var repository = new Mock<ISecurityUserRepository>();
        repository
            .Setup(x => x.GetSecurityUserByUserIdentifier(It.IsAny<string?>()))
            .ReturnsAsync((SecurityUser?)null);

        var sutMock = CreateSutMock(repository);

        var result = await sutMock.Object.GetSecurityUser();

        Assert.Null(result);
    }

    /// <summary>
    /// Verifica que GetSecurityUser mapea correctamente cuando el repositorio devuelve
    /// un usuario existente para el identificador del contexto.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public async Task GetSecurityUser_ReturnsMappedView_WhenRepositoryFindsUser()
    {
        var repository = new Mock<ISecurityUserRepository>();
        repository
            .Setup(x => x.GetSecurityUserByUserIdentifier(It.IsAny<string?>()))
            .ReturnsAsync(new SecurityUser
            {
                Id = 7,
                UserIdentifier = "user-1",
                Login = "user.login",
                Name = "User Name",
                DisplayName = "Display Name",
                Mail = "user@test.local",
                SecurityCompanyId = 1
            });

        var appContext = BuildApplicationContext();
        var userContext = BuildUserContext("user-1");
        var sut = new SecurityUserService(appContext.Object, userContext.Object, repository.Object);

        var result = await sut.GetSecurityUser();

        Assert.NotNull(result);
        Assert.Equal(7, result!.Id);
        Assert.Equal("user.login", result.Login);
        Assert.Equal("User Name", result.Name);
    }

    private static Mock<SecurityUserService> CreateSutMock(Mock<ISecurityUserRepository> repository)
    {
        var appContext = BuildApplicationContext();
        var userContext = BuildUserContext("user-1");

        var sutMock = new Mock<SecurityUserService>(appContext.Object, userContext.Object, repository.Object)
        {
            CallBase = true
        };

        return sutMock;
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
