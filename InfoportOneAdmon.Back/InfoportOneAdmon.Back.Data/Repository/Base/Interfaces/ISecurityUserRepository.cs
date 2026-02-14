using InfoportOneAdmon.Back.DataModel.Base;
using Helix6.Base.Repository;

namespace InfoportOneAdmon.Back.Data.Repository.Base.Interfaces
{
    public interface ISecurityUserRepository : IBaseRepository<SecurityUser>
    {
        Task<SecurityUser?> GetSecurityUserByUserIdentifier(string? configurationName = null);
    }
}