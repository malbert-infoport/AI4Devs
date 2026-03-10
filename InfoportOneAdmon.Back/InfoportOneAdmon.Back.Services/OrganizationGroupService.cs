using Helix6.Base.Application;
using Helix6.Base.Domain.Parameters;
using Helix6.Base.Domain.Security;
using Helix6.Base.Repository;
using Helix6.Base.Service;
using InfoportOneAdmon.Back.DataModel;
using InfoportOneAdmon.Back.Entities.Views;
using InfoportOneAdmon.Back.Entities.Views.Metadata;

namespace InfoportOneAdmon.Back.Services
{
    public class OrganizationGroupService : BaseService<OrganizationGroupView, OrganizationGroup, OrganizationGroupViewMetadata>, IOrganizationGroupService
    {
        public OrganizationGroupService(
            IApplicationContext applicationContext,
            IUserContext userContext,
            IBaseRepository<OrganizationGroup> repository)
            : base(applicationContext, userContext, repository)
        {
        }

        public async Task<bool> ExistsActiveById(int? groupId)
        {
            if (!groupId.HasValue)
                return true;

            var entity = await Repository.GetById(groupId.Value, new QueryParams(null, true));
            return entity != null && entity.AuditDeletionDate == null;
        }
    }
}
