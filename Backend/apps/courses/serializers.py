# backend/apps/courses/serializers.py
from rest_framework import serializers
from .models import Course, Enrollment
from apps.users.serializers import SimpleUserSerializer
from apps.municipalities.serializers import MunicipalitySerializer


class CourseSerializer(serializers.ModelSerializer):
    """Full course serializer"""
    municipality_detail = MunicipalitySerializer(source='municipality', read_only=True)
    created_by_detail = SimpleUserSerializer(source='created_by', read_only=True)
    available_slots = serializers.ReadOnlyField()
    is_full = serializers.ReadOnlyField()
    enrollment_count = serializers.SerializerMethodField()
    
    class Meta:
        model = Course
        fields = [
            'id', 'title', 'description', 'municipality', 'municipality_detail',
            'start_date', 'end_date', 'capacity', 'status', 'available_slots',
            'is_full', 'enrollment_count', 'created_by', 'created_by_detail',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_by', 'created_at', 'updated_at']
    
    def get_enrollment_count(self, obj):
        return obj.enrollments.filter(status='approved').count()


class CourseListSerializer(serializers.ModelSerializer):
    """Lightweight course serializer for lists"""
    municipality_name = serializers.CharField(source='municipality.name', read_only=True)
    available_slots = serializers.ReadOnlyField()
    
    class Meta:
        model = Course
        fields = [
            'id', 'title', 'municipality_name', 'start_date', 'end_date',
            'capacity', 'available_slots', 'status', 'created_at'
        ]


class CourseCreateSerializer(serializers.ModelSerializer):
    """Course creation serializer"""
    
    class Meta:
        model = Course
        fields = [
            'title', 'description', 'municipality', 'start_date',
            'end_date', 'capacity', 'status'
        ]
    
    def validate(self, data):
        """Validate course dates"""
        if data['end_date'] < data['start_date']:
            raise serializers.ValidationError({
                'end_date': 'End date must be after start date'
            })
        return data
    
    def create(self, validated_data):
        """Set created_by from request user"""
        validated_data['created_by'] = self.context['request'].user
        return super().create(validated_data)


class EnrollmentSerializer(serializers.ModelSerializer):
    """Full enrollment serializer"""
    course_detail = CourseListSerializer(source='course', read_only=True)
    provider_detail = SimpleUserSerializer(source='provider', read_only=True)
    
    class Meta:
        model = Enrollment
        fields = [
            'id', 'course', 'course_detail', 'provider', 'provider_detail',
            'status', 'notes', 'admin_notes', 'enrolled_at', 'updated_at'
        ]
        read_only_fields = ['id', 'provider', 'status', 'admin_notes', 'enrolled_at', 'updated_at']


class EnrollmentCreateSerializer(serializers.ModelSerializer):
    """Enrollment creation serializer"""
    
    class Meta:
        model = Enrollment
        fields = ['course', 'notes']
    
    def validate_course(self, value):
        """Validate course is open and has capacity"""
        if value.status != 'open':
            raise serializers.ValidationError("Course is not open for enrollment")
        
        if value.is_full:
            raise serializers.ValidationError("Course is full")
        
        # Check if user already enrolled
        user = self.context['request'].user
        if Enrollment.objects.filter(course=value, provider=user).exists():
            raise serializers.ValidationError("You are already enrolled in this course")
        
        return value
    
    def create(self, validated_data):
        """Set provider from request user"""
        validated_data['provider'] = self.context['request'].user
        validated_data['status'] = 'pending'
        return super().create(validated_data)


class EnrollmentUpdateSerializer(serializers.ModelSerializer):
    """Admin enrollment update serializer"""
    
    class Meta:
        model = Enrollment
        fields = ['status', 'admin_notes']
    
    def validate_status(self, value):
        """Validate status transitions"""
        if self.instance and self.instance.status == 'withdrawn':
            raise serializers.ValidationError("Cannot update withdrawn enrollment")
        return value
