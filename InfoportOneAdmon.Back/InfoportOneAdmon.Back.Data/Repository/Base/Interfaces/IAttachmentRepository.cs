using InfoportOneAdmon.Back.DataModel.Base;
using Helix6.Base.Repository;

namespace InfoportOneAdmon.Back.Data.Repository.Base.Interfaces
{
    public interface IAttachmentRepository : IBaseRepository<Attachment>
    {
        Task<List<Attachment>> GetAttachmentsByEntity(int entityId, string entityName, int? attachmentTypeId = null);
    }
}