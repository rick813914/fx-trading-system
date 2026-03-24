from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    """
    自定义用户模型，扩展 Django 默认的用户表。
    添加两个字段：时区和默认货币，供后续个性化设置使用。
    """
    # 用户时区，例如 'Asia/Shanghai'，默认 UTC
    timezone = models.CharField(max_length=50, default='UTC')
    # 用户默认货币，例如 'USD'，用于显示金额
    currency = models.CharField(max_length=3, default='USD')

    def __str__(self):
        return self.username