from django.contrib import admin

# Register your models here.
from .models import Mission, Offre, Alerte, Interview, SavedJob

admin.site.register(Mission)
admin.site.register(Offre)
admin.site.register(Alerte)
admin.site.register(Interview)
admin.site.register(SavedJob)
