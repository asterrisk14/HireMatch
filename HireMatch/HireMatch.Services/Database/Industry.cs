using System.ComponentModel.DataAnnotations;

namespace HireMatch.Services.Database
{
    public class Industry
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public string Name { get; set; } = default!; 
    }
}
