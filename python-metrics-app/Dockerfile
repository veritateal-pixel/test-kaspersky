FROM python:3.9-alpine

WORKDIR /app

COPY main.py .

RUN pip install prometheus-client

EXPOSE 8080

CMD ["python", "main.py"]