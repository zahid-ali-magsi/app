# config.py
import os

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'your_default_secret_key'
    SQLALCHEMY_DATABASE_URI = 'sqlite:///database.db'
    SQLALCHEMY_TRACK_MODIFICATIONS = False




# from app import db, app  # Ensure 'app' is imported from your main Flask file

# with app.app_context():
#     db.create_all()
#     print("Database tables created successfully.")
