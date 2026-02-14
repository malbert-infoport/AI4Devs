using InfoportOneAdmon.Back.Entities.Views.Base;
using Helix6.Base.Attachments;
using Helix6.Base.Domain.Configuration;
using Helix6.Base.Domain.Validations;
using Helix6.Base.Utils.Helpers;

namespace InfoportOneAdmon.Back.Api.Attachments
{
    public class AttachmentDriveSource : IAttachmentSource<AttachmentView>
    {
        private readonly AppSettings config;

        public AttachmentDriveSource(AppSettings config)
        {
            this.config = config;
        }

        public Task DeleteAttachmentContent(AttachmentView attachment)
        {
            var filePath = GetFilePath(attachment);
            if (File.Exists(filePath))
            {
                File.Delete(filePath);
            }
            else
            {
                HelixProblem.ThrowHelixProblemException(System.Net.HttpStatusCode.NotFound, Services.ServiceConsts.Problems.Attachments.ATTACHMENT_FILE_NOT_FOUND);
            }
            return Task.CompletedTask;
        }

        public async Task<AttachmentView?> GetAttachmentContent(AttachmentView attachment)
        {
            var filePath = GetFilePath(attachment);
            if (File.Exists(filePath))
            {
                var bytesFile = await File.ReadAllBytesAsync(filePath);

                attachment.FileContent = SerializationHelper.FromBytesToBase64(bytesFile, attachment.FileExtension);
            }
            else
            {
                HelixProblem.ThrowHelixProblemException(System.Net.HttpStatusCode.NotFound, Services.ServiceConsts.Problems.Attachments.ATTACHMENT_FILE_NOT_FOUND, $"File path: {filePath}");
            }
            return attachment;
        }

        public Task SaveAttachmentContent(AttachmentView attachment)
        {
            if (!string.IsNullOrEmpty(attachment.FileContent))
            {
                var filePath = GetFilePath(attachment);
                if (File.Exists(filePath))
                {
                    File.Delete(filePath);
                }

                if (!Directory.Exists(Path.GetDirectoryName(filePath))) Directory.CreateDirectory(Path.GetDirectoryName(filePath));

                var bytesFile = SerializationHelper.FromBase64ToBytes(attachment.FileContent);
                File.WriteAllBytes(filePath, bytesFile);
            }
            return Task.CompletedTask;
        }

        private string GetFilePath(AttachmentView attachment)
        {
            var fileName = $"{ReplaceInvalidCharsFileName(attachment.FileName)}.{attachment.FileExtension}";
            string folder = config.AttachmentDriveSource.Folder;
            if (string.IsNullOrEmpty(folder)) throw new Exception("Folder property in AttachmentDriveSource settings in AppSettings.json is empty.");
            if (attachment.AttachmentType != null) folder = Path.Combine(folder, ReplaceInvalidCharsFileName(attachment.AttachmentType.Description));
            folder = Path.Combine(folder, ReplaceInvalidCharsFileName(attachment.EntityName));
            if (config.AttachmentDriveSource.UseEntityDescriptionAsDirectory) folder = Path.Combine(folder, ReplaceInvalidCharsFileName($"{attachment.EntityDescription} ({attachment.EntityId})"));

            return Path.Combine(folder, fileName);
        }

        private string ReplaceInvalidCharsFileName(string filename)
        {
            return string.Join("", filename.Split(Path.GetInvalidFileNameChars()));
        }
    }
}