namespace NiceSpeak.Admin.Models.Dtos;

/// <summary>
/// 選單 DTO
/// </summary>
public class MenuDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Icon { get; set; }
    public string? Path { get; set; }
    public Guid? ParentId { get; set; }
    public int SortOrder { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
    public List<MenuDto>? Children { get; set; }
}

/// <summary>
/// 建立選單 DTO
/// </summary>
public class CreateMenuDto
{
    [Required]
    [MaxLength(100)]
    public string Name { get; set; } = string.Empty;
    
    [MaxLength(255)]
    public string? Icon { get; set; }
    
    [MaxLength(255)]
    public string? Path { get; set; }
    
    public Guid? ParentId { get; set; }
    
    public int SortOrder { get; set; }
}

/// <summary>
/// 更新選單 DTO
/// </summary>
public class UpdateMenuDto
{
    [Required]
    [MaxLength(100)]
    public string Name { get; set; } = string.Empty;
    
    [MaxLength(255)]
    public string? Icon { get; set; }
    
    [MaxLength(255)]
    public string? Path { get; set; }
    
    public Guid? ParentId { get; set; }
    
    public int SortOrder { get; set; }
}

/// <summary>
/// 角色選單權限 DTO
/// </summary>
public class RoleMenuPermissionDto
{
    public Guid RoleId { get; set; }
    public List<Guid> MenuIds { get; set; } = new();
}
