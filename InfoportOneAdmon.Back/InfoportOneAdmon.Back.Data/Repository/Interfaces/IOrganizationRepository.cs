using Helix6.Base.Repository;
using InfoportOneAdmon.Back.DataModel;

namespace InfoportOneAdmon.Back.Data.Repository.Interfaces
{
    public interface IOrganizationRepository : IBaseRepository<Organization>
    {
        Task<bool> ExistsActiveByName(string name, int excludedId = 0);
        Task<bool> ExistsActiveByTaxId(string taxId, int excludedId = 0);
    }
}
