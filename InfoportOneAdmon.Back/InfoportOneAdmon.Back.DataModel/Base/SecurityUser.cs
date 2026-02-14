using Helix6.Base.Domain.BaseInterfaces;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
//using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.DataModel.Base
{

    /// <summary>
    /// Usuarios#Usuarios pertenecientes a una empresa de seguridad##Seguridad
    /// </summary>
    [Table("SecurityUser", Schema = "Helix6_Security")]
    //[Index("SecurityCompanyId", "UserIdentifier", Name = "UK_SecurityUser", IsUnique = true)]
    public partial class SecurityUser : IEntityBase
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
        /// Identificado de Usuario#Identificador del usuario procedente del gestor de identidades 
        /// </summary>
        [StringLength(200)]
        //[Unicode(false)]
        public string UserIdentifier { get; set; }

        /// <summary>
        /// Login#Login de acceso del usuario
        /// </summary>
        [StringLength(50)]
        //[Unicode(false)]
        public string Login { get; set; }

        /// <summary>
        /// Nombre#Nombre del usuario
        /// </summary>
        [StringLength(200)]
        //[Unicode(false)]
        public string Name { get; set; }

        /// <summary>
        /// Nombre#Nombre del usuario
        /// </summary>
        [StringLength(200)]
        //[Unicode(false)]
        public string DisplayName { get; set; }

        /// <summary>
        /// Mail#Mail del usuario
        /// </summary>
        [StringLength(200)]
        //[Unicode(false)]
        public string Mail { get; set; }

        /// <summary>
        /// Nombre#Nombre del usuario
        /// </summary>
        [StringLength(50)]
        //[Unicode(false)]
        public string OrganizationCif { get; set; }

        /// <summary>
        /// Nombre#Nombre del usuario
        /// </summary>
        [StringLength(50)]
        //[Unicode(false)]
        public string OrganizationCode { get; set; }

        /// <summary>
        /// Nombre#Nombre del usuario
        /// </summary>
        [StringLength(200)]
        //[Unicode(false)]
        public string OrganizationName { get; set; }

        /// <summary>
        /// Configuración Usuario#Configuración específica del usuario logueado para esta aplicación 
        /// </summary>
        public int? SecurityUserConfigurationId { get; set; }

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
        [InverseProperty("SecurityUser")]
        public virtual SecurityCompany SecurityCompany { get; set; }

        [ForeignKey("SecurityUserConfigurationId")]
        [InverseProperty("SecurityUser")]
        public virtual SecurityUserConfiguration SecurityUserConfiguration { get; set; }

        [InverseProperty("SecurityUser")]
        public virtual ICollection<SecurityUserGridConfiguration> SecurityUserGridConfiguration { get; set; } = new List<SecurityUserGridConfiguration>();
    }
}
