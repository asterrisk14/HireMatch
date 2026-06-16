using System;

namespace HireMatch.Model.Responses
{
    public class AuthResponse
    {
        public int Id { get; set; }
        public required string FirstName { get; set; }
        public required string LastName { get; set; }
        public required string Email { get; set; }
        public required string Token { get; set; }
        public bool IsPremium { get; set; }
        public required DateOnly DateOfBirth { get; set; }
        public required string Phone { get; set; }
        public string? Role { get; set; }
    }
}