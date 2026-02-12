using Microsoft.AspNetCore.Mvc;
using NiceSpeak.Admin.Models.Dtos;
using NiceSpeak.Admin.Services;

namespace NiceSpeak.Admin.Controllers;

/// <summary>
/// 用戶 API
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    private readonly UserService _userService;
    
    public UsersController(UserService userService)
    {
        _userService = userService;
    }
    
    /// <summary>
    /// 取得所有用戶
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<List<UserDto>>> GetAll()
    {
        var users = await _userService.GetAllAsync();
        return Ok(users);
    }
    
    /// <summary>
    /// 依 ID 取得用戶
    /// </summary>
    [HttpGet("{id:guid}")]
    public async Task<ActionResult<UserDto>> GetById(Guid id)
    {
        var user = await _userService.GetByIdAsync(id);
        if (user == null)
        {
            return NotFound();
        }
        return Ok(user);
    }
    
    /// <summary>
    /// 建立用戶
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<UserDto>> Create([FromBody] CreateUserDto dto)
    {
        try
        {
            var user = await _userService.CreateAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = user.Id }, user);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ex.Message);
        }
    }
    
    /// <summary>
    /// 更新用戶
    /// </summary>
    [HttpPut("{id:guid}")]
    public async Task<ActionResult<UserDto>> Update(Guid id, [FromBody] UpdateUserDto dto)
    {
        try
        {
            var user = await _userService.UpdateAsync(id, dto);
            if (user == null)
            {
                return NotFound();
            }
            return Ok(user);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ex.Message);
        }
    }
    
    /// <summary>
    /// 刪除用戶
    /// </summary>
    [HttpDelete("{id:guid}")]
    public async Task<ActionResult> Delete(Guid id)
    {
        var result = await _userService.DeleteAsync(id);
        if (!result)
        {
            return NotFound();
        }
        return NoContent();
    }
    
    /// <summary>
    /// 取得用戶的角色
    /// </summary>
    [HttpGet("{id:guid}/roles")]
    public async Task<ActionResult<List<RoleDto>>> GetUserRoles(Guid id)
    {
        var roles = await _userService.GetUserRolesAsync(id);
        return Ok(roles);
    }
    
    /// <summary>
    /// 指派角色給用戶
    /// </summary>
    [HttpPost("{id:guid}/roles")]
    public async Task<ActionResult> AssignRoles(Guid id, [FromBody] List<Guid> roleIds)
    {
        await _userService.AssignRolesAsync(id, roleIds);
        return NoContent();
    }
    
    /// <summary>
    /// 重設密碼
    /// </summary>
    [HttpPost("{id:guid}/reset-password")]
    public async Task<ActionResult> ResetPassword(Guid id, [FromBody] string newPassword)
    {
        try
        {
            await _userService.ResetPasswordAsync(id, newPassword);
            return NoContent();
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ex.Message);
        }
    }
}
