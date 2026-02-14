using InfoportOneAdmon.Back.DataModel.Base;
using InfoportOneAdmon.Back.Entities.Views.Base;
using InfoportOneAdmon.Back.Entities.Views.Base.Metadata;
using Helix6.Base.Application;
using Helix6.Base.Domain.Security;
using Helix6.Base.Repository;
using Helix6.Base.Service;

namespace InfoportOneAdmon.Back.Services.Base
{
    public class AttachmentFileService : BaseService<AttachmentFileView, AttachmentFile, AttachmentFileViewMetadata>
    {

        public AttachmentFileService(IApplicationContext applicationContext, IUserContext userContext, IBaseRepository<AttachmentFile> repository) : base(applicationContext, userContext, repository)
        {
        }
    }
}
