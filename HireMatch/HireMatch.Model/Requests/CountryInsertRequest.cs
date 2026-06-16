using System.ComponentModel.DataAnnotations;

namespace HireMatch.Model.Requests
{
    public class CountryInsertRequest
    {
        [Required(ErrorMessage = "Name is required.")]
        public string Name { get; set; } = default!;
    }
}