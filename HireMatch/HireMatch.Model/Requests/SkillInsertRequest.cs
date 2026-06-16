using System.ComponentModel.DataAnnotations;

namespace HireMatch.Model.Requests
{
    public class SkillInsertRequest
    {
        [Required(ErrorMessage = "Name is required.")]
        public string Name { get; set; } = default!;
    }
}
