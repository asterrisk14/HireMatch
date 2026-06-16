using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Database;
using HireMatch.Services.Interfaces;
using HireMatch.Services.Messaging;
using Mapster;

namespace HireMatch.Services.Implementations
{
    public class ApplicationEFService : BaseEFCRUDService<ApplicationResponse, Application, ApplicationSearchObject, ApplicationInsertRequest, ApplicationUpdateRequest>, IApplicationService
    {
        private readonly IMessagePublisher _publisher;

        public ApplicationEFService(HireMatchDbContext context, IMessagePublisher publisher) : base(context)
        {
            _publisher = publisher;
        }

        protected override IQueryable<Application> ApplySearchFilters(IQueryable<Application> query, ApplicationSearchObject search)
        {
            query = query
                .Include(a => a.Candidate)
                .Include(a => a.JobPost).ThenInclude(j => j.Company)
                .Include(a => a.ApplicationStatus);

            if (search != null)
            {
                if (search.CandidateId.HasValue)
                    query = query.Where(a => a.CandidateId == search.CandidateId.Value);
                if (search.JobPostId.HasValue)
                    query = query.Where(a => a.JobPostId == search.JobPostId.Value);
                if (search.ApplicationStatusId.HasValue)
                    query = query.Where(a => a.ApplicationStatusId == search.ApplicationStatusId.Value);
            }

            return query.OrderByDescending(a => a.AppliedAt);
        }

        public override async Task<ApplicationResponse> Insert(ApplicationInsertRequest request)
        {
            var entity = new Application
            {
                CandidateId = request.CandidateId,
                JobPostId = request.JobPostId,
                ApplicationStatusId = request.ApplicationStatusId,
                AppliedAt = DateTime.UtcNow,
                CvUrl = request.CvUrl ?? string.Empty
            };

            _dbSet.Add(entity);
            await _dbContext.SaveChangesAsync();

            var loaded = await _dbContext.Applications
                .Include(a => a.Candidate)
                .Include(a => a.JobPost).ThenInclude(j => j.Company)
                .Include(a => a.ApplicationStatus)
                .FirstAsync(a => a.Id == entity.Id);

            return loaded.Adapt<ApplicationResponse>();
        }

        public override async Task<ApplicationResponse?> Update(int id, ApplicationUpdateRequest request)
        {
            var application = await _dbContext.Applications
                .Include(a => a.JobPost)
                .Include(a => a.ApplicationStatus)
                .FirstOrDefaultAsync(a => a.Id == id);

            if (application == null) return null;

            var oldStatusId = application.ApplicationStatusId;

            using var transaction = await _dbContext.Database.BeginTransactionAsync();
            try
            {
                application.ApplicationStatusId = request.ApplicationStatusId;

                if (oldStatusId != request.ApplicationStatusId)
                {
                    var newStatus = await _dbContext.ApplicationStatuses
                        .FirstOrDefaultAsync(s => s.Id == request.ApplicationStatusId);
                    var jobTitle = application.JobPost?.Title ?? "a position";
                    var statusName = newStatus?.Name ?? "updated";

                    var notification = new Notification
                    {
                        UserId = application.CandidateId,
                        Type = "ApplicationStatus",
                        Message = $"Your application for {jobTitle} is now: {statusName}",
                        IsRead = false,
                        CreatedAt = DateTime.UtcNow
                    };
                    _dbContext.Notifications.Add(notification);
                }

                await _dbContext.SaveChangesAsync();
                await transaction.CommitAsync();

                if (oldStatusId != request.ApplicationStatusId)
                {
                    var candidate = await _dbContext.MyAppUsers.FirstOrDefaultAsync(u => u.Id == application.CandidateId);
                    var statusForEmail = await _dbContext.ApplicationStatuses.FirstOrDefaultAsync(s => s.Id == request.ApplicationStatusId);
                    var jobTitleForEmail = application.JobPost?.Title ?? "a position";

                    if (candidate != null && !string.IsNullOrEmpty(candidate.Email))
                    {
                        _publisher.PublishEmail(new EmailMessage
                        {
                            ToEmail = candidate.Email,
                            Subject = "Application status updated",
                            Body = "Hello " + candidate.FirstName + ", your application for " + jobTitleForEmail + " is now: " + (statusForEmail != null ? statusForEmail.Name : "") + ". HireMatch"
                        });
                    }
                }
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }

            var loaded = await _dbContext.Applications
                .Include(a => a.Candidate)
                .Include(a => a.JobPost).ThenInclude(j => j.Company)
                .Include(a => a.ApplicationStatus)
                .FirstAsync(a => a.Id == id);

            return loaded.Adapt<ApplicationResponse>();
        }
    }
}
