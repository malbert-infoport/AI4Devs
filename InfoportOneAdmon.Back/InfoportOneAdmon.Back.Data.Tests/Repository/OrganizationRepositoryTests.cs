using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Helix6.Base.Domain.Parameters;
using Helix6.Base.Repository;
using InfoportOneAdmon.Back.Data.Repository;
using InfoportOneAdmon.Back.DataModel;
using Moq;
using Xunit;

namespace InfoportOneAdmon.Back.Data.Tests.Repository
{
    public class OrganizationRepositoryTests
    {
        [Fact]
        public async Task ExistsActiveByName_ReturnsTrue_WhenActiveMatchExists()
        {
            var list = new List<Organization>
            {
                new Organization { Id = 1, Name = "Acme", AuditDeletionDate = null },
                new Organization { Id = 2, Name = "Other", AuditDeletionDate = null }
            };

            var efRepo = new Mock<IBaseEFRepository<Organization>>();
            efRepo.Setup(r => r.GetAllAsQueryable(It.IsAny<QueryParams>())).Returns(new InfoportOneAdmon.Back.Data.Tests.Helpers.TestAsyncEnumerable<Organization>(list));

            var appContext = new Mock<Helix6.Base.Domain.Security.IApplicationContext>();
            var userContext = new Mock<Helix6.Base.Application.IUserContext>();
            var dapper = new Mock<Helix6.Base.Repository.IBaseDapperRepository<Organization>>();

            var repo = new OrganizationRepository(appContext.Object, userContext.Object, efRepo.Object, dapper.Object);

            var exists = await repo.ExistsActiveByName("Acme", 0);

            Assert.True(exists);
        }

        [Fact]
        public async Task ExistsActiveByTaxId_ReturnsFalse_WhenInputBlank()
        {
            var efRepo = new Mock<IBaseEFRepository<Organization>>();
            efRepo.Setup(r => r.GetAllAsQueryable(It.IsAny<QueryParams>())).Returns(new InfoportOneAdmon.Back.Data.Tests.Helpers.TestAsyncEnumerable<Organization>(new List<Organization>()));

            var appContext = new Mock<Helix6.Base.Domain.Security.IApplicationContext>();
            var userContext = new Mock<Helix6.Base.Application.IUserContext>();
            var dapper = new Mock<Helix6.Base.Repository.IBaseDapperRepository<Organization>>();

            var repo = new OrganizationRepository(appContext.Object, userContext.Object, efRepo.Object, dapper.Object);

            var exists = await repo.ExistsActiveByTaxId(string.Empty, 0);

            Assert.False(exists);
        }

        [Fact]
        public async Task GetNextSecurityCompanyId_ReturnsMaxPlusOne()
        {
            var list = new List<Organization>
            {
                new Organization { Id = 1, SecurityCompanyId = 10 },
                new Organization { Id = 2, SecurityCompanyId = 15 },
                new Organization { Id = 3, SecurityCompanyId = 7 }
            };

            var efRepo = new Mock<IBaseEFRepository<Organization>>();
            efRepo.Setup(r => r.GetAllAsQueryable(It.IsAny<QueryParams>())).Returns(new InfoportOneAdmon.Back.Data.Tests.Helpers.TestAsyncEnumerable<Organization>(list));

            var appContext = new Mock<Helix6.Base.Domain.Security.IApplicationContext>();
            var userContext = new Mock<Helix6.Base.Application.IUserContext>();
            var dapper = new Mock<Helix6.Base.Repository.IBaseDapperRepository<Organization>>();

            var repo = new OrganizationRepository(appContext.Object, userContext.Object, efRepo.Object, dapper.Object);

            var next = await repo.GetNextSecurityCompanyId();

            Assert.Equal(16, next);
        }
    }
}
