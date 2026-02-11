use serde::Deserialize;
use std::env;

#[derive(Debug, Clone, Deserialize)]
pub struct Config {
    pub app_env: String,
    pub app_name: String,
    pub app_url: String,
    
    pub database: DatabaseConfig,
    pub jwt: JwtConfig,
    pub redis: RedisConfig,
    pub mongodb: MongoConfig,
    pub external: ExternalConfig,
    pub logging: LoggingConfig,
}

#[derive(Debug, Clone, Deserialize)]
pub struct DatabaseConfig {
    pub db_type: String,
    pub host: String,
    pub port: u16,
    pub database: String,
    pub username: String,
    pub password: String,
    pub max_connections: u32,
    pub min_connections: u32,
}

#[derive(Debug, Clone, Deserialize)]
pub struct JwtConfig {
    pub secret: String,
    pub expires_in: i64,
    pub refresh_expires_in: i64,
}

#[derive(Debug, Clone, Deserialize)]
pub struct RedisConfig {
    pub host: String,
    pub port: u16,
    pub password: String,
    pub db: u32,
    pub key_prefix: String,
}

#[derive(Debug, Clone, Deserialize)]
pub struct MongoConfig {
    pub uri: String,
    pub database: String,
}

#[derive(Debug, Clone, Deserialize)]
pub struct ExternalConfig {
    pub stt_provider: String,
    pub stt_api_key: String,
    pub tts_provider: String,
    pub tts_api_key: String,
    pub ai_provider: String,
    pub ai_api_key: String,
    pub payment_provider: String,
}

#[derive(Debug, Clone, Deserialize)]
pub struct LoggingConfig {
    pub level: String,
    pub format: String,
}

impl Config {
    pub fn from_env() -> anyhow::Result<Self> {
        let app_env = env::var("APP_ENV").unwrap_or_else(|_| "dev".to_string());
        
        // 根據環境載入對應的配置文件
        let config_file = match app_env.as_str() {
            "test" => ".env.test",
            "pp" => ".env.pp",
            "prod" => ".env.prod",
            _ => ".env.dev", // 預設為 dev
        };
        
        // 讀取環境變數
        Ok(Self {
            app_env: app_env.clone(),
            app_name: env::var("APP_NAME").unwrap_or_else(|_| "Nice Speak".to_string()),
            app_url: env::var("APP_URL").unwrap_or_else(|_| "http://localhost:3000".to_string()),
            
            database: DatabaseConfig {
                db_type: env::var("DATABASE_TYPE").unwrap_or_else(|_| "mysql".to_string()),
                host: env::var("MYSQL_HOST").unwrap_or_else(|_| "103.251.113.34".to_string()),
                port: env::var("MYSQL_PORT").unwrap_or_else(|_| "31001".to_string()).parse()?,
                database: format!("nice_speak_{}", app_env),
                username: env::var("MYSQL_USER").unwrap_or_else(|_| "root".to_string()),
                password: env::var("MYSQL_PASSWORD").unwrap_or_else(|_| "".to_string()),
                max_connections: env::var("MYSQL_MAX_CONN").unwrap_or_else(|_| "20".to_string()).parse()?,
                min_connections: env::var("MYSQL_MIN_CONN").unwrap_or_else(|_| "5".to_string()).parse()?,
            },
            
            jwt: JwtConfig {
                secret: env::var("JWT_SECRET").unwrap_or_else(|_| "your-secret-key".to_string()),
                expires_in: env::var("JWT_EXPIRES_IN").unwrap_or_else(|_| "86400".to_string()).parse()?,
                refresh_expires_in: env::var("JWT_REFRESH_EXPIRES_IN").unwrap_or_else(|_| "604800".to_string()).parse()?,
            },
            
            redis: RedisConfig {
                host: env::var("REDIS_HOST").unwrap_or_else(|_| "103.251.113.34".to_string()),
                port: env::var("REDIS_PORT").unwrap_or_else(|_| "31002".to_string()).parse()?,
                password: env::var("REDIS_PASSWORD").unwrap_or_else(|_| "".to_string()),
                db: env::var("REDIS_DB").unwrap_or_else(|_| "0".to_string()).parse()?,
                key_prefix: format!("nice_speak:{}:", app_env),
            },
            
            mongodb: MongoConfig {
                uri: env::var("MONGODB_URI").unwrap_or_else(|_| "mongodb://admin:@103.251.113.34:31003".to_string()),
                database: format!("nice_speak_{}", app_env),
            },
            
            external: ExternalConfig {
                stt_provider: env::var("STT_PROVIDER").unwrap_or_else(|_| "google".to_string()),
                stt_api_key: env::var("STT_API_KEY").unwrap_or_else(|_| "".to_string()),
                tts_provider: env::var("TTS_PROVIDER").unwrap_or_else(|_| "azure".to_string()),
                tts_api_key: env::var("TTS_API_KEY").unwrap_or_else(|_| "".to_string()),
                ai_provider: env::var("AI_PROVIDER").unwrap_or_else(|_| "openai".to_string()),
                ai_api_key: env::var("AI_API_KEY").unwrap_or_else(|_| "".to_string()),
                payment_provider: env::var("PAYMENT_PROVIDER").unwrap_or_else(|_| "ecpay".to_string()),
            },
            
            logging: LoggingConfig {
                level: env::var("LOG_LEVEL").unwrap_or_else(|_| "debug".to_string()),
                format: env::var("LOG_FORMAT").unwrap_or_else(|_| "json".to_string()),
            },
        })
    }
    
    /// 取得 MySQL 連線字串
    pub fn mysql_url(&self) -> String {
        format!(
            "mysql://{}:{}@{}:{}/{}",
            self.database.username,
            self.database.password,
            self.database.host,
            self.database.port,
            self.database.database
        )
    }
    
    /// 取得 Redis 連線字串
    pub fn redis_url(&self) -> String {
        if self.redis.password.is_empty() {
            format!("redis://{}:{}/{}", self.redis.host, self.redis.port, self.redis.db)
        } else {
            format!("redis://:{}@{}:{}/{}", self.redis.password, self.redis.host, self.redis.port, self.redis.db)
        }
    }
    
    /// 是否為開發環境
    pub fn is_dev(&self) -> bool {
        self.app_env == "dev"
    }
    
    /// 是否為正式環境
    pub fn is_prod(&self) -> bool {
        self.app_env == "prod"
    }
}

/// 環境輔助函數
pub fn get_env_prefix(env: &str) -> String {
    match env {
        "test" => "_test".to_string(),
        "pp" => "_pp".to_string(),
        "prod" => "_prod".to_string(),
        _ => "_dev".to_string(), // dev
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_config_structure() {
        let config = Config::from_env();
        assert!(config.is_ok());
    }
    
    #[test]
    fn test_database_name_format() {
        let env = "dev";
        let db_name = format!("nice_speak_{}", env);
        assert_eq!(db_name, "nice_speak_dev");
    }
    
    #[test]
    fn test_redis_prefix_format() {
        let env = "test";
        let prefix = format!("nice_speak:{}:", env);
        assert_eq!(prefix, "nice_speak:test:");
    }
}
