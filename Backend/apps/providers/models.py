from django.db import models

# Create your models here.
# apps/providers/models.py
class ProviderProfile(models.Model):
    """Trust Layer - Provider verification & skills"""
    CTEVT_STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('certified', 'Certified'),
        ('not_applicable', 'Not Applicable'),
    ]
    
    SKILL_CATEGORIES = [
        ('electrician', 'Electrician'),
        ('plumber', 'Plumber'),
        ('carpenter', 'Carpenter'),
        ('mason', 'Mason'),
        ('painter', 'Painter'),
        ('mechanic', 'Mechanic'),
        ('cleaner', 'Cleaning Services'),
        ('gardener', 'Gardening'),
        ('other', 'Other'),
    ]
    
    user = models.OneToOneField('users.User', on_delete=models.CASCADE, related_name='provider_profile')
    skill_categories = models.JSONField(default=list)  # List of skill keys
    
    # Trust signals
    municipality_verified = models.BooleanField(default=False)
    verified_at = models.DateTimeField(null=True, blank=True)
    verified_by = models.ForeignKey('users.User', on_delete=models.SET_NULL, null=True, related_name='verified_providers')
    
    ctevt_status = models.CharField(max_length=20, choices=CTEVT_STATUS_CHOICES, default='pending')
    ctevt_certificate_upload = models.FileField(upload_to='certificates/', null=True, blank=True)
    ctevt_certificate_link = models.URLField(null=True, blank=True)
    
    citizenship_photo = models.ImageField(upload_to='citizenship/')
    
    # Calculated fields (updated via signals/tasks)
    avg_rating = models.DecimalField(max_digits=3, decimal_places=2, default=0.00)
    jobs_completed = models.IntegerField(default=0)
    total_earnings = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        indexes = [
            models.Index(fields=['municipality_verified', 'ctevt_status']),
            models.Index(fields=['-avg_rating']),
            models.Index(fields=['user__municipality'])
        ]