using Helix6.Base.Domain.BaseInterfaces;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
//using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.DataModel.Base
{

    /// <summary>
    /// Opciones de Acceso#Opciones de acceso que determinan todos los puntos controlados por la seguridad del sistema, sobre los cuales se pueden dotar permisos de acceso##Seguridad
    /// </summary>
    [Table("SecurityAccessOption", Schema = "Helix6_Security")]
    //[Index("Description", "SecurityModuleId", Name = "UK_SecurityAccessOption", IsUnique = true)]
    public partial class SecurityAccessOption : IEntityBase
    {
        /// <summary>
        /// ID#Table identifier
        /// </summary>
        [Key]
        public int Id { get; set; }

        /// <summary>
        /// Módulo#Módulo al que pertenece la opción de acceso
        /// </summary>
        public int SecurityModuleId { get; set; }

        /// <summary>
        /// Descripción#Descripcíon de la opción de acceso
        /// </summary>
        [StringLength(200)]
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

        [InverseProperty("SecurityAccessOption")]
        public virtual ICollection<SecurityAccessOptionLevel> SecurityAccessOptionLevel { get; set; } = new List<SecurityAccessOptionLevel>();

        [ForeignKey("SecurityModuleId")]
        [InverseProperty("SecurityAccessOption")]
        public virtual SecurityModule SecurityModule { get; set; }

        [InverseProperty("SecurityAccessOption")]
        public virtual ICollection<SecurityProfile_SecurityAccessOption> SecurityProfile_SecurityAccessOption { get; set; } = new List<SecurityProfile_SecurityAccessOption>();
    }
}
