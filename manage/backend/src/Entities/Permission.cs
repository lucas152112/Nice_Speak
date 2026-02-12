using System.ComponentModel.DataAnnotations;

namespace NiceSpeak.Admin.Entities;

/// <summary>
/// 權限實體
/// </summary>
public class Permission
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();
    
    [Required]
    [MaxLength(50)]
    public string Code { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(100)]
    public string Name { get; set; } = string.Empty;
    
    [MaxLength(500)]
    public string? Description { get; set; }
    
    /// <summary>
    /// 資源類型 (controller, api, page)
    /// </summary>
    [MaxLength(50)]
    public string ResourceType { get; set; } = "api";
    
    /// <summary>
    /// 資源路徑
    /// </summary>
    [MaxLength(255)]
    public string? ResourcePath { get; set; }
    
    /// <summary>
    /// HTTP 方法 (GET, POST, PUT, DELETE)
    /// </summary>
    [MaxLength(10)]
    public string? HttpMethod { get; set; }
    
    public int SortOrder { get; set; } = 0;
    
    public bool IsActive { get; set; } = true;
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    // 導航屬性
    public virtual ICollection<RolePermission> RolePermissions { get; set; } = new List<RolePermission>();
}
