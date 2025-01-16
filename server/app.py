# Flask application that interacts with a PostgreSQL database, returns HTML showing table columns and host
# Dockerized with Docker Compose

from flask import Flask, render_template_string
import os
import psycopg2
import socket

app = Flask(__name__)

def get_db_connection():
    try:
        conn = psycopg2.connect(
            dbname=os.getenv('POSTGRES_DB', 'postgres'),
            user=os.getenv('POSTGRES_USER', 'postgres'),
            password=os.getenv('POSTGRES_PASSWORD', 'postgres'),
            host=os.getenv('POSTGRES_HOST', 'db'),
            port=os.getenv('POSTGRES_PORT', '5432')
        )
        print("Conexão com o banco pronta")
    except psycopg2.Error as e:
        print(f"Erro de conexão: {e}")
        return None

    return conn

@app.route('/')
def index():
    host_name = socket.gethostname()

    conn = get_db_connection()
    if conn == None:
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
            <h1 style="color: red;">Erro: Não foi possivel conectar ao banco</h1>
        </body>
        </html>
        """
        return render_template_string(html_template, host=host_name)
    cursor = conn.cursor()

    my_table = os.getenv('POSTGRES_TABLE', 'test')
    cursor.execute(f"select * from {my_table} order by time_collect desc limit 1;")
    data = cursor.fetchone()

    cursor.execute(f"show pool_nodes;")
    pool_nodes = cursor.fetchall()
    db_name = [info[1] for info in pool_nodes if info[7] == 'true'][0]

    conn.close()


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
        <h1>Database: {{db_name}}</h1>
        <p>Uso de CPU: {{data[1]}}%</p>
        <p>Memória: {{data[2]}}B</p>
        <p>Timestamp da coleta: {{data[4]}}</p>
        <p>IP do host: {{data[3]}}</p>
    </body>
    </html>
    """

    return render_template_string(html_template, host=host_name, data=data, db_name=db_name)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

