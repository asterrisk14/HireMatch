using System;
using System.Linq;
using System.Threading.Tasks;
using System.IO;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Database;
using HireMatch.Services.Interfaces;

namespace HireMatch.Services.Implementations
{
    public class CandidateEFService : BaseEFCRUDService<CandidateResponse, MyAppUser, CandidateSearchObject, CandidateInsertRequest, CandidateUpdateRequest>, ICandidateService
    {
        public CandidateEFService(HireMatchDbContext dbContext) : base(dbContext) { }

        private IQueryable<MyAppUser> BaseQuery()
        {
            return _dbContext.MyAppUsers
                .Include(x => x.CandidateProfile).ThenInclude(c => c!.City)
                .Include(x => x.CandidateProfile).ThenInclude(c => c!.Country)
                .Include(x => x.CandidateProfile).ThenInclude(c => c!.PreferredIndustry)
                .Include(x => x.CandidateProfile).ThenInclude(c => c!.PreferredEmploymentType)
                .Include(x => x.UserSkills).ThenInclude(us => us.Skill);
        }

        protected override IQueryable<MyAppUser> ApplySearchFilters(IQueryable<MyAppUser> query, CandidateSearchObject search)
        {
            query = BaseQuery().Where(x => x.Role == "Candidate");

            if (search != null)
            {
                if (search.HasApplications == true)
                    query = query.Where(x => _dbContext.Applications.Any(a => a.CandidateId == x.Id));

                if (!string.IsNullOrWhiteSpace(search.FirstName))
                    query = query.Where(x => x.FirstName.Contains(search.FirstName));

                if (!string.IsNullOrWhiteSpace(search.LastName))
                    query = query.Where(x => x.LastName.Contains(search.LastName));

                if (!string.IsNullOrWhiteSpace(search.CurrentTitle))
                    query = query.Where(x => x.CandidateProfile != null &&
                                             x.CandidateProfile.CurrentTitle.Contains(search.CurrentTitle));

                if (!string.IsNullOrWhiteSpace(search.Keyword))
                    query = query.Where(x =>
                        x.FirstName.Contains(search.Keyword) ||
                        x.LastName.Contains(search.Keyword) ||
                        x.Email.Contains(search.Keyword));
            }

            return query.OrderByDescending(x => x.IsPremium).ThenBy(x => x.FirstName);
        }

        protected override CandidateResponse MapToResponse(MyAppUser entity)
        {
            var profile = entity.CandidateProfile;
            return new CandidateResponse
            {
                Id = entity.Id,
                FirstName = entity.FirstName,
                LastName = entity.LastName,
                Email = entity.Email,
                Phone = entity.Phone,
                CountryId = profile?.CountryId,
                CountryName = profile?.Country?.Name ?? string.Empty,
                CityId = profile?.CityId,
                CityName = profile?.City?.Name ?? string.Empty,
                CurrentTitle = profile?.CurrentTitle ?? string.Empty,
                YearsOfExperience = profile?.YearsOfExperience ?? 0,
                Summary = profile?.Summary ?? string.Empty,
                Skills = entity.UserSkills?.Select(us => us.Skill.Name).ToArray() ?? Array.Empty<string>(),
                LinkedInUrl = profile?.LinkedInUrl ?? string.Empty,
                PortfolioUrl = profile?.PortfolioUrl ?? string.Empty,
                CvUrl = profile?.CvUrl ?? string.Empty,
                ProfilePictureUrl = profile?.ProfilePictureUrl ?? string.Empty,
                IsPremium = entity.IsPremium,
                PreferredIndustryId = profile?.PreferredIndustryId,
                PreferredIndustryName = profile?.PreferredIndustry?.Name ?? string.Empty,
                PreferredEmploymentTypeId = profile?.PreferredEmploymentTypeId,
                PreferredEmploymentTypeName = profile?.PreferredEmploymentType?.Name ?? string.Empty,
            };
        }

        public override async Task<CandidateResponse?> GetById(int id)
        {
            var entity = await BaseQuery().FirstOrDefaultAsync(x => x.Id == id);
            return entity != null ? MapToResponse(entity) : null;
        }

        public override async Task<CandidateResponse?> Update(int id, CandidateUpdateRequest request)
        {
            var user = await BaseQuery().FirstOrDefaultAsync(u => u.Id == id);
            if (user == null) return null;

            user.FirstName = request.FirstName;
            user.LastName = request.LastName;
            user.Phone = request.Phone;

            if (user.CandidateProfile == null)
            {
                user.CandidateProfile = new Candidate { MyAppUserId = user.Id };
                _dbContext.Candidates.Add(user.CandidateProfile);
            }

            user.CandidateProfile.CountryId = request.CountryId;
            user.CandidateProfile.CityId = request.CityId;
            user.CandidateProfile.CurrentTitle = request.CurrentTitle;
            user.CandidateProfile.YearsOfExperience = request.YearsOfExperience;
            user.CandidateProfile.Summary = request.Summary;
            user.CandidateProfile.LinkedInUrl = request.LinkedInUrl;
            user.CandidateProfile.PortfolioUrl = request.PortfolioUrl;

            var existingNames = user.UserSkills.Select(us => us.Skill.Name).ToHashSet(StringComparer.OrdinalIgnoreCase);
            var requestedNames = (request.Skills ?? Array.Empty<string>()).ToHashSet(StringComparer.OrdinalIgnoreCase);

            foreach (var us in user.UserSkills.Where(us => !requestedNames.Contains(us.Skill.Name)).ToList())
                _dbContext.UserSkills.Remove(us);

            foreach (var skillName in requestedNames.Except(existingNames))
            {
                var skill = await _dbContext.Skills.FirstOrDefaultAsync(s => s.Name.ToLower() == skillName.ToLower());
                if (skill == null)
                {
                    skill = new Skill { Name = skillName };
                    _dbContext.Skills.Add(skill);
                    await _dbContext.SaveChangesAsync();
                }
                _dbContext.UserSkills.Add(new UserSkill { UserId = user.Id, SkillId = skill.Id });
            }

            await _dbContext.SaveChangesAsync();

            var updated = await BaseQuery().FirstAsync(u => u.Id == id);
            return MapToResponse(updated);
        }

        public async Task<CandidateResponse?> UpdateProfilePicture(int id, IFormFile file)
        {
            var user = await BaseQuery().FirstOrDefaultAsync(u => u.Id == id);
            if (user == null) return null;

            var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "profile-pictures");
            Directory.CreateDirectory(uploadsFolder);
            var fileName = $"{Guid.NewGuid()}_{file.FileName}";
            var filePath = Path.Combine(uploadsFolder, fileName);
            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            if (user.CandidateProfile == null)
            {
                user.CandidateProfile = new Candidate { MyAppUserId = user.Id };
                _dbContext.Candidates.Add(user.CandidateProfile);
            }
            user.CandidateProfile.ProfilePictureUrl = $"/profile-pictures/{fileName}";

            await _dbContext.SaveChangesAsync();
            return MapToResponse(user);
        }

        public async Task<CandidateResponse?> UpdateCv(int id, IFormFile file)
        {
            var user = await BaseQuery().FirstOrDefaultAsync(u => u.Id == id);
            if (user == null) return null;

            var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "cvs");
            Directory.CreateDirectory(uploadsFolder);
            var fileName = $"{Guid.NewGuid()}_{file.FileName}";
            var filePath = Path.Combine(uploadsFolder, fileName);
            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            if (user.CandidateProfile == null)
            {
                user.CandidateProfile = new Candidate { MyAppUserId = user.Id };
                _dbContext.Candidates.Add(user.CandidateProfile);
            }
            user.CandidateProfile.CvUrl = $"/cvs/{fileName}";

            await _dbContext.SaveChangesAsync();
            return MapToResponse(user);
        }

        public override Task<CandidateResponse> Insert(CandidateInsertRequest request)
        {
            throw new BusinessException("Candidates are created through registration, not this endpoint.");
        }

        public async Task<CandidateResponse?> UpdatePreferences(int id, UpdatePreferencesRequest request)
        {
            var user = await BaseQuery().FirstOrDefaultAsync(u => u.Id == id);
            if (user == null) return null;

            if (user.CandidateProfile == null)
            {
                user.CandidateProfile = new Candidate { MyAppUserId = user.Id };
                _dbContext.Candidates.Add(user.CandidateProfile);
            }

            user.CandidateProfile.PreferredIndustryId = request.PreferredIndustryId;
            user.CandidateProfile.PreferredEmploymentTypeId = request.PreferredEmploymentTypeId;

            await _dbContext.SaveChangesAsync();
            return MapToResponse(user);
        }
    }
}
