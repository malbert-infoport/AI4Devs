using System.Threading.Tasks;
using Helix6.Base.Application;
using Helix6.Base.Domain.Security;
using Helix6.Base.Repository;
using InfoportOneAdmon.Back.DataModel.Base;
using InfoportOneAdmon.Back.Services.Base;
using Moq;
using Xunit;

namespace InfoportOneAdmon.Back.Services.Tests
{
    public class AttachmentFileServiceTests
    {
        [Fact]
        public void CanConstruct_AttachmentFileService()
        {
            var repo = new Mock<IBaseRepository<AttachmentFile>>();
            var appContext = new Mock<IApplicationContext>();
            var userContext = new Mock<IUserContext>();

            var sut = new AttachmentFileService(appContext.Object, userContext.Object, repo.Object);

            Assert.NotNull(sut);
        }
    }
}
