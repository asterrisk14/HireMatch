using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HireMatch.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddIndustryToJobPost : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "IndustryId",
                table: "JobPosts",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_JobPosts_IndustryId",
                table: "JobPosts",
                column: "IndustryId");

            migrationBuilder.AddForeignKey(
                name: "FK_JobPosts_Industries_IndustryId",
                table: "JobPosts",
                column: "IndustryId",
                principalTable: "Industries",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_JobPosts_Industries_IndustryId",
                table: "JobPosts");

            migrationBuilder.DropIndex(
                name: "IX_JobPosts_IndustryId",
                table: "JobPosts");

            migrationBuilder.DropColumn(
                name: "IndustryId",
                table: "JobPosts");
        }
    }
}
