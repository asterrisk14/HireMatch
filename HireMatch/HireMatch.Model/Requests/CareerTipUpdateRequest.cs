using System.ComponentModel.DataAnnotations;

namespace HireMatch.Model.Requests
{
    public class CareerTipUpdateRequest
    {
        [Required(ErrorMessage = "Naslov je obavezan.")]
        public string Title { get; set; } = default!;

        [Required(ErrorMessage = "Sadržaj je obavezan.")]
        public string Content { get; set; } = default!;

        public string Icon { get; set; } = "💡";
    }
}