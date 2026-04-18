"""
Views for the Auth + Profiles module.
All endpoints, request/response shapes, and status codes match the OpenAPI spec.
"""
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth.hashers import make_password, check_password
from django.core.files.storage import default_storage
from django.core.mail import send_mail
from django.conf import settings
from google.oauth2 import id_token
from google.auth.transport import requests as google_requests
from apps.users.models import Utilisateur, Candidat, Recruteur, Disponibilite, Administrateur, EmailOTP
from apps.uploads.models import Media
from apps.users.serializers import (
    RegisterCandidatSerializer, RegisterRecruteurSerializer,
    LoginSerializer, ChangePasswordSerializer,
    UtilisateurSerializer, UpdateUtilisateurSerializer,
    CandidatSerializer, CandidatPublicSerializer, UpdateCandidatSerializer,
    RecruteurSerializer, RecruteurPublicSerializer, UpdateRecruteurSerializer,
    DisponibiliteSerializer, DisponibiliteRequestSerializer,
    MediaSerializer,
)
from core.permissions import IsCandidat, IsRecruteur, IsAdmin
from core.pagination import StandardPagination


# ===========================================================================
# Helpers
# ===========================================================================

def send_otp_email(email, code):
    """Send the OTP code via email (console backend in dev)."""
    send_mail(
        subject='Jobiha — Code de vérification',
        message=f'Votre code de vérification est : {code}',
        from_email=settings.DEFAULT_FROM_EMAIL,
        recipient_list=[email],
        fail_silently=False,
    )


# ===========================================================================
# Auth endpoints
# ===========================================================================

class RegisterCandidatView(APIView):
    """POST /auth/register/candidat"""
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RegisterCandidatSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        # 409 Conflict — email already registered
        if Utilisateur.objects.filter(email=data['email']).exists():
            return Response(
                {'detail': 'A user with this email already exists.'},
                status=status.HTTP_409_CONFLICT,
            )

        # Create Candidat with est_verifie=False (default)
        candidat = Candidat(
            nom=data['nom'],
            prenom=data['prenom'],
            email=data['email'],
            mot_de_passe=make_password(data['mot_de_passe']),
            telephone=data.get('telephone', ''),
            latitude=data.get('latitude'),
            longitude=data.get('longitude'),
            competences=data.get('competences', []),
            experience=data.get('experience', ''),
        )
        candidat.save()

        # Generate and send OTP
        otp = EmailOTP.generate(data['email'])
        send_otp_email(data['email'], otp.code)

        return Response({
            'verification_required': True,
            'role': 'candidat',
        }, status=status.HTTP_201_CREATED)


class RegisterRecruteurView(APIView):
    """POST /auth/register/recruteur"""
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RegisterRecruteurSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        if Utilisateur.objects.filter(email=data['email']).exists():
            return Response(
                {'detail': 'A user with this email already exists.'},
                status=status.HTTP_409_CONFLICT,
            )

        recruteur = Recruteur(
            nom=data['nom'],
            prenom=data['prenom'],
            email=data['email'],
            mot_de_passe=make_password(data['mot_de_passe']),
            telephone=data.get('telephone', ''),
            latitude=data.get('latitude'),
            longitude=data.get('longitude'),
            nom_structure=data['nom_structure'],
            type_structure=data['type_structure'],
            description=data.get('description', ''),
        )
        recruteur.save()

        # Generate and send OTP
        otp = EmailOTP.generate(data['email'])
        send_otp_email(data['email'], otp.code)

        return Response({
            'verification_required': True,
            'role': 'recruteur',
        }, status=status.HTTP_201_CREATED)


class LoginView(APIView):
    """POST /auth/login"""
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        try:
            utilisateur = Utilisateur.objects.get(email=data['email'])
        except Utilisateur.DoesNotExist:
            return Response(
                {'detail': 'Invalid email or password.'},
                status=status.HTTP_401_UNAUTHORIZED,
            )

        if not check_password(data['mot_de_passe'], utilisateur.mot_de_passe):
            return Response(
                {'detail': 'Invalid email or password.'},
                status=status.HTTP_401_UNAUTHORIZED,
            )

        if utilisateur.statut_compte != 'actif':
            return Response(
                {'detail': 'Account is disabled.'},
                status=status.HTTP_401_UNAUTHORIZED,
            )

        # Block unverified users
        if not utilisateur.est_verifie:
            return Response(
                {'detail': 'Email not verified. Please verify your email first.'},
                status=status.HTTP_403_FORBIDDEN,
            )

        refresh = RefreshToken.for_user(utilisateur)

        return Response({
            'access': str(refresh.access_token),
            'refresh': str(refresh),
            'role': utilisateur.role,
            'user': UtilisateurSerializer(utilisateur).data,
        })


class LogoutView(APIView):
    """POST /auth/logout — stateless logout (client discards tokens)."""
    permission_classes = [IsAuthenticated]

    def post(self, request):
        return Response(status=status.HTTP_204_NO_CONTENT)


class CustomTokenRefreshView(APIView):
    """POST /auth/token/refresh"""
    permission_classes = [AllowAny]

    def post(self, request):
        refresh_token = request.data.get('refresh')
        if not refresh_token:
            return Response(
                {'detail': 'Refresh token is required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        try:
            refresh = RefreshToken(refresh_token)
            return Response({'access': str(refresh.access_token)})
        except Exception:
            return Response(
                {'detail': 'Token is invalid or expired.'},
                status=status.HTTP_401_UNAUTHORIZED,
            )


class ChangePasswordView(APIView):
    """POST /auth/password/change"""
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = ChangePasswordSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        utilisateur = request.user

        if not check_password(data['ancien_mot_de_passe'], utilisateur.mot_de_passe):
            return Response(
                {'ancien_mot_de_passe': ['Old password is incorrect.']},
                status=status.HTTP_400_BAD_REQUEST,
            )

        utilisateur.mot_de_passe = make_password(data['nouveau_mot_de_passe'])
        utilisateur.save(update_fields=['mot_de_passe'])

        return Response(status=status.HTTP_204_NO_CONTENT)


class VerifyEmailView(APIView):
    """POST /auth/verify-email"""
    permission_classes = [AllowAny]

    def post(self, request):
        email = request.data.get('email')
        otp_code = request.data.get('otp')

        if not email or not otp_code:
            return Response(
                {'detail': 'Email and OTP are required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            otp = EmailOTP.objects.get(email=email, code=otp_code)
        except EmailOTP.DoesNotExist:
            return Response(
                {'detail': 'Invalid or expired OTP.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if otp.is_expired:
            otp.delete()
            return Response(
                {'detail': 'OTP has expired. Please request a new one.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Mark user as verified
        try:
            utilisateur = Utilisateur.objects.get(email=email)
        except Utilisateur.DoesNotExist:
            return Response(
                {'detail': 'User not found.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        utilisateur.est_verifie = True
        utilisateur.save(update_fields=['est_verifie'])
        otp.delete()

        # Issue JWT tokens now that user is verified
        refresh = RefreshToken.for_user(utilisateur)

        return Response({
            'access': str(refresh.access_token),
            'refresh': str(refresh),
            'role': utilisateur.role,
            'user': UtilisateurSerializer(utilisateur).data,
        })


class ResendOtpView(APIView):
    """POST /auth/resend-otp"""
    permission_classes = [AllowAny]

    def post(self, request):
        email = request.data.get('email')

        if not email:
            return Response(
                {'detail': 'Email is required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if not Utilisateur.objects.filter(email=email).exists():
            return Response(
                {'detail': 'User not found.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        otp = EmailOTP.generate(email)
        send_otp_email(email, otp.code)

        return Response({'detail': 'OTP sent.'})


# ===========================================================================
# Users endpoints
# ===========================================================================

class UserMeView(APIView):
    """GET / PATCH  /users/me"""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        return Response(UtilisateurSerializer(request.user).data)

    def patch(self, request):
        serializer = UpdateUtilisateurSerializer(data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)

        utilisateur = request.user
        for field, value in serializer.validated_data.items():
            setattr(utilisateur, field, value)
        utilisateur.save()

        return Response(UtilisateurSerializer(utilisateur).data)


# ===========================================================================
# Candidat endpoints
# ===========================================================================

class CandidatMeView(APIView):
    """GET / PATCH  /candidats/me"""
    permission_classes = [IsAuthenticated, IsCandidat]

    def get(self, request):
        candidat = request.user.candidat
        return Response(CandidatSerializer(candidat).data)

    def patch(self, request):
        candidat = request.user.candidat
        serializer = UpdateCandidatSerializer(data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)

        for field, value in serializer.validated_data.items():
            setattr(candidat, field, value)
        candidat.save()

        return Response(CandidatSerializer(candidat).data)


class CandidatByIdView(APIView):
    """GET /candidats/{id}"""
    permission_classes = [IsAuthenticated]

    def get(self, request, id):
        try:
            candidat = Candidat.objects.get(pk=id)
        except Candidat.DoesNotExist:
            return Response(
                {'detail': 'Not found.'},
                status=status.HTTP_404_NOT_FOUND,
            )
        return Response(CandidatPublicSerializer(candidat).data)


# ===========================================================================
# Disponibilite endpoints
# ===========================================================================

class DisponibiliteListCreateView(APIView):
    """GET / POST  /candidats/me/disponibilites"""
    permission_classes = [IsAuthenticated, IsCandidat]

    def get(self, request):
        candidat = request.user.candidat
        disponibilites = candidat.disponibilites.all()
        return Response(DisponibiliteSerializer(disponibilites, many=True).data)

    def post(self, request):
        serializer = DisponibiliteRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        candidat = request.user.candidat
        disponibilite = Disponibilite.objects.create(**serializer.validated_data)
        candidat.disponibilites.add(disponibilite)

        return Response(
            DisponibiliteSerializer(disponibilite).data,
            status=status.HTTP_201_CREATED,
        )


class DisponibiliteDetailView(APIView):
    """PUT / DELETE  /candidats/me/disponibilites/{id}"""
    permission_classes = [IsAuthenticated, IsCandidat]

    def put(self, request, id):
        candidat = request.user.candidat
        disponibilite = candidat.disponibilites.filter(pk=id).first()
        if not disponibilite:
            return Response(
                {'detail': 'Not found.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        serializer = DisponibiliteRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        for field, value in serializer.validated_data.items():
            setattr(disponibilite, field, value)
        disponibilite.save()

        return Response(DisponibiliteSerializer(disponibilite).data)

    def delete(self, request, id):
        candidat = request.user.candidat
        disponibilite = candidat.disponibilites.filter(pk=id).first()
        if not disponibilite:
            return Response(
                {'detail': 'Not found.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        candidat.disponibilites.remove(disponibilite)
        disponibilite.delete()

        return Response(status=status.HTTP_204_NO_CONTENT)


# ===========================================================================
# Portfolio endpoints
# ===========================================================================

class PortfolioListCreateView(APIView):
    """GET / POST  /candidats/me/portfolio"""
    permission_classes = [IsAuthenticated, IsCandidat]
    parser_classes = [MultiPartParser, FormParser]

    def get(self, request):
        candidat = request.user.candidat
        portfolio = candidat.portfolio.all()
        return Response(MediaSerializer(portfolio, many=True).data)

    def post(self, request):
        fichier = request.FILES.get('fichier')
        type_media = request.data.get('type_media')
        description = request.data.get('description', '')

        # Validate required fields
        errors = {}
        if not fichier:
            errors['fichier'] = ['This field is required.']
        if not type_media:
            errors['type_media'] = ['This field is required.']
        if errors:
            return Response(errors, status=status.HTTP_400_BAD_REQUEST)

        if type_media not in ('image', 'video', 'document'):
            return Response(
                {'type_media': ['Must be one of: image, video, document.']},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Save file and build URL
        path = default_storage.save(f'portfolio/{fichier.name}', fichier)
        url = request.build_absolute_uri(settings.MEDIA_URL + path)

        media = Media.objects.create(
            url=url,
            type=type_media,
            description=description,
        )

        candidat = request.user.candidat
        candidat.portfolio.add(media)

        return Response(
            MediaSerializer(media).data,
            status=status.HTTP_201_CREATED,
        )


class PortfolioDeleteView(APIView):
    """DELETE /candidats/me/portfolio/{id}"""
    permission_classes = [IsAuthenticated, IsCandidat]

    def delete(self, request, id):
        candidat = request.user.candidat
        media = candidat.portfolio.filter(pk=id).first()
        if not media:
            return Response(
                {'detail': 'Not found.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        candidat.portfolio.remove(media)
        media.delete()

        return Response(status=status.HTTP_204_NO_CONTENT)


# ===========================================================================
# Recruteur endpoints
# ===========================================================================

class RecruteurMeView(APIView):
    """GET / PATCH  /recruteurs/me"""
    permission_classes = [IsAuthenticated, IsRecruteur]

    def get(self, request):
        recruteur = request.user.recruteur
        return Response(RecruteurSerializer(recruteur).data)

    def patch(self, request):
        recruteur = request.user.recruteur
        serializer = UpdateRecruteurSerializer(data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)

        for field, value in serializer.validated_data.items():
            setattr(recruteur, field, value)
        recruteur.save()

        return Response(RecruteurSerializer(recruteur).data)


class RecruteurByIdView(APIView):
    """GET /recruteurs/{id}"""
    permission_classes = [IsAuthenticated]

    def get(self, request, id):
        try:
            recruteur = Recruteur.objects.get(pk=id)
        except Recruteur.DoesNotExist:
            return Response(
                {'detail': 'Not found.'},
                status=status.HTTP_404_NOT_FOUND,
            )
        return Response(RecruteurPublicSerializer(recruteur).data)


# ===========================================================================
# Admin endpoints
# ===========================================================================

class AdminUserListView(APIView):
    """GET /admin/utilisateurs"""
    permission_classes = [IsAuthenticated, IsAdmin]

    def get(self, request):
        queryset = Utilisateur.objects.all().order_by('id')

        # Optional filters from query params
        statut = request.query_params.get('statut_compte')
        if statut:
            queryset = queryset.filter(statut_compte=statut)

        est_verifie = request.query_params.get('est_verifie')
        if est_verifie is not None:
            queryset = queryset.filter(est_verifie=est_verifie.lower() == 'true')

        paginator = StandardPagination()
        page = paginator.paginate_queryset(queryset, request)
        serializer = UtilisateurSerializer(page, many=True)
        return paginator.get_paginated_response(serializer.data)


class AdminSanctionView(APIView):
    """POST /admin/utilisateurs/{id}/sanctionner"""
    permission_classes = [IsAuthenticated, IsAdmin]

    def post(self, request, id):
        try:
            utilisateur = Utilisateur.objects.get(pk=id)
        except Utilisateur.DoesNotExist:
            return Response(
                {'detail': 'Not found.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        action = request.data.get('action')
        if action not in ('suspendre', 'bloquer', 'reactiver'):
            return Response(
                {'action': ['Must be one of: suspendre, bloquer, reactiver.']},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if action == 'suspendre':
            utilisateur.statut_compte = 'suspendu'
        elif action == 'bloquer':
            utilisateur.statut_compte = 'banni'
        elif action == 'reactiver':
            utilisateur.statut_compte = 'actif'

        utilisateur.save(update_fields=['statut_compte'])

        return Response(UtilisateurSerializer(utilisateur).data)




class GoogleLoginView(APIView):
    """POST /auth/google"""
    permission_classes = [AllowAny]

    def post(self, request):
        token = request.data.get('token')  # Google ID token from frontend
        if not token:
            return Response({'detail': 'Token is required.'}, status=400)

        try:
            # Verify the token with Google
            idinfo = id_token.verify_oauth2_token(
                token,
                google_requests.Request(),
                settings.GOOGLE_CLIENT_ID
            )
        except ValueError:
            return Response({'detail': 'Invalid Google token.'}, status=401)

        email = idinfo.get('email')
        nom = idinfo.get('family_name', '')
        prenom = idinfo.get('given_name', '')

        # Existing user → issue JWT immediately
        try:
            utilisateur = Utilisateur.objects.get(email=email)
        except Utilisateur.DoesNotExist:
            # New user → ask frontend to pick a role first
            return Response({
                'requires_role_selection': True,
                'email': email,
                'nom': nom,
                'prenom': prenom,
            }, status=200)

        # Issue your JWT
        refresh = RefreshToken.for_user(utilisateur)
        return Response({
            'access': str(refresh.access_token),
            'refresh': str(refresh),
            'role': utilisateur.role,
            'user': UtilisateurSerializer(utilisateur).data,
        })


class GoogleCompleteView(APIView):
    """POST /auth/google/complete
    Creates the user after Google sign-in once the role has been chosen.
    """
    permission_classes = [AllowAny]

    def post(self, request):
        email = request.data.get('email')
        nom = request.data.get('nom', '')
        prenom = request.data.get('prenom', '')
        role = request.data.get('role')

        if not email or role not in ('candidat', 'recruteur'):
            return Response(
                {'detail': 'email and role (candidat|recruteur) are required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Prevent duplicate accounts
        if Utilisateur.objects.filter(email=email).exists():
            return Response(
                {'detail': 'A user with this email already exists.'},
                status=status.HTTP_409_CONFLICT,
            )

        if role == 'recruteur':
            nom_structure = request.data.get('nom_structure')
            type_structure = request.data.get('type_structure')
            if not nom_structure or not type_structure:
                return Response(
                    {'detail': 'nom_structure and type_structure are required for recruteur.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            utilisateur = Recruteur.objects.create(
                nom=nom,
                prenom=prenom,
                email=email,
                mot_de_passe=make_password(None),
                est_verifie=True,
                telephone='',
                nom_structure=nom_structure,
                type_structure=type_structure,
            )
        else:
            utilisateur = Candidat.objects.create(
                nom=nom,
                prenom=prenom,
                email=email,
                mot_de_passe=make_password(None),
                est_verifie=True,
                telephone='',
            )

        refresh = RefreshToken.for_user(utilisateur)
        return Response({
            'access': str(refresh.access_token),
            'refresh': str(refresh),
            'role': utilisateur.role,
            'user': UtilisateurSerializer(utilisateur).data,
        })


