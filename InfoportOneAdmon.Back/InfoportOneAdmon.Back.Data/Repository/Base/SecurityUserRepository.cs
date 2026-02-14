using InfoportOneAdmon.Back.Data.Repository.Base.Interfaces;
using InfoportOneAdmon.Back.DataModel.Base;
using Helix6.Base.Application;
using Helix6.Base.Domain.Security;
using Helix6.Base.Repository;

namespace InfoportOneAdmon.Back.Data.Repository.Base
{
    public class SecurityUserRepository : BaseRepository<SecurityUser>, ISecurityUserRepository
    {
        private readonly IUserContext _userContext;

        public SecurityUserRepository(IApplicationContext applicationContext,
                                 IUserContext userContext,
                                 IBaseEFRepository<SecurityUser> baseEFRepository,
                                 IBaseDapperRepository<SecurityUser> baseDapperRepository)
        : base(applicationContext, userContext, baseEFRepository, baseDapperRepository)
        {
            _userContext = userContext;
        }

        public async Task<SecurityUser?> GetSecurityUserByUserIdentifier(string? configurationName = null)
        {
            var query = EFRepository.GetAllAsQueryable().Where(u => u.UserIdentifier == _userContext.User.Id);
            return await EFRepository.LoadEntityWithChilds(query, configurationName);
        }
    }
}