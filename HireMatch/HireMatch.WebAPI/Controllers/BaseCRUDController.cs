using Microsoft.AspNetCore.Mvc;
using HireMatch.Services.Interfaces;
using HireMatch.Model.SearchObjects;

namespace HireMatch.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class BaseCRUDController<TResponse, TSearch, TInsert, TUpdate> : BaseController<TResponse, TSearch>
        where TResponse : class
        where TSearch : BaseSearchObject
        where TInsert : class 
        where TUpdate : class
    {
        protected readonly IBaseCRUDService<TResponse, TSearch, TInsert, TUpdate> _crudService;

        public BaseCRUDController(IBaseCRUDService<TResponse, TSearch, TInsert, TUpdate> service) : base(service)
        {
            _crudService = service;
        }

        [HttpPost]
        public virtual async Task<IActionResult> Post([FromBody] TInsert request)
        {
            var result = await _crudService.Insert(request);
            return CreatedAtAction(nameof(GetById), new { id = (result as dynamic)?.Id }, result);
        }

        [HttpPut("{id}")]
        public virtual async Task<IActionResult> Put(int id, [FromBody] TUpdate request)
        {
            var result = await _crudService.Update(id, request);
            return Ok(result);
        }

        [HttpDelete("{id}")]
        public virtual async Task<IActionResult> Delete(int id)
        {
            await _crudService.Delete(id);
            return NoContent();
        }
    }
}
