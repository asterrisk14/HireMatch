using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HireMatch.Services.Migrations
{
    /// <inheritdoc />
    public partial class FixWebhookEventIdNullable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_PremiumPayments_WebhookEventId",
                table: "PremiumPayments");

            migrationBuilder.CreateIndex(
                name: "IX_PremiumPayments_WebhookEventId",
                table: "PremiumPayments",
                column: "WebhookEventId",
                unique: true,
                filter: "[WebhookEventId] IS NOT NULL AND [WebhookEventId] != ''");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_PremiumPayments_WebhookEventId",
                table: "PremiumPayments");

            migrationBuilder.CreateIndex(
                name: "IX_PremiumPayments_WebhookEventId",
                table: "PremiumPayments",
                column: "WebhookEventId",
                unique: true);
        }
    }
}
