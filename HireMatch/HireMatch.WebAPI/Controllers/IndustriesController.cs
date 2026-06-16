using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace HireMatch.WebAPI.Controllers
{
    public class IndustriesController : BaseCRUDController<IndustryResponse, IndustrySearchObject, IndustryInsertRequest, IndustryUpdateRequest>
    {
        public IndustriesController(IIndustryService service) : base(service) { }

        [HttpPost]
        [Authorize(Roles = "Admin")]
        public override async Task<IActionResult> Post([FromBody] IndustryInsertRequest request)
        {
            return await base.Post(request);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public override async Task<IActionResult> Put(int id, [FromBody] IndustryUpdateRequest request)
        {
            return await base.Put(id, request);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public override async Task<IActionResult> Delete(int id)
        {
            try
            {
                await _crudService.Delete(id);
                return NoContent();
            }
            catch (DbUpdateException ex) when (ex.InnerException?.Message.Contains("FOREIGN KEY constraint") == true)
            {
                return BadRequest(new { error = "Cannot delete this industry as it is referenced by other records." });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = "An error occurred while deleting the industry." });
            }
        }
    }
}