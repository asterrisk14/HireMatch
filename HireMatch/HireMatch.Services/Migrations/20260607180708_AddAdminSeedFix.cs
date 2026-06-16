using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HireMatch.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddAdminSeedFix : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CurrentTitle",
                table: "MyAppUsers");

            migrationBuilder.DropColumn(
                name: "LinkedInUrl",
                table: "MyAppUsers");

            migrationBuilder.DropColumn(
                name: "Location",
                table: "MyAppUsers");

            migrationBuilder.DropColumn(
                name: "PortfolioUrl",
                table: "MyAppUsers");

            migrationBuilder.DropColumn(
                name: "Skills",
                table: "MyAppUsers");

            migrationBuilder.DropColumn(
                name: "Summary",
                table: "MyAppUsers");

            migrationBuilder.DropColumn(
                name: "YearsOfExperience",
                table: "MyAppUsers");

            migrationBuilder.AddColumn<string>(
                name: "CurrentTitle",
                table: "Candidates",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.InsertData(
                table: "MyAppUsers",
                columns: new[] { "Id", "CandidateStatusId", "CityId", "CountryId", "Email", "FirstName", "LastName", "PasswordHash", "Phone", "Role" },
                values: new object[] { 1, null, null, null, "admin@hirematch.com", "Admin", "System", "Admin123!", "000-000-000", "Admin" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "MyAppUsers",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DropColumn(
                name: "CurrentTitle",
                table: "Candidates");

            migrationBuilder.AddColumn<string>(
                name: "CurrentTitle",
                table: "MyAppUsers",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "LinkedInUrl",
                table: "MyAppUsers",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "Location",
                table: "MyAppUsers",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "PortfolioUrl",
                table: "MyAppUsers",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "Skills",
                table: "MyAppUsers",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "Summary",
                table: "MyAppUsers",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<int>(
                name: "YearsOfExperience",
                table: "MyAppUsers",
                type: "int",
                nullable: false,
                defaultValue: 0);
        }
    }
}
