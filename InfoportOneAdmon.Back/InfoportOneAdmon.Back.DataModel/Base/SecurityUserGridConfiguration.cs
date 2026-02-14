using Helix6.Base.Domain.BaseInterfaces;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
//using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.DataModel.Base
{

    [Table("SecurityUserGridConfiguration", Schema = "Helix6_Security")]
    //[Index("SecurityUserId", "Entity", "Description", Name = "UK_SecurityUserGridConfiguration", IsUnique = true)]
    public partial class SecurityUserGridConfiguration : IEntityBase
    {
        /// <summary>
        /// ID#Table identifier
        /// </summary>
        [Key]
        public int Id { get; set; }

        public int SecurityUserId { get; set; }

        [StringLength(100)]
        //[Unicode(false)]
        public string Entity { get; set; }

        [StringLength(100)]
        //[Unicode(false)]
        public string Description { get; set; }

        public bool DefaultConfiguration { get; set; }

        //[Unicode(false)]
        public string Configuration { get; set; }

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

        [ForeignKey("SecurityUserId")]
        [InverseProperty("SecurityUserGridConfiguration")]
        public virtual SecurityUser SecurityUser { get; set; }
    }
}
