using System.ComponentModel.DataAnnotations;

namespace NiceSpeak.Admin.Entities;

/// <summary>
/// 角色-選單關聯
/// </summary>
public class RoleMenu
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();
    
    public Guid RoleId { get; set; }
    
    public Guid MenuId { get; set; }
    
    /// <summary>
    /// 是否可見
    /// </summary>
    public bool IsVisible { get; set; } = true;
    
    /// <summary>
    /// 是否可操作
    /// </summary>
    public bool CanOperate { get; set; } = false;
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    // 導航屬性
    public virtual Role? Role { get; set; }
    public virtual Menu? Menu { get; set; }
}
