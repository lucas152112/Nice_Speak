namespace NiceSpeak.Admin.Models.Dtos;

/// <summary>
/// 用戶 DTO
/// </summary>
public class UserDto
{
    public Guid Id { get; set; }
    public string Username { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? DisplayName { get; set; }
    public string? AvatarUrl { get; set; }
    public bool IsActive { get; set; }
    public DateTime? LastLoginAt { get; set; }
    public DateTime CreatedAt { get; set; }
    public List<RoleDto>? Roles { get; set; }
}

/// <summary>
/// 建立用戶 DTO
/// </summary>
public class CreateUserDto
{
    [Required]
    [MaxLength(100)]
    public string Username { get; set; } = string.Empty;
    
    [Required]
    [EmailAddress]
    [MaxLength(255)]
    public string Email { get; set; } = string.Empty;
    
    [Required]
    [MinLength(6)]
    public string Password { get; set; } = string.Empty;
    
    [MaxLength(100)]
    public string? DisplayName { get; set; }
}

/// <summary>
/// 更新用戶 DTO
/// </summary>
public class UpdateUserDto
{
    [Required]
    [MaxLength(100)]
    public string Username { get; set; } = string.Empty;
    
    [Required]
    [EmailAddress]
    [MaxLength(255)]
    public string Email { get; set; } = string.Empty;
    
    [MaxLength(100)]
    public string? DisplayName { get; set; }
    
    [MaxLength(255)]
    public string? AvatarUrl { get; set; }
}

/// <summary>
/// 用戶角色 DTO
/// </summary>
public class UserRoleDto
{
    public Guid UserId { get; set; }
    public List<Guid> RoleIds { get; set; } = new();
}
