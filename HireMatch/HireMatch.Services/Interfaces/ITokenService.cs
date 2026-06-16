using HireMatch.Services.Database;
namespace HireMatch.Services.Interfaces
{
    public interface ITokenService
    {
        string CreateToken(MyAppUser user);
    }
}