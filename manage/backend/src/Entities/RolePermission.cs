using System.ComponentModel.DataAnnotations;

namespace NiceSpeak.Admin.Entities;

/// <summary>
/// 角色-權限關聯
/// </summary>
public class RolePermission
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();
    
    public Guid RoleId { get; set; }
    
    public Guid PermissionId { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    // 導航屬性
    public virtual Role? Role { get; set; }
    public virtual Permission? Permission { get; set; }
}
