using Microsoft.AspNetCore.Mvc;
using NiceSpeak.Admin.Models.Dtos;
using NiceSpeak.Admin.Services;

namespace NiceSpeak.Admin.Controllers;

/// <summary>
/// 選單 API
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class MenusController : ControllerBase
{
    private readonly MenuService _menuService;
    
    public MenusController(MenuService menuService)
    {
        _menuService = menuService;
    }
    
    /// <summary>
    /// 取得所有選單 (樹狀結構)
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<List<MenuDto>>> GetTree()
    {
        var menus = await _menuService.GetTreeAsync();
        return Ok(menus);
    }
    
    /// <summary>
    /// 依 ID 取得選單
    /// </summary>
    [HttpGet("{id:guid}")]
    public async Task<ActionResult<MenuDto>> GetById(Guid id)
    {
        var menu = await _menuService.GetByIdAsync(id);
        if (menu == null)
        {
            return NotFound();
        }
        return Ok(menu);
    }
    
    /// <summary>
    /// 建立選單
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<MenuDto>> Create([FromBody] CreateMenuDto dto)
    {
        var menu = await _menuService.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = menu.Id }, menu);
    }
    
    /// <summary>
    /// 更新選單
    /// </summary>
    [HttpPut("{id:guid}")]
    public async Task<ActionResult<MenuDto>> Update(Guid id, [FromBody] UpdateMenuDto dto)
    {
        var menu = await _menuService.UpdateAsync(id, dto);
        if (menu == null)
        {
            return NotFound();
        }
        return Ok(menu);
    }
    
    /// <summary>
    /// 刪除選單
    /// </summary>
    [HttpDelete("{id:guid}")]
    public async Task<ActionResult> Delete(Guid id)
    {
        var result = await _menuService.DeleteAsync(id);
        if (!result)
        {
            return NotFound();
        }
        return NoContent();
    }
    
    /// <summary>
    /// 取得角色的選單
    /// </summary>
    [HttpGet("role/{roleId:guid}")]
    public async Task<ActionResult<List<MenuDto>>> GetRoleMenus(Guid roleId)
    {
        var menus = await _menuService.GetRoleMenusAsync(roleId);
        return Ok(menus);
    }
    
    /// <summary>
    /// 指派選單給角色
    /// </summary>
    [HttpPost("role/{roleId:guid}")]
    public async Task<ActionResult> AssignMenus(Guid roleId, [FromBody] List<Guid> menuIds)
    {
        await _menuService.AssignMenusAsync(roleId, menuIds);
        return NoContent();
    }
}
