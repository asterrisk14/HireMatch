using System.Collections.Generic;

namespace HireMatch.Services.Database{
    
    public class Country
    {
        public int Id { get; set; }
        public string Name { get; set; } = null!;

        // Navigation
        public ICollection<City> Cities { get; set; } = new List<City>();
        public ICollection<MyAppUser> Users { get; set; } = new List<MyAppUser>();
    }
}
