# Flask application that interacts with a PostgreSQL database, returns HTML showing table columns and host
# Dockerized with Docker Compose

from flask import Flask, render_template_string
import os
import psycopg2
import socket

app = Flask(__name__)

def get_db_connection():
    while 1:
        try:
            conn = psycopg2.connect(
                dbname=os.getenv('POSTGRES_DB', 'postgres'),
                user=os.getenv('POSTGRES_USER', 'postgres'),
                password=os.getenv('POSTGRES_PASSWORD', 'postgres'),
                host=os.getenv('POSTGRES_HOST', 'db'),
                port=os.getenv('POSTGRES_PORT', '5432')
            )
            print("Conexão com o banco pronta")
            break
        except psycopg2.Error as e:
            print(f"Erro de conexão: {e}")
            print("Esperando conectar...")
    return conn

@app.route('/')
def index():
    conn = get_db_connection()
    cursor = conn.cursor()
    my_table = os.getenv('POSTGRES_TABLE', 'test')
    cursor.execute(f"select * from {my_table} order by time_collect desc limit 1;")
    data = cursor.fetchone()
    conn.close()

    host_name = socket.gethostname()

    html_template = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Avaliação Venko</title>
    </head>
    <body>
        <h1>Host: {{ host }}</h1>
        <p>Uso de CPU: {{data[1]}}%</p>
        <p>Memória: {{data[2]}}B</p>
        <p>Timestamp da coleta: {{data[4]}}</p>
        <p>IP do host: {{data[3]}}</p>
    </body>
    </html>
    """

    return render_template_string(html_template, host=host_name, data=data)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

