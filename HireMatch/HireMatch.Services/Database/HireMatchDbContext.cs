using Microsoft.EntityFrameworkCore;

namespace HireMatch.Services.Database
{
    public class HireMatchDbContext : DbContext
    {
        public HireMatchDbContext(DbContextOptions<HireMatchDbContext> options) : base(options) { }

        public DbSet<Application> Applications { get; set; }
        public DbSet<ApplicationStatus> ApplicationStatuses { get; set; }
        public DbSet<Candidate> Candidates { get; set; }
        public DbSet<WorkMode> WorkModes { get; set; }
        public DbSet<CandidatePreference> CandidatePreferences { get; set; }
        public DbSet<City> Cities { get; set; }
        public DbSet<Company> Companies { get; set; }
        public DbSet<Country> Countries { get; set; }
        public DbSet<EmploymentType> EmploymentTypes { get; set; }
        public DbSet<CareerTip> CareerTips { get; set; }
        public DbSet<Favourite> Favourites { get; set; }
        public DbSet<Industry> Industries { get; set; }
        public DbSet<JobPost> JobPosts { get; set; }
        public DbSet<JobPostSkill> JobPostSkills { get; set; }
        public DbSet<JobView> JobViews { get; set; }
        public DbSet<Message> Messages { get; set; }
        public DbSet<MyAppUser> MyAppUsers { get; set; }
        public DbSet<Notification> Notifications { get; set; }
        public DbSet<Skill> Skills { get; set; }
        public DbSet<UserActivityLog> UserActivityLogs { get; set; }
        public DbSet<UserSkill> UserSkills { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configure composite primary keys for junction tables
            modelBuilder.Entity<JobPostSkill>()
                .HasKey(jps => new { jps.JobPostId, jps.SkillId });

            modelBuilder.Entity<UserSkill>()
                .HasKey(us => new { us.UserId, us.SkillId });

            // Configure relationships to avoid cascade cycles
            modelBuilder.Entity<Application>()
                .HasOne(a => a.Candidate)
                .WithMany()
                .HasForeignKey(a => a.CandidateId)
                .OnDelete(DeleteBehavior.NoAction);
                
            modelBuilder.Entity<Candidate>()
                .HasOne(c => c.PreferredIndustry)
                .WithMany()
                .HasForeignKey(c => c.PreferredIndustryId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<Candidate>()
                .HasOne(c => c.PreferredEmploymentType)
                .WithMany()
                .HasForeignKey(c => c.PreferredEmploymentTypeId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<CareerTip>().HasData(
                new CareerTip { Id = 1, Icon = "✨", Title = "How to make your CV stand out", Content = "Keep it concise, use action verbs, and tailor it to each job. Highlight measurable achievements rather than just listing duties.", CreatedAt = new DateTime(2025, 1, 1) },
                new CareerTip { Id = 2, Icon = "💬", Title = "Top 3 soft skills recruiters love", Content = "Communication, teamwork and problem-solving consistently rank highest. Show examples of these in your interviews.", CreatedAt = new DateTime(2025, 1, 2) },
                new CareerTip { Id = 3, Icon = "🚀", Title = "Don't have experience? Here's what to do", Content = "Apply for internships, contribute to open-source projects, or take on freelance work to build your portfolio.", CreatedAt = new DateTime(2025, 1, 3) }
            );
            // Povezano sa ICollection<Application> Applications unutar JobPost.cs
            modelBuilder.Entity<Application>()
                .HasOne(a => a.JobPost)
                .WithMany(j => j.Applications) 
                .HasForeignKey(a => a.JobPostId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<Favourite>()
                .HasOne(f => f.Candidate)
                .WithMany()
                .HasForeignKey(f => f.CandidateId)
                .OnDelete(DeleteBehavior.NoAction);

            // Povezano sa ICollection<Favourite> Favourites unutar JobPost.cs
            modelBuilder.Entity<Favourite>()
                .HasOne(f => f.JobPost)
                .WithMany(j => j.Favourites)
                .HasForeignKey(f => f.JobPostId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<JobView>()
                .HasOne(jv => jv.Candidate)
                .WithMany()
                .HasForeignKey(jv => jv.CandidateId)
                .OnDelete(DeleteBehavior.NoAction);

            // Povezano sa ICollection<JobView> JobViews unutar JobPost.cs
            modelBuilder.Entity<JobView>()
                .HasOne(jv => jv.JobPost)
                .WithMany(j => j.JobViews)
                .HasForeignKey(jv => jv.JobPostId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<Message>()
                .HasOne(m => m.Sender)
                .WithMany()
                .HasForeignKey(m => m.SenderId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<Message>()
                .HasOne(m => m.Receiver)
                .WithMany()
                .HasForeignKey(m => m.ReceiverId)
                .OnDelete(DeleteBehavior.NoAction);

            // Povezano sa ICollection<Message> Messages unutar JobPost.cs
            modelBuilder.Entity<Message>()
                .HasOne(m => m.JobPost)
                .WithMany(j => j.Messages)
                .HasForeignKey(m => m.JobPostId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<Candidate>()
                .HasOne(c => c.City)
                .WithMany()
                .HasForeignKey(c => c.CityId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<Candidate>()
                .HasOne(c => c.Country)
                .WithMany()
                .HasForeignKey(c => c.CountryId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<Company>()
                .HasOne(c => c.City)
                .WithMany()
                .HasForeignKey(c => c.CityId)
                .OnDelete(DeleteBehavior.NoAction);

            // JobPost -> City
            modelBuilder.Entity<JobPost>()
                .HasOne(j => j.City)
                .WithMany()
                .HasForeignKey(j => j.CityId)
                .OnDelete(DeleteBehavior.NoAction);

            // JobPost -> WorkMode
            modelBuilder.Entity<JobPost>()
                .HasOne(j => j.WorkMode)
                .WithMany(w => w.JobPosts)
                .HasForeignKey(j => j.WorkModeId)
                .OnDelete(DeleteBehavior.NoAction);

            // WorkMode seed
            modelBuilder.Entity<WorkMode>().HasData(
                new WorkMode { Id = 1, Name = "Remote" },
                new WorkMode { Id = 2, Name = "Hybrid" },
                new WorkMode { Id = 3, Name = "On-site" }
            );
                        

            modelBuilder.Entity<Country>().HasData(
    new Country { Id = 1, Name = "Bosna i Hercegovina" },
    new Country { Id = 2, Name = "Hrvatska" },
    new Country { Id = 3, Name = "Srbija" },
    new Country { Id = 4, Name = "Slovenija" },
    new Country { Id = 5, Name = "Crna Gora" }
);

// 2. Gradovi (Sada im ponosno dodajemo CountryId = 1)
modelBuilder.Entity<City>().HasData(
        new City { Id = 1, Name = "Sarajevo", CountryId = 1 },
        new City { Id = 2, Name = "Banja Luka", CountryId = 1 },
        new City { Id = 3, Name = "Mostar", CountryId = 1 },
        new City { Id = 4, Name = "Tuzla", CountryId = 1 },
        new City { Id = 5, Name = "Zenica", CountryId = 1 },
        new City { Id = 6, Name = "Zagreb", CountryId = 2 },
        new City { Id = 7, Name = "Split", CountryId = 2 },
        new City { Id = 8, Name = "Rijeka", CountryId = 2 },
        new City { Id = 9, Name = "Osijek", CountryId = 2 },
        new City { Id = 10, Name = "Varaždin", CountryId = 2 },
        new City { Id = 11, Name = "Beograd", CountryId = 3 },
        new City { Id = 12, Name = "Novi Sad", CountryId = 3 },
        new City { Id = 13, Name = "Nis", CountryId = 3 },
        new City { Id = 14, Name = "Kragujevac", CountryId = 3 },
        new City { Id = 15, Name = "Subotica", CountryId = 3 },
        new City { Id = 16, Name = "Ljubljana", CountryId = 4 },
        new City { Id = 17, Name = "Maribor", CountryId = 4 },
        new City { Id = 18, Name = "Celje", CountryId = 4 },
        new City { Id = 19, Name = "Kranj", CountryId = 4 },
        new City { Id = 20, Name = "Koper", CountryId = 4 },
        new City { Id = 21, Name = "Podgorica", CountryId = 5 },
        new City { Id = 22, Name = "Nikšic", CountryId = 5 },
        new City { Id = 23, Name = "Herceg Novi", CountryId = 5 },
        new City { Id = 24, Name = "Kotor", CountryId = 5 },
        new City { Id = 25, Name = "Budva", CountryId = 5 }
);


modelBuilder.Entity<EmploymentType>().HasData(
    new EmploymentType { Id = 1, Name = "Full-time" },
    new EmploymentType { Id = 2, Name = "Part-time" },
    new EmploymentType { Id = 3, Name = "Freelance" },
    new EmploymentType { Id = 4, Name = "Internship" },
    new EmploymentType { Id = 5, Name = "Remote" },
    new EmploymentType { Id = 6, Name = "Hybrid" },
    new EmploymentType { Id = 7, Name = "Contract" }
);

// 4. Industrije
modelBuilder.Entity<Industry>().HasData(
    new Industry { Id = 1, Name = "IT" },
    new Industry { Id = 2, Name = "Marketing" },
    new Industry { Id = 3, Name = "Finance" },
    new Industry { Id = 4, Name = "Healthcare" },
    new Industry { Id = 5, Name = "Engineering" },
    new Industry { Id = 6, Name = "Beauty & Fashion" },
    new Industry { Id = 7, Name = "Human Resources" },
    new Industry { Id = 8, Name = "Education" },
    new Industry { Id = 9, Name = "Gaming" },
    new Industry { Id = 10, Name = "Legal" },
    new Industry { Id = 11, Name = "Manufacturing" },
    new Industry { Id = 12, Name = "Financial" }
);

    // 5. Inicijalne vještine
    modelBuilder.Entity<Skill>().HasData(
        new Skill { Id = 1, Name = ".NET" },
        new Skill { Id = 2, Name = "Angular" },
        new Skill { Id = 3, Name = "SQL Server" },
        new Skill { Id = 4, Name = "JavaScript" },
        new Skill { Id = 5, Name = "TypeScript" },
        new Skill { Id = 6, Name = "C#" }
    );


    modelBuilder.Entity<MyAppUser>().HasData(
        new MyAppUser
        {
            Id = 1, 
            FirstName = "Admin",
            LastName = "System",
            Email = "admin@hirematch.com",
            PasswordHash = "$2a$11$JO5M9Y9U1otkWfU2DR92eeNc6eUbdM0nP6YdqfGht90NhNW1mIYxC",
            Role = "Admin",
            Phone = "000-000-000",
            CountryId = null, 
            CityId = null     
            
        }
    );
   
    modelBuilder.Entity<ApplicationStatus>().HasData(
        new ApplicationStatus { Id = 1, Name = "New" },
        new ApplicationStatus { Id = 2, Name = "Reviewed" },
        new ApplicationStatus { Id = 3, Name = "Sent to client" },
        new ApplicationStatus { Id = 4, Name = "Technical interview" },
        new ApplicationStatus { Id = 5, Name = "Final stage" },
        new ApplicationStatus { Id = 6, Name = "Rejected" }
    );
            
            // ==================== KRAJ SEED PODATAKA ====================
        }
    }
}