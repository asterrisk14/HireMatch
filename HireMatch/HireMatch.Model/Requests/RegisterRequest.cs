using System;
using System.ComponentModel.DataAnnotations;

namespace HireMatch.Model.Requests
{
    public class RegisterRequest
    {
        public required string FirstName { get; set; }
        public required string LastName { get; set; }

        [EmailAddress]
        public required string Email { get; set; }

        [MinLength(6)]
        public required string Password { get; set; }
        public required DateOnly DateOfBirth { get; set; }
        [RegularExpression(@"^(\+387|0)6[0-9]{7}$", ErrorMessage = "Unesite validan broj telefona u formatu: 06XXXXXXX ili +3876XXXXXXX")]
        public required string Phone { get; set; }

        public required int CountryId { get; set; }
        public required int CityId { get; set; }
    }
}