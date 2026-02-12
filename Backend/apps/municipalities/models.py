from django.db import models


# apps/municipalities/models.py
class Municipality(models.Model):
    """Master data for Nepal municipalities"""
    name = models.CharField(max_length=100, unique=True)
    district = models.CharField(max_length=100)
    province = models.CharField(max_length=50)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        indexes = [models.Index(fields=['name'])]
        verbose_name_plural = "Municipalities"