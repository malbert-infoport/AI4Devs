using Helix6.Base.Application;
using Helix6.Base.Domain.Parameters;
using Helix6.Base.Domain.Security;
using Helix6.Base.Repository;
using InfoportOneAdmon.Back.Data.Repository.Interfaces;
using InfoportOneAdmon.Back.DataModel;
using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.Data.Repository
{
    public class OrganizationRepository : BaseRepository<Organization>, IOrganizationRepository
    {
        public OrganizationRepository(
            IApplicationContext applicationContext,
            IUserContext userContext,
            IBaseEFRepository<Organization> baseEFRepository,
            IBaseDapperRepository<Organization> baseDapperRepository)
            : base(applicationContext, userContext, baseEFRepository, baseDapperRepository)
        {
        }

        public async Task<bool> ExistsActiveByName(string name, int excludedId = 0)
        {
            if (string.IsNullOrWhiteSpace(name))
                return false;

            var query = EFRepository.GetAllAsQueryable(new QueryParams(null, true));
            return await query.AnyAsync(o =>
                o.AuditDeletionDate == null &&
                o.Id != excludedId &&
                o.Name == name);
        }

        public async Task<bool> ExistsActiveByTaxId(string taxId, int excludedId = 0)
        {
            if (string.IsNullOrWhiteSpace(taxId))
                return false;

            var query = EFRepository.GetAllAsQueryable(new QueryParams(null, true));
            return await query.AnyAsync(o =>
                o.AuditDeletionDate == null &&
                o.Id != excludedId &&
                o.TaxId == taxId);
        }
    }
}
