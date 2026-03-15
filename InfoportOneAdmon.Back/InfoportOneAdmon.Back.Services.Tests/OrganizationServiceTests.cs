using System.Security.Claims;
using Helix6.Base.Application;
using Helix6.Base.Domain;
using Helix6.Base.Domain.Security;
using Helix6.Base.Domain.Validations;
using Helix6.Base.Repository;
using InfoportOneAdmon.Back.Data.Repository.Interfaces;
using InfoportOneAdmon.Back.DataModel;
using InfoportOneAdmon.Back.Entities;
using InfoportOneAdmon.Back.Entities.Views;
using InfoportOneAdmon.Back.Services;
using Microsoft.Extensions.Logging;
using Moq;
using Xunit;

namespace InfoportOneAdmon.Back.Services.Tests;

public class OrganizationServiceTests
{
    /// <summary>
    /// Verifica que una inserción sin permiso de modificación de datos (201)
    /// añade el error de negocio CREATE_FORBIDDEN.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public async Task ValidateView_AddsCreateForbidden_WhenInsertWithoutDataModificationPermission()
    {
        var orgRepository = new Mock<IOrganizationRepository>();
        orgRepository.Setup(x => x.ExistsActiveByName(It.IsAny<string>(), It.IsAny<int>())).ReturnsAsync(false);
        orgRepository.Setup(x => x.ExistsActiveByTaxId(It.IsAny<string>(), It.IsAny<int>())).ReturnsAsync(false);

        var sut = CreateSut(orgRepository, new List<int> { Consts.SecurityAccessOption.OrganizationOptions.ORGANIZATION_MODULES_QUERY });

        var validations = new HelixValidationProblem();
        var view = BuildValidView();

        await sut.ValidateView(validations, view, HelixEnums.EnumActionType.Insert);

        Assert.Contains(validations.HelixErrors, e => e.ErrorCode == Consts.Validations.Organization.CREATE_FORBIDDEN);
    }

    /// <summary>
    /// Verifica que los campos mínimos de negocio y formato de email se validan correctamente
    /// añadiendo NAME_REQUIRED, TAXID_REQUIRED y CONTACT_EMAIL_INVALID cuando corresponde.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public async Task ValidateView_AddsRequiredAndEmailErrors_WhenInputIsInvalid()
    {
        var orgRepository = new Mock<IOrganizationRepository>();
        orgRepository.Setup(x => x.ExistsActiveByName(It.IsAny<string>(), It.IsAny<int>())).ReturnsAsync(false);
        orgRepository.Setup(x => x.ExistsActiveByTaxId(It.IsAny<string>(), It.IsAny<int>())).ReturnsAsync(false);

        var sut = CreateSut(orgRepository, new List<int> { Consts.SecurityAccessOption.OrganizationOptions.ORGANIZATION_DATA_MODIFICATION });

        var validations = new HelixValidationProblem();
        var view = new OrganizationView
        {
            Name = string.Empty,
            TaxId = string.Empty,
            ContactEmail = "invalid-email"
        };

        await sut.ValidateView(validations, view, HelixEnums.EnumActionType.Insert);

        Assert.Contains(validations.HelixErrors, e => e.ErrorCode == Consts.Validations.Organization.NAME_REQUIRED);
        Assert.Contains(validations.HelixErrors, e => e.ErrorCode == Consts.Validations.Organization.TAXID_REQUIRED);
        Assert.Contains(validations.HelixErrors, e => e.ErrorCode == Consts.Validations.Organization.CONTACT_EMAIL_INVALID);
    }

    /// <summary>
    /// Verifica que la validación de unicidad añade errores de nombre y taxId
    /// cuando el repositorio detecta registros activos duplicados.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public async Task ValidateView_AddsDuplicateErrors_WhenRepositoryReportsActiveDuplicates()
    {
        var orgRepository = new Mock<IOrganizationRepository>();
        orgRepository.Setup(x => x.ExistsActiveByName("Company", It.IsAny<int>())).ReturnsAsync(true);
        orgRepository.Setup(x => x.ExistsActiveByTaxId("B12345678", It.IsAny<int>())).ReturnsAsync(true);

        var sut = CreateSut(orgRepository, new List<int> { Consts.SecurityAccessOption.OrganizationOptions.ORGANIZATION_DATA_MODIFICATION });

        var validations = new HelixValidationProblem();
        var view = BuildValidView();

        await sut.ValidateView(validations, view, HelixEnums.EnumActionType.Update);

        Assert.Contains(validations.HelixErrors, e => e.ErrorCode == Consts.Validations.Organization.NAME_ALREADY_EXISTS);
        Assert.Contains(validations.HelixErrors, e => e.ErrorCode == Consts.Validations.Organization.TAXID_ALREADY_EXISTS);
    }

    /// <summary>
    /// Verifica que, cuando GroupId viene informado pero no existe grupo activo,
    /// se registra el error GROUP_NOT_FOUND_OR_INACTIVE.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public async Task ValidateView_AddsGroupError_WhenGroupDoesNotExist()
    {
        var orgRepository = new Mock<IOrganizationRepository>();
        orgRepository.Setup(x => x.ExistsActiveByName(It.IsAny<string>(), It.IsAny<int>())).ReturnsAsync(false);
        orgRepository.Setup(x => x.ExistsActiveByTaxId(It.IsAny<string>(), It.IsAny<int>())).ReturnsAsync(false);

        var sut = CreateSut(orgRepository, new List<int> { Consts.SecurityAccessOption.OrganizationOptions.ORGANIZATION_DATA_MODIFICATION });

        var validations = new HelixValidationProblem();
        var view = BuildValidView();
        view.GroupId = 55;

        await sut.ValidateView(validations, view, HelixEnums.EnumActionType.Update);

        Assert.Contains(validations.HelixErrors, e => e.ErrorCode == Consts.Validations.Organization.GROUP_NOT_FOUND_OR_INACTIVE);
    }

    /// <summary>
    /// Verifica que GetNewEntity asigna el próximo SecurityCompanyId devuelto
    /// por el repositorio de organizaciones.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public async Task GetNewEntity_AssignsNextSecurityCompanyId_FromRepository()
    {
        var orgRepository = new Mock<IOrganizationRepository>();
        orgRepository.Setup(x => x.GetNextSecurityCompanyId()).ReturnsAsync(99);

        var sut = CreateSut(orgRepository, new List<int> { Consts.SecurityAccessOption.OrganizationOptions.ORGANIZATION_DATA_MODIFICATION });

        var result = await sut.GetNewEntity();

        Assert.NotNull(result);
        Assert.Equal(99, result!.SecurityCompanyId);
    }

    /// <summary>
    /// Verifica que EndActions marca EventSent=true cuando la entidad indica
    /// que se debe publicar evento de organización.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public async Task EndActions_SetsEventSentTrue_WhenPublishOrganizationEventIsTrue()
    {
        var orgRepository = new Mock<IOrganizationRepository>();
        var sut = CreateSut(orgRepository, new List<int> { Consts.SecurityAccessOption.OrganizationOptions.ORGANIZATION_DATA_MODIFICATION });

        var view = BuildValidView();
        view.PublishOrganizationEvent = true;

        await sut.EndActions(view, HelixEnums.EnumActionType.Update, null);

        Assert.True(view.EventSent);
    }

    /// <summary>
    /// Verifica que EndActions marca EventSent=false cuando no corresponde
    /// publicar evento de organización.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public async Task EndActions_SetsEventSentFalse_WhenPublishOrganizationEventIsFalse()
    {
        var orgRepository = new Mock<IOrganizationRepository>();
        var sut = CreateSut(orgRepository, new List<int> { Consts.SecurityAccessOption.OrganizationOptions.ORGANIZATION_DATA_MODIFICATION });

        var view = BuildValidView();
        view.PublishOrganizationEvent = false;

        await sut.EndActions(view, HelixEnums.EnumActionType.Update, null);

        Assert.False(view.EventSent);
    }

    private static OrganizationView BuildValidView()
    {
        return new OrganizationView
        {
            Id = 1,
            Name = "Company",
            Acronym = "CMP",
            TaxId = "B12345678",
            Address = "Main Street",
            City = "Valencia",
            PostalCode = "46001",
            Country = "ES",
            ContactEmail = "test@company.es",
            ContactPhone = "+34960000000"
        };
    }

    private static OrganizationService CreateSut(Mock<IOrganizationRepository> organizationRepository, List<int> grantedPermissions)
    {
        var applicationContext = BuildApplicationContext();
        var userContext = BuildUserContext("org-user");

        var userPermissions = new Mock<IUserPermissions>();
        userPermissions.Setup(x => x.GetUserPermissions())
            .ReturnsAsync(new AuthPermissions { Permissions = grantedPermissions });

        var groupRepo = new Mock<IBaseRepository<OrganizationGroup>>();
        groupRepo.Setup(x => x.GetById(It.IsAny<int>(), It.IsAny<string?>())).ReturnsAsync((OrganizationGroup?)null);

        var organizationGroupService = new OrganizationGroupService(
            applicationContext.Object,
            userContext.Object,
            groupRepo.Object);

        var auditRepo = new Mock<IBaseRepository<AuditLog>>();
        var auditLogger = new Mock<ILogger<AuditLogService>>();
        var auditService = new AuditLogService(
            applicationContext.Object,
            userContext.Object,
            auditRepo.Object,
            auditLogger.Object);

        var appModuleRepository = new Mock<IBaseRepository<ApplicationModule>>();
        appModuleRepository.Setup(x => x.GetById(It.IsAny<int>(), It.IsAny<string?>())).ReturnsAsync((ApplicationModule?)null);

        var logger = new Mock<ILogger<OrganizationService>>();

        return new OrganizationService(
            applicationContext.Object,
            userContext.Object,
            organizationRepository.Object,
            userPermissions.Object,
            organizationGroupService,
            auditService,
            appModuleRepository.Object,
            logger.Object);
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
