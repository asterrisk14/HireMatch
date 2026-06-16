using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;

namespace HireMatch.Services.Interfaces
{
    public interface IFavouriteService : IBaseCRUDService<FavouriteResponse, FavouriteSearchObject, FavouriteInsertRequest, FavouriteUpdateRequest>
    {
    }
}
