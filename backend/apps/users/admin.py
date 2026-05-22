from django.contrib import admin

# Register your models here.

from .models import Utilisateur, Candidat, Recruteur, Administrateur, Disponibilite

admin.site.register(Utilisateur)
admin.site.register(Candidat)
admin.site.register(Recruteur)
admin.site.register(Administrateur)
admin.site.register(Disponibilite)