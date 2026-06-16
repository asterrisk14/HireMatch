using System;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using HireMatch.Model.Requests;
using HireMatch.Services.Database;
using HireMatch.Services.Interfaces; // <-- DODANO

namespace HireMatch.Services.Implementations
{
    public class UserSkillEFService : IUserSkillService
    {
        private readonly HireMatchDbContext _context;

        public UserSkillEFService(HireMatchDbContext context)
        {
            _context = context;
        }

        public async Task<bool> AddSkillToUserAsync(UserSkillInsertRequest request)
        {
            if (request == null || string.IsNullOrWhiteSpace(request.SkillName))
                return false;

            var trimmedSkillName = request.SkillName.Trim();

            var skill = await _context.Skills
                .FirstOrDefaultAsync(s => s.Name.ToLower() == trimmedSkillName.ToLower());

            if (skill == null)
            {
                skill = new Skill { Name = trimmedSkillName };
                _context.Skills.Add(skill);
                await _context.SaveChangesAsync();
            }

            var alreadyHasSkill = await _context.UserSkills
                .AnyAsync(us => us.UserId == request.UserId && us.SkillId == skill.Id);

            if (alreadyHasSkill)
                return true;

            var userSkill = new UserSkill
            {
                UserId = request.UserId,
                SkillId = skill.Id
            };

            _context.UserSkills.Add(userSkill);
            await _context.SaveChangesAsync();

            return true;
        }
    }
}