using Helix6.Base.Domain.BaseInterfaces;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
//using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.DataModel.Base
{

    [Table("SecurityAccessOptionLevel", Schema = "Helix6_Security")]
    //[Index("SecurityAccessOptionId", "Controller", Name = "UK_SecurityAccessOptionLevel", IsUnique = true)]
    public partial class SecurityAccessOptionLevel : IEntityBase
    {
        /// <summary>
        /// ID#Table identifier
        /// </summary>
        [Key]
        public int Id { get; set; }

        public int SecurityAccessOptionId { get; set; }

        [StringLength(200)]
        //[Unicode(false)]
        public string Controller { get; set; }

        public int SecurityLevel { get; set; }

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

        [ForeignKey("SecurityAccessOptionId")]
        [InverseProperty("SecurityAccessOptionLevel")]
        public virtual SecurityAccessOption SecurityAccessOption { get; set; }
    }
}
