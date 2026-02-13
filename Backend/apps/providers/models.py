# backend/apps/providers/models.py
from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator
from django.utils import timezone


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
        ('tailor', 'Tailor'),
        ('beautician', 'Beauty Services'),
        ('cook', 'Cooking Services'),
        ('tutor', 'Tutoring'),
        ('driver', 'Driver'),
        ('other', 'Other'),
    ]
    
    user = models.OneToOneField(
        'users.User',
        on_delete=models.CASCADE,
        related_name='provider_profile'
    )
    
    # Skills
    skill_categories = models.JSONField(
        default=list,
        help_text="List of skill category keys"
    )
    bio = models.TextField(blank=True, help_text="Provider description")
    experience_years = models.IntegerField(
        default=0,
        validators=[MinValueValidator(0), MaxValueValidator(50)]
    )
    
    # Trust signals - Municipal verification
    municipality_verified = models.BooleanField(default=False)
    verified_at = models.DateTimeField(null=True, blank=True)
    verified_by = models.ForeignKey(
        'users.User',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='verified_providers'
    )
    verification_notes = models.TextField(blank=True)
    
    # Trust signals - CTEVT (mock)
    ctevt_status = models.CharField(
        max_length=20,
        choices=CTEVT_STATUS_CHOICES,
        default='pending'
    )
    ctevt_certificate_upload = models.FileField(
        upload_to='certificates/',
        null=True,
        blank=True,
        help_text="Upload CTEVT certificate (PDF/Image)"
    )
    ctevt_certificate_link = models.URLField(
        null=True,
        blank=True,
        help_text="Link to online CTEVT certificate"
    )
    
    # Documents
    citizenship_photo = models.ImageField(
        upload_to='citizenship/',
        help_text="Citizenship card photo"
    )
    
    # Calculated fields (updated via signals)
    avg_rating = models.DecimalField(
        max_digits=3,
        decimal_places=2,
        default=0.00,
        validators=[MinValueValidator(0), MaxValueValidator(5)]
    )
    jobs_completed = models.IntegerField(default=0)
    total_earnings = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=0.00
    )
    
    # Profile status
    is_active = models.BooleanField(default=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'provider_profiles'
        indexes = [
            models.Index(fields=['municipality_verified', 'ctevt_status']),
            models.Index(fields=['-avg_rating']),
            models.Index(fields=['-created_at']),
        ]
        ordering = ['-avg_rating', '-jobs_completed']
    
    def __str__(self):
        return f"Provider: {self.user.name}"
    
    def get_skill_display_names(self):
        """Get human-readable skill names"""
        skill_dict = dict(self.SKILL_CATEGORIES)
        return [skill_dict.get(skill, skill) for skill in self.skill_categories]
    
    @property
    def trust_score(self):
        """Calculate basic trust score (0-100)"""
        score = 0
        if self.municipality_verified:
            score += 40
        if self.ctevt_status == 'certified':
            score += 30
        if self.avg_rating >= 4.0:
            score += 20
        if self.jobs_completed >= 10:
            score += 10
        return min(score, 100)