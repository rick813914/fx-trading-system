# 外汇交易订单管理系统 - 数据库架构文档

## 概述

本文档描述了外汇交易订单管理系统的数据库架构设计。

## 表关系图

## 核心表说明

### 1. 用户相关表

#### users_user - 用户表

- **主键**: id (BIGSERIAL)
    
- **功能**: 存储系统用户的基本信息
    
- **关键字段**:
    
    - `username`: 用户名，唯一
        
    - `email`: 邮箱，唯一
        
    - `password`: 加密后的密码
        
    - `is_active`: 用户是否激活
        
    - `is_staff`: 是否为员工
        
    - `is_superuser`: 是否为超级用户
        

#### users_profile - 用户资料表

- **外键**: user_id → users_user.id
    
- **功能**: 存储用户的个人资料和偏好设置
    
- **关键字段**:
    
    - `language`: 界面语言
        
    - `timezone`: 时区
        
    - `currency`: 默认货币
        
    - `risk_per_trade`: 每笔交易风险百分比
        

### 2. 账户相关表

#### accounts_account - 交易账户表

- **外键**: user_id → users_user.id
    
- **功能**: 存储用户的交易账户信息
    
- **关键字段**:
    
    - `name`: 账户名称
        
    - `account_number`: 账户号码
        
    - `broker_name`: 经纪商名称
        
    - `account_type`: 账户类型 (DEMO/REAL/PAPER)
        
    - `initial_balance`: 初始余额
        
    - `current_balance`: 当前余额
        
    - 统计字段: total_trades, winning_trades, losing_trades 等
        

#### accounts_cashflow - 资金流水表

- **外键**: account_id → accounts_account.id
    
- **功能**: 记录账户的所有资金变动
    
- **关键字段**:
    
    - `transaction_type`: 交易类型 (DEPOSIT/WITHDRAWAL/PROFIT/LOSS)
        
    - `amount`: 变动金额
        
    - `balance_before`: 变动前余额
        
    - `balance_after`: 变动后余额
        

### 3. 订单相关表（核心）

#### orders_order - 订单表

- **外键**: account_id → accounts_account.id
    
- **功能**: 存储所有的交易订单
    
- **关键字段**:
    
    - `symbol`: 交易品种 (如 EUR/USD)
        
    - `direction`: 交易方向 (BUY/SELL)
        
    - `volume`: 交易手数
        
    - `open_price`: 开仓价格
        
    - `close_price`: 平仓价格
        
    - `status`: 订单状态 (OPEN/CLOSED/CANCELLED)
        
    - `net_profit`: 净利润（自动计算）
        
- **索引**: 为频繁查询的字段创建了多个索引
    

#### orders_tag - 标签表

- **外键**: user_id → users_user.id
    
- **功能**: 允许用户为订单创建自定义标签
    
- **关键字段**:
    
    - `name`: 标签名称
        
    - `color`: 标签颜色（用于UI显示）
        

#### orders_order_tags - 订单标签关联表

- **功能**: 实现订单和标签的多对多关系
    

### 4. 系统表

#### system_auditlog - 审计日志表

- **功能**: 记录所有重要的系统操作
    
- **关键字段**:
    
    - `action`: 操作名称
        
    - `resource_type`: 资源类型
        
    - `resource_id`: 资源ID
        
    - `before_state`: 操作前状态（JSON）
        
    - `after_state`: 操作后状态（JSON）
        

#### system_config - 系统配置表

- **功能**: 存储系统配置项
    
- **关键字段**:
    
    - `config_key`: 配置键（唯一）
        
    - `config_value`: 配置值（JSON格式）
        
    - `is_public`: 是否为公开配置
        

## 触发器

### 1. 自动更新时间戳

- **触发器**: update_updated_at_column
    
- **功能**: 在更新任何表时自动更新updated_at字段
    

### 2. 订单盈利计算

- **触发器**: calculate_order_profit
    
- **功能**: 当订单状态变为CLOSED时，自动计算盈利
    

### 3. 账户统计更新

- **触发器**: update_account_stats_on_order_change
    
- **功能**: 当订单关闭时，自动更新账户统计信息
    

## 索引策略

为了提高查询性能，我们为以下字段创建了索引：

- **用户表**: email, username
    
- **账户表**: user_id, is_active
    
- **订单表**（最重要的索引）:
    
    - `account_id` - 按账户查询
        
    - `symbol` - 按货币对查询
        
    - `open_time`, `close_time` - 时间范围查询
        
    - 复合索引: `account_id + status`, `symbol + open_time`
        
- **审计日志**: user_id, created_at, action
    

## 性能优化

- **统计字段缓存**: 在accounts_account表中缓存交易统计数据，避免实时计算
    
- **触发器自动化**: 使用触发器自动维护数据一致性
    
- **适当的索引**: 为所有查询频繁的字段创建索引
    
- **JSON字段**: 对配置和变更记录使用JSONB字段，提供灵活性
    

## 数据完整性

- **外键约束**: 所有关系都通过外键约束保证
    
- **检查约束**: 对枚举字段使用CHECK约束
    
- **唯一约束**: 对需要唯一的字段（如用户名、邮箱）添加唯一约束
    
- **级联删除**: 相关表的级联删除设置
    

## 开发环境数据

数据库初始化时会自动插入：

- 一个演示用户（用户名: demo，邮箱: demo@example.com）
    
- 一个演示账户（初始余额: $10,000）
    
- 系统默认配置（支持的货币对、导入设置等）