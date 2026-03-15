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
    public class AttachmentRepositoryTests
    {
        /// <summary>
        /// Verifica que la consulta por entidad genera filtro SQL con EntityId y EntityName,
        /// y devuelve la lista obtenida desde Dapper.
        /// </summary>
        [Fact]
        [Trait("Category", "Critical")]
        public async System.Threading.Tasks.Task GetAttachmentsByEntity_BuildsFilterWithoutAttachmentType_WhenAttachmentTypeIsNull()
        {
            var appContext = BuildApplicationContext();
            var userContext = BuildUserContext();
            var efRepo = new Mock<IBaseEFRepository<Attachment>>();
            var dapperRepo = new Mock<IBaseDapperRepository<Attachment>>();

            HelixFilter? capturedFilter = null;
            dapperRepo
                .Setup(x => x.GetAll(It.IsAny<QueryParams>(), It.IsAny<IGenericFilter>()))
                .Callback<QueryParams, IGenericFilter?>((_, filter) => capturedFilter = filter as HelixFilter)
                .ReturnsAsync(new List<Attachment>
                {
                    new Attachment { Id = 1, EntityId = 99, EntityName = "Organization" }
                });

            var sut = new AttachmentRepository(appContext.Object, userContext.Object, efRepo.Object, dapperRepo.Object);

            var result = await sut.GetAttachmentsByEntity(99, "Organization");

            Assert.Single(result);
            Assert.NotNull(capturedFilter);
            Assert.Contains("\"EntityId\" = @EntityId", capturedFilter!.WhereToSql);
            Assert.Contains("\"EntityName\" = @EntityName", capturedFilter.WhereToSql);
            Assert.DoesNotContain("AttachmentTypeId", capturedFilter.WhereToSql);
            Assert.Equal(99, capturedFilter.WhereToSqlParameters["EntityId"]);
            Assert.Equal("Organization", capturedFilter.WhereToSqlParameters["EntityName"]);
        }

        /// <summary>
        /// Verifica que, cuando viene informado attachmentTypeId, se añade al filtro SQL
        /// y a la colección de parámetros para Dapper.
        /// </summary>
        [Fact]
        [Trait("Category", "Critical")]
        public async System.Threading.Tasks.Task GetAttachmentsByEntity_BuildsFilterWithAttachmentType_WhenAttachmentTypeIsProvided()
        {
            var appContext = BuildApplicationContext();
            var userContext = BuildUserContext();
            var efRepo = new Mock<IBaseEFRepository<Attachment>>();
            var dapperRepo = new Mock<IBaseDapperRepository<Attachment>>();

            HelixFilter? capturedFilter = null;
            dapperRepo
                .Setup(x => x.GetAll(It.IsAny<QueryParams>(), It.IsAny<IGenericFilter>()))
                .Callback<QueryParams, IGenericFilter?>((_, filter) => capturedFilter = filter as HelixFilter)
                .ReturnsAsync(new List<Attachment>
                {
                    new Attachment { Id = 2, EntityId = 99, EntityName = "Organization", AttachmentTypeId = 7 }
                });

            var sut = new AttachmentRepository(appContext.Object, userContext.Object, efRepo.Object, dapperRepo.Object);

            var result = await sut.GetAttachmentsByEntity(99, "Organization", 7);

            Assert.Single(result);
            Assert.NotNull(capturedFilter);
            Assert.Contains("\"AttachmentTypeId\" = @AttachmentTypeId", capturedFilter!.WhereToSql);
            Assert.Equal(7, capturedFilter.WhereToSqlParameters["AttachmentTypeId"]);
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
            var principal = new ClaimsPrincipal(new ClaimsIdentity(new[] { new Claim("sub", "data-user") }, "TestAuth"));

            var claimsMapping = new Mock<IUserClaimsMapping>();
            claimsMapping.Setup(x => x.GetUserId(It.IsAny<ClaimsPrincipal>())).Returns("data-user");
            claimsMapping.Setup(x => x.GetUserName(It.IsAny<ClaimsPrincipal>())).Returns("Data User");
            claimsMapping.Setup(x => x.GetDisplayName(It.IsAny<ClaimsPrincipal>())).Returns("Data User");
            claimsMapping.Setup(x => x.GetLogin(It.IsAny<ClaimsPrincipal>())).Returns("data.user");
            claimsMapping.Setup(x => x.GetMail(It.IsAny<ClaimsPrincipal>())).Returns("data.user@test.local");
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
