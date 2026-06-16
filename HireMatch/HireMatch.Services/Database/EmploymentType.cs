using System.ComponentModel.DataAnnotations;

namespace HireMatch.Services.Database
{
    public class EmploymentType
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public string Name { get; set; } = default!; // Full-time, Part-time, Contract, Internship

        public ICollection<JobPost> JobPosts { get; set; } = new List<JobPost>();
    }
}
