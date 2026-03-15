using System.Collections.Generic;
using Helix6.Base.Application;
using Helix6.Base.Domain.EntitiesConfiguration;
using Helix6.Base.Domain.Parameters;
using Helix6.Base.Domain.Security;
using Helix6.Base.Repository;
using InfoportOneAdmon.Back.Data.Repository;
using InfoportOneAdmon.Back.DataModel;
using Moq;
using Xunit;

namespace InfoportOneAdmon.Back.Data.Tests.Repository
{
    public class VTA_OrganizationRepositoryTests
    {
        /// <summary>
        /// Verifica que GetAll delega en Dapper para configuraciones simples
        /// y reenvia los parametros recibidos.
        /// </summary>
        [Fact]
        [Trait("Category", "Critical")]
        public async System.Threading.Tasks.Task GetAll_UsesDapper_ForSimpleConfiguration_AndForwardsParameters()
        {
            var appContext = BuildApplicationContext();
            var userContext = new Mock<IUserContext>();
            var efRepo = new Mock<IBaseEFRepository<VTA_Organization>>();
            var dapperRepo = new Mock<IBaseDapperRepository<VTA_Organization>>();

            var queryParams = new QueryParams("default", true);
            var genericFilter = new HelixFilter { WhereToSql = "\"Id\" > 0" };
            QueryParams? capturedQueryParams = null;
            IGenericFilter? capturedFilter = null;

            dapperRepo
                .Setup(x => x.GetAll(It.IsAny<QueryParams>(), It.IsAny<IGenericFilter>()))
                .Callback<QueryParams, IGenericFilter?>((q, f) =>
                {
                    capturedQueryParams = q;
                    capturedFilter = f;
                })
                .ReturnsAsync(new List<VTA_Organization>
                {
                    new VTA_Organization { Id = 1, Name = "Org 1", TaxId = "B11111111" }
                });

            var sut = new VTA_OrganizationRepository(appContext.Object, userContext.Object, efRepo.Object, dapperRepo.Object);

            var result = await sut.GetAll(queryParams, genericFilter);

            Assert.Single(result);
            Assert.NotNull(capturedQueryParams);
            Assert.Same(queryParams, capturedQueryParams);
            Assert.NotNull(capturedFilter);
            Assert.Same(genericFilter, capturedFilter);
            dapperRepo.Verify(x => x.GetAll(It.IsAny<QueryParams>(), It.IsAny<IGenericFilter>()), Times.Once);
            efRepo.Verify(x => x.GetAll(It.IsAny<QueryParams>(), It.IsAny<IGenericFilter>()), Times.Never);
        }

        private static Mock<IApplicationContext> BuildApplicationContext()
        {
            var entities = new HelixEntities();
            entities.Entities.Add(new HelixEntity
            {
                EntityName = nameof(VTA_Organization),
                ViewName = "VTA_OrganizationView",
                Configurations = new List<HelixEntityConfiguration>
                {
                    new HelixEntityConfiguration { ConfigurationName = "default" }
                }
            });

            var appContext = new Mock<IApplicationContext>();
            appContext.SetupGet(x => x.ApplicationName).Returns("InfoportOneAdmon");
            appContext.SetupGet(x => x.EntitiesConfiguration).Returns(entities);

            return appContext;
        }
    }
}
