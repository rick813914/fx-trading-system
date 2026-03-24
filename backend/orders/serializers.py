"""
订单序列化器
"""
from rest_framework import serializers
from .models import Order

class OrderSerializer(serializers.ModelSerializer):
    """
    订单序列化器，包含所有字段，user 等字段只读。
    """
    class Meta:
        model = Order
        fields = '__all__'
        read_only_fields = ['user', 'created_at', 'updated_at']
