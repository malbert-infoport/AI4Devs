using Helix6.Base.Domain.BaseInterfaces;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
//using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.DataModel.Base
{

    /// <summary>
    /// Empresas Seguridad#En un entorno multiempresa esta tabla contiene la lista de empresas configuradas que podrán trabajar con la aplicación##Seguridad
    /// </summary>
    [Table("SecurityCompanyConfiguration", Schema = "Helix6_Security")]
    public partial class SecurityCompanyConfiguration : IEntityBase
    {
        /// <summary>
        /// ID#Table identifier
        /// </summary>
        [Key]
        public int Id { get; set; }

        [StringLength(50)]
        public string HostEmail { get; set; }

        public int? PortEmail { get; set; }

        [StringLength(50)]
        public string UserEmail { get; set; }

        [StringLength(50)]
        public string PasswordEmail { get; set; }

        public bool? DefaultCredentialsEmail { get; set; }

        public bool? SSLEmail { get; set; }

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

        [InverseProperty("SecurityCompanyConfiguration")]
        public virtual ICollection<SecurityCompany> SecurityCompany { get; set; } = new List<SecurityCompany>();
    }
}
