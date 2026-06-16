using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HireMatch.Services.Migrations
{
    /// <inheritdoc />
    public partial class DodajDatumRodjenja : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateOnly>(
                name: "DateOfBirth",
                table: "MyAppUsers",
                type: "date",
                nullable: false,
                defaultValue: new DateOnly(1, 1, 1));

            migrationBuilder.UpdateData(
                table: "MyAppUsers",
                keyColumn: "Id",
                keyValue: 1,
                column: "DateOfBirth",
                value: new DateOnly(1, 1, 1));
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DateOfBirth",
                table: "MyAppUsers");
        }
    }
}
