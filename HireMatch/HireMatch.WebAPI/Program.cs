using Microsoft.EntityFrameworkCore;
using Scalar.AspNetCore;
using HireMatch.Services;
using HireMatch.Services.Database;
using HireMatch.Services.Interfaces;
using HireMatch.Services.Implementations;
using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using DotNetEnv;
using Mapster;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;

DotNetEnv.Env.Load();

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddCors(options =>
{
    options.AddPolicy("CorsPolicy", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

builder.Services.AddDbContext<HireMatchDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddScoped<ICandidateService, CandidateEFService>();
builder.Services.AddScoped<IJobPostService, JobPostEFService>();
builder.Services.AddScoped<ICompanyService, CompanyEFService>();
builder.Services.AddScoped<IUserSkillService, UserSkillEFService>();
builder.Services.AddScoped<ITokenService, TokenService>();
builder.Services.AddScoped<IPaymentService, PaymentService>();
builder.Services.AddScoped<IFavouriteService, FavouriteEFService>();
builder.Services.AddScoped<IApplicationService, ApplicationEFService>();
builder.Services.AddScoped<IApplicationStatusService, ApplicationStatusEFService>();
builder.Services.AddScoped<IEmploymentTypeService, EmploymentTypeEFService>();
builder.Services.AddScoped<IIndustryService, IndustryEFService>();
builder.Services.AddScoped<ISkillService, SkillEFService>();
builder.Services.AddScoped<ICountryService, CountryEFService>();
builder.Services.AddScoped<ICityService, CityEFService>();
builder.Services.AddScoped<ICareerTipService, CareerTipEFService>();
builder.Services.AddScoped<IWorkModeService, WorkModeEFService>();
builder.Services.AddScoped<INotificationService, NotificationEFService>();
builder.Services.AddSingleton<HireMatch.Services.Messaging.IMessagePublisher, HireMatch.Services.Messaging.RabbitMqPublisher>();

builder.Services.AddHttpContextAccessor();

var tokenKey = Environment.GetEnvironmentVariable("TokenKey") ?? throw new Exception("TokenKey nije definisan u .env");
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(tokenKey)),
            ValidateIssuer = false,
            ValidateAudience = false
        };
    });

TypeAdapterConfig.GlobalSettings.NewConfig<CandidateInsertRequest, MyAppUser>().IgnoreNullValues(true);
TypeAdapterConfig.GlobalSettings.NewConfig<CandidateUpdateRequest, MyAppUser>().IgnoreNullValues(true);
TypeAdapterConfig.GlobalSettings.NewConfig<MyAppUser, CandidateResponse>();
TypeAdapterConfig.GlobalSettings.NewConfig<JobPostInsertRequest, JobPost>().IgnoreNullValues(true);
TypeAdapterConfig.GlobalSettings.NewConfig<JobPostUpdateRequest, JobPost>().IgnoreNullValues(true);
TypeAdapterConfig.GlobalSettings.NewConfig<JobPost, JobPostResponse>();
TypeAdapterConfig.GlobalSettings.NewConfig<CompanyInsertRequest, Company>().IgnoreNullValues(true);
TypeAdapterConfig.GlobalSettings.NewConfig<CompanyUpdateRequest, Company>().IgnoreNullValues(true);
TypeAdapterConfig.GlobalSettings.NewConfig<Company, CompanyResponse>();

TypeAdapterConfig<Application, ApplicationResponse>.NewConfig()
    .Map(dest => dest.JobPostTitle, src => src.JobPost.Title)
    .Map(dest => dest.ApplicationStatusName, src => src.ApplicationStatus.Name)
    .Map(dest => dest.CompanyName, src => src.JobPost.Company.Name)
    .Map(dest => dest.CompanyLogoUrl, src => src.JobPost.Company.LogoUrl ?? string.Empty)
    .Map(dest => dest.CandidateFirstName, src => src.Candidate.FirstName)
    .Map(dest => dest.CandidateLastName, src => src.Candidate.LastName)
    .Map(dest => dest.CandidateEmail, src => src.Candidate.Email);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseMiddleware<HireMatch.WebAPI.Middlewares.ExceptionMiddleware>();


using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<HireMatchDbContext>();

    var retries = 0;
    while (retries < 10)
    {
        try { db.Database.Migrate(); break; }
        catch { retries++; Thread.Sleep(3000); }
    }

    if (!db.MyAppUsers.Any(u => u.Role == "Candidate"))
    {
        var mobileUser = new MyAppUser
        {
            FirstName = "Mobile",
            LastName = "User",
            Email = "mobile@hirematch.com",
            PasswordHash = "$2b$11$K3m/d1q2NGsdFYhJ3T74yeAu.YcDG4Q3MG7NnFRajSEhM4mdWDoMS",
            Role = "Candidate",
            Phone = "061-111-222"
        };
        db.MyAppUsers.Add(mobileUser);
        db.SaveChanges();

        db.Candidates.Add(new Candidate
        {
            MyAppUserId = mobileUser.Id,
            CurrentTitle = "Software Developer",
            Summary = "Looking for new opportunities.",
            LinkedInUrl = string.Empty,
            PortfolioUrl = string.Empty,
            CvUrl = string.Empty,
            ProfilePictureUrl = string.Empty,
            YearsOfExperience = 2
        });
        db.SaveChanges();
    }

    if (!db.Companies.Any())
    {
        var now = DateTime.UtcNow;
        db.Companies.AddRange(
            new Company { Name = "TechCorp d.o.o.", Address = "Zmaja od Bosne 1", RegistrationNumber = "1234567890", CreatedAt = now },
            new Company { Name = "Digital Agency", Address = "Ilica 10", RegistrationNumber = "2345678901", CreatedAt = now },
            new Company { Name = "Finance Plus", Address = "Knez Mihajlova 5", RegistrationNumber = "3456789012", CreatedAt = now },
            new Company { Name = "HealthCare Solutions", Address = "Titova 22", RegistrationNumber = "4567890123", CreatedAt = now },
            new Company { Name = "StartUp Hub", Address = "Slovenska 30", RegistrationNumber = "5678901234", CreatedAt = now }
        );
        db.SaveChanges();
    }

    if (!db.JobPosts.Any())
{
    try
    {
        var companies = db.Companies.ToList();
        if (companies.Any())
        {
            var now = DateTime.UtcNow;
            db.JobPosts.AddRange(
                new JobPost
                {
                    Title = "Senior .NET Developer",
                    Description = "Looking for experienced .NET developer.",
                    CompanyId = companies[0].Id,
                    RecruiterId = 1,
                    IndustryId = 1,
                    EmploymentTypeId = 1,
                    WorkModeId = 2,
                    CityId = 1,
                    ExpiryDate = now.AddMonths(14),
                    CreatedAt = now,
                    UpdatedAt = now,
                    Compensation = "3000-5000 KM"
                },
                new JobPost
                {
                    Title = "Flutter Mobile Developer",
                    Description = "Join our mobile team.",
                    CompanyId = companies[0].Id,
                    RecruiterId = 1,
                    IndustryId = 1,
                    EmploymentTypeId = 1,
                    WorkModeId = 1,
                    CityId = 1,
                    ExpiryDate = now.AddMonths(14),
                    CreatedAt = now,
                    UpdatedAt = now,
                    Compensation = "2500-4000 KM"
                },
                new JobPost
                {
                    Title = "Marketing Specialist",
                    Description = "Creative marketing specialist needed.",
                    CompanyId = companies[1].Id,
                    RecruiterId = 1,
                    IndustryId = 2,
                    EmploymentTypeId = 1,
                    WorkModeId = 2,
                    CityId = 1,
                    ExpiryDate = now.AddMonths(14),
                    CreatedAt = now,
                    UpdatedAt = now,
                    Compensation = "2000-3000 KM"
                },
                new JobPost
                {
                    Title = "Financial Analyst",
                    Description = "Experienced financial analyst.",
                    CompanyId = companies[2].Id,
                    RecruiterId = 1,
                    IndustryId = 3,
                    EmploymentTypeId = 1,
                    WorkModeId = 3,
                    CityId = 1,
                    ExpiryDate = now.AddMonths(14),
                    CreatedAt = now,
                    UpdatedAt = now,
                    Compensation = "2800-4500 KM"
                },
                new JobPost
                {
                    Title = "HR Manager",
                    Description = "HR Manager to lead talent acquisition.",
                    CompanyId = companies[3].Id,
                    RecruiterId = 1,
                    IndustryId = 7,
                    EmploymentTypeId = 1,
                    WorkModeId = 2,
                    CityId = 1,
                    ExpiryDate = now.AddMonths(14),
                    CreatedAt = now,
                    UpdatedAt = now,
                    Compensation = "2500-3500 KM"
                }
            );
            db.SaveChanges();
        }
    }
    catch { }
}
}

app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "HireMatch API V1");
});

app.MapScalarApiReference(options =>
{
    options.WithOpenApiRoutePattern("/swagger/v1/swagger.json");
});

app.UseCors("CorsPolicy");
app.UseAuthentication();
app.UseAuthorization();
app.UseStaticFiles();
app.MapControllers();

app.Run();