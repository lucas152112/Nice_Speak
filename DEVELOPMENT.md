# OpenClaw Rust 重構開發規則

## 概述

本文檔定義 OpenClaw Rust 重構專案的開發原則、規範和流程。

---

## 開發原則

### 1. 永不崩潰 (Zero Crash)

| 原則 | 說明 |
|------|------|
| Panic 處理 | 所有可能的錯誤必須有明確的處理邏輯 |
| 優雅降級 | 任何模組故障不能影響系統整體運作 |
| 自動恢復 | 服務必須具備自我修復能力 |

### 2. 多工能力 (Concurrency)

| 原則 | 說明 |
|------|------|
| Actor 模型 | 使用 Actor 模式處理並發訊息 |
| 非阻塞 I/O | 所有 I/O 操作必須非阻塞 |
| 工作窃取 | 支援工作負荷自動平衡 |

### 3. 通訊能力 (Communication)

| 原則 | 說明 |
|------|------|
| 統一 Broker | 所有模組透過 Message Broker 溝通 |
| 異步優先 | 優先使用異步通訊模式 |
| 熔斷保護 | 外部服務故障不能拖垮系統 |

### 4. 預警機制 (Early Warning)

| 原則 | 說明 |
|------|------|
| 主動監控 | 系統狀態即時監控 |
| 閾值警報 | 異常情況自動警報 |
| 結構化日誌 | 便於問題追蹤和分析 |

---

## 程式碼規範

### Rust 編碼風格

```rust
// ✅ 好的範例
async fn process_message(message: &Message) -> Result<ProcessingResult> {
    // 1. 驗證輸入
    validate_input(message)?;
    
    // 2. 處理業務
    let result = execute_business_logic(message).await?;
    
    // 3. 記錄日誌
    tracing::info!(message_id = %message.id, "Message processed");
    
    Ok(result)
}

// ❌ 不好的範例
fn process_message(message: &Message) -> Result<ProcessingResult> {
    let result = execute_business_logic(message)?; // 沒有驗證、沒有日誌
    Ok(result)
}
```

### 錯誤處理

```rust
// ✅ 使用 thiserror 定義明確的錯誤類型
#[derive(Debug, thiserror::Error)]
pub enum ServiceError {
    #[error("Connection failed: {source}")]
    ConnectionError { source: std::io::Error },
    
    #[error("Timeout after {timeout_ms}ms")]
    Timeout { timeout_ms: u64 },
    
    #[error("Invalid input: {reason}")]
    ValidationError { reason: String },
}

// ✅ 錯誤必須可恢復
fn resilient_operation() -> Result<T> {
    retry_with_backoff(|| operation()).await
}
```

### 測試覆蓋

| 測試類型 | 覆蓋率目標 |
|----------|-----------|
| 單元測試 | ≥ 80% |
| 整合測試 | ≥ 60% |
| 端到端測試 | 核心流程 100% |

---

## Git 分支策略

```
main (主分支)
├── dev (開發環境)
│   ├── feature/xxx (功能分支)
│   └── fix/xxx (修復分支)
├── test (測試環境)
│   ├── feature/xxx
│   └── fix/xxx
├── pp (預發布)
│   ├── feature/xxx
│   └── fix/xxx
└── prod (生產環境)
    └── hotfix/xxx
```

### 合併規則

| 來源 | 目標 | 說明 |
|------|------|------|
| feature/xxx | dev | 新功能開發 |
| dev | test | 功能完成 |
| test | pp | 測試通過 |
| pp | prod | 預發布驗證 |
| hotfix/xxx | prod | 緊急修復 |

---

## 提交規範

### 提交訊息格式

```
<類型>(<範圍>): <描述>

[可選的正文]

[可選的結語]
```

### 類型

| 類型 | 說明 |
|------|------|
| feat | 新功能 |
| fix | 錯誤修復 |
| refactor | 重構 |
| docs | 文件更新 |
| test | 測試相關 |
| chore | 建置/工具 |

### 範例

```
feat(actor): Add message queue for actor communication

- Implement async message passing
- Add queue size monitoring
- Support priority messages

Closes #123
```

---

## 模組依賴規則

### 依賴方向

```
Core (核心)
    │
    ▼
Communication (通訊) ──► Message Broker
    │
    ▼
Tools (工具)
    │
    ▼
Stability (穩定性)
    │
    ▼
Monitoring (監控)
```

### 禁止依賴

| 禁止 | 原因 |
|------|------|
| 循環依賴 | 導致編譯問題 |
| 上層依賴下層 | 破壞架構清晰度 |
| 外部未驗證套件 | 安全風險 |

---

## 部署規範

### 環境對應

| 環境 | 分支 | 配置檔 |
|------|------|--------|
| 開發 | dev | config/dev.toml |
| 測試 | test | config/test.toml |
| 預發布 | pp | config/staging.toml |
| 生產 | prod | config/prod.toml |

### 部署原則

1. **不可變基礎設施**
   - Docker 映像不可變
   - 配置外部化
   - 環境隔離

2. **漸進式部署**
   - 金絲雀發布
   - 自動回滾
   - 健康檢查

---

## 監控指標

### 系統指標

| 指標 | 閾值 | 警報級別 |
|------|------|----------|
| 記憶體使用率 | > 80% | Warning |
| CPU 使用率 | > 90% | Warning |
| 回應時間 P99 | > 500ms | Warning |
| 錯誤率 | > 1% | Critical |
| 可用性 | < 99.9% | Critical |

### 業務指標

| 指標 | 說明 |
|------|------|
| 訊息處理量 | 每秒處理訊息數 |
| 併發連線數 | 同時連線數 |
| 佇列深度 | 待處理訊息數 |
| 重試次數 | 失敗重試次數 |

---

## 安全規範

### 敏感資料

| 類型 | 處理方式 |
|------|----------|
| API Key | 環境變數 |
| 密碼 | bcrypt 加密 |
| Token | JWT + 過期機制 |
| 日誌 | 脫敏處理 |

### 網路安全

- 所有對外請求走 HTTPS
- 內部服務走專用網路
- Rate Limiting 保護
- Circuit Breaker 防護

---

## 效能要求

### 延遲目標

| 操作 | P95 | P99 |
|------|-----|-----|
| 訊息處理 | < 50ms | < 100ms |
| API 回應 | < 200ms | < 500ms |
| 頁面載入 | < 1s | < 2s |

### 吞吐量目標

| 場景 | 目標 |
|------|------|
| 訊息處理 | 10,000 msg/s |
| 併發連線 | 50,000 connections |
| 佇列處理 | 100,000 msg/s |

---

## 文件要求

### 必須文件

| 文件 | 說明 |
|------|------|
| README.md | 專案說明 |
| ARCHITECTURE.md | 架構說明 |
| API.md | API 文件 |
| DEVELOPMENT.md | 本文件 |
| DEPLOYMENT.md | 部署說明 |

### 文件更新時機

| 文件 | 更新時機 |
|------|----------|
| README.md | 新功能 |
| API.md | API 變更 |
| DEVELOPMENT.md | 流程變更 |
| DEPLOYMENT.md | 部署變更 |

---

## 開發流程

```
需求 ─► 設計 ─► 開發 ─► 測試 ─► Review ─► 合併 ─► 部署
  │        │        │        │        │        │        │
  ▼        ▼        ▼        ▼        ▼        ▼        ▼
Bug      Arch    Code     Unit     Approve  Git      K8s
Report   Change  Format   Test     Comment  Push     Apply
```

---

## 緊急修復流程

1. **建立 Hotfix 分支**
   ```bash
   git checkout -b hotfix/issue-number origin/prod
   ```

2. **修復並測試**
   - 最小修改
   - 確保測試通過

3. **Review & 合併**
   - 快速 Review
   - 合併到 prod

4. **部署**
   - 優先部署
   - 監控異常

5. **同步到其他分支**
   ```bash
   git merge prod/dev
   git merge prod/test
   ```

---

## 持續改進

### 定期檢視

| 項目 | 頻率 | 負責人 |
|------|------|--------|
| 程式碼審查 | 每週 | Tech Lead |
| 效能優化 | 每月 | Team |
| 架構檢視 | 每季 | Architect |
| 安全審計 | 每半年 | Security |

### 改進來源

- 系統監控數據
- 使用者回饋
- 技術債務清單
- 業界最佳實踐

---

## 參考文件

- [OpenClaw Rust 重構計劃](../OPENCLAW_RUST_REARCHITECTURE_PLAN.md)
- [專案 README.md](../README.md)
- [架構文件](../ARCHITECTURE.md)

---

**最後更新**: 2026-02-13
**版本**: 1.0
