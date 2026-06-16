using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace HireMatch.Services.Migrations
{
    /// <inheritdoc />
    public partial class UpdateIndustrySeed : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Industries",
                keyColumn: "Id",
                keyValue: 1,
                column: "Name",
                value: "IT");

            migrationBuilder.UpdateData(
                table: "Industries",
                keyColumn: "Id",
                keyValue: 2,
                column: "Name",
                value: "Marketing");

            migrationBuilder.UpdateData(
                table: "Industries",
                keyColumn: "Id",
                keyValue: 3,
                column: "Name",
                value: "Finance");

            migrationBuilder.UpdateData(
                table: "Industries",
                keyColumn: "Id",
                keyValue: 4,
                column: "Name",
                value: "Healthcare");

            migrationBuilder.InsertData(
                table: "Industries",
                columns: new[] { "Id", "Name" },
                values: new object[,]
                {
                    { 5, "Engineering" },
                    { 6, "Beauty & Fashion" },
                    { 7, "Human Resources" },
                    { 8, "Education" },
                    { 9, "Gaming" },
                    { 10, "Legal" }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Industries",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Industries",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Industries",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Industries",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Industries",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Industries",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.UpdateData(
                table: "Industries",
                keyColumn: "Id",
                keyValue: 1,
                column: "Name",
                value: "Software Development / IT");

            migrationBuilder.UpdateData(
                table: "Industries",
                keyColumn: "Id",
                keyValue: 2,
                column: "Name",
                value: "Banking & Finance");

            migrationBuilder.UpdateData(
                table: "Industries",
                keyColumn: "Id",
                keyValue: 3,
                column: "Name",
                value: "Marketing & E-commerce");

            migrationBuilder.UpdateData(
                table: "Industries",
                keyColumn: "Id",
                keyValue: 4,
                column: "Name",
                value: "Human Resources");
        }
    }
}
