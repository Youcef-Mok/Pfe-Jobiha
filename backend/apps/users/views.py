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
from apps.users.models import Utilisateur, Candidat, Recruteur, Disponibilite, Administrateur, EmailOTP, BlockedUser, RestrictedUser
from apps.users.models.settings import UserSettings
from apps.users.models.recent_search import RecentSearch
from apps.uploads.models import Media
from apps.reviews.models.evaluation import Evaluation
from apps.users.serializers import (
    RegisterCandidatSerializer, RegisterRecruteurSerializer,
    LoginSerializer, ChangePasswordSerializer,
    ForgotPasswordSerializer, ResetPasswordSerializer,
    UtilisateurSerializer, UpdateUtilisateurSerializer,
    CandidatSerializer, CandidatPublicSerializer, UpdateCandidatSerializer,
    RecruteurSerializer, RecruteurPublicSerializer, UpdateRecruteurSerializer,
    DisponibiliteSerializer, DisponibiliteRequestSerializer,
    MediaSerializer,
    UserMeSerializer, ReviewSerializer, UserSettingsSerializer,
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
    """GET / PUT  /users/me"""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        return Response(UserMeSerializer(request.user).data)

    def put(self, request):
        utilisateur = request.user

        # Update base Utilisateur fields
        base_fields = ['nom', 'prenom', 'telephone', 'latitude', 'longitude']
        for f in base_fields:
            if f in request.data:
                setattr(utilisateur, f, request.data[f])
        utilisateur.save()

        # Update child profile fields
        if hasattr(utilisateur, 'candidat'):
            c = utilisateur.candidat
            if 'competences' in request.data:
                c.competences = request.data['competences']
            if 'experience' in request.data:
                c.experience = request.data['experience']
            c.save()
        elif hasattr(utilisateur, 'recruteur'):
            r = utilisateur.recruteur
            if 'nom_structure' in request.data:
                r.nom_structure = request.data['nom_structure']
            if 'type_structure' in request.data:
                r.type_structure = request.data['type_structure']
            if 'description' in request.data:
                r.description = request.data['description']
            r.save()

        return Response(UserMeSerializer(utilisateur).data)

    # Keep PATCH as alias
    def patch(self, request):
        return self.put(request)

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
        
        candidat.save(update_fields=list(serializer.validated_data.keys()))

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
        # Disponibilite has no candidat FK — the relationship is a M2M on Candidat.
        # Create the standalone object first, then attach it via the M2M manager.
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
        medias = candidat.medias.all()
        return Response(MediaSerializer(medias, many=True).data)

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
        
        candidat = request.user.candidat
        
        media = Media.objects.create(
            candidat=candidat,
            url=url,
            type_media=type_media,
            description=description,
        )

        
        

        return Response(
            MediaSerializer(media).data,
            status=status.HTTP_201_CREATED,
        )


class PortfolioDeleteView(APIView):
    """DELETE /candidats/me/portfolio/{id}"""
    permission_classes = [IsAuthenticated, IsCandidat]

    def delete(self, request, id):
        candidat = request.user.candidat
        media = candidat.medias.filter(pk=id).first()
        if not media:
            return Response(
                {'detail': 'Not found.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        
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
        recruteur.save(update_fields=list(serializer.validated_data.keys()))

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
        telephone = idinfo.get('phone_number', '')

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
                'telephone': telephone,
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
        telephone = request.data.get('telephone', '')

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
            # nom_structure / type_structure are optional here — the Flutter
            # recruiter-profile screen collects them via PATCH /recruteurs/me.
            nom_structure = request.data.get('nom_structure', '')
            type_structure = request.data.get('type_structure', '')
            utilisateur = Recruteur.objects.create(
                nom=nom,
                prenom=prenom,
                email=email,
                mot_de_passe=make_password(None),
                est_verifie=True,
                telephone=telephone,
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
                telephone=telephone,
            )

        refresh = RefreshToken.for_user(utilisateur)
        return Response({
            'access': str(refresh.access_token),
            'refresh': str(refresh),
            'role': utilisateur.role,
            'user': UtilisateurSerializer(utilisateur).data,
        })


class ForgotPasswordView(APIView):
    """POST /auth/password/forgot"""
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = ForgotPasswordSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        email = serializer.validated_data['email']

        # Always return 200 to avoid email enumeration
        if Utilisateur.objects.filter(email=email).exists():
            otp = EmailOTP.generate(email)
            send_otp_email(email, otp.code)

        return Response({'detail': 'Si cet email existe, un code a été envoyé.'})


class ResetPasswordView(APIView):
    """POST /auth/password/reset"""
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = ResetPasswordSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        try:
            otp = EmailOTP.objects.get(email=data['email'], code=data['otp'])
        except EmailOTP.DoesNotExist:
            return Response(
                {'detail': 'Code invalide ou expiré.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if otp.is_expired:
            otp.delete()
            return Response(
                {'detail': 'Code expiré. Veuillez en demander un nouveau.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            utilisateur = Utilisateur.objects.get(email=data['email'])
        except Utilisateur.DoesNotExist:
            return Response(
                {'detail': 'Utilisateur introuvable.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        utilisateur.mot_de_passe = make_password(data['nouveau_mot_de_passe'])
        utilisateur.save(update_fields=['mot_de_passe'])
        otp.delete()

        return Response(status=status.HTTP_204_NO_CONTENT)



# __ Blocked users ______________________________________________


class DeactivateAccountView(APIView):
    """POST /users/me/deactivate"""
    permission_classes = [IsAuthenticated]

    def post(self, request):
        utilisateur = request.user
        utilisateur.statut_compte = 'inactif'
        utilisateur.save(update_fields=['statut_compte'])
        return Response(status=status.HTTP_204_NO_CONTENT)


class BlockedUsersView(APIView):
    """GET /users/me/blocked  — list blocked users
       POST /users/me/blocked  — block a user
       DELETE /users/me/blocked/{id} — unblock a user
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        blocked = BlockedUser.objects.filter(
            bloqueur=request.user
        ).select_related('bloque')
        data = [
            {
                'id':          b.bloque.id,
                'nom':         b.bloque.nom,
                'prenom':      b.bloque.prenom,
                # Flutter BlockedUserModel.fromJson reads 'avatar' as String?
                'avatar':      None,
                'date_blocage': b.date_blocage,
            }
            for b in blocked
        ]
        return Response(data)

    def post(self, request):
        bloque_id = request.data.get('user_id')
        if not bloque_id:
            return Response(
                {'detail': 'user_id is required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        if bloque_id == request.user.pk:
            return Response(
                {'detail': 'You cannot block yourself.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        try:
            bloque = Utilisateur.objects.get(pk=bloque_id)
        except Utilisateur.DoesNotExist:
            return Response(
                {'detail': 'User not found.'},
                status=status.HTTP_404_NOT_FOUND,
            )
        BlockedUser.objects.get_or_create(bloqueur=request.user, bloque=bloque)
        return Response(status=status.HTTP_204_NO_CONTENT)

    def delete(self, request, id):
        deleted, _ = BlockedUser.objects.filter(
            bloqueur=request.user, bloque_id=id
        ).delete()
        if not deleted:
            return Response(
                {'detail': 'Not found.'},
                status=status.HTTP_404_NOT_FOUND,
            )
        return Response(status=status.HTTP_204_NO_CONTENT)

# __ Restricted users ______________________________________________


class RestrictedUsersView(APIView):
    """GET /users/me/restricted  — list restricted users
       POST /users/me/restricted  — restrict a user
       DELETE /users/me/restricted/{id} — unrestrict a user
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        restricted = RestrictedUser.objects.filter(
            restricteur=request.user
        ).select_related('restreint')
        data = {
            'restricted_ids': [str(r.restreint.id) for r in restricted]
        }
        return Response(data)

    def post(self, request):
        contact_id = request.data.get('contact_id')
        if not contact_id:
            return Response(
                {'detail': 'contact_id is required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        
        # Convert string to int if needed
        try:
            restreint_id = int(contact_id)
        except (ValueError, TypeError):
            return Response(
                {'detail': 'contact_id must be a valid integer.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        
        if restreint_id == request.user.pk:
            return Response(
                {'detail': 'You cannot restrict yourself.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        try:
            restreint = Utilisateur.objects.get(pk=restreint_id)
        except Utilisateur.DoesNotExist:
            return Response(
                {'detail': 'User not found.'},
                status=status.HTTP_404_NOT_FOUND,
            )
        RestrictedUser.objects.get_or_create(restricteur=request.user, restreint=restreint)
        return Response(status=status.HTTP_204_NO_CONTENT)

    def delete(self, request, id):
        deleted, _ = RestrictedUser.objects.filter(
            restricteur=request.user, restreint_id=id
        ).delete()
        if not deleted:
            return Response(
                {'detail': 'Not found.'},
                status=status.HTTP_404_NOT_FOUND,
            )
        return Response(status=status.HTTP_204_NO_CONTENT)


#__ Push notification _____________________________________________________________

class PushNotifPrefView(APIView):
    """GET / PATCH  /users/me/preferences"""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        return Response({'push_notif_enabled': request.user.push_notif_enabled})

    def patch(self, request):
        value = request.data.get('push_notif_enabled')
        if not isinstance(value, bool):
            return Response(
                {'push_notif_enabled': ['Must be a boolean.']},
                status=status.HTTP_400_BAD_REQUEST,
            )
        request.user.push_notif_enabled = value
        request.user.save(update_fields=['push_notif_enabled'])
        return Response({'push_notif_enabled': request.user.push_notif_enabled})


# ===========================================================================
# User Reviews
# ===========================================================================

class UserListView(APIView):
    """GET /users — list all users with optional role filter"""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        queryset = Utilisateur.objects.filter(
            statut_compte='actif',
            est_verifie=True
        ).exclude(pk=request.user.pk).order_by('id')

        # Optional role filter
        role_filter = request.query_params.get('role')
        if role_filter:
            # Filter by checking child profile existence
            if role_filter == 'candidat':
                queryset = queryset.filter(candidat__isnull=False)
            elif role_filter == 'recruteur':
                queryset = queryset.filter(recruteur__isnull=False)

        paginator = StandardPagination()
        page = paginator.paginate_queryset(queryset, request)
        serializer = UtilisateurSerializer(page, many=True)
        return paginator.get_paginated_response(serializer.data)


class UserReviewsView(APIView):
    """GET /users/<id>/reviews"""
    permission_classes = [IsAuthenticated]

    def get(self, request, id):
        evaluations = Evaluation.objects.filter(
            evalue_id=id
        ).select_related('evaluateur', 'mission__candidature__offre__recruteur'
        ).order_by('-date_evaluation')
        serializer = ReviewSerializer(evaluations, many=True)
        return Response(serializer.data)


# ===========================================================================
# User CV
# ===========================================================================

class UserCvView(APIView):
    """GET /users/<id>/cv"""
    permission_classes = [IsAuthenticated]

    def get(self, request, id):
        try:
            candidat = Candidat.objects.get(pk=id)
        except Candidat.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        # TODO: source from dedicated CV models when they exist
        return Response({
            'formations': [],
            'experiences': [],
            'languages': [],
            'skills': candidat.competences or [],
        })


# ===========================================================================
# Unified Register
# ===========================================================================

class UnifiedRegisterView(APIView):
    """POST /auth/register"""
    permission_classes = [AllowAny]

    def post(self, request):
        account_type = request.data.get('account_type')
        nom = request.data.get('nom', '')
        prenom = request.data.get('prenom', '')
        email = request.data.get('email')
        mot_de_passe = request.data.get('mot_de_passe') or request.data.get('password')

        if not email or not mot_de_passe:
            return Response(
                {'detail': 'email and password are required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if Utilisateur.objects.filter(email=email).exists():
            return Response(
                {'detail': 'A user with this email already exists.'},
                status=status.HTTP_409_CONFLICT,
            )

        if account_type == 'recruiter':
            utilisateur = Recruteur.objects.create(
                nom=nom, prenom=prenom, email=email,
                mot_de_passe=make_password(mot_de_passe),
                est_verifie=True,
                nom_structure=request.data.get('nom_structure', ''),
                type_structure=request.data.get('type_structure', ''),
            )
            role = 'recruteur'
        else:
            utilisateur = Candidat.objects.create(
                nom=nom, prenom=prenom, email=email,
                mot_de_passe=make_password(mot_de_passe),
                est_verifie=True,
            )
            role = 'candidat'

        refresh = RefreshToken.for_user(utilisateur)
        return Response({
            'access_token': str(refresh.access_token),
            'user': {
                'id': utilisateur.id,
                'name': f"{utilisateur.prenom} {utilisateur.nom}",
                'account_type': role,
            },
        }, status=status.HTTP_201_CREATED)


# ===========================================================================
# Account Delete
# ===========================================================================

class AccountDeleteView(APIView):
    """DELETE /account"""
    permission_classes = [IsAuthenticated]

    def delete(self, request):
        request.user.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


# ===========================================================================
# User Settings
# ===========================================================================

class UserSettingsView(APIView):
    """GET / PUT  /settings"""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        settings_obj, _ = UserSettings.objects.get_or_create(user=request.user)
        return Response(UserSettingsSerializer(settings_obj).data)

    def put(self, request):
        settings_obj, _ = UserSettings.objects.get_or_create(user=request.user)
        serializer = UserSettingsSerializer(settings_obj, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)


class SettingsNotificationsView(APIView):
    """PUT /settings/notifications"""
    permission_classes = [IsAuthenticated]

    def put(self, request):
        enabled = request.data.get('enabled')
        if not isinstance(enabled, bool):
            return Response({'detail': 'enabled must be a boolean.'}, status=status.HTTP_400_BAD_REQUEST)
        settings_obj, _ = UserSettings.objects.get_or_create(user=request.user)
        settings_obj.notifications_enabled = enabled
        settings_obj.save(update_fields=['notifications_enabled'])
        return Response(UserSettingsSerializer(settings_obj).data)


class SettingsThemeView(APIView):
    """PUT /settings/theme"""
    permission_classes = [IsAuthenticated]

    def put(self, request):
        dark_mode = request.data.get('dark_mode')
        if not isinstance(dark_mode, bool):
            return Response({'detail': 'dark_mode must be a boolean.'}, status=status.HTTP_400_BAD_REQUEST)
        settings_obj, _ = UserSettings.objects.get_or_create(user=request.user)
        settings_obj.dark_mode = dark_mode
        settings_obj.save(update_fields=['dark_mode'])
        return Response(UserSettingsSerializer(settings_obj).data)


class SettingsLanguageView(APIView):
    """PUT /settings/language"""
    permission_classes = [IsAuthenticated]

    def put(self, request):
        language_code = request.data.get('language_code')
        if not language_code:
            return Response({'detail': 'language_code is required.'}, status=status.HTTP_400_BAD_REQUEST)
        settings_obj, _ = UserSettings.objects.get_or_create(user=request.user)
        settings_obj.language_code = language_code
        settings_obj.save(update_fields=['language_code'])
        return Response(UserSettingsSerializer(settings_obj).data)


# ===========================================================================
# Recent Searches
# ===========================================================================

class RecentSearchListView(APIView):
    """GET /searches/recent"""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        searches = RecentSearch.objects.filter(
            user=request.user
        ).order_by('-searched_at')[:10]
        return Response({'searches': [s.query for s in searches]})


class RecentSearchCreateView(APIView):
    """POST /searches — create; DELETE /searches — clear all"""
    permission_classes = [IsAuthenticated]

    def post(self, request):
        query = request.data.get('query', '').strip()
        if not query:
            return Response({'detail': 'query is required.'}, status=status.HTTP_400_BAD_REQUEST)

        from django.utils import timezone as tz
        obj, created = RecentSearch.objects.get_or_create(
            user=request.user, query=query,
            defaults={'searched_at': tz.now()}
        )
        if not created:
            obj.searched_at = tz.now()
            obj.save(update_fields=['searched_at'])

        return Response({'query': obj.query}, status=status.HTTP_201_CREATED)

    def delete(self, request):
        RecentSearch.objects.filter(user=request.user).delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


# Keep as alias
RecentSearchClearView = RecentSearchCreateView

# ===========================================================================
# Stub for not-yet-implemented endpoints
# ===========================================================================

class StubView(APIView):
    """Temporary stub — returns 501 for every HTTP method."""

    def handle(self, request, *args, **kwargs):
        return Response({'detail': 'not implemented'}, status=501)

    get = post = put = patch = delete = handle
