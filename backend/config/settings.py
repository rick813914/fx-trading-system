"""
Django settings for config project.
"""

from pathlib import Path

# Build paths inside the project like this: BASE_DIR / 'subdir'
BASE_DIR = Path(__file__).resolve().parent.parent


# ==================== 安全设置 ====================
# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = 'django-insecure-1ddc9c!8)8l3hcmkts*4z+u(ng^!(buqlrp$h818b9co=%4l5%'

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

# 允许前端开发服务器访问（Vite 默认运行在 5173 端口）
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
    'rest_framework',          # DRF
    'corsheaders',             # 跨域支持
    # 'django_celery_results',   # Celery 结果存储（可选）

    # 自定义应用（后续创建）
    # 'users',                 # 用户管理
    # 'orders',                # 订单管理
    # 'accounts',              # 账户管理
    # 'analysis',              # 数据分析
    # 'reports',               # 报表服务
    # 'system',                # 系统设置
]

# ==================== 中间件 ====================
MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',  # CORS 中间件（要放在最前面）
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

# ==================== CORS 配置（允许前端跨域访问）====================
# 允许所有来源（开发环境使用，生产环境需要限制）
CORS_ALLOW_ALL_ORIGINS = True

# 或者指定具体的允许来源（更安全）
# CORS_ALLOWED_ORIGINS = [
#     "http://localhost:5173",   # Vite 开发服务器
#     "http://127.0.0.1:5173",
# ]

# 允许前端携带认证信息（如 Cookie）
CORS_ALLOW_CREDENTIALS = True

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


# ==================== 数据库配置（连接到 Docker 的 PostgreSQL）====================
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',  # 改用 PostgreSQL
        'NAME': 'fxtrading',                        # 数据库名（与 docker-compose.yml 一致）
        'USER': 'fxtrader',                         # 用户名
        'PASSWORD': 'fxtrader123',                  # 密码
        'HOST': 'localhost',                        # 数据库地址（Docker 映射到宿主机）
        'PORT': '5432',                             # 端口
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
LANGUAGE_CODE = 'zh-hans'      # 改为简体中文
TIME_ZONE = 'Asia/Shanghai'    # 改为中国时区
USE_I18N = True
USE_TZ = True                   # 启用时区支持


# ==================== 静态文件 ====================
STATIC_URL = 'static/'


# ==================== DRF 配置 ====================
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.SessionAuthentication',
        'rest_framework.authentication.BasicAuthentication',
        # 后续添加 JWT 认证
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',  # 默认需要认证
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
}


# ==================== Redis 缓存配置（可选）====================
# 如果暂时不用 Redis，可以跳过这部分
# CACHES = {
#     'default': {
#         'BACKEND': 'django_redis.cache.RedisCache',
#         'LOCATION': 'redis://localhost:6379/1',
#         'OPTIONS': {
#             'CLIENT_CLASS': 'django_redis.client.DefaultClient',
#         }
#     }
# }


# ==================== Celery 配置（可选）====================
# 如果暂时不用 Celery，可以跳过这部分
# CELERY_BROKER_URL = 'redis://localhost:6379/0'
# CELERY_RESULT_BACKEND = 'django-db'
# CELERY_ACCEPT_CONTENT = ['json']
# CELERY_TASK_SERIALIZER = 'json'


# ==================== 默认主键字段类型 ====================
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'