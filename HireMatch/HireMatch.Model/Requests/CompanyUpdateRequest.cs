using System.ComponentModel.DataAnnotations;

namespace HireMatch.Model.Requests
{
    public class CompanyUpdateRequest
    {
        [Required(ErrorMessage = "Name is required.")]
        public string Name { get; set; } = default!;

        [Required(ErrorMessage = "Address is required.")]
        public string Address { get; set; } = default!;

        [Required(ErrorMessage = "City is required.")]
        public int CityId { get; set; }

        [Required(ErrorMessage = "Registration number is required.")]
        public string RegistrationNumber { get; set; } = default!;

        public string? Description { get; set; }
        public string? Website { get; set; }
    }
}