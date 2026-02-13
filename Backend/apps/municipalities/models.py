# backend/apps/municipalities/models.py
from django.db import models


class Municipality(models.Model):
    """Master data for Nepal municipalities"""
    
    name = models.CharField(max_length=100, unique=True)
    district = models.CharField(max_length=100)
    province = models.CharField(max_length=50)
    created_at = models.DateTimeField(auto_now_add=True, null=True) 
    
    class Meta:
        db_table = 'municipalities'
        verbose_name_plural = "Municipalities"
        indexes = [
            models.Index(fields=['name']),
            models.Index(fields=['district']),
        ]
        ordering = ['name']
    
    def __str__(self):
        return f"{self.name}, {self.district}"