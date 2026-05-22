"""
OTP model — stores a 6-digit code per email for email verification.
Codes expire after 10 minutes.
"""
import random
import string
from django.db import models
from django.utils import timezone
from datetime import timedelta


class EmailOTP(models.Model):
    email = models.EmailField()
    code = models.CharField(max_length=6)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "email_otp"

    def __str__(self):
        return f"OTP for {self.email}"

    @property
    def is_expired(self):
        return timezone.now() > self.created_at + timedelta(minutes=10)

    @classmethod
    def generate(cls, email):
        """Delete old OTPs for this email, create a new one."""
        cls.objects.filter(email=email).delete()
        code = ''.join(random.choices(string.digits, k=6))
        return cls.objects.create(email=email, code=code)
