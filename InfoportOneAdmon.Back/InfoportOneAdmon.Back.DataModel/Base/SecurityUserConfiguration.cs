using Helix6.Base.Domain.BaseInterfaces;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
//using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.DataModel.Base
{

    /// <summary>
    /// Personalización de Usuario#Parámetros de configuración asociados al usuario que determinan temas como la paginación o el idioma de la aplicación.##Seguridad
    /// </summary>
    [Table("SecurityUserConfiguration", Schema = "Helix6_Security")]
    public partial class SecurityUserConfiguration : IEntityBase
    {
        /// <summary>
        /// ID#Table identifier
        /// </summary>
        [Key]
        public int Id { get; set; }

        /// <summary>
        /// Paginación#Registros por página que se podrán visualizar para este usuario en las ventanas con listas de registros
        /// </summary>
        public int Pagination { get; set; }

        /// <summary>
        /// Paginación Modal#Registros por página que se podrán visualizar para este usuario en las ventanas emergentes con listas de registros
        /// </summary>
        public int ModalPagination { get; set; }

        [StringLength(10)]
        //[Unicode(false)]
        public string Language { get; set; }

        /// <summary>
        /// Audit - Deletion Date#Logic registry deletion date
        /// </summary>
        [Column(TypeName = "datetime")]
        public DateTime? LastConnectionDate { get; set; }

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

        [InverseProperty("SecurityUserConfiguration")]
        public virtual ICollection<SecurityUser> SecurityUser { get; set; } = new List<SecurityUser>();
    }
}
