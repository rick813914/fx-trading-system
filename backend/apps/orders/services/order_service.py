"""
订单服务层，封装订单相关业务逻辑
"""
import logging
from typing import Tuple, List
from django.db import transaction
from django.core.exceptions import ValidationError
from django.contrib.auth import get_user_model

from ..models import Order
from ..parsers.mt4 import MT4Parser
from .kpi import calculate_kpi  # 保留原有 KPI 计算

User = get_user_model()
logger = logging.getLogger(__name__)


class OrderService:
    """订单服务类"""

    def __init__(self, user_id: int):
        self.user_id = user_id

    def import_orders_from_csv(self, file_content: bytes, filename: str, broker: str = 'MT4') -> Tuple[int, List[str]]:
        """
        导入 CSV 订单
        返回 (成功数, 错误列表)
        """
        # 1. 选择解析器
        if broker.upper() == 'MT4':
            parser = MT4Parser(file_content)
        else:
            raise ValueError(f"不支持的经纪商类型: {broker}")

        # 2. 解析
        orders_data, parse_errors = parser.parse()
        if not orders_data:
            raise ValidationError("没有有效数据可导入")

        # 3. 获取用户（用于创建订单时关联）
        try:
            user = User.objects.get(id=self.user_id)
        except User.DoesNotExist:
            raise ValidationError("用户不存在")

        # 4. 批量创建订单（使用事务，任意失败则全部回滚）
        created_count = 0
        try:
            with transaction.atomic():
                for data in orders_data:
                    # 确保 data 中没有 user 字段，否则会冲突
                    data.pop('user', None)
                    Order.objects.create(user=user, **data)
                    created_count += 1
        except Exception as e:
            logger.error(f"批量导入时发生错误，事务回滚: {e}")
            # 将错误添加到错误列表
            error_msg = f"导入失败: {str(e)}"
            parse_errors.append(error_msg)
            # 由于事务回滚，created_count 为 0，所以返回 0 和错误列表
            return 0, parse_errors

        # 5. 可选：清除相关 KPI 缓存（如果使用了缓存）
        # 示例：cache.delete(f'kpi_{self.user_id}')

        return created_count, parse_errors

    # 可以在这里添加其他业务方法，比如更新订单等