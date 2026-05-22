from django.contrib import admin

# Register your models here.
from .models import Signalement, Evaluation

admin.site.register(Signalement)
admin.site.register(Evaluation)
