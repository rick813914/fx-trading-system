"""
订单视图集
"""
from rest_framework import viewsets, permissions
from .models import Order
from .serializers import OrderSerializer

class OrderViewSet(viewsets.ModelViewSet):
    """
    订单视图集，自动提供 list, create, retrieve, update, destroy 操作。
    """
    serializer_class = OrderSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        """
        只返回当前登录用户的订单，按开仓时间倒序。
        """
        return Order.objects.filter(user=self.request.user).order_by('-open_time')

    def perform_create(self, serializer):
        """
        创建订单时自动关联当前用户。
        """
        serializer.save(user=self.request.user)

# backend/orders/views.py 末尾添加
from rest_framework.views import APIView
from rest_framework.response import Response
from .services.kpi import calculate_kpi

class KPIView(APIView):
    """
    KPI 统计视图
    """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        kpi_data = calculate_kpi(request.user.id)
        return Response(kpi_data)