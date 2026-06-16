using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace HireMatch.Services.Migrations
{
    /// <inheritdoc />
    public partial class CompanyJobCityFK_WorkMode : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Location",
                table: "JobPosts");

            migrationBuilder.DropColumn(
                name: "City",
                table: "Companies");

            migrationBuilder.AddColumn<int>(
                name: "CityId",
                table: "JobPosts",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "WorkModeId",
                table: "JobPosts",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "CityId",
                table: "Companies",
                type: "int",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "WorkModes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_WorkModes", x => x.Id);
                });

            migrationBuilder.InsertData(
                table: "WorkModes",
                columns: new[] { "Id", "Name" },
                values: new object[,]
                {
                    { 1, "Remote" },
                    { 2, "Hybrid" },
                    { 3, "On-site" }
                });

            migrationBuilder.CreateIndex(
                name: "IX_JobPosts_CityId",
                table: "JobPosts",
                column: "CityId");

            migrationBuilder.CreateIndex(
                name: "IX_JobPosts_WorkModeId",
                table: "JobPosts",
                column: "WorkModeId");

            migrationBuilder.CreateIndex(
                name: "IX_Companies_CityId",
                table: "Companies",
                column: "CityId");

            migrationBuilder.AddForeignKey(
                name: "FK_Companies_Cities_CityId",
                table: "Companies",
                column: "CityId",
                principalTable: "Cities",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_JobPosts_Cities_CityId",
                table: "JobPosts",
                column: "CityId",
                principalTable: "Cities",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_JobPosts_WorkModes_WorkModeId",
                table: "JobPosts",
                column: "WorkModeId",
                principalTable: "WorkModes",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Companies_Cities_CityId",
                table: "Companies");

            migrationBuilder.DropForeignKey(
                name: "FK_JobPosts_Cities_CityId",
                table: "JobPosts");

            migrationBuilder.DropForeignKey(
                name: "FK_JobPosts_WorkModes_WorkModeId",
                table: "JobPosts");

            migrationBuilder.DropTable(
                name: "WorkModes");

            migrationBuilder.DropIndex(
                name: "IX_JobPosts_CityId",
                table: "JobPosts");

            migrationBuilder.DropIndex(
                name: "IX_JobPosts_WorkModeId",
                table: "JobPosts");

            migrationBuilder.DropIndex(
                name: "IX_Companies_CityId",
                table: "Companies");

            migrationBuilder.DropColumn(
                name: "CityId",
                table: "JobPosts");

            migrationBuilder.DropColumn(
                name: "WorkModeId",
                table: "JobPosts");

            migrationBuilder.DropColumn(
                name: "CityId",
                table: "Companies");

            migrationBuilder.AddColumn<string>(
                name: "Location",
                table: "JobPosts",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "City",
                table: "Companies",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");
        }
    }
}
