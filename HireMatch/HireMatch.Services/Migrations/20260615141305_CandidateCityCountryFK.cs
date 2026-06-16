using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HireMatch.Services.Migrations
{
    /// <inheritdoc />
    public partial class CandidateCityCountryFK : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "City",
                table: "Candidates");

            migrationBuilder.AddColumn<int>(
                name: "CityId",
                table: "Candidates",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "CountryId",
                table: "Candidates",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Candidates_CityId",
                table: "Candidates",
                column: "CityId");

            migrationBuilder.CreateIndex(
                name: "IX_Candidates_CountryId",
                table: "Candidates",
                column: "CountryId");

            migrationBuilder.AddForeignKey(
                name: "FK_Candidates_Cities_CityId",
                table: "Candidates",
                column: "CityId",
                principalTable: "Cities",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Candidates_Countries_CountryId",
                table: "Candidates",
                column: "CountryId",
                principalTable: "Countries",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Candidates_Cities_CityId",
                table: "Candidates");

            migrationBuilder.DropForeignKey(
                name: "FK_Candidates_Countries_CountryId",
                table: "Candidates");

            migrationBuilder.DropIndex(
                name: "IX_Candidates_CityId",
                table: "Candidates");

            migrationBuilder.DropIndex(
                name: "IX_Candidates_CountryId",
                table: "Candidates");

            migrationBuilder.DropColumn(
                name: "CityId",
                table: "Candidates");

            migrationBuilder.DropColumn(
                name: "CountryId",
                table: "Candidates");

            migrationBuilder.AddColumn<string>(
                name: "City",
                table: "Candidates",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");
        }
    }
}
