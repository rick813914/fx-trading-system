"""
项目根路由
"""
from django.contrib import admin
from django.urls import include, path

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/users/', include('apps.users.urls')),   # 用户 API
    path('api/', include('apps.orders.urls')),        # 订单 API（因为 orders.urls 中路由以 orders/ 开头）
]