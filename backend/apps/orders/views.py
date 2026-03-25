"""
订单视图集
"""
import csv
from django.http import HttpResponse
from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.views import APIView
from celery.result import AsyncResult
from core.permissions import IsOwner
from .models import Order
from .serializers import OrderSerializer
from .services.kpi import calculate_kpi
from .tasks import import_orders_task
from .services.order_service import OrderService


class OrderViewSet(viewsets.ModelViewSet):
    """
    订单视图集，自动提供 list, create, retrieve, update, destroy 操作。
    并添加自定义导入导出接口。
    """
    serializer_class = OrderSerializer
    permission_classes = [permissions.IsAuthenticated, IsOwner]

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

    # ==================== 新增：CSV 导入导出功能 ====================
    @action(detail=False, methods=['post'], url_path='import-csv')
    def import_csv(self, request):
        """
        导入 CSV 订单（异步任务）
        """
        file_obj = request.FILES.get('file')
        if not file_obj:
            return Response({'error': '未提供文件'}, status=status.HTTP_400_BAD_REQUEST)

        if not file_obj.name.endswith('.csv'):
            return Response({'error': '只支持 CSV 文件'}, status=status.HTTP_400_BAD_REQUEST)

        # 读取文件内容
        content = file_obj.read()

        # 启动异步任务
        task = import_orders_task.delay(
            user_id=request.user.id,
            file_content=content,
            filename=file_obj.name,
            broker='MT4'  # 可扩展
        )

        return Response({
            'task_id': task.id,
            'message': '导入任务已开始'
        }, status=status.HTTP_202_ACCEPTED)

    @action(detail=False, methods=['get'], url_path='import-status/(?P<task_id>[^/.]+)')
    def import_status(self, request, task_id):
        """
        查询导入任务状态
        """
        task = AsyncResult(task_id)
        if task.pending:
            return Response({'state': 'PENDING'})
        elif task.failed():
            return Response({'state': 'FAILURE', 'error': str(task.info)})
        elif task.successful():
            return Response({'state': 'SUCCESS', 'result': task.result})
        else:
            return Response({'state': task.state})

    @action(detail=False, methods=['get'], url_path='export-csv')
    def export_csv(self, request):
        """
        导出订单为 CSV 文件
        """
        orders = self.get_queryset()
        response = HttpResponse(content_type='text/csv')
        response['Content-Disposition'] = 'attachment; filename="orders_export.csv"'

        writer = csv.writer(response)
        writer.writerow([
            'Ticket', 'Symbol', 'Direction', 'Volume', 'Open Price', 'Close Price',
            'Open Time', 'Close Time', 'Profit', 'Commission', 'Swap', 'Comment'
        ])

        for order in orders:
            writer.writerow([
                order.ticket or '',
                order.symbol,
                order.direction,
                order.volume,
                order.open_price,
                order.close_price or '',
                order.open_time.strftime('%Y-%m-%d %H:%M:%S') if order.open_time else '',
                order.close_time.strftime('%Y-%m-%d %H:%M:%S') if order.close_time else '',
                order.profit,
                order.commission,
                order.swap,
                order.comment or ''
            ])

        return response


class KPIView(APIView):
    """
    KPI 统计视图
    """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        kpi_data = calculate_kpi(request.user.id)
        return Response(kpi_data)