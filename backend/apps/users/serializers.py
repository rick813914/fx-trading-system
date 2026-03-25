"""
用户序列化器
"""
from rest_framework import serializers
from .models import User

class UserSerializer(serializers.ModelSerializer):
    """
    用户资料序列化器，用于获取和修改用户信息。
    """
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'timezone', 'currency']

class RegisterSerializer(serializers.ModelSerializer):
    """
    注册序列化器，用于创建新用户。
    """
    password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = User
        fields = ['username', 'email', 'password']

    def create(self, validated_data):
        """
        使用 create_user 方法，自动处理密码加密。
        """
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password']
        )
        return user