using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HireMatch.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddApplicationAuditFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "RejectionReason",
                table: "Applications",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "StatusChangedAt",
                table: "Applications",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusChangedById",
                table: "Applications",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Applications_StatusChangedById",
                table: "Applications",
                column: "StatusChangedById");

            migrationBuilder.AddForeignKey(
                name: "FK_Applications_MyAppUsers_StatusChangedById",
                table: "Applications",
                column: "StatusChangedById",
                principalTable: "MyAppUsers",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Applications_MyAppUsers_StatusChangedById",
                table: "Applications");

            migrationBuilder.DropIndex(
                name: "IX_Applications_StatusChangedById",
                table: "Applications");

            migrationBuilder.DropColumn(
                name: "RejectionReason",
                table: "Applications");

            migrationBuilder.DropColumn(
                name: "StatusChangedAt",
                table: "Applications");

            migrationBuilder.DropColumn(
                name: "StatusChangedById",
                table: "Applications");
        }
    }
}
