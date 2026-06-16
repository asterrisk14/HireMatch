using System.Collections.Generic;

namespace HireMatch.Services.Database{
    public class City
    {
        public int Id { get; set; }
        public string Name { get; set; } = null!;

        public int CountryId { get; set; }
        public Country Country { get; set; } = null!;

        // Navigation
        public ICollection<MyAppUser> Users { get; set; } = new List<MyAppUser>();
    }
}
