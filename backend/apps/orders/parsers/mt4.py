"""
MT4 标准 CSV 解析器
"""
import logging
from datetime import datetime
from decimal import Decimal
from django.utils import timezone
from .base import BaseCSVParser

logger = logging.getLogger(__name__)


class MT4Parser(BaseCSVParser):
    """MT4 标准 CSV 解析器"""

    # 字段映射（根据实际 MT4 导出列名调整）
    FIELD_MAPPING = {
        'Ticket': 'ticket',
        'Open Time': 'open_time',
        'Type': 'direction',
        'Size': 'volume',
        'Symbol': 'symbol',
        'Open Price': 'open_price',
        'Close Price': 'close_price',
        'Profit': 'profit',
        'Commission': 'commission',
        'Swap': 'swap',
        'Comment': 'comment',
        'Close Time': 'close_time',
    }

    def parse(self) -> tuple[list, list]:
        rows = self._read_csv()
        orders = []
        errors = []

        for row_num, row in enumerate(rows, start=2):
            try:
                data = self._parse_row(row)
                orders.append(data)
            except Exception as e:
                errors.append(f"第 {row_num} 行: {str(e)}")

        return orders, errors

    def _parse_row(self, row: dict) -> dict:
        data = {}
        # 字段映射
        for csv_field, model_field in self.FIELD_MAPPING.items():
            if csv_field in row:
                data[model_field] = row[csv_field]

        # 方向转换（MT4 Type: 0=buy, 1=sell）
        type_raw = data.get('direction', '').strip()
        if type_raw in ('0', 'buy', 'BUY'):
            data['direction'] = 'BUY'
        elif type_raw in ('1', 'sell', 'SELL'):
            data['direction'] = 'SELL'
        else:
            raise ValueError(f"未知交易方向: {type_raw}")

        # 数值字段转换
        for field in ['volume', 'open_price', 'close_price', 'profit', 'commission', 'swap']:
            if data.get(field):
                data[field] = Decimal(str(data[field]))

        # 时间字段转换
        def parse_time(time_str):
            if not time_str:
                return None
            for fmt in ('%Y.%m.%d %H:%M:%S', '%Y-%m-%d %H:%M:%S'):
                try:
                    dt = datetime.strptime(time_str, fmt)
                    return timezone.make_aware(dt)
                except ValueError:
                    continue
            raise ValueError(f"时间格式错误: {time_str}")

        data['open_time'] = parse_time(data.get('open_time'))
        if data.get('close_time'):
            data['close_time'] = parse_time(data.get('close_time'))

        # 默认值
        data.setdefault('close_price', None)
        data.setdefault('profit', 0)
        data.setdefault('commission', 0)
        data.setdefault('swap', 0)
        data.setdefault('comment', '')

        return data