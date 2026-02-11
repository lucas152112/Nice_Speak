-- ========================================
-- Device Binding Schema for Nice_Speak
-- ========================================

-- 設備綁定表
CREATE TABLE IF NOT EXISTS `devices` (
    `id` CHAR(36) NOT NULL DEFAULT (UUID()),
    `device_id` VARCHAR(64) NOT NULL COMMENT '設備唯一識別碼',
    `user_id` CHAR(36) NULL COMMENT '綁定用戶 ID',
    `platform` VARCHAR(20) NOT NULL COMMENT '平台: android, ios, web',
    `fcm_token` VARCHAR(256) NULL COMMENT 'Firebase Cloud Messaging Token',
    `has_used_free_trial` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否使用過免費試用',
    `is_banned` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否被封禁',
    `ban_reason` VARCHAR(255) NULL COMMENT '封禁原因',
    `registered_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '註冊時間',
    `last_used_at` DATETIME NULL COMMENT '最後使用時間',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_device_id` (`device_id`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_has_used_free_trial` (`has_used_free_trial`),
    INDEX `idx_is_banned` (`is_banned`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='設備綁定表';

-- 設備使用記錄表
CREATE TABLE IF NOT EXISTS `device_usage_logs` (
    `id` CHAR(36) NOT NULL DEFAULT (UUID()),
    `device_id` VARCHAR(64) NOT NULL COMMENT '設備 ID',
    `event_type` VARCHAR(50) NOT NULL COMMENT '事件類型',
    `app_version` VARCHAR(20) NULL COMMENT 'App 版本',
    `platform` VARCHAR(20) NULL COMMENT '平台',
    `metadata` JSON NULL COMMENT '附加資料',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_device_id` (`device_id`),
    INDEX `idx_event_type` (`event_type`),
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='設備使用記錄表';

-- ========================================
-- Stored Procedures
-- ========================================

DELIMITER $$

-- 檢查設備是否可以免費試用
DROP PROCEDURE IF EXISTS `sp_check_device_free_trial`$$
CREATE PROCEDURE `sp_check_device_free_trial`(
    IN p_device_id VARCHAR(64)
)
BEGIN
    SELECT 
        d.device_id,
        d.has_used_free_trial,
        d.is_banned,
        d.ban_reason,
        d.registered_at,
        d.last_used_at,
        CASE 
            WHEN d.is_banned = 1 THEN FALSE
            WHEN d.has_used_free_trial = 1 THEN FALSE
            ELSE TRUE
        END AS can_use_free_trial;
END$$

-- 註冊設備
DROP PROCEDURE IF EXISTS `sp_register_device`$$
CREATE PROCEDURE `sp_register_device`(
    IN p_device_id VARCHAR(64),
    IN p_platform VARCHAR(20),
    IN p_fcm_token VARCHAR(256)
)
BEGIN
    INSERT INTO devices (device_id, platform, fcm_token, registered_at, last_used_at)
    VALUES (p_device_id, p_platform, p_fcm_token, NOW(), NOW())
    ON DUPLICATE KEY UPDATE
        last_used_at = NOW(),
        platform = p_platform,
        fcm_token = COALESCE(p_fcm_token, fcm_token);
    
    SELECT device_id, has_used_free_trial, is_banned FROM devices WHERE device_id = p_device_id;
END$$

-- 標記設備已使用免費試用
DROP PROCEDURE IF EXISTS `sp_mark_device_trial_used`$$
CREATE PROCEDURE `sp_mark_device_trial_used`(
    IN p_device_id VARCHAR(64)
)
BEGIN
    UPDATE devices 
    SET has_used_free_trial = 1, last_used_at = NOW()
    WHERE device_id = p_device_id;
    
    SELECT ROW_COUNT() AS affected_rows;
END$$

-- 封禁設備
DROP PROCEDURE IF EXISTS `sp_ban_device`$$
CREATE PROCEDURE `sp_ban_device`(
    IN p_device_id VARCHAR(64),
    IN p_reason VARCHAR(255)
)
BEGIN
    UPDATE devices 
    SET is_banned = 1, ban_reason = p_reason, last_used_at = NOW()
    WHERE device_id = p_device_id;
    
    SELECT ROW_COUNT() AS affected_rows;
END$$

DELIMITER ;

-- ========================================
-- Sample Data (測試用)
-- ========================================

-- 測試設備
INSERT INTO devices (device_id, platform, has_used_free_trial, is_banned)
VALUES 
    ('test-device-001', 'android', 0, 0),
    ('test-device-002', 'ios', 1, 0),
    ('test-device-003', 'web', 0, 1)
ON DUPLICATE KEY UPDATE updated_at = NOW();

-- 測試使用記錄
INSERT INTO device_usage_logs (device_id, event_type, app_version, platform)
VALUES 
    ('test-device-001', 'APP_OPENED', '1.0.0', 'android'),
    ('test-device-002', 'TRIAL_STARTED', '1.0.0', 'ios'),
    ('test-device-003', 'APP_OPENED', '1.0.0', 'web');

-- ========================================
-- Usage Examples
-- ========================================

-- 檢查設備狀態
-- CALL sp_check_device_free_trial('test-device-001');

-- 註冊設備
-- CALL sp_register_device('new-device-001', 'web', NULL);

-- 標記已使用試用
-- CALL sp_mark_device_trial_used('test-device-001');

-- 封禁設備
-- CALL sp_ban_device('test-device-003', 'Suspicious activity detected');
