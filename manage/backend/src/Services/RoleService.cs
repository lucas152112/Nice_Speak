using Microsoft.EntityFrameworkCore;
using NiceSpeak.Admin.Data;
using NiceSpeak.Admin.Entities;
using NiceSpeak.Admin.Models.Dtos;

namespace NiceSpeak.Admin.Services;

/// <summary>
/// 角色服務
/// </summary>
public class RoleService
{
    private readonly AdminDbContext _context;
    
    public RoleService(AdminDbContext context)
    {
        _context = context;
    }
    
    /// <summary>
    /// 取得所有角色
    /// </summary>
    public async Task<List<RoleDto>> GetAllAsync()
    {
        return await _context.Roles
            .Where(r => r.IsActive)
            .OrderBy(r => r.Code)
            .Select(r => new RoleDto
            {
                Id = r.Id,
                Code = r.Code,
                Name = r.Name,
                Description = r.Description,
                CreatedAt = r.CreatedAt
            })
            .ToListAsync();
    }
    
    /// <summary>
    /// 依 ID 取得角色
    /// </summary>
    public async Task<RoleDto?> GetByIdAsync(Guid id)
    {
        return await _context.Roles
            .Where(r => r.Id == id && r.IsActive)
            .Select(r => new RoleDto
            {
                Id = r.Id,
                Code = r.Code,
                Name = r.Name,
                Description = r.Description,
                CreatedAt = r.CreatedAt
            })
            .FirstOrDefaultAsync();
    }
    
    /// <summary>
    /// 建立角色
    /// </summary>
    public async Task<RoleDto> CreateAsync(CreateRoleDto dto)
    {
        // 檢查 Code 是否存在
        if (await _context.Roles.AnyAsync(r => r.Code == dto.Code && r.IsActive))
        {
            throw new InvalidOperationException($"角色代碼 '{dto.Code}' 已存在");
        }
        
        var role = new Role
        {
            Code = dto.Code,
            Name = dto.Name,
            Description = dto.Description
        };
        
        _context.Roles.Add(role);
        await _context.SaveChangesAsync();
        
        return new RoleDto
        {
            Id = role.Id,
            Code = role.Code,
            Name = role.Name,
            Description = role.Description,
            CreatedAt = role.CreatedAt
        };
    }
    
    /// <summary>
    /// 更新角色
    /// </summary>
    public async Task<RoleDto?> UpdateAsync(Guid id, UpdateRoleDto dto)
    {
        var role = await _context.Roles.FindAsync(id);
        if (role == null || !role.IsActive)
        {
            return null;
        }
        
        // 檢查 Code 是否被其他角色使用
        if (dto.Code != role.Code && 
            await _context.Roles.AnyAsync(r => r.Code == dto.Code && r.IsActive && r.Id != id))
        {
            throw new InvalidOperationException($"角色代碼 '{dto.Code}' 已存在");
        }
        
        role.Code = dto.Code;
        role.Name = dto.Name;
        role.Description = dto.Description;
        role.UpdatedAt = DateTime.UtcNow;
        
        await _context.SaveChangesAsync();
        
        return new RoleDto
        {
            Id = role.Id,
            Code = role.Code,
            Name = role.Name,
            Description = role.Description,
            CreatedAt = role.CreatedAt
        };
    }
    
    /// <summary>
    /// 刪除角色 (軟刪除)
    /// </summary>
    public async Task<bool> DeleteAsync(Guid id)
    {
        var role = await _context.Roles.FindAsync(id);
        if (role == null || !role.IsActive)
        {
            return false;
        }
        
        role.IsActive = false;
        role.UpdatedAt = DateTime.UtcNow;
        
        await _context.SaveChangesAsync();
        return true;
    }
    
    /// <summary>
    /// 取得角色的權限
    /// </summary>
    public async Task<List<PermissionDto>> GetRolePermissionsAsync(Guid roleId)
    {
        return await _context.RolePermissions
            .Where(rp => rp.RoleId == roleId)
            .Include(rp => rp.Permission)
            .Where(rp => rp.Permission != null && rp.Permission.IsActive)
            .Select(rp => new PermissionDto
            {
                Id = rp.Permission!.Id,
                Code = rp.Permission.Code,
                Name = rp.Permission.Name,
                Description = rp.Permission.Description,
                ResourceType = rp.Permission.ResourceType,
                ResourcePath = rp.Permission.ResourcePath,
                HttpMethod = rp.Permission.HttpMethod
            })
            .ToListAsync();
    }
    
    /// <summary>
    /// 指派權限給角色
    /// </summary>
    public async Task AssignPermissionsAsync(Guid roleId, List<Guid> permissionIds)
    {
        var role = await _context.Roles.FindAsync(roleId);
        if (role == null || !role.IsActive)
        {
            throw new InvalidOperationException("角色不存在");
        }
        
        // 移除現有權限
        var existingPermissions = await _context.RolePermissions
            .Where(rp => rp.RoleId == roleId)
            .ToListAsync();
        _context.RolePermissions.RemoveRange(existingPermissions);
        
        // 新增權限
        var rolePermissions = permissionIds.Select(permissionId => new RolePermission
        {
            RoleId = roleId,
            PermissionId = permissionId
        }).ToList();
        _context.RolePermissions.AddRange(rolePermissions);
        
        await _context.SaveChangesAsync();
    }
}
