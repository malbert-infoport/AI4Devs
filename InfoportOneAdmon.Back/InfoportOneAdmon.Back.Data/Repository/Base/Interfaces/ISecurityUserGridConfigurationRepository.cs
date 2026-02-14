using InfoportOneAdmon.Back.DataModel.Base;
using Helix6.Base.Repository;

namespace InfoportOneAdmon.Back.Data.Repository.Base.Interfaces
{
    public interface ISecurityUserGridConfigurationRepository : IBaseRepository<SecurityUserGridConfiguration>
    {
        Task<List<SecurityUserGridConfiguration>?> GetConfigurations(string entityName, int securityUserid);

        Task<SecurityUserGridConfiguration?> GetDefaultUserGridConfiguration(string entityName, int securityUserId);
    }
}