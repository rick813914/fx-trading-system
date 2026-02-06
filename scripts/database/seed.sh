#!/bin/bash
# 数据种子脚本 - 添加演示数据

set -e

echo "添加演示数据..."

# 检查数据库是否可用
if ! docker-compose exec -T postgres pg_isready -U postgres; then
    echo "❌ 数据库不可用"
    exit 1
fi

echo "1. 检查并添加演示用户..."
docker-compose exec -T postgres psql -U postgres -d fx_trading_dev << 'SQL'
-- 如果演示用户不存在，则创建
INSERT INTO users_user (username, email, password, is_active, is_staff, date_joined)
SELECT 'demo', 'demo@example.com', 'pbkdf2_sha256$dummy$...', true, false, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM users_user WHERE username = 'demo');

-- 获取演示用户ID
WITH demo_user AS (
    SELECT id FROM users_user WHERE username = 'demo'
)
-- 添加演示账户
INSERT INTO accounts_account (user_id, name, account_number, broker_name, account_type, currency, initial_balance, current_balance, is_default)
SELECT id, 'Demo Account', 'DEMO-001', 'FX Broker Demo', 'DEMO', 'USD', 10000.00, 10000.00, true
FROM demo_user
WHERE NOT EXISTS (SELECT 1 FROM accounts_account WHERE name = 'Demo Account');

-- 添加一些演示订单
WITH demo_account AS (
    SELECT a.id
    FROM accounts_account a
    JOIN users_user u ON a.user_id = u.id
    WHERE u.username = 'demo' AND a.name = 'Demo Account'
)
INSERT INTO orders_order (
    account_id, symbol, direction, order_type, volume,
    open_price, close_price, stop_loss, take_profit,
    open_time, close_time, commission, swap, taxes,
    gross_profit, net_profit, profit_pips, profit_percentage,
    status, timeframe, strategy_name, notes
)
SELECT
    id,
    'EUR/USD',
    CASE WHEN RANDOM() > 0.5 THEN 'BUY' ELSE 'SELL' END,
    'MARKET',
    ROUND((RANDOM() * 1.5 + 0.1)::numeric, 2),
    ROUND((RANDOM() * 0.05 + 1.08)::numeric, 5),
    ROUND((RANDOM() * 0.05 + 1.08)::numeric, 5),
    ROUND((RANDOM() * 0.02 + 1.07)::numeric, 5),
    ROUND((RANDOM() * 0.02 + 1.09)::numeric, 5),
    CURRENT_TIMESTAMP - INTERVAL '30 days' * RANDOM(),
    CURRENT_TIMESTAMP - INTERVAL '29 days' * RANDOM(),
    ROUND((RANDOM() * 5)::numeric, 2),
    ROUND((RANDOM() * 2)::numeric, 2),
    ROUND((RANDOM() * 3)::numeric, 2),
    ROUND((RANDOM() * 200 - 100)::numeric, 2),
    ROUND((RANDOM() * 200 - 100)::numeric, 2),
    ROUND((RANDOM() * 50 - 25)::numeric, 2),
    ROUND((RANDOM() * 2 - 1)::numeric, 4),
    'CLOSED',
    'H1',
    'Demo Strategy',
    'Demo trade for testing'
FROM demo_account
WHERE NOT EXISTS (SELECT 1 FROM orders_order WHERE account_id = demo_account.id LIMIT 1)
LIMIT 20;

RAISE NOTICE '演示数据添加完成！';
SQL

echo "✅ 演示数据添加完成！"