using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace HireMatch.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddCareerTips : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "CareerTips",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Title = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Content = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Icon = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CareerTips", x => x.Id);
                });

            migrationBuilder.InsertData(
                table: "CareerTips",
                columns: new[] { "Id", "Content", "CreatedAt", "Icon", "Title" },
                values: new object[,]
                {
                    { 1, "Keep it concise, use action verbs, and tailor it to each job. Highlight measurable achievements rather than just listing duties.", new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "✨", "How to make your CV stand out" },
                    { 2, "Communication, teamwork and problem-solving consistently rank highest. Show examples of these in your interviews.", new DateTime(2025, 1, 2, 0, 0, 0, 0, DateTimeKind.Unspecified), "💬", "Top 3 soft skills recruiters love" },
                    { 3, "Apply for internships, contribute to open-source projects, or take on freelance work to build your portfolio.", new DateTime(2025, 1, 3, 0, 0, 0, 0, DateTimeKind.Unspecified), "🚀", "Don't have experience? Here's what to do" }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "CareerTips");
        }
    }
}
