from django.urls import path
from apps.applications import views

urlpatterns = [
    # GET/POST /applications
    path('applications', views.ApplicationsView.as_view(), name='applications-list'),

    # DELETE /applications/<id>
    path('applications/<int:id>', views.ApplicationDetailView.as_view(), name='application-detail'),

    # PUT /applications/<id>/accept
    path('applications/<int:id>/accept', views.AcceptApplicationView.as_view(), name='accept-application'),

    # PUT /applications/<id>/reject
    path('applications/<int:id>/reject', views.RejectApplicationView.as_view(), name='reject-application'),


]