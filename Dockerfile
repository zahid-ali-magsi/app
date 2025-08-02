FROM python:3.10

# Install Git LFS
RUN apt-get update && apt-get install -y git-lfs && git lfs install

WORKDIR /app
COPY . .

# Verify models before installation
RUN python verify_models.py

RUN pip install -r requirements.txt

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]
