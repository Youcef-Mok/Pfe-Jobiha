from django.contrib import admin

# Register your models here.
from .models import Mission, Offre

admin.site.register(Mission)
admin.site.register(Offre)
