using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HireMatch.Services.Migrations
{
    /// <inheritdoc />
    public partial class CandidatePreferences : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "PreferredEmploymentTypeId",
                table: "Candidates",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "PreferredIndustryId",
                table: "Candidates",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Candidates_PreferredEmploymentTypeId",
                table: "Candidates",
                column: "PreferredEmploymentTypeId");

            migrationBuilder.CreateIndex(
                name: "IX_Candidates_PreferredIndustryId",
                table: "Candidates",
                column: "PreferredIndustryId");

            migrationBuilder.AddForeignKey(
                name: "FK_Candidates_EmploymentTypes_PreferredEmploymentTypeId",
                table: "Candidates",
                column: "PreferredEmploymentTypeId",
                principalTable: "EmploymentTypes",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Candidates_Industries_PreferredIndustryId",
                table: "Candidates",
                column: "PreferredIndustryId",
                principalTable: "Industries",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Candidates_EmploymentTypes_PreferredEmploymentTypeId",
                table: "Candidates");

            migrationBuilder.DropForeignKey(
                name: "FK_Candidates_Industries_PreferredIndustryId",
                table: "Candidates");

            migrationBuilder.DropIndex(
                name: "IX_Candidates_PreferredEmploymentTypeId",
                table: "Candidates");

            migrationBuilder.DropIndex(
                name: "IX_Candidates_PreferredIndustryId",
                table: "Candidates");

            migrationBuilder.DropColumn(
                name: "PreferredEmploymentTypeId",
                table: "Candidates");

            migrationBuilder.DropColumn(
                name: "PreferredIndustryId",
                table: "Candidates");
        }
    }
}
