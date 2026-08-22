using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
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

        private static readonly Dictionary<int, List<int>> _allowedTransitions = new()
        {
            { 1, new List<int> { 2, 6 } },
            { 2, new List<int> { 3, 6 } },
            { 3, new List<int> { 4, 6 } },
            { 4, new List<int> { 5, 6 } },
            { 5, new List<int>() },
            { 6, new List<int>() },
        };
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
                ApplicationStatusId = 1,
                AppliedAt = DateTime.UtcNow,
                CvUrl = request.CvUrl ?? string.Empty,
                StatusChangedAt = DateTime.UtcNow
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
            var newStatusId = request.ApplicationStatusId;

            if (oldStatusId != newStatusId)
            {
                if (!_allowedTransitions.TryGetValue(oldStatusId, out var allowed) || !allowed.Contains(newStatusId))
                {
                    throw new BusinessException($"Status transition from '{application.ApplicationStatus?.Name}' to the selected status is not allowed.");
                }

                if (newStatusId == 6 && string.IsNullOrWhiteSpace(request.RejectionReason))
                {
                    throw new BusinessException("Rejection reason is required when rejecting an application.");
                }
            }

            var changedById = request.ChangedById ?? 0;

            using var transaction = await _dbContext.Database.BeginTransactionAsync();
            try
            {
                application.ApplicationStatusId = newStatusId;
                application.StatusChangedAt = DateTime.UtcNow;
                application.StatusChangedById = changedById > 0 ? changedById : null;

                if (newStatusId == 6)
                    application.RejectionReason = request.RejectionReason;

                if (oldStatusId != newStatusId)
                {
                    var newStatus = await _dbContext.ApplicationStatuses
                        .FirstOrDefaultAsync(s => s.Id == newStatusId);
                    var jobTitle = application.JobPost?.Title ?? "a position";
                    var statusName = newStatus?.Name ?? "updated";

                    var notificationMessage = newStatusId == 6
                        ? $"Your application for {jobTitle} was rejected. Reason: {request.RejectionReason}"
                        : $"Your application for {jobTitle} is now: {statusName}";

                    _dbContext.Notifications.Add(new Notification
                    {
                        UserId = application.CandidateId,
                        Type = "ApplicationStatus",
                        Message = notificationMessage,
                        IsRead = false,
                        CreatedAt = DateTime.UtcNow
                    });
                }

                await _dbContext.SaveChangesAsync();
                await transaction.CommitAsync();

                if (oldStatusId != newStatusId)
                {
                    var candidate = await _dbContext.MyAppUsers.FirstOrDefaultAsync(u => u.Id == application.CandidateId);
                    var statusForEmail = await _dbContext.ApplicationStatuses.FirstOrDefaultAsync(s => s.Id == newStatusId);
                    var jobTitleForEmail = application.JobPost?.Title ?? "a position";

                    if (candidate != null && !string.IsNullOrEmpty(candidate.Email))
                    {
                        var emailBody = newStatusId == 6
                            ? $"Hello {candidate.FirstName}, your application for {jobTitleForEmail} was rejected. Reason: {request.RejectionReason}. HireMatch"
                            : $"Hello {candidate.FirstName}, your application for {jobTitleForEmail} is now: {statusForEmail?.Name ?? "updated"}. HireMatch";

                        await _publisher.PublishEmail(new EmailMessage
                        {
                            ToEmail = candidate.Email,
                            Subject = "Application status updated",
                            Body = emailBody
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