FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY ./app.py .

# Roda em modo de debug apenas para hot reload o código
CMD ["flask", "run", "--host=0.0.0.0", "--port=5000", "--debug"]