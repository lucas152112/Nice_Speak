using Microsoft.AspNetCore.Mvc;
using NiceSpeak.Admin.Models.Dtos;
using NiceSpeak.Admin.Services;

namespace NiceSpeak.Admin.Controllers;

/// <summary>
/// 角色 API
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class RolesController : ControllerBase
{
    private readonly RoleService _roleService;
    
    public RolesController(RoleService roleService)
    {
        _roleService = roleService;
    }
    
    /// <summary>
    /// 取得所有角色
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<List<RoleDto>>> GetAll()
    {
        var roles = await _roleService.GetAllAsync();
        return Ok(roles);
    }
    
    /// <summary>
    /// 依 ID 取得角色
    /// </summary>
    [HttpGet("{id:guid}")]
    public async Task<ActionResult<RoleDto>> GetById(Guid id)
    {
        var role = await _roleService.GetByIdAsync(id);
        if (role == null)
        {
            return NotFound();
        }
        return Ok(role);
    }
    
    /// <summary>
    /// 建立角色
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<RoleDto>> Create([FromBody] CreateRoleDto dto)
    {
        try
        {
            var role = await _roleService.CreateAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = role.Id }, role);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ex.Message);
        }
    }
    
    /// <summary>
    /// 更新角色
    /// </summary>
    [HttpPut("{id:guid}")]
    public async Task<ActionResult<RoleDto>> Update(Guid id, [FromBody] UpdateRoleDto dto)
    {
        try
        {
            var role = await _roleService.UpdateAsync(id, dto);
            if (role == null)
            {
                return NotFound();
            }
            return Ok(role);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ex.Message);
        }
    }
    
    /// <summary>
    /// 刪除角色
    /// </summary>
    [HttpDelete("{id:guid}")]
    public async Task<ActionResult> Delete(Guid id)
    {
        var result = await _roleService.DeleteAsync(id);
        if (!result)
        {
            return NotFound();
        }
        return NoContent();
    }
    
    /// <summary>
    /// 取得角色的權限
    /// </summary>
    [HttpGet("{id:guid}/permissions")]
    public async Task<ActionResult<List<PermissionDto>>> GetRolePermissions(Guid id)
    {
        var permissions = await _roleService.GetRolePermissionsAsync(id);
        return Ok(permissions);
    }
    
    /// <summary>
    /// 指派權限給角色
    /// </summary>
    [HttpPost("{id:guid}/permissions")]
    public async Task<ActionResult> AssignPermissions(Guid id, [FromBody] List<Guid> permissionIds)
    {
        try
        {
            await _roleService.AssignPermissionsAsync(id, permissionIds);
            return NoContent();
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ex.Message);
        }
    }
}
