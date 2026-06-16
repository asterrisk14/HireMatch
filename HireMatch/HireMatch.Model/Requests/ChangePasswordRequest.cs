using System.ComponentModel.DataAnnotations;

namespace HireMatch.Model.Requests
{
    public class ChangePasswordRequest
    {
        [Required(ErrorMessage = "You must provide your current password.")]
        public string CurrentPassword { get; set; } = default!;

        [Required(ErrorMessage = "You must provide a new password.")]
        [MinLength(6, ErrorMessage = "The new password must have at least 6 characters.")]
        public string NewPassword { get; set; } = default!;
    }
}