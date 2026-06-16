namespace HireMatch.Model.Responses
{
    public class CityResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = default!;
        public int CountryId { get; set; }
        public string CountryName { get; set; } = string.Empty;
    }
}
