using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;
//using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.DataModel.Base
{

    //[Keyless]
    [Table("VTA_Attachment", Schema = "Helix6_Attachment")]
    public partial class VTA_Attachment : IEntityBase
    {
        public int Id { get; set; }

        public int AttachmentTypeId { get; set; }

        public int EntityId { get; set; }

        [StringLength(1000)]
        //[Unicode(false)]
        public string EntityName { get; set; }

        [StringLength(2000)]
        //[Unicode(false)]
        public string EntityDescription { get; set; }

        [StringLength(1000)]
        //[Unicode(false)]
        public string FileName { get; set; }

        [StringLength(10)]
        //[Unicode(false)]
        public string FileExtension { get; set; }

        public int? FileSizeKb { get; set; }

        [StringLength(2000)]
        //[Unicode(false)]
        public string AttachmentDescription { get; set; }

        public int? AttachmentFileId { get; set; }

        [StringLength(70)]
        //[Unicode(false)]
        public string AuditCreationUser { get; set; }

        [StringLength(70)]
        //[Unicode(false)]
        public string AuditModificationUser { get; set; }

        [Column(TypeName = "datetime")]
        public DateTime? AuditCreationDate { get; set; }

        [Column(TypeName = "datetime")]
        public DateTime? AuditModificationDate { get; set; }

        [Column(TypeName = "datetime")]
        public DateTime? AuditDeletionDate { get; set; }

        [StringLength(2000)]
        //[Unicode(false)]
        public string AttachmentType { get; set; }
    }
}
