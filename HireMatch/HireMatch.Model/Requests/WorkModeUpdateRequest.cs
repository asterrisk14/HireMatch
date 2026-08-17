using System;

namespace HireMatch.Model.Requests
{
    public class WorkModeUpdateRequest
    {
        public int Id { get; set; }
        public string Name { get; set; } = default!;

    }
}