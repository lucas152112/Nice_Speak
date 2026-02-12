using Microsoft.EntityFrameworkCore;
using NiceSpeak.Admin.Data;
using NiceSpeak.Admin.Entities;
using NiceSpeak.Admin.Models.Dtos;

namespace NiceSpeak.Admin.Services;

/// <summary>
/// 選單服務
/// </summary>
public class MenuService
{
    private readonly AdminDbContext _context;
    
    public MenuService(AdminDbContext context)
    {
        _context = context;
    }
    
    /// <summary>
    /// 取得所有選單 (樹狀結構)
    /// </summary>
    public async Task<List<MenuDto>> GetTreeAsync()
    {
        var menus = await _context.Menus
            .Where(m => m.IsActive)
            .OrderBy(m => m.SortOrder)
            .ToListAsync();
            
        return BuildTree(menus, null);
    }
    
    /// <summary>
    /// 依 ID 取得選單
    /// </summary>
    public async Task<MenuDto?> GetByIdAsync(Guid id)
    {
        var menu = await _context.Menus.FindAsync(id);
        if (menu == null || !menu.IsActive)
        {
            return null;
        }
        
        return new MenuDto
        {
            Id = menu.Id,
            Name = menu.Name,
            Icon = menu.Icon,
            Path = menu.Path,
            ParentId = menu.ParentId,
            SortOrder = menu.SortOrder,
            IsActive = menu.IsActive,
            CreatedAt = menu.CreatedAt
        };
    }
    
    /// <summary>
    /// 建立選單
    /// </summary>
    public async Task<MenuDto> CreateAsync(CreateMenuDto dto)
    {
        var menu = new Menu
        {
            Name = dto.Name,
            Icon = dto.Icon,
            Path = dto.Path,
            ParentId = dto.ParentId,
            SortOrder = dto.SortOrder
        };
        
        _context.Menus.Add(menu);
        await _context.SaveChangesAsync();
        
        return new MenuDto
        {
            Id = menu.Id,
            Name = menu.Name,
            Icon = menu.Icon,
            Path = menu.Path,
            ParentId = menu.ParentId,
            SortOrder = menu.SortOrder,
            IsActive = menu.IsActive,
            CreatedAt = menu.CreatedAt
        };
    }
    
    /// <summary>
    /// 更新選單
    /// </summary>
    public async Task<MenuDto?> UpdateAsync(Guid id, UpdateMenuDto dto)
    {
        var menu = await _context.Menus.FindAsync(id);
        if (menu == null || !menu.IsActive)
        {
            return null;
        }
        
        menu.Name = dto.Name;
        menu.Icon = dto.Icon;
        menu.Path = dto.Path;
        menu.ParentId = dto.ParentId;
        menu.SortOrder = dto.SortOrder;
        menu.UpdatedAt = DateTime.UtcNow;
        
        await _context.SaveChangesAsync();
        
        return new MenuDto
        {
            Id = menu.Id,
            Name = menu.Name,
            Icon = menu.Icon,
            Path = menu.Path,
            ParentId = menu.ParentId,
            SortOrder = menu.SortOrder,
            IsActive = menu.IsActive,
            CreatedAt = menu.CreatedAt
        };
    }
    
    /// <summary>
    /// 刪除選單 (軟刪除)
    /// </summary>
    public async Task<bool> DeleteAsync(Guid id)
    {
        var menu = await _context.Menus.FindAsync(id);
        if (menu == null || !menu.IsActive)
        {
            return false;
        }
        
        menu.IsActive = false;
        menu.UpdatedAt = DateTime.UtcNow;
        
        await _context.SaveChangesAsync();
        return true;
    }
    
    /// <summary>
    /// 取得角色的選單權限
    /// </summary>
    public async Task<List<MenuDto>> GetRoleMenusAsync(Guid roleId)
    {
        var roleMenus = await _context.RoleMenus
            .Where(rm => rm.RoleId == roleId && rm.IsVisible)
            .Include(rm => rm.Menu)
            .Where(rm => rm.Menu != null && rm.Menu.IsActive)
            .Select(rm => rm.Menu!)
            .ToListAsync();
            
        return BuildTree(roleMenus, null);
    }
    
    /// <summary>
    /// 指派選單給角色
    /// </summary>
    public async Task AssignMenusAsync(Guid roleId, List<Guid> menuIds)
    {
        // 移除現有選單
        var existingMenus = await _context.RoleMenus
            .Where(rm => rm.RoleId == roleId)
            .ToListAsync();
        _context.RoleMenus.RemoveRange(existingMenus);
        
        // 新增選單
        var roleMenus = menuIds.Select(menuId => new RoleMenu
        {
            RoleId = roleId,
            MenuId = menuId,
            IsVisible = true
        }).ToList();
        _context.RoleMenus.AddRange(roleMenus);
        
        await _context.SaveChangesAsync();
    }
    
    /// <summary>
    /// 建立樹狀結構
    /// </summary>
    private List<MenuDto> BuildTree(List<Menu> menus, Guid? parentId)
    {
        return menus
            .Where(m => m.ParentId == parentId)
            .OrderBy(m => m.SortOrder)
            .Select(m => new MenuDto
            {
                Id = m.Id,
                Name = m.Name,
                Icon = m.Icon,
                Path = m.Path,
                ParentId = m.ParentId,
                SortOrder = m.SortOrder,
                IsActive = m.IsActive,
                CreatedAt = m.CreatedAt,
                Children = BuildTree(menus, m.Id)
            })
            .ToList();
    }
}
