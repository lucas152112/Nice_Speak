using Microsoft.EntityFrameworkCore;
using NiceSpeak.Admin.Data;
using NiceSpeak.Admin.Entities;
using NiceSpeak.Admin.Models.Dtos;
using System.Security.Cryptography;
using System.Text;

namespace NiceSpeak.Admin.Services;

/// <summary>
/// 用戶服務
/// </summary>
public class UserService
{
    private readonly AdminDbContext _context;
    
    public UserService(AdminDbContext context)
    {
        _context = context;
    }
    
    /// <summary>
    /// 取得所有用戶
    /// </summary>
    public async Task<List<UserDto>> GetAllAsync()
    {
        return await _context.Users
            .Where(u => u.IsActive)
            .OrderByDescending(u => u.CreatedAt)
            .Select(u => new UserDto
            {
                Id = u.Id,
                Username = u.Username,
                Email = u.Email,
                DisplayName = u.DisplayName,
                AvatarUrl = u.AvatarUrl,
                IsActive = u.IsActive,
                LastLoginAt = u.LastLoginAt,
                CreatedAt = u.CreatedAt
            })
            .ToListAsync();
    }
    
    /// <summary>
    /// 依 ID 取得用戶
    /// </summary>
    public async Task<UserDto?> GetByIdAsync(Guid id)
    {
        return await _context.Users
            .Where(u => u.Id == id && u.IsActive)
            .Select(u => new UserDto
            {
                Id = u.Id,
                Username = u.Username,
                Email = u.Email,
                DisplayName = u.DisplayName,
                AvatarUrl = u.AvatarUrl,
                IsActive = u.IsActive,
                LastLoginAt = u.LastLoginAt,
                CreatedAt = u.CreatedAt
            })
            .FirstOrDefaultAsync();
    }
    
    /// <summary>
    /// 建立用戶
    /// </summary>
    public async Task<UserDto> CreateAsync(CreateUserDto dto)
    {
        if (await _context.Users.AnyAsync(u => u.Username == dto.Username && u.IsActive))
        {
            throw new InvalidOperationException($"用戶名稱 '{dto.Username}' 已存在");
        }
        
        if (await _context.Users.AnyAsync(u => u.Email == dto.Email && u.IsActive))
        {
            throw new InvalidOperationException($"Email '{dto.Email}' 已存在");
        }
        
        var user = new User
        {
            Username = dto.Username,
            Email = dto.Email,
            PasswordHash = HashPassword(dto.Password),
            DisplayName = dto.DisplayName
        };
        
        _context.Users.Add(user);
        await _context.SaveChangesAsync();
        
        return new UserDto
        {
            Id = user.Id,
            Username = user.Username,
            Email = user.Email,
            DisplayName = user.DisplayName,
            AvatarUrl = user.AvatarUrl,
            IsActive = user.IsActive,
            CreatedAt = user.CreatedAt
        };
    }
    
    /// <summary>
    /// 更新用戶
    /// </summary>
    public async Task<UserDto?> UpdateAsync(Guid id, UpdateUserDto dto)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null || !user.IsActive)
        {
            return null;
        }
        
        if (dto.Username != user.Username && 
            await _context.Users.AnyAsync(u => u.Username == dto.Username && u.IsActive && u.Id != id))
        {
            throw new InvalidOperationException($"用戶名稱 '{dto.Username}' 已存在");
        }
        
        user.Username = dto.Username;
        user.Email = dto.Email;
        user.DisplayName = dto.DisplayName;
        user.AvatarUrl = dto.AvatarUrl;
        user.UpdatedAt = DateTime.UtcNow;
        
        await _context.SaveChangesAsync();
        
        return new UserDto
        {
            Id = user.Id,
            Username = user.Username,
            Email = user.Email,
            DisplayName = user.DisplayName,
            AvatarUrl = user.AvatarUrl,
            IsActive = user.IsActive,
            CreatedAt = user.CreatedAt
        };
    }
    
    /// <summary>
    /// 刪除用戶 (軟刪除)
    /// </summary>
    public async Task<bool> DeleteAsync(Guid id)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null || !user.IsActive)
        {
            return false;
        }
        
        user.IsActive = false;
        user.UpdatedAt = DateTime.UtcNow;
        
        await _context.SaveChangesAsync();
        return true;
    }
    
    /// <summary>
    /// 取得用戶的角色
    /// </summary>
    public async Task<List<RoleDto>> GetUserRolesAsync(Guid userId)
    {
        return await _context.UserRoles
            .Where(ur => ur.UserId == userId)
            .Include(ur => ur.Role)
            .Where(ur => ur.Role != null && ur.Role.IsActive)
            .Select(ur => new RoleDto
            {
                Id = ur.Role!.Id,
                Code = ur.Role.Code,
                Name = ur.Role.Name,
                Description = ur.Role.Description,
                CreatedAt = ur.Role.CreatedAt
            })
            .ToListAsync();
    }
    
    /// <summary>
    /// 指派角色給用戶
    /// </summary>
    public async Task AssignRolesAsync(Guid userId, List<Guid> roleIds)
    {
        var user = await _context.Users.FindAsync(userId);
        if (user == null || !user.IsActive)
        {
            throw new InvalidOperationException("用戶不存在");
        }
        
        // 移除現有角色
        var existingRoles = await _context.UserRoles
            .Where(ur => ur.UserId == userId)
            .ToListAsync();
        _context.UserRoles.RemoveRange(existingRoles);
        
        // 新增角色
        var userRoles = roleIds.Select(roleId => new UserRole
        {
            UserId = userId,
            RoleId = roleId
        }).ToList();
        _context.UserRoles.AddRange(userRoles);
        
        await _context.SaveChangesAsync();
    }
    
    /// <summary>
    /// 重設密碼
    /// </summary>
    public async Task ResetPasswordAsync(Guid id, string newPassword)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null || !user.IsActive)
        {
            throw new InvalidOperationException("用戶不存在");
        }
        
        user.PasswordHash = HashPassword(newPassword);
        user.UpdatedAt = DateTime.UtcNow();
        
        await _context.SaveChangesAsync();
    }
    
    /// <summary>
    /// 密碼加密
    /// </summary>
    private static string HashPassword(string password)
    {
        using var sha256 = SHA256.Create();
        var salt = "NiceSpeak.Admin"; // 實際應使用隨機鹽
        var bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password + salt));
        return Convert.ToBase64String(bytes);
    }
}
