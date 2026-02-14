using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;
//using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.DataModel.Base
{

    [Table("AttachmentType", Schema = "Helix6_Attachment")]
    public partial class AttachmentType : IEntityBase
    {
        /// <summary>
        /// ID#Table identifier
        /// </summary>
        [Key]
        public int Id { get; set; }

        [StringLength(2000)]
        //[Unicode(false)]
        public string Description { get; set; }

        /// <summary>
        /// Audit - Creation User#Registry creation user
        /// </summary>
        [StringLength(70)]
        //[Unicode(false)]
        public string AuditCreationUser { get; set; }

        /// <summary>
        /// Audit - Modification User#Registry modification User
        /// </summary>
        [StringLength(70)]
        //[Unicode(false)]
        public string AuditModificationUser { get; set; }

        /// <summary>
        /// Audit - Creation Date#Registry creation date
        /// </summary>
        [Column(TypeName = "datetime")]
        public DateTime? AuditCreationDate { get; set; }

        /// <summary>
        /// Audit - Modification Date#Last registry modification date
        /// </summary>
        [Column(TypeName = "datetime")]
        public DateTime? AuditModificationDate { get; set; }

        /// <summary>
        /// Audit - Deletion Date#Logic registry deletion date
        /// </summary>
        [Column(TypeName = "datetime")]
        public DateTime? AuditDeletionDate { get; set; }

        [InverseProperty("AttachmentType")]
        public virtual ICollection<Attachment> Attachment { get; set; } = new List<Attachment>();
    }
}
