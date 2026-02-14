using InfoportOneAdmon.Back.Data.Repository.Base.Interfaces;
using InfoportOneAdmon.Back.DataModel.Base;
using Helix6.Base.Application;
using Helix6.Base.Domain.Parameters;
using Helix6.Base.Domain.Security;
using Helix6.Base.Repository;

namespace InfoportOneAdmon.Back.Data.Repository.Base
{
    public class SecurityUserGridConfigurationRepository : BaseRepository<SecurityUserGridConfiguration>, ISecurityUserGridConfigurationRepository
    {
        public SecurityUserGridConfigurationRepository(IApplicationContext applicationContext,
                                 IUserContext userContext,
                                 IBaseEFRepository<SecurityUserGridConfiguration> baseEFRepository,
                                 IBaseDapperRepository<SecurityUserGridConfiguration> baseDapperRepository)
        : base(applicationContext, userContext, baseEFRepository, baseDapperRepository)
        {
        }

        public async Task<List<SecurityUserGridConfiguration>?> GetConfigurations(string entityName, int securityUserid)
        {
            HelixFilter helixFilter = new()
            {
                WhereToSql = $"\"Entity\" = '{entityName}' AND \"SecurityUserId\" = {securityUserid}"
            };
            return await DapperRepository.GetAll(new QueryParams(), helixFilter);
        }

        public async Task<SecurityUserGridConfiguration?> GetDefaultUserGridConfiguration(string entityName, int securityUserId)
        {
            HelixFilter helixFilter = new()
            {
                WhereToSql = $"\"Entity\" = '{entityName}' AND \"SecurityUserId\" = {securityUserId} AND \"DefaultConfiguration\" = 1"
            };
            var result = await DapperRepository.GetAll(new QueryParams(), helixFilter);
            return result.FirstOrDefault();
        }
    }
}