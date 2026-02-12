using System.ComponentModel.DataAnnotations;

namespace NiceSpeak.Admin.Entities;

/// <summary>
/// 選單實體
/// </summary>
public class Menu
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();
    
    [Required]
    [MaxLength(100)]
    public string Name { get; set; } = string.Empty;
    
    [MaxLength(255)]
    public string? Icon { get; set; }
    
    [MaxLength(255)]
    public string? Path { get; set; }
    
    public Guid? ParentId { get; set; }
    
    public int SortOrder { get; set; } = 0;
    
    public bool IsActive { get; set; } = true;
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    public DateTime? UpdatedAt { get; set; }
    
    // 導航屬性
    public virtual Menu? Parent { get; set; }
    public virtual ICollection<Menu> Children { get; set; } = new List<Menu>();
    public virtual ICollection<RoleMenu> RoleMenus { get; set; } = new List<RoleMenu>();
}
