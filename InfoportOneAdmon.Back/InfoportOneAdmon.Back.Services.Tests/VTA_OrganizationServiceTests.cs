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
    /// Verifica que GetAll delega en el repositorio VTA y devuelve
    /// las vistas mapeadas a partir de las entidades recuperadas.
    /// </summary>
    [Fact]
    [Trait("Category", "Critical")]
    public async System.Threading.Tasks.Task GetAll_DelegatesToRepository_AndReturnsMappedViews()
    {
        var repository = new Mock<IVTA_OrganizationRepository>();
        repository
            .Setup(x => x.GetAll(It.IsAny<QueryParams>(), It.IsAny<IGenericFilter>()))
            .ReturnsAsync(new List<VTA_Organization>
            {
                new VTA_Organization { Id = 1, Name = "Org 1", TaxId = "B11111111" },
                new VTA_Organization { Id = 2, Name = "Org 2", TaxId = "B22222222" }
            });

        var appContext = new Mock<IApplicationContext>();
        appContext.SetupGet(x => x.ApplicationName).Returns("InfoportOneAdmon");
        var userContext = new Mock<IUserContext>();

        var sut = new VTA_OrganizationService(appContext.Object, userContext.Object, repository.Object);

        var result = await sut.GetAll(new QueryParams());

        Assert.Equal(2, result.Count);
        Assert.Equal("Org 1", result[0].Name);
        Assert.Equal("Org 2", result[1].Name);
        repository.Verify(x => x.GetAll(It.IsAny<QueryParams>(), It.IsAny<IGenericFilter>()), Times.Once);
    }
}
