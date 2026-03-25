from django.db import models
from django.conf import settings

class Order(models.Model):
    """
    订单模型，记录一笔外汇交易。
    """
    # 方向选择：买入 / 卖出
    DIRECTION_CHOICES = (
        ('BUY', 'Buy'),
        ('SELL', 'Sell'),
    )

    # 关联用户（外键），当用户删除时，其订单也删除（级联删除）
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='orders')

    # 交易品种（货币对），如 EURUSD
    symbol = models.CharField(max_length=10)

    # 手数，支持小数，如 0.01
    volume = models.DecimalField(max_digits=10, decimal_places=2)

    # 方向：买入或卖出
    direction = models.CharField(max_length=4, choices=DIRECTION_CHOICES)

    # 开仓价
    open_price = models.DecimalField(max_digits=10, decimal_places=5)

    # 平仓价（允许为空，未平仓时为空）
    close_price = models.DecimalField(max_digits=10, decimal_places=5, null=True, blank=True)

    # 开仓时间
    open_time = models.DateTimeField()

    # 平仓时间（允许为空）
    close_time = models.DateTimeField(null=True, blank=True)

    # 盈亏金额（以基础货币计）
    profit = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    # 在 Order 类中添加字段
    ticket = models.CharField(max_length=50, blank=True, null=True, verbose_name='订单号')
    commission = models.DecimalField(max_digits=10, decimal_places=2, default=0, verbose_name='佣金')
    swap = models.DecimalField(max_digits=10, decimal_places=2, default=0, verbose_name='隔夜利息')
    comment = models.TextField(blank=True, null=True, verbose_name='备注')
    extra_data = models.JSONField(default=dict, blank=True, verbose_name='扩展数据')
    # 自动记录创建时间和更新时间
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.user.username} - {self.symbol} - {self.open_time}"