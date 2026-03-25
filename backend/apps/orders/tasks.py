"""
Celery 异步任务
"""
import logging
from celery import shared_task
from django.contrib.auth import get_user_model
from .services.order_service import OrderService

User = get_user_model()
logger = logging.getLogger(__name__)


@shared_task(bind=True)
def import_orders_task(self, user_id: int, file_content: bytes, filename: str, broker: str = 'MT4'):
    """
    异步导入订单任务
    """
    try:
        user = User.objects.get(id=user_id)
    except User.DoesNotExist:
        return {'status': 'error', 'message': '用户不存在'}

    try:
        service = OrderService(user_id=user_id)
        created, errors = service.import_orders_from_csv(file_content, filename, broker)
        return {
            'status': 'success',
            'created': created,
            'errors': errors,
            'total': created + len(errors),
            'filename': filename
        }
    except Exception as e:
        logger.exception("订单导入任务执行失败")
        return {'status': 'failure', 'error': str(e)}