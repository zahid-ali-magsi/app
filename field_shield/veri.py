from app import db, User
User.query.all()  # Should return existing users if data wasn’t lost.