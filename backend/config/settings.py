"""
Django settings for config project.
"""

from pathlib import Path
from datetime import timedelta  # 新增：用于 JWT 配置

# Build paths inside the project like this: BASE_DIR / 'subdir'
BASE_DIR = Path(__file__).resolve().parent.parent

# ==================== 安全设置 ====================
SECRET_KEY = 'django-insecure-1ddc9c!8)8l3hcmkts*4z+u(ng^!(buqlrp$h818b9co=%4l5%'
DEBUG = True
ALLOWED_HOSTS = ['localhost', '127.0.0.1']

# ==================== 应用注册 ====================
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    # 第三方应用
    'rest_framework',               # Django REST Framework
    'corsheaders',                  # 跨域支持
    'rest_framework_simplejwt',     # JWT 认证

    # 自定义应用（注意：必须先创建，再注册）
    'users',                        # 用户管理
    'orders',                       # 订单管理
]

# ==================== 中间件 ====================
MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',  # CORS 中间件（必须放在最前面）
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

# ==================== CORS 配置（允许前端跨域）====================
CORS_ALLOW_ALL_ORIGINS = True          # 开发环境允许所有来源
CORS_ALLOW_CREDENTIALS = True          # 允许携带 Cookie

# ==================== 路由配置 ====================
ROOT_URLCONF = 'config.urls'

# ==================== 模板配置 ====================
TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'config.wsgi.application'

# ==================== 数据库配置（PostgreSQL）====================
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'fxtrading',          # 数据库名（请提前创建）
        'USER': 'fxtrader',           # 用户名
        'PASSWORD': 'fxtrader123',    # 密码
        'HOST': 'localhost',          # 数据库地址（Docker 映射或宿主机）
        'PORT': '5432',
    }
}

# ==================== 密码验证 ====================
AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

# ==================== 国际化配置 ====================
LANGUAGE_CODE = 'zh-hans'
TIME_ZONE = 'Asia/Shanghai'
USE_I18N = True
USE_TZ = True

# ==================== 静态文件 ====================
STATIC_URL = 'static/'

# ==================== Django REST Framework 配置 ====================
REST_FRAMEWORK = {
    # 认证类：优先使用 JWT，其次使用 Session 和 Basic 认证（方便调试）
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
        'rest_framework.authentication.SessionAuthentication',
        'rest_framework.authentication.BasicAuthentication',
    ],
    # 权限类：默认要求认证（未登录不能访问）
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    # 分页配置：每页 20 条
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
}

# ==================== JWT 配置 ====================
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=30),   # 访问令牌有效期 30 分钟
    'REFRESH_TOKEN_LIFETIME': timedelta(days=1),      # 刷新令牌有效期 1 天
    'AUTH_HEADER_TYPES': ('Bearer',),                 # 认证头格式：Bearer <token>
}

# ==================== 自定义用户模型 ====================
AUTH_USER_MODEL = 'users.User'

# ==================== 默认主键字段类型 ====================
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'