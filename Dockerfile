# Imagen base ligera
FROM python:3.11-slim

# Directorio de trabajo
WORKDIR /app

# Copiar dependencias e instalarlas
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar aplicación
COPY app.py .

# Exponer puerto
EXPOSE 5000

# Comando de arranque
CMD ["python", "app.py"]