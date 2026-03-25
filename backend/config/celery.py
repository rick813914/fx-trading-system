# backend/config/celery.py
import os
from celery import Celery

# 设置 Django 环境变量
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.development')

app = Celery('config')
# 从 Django 配置中读取 Celery 相关配置
app.config_from_object('django.conf:settings', namespace='CELERY')
# 自动发现所有 app 中的 tasks.py
app.autodiscover_tasks()