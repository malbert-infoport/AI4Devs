using InfoportOneAdmon.Back.Data.Repository.Base.Interfaces;
using InfoportOneAdmon.Back.DataModel.Base;
using Helix6.Base.Application;
using Helix6.Base.Domain.Parameters;
using Helix6.Base.Domain.Security;
using Helix6.Base.Helpers;
using Helix6.Base.Repository;

namespace InfoportOneAdmon.Back.Data.Repository.Base
{
    public class PermissionsRepository : BaseRepository<Permissions>, IPermissionsRepository
    {
        public PermissionsRepository(IApplicationContext applicationContext,
                                 IUserContext userContext,
                                 IBaseEFRepository<Permissions> baseEFRepository,
                                 IBaseDapperRepository<Permissions> baseDapperRepository)
        : base(applicationContext, userContext, baseEFRepository, baseDapperRepository)
        {
        }

        public async Task<List<Permissions>> GetPermissions()
        {
            if (UserContext.User.IsAdmin)
                return await DapperRepository.GetAll();
            else
            {
                if (UserContext.Applications[0].Roles.Count > 0)
                {
                    HelixFilter helixFilter = new()
                    {
                        WhereToSql = RepositoryHelper.GetWhereForMultipleString("Rol", UserContext.Applications[0].Roles)
                    };
                    return await DapperRepository.GetAll(new QueryParams(), helixFilter);
                }
                return new List<Permissions>();
            }
        }
    }
}