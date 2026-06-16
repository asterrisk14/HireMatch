using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HireMatch.Services.Migrations
{
    /// <inheritdoc />
    public partial class ExpandCandidateProfile : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "LinkedInUrl",
                table: "Candidates",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "PortfolioUrl",
                table: "Candidates",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Summary",
                table: "Candidates",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "YearsOfExperience",
                table: "Candidates",
                type: "int",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "LinkedInUrl",
                table: "Candidates");

            migrationBuilder.DropColumn(
                name: "PortfolioUrl",
                table: "Candidates");

            migrationBuilder.DropColumn(
                name: "Summary",
                table: "Candidates");

            migrationBuilder.DropColumn(
                name: "YearsOfExperience",
                table: "Candidates");
        }
    }
}
