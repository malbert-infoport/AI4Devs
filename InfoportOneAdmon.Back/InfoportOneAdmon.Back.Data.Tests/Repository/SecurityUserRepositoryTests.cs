using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using Helix6.Base.Application;
using Helix6.Base.Domain.Parameters;
using Helix6.Base.Domain.Security;
using Helix6.Base.Repository;
using InfoportOneAdmon.Back.Data.Repository.Base;
using InfoportOneAdmon.Back.Data.Tests.Helpers;
using InfoportOneAdmon.Back.DataModel.Base;
using Moq;
using Xunit;

namespace InfoportOneAdmon.Back.Data.Tests.Repository
{
    public class SecurityUserRepositoryTests
    {
        /// <summary>
        /// Verifica que GetSecurityUserByUserIdentifier filtra por UserContext.User.Id
        /// y devuelve el usuario esperado cuando existe coincidencia.
        /// </summary>
        [Fact]
        [Trait("Category", "Critical")]
        public async System.Threading.Tasks.Task GetSecurityUserByUserIdentifier_ReturnsExpectedUser_WhenUserExists()
        {
            var users = new List<SecurityUser>
            {
                new SecurityUser { Id = 1, UserIdentifier = "other-user", Login = "other" },
                new SecurityUser { Id = 2, UserIdentifier = "target-user", Login = "target" }
            };

            var appContext = BuildApplicationContext();
            var userContext = BuildUserContext("target-user");
            var dapperRepo = new Mock<IBaseDapperRepository<SecurityUser>>();
            var efRepo = new Mock<IBaseEFRepository<SecurityUser>>();

            efRepo
                .Setup(x => x.GetAllAsQueryable(It.IsAny<QueryParams>()))
                .Returns(new TestAsyncEnumerable<SecurityUser>(users));

            efRepo
                .Setup(x => x.LoadEntityWithChilds(It.IsAny<IQueryable<SecurityUser>>(), It.IsAny<string?>()))
                .ReturnsAsync((IQueryable<SecurityUser> query, string? _) => query.FirstOrDefault());

            var sut = new SecurityUserRepository(appContext.Object, userContext.Object, efRepo.Object, dapperRepo.Object);

            var result = await sut.GetSecurityUserByUserIdentifier();

            Assert.NotNull(result);
            Assert.Equal(2, result!.Id);
            Assert.Equal("target", result.Login);
        }

        /// <summary>
        /// Verifica que GetSecurityUserByUserIdentifier devuelve null cuando no hay
        /// ningún usuario con el identificador del contexto.
        /// </summary>
        [Fact]
        [Trait("Category", "Critical")]
        public async System.Threading.Tasks.Task GetSecurityUserByUserIdentifier_ReturnsNull_WhenUserDoesNotExist()
        {
            var users = new List<SecurityUser>
            {
                new SecurityUser { Id = 1, UserIdentifier = "other-user", Login = "other" }
            };

            var appContext = BuildApplicationContext();
            var userContext = BuildUserContext("target-user");
            var dapperRepo = new Mock<IBaseDapperRepository<SecurityUser>>();
            var efRepo = new Mock<IBaseEFRepository<SecurityUser>>();

            efRepo
                .Setup(x => x.GetAllAsQueryable(It.IsAny<QueryParams>()))
                .Returns(new TestAsyncEnumerable<SecurityUser>(users));

            efRepo
                .Setup(x => x.LoadEntityWithChilds(It.IsAny<IQueryable<SecurityUser>>(), It.IsAny<string?>()))
                .ReturnsAsync((IQueryable<SecurityUser> query, string? _) => query.FirstOrDefault());

            var sut = new SecurityUserRepository(appContext.Object, userContext.Object, efRepo.Object, dapperRepo.Object);

            var result = await sut.GetSecurityUserByUserIdentifier();

            Assert.Null(result);
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
            var principal = new ClaimsPrincipal(new ClaimsIdentity(new[] { new Claim("sub", userId) }, "TestAuth"));

            var claimsMapping = new Mock<IUserClaimsMapping>();
            claimsMapping.Setup(x => x.GetUserId(It.IsAny<ClaimsPrincipal>())).Returns(userId);
            claimsMapping.Setup(x => x.GetUserName(It.IsAny<ClaimsPrincipal>())).Returns("Security User");
            claimsMapping.Setup(x => x.GetDisplayName(It.IsAny<ClaimsPrincipal>())).Returns("Security User");
            claimsMapping.Setup(x => x.GetLogin(It.IsAny<ClaimsPrincipal>())).Returns("security.user");
            claimsMapping.Setup(x => x.GetMail(It.IsAny<ClaimsPrincipal>())).Returns("security.user@test.local");
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
