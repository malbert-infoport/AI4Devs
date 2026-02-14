using Helix6.Base.Domain.BaseInterfaces;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
//using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.DataModel.Base
{

    [Table("SecurityVersion", Schema = "Helix6_Security")]
    public partial class SecurityVersion : IEntityBase
    {
        /// <summary>
        /// ID#Table identifier
        /// </summary>
        [Key]
        public int Id { get; set; }

        [StringLength(20)]
        public string Version { get; set; }

        [Column(TypeName = "text")]
        public string Observations { get; set; }

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
    }
}
