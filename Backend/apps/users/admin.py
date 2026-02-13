from django.contrib import admin
from .models import User

# user model ko admin ma register garne
admin.site.register(User)

