# OpenClaw Rust 重構詳細開發計劃

## 概述

本文檔詳細描述將 OpenClaw 系統從 Node.js/TypeScript 重構為 Rust 的完整技術規格。

---

## 第一階段：核心框架 (Core Framework)

### 1.1 Actor System (Actor 系統)

**功能**: 異步 Actor 模型，用於並發處理

**依賴 Crates**:
- `tokio` - 異步執行
- `actix` - Actor 框架

```rust
// 主要程式碼結構
pub trait ActorMessage: Send + Clone + 'static {
    type Result: Send + 'static;
}

pub enum SupervisionStrategy {
    OneForOne,      // 只重啟失敗的 Actor
    OneForAll,      // 重啟所有相關 Actor
    RestForOne,     // 重啟失敗的及其後續
}

#[async_trait]
pub trait Lifecycle: Actor {
    async fn started(&mut self, ctx: &mut Context<Self>);
    async fn stopped(&mut self, ctx: &mut Context<Self>);
    async fn failed(&mut self, ctx: &mut Context<Self>, error: &ActorError);
}
```

### 1.2 Message Broker (訊息佇列)

**功能**: 訊息發布/訂閱系統

**依賴 Crates**:
- `lapin` - RabbitMQ 客戶端
- `tokio` - 異步 runtime

```rust
pub enum BrokerMessage {
    UserMessage {
        platform: Platform,
        channel_id: String,
        user_id: String,
        content: String,
        timestamp: chrono::DateTime<chrono::Utc>,
    },
    SystemEvent {
        event_type: String,
        payload: serde_json::Value,
    },
    Command {
        command: String,
        args: Vec<String>,
        source: String,
    },
}

pub struct MessageBroker {
    connection: lapin::Connection,
    channels: HashMap<String, Channel>,
    subscribers: Arc<RwLock<HashMap<String, mpsc::Sender<BrokerMessage>>>>,
}
```

### 1.3 State Machine (狀態機)

**功能**: 狀態管理與轉換

**依賴 Crates**:
- `smlang` - 狀態機

```rust
statemachine!(
    states {
        Initializing,
        Running,
        Paused,
        Stopping,
        Stopped,
        Error(String),
    },
    events {
        Start,
        Pause,
        Stop,
        Restart,
        Heartbeat,
        ErrorOccurred(String),
    },
    transitions {
        Initializing -> Running on Start,
        Running -> Paused on Pause,
        Running -> Stopping on Stop,
        Paused -> Running on Start,
        Stopping -> Stopped,
        Running -> Error(String) on ErrorOccurred,
    }
);
```

### 1.4 Configuration (配置管理)

**功能**: 設定載入與驗證

**依賴 Crates**:
- `serde` / `toml` - 序列化
- `figment` - 多來源配置

```rust
pub struct OpenClawConfig {
    pub gateway: GatewayConfig,
    pub agent: AgentConfig,
    pub messaging: MessagingConfig,
    pub tools: ToolsConfig,
    pub monitoring: MonitoringConfig,
}
```

---

## 第二階段：通訊層 (Communication Layer)

### 2.1 Discord Bot

**功能**: Discord 閘道連接與訊息處理

**依賴 Crates**:
- `serenity` - Discord API

```rust
pub struct DiscordBot {
    client: serenity::Client,
    message_tx: mpsc::Sender<DiscordMessage>,
}

pub struct DiscordMessage {
    pub channel_id: String,
    pub guild_id: Option<String>,
    pub user_id: String,
    pub content: String,
    pub timestamp: chrono::DateTime<chrono::Utc>,
}
```

### 2.2 WhatsApp

**功能**: WhatsApp Business API 連接

**依賴 Crates**:
- `reqwest` - HTTP 客戶端

### 2.3 Telegram

**功能**: Telegram Bot API

**依賴 Crates**:
- `teloxide` - Telegram Bot

### 2.4 Webhook

**功能**: 統一 Webhook 接收

**依賴 Crates**:
- `axum` - Web Framework

---

## 第三階段：工具系統 (Tools System)

### 3.1 Exec Tool

**功能**: 指令執行

```rust
pub struct ExecRequest {
    pub command: String,
    pub args: Vec<String>,
    pub timeout_seconds: Option<u64>,
    pub working_dir: Option<String>,
    pub environment: Option<HashMap<String, String>>,
    pub elevated: bool,
}
```

**安全機制**:
- 命令白名單
- 危險字元過濾
- 逾時保護

### 3.2 Browser Tool

**功能**: 瀏覽器控制

**依賴 Crates**:
- `chromiumoxide` - Chrome DevTools

```rust
pub enum BrowserAction {
    Navigate { url: String },
    Click { selector: String },
    Type { selector: String, text: String },
    Screenshot { path: Option<String> },
    GetHtml,
    ExecuteJavaScript { code: String },
}
```

### 3.3 Web Fetch

**功能**: HTTP 請求

**依賴 Crates**:
- `reqwest` - HTTP 客戶端
- `scraper` - HTML 解析

### 3.4 File I/O

**功能**: 檔案操作

---

## 第四階段：穩定性系統 (Stability System)

### 4.1 Panic Handler (永不崩潰)

**功能**: 全域異常處理與自動恢復

```rust
pub struct PanicInfo {
    pub message: String,
    pub location: String,
    pub backtrace: String,
    pub thread_name: Option<String>,
    pub timestamp: chrono::DateTime<chrono::Utc>,
}
```

**策略**:
- 自訂 panic hook
- 即時日誌記錄
- 警報通知
- 自動恢復嘗試

### 4.2 Health Check (健康檢查)

**功能**: 服務健康監控

```rust
pub enum HealthStatus {
    Healthy,
    Degraded,
    Unhealthy,
    Unknown,
}

pub struct HealthReport {
    pub overall_status: HealthStatus,
    pub components: Vec<ComponentStatus>,
    pub timestamp: chrono::DateTime<chrono::Utc>,
}
```

### 4.3 Circuit Breaker (熔斷機制)

**功能**: 防止級聯故障

```rust
pub enum CircuitStatus {
    Closed,      // 正常運行
    Open,        // 阻斷請求
    HalfOpen,    // 測試恢復
}

pub struct CircuitConfig {
    pub failure_threshold: u64,
    pub success_threshold: u64,
    pub timeout_ms: u64,
}
```

**邏輯**:
- 失敗 N 次 → Open
- 逾時後 → HalfOpen
- 成功 M 次 → Closed

### 4.4 Rate Limiter (流量限制)

**功能**: 請求速率控制

```rust
pub struct RateLimitConfig {
    pub capacity: u64,       // 最大 token 數
    pub refill_rate: f64,   // 每秒補充 token
    pub initial_tokens: u64,
}
```

---

## 第五階段：預警系統 (Early Warning System)

### 5.1 Metrics Collection (指標收集)

**功能**: 效能指標收集

**依賴 Crates**:
- `prometheus` - 指標客戶端

```rust
pub struct MetricsCollector {
    messages_sent: Counter,
    messages_received: Counter,
    api_calls: Counter,
    errors_total: Counter,
    active_connections: Gauge,
    response_time: Histogram,
}
```

### 5.2 Alerting (警報通知)

**功能**: 異常自動警報

**功能**:
- 閾值觸發
- 多管道通知 (Discord, Email, Slack)
- 警報升級

### 5.3 Logging (結構化日誌)

**功能**: 統一日誌系統

**依賴 Crates**:
- `tracing` - 結構化日誌
- `tracing-subscriber` - 日誌輸出

---

## Crates 依賴清單

### 異步與並發
| Crate | 版本 | 用途 |
|-------|------|------|
| tokio | 1.x | 異步 runtime |
| async-trait | 0.1 | 異步 trait |
| futures | 0.3 | Future 工具 |

### Web 與 API
| Crate | 版本 | 用途 |
|-------|------|------|
| axum | 0.6 | Web Framework |
| warp | 0.3 | Web Framework |
| reqwest | 0.11 | HTTP 客戶端 |
| serde | 1.x | 序列化 |
| toml | 0.5 | TOML 解析 |

### 即時通訊
| Crate | 版本 | 用途 |
|-------|------|------|
| serenity | 0.11 | Discord |
| teloxide | 0.5 | Telegram |
| lapin | 1.x | RabbitMQ |

### 監控
| Crate | 版本 | 用途 |
|-------|------|------|
| prometheus | 0.13 | 指標 |
| tracing | 0.1 | 日誌 |
| metrics | 0.5 | 指標抽象 |

### 瀏覽器控制
| Crate | 版本 | 用途 |
|-------|------|------|
| chromiumoxide | 0.4 | Chrome DevTools |

### 資料庫
| Crate | 版本 | 用途 |
|-------|------|------|
| sqlx | 0.6 | 異步 SQL |
| sea-orm | 0.11 | ORM |

---

## 優先順序

### P0 - 核心功能 (必須)
1. Actor System
2. Message Broker
3. Configuration
4. Panic Handler

### P1 - 通訊功能 (重要)
1. Discord Bot
2. Webhook Receiver
3. Telegram Bot

### P2 - 工具功能 (必要)
1. Exec Tool
2. File I/O
3. Web Fetch

### P3 - 穩定性 (增強)
1. Health Check
2. Circuit Breaker
3. Rate Limiter
4. Metrics

### P4 - 預警 (優化)
1. Alerting
2. Structured Logging

---

## 估計開發時間

| 階段 | 模組數 | 估計時間 |
|------|--------|----------|
| 第一階段 | 4 | 2 週 |
| 第二階段 | 4 | 2 週 |
| 第三階段 | 4 | 1 週 |
| 第四階段 | 4 | 1 週 |
| 第五階段 | 3 | 1 週 |
| **總計** | **19** | **7 週** |

---

## 檔案結構

```
openclaw-rust/
├── Cargo.toml
├── src/
│   ├── main.rs
│   ├── lib.rs
│   ├── core/
│   │   ├── actor/
│   │   ├── broker/
│   │   ├── state/
│   │   └── config/
│   ├── communication/
│   │   ├── discord/
│   │   ├── whatsapp/
│   │   ├── telegram/
│   │   └── webhook/
│   ├── tools/
│   │   ├── exec/
│   │   ├── browser/
│   │   ├── file/
│   │   └── web/
│   ├── stability/
│   │   ├── panic_handler/
│   │   ├── health/
│   │   ├── circuit_breaker/
│   │   └── rate_limiter/
│   └── monitoring/
│       ├── metrics/
│       ├── alerting/
│       └── logging/
├── configs/
│   └── default.toml
├── docker/
│   └── Dockerfile
└── k8s/
    └── deployment.yaml
```
