FROM python:3.12-slim
WORKDIR /App
COPY App.py /App/App.py
RUN pip install --no-cache-dir flask itsdangerous
ENV FLASK_APP=App.py
EXPOSE 8000
CMD ["python","-m","flask","run","--host=0.0.0.0","--port=8000"]