using InfoportOneAdmon.Back.DataModel.Base;
using Helix6.Base.Repository;

namespace InfoportOneAdmon.Back.Data.Repository.Base.Interfaces
{
    public interface IPermissionsRepository : IBaseRepository<Permissions>
    {
        Task<List<Permissions>> GetPermissions();
    }
}