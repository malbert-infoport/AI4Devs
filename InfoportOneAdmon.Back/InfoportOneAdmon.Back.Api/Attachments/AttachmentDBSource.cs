using InfoportOneAdmon.Back.Entities.Views.Base;
using InfoportOneAdmon.Back.Services.Base;
using Helix6.Base.Attachments;
using Helix6.Base.Domain.BaseInterfaces;

namespace InfoportOneAdmon.Back.Api.Attachments
{
    public class AttachmentDBSource : IAttachmentSource<AttachmentView>
    {
        private readonly AttachmentFileService _attachmentFileService;
        public AttachmentDBSource(AttachmentFileService attachmentFileService)
        {
            _attachmentFileService = attachmentFileService;
        }

        public async Task<AttachmentView?> GetAttachmentContent(AttachmentView attachment)
        {
            if (attachment.AttachmentFileId.HasValue)
            {
                var attachmentFile = await _attachmentFileService.GetById(attachment.AttachmentFileId.Value);
                if (attachmentFile != null)
                    attachment.FileContent = attachmentFile.FileContent;
            }
            return attachment;
        }

        public async Task SaveAttachmentContent(AttachmentView attachment)
        {
            if (!string.IsNullOrEmpty(attachment.FileContent))
            {
                if (attachment.AttachmentFileId.HasValue && attachment.AttachmentFileId.Value != 0)
                {
                    //Se trata de una actualización del adjunto
                    var attachmentFile = await _attachmentFileService.GetById(attachment.AttachmentFileId.Value);
                    if (attachmentFile != null)
                    {
                        attachmentFile.FileContent = attachment.FileContent;
                        await _attachmentFileService.Update(attachmentFile);
                    }
                }
                else
                {
                    //Se trata de una inserción del adjunto
                    var attachmentFile = await _attachmentFileService.GetNewEntity();
                    if (attachmentFile != null)
                    {
                        attachmentFile.FileContent = attachment.FileContent;
                        attachment.AttachmentFileId = await _attachmentFileService.Insert(attachmentFile);
                    }
                }
            }
        }

        public async Task DeleteAttachmentContent(AttachmentView attachment)
        {
            if (attachment.AttachmentFileId.HasValue && attachment.AttachmentFileId.Value != 0)
            {
                await _attachmentFileService.DeleteById(attachment.AttachmentFileId.Value);
            }
        }
    }
}
