using InfoportOneAdmon.Back.Data.Repository.Base.Interfaces;
using InfoportOneAdmon.Back.DataModel.Base;
using InfoportOneAdmon.Back.Entities.Views.Base;
using InfoportOneAdmon.Back.Entities.Views.Base.Metadata;
using Helix6.Base.Application;
using Helix6.Base.Attachments;
using Helix6.Base.Domain;
using Helix6.Base.Domain.Parameters;
using Helix6.Base.Domain.Security;
using Helix6.Base.Service;

namespace InfoportOneAdmon.Back.Services.Base
{
    public class AttachmentService : BaseService<AttachmentView, Attachment, AttachmentViewMetadata>, IBaseAttachmentService<AttachmentView>
    {
        private readonly IAttachmentRepository _repository;
        private readonly IAttachmentSource<AttachmentView> _attachmentSource;

        public AttachmentService(IApplicationContext applicationContext, IUserContext userContext, IAttachmentRepository repository, IAttachmentSource<AttachmentView> attachmentSource) : base(applicationContext, userContext, repository)
        {
            _repository = repository;
            _attachmentSource = attachmentSource;
        }

        public override async Task PreviousActions(AttachmentView? view, HelixEnums.EnumActionType actionType, string? configurationName = null)
        {
            //Si el adjunto viene con el fichero en Base64 se debe procesar su almacenamiento
            if (view != null)
            {
                if (actionType == HelixEnums.EnumActionType.Insert || actionType == HelixEnums.EnumActionType.Update)
                {
                    if (view.FileContent != null)
                        await _attachmentSource.SaveAttachmentContent(view);
                }
            }
            await base.PreviousActions(view, actionType, configurationName);
        }

        public override async Task EndActions(AttachmentView? view, HelixEnums.EnumActionType actionType, string? configurationName)
        {
            if (view != null)
            {
                if (actionType == HelixEnums.EnumActionType.Delete || actionType == HelixEnums.EnumActionType.LogicDelete)
                    await _attachmentSource.DeleteAttachmentContent(view);
            }
            await base.EndActions(view, actionType, configurationName);
        }

        public async Task<AttachmentView> GetNewAttachmentEntity(int entityId, string entityName, string entityDescription)
        {
            var attachment = await GetNewEntity();
            attachment ??= new AttachmentView();
            attachment.EntityId = entityId;
            attachment.EntityName = entityName;
            attachment.EntityDescription = entityDescription;
            attachment.FileContent = string.Empty;
            attachment.FileExtension = string.Empty;
            attachment.FileName = string.Empty;
            attachment.FileSizeKb = 0;
            attachment.AttachmentDescription = string.Empty;
            return attachment;
        }

        public async Task<List<AttachmentView>> GetAttachmentsByEntity(int entityId, string entityName, int? attachmentTypeId = null)
        {
            var attachments = await _repository.GetAttachmentsByEntity(entityId, entityName, attachmentTypeId);
            return await MapEntitiesToViews(attachments);
        }

        public async Task DeleteAttachmentsByEntity(int entityId, string entityName, int? attachmentTypeId = null)
        {
            var attachments = await _repository.GetAttachmentsByEntity(entityId, entityName, attachmentTypeId);
            if (attachments != null && attachments.Count > 0)
                await DeleteByIds(attachments.Select(a => a.Id).ToList());
        }

        public async Task<AttachmentView?> GetAttachmentContent(int attachmentid)
        {
            var attachment = await GetById(attachmentid, new QueryParams() { ConfigurationName = "Defecto" });
            if (attachment != null)
                return await _attachmentSource.GetAttachmentContent(attachment);
            return null;
        }
    }
}