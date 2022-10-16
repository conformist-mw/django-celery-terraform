from django.http import HttpResponse
from django_aws.tasks import web_task


def create_web_task(request):
    web_task.delay()
    return HttpResponse("Task added")
