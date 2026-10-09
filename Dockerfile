
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt .

RUN python -m pip install --no-cache-dir -r requirements.txt

RUN useradd --create-home --shell /usr/sbin/nologin appuser

COPY --chown=appuser:appuser app/ ./app/

USER appuser

EXPOSE 5000

CMD ["gunicorn", "--chdir", "app", "--bind", "0.0.0.0:5000", "app:app"]
