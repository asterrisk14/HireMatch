using System.ComponentModel.DataAnnotations;

namespace HireMatch.Model.Requests
{
    public class CityUpdateRequest
    {
        [Required(ErrorMessage = "Name is required.")]
        public string Name { get; set; } = default!;

        [Required(ErrorMessage = "Country is required.")]
        public int CountryId { get; set; }
    }
}