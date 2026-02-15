using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace InfoportOneAdmon.Back.Data.Migrations
{
    /// <inheritdoc />
    public partial class Migration_01020001_StructureHelix : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            var assembly = typeof(InfoportOneAdmon.Back.Data.DataModel.EntityModel).Assembly;
            using var stream = assembly.GetManifestResourceStream("InfoportOneAdmon.Back.Data.Scripts.01020001_StructureHelix.sql");
            using var reader = new System.IO.StreamReader(stream!);
            var sql = reader.ReadToEnd();
            migrationBuilder.Sql(sql, suppressTransaction: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
        }
    }
}
