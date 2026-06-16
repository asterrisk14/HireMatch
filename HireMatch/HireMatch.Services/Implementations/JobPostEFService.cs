using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Database;
using HireMatch.Services.Interfaces;
using Mapster;
using HireMatch.Services.Implementations;
using Microsoft.EntityFrameworkCore;

namespace HireMatch.Services.Implementations
{
    public class JobPostEFService : BaseEFCRUDService<JobPostResponse, JobPost, JobPostSearchObject, JobPostInsertRequest, JobPostUpdateRequest>, IJobPostService
    {
        public JobPostEFService(HireMatchDbContext context) : base(context) { }

        protected override IQueryable<JobPost> ApplySearchFilters(IQueryable<JobPost> query, JobPostSearchObject search)
        {
            query = query
                .Include(x => x.Company)
                .Include(x => x.EmploymentType)
                .Include(x => x.Industry)
                .Include(x => x.City)
                .Include(x => x.WorkMode)
                .Include(x => x.Applications);

            if (search != null)
            {
                if (search.CompanyId.HasValue)
                    query = query.Where(x => x.CompanyId == search.CompanyId.Value);

                if (search.RecruiterId.HasValue)
                    query = query.Where(x => x.RecruiterId == search.RecruiterId.Value);

                if (search.EmploymentTypeId.HasValue)
                    query = query.Where(x => x.EmploymentTypeId == search.EmploymentTypeId.Value);

                if (!string.IsNullOrWhiteSpace(search.Title))
                    query = query.Where(x => x.Title.ToLower().Contains(search.Title.ToLower()));

                // Location filter sada po imenu grada
                if (!string.IsNullOrWhiteSpace(search.Location))
                {
                    var location = search.Location.ToLower();
                    query = query.Where(x => x.City != null && x.City.Name.ToLower().Contains(location));
                }

                if (search.ExpiryDateFrom.HasValue)
                    query = query.Where(x => x.ExpiryDate >= search.ExpiryDateFrom.Value);

                if (search.ExpiryDateTo.HasValue)
                    query = query.Where(x => x.ExpiryDate <= search.ExpiryDateTo.Value);

                if (search.IsActive.HasValue)
                {
                    var now = DateTime.UtcNow;
                    if (search.IsActive.Value)
                        query = query.Where(x => x.ExpiryDate > now);
                    else
                        query = query.Where(x => x.ExpiryDate <= now);
                }

                if (!string.IsNullOrWhiteSpace(search.Keyword))
                {
                    var keyword = search.Keyword.ToLower();
                    query = query.Where(x =>
                        x.Title.ToLower().Contains(keyword) ||
                        x.Description.ToLower().Contains(keyword) ||
                        x.Company.Name.ToLower().Contains(keyword));
                }
            }

            return query.OrderByDescending(x => x.Id);
        }

        protected override JobPostResponse MapToResponse(JobPost entity)
        {
            return new JobPostResponse
            {
                Id = entity.Id,
                CompanyId = entity.CompanyId,
                CompanyName = entity.Company?.Name ?? string.Empty,
                CompanyLogoUrl = entity.Company?.LogoUrl ?? string.Empty,
                RecruiterId = entity.RecruiterId,
                Title = entity.Title,
                Description = entity.Description,
                Compensation = entity.Compensation,
                EmploymentTypeId = entity.EmploymentTypeId,
                EmploymentTypeName = entity.EmploymentType?.Name ?? string.Empty,
                IsPaid = entity.IsPaid,
                // Location se puni iz grada (+ work mode ako postoji), Flutter kompatibilnost
                Location = entity.City?.Name ?? string.Empty,
                CityId = entity.CityId,
                CityName = entity.City?.Name ?? string.Empty,
                WorkModeId = entity.WorkModeId,
                WorkModeName = entity.WorkMode?.Name ?? string.Empty,
                IndustryId = entity.IndustryId,
                IndustryName = entity.Industry?.Name ?? string.Empty,
                ExpiryDate = entity.ExpiryDate,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt,
                ApplicationCount = entity.Applications?.Count ?? 0
            };
        }


        public override async Task<JobPostResponse> Insert(JobPostInsertRequest request)
        {
            var entity = new JobPost
            {
                CompanyId = request.CompanyId,
                RecruiterId = request.RecruiterId,
                Title = request.Title,
                Description = request.Description,
                CityId = request.CityId,
                WorkModeId = request.WorkModeId,
                Compensation = request.Compensation,
                EmploymentTypeId = request.EmploymentTypeId,
                IndustryId = request.IndustryId,
                ExpiryDate = request.ExpiryDate,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
            };

            foreach (var skillId in request.SkillIds.Distinct())
                entity.JobPostSkills.Add(new JobPostSkill { SkillId = skillId });

            _dbSet.Add(entity);
            await _dbContext.SaveChangesAsync();

            var loaded = await _dbContext.JobPosts
                .Include(j => j.Company).Include(j => j.EmploymentType)
                .Include(j => j.Industry).Include(j => j.City).Include(j => j.WorkMode)
                .Include(j => j.Applications)
                .FirstAsync(j => j.Id == entity.Id);

            return MapToResponse(loaded);
        }

        public override async Task<JobPostResponse?> Update(int id, JobPostUpdateRequest request)
        {
            var entity = await _dbContext.JobPosts
                .Include(j => j.JobPostSkills)
                .FirstOrDefaultAsync(j => j.Id == id);
            if (entity == null) return null;

            entity.CompanyId = request.CompanyId;
            entity.RecruiterId = request.RecruiterId;
            entity.Title = request.Title;
            entity.Description = request.Description;
            entity.CityId = request.CityId;
            entity.WorkModeId = request.WorkModeId;
            entity.Compensation = request.Compensation;
            entity.EmploymentTypeId = request.EmploymentTypeId;
            entity.ExpiryDate = request.ExpiryDate;
            entity.UpdatedAt = DateTime.UtcNow;

            // Ažuriraj vještine: obriši stare, dodaj nove
            _dbContext.JobPostSkills.RemoveRange(entity.JobPostSkills);
            foreach (var skillId in request.SkillIds.Distinct())
                entity.JobPostSkills.Add(new JobPostSkill { SkillId = skillId });

            await _dbContext.SaveChangesAsync();

            var loaded = await _dbContext.JobPosts
                .Include(j => j.Company).Include(j => j.EmploymentType)
                .Include(j => j.Industry).Include(j => j.City).Include(j => j.WorkMode)
                .Include(j => j.Applications)
                .FirstAsync(j => j.Id == id);

            return MapToResponse(loaded);
        }
        public async Task<List<RecommendedJobResponse>> GetRecommended(int candidateId, int take = 10)
        {
            var user = await _dbContext.MyAppUsers
                .Include(u => u.CandidateProfile)
                .Include(u => u.UserSkills)
                .FirstOrDefaultAsync(u => u.Id == candidateId);

            if (user == null)
                return new List<RecommendedJobResponse>();

            var preferredIndustryId = user.CandidateProfile?.PreferredIndustryId;
            var preferredTypeId = user.CandidateProfile?.PreferredEmploymentTypeId;
            var userSkillIds = user.UserSkills.Select(us => us.SkillId).ToHashSet();

            var now = DateTime.UtcNow;
            var jobs = await _dbContext.JobPosts
                .Include(j => j.Company)
                .Include(j => j.EmploymentType)
                .Include(j => j.Industry)
                .Include(j => j.City)
                .Include(j => j.JobPostSkills).ThenInclude(jps => jps.Skill)
                .Where(j => j.ExpiryDate > now)
                .ToListAsync();

            var results = new List<RecommendedJobResponse>();

            foreach (var job in jobs)
            {
                int score = 0;
                var reasons = new List<string>();

                if (preferredIndustryId.HasValue && job.IndustryId == preferredIndustryId.Value)
                {
                    score += 2;
                    reasons.Add($"odgovara tvojoj industriji ({job.Industry?.Name})");
                }

                if (preferredTypeId.HasValue && job.EmploymentTypeId == preferredTypeId.Value)
                {
                    score += 1;
                    reasons.Add($"odgovara željenom tipu rada ({job.EmploymentType?.Name})");
                }

                var jobSkillNames = job.JobPostSkills
                    .Where(jps => userSkillIds.Contains(jps.SkillId))
                    .Select(jps => jps.Skill.Name)
                    .ToList();

                if (jobSkillNames.Any())
                {
                    score += jobSkillNames.Count;
                    var skillsText = string.Join(", ", jobSkillNames);
                    reasons.Add($"{jobSkillNames.Count} vještina se poklapa ({skillsText})");
                }

                if (score > 0)
                {
                    results.Add(new RecommendedJobResponse
                    {
                        Id = job.Id,
                        Title = job.Title,
                        CompanyName = job.Company?.Name ?? string.Empty,
                        CompanyLogoUrl = job.Company?.LogoUrl ?? string.Empty,
                        Location = job.City?.Name ?? string.Empty,
                        EmploymentTypeName = job.EmploymentType?.Name ?? string.Empty,
                        ExpiryDate = job.ExpiryDate,
                        Score = score,
                        Explanation = "Preporučeno jer " + string.Join("; ", reasons) + ".",
                    });
                }
            }

            return results
                .OrderByDescending(r => r.Score)
                .Take(take)
                .ToList();
        }
    }

    
}