
CREATE VIEW [Helix6_Attachment].[VTA_Attachment]
AS
SELECT        A.Id, A.AttachmentTypeId, A.EntityId, A.EntityName, A.EntityDescription, A.FileName, A.FileExtension, A.FileSizeKb, A.AttachmentDescription, A.AttachmentFileId, A.AuditCreationUser, A.AuditModificationUser, A.AuditCreationDate, 
                         A.AuditModificationDate, A.AuditDeletionDate, AT.Description AS AttachmentType
FROM            Helix6_Attachment.Attachment AS A LEFT JOIN
                         Helix6_Attachment.AttachmentType AS AT ON A.AttachmentTypeId = AT.Id