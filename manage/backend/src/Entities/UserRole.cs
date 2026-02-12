using System.ComponentModel.DataAnnotations;

namespace NiceSpeak.Admin.Entities;

/// <summary>
/// 用戶-角色關聯
/// </summary>
public class UserRole
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();
    
    public Guid UserId { get; set; }
    
    public Guid RoleId { get; set; }
    
    public DateTime AssignedAt { get; set; } = DateTime.UtcNow;
    
    public Guid? AssignedBy { get; set; }
    
    // 導航屬性
    public virtual User? User { get; set; }
    public virtual Role? Role { get; set; }
}
