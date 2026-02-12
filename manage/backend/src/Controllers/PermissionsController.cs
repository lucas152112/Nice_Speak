using Microsoft.AspNetCore.Mvc;
using NiceSpeak.Admin.Models.Dtos;
using NiceSpeak.Admin.Services;

namespace NiceSpeak.Admin.Controllers;

/// <summary>
/// 權限 API
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class PermissionsController : ControllerBase
{
    private readonly PermissionService _permissionService;
    
    public PermissionsController(PermissionService permissionService)
    {
        _permissionService = permissionService;
    }
    
    /// <summary>
    /// 取得所有權限
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<List<PermissionDto>>> GetAll()
    {
        var permissions = await _permissionService.GetAllAsync();
        return Ok(permissions);
    }
    
    /// <summary>
    /// 依 ID 取得權限
    /// </summary>
    [HttpGet("{id:guid}")]
    public async Task<ActionResult<PermissionDto>> GetById(Guid id)
    {
        var permission = await _permissionService.GetByIdAsync(id);
        if (permission == null)
        {
            return NotFound();
        }
        return Ok(permission);
    }
    
    /// <summary>
    /// 建立權限
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<PermissionDto>> Create([FromBody] CreatePermissionDto dto)
    {
        try
        {
            var permission = await _permissionService.CreateAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = permission.Id }, permission);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ex.Message);
        }
    }
    
    /// <summary>
    /// 更新權限
    /// </summary>
    [HttpPut("{id:guid}")]
    public async Task<ActionResult<PermissionDto>> Update(Guid id, [FromBody] UpdatePermissionDto dto)
    {
        try
        {
            var permission = await _permissionService.UpdateAsync(id, dto);
            if (permission == null)
            {
                return NotFound();
            }
            return Ok(permission);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ex.Message);
        }
    }
    
    /// <summary>
    /// 刪除權限
    /// </summary>
    [HttpDelete("{id:guid}")]
    public async Task<ActionResult> Delete(Guid id)
    {
        var result = await _permissionService.DeleteAsync(id);
        if (!result)
        {
            return NotFound();
        }
        return NoContent();
    }
}
