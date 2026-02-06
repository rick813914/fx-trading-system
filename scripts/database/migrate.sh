#!/bin/bash
# 数据库迁移脚本（当数据库结构有变更时使用）

set -e

echo "运行数据库迁移..."

# 这里可以添加具体的迁移命令
# 例如，如果你使用Django，可能是：
# docker-compose exec backend python manage.py migrate

# 暂时先执行基本的SQL检查
docker-compose exec postgres psql -U postgres -d fx_trading_dev -c "
DO \$\$
BEGIN
    RAISE NOTICE '迁移脚本执行完成';
    RAISE NOTICE '表数量: %', (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public');
END \$\$;
"

echo "✅ 迁移完成！"