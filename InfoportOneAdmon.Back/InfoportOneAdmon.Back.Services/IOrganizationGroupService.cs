namespace InfoportOneAdmon.Back.Services
{
    public interface IOrganizationGroupService
    {
        Task<bool> ExistsActiveById(int? groupId);
    }
}
