using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Interfaces;

namespace HireMatch.Services
{
    public interface ICompanyService : IBaseCRUDService<CompanyResponse, CompanySearchObject, CompanyInsertRequest, CompanyUpdateRequest>
    {
    }
}
