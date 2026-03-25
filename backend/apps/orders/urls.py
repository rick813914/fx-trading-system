"""
订单路由
"""
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import OrderViewSet, KPIView, ImportStatusView

router = DefaultRouter()
router.register(r'orders', OrderViewSet, basename='order')

urlpatterns = [
    path('', include(router.urls)),
    path('kpi/', KPIView.as_view(), name='kpi'),  # 新增 KPI 路由
    path('orders/import-status/<str:task_id>/', ImportStatusView.as_view(), name='import-status'),  # 新增
]