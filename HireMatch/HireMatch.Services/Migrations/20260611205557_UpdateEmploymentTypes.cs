using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace HireMatch.Services.Migrations
{
    /// <inheritdoc />
    public partial class UpdateEmploymentTypes : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "EmploymentTypes",
                columns: new[] { "Id", "Name" },
                values: new object[,]
                {
                    { 5, "Remote" },
                    { 6, "Hybrid" },
                    { 7, "Contract" }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "EmploymentTypes",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "EmploymentTypes",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "EmploymentTypes",
                keyColumn: "Id",
                keyValue: 7);
        }
    }
}
