using System.Collections.Generic;
using Helix6.Base.Application;
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
        /// Verifica que el repositorio VTA se construye correctamente con sus dependencias
        /// y mantiene la herencia esperada del repositorio base.
        /// </summary>
        [Fact]
        [Trait("Category", "Critical")]
        public void Constructor_CreatesRepositoryInstance()
        {
            var appContext = new Mock<IApplicationContext>();
            var userContext = new Mock<IUserContext>();
            var efRepo = new Mock<IBaseEFRepository<VTA_Organization>>();
            var dapperRepo = new Mock<IBaseDapperRepository<VTA_Organization>>();

            var sut = new VTA_OrganizationRepository(appContext.Object, userContext.Object, efRepo.Object, dapperRepo.Object);

            Assert.NotNull(sut);
            Assert.IsAssignableFrom<IBaseRepository<VTA_Organization>>(sut);
        }
    }
}
