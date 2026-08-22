using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using HireMatch.Services.Database;

namespace HireMatch.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize(Roles = "Admin")]
    public class AnalyticsController : ControllerBase
    {
        private readonly HireMatchDbContext _context;

        public AnalyticsController(HireMatchDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetStats()
        {
            var now = DateTime.UtcNow;

            var jobsPosted = await _context.JobPosts.CountAsync();
            var candidates = await _context.Candidates.CountAsync();
            var applications = await _context.Applications.CountAsync();
            var totalUsers = await _context.MyAppUsers.CountAsync();

            var sixMonthsAgo = now.AddMonths(-5);
            var startDate = new DateTime(sixMonthsAgo.Year, sixMonthsAgo.Month, 1);

            var monthlyData = await _context.Applications
                .Where(a => a.AppliedAt >= startDate)
                .GroupBy(a => new { a.AppliedAt.Year, a.AppliedAt.Month })
                .Select(g => new
                {
                    g.Key.Year,
                    g.Key.Month,
                    Count = g.Count()
                })
                .ToListAsync();

            var monthLabels = new List<string>();
            var monthlyApplications = new List<int>();
            var monthNames = new[] { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" };

            for (int i = 5; i >= 0; i--)
            {
                var d = now.AddMonths(-i);
                monthLabels.Add(monthNames[d.Month - 1]);
                var count = monthlyData
                    .FirstOrDefault(m => m.Year == d.Year && m.Month == d.Month)?.Count ?? 0;
                monthlyApplications.Add(count);
            }

            return Ok(new
            {
                jobsPosted,
                candidates,
                applications,
                totalUsers,
                monthLabels,
                monthlyApplications
            });
        }
    }
}