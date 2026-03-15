using System.Collections.Generic;
using System.Security.Claims;
using Helix6.Base.Application;
using Helix6.Base.Domain.Parameters;
using Helix6.Base.Domain.Security;
using Helix6.Base.Repository;
using InfoportOneAdmon.Back.Data.Repository.Base;
using InfoportOneAdmon.Back.DataModel.Base;
using Moq;
using Xunit;

namespace InfoportOneAdmon.Back.Data.Tests.Repository
{
    public class SecurityUserGridConfigurationRepositoryTests
    {
        /// <summary>
        /// Verifica que GetConfigurations construye el filtro por entidad y usuario,
        /// y devuelve los elementos de Dapper.
        /// </summary>
        [Fact]
        [Trait("Category", "Critical")]
        public async System.Threading.Tasks.Task GetConfigurations_BuildsExpectedFilter_AndReturnsList()
        {
            var appContext = BuildApplicationContext();
            var userContext = BuildUserContext();
            var efRepo = new Mock<IBaseEFRepository<SecurityUserGridConfiguration>>();
            var dapperRepo = new Mock<IBaseDapperRepository<SecurityUserGridConfiguration>>();

            HelixFilter? capturedFilter = null;
            dapperRepo
                .Setup(x => x.GetAll(It.IsAny<QueryParams>(), It.IsAny<IGenericFilter>()))
                .Callback<QueryParams, IGenericFilter?>((_, filter) => capturedFilter = filter as HelixFilter)
                .ReturnsAsync(new List<SecurityUserGridConfiguration>
                {
                    new SecurityUserGridConfiguration { Id = 1, Entity = "Organization", SecurityUserId = 7 }
                });

            var sut = new SecurityUserGridConfigurationRepository(appContext.Object, userContext.Object, efRepo.Object, dapperRepo.Object);

            var result = await sut.GetConfigurations("Organization", 7);

            Assert.NotNull(result);
            Assert.Single(result!);
            Assert.NotNull(capturedFilter);
            Assert.Contains("\"Entity\" = 'Organization'", capturedFilter!.WhereToSql);
            Assert.Contains("\"SecurityUserId\" = 7", capturedFilter.WhereToSql);
        }

        /// <summary>
        /// Verifica que GetDefaultUserGridConfiguration añade la condición de DefaultConfiguration
        /// y devuelve el primer elemento de la lista resultante.
        /// </summary>
        [Fact]
        [Trait("Category", "Critical")]
        public async System.Threading.Tasks.Task GetDefaultUserGridConfiguration_ReturnsFirstMatch_WhenListHasItems()
        {
            var appContext = BuildApplicationContext();
            var userContext = BuildUserContext();
            var efRepo = new Mock<IBaseEFRepository<SecurityUserGridConfiguration>>();
            var dapperRepo = new Mock<IBaseDapperRepository<SecurityUserGridConfiguration>>();

            HelixFilter? capturedFilter = null;
            dapperRepo
                .Setup(x => x.GetAll(It.IsAny<QueryParams>(), It.IsAny<IGenericFilter>()))
                .Callback<QueryParams, IGenericFilter?>((_, filter) => capturedFilter = filter as HelixFilter)
                .ReturnsAsync(new List<SecurityUserGridConfiguration>
                {
                    new SecurityUserGridConfiguration { Id = 9, Entity = "Organization", SecurityUserId = 7, DefaultConfiguration = true },
                    new SecurityUserGridConfiguration { Id = 10, Entity = "Organization", SecurityUserId = 7, DefaultConfiguration = true }
                });

            var sut = new SecurityUserGridConfigurationRepository(appContext.Object, userContext.Object, efRepo.Object, dapperRepo.Object);

            var result = await sut.GetDefaultUserGridConfiguration("Organization", 7);

            Assert.NotNull(result);
            Assert.Equal(9, result!.Id);
            Assert.NotNull(capturedFilter);
            Assert.Contains("\"DefaultConfiguration\" = True", capturedFilter!.WhereToSql);
        }

        /// <summary>
        /// Verifica que GetDefaultUserGridConfiguration devuelve null
        /// cuando no hay configuraciones por defecto para el usuario.
        /// </summary>
        [Fact]
        [Trait("Category", "Critical")]
        public async System.Threading.Tasks.Task GetDefaultUserGridConfiguration_ReturnsNull_WhenListIsEmpty()
        {
            var appContext = BuildApplicationContext();
            var userContext = BuildUserContext();
            var efRepo = new Mock<IBaseEFRepository<SecurityUserGridConfiguration>>();
            var dapperRepo = new Mock<IBaseDapperRepository<SecurityUserGridConfiguration>>();

            HelixFilter? capturedFilter = null;
            dapperRepo
                .Setup(x => x.GetAll(It.IsAny<QueryParams>(), It.IsAny<IGenericFilter>()))
                .Callback<QueryParams, IGenericFilter?>((_, filter) => capturedFilter = filter as HelixFilter)
                .ReturnsAsync(new List<SecurityUserGridConfiguration>());

            var sut = new SecurityUserGridConfigurationRepository(appContext.Object, userContext.Object, efRepo.Object, dapperRepo.Object);

            var result = await sut.GetDefaultUserGridConfiguration("Organization", 7);

            Assert.Null(result);
            Assert.NotNull(capturedFilter);
            Assert.Contains("\"Entity\" = 'Organization'", capturedFilter!.WhereToSql);
            Assert.Contains("\"SecurityUserId\" = 7", capturedFilter.WhereToSql);
            Assert.Contains("\"DefaultConfiguration\" = True", capturedFilter.WhereToSql);
        }

        private static Mock<IApplicationContext> BuildApplicationContext()
        {
            var appContext = new Mock<IApplicationContext>();
            appContext.SetupGet(x => x.ApplicationName).Returns("InfoportOneAdmon");
            appContext.SetupGet(x => x.RolPrefixes).Returns("APP_");
            appContext.SetupGet(x => x.PermisionsMinutesCache).Returns(30);
            return appContext;
        }

        private static Mock<IUserContext> BuildUserContext()
        {
            var principal = new ClaimsPrincipal(new ClaimsIdentity(new[] { new Claim("sub", "grid-user") }, "TestAuth"));

            var claimsMapping = new Mock<IUserClaimsMapping>();
            claimsMapping.Setup(x => x.GetUserId(It.IsAny<ClaimsPrincipal>())).Returns("grid-user");
            claimsMapping.Setup(x => x.GetUserName(It.IsAny<ClaimsPrincipal>())).Returns("Grid User");
            claimsMapping.Setup(x => x.GetDisplayName(It.IsAny<ClaimsPrincipal>())).Returns("Grid User");
            claimsMapping.Setup(x => x.GetLogin(It.IsAny<ClaimsPrincipal>())).Returns("grid.user");
            claimsMapping.Setup(x => x.GetMail(It.IsAny<ClaimsPrincipal>())).Returns("grid.user@test.local");
            claimsMapping.Setup(x => x.GetOrganizationCif(It.IsAny<ClaimsPrincipal>())).Returns("B12345678");
            claimsMapping.Setup(x => x.GetOrganizationCode(It.IsAny<ClaimsPrincipal>())).Returns("0045");
            claimsMapping.Setup(x => x.GetOrganizationName(It.IsAny<ClaimsPrincipal>())).Returns("Company");
            claimsMapping.Setup(x => x.GetSecurityCompanyId(It.IsAny<ClaimsPrincipal>())).Returns(1);
            claimsMapping.Setup(x => x.GetRoles(It.IsAny<ClaimsPrincipal>(), It.IsAny<string>())).Returns(new List<string> { "APP_READ" });
            claimsMapping.Setup(x => x.GetIsAdmin(It.IsAny<ClaimsPrincipal>(), It.IsAny<string>())).Returns(false);
            claimsMapping.Setup(x => x.GetSendClaimsToFront()).Returns(false);

            var appContext = BuildApplicationContext();
            var user = new AuthUser(principal, claimsMapping.Object, appContext.Object);
            var application = new AuthApplication(principal, claimsMapping.Object, appContext.Object);

            var userContext = new Mock<IUserContext>();
            userContext.SetupGet(x => x.User).Returns(user);
            userContext.SetupGet(x => x.AuthenticationType).Returns("JwtBearer");
            userContext.SetupGet(x => x.Applications).Returns(new List<AuthApplication> { application });
            userContext.SetupProperty(x => x.Claims, new List<AuthClaim>());
            userContext.SetupGet(x => x.SendClaimsToFront).Returns(false);

            return userContext;
        }
    }
}
