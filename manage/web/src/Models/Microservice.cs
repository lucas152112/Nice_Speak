namespace NiceSpeak.Admin.Web.Models;

/// <summary>
/// 微服務實體
/// </summary>
public class Microservice
{
    public Guid Id { get; set; } = Guid.NewGuid();
    
    /// <summary>
    /// 服務名稱
    /// </summary>
    public string Name { get; set; } = string.Empty;
    
    /// <summary>
    /// 服務描述
    /// </summary>
    public string? Description { get; set; }
    
    /// <summary>
    /// 服務目錄路徑
    /// </summary>
    public string DirectoryPath { get; set; } = string.Empty;
    
    /// <summary>
    /// 服務類型 (api, web, worker, etc.)
    /// </summary>
    public string ServiceType { get; set; } = "api";
    
    /// <summary>
    /// 運行端口
    /// </summary>
    public int? Port { get; set; }
    
    /// <summary>
    /// 運行狀態 (stopped, running, error)
    /// </summary>
    public string Status { get; set; } = "stopped";
    
    /// <summary>
    /// 是否自動重啟
    /// </summary>
    public bool AutoRestart { get; set; } = false;
    
    /// <summary>
    /// 健康檢查 URL
    /// </summary>
    public string? HealthCheckUrl { get; set; }
    
    /// <summary>
    /// 上次部署時間
    /// </summary>
    public DateTime? LastDeployAt { get; set; }
    
    /// <summary>
    /// 上次狀態變更時間
    /// </summary>
    public DateTime? LastStatusChangeAt { get; set; }
    
    /// <summary>
    /// 建立時間
    /// </summary>
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    /// <summary>
    /// 更新時間
    /// </summary>
    public DateTime? UpdatedAt { get; set; }
}

/// <summary>
/// 微服務操作日誌
/// </summary>
public class MicroserviceLog
{
    public Guid Id { get; set; } = Guid.NewGuid();
    
    public Guid MicroserviceId { get; set; }
    
    public string Action { get; set; } = string.Empty;
    
    public string? Message { get; set; }
    
    public bool IsSuccess { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
