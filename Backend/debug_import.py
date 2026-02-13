
import os
import django
import sys
import traceback

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'jansewa.settings')
django.setup()

try:
    from apps.payments.views import payment_status
    print("Import successful")
except Exception:
    traceback.print_exc()
