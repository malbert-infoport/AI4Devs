using Helix6.Base.Application;
using Helix6.Base.Domain.Security;
using Helix6.Base.Repository;
using InfoportOneAdmon.Back.Data.Repository.Base.Interfaces;
using InfoportOneAdmon.Back.DataModel.Base;

namespace InfoportOneAdmon.Back.Data.Repository.Base;
public class SecurityCompanyRepository
        : BaseRepository<SecurityCompany>,
            ISecurityCompanyRepository
{
    private readonly IUserContext _userContext;

    public SecurityCompanyRepository(
        IApplicationContext applicationContext,
        IUserContext userContext,
        IBaseEFRepository<SecurityCompany> efRepository,
        IBaseDapperRepository<SecurityCompany> dapperRepository
    )
        : base(applicationContext, userContext, efRepository, dapperRepository)
    {
        _userContext = userContext;
    }
}
