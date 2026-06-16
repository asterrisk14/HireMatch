namespace HireMatch.Model.Result
{
    public class PagedResult<T>
    {
        public List<T> Result { get; set; } = new List<T>();
        public int? TotalCount { get; set; }
    }
}