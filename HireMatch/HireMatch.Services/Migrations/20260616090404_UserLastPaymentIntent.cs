using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HireMatch.Services.Migrations
{
    /// <inheritdoc />
    public partial class UserLastPaymentIntent : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "LastPaymentIntentId",
                table: "MyAppUsers",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "MyAppUsers",
                keyColumn: "Id",
                keyValue: 1,
                column: "LastPaymentIntentId",
                value: null);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "LastPaymentIntentId",
                table: "MyAppUsers");
        }
    }
}
