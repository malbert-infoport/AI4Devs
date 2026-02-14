using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace InfoportOneAdmon.Back.Data.Migrations
{
    /// <inheritdoc />
    public partial class AlignAfterFix_20260214 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditModificationDate",
                schema: "Helix6_Attachment",
                table: "VTA_Attachment",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditDeletionDate",
                schema: "Helix6_Attachment",
                table: "VTA_Attachment",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditCreationDate",
                schema: "Helix6_Attachment",
                table: "VTA_Attachment",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditModificationDate",
                schema: "Helix6_Security",
                table: "SecurityVersion",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditDeletionDate",
                schema: "Helix6_Security",
                table: "SecurityVersion",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditCreationDate",
                schema: "Helix6_Security",
                table: "SecurityVersion",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditModificationDate",
                schema: "Helix6_Security",
                table: "SecurityUserGridConfiguration",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditDeletionDate",
                schema: "Helix6_Security",
                table: "SecurityUserGridConfiguration",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditCreationDate",
                schema: "Helix6_Security",
                table: "SecurityUserGridConfiguration",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "LastConnectionDate",
                schema: "Helix6_Security",
                table: "SecurityUserConfiguration",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditModificationDate",
                schema: "Helix6_Security",
                table: "SecurityUserConfiguration",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditDeletionDate",
                schema: "Helix6_Security",
                table: "SecurityUserConfiguration",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditCreationDate",
                schema: "Helix6_Security",
                table: "SecurityUserConfiguration",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditModificationDate",
                schema: "Helix6_Security",
                table: "SecurityUser",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditDeletionDate",
                schema: "Helix6_Security",
                table: "SecurityUser",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditCreationDate",
                schema: "Helix6_Security",
                table: "SecurityUser",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditModificationDate",
                schema: "Helix6_Security",
                table: "SecurityProfile_SecurityAccessOption",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditDeletionDate",
                schema: "Helix6_Security",
                table: "SecurityProfile_SecurityAccessOption",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditCreationDate",
                schema: "Helix6_Security",
                table: "SecurityProfile_SecurityAccessOption",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditModificationDate",
                schema: "Helix6_Security",
                table: "SecurityProfile",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditDeletionDate",
                schema: "Helix6_Security",
                table: "SecurityProfile",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditCreationDate",
                schema: "Helix6_Security",
                table: "SecurityProfile",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditModificationDate",
                schema: "Helix6_Security",
                table: "SecurityModule",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditDeletionDate",
                schema: "Helix6_Security",
                table: "SecurityModule",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditCreationDate",
                schema: "Helix6_Security",
                table: "SecurityModule",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditModificationDate",
                schema: "Helix6_Security",
                table: "SecurityCompanyGroup",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditDeletionDate",
                schema: "Helix6_Security",
                table: "SecurityCompanyGroup",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditCreationDate",
                schema: "Helix6_Security",
                table: "SecurityCompanyGroup",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditModificationDate",
                schema: "Helix6_Security",
                table: "SecurityCompanyConfiguration",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditDeletionDate",
                schema: "Helix6_Security",
                table: "SecurityCompanyConfiguration",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditCreationDate",
                schema: "Helix6_Security",
                table: "SecurityCompanyConfiguration",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditModificationDate",
                schema: "Helix6_Security",
                table: "SecurityCompany",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditDeletionDate",
                schema: "Helix6_Security",
                table: "SecurityCompany",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditCreationDate",
                schema: "Helix6_Security",
                table: "SecurityCompany",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditModificationDate",
                schema: "Helix6_Security",
                table: "SecurityAccessOptionLevel",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditDeletionDate",
                schema: "Helix6_Security",
                table: "SecurityAccessOptionLevel",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditCreationDate",
                schema: "Helix6_Security",
                table: "SecurityAccessOptionLevel",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditModificationDate",
                schema: "Helix6_Security",
                table: "SecurityAccessOption",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditDeletionDate",
                schema: "Helix6_Security",
                table: "SecurityAccessOption",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditCreationDate",
                schema: "Helix6_Security",
                table: "SecurityAccessOption",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditModificationDate",
                schema: "Helix6_Security",
                table: "Permissions",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditDeletionDate",
                schema: "Helix6_Security",
                table: "Permissions",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditCreationDate",
                schema: "Helix6_Security",
                table: "Permissions",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditModificationDate",
                schema: "Helix6_Attachment",
                table: "AttachmentType",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditDeletionDate",
                schema: "Helix6_Attachment",
                table: "AttachmentType",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditCreationDate",
                schema: "Helix6_Attachment",
                table: "AttachmentType",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditModificationDate",
                schema: "Helix6_Attachment",
                table: "AttachmentFile",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditDeletionDate",
                schema: "Helix6_Attachment",
                table: "AttachmentFile",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditCreationDate",
                schema: "Helix6_Attachment",
                table: "AttachmentFile",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditModificationDate",
                schema: "Helix6_Attachment",
                table: "Attachment",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditDeletionDate",
                schema: "Helix6_Attachment",
                table: "Attachment",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditCreationDate",
                schema: "Helix6_Attachment",
                table: "Attachment",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditModificationDate",
                schema: "Helix6_Attachment",
                table: "VTA_Attachment",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditDeletionDate",
                schema: "Helix6_Attachment",
                table: "VTA_Attachment",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditCreationDate",
                schema: "Helix6_Attachment",
                table: "VTA_Attachment",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditModificationDate",
                schema: "Helix6_Security",
                table: "SecurityVersion",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditDeletionDate",
                schema: "Helix6_Security",
                table: "SecurityVersion",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditCreationDate",
                schema: "Helix6_Security",
                table: "SecurityVersion",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditModificationDate",
                schema: "Helix6_Security",
                table: "SecurityUserGridConfiguration",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditDeletionDate",
                schema: "Helix6_Security",
                table: "SecurityUserGridConfiguration",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditCreationDate",
                schema: "Helix6_Security",
                table: "SecurityUserGridConfiguration",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "LastConnectionDate",
                schema: "Helix6_Security",
                table: "SecurityUserConfiguration",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditModificationDate",
                schema: "Helix6_Security",
                table: "SecurityUserConfiguration",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditDeletionDate",
                schema: "Helix6_Security",
                table: "SecurityUserConfiguration",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditCreationDate",
                schema: "Helix6_Security",
                table: "SecurityUserConfiguration",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditModificationDate",
                schema: "Helix6_Security",
                table: "SecurityUser",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditDeletionDate",
                schema: "Helix6_Security",
                table: "SecurityUser",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditCreationDate",
                schema: "Helix6_Security",
                table: "SecurityUser",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditModificationDate",
                schema: "Helix6_Security",
                table: "SecurityProfile_SecurityAccessOption",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditDeletionDate",
                schema: "Helix6_Security",
                table: "SecurityProfile_SecurityAccessOption",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditCreationDate",
                schema: "Helix6_Security",
                table: "SecurityProfile_SecurityAccessOption",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditModificationDate",
                schema: "Helix6_Security",
                table: "SecurityProfile",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditDeletionDate",
                schema: "Helix6_Security",
                table: "SecurityProfile",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditCreationDate",
                schema: "Helix6_Security",
                table: "SecurityProfile",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditModificationDate",
                schema: "Helix6_Security",
                table: "SecurityModule",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditDeletionDate",
                schema: "Helix6_Security",
                table: "SecurityModule",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditCreationDate",
                schema: "Helix6_Security",
                table: "SecurityModule",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditModificationDate",
                schema: "Helix6_Security",
                table: "SecurityCompanyGroup",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditDeletionDate",
                schema: "Helix6_Security",
                table: "SecurityCompanyGroup",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditCreationDate",
                schema: "Helix6_Security",
                table: "SecurityCompanyGroup",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditModificationDate",
                schema: "Helix6_Security",
                table: "SecurityCompanyConfiguration",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditDeletionDate",
                schema: "Helix6_Security",
                table: "SecurityCompanyConfiguration",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditCreationDate",
                schema: "Helix6_Security",
                table: "SecurityCompanyConfiguration",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditModificationDate",
                schema: "Helix6_Security",
                table: "SecurityCompany",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditDeletionDate",
                schema: "Helix6_Security",
                table: "SecurityCompany",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditCreationDate",
                schema: "Helix6_Security",
                table: "SecurityCompany",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditModificationDate",
                schema: "Helix6_Security",
                table: "SecurityAccessOptionLevel",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditDeletionDate",
                schema: "Helix6_Security",
                table: "SecurityAccessOptionLevel",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditCreationDate",
                schema: "Helix6_Security",
                table: "SecurityAccessOptionLevel",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditModificationDate",
                schema: "Helix6_Security",
                table: "SecurityAccessOption",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditDeletionDate",
                schema: "Helix6_Security",
                table: "SecurityAccessOption",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditCreationDate",
                schema: "Helix6_Security",
                table: "SecurityAccessOption",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditModificationDate",
                schema: "Helix6_Security",
                table: "Permissions",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditDeletionDate",
                schema: "Helix6_Security",
                table: "Permissions",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditCreationDate",
                schema: "Helix6_Security",
                table: "Permissions",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditModificationDate",
                schema: "Helix6_Attachment",
                table: "AttachmentType",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditDeletionDate",
                schema: "Helix6_Attachment",
                table: "AttachmentType",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditCreationDate",
                schema: "Helix6_Attachment",
                table: "AttachmentType",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditModificationDate",
                schema: "Helix6_Attachment",
                table: "AttachmentFile",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditDeletionDate",
                schema: "Helix6_Attachment",
                table: "AttachmentFile",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditCreationDate",
                schema: "Helix6_Attachment",
                table: "AttachmentFile",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditModificationDate",
                schema: "Helix6_Attachment",
                table: "Attachment",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditDeletionDate",
                schema: "Helix6_Attachment",
                table: "Attachment",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "AuditCreationDate",
                schema: "Helix6_Attachment",
                table: "Attachment",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);
        }
    }
}
