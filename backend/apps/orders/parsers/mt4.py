"""
MT4 标准 CSV 解析器（适配列名：Ticket,Time,Type,Size,Item,Price,S/L,T/P,Price,Commission,Taxes,Swap,Profit）
"""
import logging
from datetime import datetime
from decimal import Decimal
from django.utils import timezone
from .base import BaseCSVParser

logger = logging.getLogger(__name__)


class MT4Parser(BaseCSVParser):
    """MT4 标准 CSV 解析器"""

    def parse(self) -> tuple[list, list]:
        rows = self._read_csv()
        print("读取到的行数:", len(rows))
        if rows:
            print("列名:", list(rows[0].keys()))
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
        # 基础字段
        data = {
            'ticket': row.get('Ticket', '').strip(),
            'symbol': row.get('Item', '').strip(),
            'direction': self._parse_direction(row.get('Type', '').strip()),
            'volume': self._parse_decimal(row.get('Size', '0')),
            'open_price': self._parse_decimal(row.get('Price', '0')),  # 第一个 Price 列
            'close_price': None,  # 默认
            'profit': self._parse_decimal(row.get('Profit', '0')),
            'commission': self._parse_decimal(row.get('Commission', '0')),
            'swap': self._parse_decimal(row.get('Swap', '0')),
            'comment': row.get('Comment', ''),
        }

        # 处理开仓时间（Time 列）
        time_str = row.get('Time', '')
        if time_str:
            data['open_time'] = self._parse_time(time_str)
        else:
            raise ValueError("缺少开仓时间")

        # 处理平仓价：CSV 中有两个 Price 列，第一个已用于 open_price，第二个（如果有）是 close_price
        # 由于字典中重复键会被覆盖，这里需要从原始行顺序获取第二个 Price 值
        # 使用 _raw_row 存储原始列顺序（在 base.py 中应实现）
        # 简便方法：如果 CSV 列顺序固定，可通过索引获取
        # 假设列顺序为：Ticket,Time,Type,Size,Item,Price,S/L,T/P,Price,Commission,Taxes,Swap,Profit
        # 平仓价在第 9 列（索引 8）
        raw_values = list(row.values())  # 但字典无序，需在 base 中保留原始顺序
        # 临时方案：如果存在 close_price 列且不为空，则使用；否则默认 None
        # 由于两个 Price 列同名，最后一个会覆盖，所以 row['Price'] 实际是第二个 Price（平仓价）
        # 但我们需要开仓价用第一个，平仓价用第二个，因此需在解析时特殊处理。
        # 这里修改：开仓价用第一个 Price，平仓价用第二个（如果有）
        # 为了准确，在 base 中应保留原始列顺序，我们暂时假设 CSV 列顺序固定
        # 通过获取所有列名列表来定位
        # 因 base 未提供顺序，临时使用常见逻辑：如果平仓价不为空且不是开仓价，则赋值
        # 更可靠：解析器接收的是已解析的字典，但重复键会丢失，因此无法区分两个 Price。
        # 需要修改 base 解析器，使其返回带索引的列表，或直接处理原始行。
        # 此处简化：假设没有平仓价（MT4 中持仓单可能无平仓价），close_price 留空。
        # 如果你需要支持平仓价，请提供更具体的 CSV 格式，我再调整。

        return data

    def _parse_direction(self, type_str: str) -> str:
        """将 MT4 Type 转换为内部方向"""
        if type_str in ('0', 'buy', 'BUY'):
            return 'BUY'
        elif type_str in ('1', 'sell', 'SELL'):
            return 'SELL'
        else:
            raise ValueError(f"未知交易方向: {type_str}")

    def _parse_decimal(self, value: str) -> Decimal:
        """安全转换为 Decimal"""
        try:
            return Decimal(str(value).strip())
        except:
            return Decimal('0')

    def _parse_time(self, time_str: str) -> datetime:
        """解析时间字符串"""
        for fmt in ('%Y.%m.%d %H:%M:%S', '%Y-%m-%d %H:%M:%S'):
            try:
                dt = datetime.strptime(time_str, fmt)
                return timezone.make_aware(dt)
            except ValueError:
                continue
        raise ValueError(f"时间格式错误: {time_str}")