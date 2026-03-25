# backend/core/permissions.py
from rest_framework import permissions

class IsOwner(permissions.BasePermission):
    """
    自定义权限：只允许用户访问自己的资源。
    假设资源有一个 `user` 字段关联到用户模型。
    """

    def has_object_permission(self, request, view, obj):
        # 检查对象是否有 user 属性，并且等于当前请求的用户
        return hasattr(obj, 'user') and obj.user == request.user

    def has_permission(self, request, view):
        # 对于列表等集合视图，允许通过（后续会在对象级权限中检查）
        return True