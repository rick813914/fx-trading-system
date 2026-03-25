"""
CSV 导入功能测试（集成测试）
测试异步任务和导入 API
"""
import pytest
import time
from django.core.files.uploadedfile import SimpleUploadedFile
from rest_framework.test import APIClient
from celery.result import AsyncResult
from apps.orders.models import Order
from apps.orders.tasks import import_orders_task

@pytest.fixture
def user(db):
    from django.contrib.auth import get_user_model
    User = get_user_model()
    return User.objects.create_user(username='testuser', password='testpass123')

@pytest.fixture
def auth_client(user):
    client = APIClient()
    response = client.post('/api/token/', {'username': 'testuser', 'password': 'testpass123'})
    token = response.data['access']
    client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')
    return client


@pytest.mark.django_db
class TestCSVImport:
    """CSV 导入测试"""

    def test_import_csv_success(self, auth_client, user):
        """测试成功导入 CSV"""
        csv_content = b'''Ticket,Open Time,Type,Size,Symbol,Open Price,Close Price,Profit,Commission,Swap,Comment,Close Time
123,2024.01.01 10:00:00,0,0.01,EURUSD,1.10000,1.10500,5.00,0.00,0.00,test,2024.01.01 12:00:00
124,2024.01.02 14:30:00,1,0.02,GBPUSD,1.25000,1.24500,-10.00,0.00,0.00,example,2024.01.02 16:00:00
'''
        file = SimpleUploadedFile('test.csv', csv_content, content_type='text/csv')
        response = auth_client.post('/api/orders/import-csv/', {'file': file}, format='multipart')
        assert response.status_code == 202
        task_id = response.data['task_id']

        # 等待任务完成（简化，实际可用轮询）
        task = AsyncResult(task_id)
        while task.state == 'PENDING':
            time.sleep(0.1)
        assert task.successful()
        result = task.result
        assert result['status'] == 'success'
        assert result['created'] == 2
        assert Order.objects.count() == 2
        assert Order.objects.first().symbol == 'EURUSD'

    def test_import_csv_with_errors(self, auth_client, user):
        """测试导入包含错误行的 CSV"""
        csv_content = b'''Ticket,Open Time,Type,Size,Symbol,Open Price,Close Price,Profit,Commission,Swap,Comment,Close Time
123,invalid_date,0,0.01,EURUSD,1.10000,1.10500,5.00,0.00,0.00,test,2024.01.01 12:00:00
124,2024.01.02 14:30:00,1,0.02,GBPUSD,1.25000,1.24500,-10.00,0.00,0.00,example,2024.01.02 16:00:00
'''
        file = SimpleUploadedFile('test.csv', csv_content, content_type='text/csv')
        response = auth_client.post('/api/orders/import-csv/', {'file': file}, format='multipart')
        task_id = response.data['task_id']
        task = AsyncResult(task_id)
        while task.state == 'PENDING':
            time.sleep(0.1)
        assert task.successful()
        result = task.result
        # 事务整体回滚，所以 created=0
        assert result['status'] == 'success'
        assert result['created'] == 0
        assert len(result['errors']) > 0
        assert Order.objects.count() == 0

    def test_export_csv(self, auth_client, order_data):
        """测试导出 CSV"""
        # 先创建订单
        auth_client.post('/api/orders/', order_data)
        response = auth_client.get('/api/orders/export-csv/')
        assert response.status_code == 200
        assert response['Content-Type'] == 'text/csv'
        content = response.content.decode()
        assert 'Ticket' in content
        assert 'EURUSD' in content