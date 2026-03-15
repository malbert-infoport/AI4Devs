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
    public class PermissionsRepositoryTests
    {
        /// <summary>
        /// Verifica que para usuarios administrador se consulta directamente todo el catálogo
        /// de permisos usando Dapper.GetAll sin filtro.
        /// </summary>
        [Fact]
        [Trait("Category", "Critical")]
        public async System.Threading.Tasks.Task GetPermissions_ReturnsAll_WhenUserIsAdmin()
        {
            var appContext = BuildApplicationContext();
            var userContext = BuildUserContext(true, new List<string> { "APP_READ" });
            var efRepo = new Mock<IBaseEFRepository<Permissions>>();
            var dapperRepo = new Mock<IBaseDapperRepository<Permissions>>();

            dapperRepo
                .Setup(x => x.GetAll())
                .ReturnsAsync(new List<Permissions>
                {
                    new Permissions { Id = 1, SecurityAccessOptionId = 10 },
                    new Permissions { Id = 2, SecurityAccessOptionId = 11 }
                });

            var sut = new PermissionsRepository(appContext.Object, userContext.Object, efRepo.Object, dapperRepo.Object);

            var result = await sut.GetPermissions();

            Assert.Equal(2, result.Count);
            dapperRepo.Verify(x => x.GetAll(), Times.Once);
            dapperRepo.Verify(x => x.GetAll(It.IsAny<QueryParams>(), It.IsAny<IGenericFilter>()), Times.Never);
        }

        /// <summary>
        /// Verifica que para usuarios no administrador con roles se genera un filtro OR por rol
        /// y se invoca Dapper.GetAll(QueryParams, filter).
        /// </summary>
        [Fact]
        [Trait("Category", "Critical")]
        public async System.Threading.Tasks.Task GetPermissions_UsesRolesFilter_WhenUserIsNotAdminAndHasRoles()
        {
            var appContext = BuildApplicationContext();
            var userContext = BuildUserContext(false, new List<string> { "APP_READ", "APP_WRITE" });
            var efRepo = new Mock<IBaseEFRepository<Permissions>>();
            var dapperRepo = new Mock<IBaseDapperRepository<Permissions>>();

            HelixFilter? capturedFilter = null;
            dapperRepo
                .Setup(x => x.GetAll(It.IsAny<QueryParams>(), It.IsAny<IGenericFilter>()))
                .Callback<QueryParams, IGenericFilter?>((_, filter) => capturedFilter = filter as HelixFilter)
                .ReturnsAsync(new List<Permissions>
                {
                    new Permissions { Id = 3, SecurityAccessOptionId = 12 }
                });

            var sut = new PermissionsRepository(appContext.Object, userContext.Object, efRepo.Object, dapperRepo.Object);

            var result = await sut.GetPermissions();

            Assert.Single(result);
            Assert.NotNull(capturedFilter);
            Assert.Contains("\"Rol\" = 'APP_READ'", capturedFilter!.WhereToSql);
            Assert.Contains("\"Rol\" = 'APP_WRITE'", capturedFilter.WhereToSql);
        }

        /// <summary>
        /// Verifica que para usuarios no administrador sin roles el resultado es vacío
        /// y no se ejecutan consultas Dapper.
        /// </summary>
        [Fact]
        [Trait("Category", "Critical")]
        public async System.Threading.Tasks.Task GetPermissions_ReturnsEmpty_WhenUserIsNotAdminAndHasNoRoles()
        {
            var appContext = BuildApplicationContext();
            var userContext = BuildUserContext(false, new List<string>());
            var efRepo = new Mock<IBaseEFRepository<Permissions>>();
            var dapperRepo = new Mock<IBaseDapperRepository<Permissions>>();

            var sut = new PermissionsRepository(appContext.Object, userContext.Object, efRepo.Object, dapperRepo.Object);

            var result = await sut.GetPermissions();

            Assert.Empty(result);
            dapperRepo.Verify(x => x.GetAll(), Times.Never);
            dapperRepo.Verify(x => x.GetAll(It.IsAny<QueryParams>(), It.IsAny<IGenericFilter>()), Times.Never);
        }

        private static Mock<IApplicationContext> BuildApplicationContext()
        {
            var appContext = new Mock<IApplicationContext>();
            appContext.SetupGet(x => x.ApplicationName).Returns("InfoportOneAdmon");
            appContext.SetupGet(x => x.RolPrefixes).Returns("APP_");
            appContext.SetupGet(x => x.PermisionsMinutesCache).Returns(30);
            return appContext;
        }

        private static Mock<IUserContext> BuildUserContext(bool isAdmin, List<string> roles)
        {
            var principal = new ClaimsPrincipal(new ClaimsIdentity(new[] { new Claim("sub", "permissions-user") }, "TestAuth"));

            var claimsMapping = new Mock<IUserClaimsMapping>();
            claimsMapping.Setup(x => x.GetUserId(It.IsAny<ClaimsPrincipal>())).Returns("permissions-user");
            claimsMapping.Setup(x => x.GetUserName(It.IsAny<ClaimsPrincipal>())).Returns("Permissions User");
            claimsMapping.Setup(x => x.GetDisplayName(It.IsAny<ClaimsPrincipal>())).Returns("Permissions User");
            claimsMapping.Setup(x => x.GetLogin(It.IsAny<ClaimsPrincipal>())).Returns("permissions.user");
            claimsMapping.Setup(x => x.GetMail(It.IsAny<ClaimsPrincipal>())).Returns("permissions.user@test.local");
            claimsMapping.Setup(x => x.GetOrganizationCif(It.IsAny<ClaimsPrincipal>())).Returns("B12345678");
            claimsMapping.Setup(x => x.GetOrganizationCode(It.IsAny<ClaimsPrincipal>())).Returns("0045");
            claimsMapping.Setup(x => x.GetOrganizationName(It.IsAny<ClaimsPrincipal>())).Returns("Company");
            claimsMapping.Setup(x => x.GetSecurityCompanyId(It.IsAny<ClaimsPrincipal>())).Returns(1);
            claimsMapping.Setup(x => x.GetRoles(It.IsAny<ClaimsPrincipal>(), It.IsAny<string>())).Returns(roles);
            claimsMapping.Setup(x => x.GetIsAdmin(It.IsAny<ClaimsPrincipal>(), It.IsAny<string>())).Returns(isAdmin);
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
