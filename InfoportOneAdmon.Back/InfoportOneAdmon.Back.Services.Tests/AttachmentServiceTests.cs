using System.Collections.Generic;
using System.Threading.Tasks;
using Helix6.Base.Application;
using Helix6.Base.Domain;
using Helix6.Base.Domain.Parameters;
using Helix6.Base.Domain.Security;
using Helix6.Base.Repository;
using Helix6.Base.Attachments;
using InfoportOneAdmon.Back.Data.Repository.Base.Interfaces;
using InfoportOneAdmon.Back.DataModel.Base;
using InfoportOneAdmon.Back.Entities.Views.Base;
using InfoportOneAdmon.Back.Services.Base;
using Moq;
using Xunit;

namespace InfoportOneAdmon.Back.Services.Tests
{
    public class AttachmentServiceTests
    {
        [Fact]
        public async Task PreviousActions_WithFileContent_CallsSaveAttachmentContent()
        {
            var repo = new Mock<IAttachmentRepository>();
            var source = new Mock<IAttachmentSource<AttachmentView>>();

            var appContext = new Mock<IApplicationContext>();
            var userContext = new Mock<IUserContext>();

            var sut = new AttachmentService(appContext.Object, userContext.Object, repo.Object, source.Object);

            var view = new AttachmentView { FileContent = "data", FileName = "f.txt" };

            await sut.PreviousActions(view, HelixEnums.EnumActionType.Insert);

            source.Verify(x => x.SaveAttachmentContent(It.Is<AttachmentView>(v => v == view)), Times.Once);
        }

        [Fact]
        public async Task EndActions_OnDelete_CallsDeleteAttachmentContent()
        {
            var repo = new Mock<IAttachmentRepository>();
            var source = new Mock<IAttachmentSource<AttachmentView>>();

            var appContext = new Mock<IApplicationContext>();
            var userContext = new Mock<IUserContext>();

            var sut = new AttachmentService(appContext.Object, userContext.Object, repo.Object, source.Object);

            var view = new AttachmentView { Id = 5 };

            await sut.EndActions(view, HelixEnums.EnumActionType.Delete, null);

            source.Verify(x => x.DeleteAttachmentContent(It.Is<AttachmentView>(v => v == view)), Times.Once);
        }

        [Fact]
        public async Task GetNewAttachmentEntity_InitializesDefaults()
        {
            var repo = new Mock<IAttachmentRepository>();
            var source = new Mock<IAttachmentSource<AttachmentView>>();

            var appContext = new Mock<IApplicationContext>();
            var userContext = new Mock<IUserContext>();

            var sut = new AttachmentService(appContext.Object, userContext.Object, repo.Object, source.Object);

            var result = await sut.GetNewAttachmentEntity(10, "Entity", "Desc");

            Assert.NotNull(result);
            Assert.Equal(10, result.EntityId);
            Assert.Equal("Entity", result.EntityName);
            Assert.Equal("Desc", result.EntityDescription);
            Assert.Equal(string.Empty, result.FileContent);
            Assert.Equal(string.Empty, result.FileName);
        }
    }
}
