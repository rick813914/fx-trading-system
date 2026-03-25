"""
订单 API 测试（单元测试）
测试订单 CRUD、KPI 接口以及权限控制
"""
import pytest
from decimal import Decimal
from django.contrib.auth import get_user_model
from rest_framework.test import APIClient
from apps.orders.models import Order

User = get_user_model()

@pytest.fixture
def user(db):
    """创建测试用户"""
    return User.objects.create_user(
        username='testuser',
        password='testpass123',
        email='test@example.com'
    )

@pytest.fixture
def auth_client(user):
    """已认证的 API 客户端（使用正确的登录端点）"""
    client = APIClient()
    response = client.post('/api/users/login/', {
        'username': user.username,
        'password': 'testpass123'
    })
    assert response.status_code == 200, f"登录失败: {response.content}"
    token = response.data['access']
    client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')
    return client

@pytest.fixture
def order_data(user):
    """订单测试数据"""
    return {
        'symbol': 'EURUSD',
        'volume': '1.0',
        'direction': 'BUY',
        'open_price': '1.10000',
        'open_time': '2024-01-01T10:00:00Z',
        'profit': '0',
    }


@pytest.mark.django_db
class TestOrderAPI:
    """订单 CRUD 测试"""

    def test_create_order(self, auth_client, order_data):
        """测试创建订单"""
        response = auth_client.post('/api/orders/', order_data)
        assert response.status_code == 201
        assert Order.objects.count() == 1
        order = Order.objects.first()
        assert order.symbol == 'EURUSD'
        assert order.user.username == 'testuser'

    def test_list_orders(self, auth_client, order_data):
        """测试获取订单列表"""
        auth_client.post('/api/orders/', order_data)
        auth_client.post('/api/orders/', {**order_data, 'symbol': 'GBPUSD'})
        response = auth_client.get('/api/orders/')
        assert response.status_code == 200
        assert response.data['count'] == 2
        assert len(response.data['results']) == 2

    def test_update_order(self, auth_client, order_data):
        """测试更新订单"""
        create_resp = auth_client.post('/api/orders/', order_data)
        order_id = create_resp.data['id']
        update_data = {'profit': '100.00', 'close_price': '1.10500'}
        response = auth_client.patch(f'/api/orders/{order_id}/', update_data)
        assert response.status_code == 200
        order = Order.objects.get(id=order_id)
        assert order.profit == 100.00
        assert order.close_price == Decimal('1.10500')

    def test_delete_order(self, auth_client, order_data):
        """测试删除订单"""
        create_resp = auth_client.post('/api/orders/', order_data)
        order_id = create_resp.data['id']
        response = auth_client.delete(f'/api/orders/{order_id}/')
        assert response.status_code == 204
        assert Order.objects.count() == 0

    def test_filter_orders(self, auth_client, order_data):
        """测试筛选功能"""
        auth_client.post('/api/orders/', order_data)
        auth_client.post('/api/orders/', {**order_data, 'symbol': 'GBPUSD'})
        response = auth_client.get('/api/orders/?symbol=EURUSD')
        assert response.data['count'] == 1
        assert response.data['results'][0]['symbol'] == 'EURUSD'

    def test_kpi_view(self, auth_client, order_data):
        """测试 KPI 统计接口"""
        # 创建盈利订单
        auth_client.post('/api/orders/', {**order_data, 'profit': '100'})
        # 创建亏损订单
        auth_client.post('/api/orders/', {**order_data, 'profit': '-50'})
        response = auth_client.get('/api/kpi/')
        assert response.status_code == 200
        assert response.data['total_profit'] == 50.00
        assert response.data['win_rate'] == 50.0

    def test_permission_isolation(self, auth_client, order_data, user):
        """测试用户只能访问自己的订单"""
        # 创建另一个用户
        other_user = User.objects.create_user(username='other', password='pass')
        other_client = APIClient()
        resp = other_client.post('/api/users/login/', {'username': 'other', 'password': 'pass'})
        token = resp.data['access']
        other_client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')

        # 用第一个用户创建订单
        auth_client.post('/api/orders/', order_data)
        # 第二个用户尝试获取列表
        response = other_client.get('/api/orders/')
        assert response.data['count'] == 0
        # 尝试访问第一个用户的订单
        order = Order.objects.first()
        response = other_client.get(f'/api/orders/{order.id}/')
        assert response.status_code == 404