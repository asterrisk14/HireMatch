using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace HireMatch.WebAPI.Controllers
{
    public class FavouritesController : BaseCRUDController<FavouriteResponse, FavouriteSearchObject, FavouriteInsertRequest, FavouriteUpdateRequest>
    {
        public FavouritesController(IFavouriteService service) : base(service) { }
    }
}
