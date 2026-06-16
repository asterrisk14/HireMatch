using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace HireMatch.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddCountriesCitiesAndStatuses : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "CandidateStatuses",
                columns: new[] { "Id", "Name" },
                values: new object[,]
                {
                    { 1, "Open to full-time" },
                    { 2, "Open to part-time" },
                    { 3, "Open to freelance/contract" },
                    { 4, "Open to internship" },
                    { 5, "Not actively looking" }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "CandidateStatuses",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "CandidateStatuses",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "CandidateStatuses",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "CandidateStatuses",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "CandidateStatuses",
                keyColumn: "Id",
                keyValue: 5);
        }
    }
}
