using Microsoft.EntityFrameworkCore;
using NiceSpeak.Admin.Entities;

namespace NiceSpeak.Admin.Data;

/// <summary>
/// 資料庫上下文
/// </summary>
public class AdminDbContext : DbContext
{
    public AdminDbContext(DbContextOptions<AdminDbContext> options)
        : base(options)
    {
    }
    
    // DbSets
    public DbSet<User> Users { get; set; } = null!;
    public DbSet<Role> Roles { get; set; } = null!;
    public DbSet<Permission> Permissions { get; set; } = null!;
    public DbSet<Menu> Menus { get; set; } = null!;
    public DbSet<UserRole> UserRoles { get; set; } = null!;
    public DbSet<RolePermission> RolePermissions { get; set; } = null!;
    public DbSet<RoleMenu> RoleMenus { get; set; } = null!;
    
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        
        // User
        modelBuilder.Entity<User>(entity =>
        {
            entity.HasIndex(e => e.Username).IsUnique();
            entity.HasIndex(e => e.Email).IsUnique();
        });
        
        // Role
        modelBuilder.Entity<Role>(entity =>
        {
            entity.HasIndex(e => e.Code).IsUnique();
        });
        
        // Permission
        modelBuilder.Entity<Permission>(entity =>
        {
            entity.HasIndex(e => e.Code).IsUnique();
        });
        
        // Menu
        modelBuilder.Entity<Menu>(entity =>
        {
            entity.HasOne(e => e.Parent)
                .WithMany(e => e.Children)
                .HasForeignKey(e => e.ParentId)
                .OnDelete(DeleteBehavior.Restrict);
        });
        
        // UserRole (Composite Key)
        modelBuilder.Entity<UserRole>(entity =>
        {
            entity.HasIndex(e => new { e.UserId, e.RoleId }).IsUnique();
            entity.HasOne(e => e.User)
                .WithMany(u => u.UserRoles)
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Cascade);
            entity.HasOne(e => e.Role)
                .WithMany(r => r.Users)
                .HasForeignKey(e => e.RoleId)
                .OnDelete(DeleteBehavior.Cascade);
        });
        
        // RolePermission (Composite Key)
        modelBuilder.Entity<RolePermission>(entity =>
        {
            entity.HasIndex(e => new { e.RoleId, e.PermissionId }).IsUnique();
            entity.HasOne(e => e.Role)
                .WithMany(r => r.RolePermissions)
                .HasForeignKey(e => e.RoleId)
                .OnDelete(DeleteBehavior.Cascade);
            entity.HasOne(e => e.Permission)
                .WithMany(p => p.RolePermissions)
                .HasForeignKey(e => e.PermissionId)
                .OnDelete(DeleteBehavior.Cascade);
        });
        
        // RoleMenu (Composite Key)
        modelBuilder.Entity<RoleMenu>(entity =>
        {
            entity.HasIndex(e => new { e.RoleId, e.MenuId }).IsUnique();
            entity.HasOne(e => e.Role)
                .WithMany(r => r.RoleMenus)
                .HasForeignKey(e => e.RoleId)
                .OnDelete(DeleteBehavior.Cascade);
            entity.HasOne(e => e.Menu)
                .WithMany(m => m.RoleMenus)
                .HasForeignKey(e => e.MenuId)
                .OnDelete(DeleteBehavior.Cascade);
        });
    }
}
