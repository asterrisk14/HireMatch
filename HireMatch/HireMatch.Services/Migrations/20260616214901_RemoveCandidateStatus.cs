using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace HireMatch.Services.Migrations
{
    /// <inheritdoc />
    public partial class RemoveCandidateStatus : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_MyAppUsers_CandidateStatuses_CandidateStatusId",
                table: "MyAppUsers");

            migrationBuilder.DropTable(
                name: "CandidateStatuses");

            migrationBuilder.DropIndex(
                name: "IX_MyAppUsers_CandidateStatusId",
                table: "MyAppUsers");

            migrationBuilder.DropColumn(
                name: "CandidateStatusId",
                table: "MyAppUsers");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "CandidateStatusId",
                table: "MyAppUsers",
                type: "int",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "CandidateStatuses",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CandidateStatuses", x => x.Id);
                });

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

            migrationBuilder.UpdateData(
                table: "MyAppUsers",
                keyColumn: "Id",
                keyValue: 1,
                column: "CandidateStatusId",
                value: null);

            migrationBuilder.CreateIndex(
                name: "IX_MyAppUsers_CandidateStatusId",
                table: "MyAppUsers",
                column: "CandidateStatusId");

            migrationBuilder.AddForeignKey(
                name: "FK_MyAppUsers_CandidateStatuses_CandidateStatusId",
                table: "MyAppUsers",
                column: "CandidateStatusId",
                principalTable: "CandidateStatuses",
                principalColumn: "Id");
        }
    }
}
