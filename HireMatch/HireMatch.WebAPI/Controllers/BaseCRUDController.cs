using Microsoft.AspNetCore.Mvc;
using HireMatch.Services.Interfaces;
using HireMatch.Model.SearchObjects;

namespace HireMatch.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    // Ovdje dodajemo ograničenja i za TInsert i TUpdate
    public class BaseCRUDController<TResponse, TSearch, TInsert, TUpdate> : BaseController<TResponse, TSearch>
        where TResponse : class
        where TSearch : BaseSearchObject
        where TInsert : class // Ovo popravlja grešku
        where TUpdate : class // Ovo popravlja grešku
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
            // Koristimo dynamic da izvučemo Id iz rezultata za CreatedAtAction
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
