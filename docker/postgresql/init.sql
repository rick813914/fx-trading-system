-- ============================================
-- 外汇交易订单管理系统 - 数据库初始化脚本
-- ============================================

-- 1. 创建数据库（已在docker-compose中指定，这里确保扩展）
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. 创建用户相关的表
CREATE TABLE IF NOT EXISTS users_user (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(150) UNIQUE NOT NULL,
    email VARCHAR(254) UNIQUE NOT NULL,
    password VARCHAR(128) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    is_staff BOOLEAN DEFAULT false,
    is_superuser BOOLEAN DEFAULT false,
    date_joined TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP WITH TIME ZONE,

    -- 审计字段
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_by BIGINT
);

CREATE TABLE IF NOT EXISTS users_profile (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT UNIQUE NOT NULL REFERENCES users_user(id) ON DELETE CASCADE,
    full_name VARCHAR(255),
    phone_number VARCHAR(20),
    language VARCHAR(10) DEFAULT 'zh',
    timezone VARCHAR(50) DEFAULT 'Asia/Shanghai',
    currency VARCHAR(10) DEFAULT 'CNY',

    -- 交易偏好
    default_lot_size DECIMAL(10, 2) DEFAULT 0.01,
    risk_per_trade DECIMAL(5, 2) DEFAULT 1.0, -- 每笔交易风险百分比
    max_daily_risk DECIMAL(10, 2) DEFAULT 5.0, -- 每日最大风险

    -- 通知设置
    email_notifications BOOLEAN DEFAULT true,
    trade_notifications BOOLEAN DEFAULT true,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. 账户相关表
CREATE TABLE IF NOT EXISTS accounts_account (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users_user(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    account_number VARCHAR(100),
    broker_name VARCHAR(255),
    account_type VARCHAR(50) DEFAULT 'DEMO', -- DEMO, REAL, PAPER
    currency VARCHAR(10) DEFAULT 'USD',

    -- 初始资金和当前资金
    initial_balance DECIMAL(15, 2) DEFAULT 0.00,
    current_balance DECIMAL(15, 2) DEFAULT 0.00,

    -- 统计字段（缓存，提高查询性能）
    total_trades INTEGER DEFAULT 0,
    winning_trades INTEGER DEFAULT 0,
    losing_trades INTEGER DEFAULT 0,
    total_profit DECIMAL(15, 2) DEFAULT 0.00,
    total_loss DECIMAL(15, 2) DEFAULT 0.00,
    net_profit DECIMAL(15, 2) DEFAULT 0.00,

    -- 状态
    is_active BOOLEAN DEFAULT true,
    is_default BOOLEAN DEFAULT false,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_by BIGINT
);

CREATE TABLE IF NOT EXISTS accounts_cashflow (
    id BIGSERIAL PRIMARY KEY,
    account_id BIGINT NOT NULL REFERENCES accounts_account(id) ON DELETE CASCADE,
    transaction_type VARCHAR(50) NOT NULL, -- DEPOSIT, WITHDRAWAL, PROFIT, LOSS, ADJUSTMENT
    amount DECIMAL(15, 2) NOT NULL,
    balance_before DECIMAL(15, 2) NOT NULL,
    balance_after DECIMAL(15, 2) NOT NULL,
    description TEXT,
    reference_id VARCHAR(255), -- 外部参考ID
    transaction_date TIMESTAMP WITH TIME ZONE NOT NULL,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT
);

-- 4. 订单相关表（核心表）
CREATE TABLE IF NOT EXISTS orders_order (
    id BIGSERIAL PRIMARY KEY,
    account_id BIGINT NOT NULL REFERENCES accounts_account(id) ON DELETE CASCADE,

    -- 订单基本信息
    external_id VARCHAR(255), -- 外部平台订单ID
    symbol VARCHAR(50) NOT NULL, -- 交易品种，如 EUR/USD
    direction VARCHAR(10) NOT NULL CHECK (direction IN ('BUY', 'SELL')), -- 交易方向
    order_type VARCHAR(20) DEFAULT 'MARKET', -- MARKET, LIMIT, STOP
    volume DECIMAL(12, 2) NOT NULL, -- 手数

    -- 价格信息
    open_price DECIMAL(12, 6) NOT NULL,
    close_price DECIMAL(12, 6),
    stop_loss DECIMAL(12, 6),
    take_profit DECIMAL(12, 6),

    -- 时间信息
    open_time TIMESTAMP WITH TIME ZONE NOT NULL,
    close_time TIMESTAMP WITH TIME ZONE,

    -- 佣金和费用
    commission DECIMAL(10, 2) DEFAULT 0.00,
    swap DECIMAL(10, 2) DEFAULT 0.00,
    taxes DECIMAL(10, 2) DEFAULT 0.00,

    -- 计算结果
    gross_profit DECIMAL(12, 2), -- 毛利（未扣除费用）
    net_profit DECIMAL(12, 2), -- 净利（扣除所有费用）
    profit_pips DECIMAL(10, 2), -- 盈利点数
    profit_percentage DECIMAL(10, 4), -- 盈利百分比

    -- 状态
    status VARCHAR(20) DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'CLOSED', 'CANCELLED', 'PENDING')),

    -- 交易信息
    timeframe VARCHAR(10), -- 交易时间框架，如 M1, H1, D1
    strategy_name VARCHAR(255), -- 策略名称
    notes TEXT, -- 交易笔记

    -- 审计字段
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_by BIGINT,
    imported_from VARCHAR(100), -- 导入来源，如 'MT4', 'MT5', 'MANUAL'
    import_batch_id UUID, -- 同一批次导入的订单ID

    -- 索引
    CONSTRAINT unique_external_id_account UNIQUE (external_id, account_id)
);

-- 5. 标签表
CREATE TABLE IF NOT EXISTS orders_tag (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    color VARCHAR(20) DEFAULT '#3B82F6',
    user_id BIGINT NOT NULL REFERENCES users_user(id) ON DELETE CASCADE,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(name, user_id)
);

-- 6. 订单标签关联表（多对多关系）
CREATE TABLE IF NOT EXISTS orders_order_tags (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders_order(id) ON DELETE CASCADE,
    tag_id BIGINT NOT NULL REFERENCES orders_tag(id) ON DELETE CASCADE,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(order_id, tag_id)
);

-- 7. 导入模板表
CREATE TABLE IF NOT EXISTS orders_importtemplate (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    user_id BIGINT NOT NULL REFERENCES users_user(id) ON DELETE CASCADE,
    template_type VARCHAR(50) NOT NULL, -- MT4, MT5, CUSTOM

    -- 列映射配置（JSON格式）
    column_mapping JSONB NOT NULL,

    -- 导入选项
    import_options JSONB DEFAULT '{}',

    is_default BOOLEAN DEFAULT false,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 8. 会话管理表（用于JWT刷新令牌管理）
CREATE TABLE IF NOT EXISTS users_session (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users_user(id) ON DELETE CASCADE,
    refresh_token_hash VARCHAR(255) NOT NULL,
    user_agent TEXT,
    ip_address INET,

    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    revoked BOOLEAN DEFAULT false,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_used_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 9. 系统日志表
CREATE TABLE IF NOT EXISTS system_auditlog (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users_user(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(100),
    resource_id VARCHAR(255),

    -- 变更详情（JSON格式）
    before_state JSONB,
    after_state JSONB,
    changes JSONB,

    ip_address INET,
    user_agent TEXT,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 10. 系统配置表
CREATE TABLE IF NOT EXISTS system_config (
    id BIGSERIAL PRIMARY KEY,
    config_key VARCHAR(255) UNIQUE NOT NULL,
    config_value JSONB NOT NULL,
    description TEXT,

    is_public BOOLEAN DEFAULT false,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_by BIGINT
);

-- ============================================
-- 索引创建（提高查询性能）
-- ============================================

-- 用户相关索引
CREATE INDEX idx_users_user_email ON users_user(email);
CREATE INDEX idx_users_user_username ON users_user(username);

-- 账户相关索引
CREATE INDEX idx_accounts_account_user_id ON accounts_account(user_id);
CREATE INDEX idx_accounts_account_is_active ON accounts_account(is_active);
CREATE INDEX idx_accounts_cashflow_account_id ON accounts_cashflow(account_id);
CREATE INDEX idx_accounts_cashflow_transaction_date ON accounts_cashflow(transaction_date);

-- 订单相关索引（非常重要，因为查询频繁）
CREATE INDEX idx_orders_order_account_id ON orders_order(account_id);
CREATE INDEX idx_orders_order_symbol ON orders_order(symbol);
CREATE INDEX idx_orders_order_direction ON orders_order(direction);
CREATE INDEX idx_orders_order_status ON orders_order(status);
CREATE INDEX idx_orders_order_open_time ON orders_order(open_time);
CREATE INDEX idx_orders_order_close_time ON orders_order(close_time);
CREATE INDEX idx_orders_order_created_at ON orders_order(created_at);

-- 复合索引（提高特定查询性能）
CREATE INDEX idx_orders_order_account_status ON orders_order(account_id, status);
CREATE INDEX idx_orders_order_account_time_range ON orders_order(account_id, open_time, close_time);
CREATE INDEX idx_orders_order_symbol_time ON orders_order(symbol, open_time);

-- 标签相关索引
CREATE INDEX idx_orders_tag_user_id ON orders_tag(user_id);
CREATE INDEX idx_orders_order_tags_order_id ON orders_order_tags(order_id);
CREATE INDEX idx_orders_order_tags_tag_id ON orders_order_tags(tag_id);

-- 会话索引
CREATE INDEX idx_users_session_user_id ON users_session(user_id);
CREATE INDEX idx_users_session_refresh_token_hash ON users_session(refresh_token_hash);
CREATE INDEX idx_users_session_expires_at ON users_session(expires_at);

-- 审计日志索引
CREATE INDEX idx_system_auditlog_user_id ON system_auditlog(user_id);
CREATE INDEX idx_system_auditlog_created_at ON system_auditlog(created_at);
CREATE INDEX idx_system_auditlog_action ON system_auditlog(action);

-- ============================================
-- 函数和触发器
-- ============================================

-- 1. 自动更新 updated_at 字段的函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. 订单关闭时自动计算盈利的函数
CREATE OR REPLACE FUNCTION calculate_order_profit()
RETURNS TRIGGER AS $$
DECLARE
    price_diff DECIMAL(12, 6);
    pip_value DECIMAL(10, 6);
    lot_size DECIMAL(10, 2);
BEGIN
    -- 只在订单关闭且有close_price时计算
    IF NEW.status = 'CLOSED' AND NEW.close_price IS NOT NULL AND NEW.open_price IS NOT NULL THEN
        -- 计算价格差异
        IF NEW.direction = 'BUY' THEN
            price_diff := NEW.close_price - NEW.open_price;
        ELSE -- SELL
            price_diff := NEW.open_price - NEW.close_price;
        END IF;

        -- 简化计算：假设1手 = 100000 单位，1pip = 0.0001（对大多数货币对）
        -- 实际项目中需要根据货币对精确计算
        lot_size := 100000;

        -- 计算毛利（未扣除费用）
        NEW.gross_profit := price_diff * lot_size * NEW.volume;

        -- 计算净利（扣除佣金、费用等）
        NEW.net_profit := NEW.gross_profit - COALESCE(NEW.commission, 0) - COALESCE(NEW.swap, 0) - COALESCE(NEW.taxes, 0);

        -- 计算盈利点数
        IF NEW.symbol LIKE '%JPY%' THEN
            -- 日元货币对，1pip = 0.01
            NEW.profit_pips := price_diff * 100;
        ELSE
            -- 大多数货币对，1pip = 0.0001
            NEW.profit_pips := price_diff * 10000;
        END IF;

        -- 计算盈利百分比（基于仓位大小估算）
        IF NEW.net_profit != 0 THEN
            NEW.profit_percentage := (NEW.net_profit / (NEW.volume * 1000)) * 100; -- 简化计算
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. 订单状态变化时更新账户统计的函数
CREATE OR REPLACE FUNCTION update_account_stats_on_order_change()
RETURNS TRIGGER AS $$
BEGIN
    -- 当订单状态从非CLOSED变为CLOSED时，更新账户统计
    IF (OLD.status != 'CLOSED' AND NEW.status = 'CLOSED' AND NEW.net_profit IS NOT NULL) THEN
        UPDATE accounts_account
        SET
            total_trades = total_trades + 1,
            winning_trades = winning_trades + CASE WHEN NEW.net_profit > 0 THEN 1 ELSE 0 END,
            losing_trades = losing_trades + CASE WHEN NEW.net_profit < 0 THEN 1 ELSE 0 END,
            total_profit = total_profit + CASE WHEN NEW.net_profit > 0 THEN NEW.net_profit ELSE 0 END,
            total_loss = total_loss + CASE WHEN NEW.net_profit < 0 THEN ABS(NEW.net_profit) ELSE 0 END,
            net_profit = net_profit + NEW.net_profit,
            current_balance = current_balance + NEW.net_profit,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = NEW.account_id;

        -- 插入资金流水记录
        INSERT INTO accounts_cashflow (
            account_id, transaction_type, amount,
            balance_before, balance_after,
            description, transaction_date, created_by
        )
        SELECT
            NEW.account_id,
            CASE WHEN NEW.net_profit > 0 THEN 'PROFIT' ELSE 'LOSS' END,
            NEW.net_profit,
            a.current_balance - NEW.net_profit,
            a.current_balance,
            'Order #' || NEW.id || ' closed: ' || NEW.symbol || ' ' || NEW.direction,
            COALESCE(NEW.close_time, CURRENT_TIMESTAMP),
            NEW.updated_by
        FROM accounts_account a
        WHERE a.id = NEW.account_id;

    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 应用触发器
-- ============================================

-- 自动更新updated_at的触发器
CREATE TRIGGER update_users_user_updated_at
    BEFORE UPDATE ON users_user
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_accounts_account_updated_at
    BEFORE UPDATE ON accounts_account
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_order_updated_at
    BEFORE UPDATE ON orders_order
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_tag_updated_at
    BEFORE UPDATE ON orders_tag
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_importtemplate_updated_at
    BEFORE UPDATE ON orders_importtemplate
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_system_config_updated_at
    BEFORE UPDATE ON system_config
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 订单盈利计算触发器
CREATE TRIGGER calculate_order_profit_trigger
    BEFORE UPDATE ON orders_order
    FOR EACH ROW EXECUTE FUNCTION calculate_order_profit();

-- 账户统计更新触发器
CREATE TRIGGER update_account_stats_trigger
    AFTER UPDATE ON orders_order
    FOR EACH ROW EXECUTE FUNCTION update_account_stats_on_order_change();

-- ============================================
-- 插入初始数据
-- ============================================

-- 插入默认系统配置
INSERT INTO system_config (config_key, config_value, description, is_public) VALUES
('system.currency_pairs', '["EUR/USD", "GBP/USD", "USD/JPY", "USD/CHF", "AUD/USD", "USD/CAD", "NZD/USD", "EUR/GBP", "EUR/JPY", "GBP/JPY"]'::jsonb, '支持的货币对列表', true),
('system.default_import_settings', '{"delimiter": ",", "encoding": "utf-8", "skip_rows": 1}'::jsonb, '默认导入设置', false),
('system.reporting.periods', '["7d", "30d", "90d", "1y", "all"]'::jsonb, '报表支持的时间周期', true),
('system.performance.thresholds', '{"win_rate": 50, "profit_factor": 1.5, "max_drawdown": 20}'::jsonb, '绩效评估阈值', false)
ON CONFLICT (config_key) DO NOTHING;

-- 插入一个演示用户（密码：demo123，实际使用时会加密）
-- 注意：实际项目中密码应该在前端或应用层加密，这里只是演示
INSERT INTO users_user (username, email, password, is_active, is_staff, date_joined) VALUES
('demo', 'demo@example.com', 'pbkdf2_sha256$600000$abc123$...', true, false, CURRENT_TIMESTAMP)
ON CONFLICT (username) DO NOTHING;

-- 插入演示账户
INSERT INTO accounts_account (user_id, name, account_number, broker_name, account_type, currency, initial_balance, current_balance, is_default)
SELECT id, 'Demo Account', 'DEMO-001', 'FX Broker Demo', 'DEMO', 'USD', 10000.00, 10000.00, true
FROM users_user WHERE username = 'demo'
ON CONFLICT DO NOTHING;

-- ============================================
-- 权限设置
-- ============================================

-- 为开发环境创建专用用户（可选）
CREATE USER fx_dev_user WITH PASSWORD 'fx_dev_password';
GRANT CONNECT ON DATABASE fx_trading_dev TO fx_dev_user;

-- 授予表权限
GRANT USAGE ON SCHEMA public TO fx_dev_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO fx_dev_user;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO fx_dev_user;

-- 授予函数执行权限
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO fx_dev_user;

-- ============================================
-- 完成提示
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '外汇交易订单管理系统数据库初始化完成！';
    RAISE NOTICE '数据库名: fx_trading_dev';
    RAISE NOTICE '表数量: %', (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public');
END $$;