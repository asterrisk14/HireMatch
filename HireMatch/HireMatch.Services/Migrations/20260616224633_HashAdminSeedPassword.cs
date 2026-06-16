using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HireMatch.Services.Migrations
{
    /// <inheritdoc />
    public partial class HashAdminSeedPassword : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "MyAppUsers",
                keyColumn: "Id",
                keyValue: 1,
                column: "PasswordHash",
                value: "$2a$11$JO5M9Y9U1otkWfU2DR92eeNc6eUbdM0nP6YdqfGht90NhNW1mIYxC");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "MyAppUsers",
                keyColumn: "Id",
                keyValue: 1,
                column: "PasswordHash",
                value: "Admin123!");
        }
    }
}
