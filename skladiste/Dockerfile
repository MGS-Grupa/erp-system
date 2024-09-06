FROM python:3.8-slim

WORKDIR /app

RUN python -m venv venv

COPY requirements.txt .
RUN ./venv/bin/pip install --upgrade pip && ./venv/bin/pip install -r requirements.txt && ./venv/bin/pip install gunicorn

COPY . /app

EXPOSE 5006

CMD ["./venv/bin/gunicorn", "--bind", "0.0.0.0:5006", "api:app"]
