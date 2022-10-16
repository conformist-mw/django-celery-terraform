from django.http import HttpResponse
from django.db import connection


def health_check_middleware(get_response):
    def middleware(request):
        # Health-check request
        if request.path == "/health/":
            # Check DB connection is healthy
            with connection.cursor() as cursor:
                cursor.execute("SELECT 1")

            return HttpResponse("Healthy!")

        # Regular requests
        return get_response(request)

    return middleware
