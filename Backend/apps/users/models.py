from django.db import models
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin

# Create your models here.
# apps/users/models.py
class User(AbstractBaseUser, PermissionsMixin):
    """Custom user with phone-based auth"""
    ROLE_CHOICES = [
        ('citizen', 'Citizen'),
        ('provider', 'Service Provider'),
        ('municipality_admin', 'Municipality Admin'),
    ]
    
    phone = models.CharField(max_length=15, unique=True)  # Primary identifier
    name = models.CharField(max_length=150)
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='citizen')
    municipality = models.ForeignKey('municipalities.Municipality', on_delete=models.PROTECT)
    photo = models.ImageField(upload_to='profiles/', null=True, blank=True)
    
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    date_joined = models.DateTimeField(auto_now_add=True)
    
    USERNAME_FIELD = 'phone'
    REQUIRED_FIELDS = ['name']
    
    class Meta:
        indexes = [
            models.Index(fields=['phone']),
            models.Index(fields=['municipality', 'role'])
        ]