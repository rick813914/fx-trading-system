"""
KPI 计算服务
"""
from decimal import Decimal
from django.db.models import Sum, Count, Q
from ..models import Order

def calculate_kpi(user_id):
    """
    计算指定用户的 KPI 指标
    """
    # 查询用户所有订单
    orders = Order.objects.filter(user_id=user_id)

    # 总订单数
    total_orders = orders.count()

    if total_orders == 0:
        return {
            'total_orders': 0,
            'total_profit': 0,
            'win_rate': 0,
            'avg_profit': 0,
            'max_profit': 0,
            'max_loss': 0,
        }

    # 总盈亏
    total_profit = orders.aggregate(total=Sum('profit'))['total'] or Decimal('0')
    # 盈利订单数
    win_orders = orders.filter(profit__gt=0).count()
    # 胜率（盈利订单数 / 总订单数）
    win_rate = round((win_orders / total_orders) * 100, 2)

    # 平均盈亏
    avg_profit = round(total_profit / total_orders, 2)

    # 最大盈利
    max_profit = orders.aggregate(max=Sum('profit'))['max'] or Decimal('0')
    # 最大亏损（取最小值，负数）
    max_loss = orders.aggregate(min=Sum('profit'))['min'] or Decimal('0')

    return {
        'total_orders': total_orders,
        'total_profit': round(total_profit, 2),
        'win_rate': win_rate,
        'avg_profit': avg_profit,
        'max_profit': round(max_profit, 2),
        'max_loss': round(max_loss, 2),
    }