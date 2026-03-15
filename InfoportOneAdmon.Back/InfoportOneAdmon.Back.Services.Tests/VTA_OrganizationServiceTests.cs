using System.Collections.Generic;
using Helix6.Base.Application;
using Helix6.Base.Domain.Parameters;
using Helix6.Base.Domain.Security;
using InfoportOneAdmon.Back.Data.Repository.Interfaces;
using InfoportOneAdmon.Back.DataModel;
using InfoportOneAdmon.Back.Services;
using Moq;
using Xunit;

namespace InfoportOneAdmon.Back.Services.Tests;

public class VTA_OrganizationServiceTests
{
    /// <summary>
    /// Verifica que GetAll reenvia los parametros al repositorio VTA
    /// y devuelve el resultado esperado sin relajar la verificacion de entrada.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public async System.Threading.Tasks.Task GetAll_DelegatesToRepository_AndReturnsMappedViews()
    {
        var repository = new Mock<IVTA_OrganizationRepository>();
        var queryParams = new QueryParams("default", true);
        var genericFilter = new HelixFilter { WhereToSql = "\"Id\" > 0" };

        repository
            .Setup(x => x.GetAll(
                It.Is<QueryParams>(q => q.ConfigurationName == "default" && q.IncludeDeleted),
                It.Is<IGenericFilter>(f => f != null && ((HelixFilter)f).WhereToSql == "\"Id\" > 0")))
            .ReturnsAsync(new List<VTA_Organization>());

        var appContext = new Mock<IApplicationContext>();
        appContext.SetupGet(x => x.ApplicationName).Returns("InfoportOneAdmon");
        var userContext = new Mock<IUserContext>();

        var sut = new VTA_OrganizationService(appContext.Object, userContext.Object, repository.Object);

        var result = await sut.GetAll(queryParams, genericFilter);

        Assert.Empty(result);
        repository.Verify(x => x.GetAll(
            It.Is<QueryParams>(q => q.ConfigurationName == "default" && q.IncludeDeleted),
            It.Is<IGenericFilter>(f => f != null && ((HelixFilter)f).WhereToSql == "\"Id\" > 0")), Times.Once);
    }
}
