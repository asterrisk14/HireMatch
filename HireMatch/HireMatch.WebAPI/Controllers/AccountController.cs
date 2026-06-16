using HireMatch.Services.Interfaces;
using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Services.Database;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BCrypt.Net; // OVO JE KLJUČNO

namespace HireMatch.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class AccountController : ControllerBase
    {
        private readonly HireMatchDbContext _context; // Koristi specifičan tip umjesto DbContext
        private readonly ITokenService _tokenService;

        public AccountController(HireMatchDbContext context, ITokenService tokenService)
        {
            _context = context;
            _tokenService = tokenService;
        }

        [HttpPost("register")]
        [AllowAnonymous]
        public async Task<ActionResult<AuthResponse>> Register(RegisterRequest registerDto)
        {
            if (await _context.MyAppUsers.AnyAsync(x => x.Email == registerDto.Email))
                return BadRequest("Email is already in use");

            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                var user = new MyAppUser
                {
                    FirstName = registerDto.FirstName,
                    LastName = registerDto.LastName,
                    Email = registerDto.Email,
                    Phone = registerDto.Phone,
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword(registerDto.Password),
                    Role = "Candidate",
                    CountryId = registerDto.CountryId,
                    CityId = registerDto.CityId,
                    DateOfBirth = registerDto.DateOfBirth
                };

                _context.MyAppUsers.Add(user);
                await _context.SaveChangesAsync();

                // Kreiraj Candidate profil za novog korisnika
                var candidate = new Candidate
                {
                    MyAppUserId = user.Id,
                    CurrentTitle = string.Empty,
                    Summary = string.Empty,
                    LinkedInUrl = string.Empty,
                    PortfolioUrl = string.Empty,
                    CvUrl = string.Empty,
                    ProfilePictureUrl = string.Empty,
                    YearsOfExperience = 0
                };
                _context.Candidates.Add(candidate);
                await _context.SaveChangesAsync();

                await transaction.CommitAsync();

                return ToAuthResponse(user);
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }
        }
        [HttpPost("login")]
        [AllowAnonymous]
        public async Task<ActionResult<AuthResponse>> Login(LoginRequest loginDto)
        {
            var user = await _context.MyAppUsers.FirstOrDefaultAsync(x => x.Email == loginDto.Email);
            
            // PROVJERA HASHIRANE LOZINKE
            if (user == null || !BCrypt.Net.BCrypt.Verify(loginDto.Password, user.PasswordHash))
            {
                return Unauthorized("Invalid email or password");
            }

            return ToAuthResponse(user);
        }

        [HttpPost("change-password")]
        [Authorize]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request)
        {
            var userIdClaim = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value
                            ?? User.FindFirst("id")?.Value;

            if (userIdClaim == null || !int.TryParse(userIdClaim, out var userId))
                return Unauthorized();

            var user = await _context.MyAppUsers.FirstOrDefaultAsync(u => u.Id == userId);
            if (user == null) return NotFound();

            // PROVJERA I RE-HASHIRANJE
            if (!BCrypt.Net.BCrypt.Verify(request.CurrentPassword, user.PasswordHash))
                return BadRequest(new { message = "Trenutna lozinka nije ispravna." });

            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Lozinka je uspješno promijenjena." });
        }

        private AuthResponse ToAuthResponse(MyAppUser user)
        {
            return new AuthResponse
            {
                Id = user.Id,
                Email = user.Email,
                Token = _tokenService.CreateToken(user), 
                FirstName = user.FirstName,
                LastName = user.LastName,
                Role = user.Role,
                Phone = user.Phone ?? string.Empty,
                IsPremium = user.IsPremium,
                DateOfBirth = user.DateOfBirth // Pretpostavljam da ti je to polje u modelu MyAppUser
            };
        }
    }
}