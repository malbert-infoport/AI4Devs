using Helix6.Base.Application;
using Helix6.Base.Repository;
using Helix6.Base.Domain.Security;
using InfoportOneAdmon.Back.DataModel;
using InfoportOneAdmon.Back.Entities.Views;
using InfoportOneAdmon.Back.Services;
using Moq;
using Xunit;

namespace InfoportOneAdmon.Back.Services.Tests;

public class OrganizationGroupServiceTests
{
    [Fact]
    [Trait("Category", "Critical")]
    public async Task GetById_DelegatesToRepository_ReturnsNullWhenNotFound()
    {
        var repo = new Mock<IBaseRepository<OrganizationGroup>>();
        repo.Setup(r => r.GetById(It.IsAny<int>(), It.IsAny<Helix6.Base.Domain.Parameters.QueryParams>())).ReturnsAsync((OrganizationGroup?)null);

        var appContext = new Mock<IApplicationContext>();
        appContext.SetupGet(a => a.ApplicationName).Returns("InfoportOneAdmon");
        var userContext = new Mock<IUserContext>();

        var sut = new OrganizationGroupService(appContext.Object, userContext.Object, repo.Object);

        var result = await sut.GetById(1, (string?)null);

        Assert.Null(result);
        repo.Verify(r => r.GetById(1, It.IsAny<Helix6.Base.Domain.Parameters.QueryParams>()), Times.Once);
    }

    [Fact]
    [Trait("Category", "Critical")]
    public async Task GetNewEntity_InitializesOrganizationCollection()
    {
        var repo = new Mock<IBaseRepository<OrganizationGroup>>();

        var appContext = new Mock<IApplicationContext>();
        appContext.SetupGet(a => a.ApplicationName).Returns("InfoportOneAdmon");
        var userContext = new Mock<IUserContext>();

        var sut = new OrganizationGroupService(appContext.Object, userContext.Object, repo.Object);

        var result = await sut.GetNewEntity();

        Assert.NotNull(result);
        Assert.NotNull(result!.Organization);
        Assert.Empty(result.Organization);
    }

    [Fact]
    [Trait("Category", "Critical")]
    public async Task ValidateView_DoesNotAddErrors_ForValidView()
    {
        var repo = new Mock<IBaseRepository<OrganizationGroup>>();

        var appContext = new Mock<IApplicationContext>();
        appContext.SetupGet(a => a.ApplicationName).Returns("InfoportOneAdmon");
        var userContext = new Mock<IUserContext>();

        var sut = new OrganizationGroupService(appContext.Object, userContext.Object, repo.Object);

        var validations = new Helix6.Base.Domain.Validations.HelixValidationProblem();
        var view = new OrganizationGroupView { GroupName = "Group A", Description = "Desc" };

        await sut.ValidateView(validations, view, Helix6.Base.Domain.HelixEnums.EnumActionType.Insert);

        Assert.Empty(validations.HelixErrors);
    }
}
