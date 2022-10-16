from django.contrib import admin
from django.urls import path

from core.views import create_web_task

admin.site.site_header = 'Django Messages'

urlpatterns = [
    path('admin/', admin.site.urls),
    path('create-task', create_web_task),
]
