namespace NiceSpeak.Admin.Models.Dtos;

/// <summary>
/// 權限 DTO
/// </summary>
public class PermissionDto
{
    public Guid Id { get; set; }
    public string Code { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string ResourceType { get; set; } = "api";
    public string? ResourcePath { get; set; }
    public string? HttpMethod { get; set; }
    public int SortOrder { get; set; }
    public bool IsActive { get; set; }
}

/// <summary>
/// 建立權限 DTO
/// </summary>
public class CreatePermissionDto
{
    [Required]
    [MaxLength(50)]
    public string Code { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(100)]
    public string Name { get; set; } = string.Empty;
    
    [MaxLength(500)]
    public string? Description { get; set; }
    
    [MaxLength(50)]
    public string ResourceType { get; set; } = "api";
    
    [MaxLength(255)]
    public string? ResourcePath { get; set; }
    
    [MaxLength(10)]
    public string? HttpMethod { get; set; }
    
    public int SortOrder { get; set; }
}

/// <summary>
/// 更新權限 DTO
/// </summary>
public class UpdatePermissionDto
{
    [Required]
    [MaxLength(50)]
    public string Code { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(100)]
    public string Name { get; set; } = string.Empty;
    
    [MaxLength(500)]
    public string? Description { get; set; }
    
    [MaxLength(50)]
    public string ResourceType { get; set; } = "api";
    
    [MaxLength(255)]
    public string? ResourcePath { get; set; }
    
    [MaxLength(10)]
    public string? HttpMethod { get; set; }
    
    public int SortOrder { get; set; }
}
