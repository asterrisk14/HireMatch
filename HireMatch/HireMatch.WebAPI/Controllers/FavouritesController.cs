using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace HireMatch.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class FavouritesController : BaseCRUDController<FavouriteResponse, FavouriteSearchObject, FavouriteInsertRequest, FavouriteUpdateRequest>
    {
        private readonly IFavouriteService _favouriteService;

        public FavouritesController(IFavouriteService service) : base(service)
        {
            _favouriteService = service;
        }

        [HttpGet]
        [Authorize]
        public override async Task<IActionResult> Get([FromQuery] FavouriteSearchObject search)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                            ?? User.FindFirst(System.IdentityModel.Tokens.Jwt.JwtRegisteredClaimNames.NameId)?.Value;

            if (userIdClaim == null || !int.TryParse(userIdClaim, out var userId))
                return Unauthorized();

            var isAdmin = User.IsInRole("Admin");
            if (!isAdmin)
                search.CandidateId = userId;

            var result = await _service.Get(search);
            return Ok(result);
        }

        [HttpPost]
        [Authorize]
        public override async Task<IActionResult> Post([FromBody] FavouriteInsertRequest request)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                            ?? User.FindFirst(System.IdentityModel.Tokens.Jwt.JwtRegisteredClaimNames.NameId)?.Value;

            if (userIdClaim == null || !int.TryParse(userIdClaim, out var userId))
                return Unauthorized();

            request.CandidateId = userId;

            var result = await _crudService.Insert(request);
            return Ok(result);
        }

        [HttpDelete("{id}")]
        [Authorize]
        public override async Task<IActionResult> Delete(int id)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                            ?? User.FindFirst(System.IdentityModel.Tokens.Jwt.JwtRegisteredClaimNames.NameId)?.Value;

            if (userIdClaim == null || !int.TryParse(userIdClaim, out var userId))
                return Unauthorized();

            var favourite = await _favouriteService.GetById(id);
            if (favourite == null)
                return NotFound();

            var isAdmin = User.IsInRole("Admin");
            if (!isAdmin && favourite.CandidateId != userId)
                return Forbid();

            await _crudService.Delete(id);
            return NoContent();
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public override async Task<IActionResult> Put(int id, [FromBody] FavouriteUpdateRequest request)
        {
            var result = await _crudService.Update(id, request);
            return Ok(result);
        }
    }
}