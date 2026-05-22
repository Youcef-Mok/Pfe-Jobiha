"""
Placeholder Image Generator for Jobiha Seed Data
Run this script from the backend directory: python create_placeholder_images.py
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_placeholder(path, text, color, size=(800, 600)):
    """Create a placeholder image with text"""
    # Ensure directory exists
    os.makedirs(os.path.dirname(path), exist_ok=True)
    
    # Create image
    img = Image.new('RGB', size, color=color)
    draw = ImageDraw.Draw(img)
    
    # Try to use a nice font, fallback to default
    try:
        font = ImageFont.truetype("arial.ttf", 40 if size[0] > 400 else 20)
    except:
        font = ImageFont.load_default()
    
    # Calculate text position (center)
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    position = ((size[0] - text_width) // 2, (size[1] - text_height) // 2)
    
    # Draw text
    draw.text(position, text, fill='white', font=font)
    
    # Save image
    img.save(path, quality=85)
    print(f"✓ Created: {path}")

def main():
    print("🎨 Creating placeholder images for Jobiha seed data...\n")
    
    # Avatar colors (diverse palette)
    avatar_colors = [
        '#3498db',  # Blue
        '#e74c3c',  # Red
        '#2ecc71',  # Green
        '#f39c12',  # Orange
        '#9b59b6',  # Purple
        '#1abc9c',  # Turquoise
        '#34495e',  # Dark gray
        '#e67e22',  # Carrot
        '#95a5a6',  # Gray
        '#c0392b',  # Dark red
        '#16a085',  # Dark turquoise
        '#27ae60',  # Dark green
        '#2980b9',  # Dark blue
        '#8e44ad',  # Dark purple
        '#d35400',  # Pumpkin
    ]
    
    # Create DEMO avatars (special for presentation)
    print("🎯 Creating DEMO user avatars...")
    create_placeholder(
        'media/avatars/demo_candidat.jpg',
        'Amina\nBenali',
        '#2ecc71',  # Green - success/candidate
        (300, 300)
    )
    create_placeholder(
        'media/avatars/demo_recruteur.jpg',
        'Sarah\nTech Innovate',
        '#3498db',  # Blue - professional/recruiter
        (300, 300)
    )
    
    # Create avatars (user_7 to user_21)
    print("\n👤 Creating user avatars...")
    user_names = [
        'Amina B.', 'Yacine K.', 'Salima M.', 'Karim B.', 'Nadia H.',
        'Mehdi S.', 'Fatima L.', 'Riad C.', 'Leila B.', 'Ahmed',
        'Samira', 'Rachid', 'Yasmine', 'Sofiane', 'Meriem'
    ]
    
    for i, name in enumerate(user_names, start=7):
        color = avatar_colors[i - 7]
        create_placeholder(
            f'media/avatars/user_{i}.jpg',
            name,
            color,
            (300, 300)
        )
    
    # Create DEMO company logo
    print("\n🎯 Creating DEMO company logo...")
    create_placeholder(
        'media/logos/demo_company.png',
        'Tech\nInnovate\nAlgeria',
        '#2c3e50',  # Dark professional
        (200, 200)
    )
    
    # Create company logos
    print("\n🏢 Creating company logos...")
    logos = [
        ('tech_solutions', 'Tech\nSolutions', '#2c3e50'),
        ('design_studio', 'Design\nStudio', '#e74c3c'),
        ('btp_algerie', 'BTP\nAlgérie', '#f39c12'),
        ('digital_agency', 'Digital\nAgency', '#3498db'),
        ('construction_plus', 'Construction\nPlus', '#e67e22'),
        ('web_innovate', 'Web\nInnovate', '#9b59b6'),
    ]
    
    for filename, text, color in logos:
        create_placeholder(
            f'media/logos/{filename}.png',
            text,
            color,
            (200, 200)
        )
    
    # Create DEMO job images
    print("\n🎯 Creating DEMO job images...")
    demo_jobs = [
        ('demo_job_1', 'Senior\nFull Stack\nReact/Node', '#3498db'),
        ('demo_job_2', 'Mobile\nDeveloper\nFlutter', '#3498db'),
        ('demo_job_3', 'DevOps\nEngineer', '#3498db'),
        ('demo_job_4', 'UI/UX\nDesigner\nSenior', '#e74c3c'),
        ('demo_job_5', 'Chef de Projet\nDigital', '#3498db'),
    ]
    
    for filename, text, color in demo_jobs:
        create_placeholder(
            f'media/jobs/{filename}.jpg',
            text,
            color,
            (800, 600)
        )
    
    # Create job images
    print("\n💼 Creating job images...")
    job_titles = [
        'Backend Dev', 'Chef Projet', 'Mobile Dev', 'Data Analyst', 'Full Stack',
        'UI/UX Design', 'Graphiste', 'Motion Design', 'Product Design',
        'Ingénieur Civil', 'Architecte', 'Chef Chantier', 'Conducteur',
        'Dessinateur', 'Métreur'
    ]
    
    job_colors = {
        'Informatique': '#3498db',
        'Design': '#e74c3c',
        'BTP': '#f39c12',
    }
    
    for i, title in enumerate(job_titles, start=5):
        if i <= 9:
            color = job_colors['Informatique']
        elif i <= 13:
            color = job_colors['Design']
        else:
            color = job_colors['BTP']
        
        create_placeholder(
            f'media/jobs/job_{i}.jpg',
            title,
            color,
            (800, 600)
        )
    
    # Create DEMO mission images
    print("\n🎯 Creating DEMO mission images...")
    demo_missions = [
        ('demo_mission_1', 'SaaS\nAnalytics\nModule', '#16a085'),
        ('demo_mission_2', 'Mobile App\nFintech\nProject', '#16a085'),
    ]
    
    for filename, text, color in demo_missions:
        create_placeholder(
            f'media/missions/{filename}.jpg',
            text,
            color,
            (800, 600)
        )
    
    # Create mission images
    print("\n🎯 Creating mission images...")
    mission_titles = [
        'SaaS Dev', 'Team Coord', 'Video Prod', 'Architecture', 'Infrastructure'
    ]
    
    for i, title in enumerate(mission_titles, start=3):
        create_placeholder(
            f'media/missions/mission_{i}.jpg',
            f'Mission\n{title}',
            '#16a085',
            (800, 600)
        )
    
    print("\n" + "="*60)
    print("✅ All placeholder images created successfully!")
    print("="*60)
    print("\n📊 Summary:")
    print(f"  🎯 DEMO IMAGES:")
    print(f"     • 2 demo avatars (candidat + recruteur)")
    print(f"     • 1 demo company logo")
    print(f"     • 5 demo job images")
    print(f"     • 2 demo mission images")
    print(f"  📦 REGULAR IMAGES:")
    print(f"     • 15 user avatars (300x300)")
    print(f"     • 6 company logos (200x200)")
    print(f"     • 15 job images (800x600)")
    print(f"     • 5 mission images (800x600)")
    print(f"  📊 Total: 51 images")
    print("\n📁 Location: backend/media/")
    print("\n🚀 Next steps:")
    print("  1. Run demo_seed_data.sql for teacher presentation")
    print("  2. Or run seed_data.sql for full dataset")
    print("\n🎯 Demo accounts:")
    print("  👤 Candidat: amina.demo@gmail.com / password123")
    print("  🏢 Recruteur: tech.demo@company.dz / password123")

if __name__ == '__main__':
    main()
