# backend/apps/courses/models.py
from django.db import models
from django.core.validators import MinValueValidator


class Course(models.Model):
    """Training courses offered by municipalities"""
    
    STATUS_CHOICES = [
        ('draft', 'Draft'),
        ('open', 'Open for Enrollment'),
        ('closed', 'Closed'),
        ('completed', 'Completed'),
    ]
    
    title = models.CharField(max_length=200)
    description = models.TextField()
    municipality = models.ForeignKey(
        'municipalities.Municipality',
        on_delete=models.CASCADE,
        related_name='courses'
    )
    
    # Schedule
    start_date = models.DateField()
    end_date = models.DateField()
    
    # Capacity
    capacity = models.IntegerField(
        validators=[MinValueValidator(1)],
        help_text="Maximum number of enrollments"
    )
    
    # Status
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='draft'
    )
    
    # Metadata
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    created_by = models.ForeignKey(
        'users.User',
        on_delete=models.SET_NULL,
        null=True,
        related_name='created_courses',
        limit_choices_to={'role': 'municipality_admin'}
    )
    
    class Meta:
        db_table = 'courses'
        indexes = [
            models.Index(fields=['municipality', 'status', '-start_date']),
            models.Index(fields=['status', '-created_at']),
        ]
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.title} - {self.municipality.name}"
    
    @property
    def is_full(self):
        """Check if course has reached capacity"""
        return self.enrollments.filter(status='approved').count() >= self.capacity
    
    @property
    def available_slots(self):
        """Get number of available slots"""
        approved_count = self.enrollments.filter(status='approved').count()
        return max(0, self.capacity - approved_count)


class Enrollment(models.Model):
    """Provider enrollment in courses"""
    
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('approved', 'Approved'),
        ('rejected', 'Rejected'),
        ('withdrawn', 'Withdrawn'),
    ]
    
    course = models.ForeignKey(
        Course,
        on_delete=models.CASCADE,
        related_name='enrollments'
    )
    provider = models.ForeignKey(
        'users.User',
        on_delete=models.CASCADE,
        related_name='course_enrollments',
        limit_choices_to={'role': 'provider'}
    )
    
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='pending'
    )
    
    # Timestamps
    enrolled_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    # Optional notes
    notes = models.TextField(blank=True, help_text="Provider notes or motivation")
    admin_notes = models.TextField(blank=True, help_text="Admin review notes")
    
    class Meta:
        db_table = 'course_enrollments'
        unique_together = [('course', 'provider')]
        indexes = [
            models.Index(fields=['course', 'status']),
            models.Index(fields=['provider', '-enrolled_at']),
        ]
        ordering = ['-enrolled_at']
    
    def __str__(self):
        return f"{self.provider.name} → {self.course.title} ({self.status})"
