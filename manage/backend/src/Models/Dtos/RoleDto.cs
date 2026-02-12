namespace NiceSpeak.Admin.Models.Dtos;

/// <summary>
/// 角色 DTO
/// </summary>
public class RoleDto
{
    public Guid Id { get; set; }
    public string Code { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public DateTime CreatedAt { get; set; }
}

/// <summary>
/// 建立角色 DTO
/// </summary>
public class CreateRoleDto
{
    [Required]
    [MaxLength(50)]
    public string Code { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(100)]
    public string Name { get; set; } = string.Empty;
    
    [MaxLength(500)]
    public string? Description { get; set; }
}

/// <summary>
/// 更新角色 DTO
/// </summary>
public class UpdateRoleDto
{
    [Required]
    [MaxLength(50)]
    public string Code { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(100)]
    public string Name { get; set; } = string.Empty;
    
    [MaxLength(500)]
    public string? Description { get; set; }
}
