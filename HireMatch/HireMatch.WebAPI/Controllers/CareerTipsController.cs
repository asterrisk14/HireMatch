using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;

namespace HireMatch.WebAPI.Controllers
{
    public class CareerTipsController : BaseCRUDController<CareerTipResponse, CareerTipSearchObject, CareerTipInsertRequest, CareerTipUpdateRequest>
    {
        public CareerTipsController(ICareerTipService service) : base(service) { }
    }
}