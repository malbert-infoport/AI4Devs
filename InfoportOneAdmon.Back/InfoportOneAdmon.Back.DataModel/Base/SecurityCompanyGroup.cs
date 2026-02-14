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
    [Table("SecurityCompanyGroup", Schema = "Helix6_Security")]
    //[Index("Name", Name = "UK_SecurityCompanyGroup")]
    public partial class SecurityCompanyGroup : IEntityBase
    {
        /// <summary>
        /// ID#Table identifier
        /// </summary>
        [Key]
        public int Id { get; set; }

        /// <summary>
        /// Nombre#Nombre de la empresa de seguridad
        /// </summary>
        [StringLength(200)]
        //[Unicode(false)]
        public string Name { get; set; }

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

        [InverseProperty("SecurityCompanyGroup")]
        public virtual ICollection<SecurityCompany> SecurityCompany { get; set; } = new List<SecurityCompany>();
    }
}
