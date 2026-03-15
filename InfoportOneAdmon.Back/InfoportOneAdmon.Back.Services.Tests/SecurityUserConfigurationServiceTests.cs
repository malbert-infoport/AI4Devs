using System.Security.Claims;
using System.Collections.Generic;
using Helix6.Base.Application;
using Helix6.Base.Domain.Parameters;
using Helix6.Base.Domain.Security;
using Helix6.Base.Repository;
using InfoportOneAdmon.Back.DataModel.Base;
using InfoportOneAdmon.Back.Data.Repository.Base.Interfaces;
using InfoportOneAdmon.Back.Entities.Views.Base;
using InfoportOneAdmon.Back.Services.Base;
using Moq;
using Xunit;

namespace InfoportOneAdmon.Back.Services.Tests
{
    public class SecurityUserConfigurationServiceTests
    {
        /// <summary>
        /// Verifica que GetUserConfiguration devuelve nulo cuando no existe SecurityUser asociado
        /// al usuario autenticado en el contexto.
        /// </summary>
        [Fact]
        [Trait("Category", "Critical")]
        public async System.Threading.Tasks.Task GetUserConfiguration_ReturnsNull_WhenNoSecurityUser()
        {
            var securityUserRepo = new Mock<ISecurityUserRepository>();
            securityUserRepo.Setup(x => x.GetSecurityUserByUserIdentifier(It.IsAny<string?>())).ReturnsAsync((SecurityUser?)null);

            var appContext = BuildApplicationContext();
            var userContext = BuildUserContext("no-user");

            var securityUserService = new SecurityUserService(appContext.Object, userContext.Object, securityUserRepo.Object);

            var repo = new Mock<IBaseRepository<InfoportOneAdmon.Back.DataModel.Base.SecurityUserConfiguration>>();

            var sut = new SecurityUserConfigurationService(appContext.Object, userContext.Object, repo.Object, securityUserService);

            var result = await sut.GetUserConfiguration();

            Assert.Null(result);
        }

        /// <summary>
        /// Verifica que GetUserConfiguration devuelve la configuración cuando el SecurityUser
        /// tiene SecurityUserConfigurationId informado.
        /// </summary>
        [Fact]
        [Trait("Category", "Critical")]
        public async System.Threading.Tasks.Task GetUserConfiguration_ReturnsView_WhenSecurityUserHasConfig()
        {
            var securityUserRepo = new Mock<ISecurityUserRepository>();
            securityUserRepo.Setup(x => x.GetSecurityUserByUserIdentifier(It.IsAny<string?>())).ReturnsAsync(new SecurityUser { Id = 7, SecurityUserConfigurationId = 11 });

            var appContext = BuildApplicationContext();
            var userContext = BuildUserContext("user-7");

            var securityUserService = new SecurityUserService(appContext.Object, userContext.Object, securityUserRepo.Object);

            var repo = new Mock<IBaseRepository<InfoportOneAdmon.Back.DataModel.Base.SecurityUserConfiguration>>();
            repo.Setup(x => x.GetById(11)).ReturnsAsync(new SecurityUserConfiguration
            {
                Id = 11,
                Pagination = 25,
                ModalPagination = 10,
                Language = "es-ES"
            });
            repo.Setup(x => x.GetById(11, It.IsAny<QueryParams>())).ReturnsAsync(new SecurityUserConfiguration
            {
                Id = 11,
                Pagination = 25,
                ModalPagination = 10,
                Language = "es-ES"
            });
            repo.Setup(x => x.GetById(11, It.IsAny<string>())).ReturnsAsync(new SecurityUserConfiguration
            {
                Id = 11,
                Pagination = 25,
                ModalPagination = 10,
                Language = "es-ES"
            });

            var sut = new SecurityUserConfigurationService(appContext.Object, userContext.Object, repo.Object, securityUserService);

            var result = await sut.GetUserConfiguration();

            Assert.NotNull(result);
            Assert.Equal(11, result!.Id);
            Assert.Equal(25, result.Pagination);
        }

        /// <summary>
        /// Verifica que Update combina los valores recibidos con la configuración existente
        /// antes de delegar en la actualización base.
        /// </summary>
        [Fact]
        [Trait("Category", "Critical")]
        public async System.Threading.Tasks.Task Update_MergesViewValues_WithStoredConfiguration()
        {
            var securityUserRepo = new Mock<ISecurityUserRepository>();
            securityUserRepo.Setup(x => x.GetSecurityUserByUserIdentifier(It.IsAny<string?>())).ReturnsAsync((SecurityUser?)null);

            var appContext = BuildApplicationContext();
            var userContext = BuildUserContext("user-update");
            var securityUserService = new SecurityUserService(appContext.Object, userContext.Object, securityUserRepo.Object);

            var repo = new Mock<IBaseRepository<SecurityUserConfiguration>>();
            repo.Setup(x => x.GetById(11, It.IsAny<QueryParams>())).ReturnsAsync(new SecurityUserConfiguration
            {
                Id = 11,
                Pagination = 10,
                ModalPagination = 5,
                Language = "en-US"
            });

            SecurityUserConfiguration? updatedEntity = null;
            repo.Setup(x => x.Update(It.IsAny<SecurityUserConfiguration>(), It.IsAny<SetParamsRepository>()))
                .Callback<SecurityUserConfiguration, SetParamsRepository>((entity, _) => updatedEntity = entity)
                .ReturnsAsync(true);
            repo.Setup(x => x.Update(It.IsAny<SecurityUserConfiguration>(), It.IsAny<string>()))
                .Callback<SecurityUserConfiguration, string>((entity, _) => updatedEntity = entity)
                .ReturnsAsync(true);

            var sut = new SecurityUserConfigurationService(appContext.Object, userContext.Object, repo.Object, securityUserService);
            var viewToUpdate = new SecurityUserConfigurationView
            {
                Id = 11,
                Pagination = 25,
                ModalPagination = 12,
                Language = "es-ES"
            };

            var result = await sut.Update(viewToUpdate, new SetParamsService
            {
                ExecuteValidateView = false,
                ExecutePreviousActions = false,
                ExecuteEndActions = false
            });

            Assert.True(result);
            Assert.NotNull(updatedEntity);
            Assert.Equal(25, updatedEntity!.Pagination);
            Assert.Equal(12, updatedEntity.ModalPagination);
            Assert.Equal("es-ES", updatedEntity.Language);
        }

        /// <summary>
        /// Verifica que Update devuelve false cuando recibe una vista nula.
        /// </summary>
        [Fact]
        [Trait("Category", "Critical")]
        public async System.Threading.Tasks.Task Update_ReturnsFalse_WhenViewIsNull()
        {
            var securityUserRepo = new Mock<ISecurityUserRepository>();
            securityUserRepo.Setup(x => x.GetSecurityUserByUserIdentifier(It.IsAny<string?>())).ReturnsAsync((SecurityUser?)null);

            var appContext = BuildApplicationContext();
            var userContext = BuildUserContext("user-null");
            var securityUserService = new SecurityUserService(appContext.Object, userContext.Object, securityUserRepo.Object);
            var repo = new Mock<IBaseRepository<SecurityUserConfiguration>>();

            var sut = new SecurityUserConfigurationService(appContext.Object, userContext.Object, repo.Object, securityUserService);

            var result = await sut.Update(null!, new SetParamsService());

            Assert.False(result);
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
            var claimsPrincipal = new ClaimsPrincipal(new ClaimsIdentity(new[] { new Claim("sub", userId) }, "TestAuth"));

            var claimsMapping = new Mock<IUserClaimsMapping>();
            claimsMapping.Setup(x => x.GetUserId(It.IsAny<ClaimsPrincipal>())).Returns(userId);
            claimsMapping.Setup(x => x.GetUserName(It.IsAny<ClaimsPrincipal>())).Returns("UserName");
            claimsMapping.Setup(x => x.GetDisplayName(It.IsAny<ClaimsPrincipal>())).Returns("Display Name");
            claimsMapping.Setup(x => x.GetLogin(It.IsAny<ClaimsPrincipal>())).Returns("user.login");
            claimsMapping.Setup(x => x.GetMail(It.IsAny<ClaimsPrincipal>())).Returns("user@test.local");
            claimsMapping.Setup(x => x.GetOrganizationCif(It.IsAny<ClaimsPrincipal>())).Returns("B12345678");
            claimsMapping.Setup(x => x.GetOrganizationCode(It.IsAny<ClaimsPrincipal>())).Returns("0045");
            claimsMapping.Setup(x => x.GetOrganizationName(It.IsAny<ClaimsPrincipal>())).Returns("Company");
            claimsMapping.Setup(x => x.GetSecurityCompanyId(It.IsAny<ClaimsPrincipal>())).Returns(1);
            claimsMapping.Setup(x => x.GetRoles(It.IsAny<ClaimsPrincipal>(), It.IsAny<string>())).Returns(new List<string> { "APP_READ" });
            claimsMapping.Setup(x => x.GetIsAdmin(It.IsAny<ClaimsPrincipal>(), It.IsAny<string>())).Returns(false);
            claimsMapping.Setup(x => x.GetSendClaimsToFront()).Returns(false);

            var appContext = BuildApplicationContext();
            var user = new AuthUser(claimsPrincipal, claimsMapping.Object, appContext.Object);
            var application = new AuthApplication(claimsPrincipal, claimsMapping.Object, appContext.Object);

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
