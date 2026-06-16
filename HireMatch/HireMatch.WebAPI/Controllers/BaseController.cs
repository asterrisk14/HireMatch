using Microsoft.AspNetCore.Mvc;
using HireMatch.Services.Interfaces;
using HireMatch.Model.SearchObjects;
using HireMatch.Model.Result;

namespace HireMatch.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class BaseController<TResponse, TSearch> : ControllerBase
        where TResponse : class
        where TSearch : BaseSearchObject
    {
        protected readonly IBaseReadService<TResponse, TSearch> _service;

        public BaseController(IBaseReadService<TResponse, TSearch> service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<IActionResult> Get([FromQuery] TSearch search)
        {
            var result = await _service.Get(search);
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var result = await _service.GetById(id);
            if (result == null)
            {
                return NotFound();
            }
            return Ok(result);
        }
    }
}