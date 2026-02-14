using InfoportOneAdmon.Back.Data.Repository.Base.Interfaces;
using InfoportOneAdmon.Back.DataModel.Base;
using Helix6.Base.Application;
using Helix6.Base.Domain.Parameters;
using Helix6.Base.Domain.Security;
using Helix6.Base.Repository;

namespace InfoportOneAdmon.Back.Data.Repository.Base
{
    public class AttachmentRepository : BaseRepository<Attachment>, IAttachmentRepository
    {
        public AttachmentRepository(IApplicationContext applicationContext,
                                IUserContext userContext,
                                IBaseEFRepository<Attachment> baseEFRepository,
                                IBaseDapperRepository<Attachment> baseDapperRepository)
        : base(applicationContext, userContext, baseEFRepository, baseDapperRepository)
        {
        }

        public async Task<List<Attachment>> GetAttachmentsByEntity(int entityId, string entityName, int? attachmentTypeId = null)
        {
            var helixFilter = new HelixFilter
            {
                WhereToSql = $"\"EntityId\" = @EntityId AND \"EntityName\" = @EntityName"
            };
            if (attachmentTypeId.HasValue)
            {
                helixFilter.WhereToSql += " AND \"AttachmentTypeId\" = @AttachmentTypeId";
                helixFilter.WhereToSqlParameters.Add("AttachmentTypeId", attachmentTypeId.Value);
            }
            helixFilter.WhereToSqlParameters.Add("EntityId", entityId);
            helixFilter.WhereToSqlParameters.Add("EntityName", entityName);
            return await DapperRepository.GetAll(new QueryParams(), helixFilter);
        }
    }
}