using Microsoft.EntityFrameworkCore;
using Scalar.AspNetCore;
using HireMatch.Services;
using HireMatch.Services.Database;
using HireMatch.Services.Interfaces;
using HireMatch.Services.Implementations;
using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Services.Database;
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
        policy.AllowAnyHeader()
              .AllowAnyMethod()
              .AllowAnyOrigin();
    });
});

builder.Services.AddControllers();
builder.Services.AddOpenApi();

builder.Services.AddDbContext<HireMatchDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddScoped<DbContext>(provider => provider.GetRequiredService<HireMatchDbContext>());

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
builder.Services.AddScoped<IIndustryService, IndustryEFService>();
builder.Services.AddScoped<IWorkModeService, WorkModeEFService>();
builder.Services.AddScoped<INotificationService, NotificationEFService>();
builder.Services.AddSingleton<HireMatch.Services.Messaging.IMessagePublisher, HireMatch.Services.Messaging.RabbitMqPublisher>();

// 3. Dodavanje JWT Autentifikacije
var tokenKey = builder.Configuration["TokenKey"] ?? "OvoJeMojSuperTajniIPredugackiKljucZaGenerisanjeTokena1234567890!";
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

// Mapster konfiguracija
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
    .Map(dest => dest.CompanyLogoUrl, src => src.JobPost.Company.LogoUrl ?? string.Empty);
TypeAdapterConfig<Application, ApplicationResponse>.NewConfig()
    .Map(dest => dest.CandidateFirstName, src => src.Candidate.FirstName)
    .Map(dest => dest.CandidateLastName, src => src.Candidate.LastName)
    .Map(dest => dest.CandidateEmail, src => src.Candidate.Email)
    .Map(dest => dest.JobPostTitle, src => src.JobPost.Title)
    .Map(dest => dest.ApplicationStatusName, src => src.ApplicationStatus.Name);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<HireMatch.Services.Database.HireMatchDbContext>();
    db.Database.EnsureCreated();
}

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.UseSwagger();
    app.UseSwaggerUI();
    app.MapScalarApiReference();
}

app.UseCors("CorsPolicy");

app.UseAuthentication(); 
app.UseAuthorization();
app.UseStaticFiles();

app.MapControllers();

app.Run();