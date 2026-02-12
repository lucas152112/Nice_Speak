using System.ComponentModel.DataAnnotations;

namespace NiceSpeak.Admin.Entities;

/// <summary>
/// 用戶實體
/// </summary>
public class User
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();
    
    [Required]
    [MaxLength(100)]
    public string Username { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(255)]
    public string Email { get; set; } = string.Empty;
    
    [Required]
    public string PasswordHash { get; set; } = string.Empty;
    
    [MaxLength(100)]
    public string? DisplayName { get; set; }
    
    [MaxLength(255)]
    public string? AvatarUrl { get; set; }
    
    public bool IsActive { get; set; } = true;
    
    public bool IsLocked { get; set; } = false;
    
    public DateTime? LastLoginAt { get; set; }
    
    public int LoginAttempts { get; set; } = 0;
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    public DateTime? UpdatedAt { get; set; }
    
    // 導航屬性
    public virtual ICollection<UserRole> UserRoles { get; set; } = new List<UserRole>();
}
