# backend/apps/users/models.py
from django.db import models
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin, BaseUserManager
from django.core.validators import RegexValidator


class UserManager(BaseUserManager):
    """Custom user manager for phone-based authentication"""
    
    def create_user(self, phone, name, municipality, role='citizen', password=None, **extra_fields):
        if not phone:
            raise ValueError('Phone number is required')
        if not name:
            raise ValueError('Name is required')
        if not municipality:
            raise ValueError('Municipality is required')
        
        # Handle municipality as ID or instance
        from apps.municipalities.models import Municipality
        if isinstance(municipality, int) or isinstance(municipality, str):
            try:
                municipality = Municipality.objects.get(id=municipality)
            except Municipality.DoesNotExist:
                raise ValueError(f'Municipality with id {municipality} does not exist')
        
        user = self.model(
            phone=phone,
            name=name,
            municipality=municipality,
            role=role,
            **extra_fields
        )
        user.set_unusable_password()  # Phone-based auth, no password
        user.save(using=self._db)
        return user
    
    def create_superuser(self, phone, name, municipality, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('role', 'municipality_admin')
        
        if extra_fields.get('is_staff') is not True:
            raise ValueError('Superuser must have is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Superuser must have is_superuser=True.')
        
        user = self.create_user(phone, name, municipality, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user


class User(AbstractBaseUser, PermissionsMixin):
    """Custom user model with phone-based authentication"""
    
    ROLE_CHOICES = [
        ('citizen', 'Citizen'),
        ('provider', 'Service Provider'),
        ('municipality_admin', 'Municipality Admin'),
    ]
    
    phone_regex = RegexValidator(
        regex=r'^98\d{8}$',
        message="Phone number must be 10 digits starting with 98"
    )
    
    phone = models.CharField(
        max_length=15,
        unique=True,
        validators=[phone_regex],
        help_text="Phone number (10 digits starting with 98)"
    )
    name = models.CharField(max_length=150)
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='citizen')
    municipality = models.ForeignKey(
        'municipalities.Municipality',
        on_delete=models.PROTECT,
        related_name='users'
    )
    photo = models.ImageField(upload_to='profiles/', null=True, blank=True)
    
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    date_joined = models.DateTimeField(auto_now_add=True)
    last_login = models.DateTimeField(null=True, blank=True)
    
    objects = UserManager()
    
    USERNAME_FIELD = 'phone'
    REQUIRED_FIELDS = ['name', 'municipality']
    
    class Meta:
        db_table = 'users'
        indexes = [
            models.Index(fields=['phone']),
            models.Index(fields=['municipality', 'role']),
        ]
    
    def __str__(self):
        return f"{self.name} ({self.phone})"
    
    def get_full_name(self):
        return self.name
    
    def get_short_name(self):
        return self.name.split()[0] if self.name else ''