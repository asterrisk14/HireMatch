namespace HireMatch.Model.Responses
{
    public class CompanyResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = default!;
        public string Address { get; set; } = default!;
        public int? CityId { get; set; }
        public string CityName { get; set; } = string.Empty;
        public string RegistrationNumber { get; set; } = default!;
        public string? Description { get; set; }
        public string? Website { get; set; }
        public string? LogoUrl { get; set; }
        public System.DateTime CreatedAt { get; set; }
    }
}