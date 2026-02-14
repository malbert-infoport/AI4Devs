using Helix6.Base.Domain.BaseInterfaces;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
//using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.DataModel.Base
{

    /// <summary>
    /// Perfiles de Seguridad#Perfiles a los que pertenecen los usuarios del sistema y que condiciona los permisos de los mismos##Seguridad
    /// </summary>
    [Table("SecurityProfile", Schema = "Helix6_Security")]
    //[Index("Description", "SecurityCompanyId", Name = "UK_SecurityProfile", IsUnique = true)]
    public partial class SecurityProfile : IEntityBase
    {
        /// <summary>
        /// ID#Table identifier
        /// </summary>
        [Key]
        public int Id { get; set; }

        /// <summary>
        /// Empresa Seguridad#Empresa del entorno multiempresa de la aplicación a la que pertenece esta entidad.
        /// </summary>
        public int SecurityCompanyId { get; set; }

        /// <summary>
        /// Descripción#Descripción del perfil
        /// </summary>
        [StringLength(200)]
        //[Unicode(false)]
        public string Description { get; set; }

        [StringLength(100)]
        //[Unicode(false)]
        public string Rol { get; set; }

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

        [ForeignKey("SecurityCompanyId")]
        [InverseProperty("SecurityProfile")]
        public virtual SecurityCompany SecurityCompany { get; set; }

        [InverseProperty("SecurityProfile")]
        public virtual ICollection<SecurityProfile_SecurityAccessOption> SecurityProfile_SecurityAccessOption { get; set; } = new List<SecurityProfile_SecurityAccessOption>();
    }
}
