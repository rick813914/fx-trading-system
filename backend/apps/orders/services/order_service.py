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
        导入 CSV 订单（允许部分成功，跳过错误行）
        返回 (成功数, 错误列表)
        """
        # 1. 选择解析器
        if broker.upper() == 'MT4':
            parser = MT4Parser(file_content)
        else:
            raise ValueError(f"不支持的经纪商类型: {broker}")

        # 2. 解析
        orders_data, parse_errors = parser.parse()
        print(f"解析到的订单数据条数: {len(orders_data)}")
        print(f"解析错误: {parse_errors}")
        if not orders_data:
            raise ValidationError("没有有效数据可导入")

        # 3. 获取用户
        user = User.objects.get(id=self.user_id)

        # 4. 逐条创建订单（允许部分成功）
        created_count = 0
        db_errors = []
        for data in orders_data:
            try:
                Order.objects.create(user=user, **data)
                created_count += 1
            except Exception as e:
                db_errors.append(str(e))
                logger.warning(f"订单创建失败: {e}, 数据: {data}")

        return created_count, parse_errors + db_errors