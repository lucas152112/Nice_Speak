using Microsoft.EntityFrameworkCore;
using NiceSpeak.Admin.Data;
using NiceSpeak.Admin.Entities;
using NiceSpeak.Admin.Models.Dtos;

namespace NiceSpeak.Admin.Services;

/// <summary>
/// 權限服務
/// </summary>
public class PermissionService
{
    private readonly AdminDbContext _context;
    
    public PermissionService(AdminDbContext context)
    {
        _context = context;
    }
    
    /// <summary>
    /// 取得所有權限
    /// </summary>
    public async Task<List<PermissionDto>> GetAllAsync()
    {
        return await _context.Permissions
            .Where(p => p.IsActive)
            .OrderBy(p => p.SortOrder)
            .ThenBy(p => p.Code)
            .Select(p => new PermissionDto
            {
                Id = p.Id,
                Code = p.Code,
                Name = p.Name,
                Description = p.Description,
                ResourceType = p.ResourceType,
                ResourcePath = p.ResourcePath,
                HttpMethod = p.HttpMethod,
                SortOrder = p.SortOrder,
                IsActive = p.IsActive
            })
            .ToListAsync();
    }
    
    /// <summary>
    /// 依 ID 取得權限
    /// </summary>
    public async Task<PermissionDto?> GetByIdAsync(Guid id)
    {
        return await _context.Permissions
            .Where(p => p.Id == id && p.IsActive)
            .Select(p => new PermissionDto
            {
                Id = p.Id,
                Code = p.Code,
                Name = p.Name,
                Description = p.Description,
                ResourceType = p.ResourceType,
                ResourcePath = p.ResourcePath,
                HttpMethod = p.HttpMethod,
                SortOrder = p.SortOrder,
                IsActive = p.IsActive
            })
            .FirstOrDefaultAsync();
    }
    
    /// <summary>
    /// 建立權限
    /// </summary>
    public async Task<PermissionDto> CreateAsync(CreatePermissionDto dto)
    {
        if (await _context.Permissions.AnyAsync(p => p.Code == dto.Code && p.IsActive))
        {
            throw new InvalidOperationException($"權限代碼 '{dto.Code}' 已存在");
        }
        
        var permission = new Permission
        {
            Code = dto.Code,
            Name = dto.Name,
            Description = dto.Description,
            ResourceType = dto.ResourceType,
            ResourcePath = dto.ResourcePath,
            HttpMethod = dto.HttpMethod,
            SortOrder = dto.SortOrder
        };
        
        _context.Permissions.Add(permission);
        await _context.SaveChangesAsync();
        
        return new PermissionDto
        {
            Id = permission.Id,
            Code = permission.Code,
            Name = permission.Name,
            Description = permission.Description,
            ResourceType = permission.ResourceType,
            ResourcePath = permission.ResourcePath,
            HttpMethod = permission.HttpMethod,
            SortOrder = permission.SortOrder,
            IsActive = permission.IsActive
        };
    }
    
    /// <summary>
    /// 更新權限
    /// </summary>
    public async Task<PermissionDto?> UpdateAsync(Guid id, UpdatePermissionDto dto)
    {
        var permission = await _context.Permissions.FindAsync(id);
        if (permission == null || !permission.IsActive)
        {
            return null;
        }
        
        if (dto.Code != permission.Code && 
            await _context.Permissions.AnyAsync(p => p.Code == dto.Code && p.IsActive && p.Id != id))
        {
            throw new InvalidOperationException($"權限代碼 '{dto.Code}' 已存在");
        }
        
        permission.Code = dto.Code;
        permission.Name = dto.Name;
        permission.Description = dto.Description;
        permission.ResourceType = dto.ResourceType;
        permission.ResourcePath = dto.ResourcePath;
        permission.HttpMethod = dto.HttpMethod;
        permission.SortOrder = dto.SortOrder;
        
        await _context.SaveChangesAsync();
        
        return new PermissionDto
        {
            Id = permission.Id,
            Code = permission.Code,
            Name = permission.Name,
            Description = permission.Description,
            ResourceType = permission.ResourceType,
            ResourcePath = permission.ResourcePath,
            HttpMethod = permission.HttpMethod,
            SortOrder = permission.SortOrder,
            IsActive = permission.IsActive
        };
    }
    
    /// <summary>
    /// 刪除權限 (軟刪除)
    /// </summary>
    public async Task<bool> DeleteAsync(Guid id)
    {
        var permission = await _context.Permissions.FindAsync(id);
        if (permission == null || !permission.IsActive)
        {
            return false;
        }
        
        permission.IsActive = false;
        await _context.SaveChangesAsync();
        return true;
    }
}
