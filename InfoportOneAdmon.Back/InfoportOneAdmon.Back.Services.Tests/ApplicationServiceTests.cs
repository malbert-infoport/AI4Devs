using Helix6.Base.Application;
using Helix6.Base.Repository;
using Helix6.Base.Domain.Security;
using InfoportOneAdmon.Back.DataModel;
using InfoportOneAdmon.Back.Entities.Views;
using InfoportOneAdmon.Back.Services;
using Moq;
using Xunit;

namespace InfoportOneAdmon.Back.Services.Tests;

public class ApplicationServiceTests
{
    [Fact]
    [Trait("Category", "Critical")]
    public async Task GetById_DelegatesToRepository_ReturnsNullWhenNotFound()
    {
        var repo = new Mock<IBaseRepository<Application>>();
        repo.Setup(r => r.GetById(It.IsAny<int>(), It.IsAny<Helix6.Base.Domain.Parameters.QueryParams>())).ReturnsAsync((Application?)null);

        var appContext = new Mock<IApplicationContext>();
        appContext.SetupGet(a => a.ApplicationName).Returns("InfoportOneAdmon");
        var userContext = new Mock<IUserContext>();

        var sut = new ApplicationService(appContext.Object, userContext.Object, repo.Object);

        var result = await sut.GetById(1, (string?)null);

        Assert.Null(result);
        repo.Verify(r => r.GetById(1, It.IsAny<Helix6.Base.Domain.Parameters.QueryParams>()), Times.Once);
    }
}
