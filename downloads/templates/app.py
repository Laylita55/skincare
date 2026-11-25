import http.server
import socketserver
import json
import sqlite3
import smtplib
from urllib.parse import parse_qs, urlparse
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

PORT = 2802
DB_NAME = "datos.db"

# CONFIGURA TU CORREO Y TU CONTRASEÑA DE APLICACIÓN DE GMAIL
EMAIL_EMISOR = 'tu_correo@gmail.com'
EMAIL_PASSWORD = 'tu_clave_de_aplicacion'

def init_db():
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        email TEXT NOT NULL
    )
    ''')
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS ventas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        producto TEXT NOT NULL,
        email TEXT NOT NULL,
        monto_ingresado REAL NOT NULL,
        precio_total REAL NOT NULL,
        fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
    ''')
    conn.commit()
    conn.close()

def enviar_correo_factura(email_cliente, producto, monto_ingresado, precio_total):
    cambio = monto_ingresado - precio_total
    
    msg = MIMEMultipart()
    msg['From'] = EMAIL_EMISOR
    msg['To'] = email_cliente
    msg['Subject'] = 'Factura de Compra - Beautyweb'

    cuerpo_html = f"""
    <div style="font-family: Arial, sans-serif; padding: 20px; border: 1px solid #c8e6c9; border-radius: 8px;">
        <h2 style="color: #388e3c;">¡Gracias por tu compra en Beautyweb!</h2>
        <p>A continuación se detalla tu comprobante de compra:</p>
        <hr>
        <ul>
            <li><strong>Producto/Detalle:</strong> {producto}</li>
            <li><strong>Total a Pagar:</strong> ${precio_total}</li>
            <li><strong>Monto Entregado:</strong> ${monto_ingresado}</li>
            <li><strong>Cambio:</strong> ${cambio}</li>
        </ul>
        <hr>
        <p style="color: #388e3c;"><em>Beautyweb - Skincare</em></p>
    </div>
    """
    msg.attach(MIMEText(cuerpo_html, 'html'))

    server = smtplib.SMTP('smtp.gmail.com', 587)
    server.starttls()
    server.login(EMAIL_EMISOR, EMAIL_PASSWORD)
    server.sendmail(EMAIL_EMISOR, email_cliente, msg.as_string())
    server.quit()

class BeautywebHandler(http.server.SimpleHTTPRequestHandler):
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

    def do_GET(self):
        parsed_path = urlparse(self.path)
        if parsed_path.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'text/html; charset=utf-8')
            self.end_headers()
            try:
                with open('templates/skincare.html', 'rb') as file:
                    self.wfile.write(file.read())
            except FileNotFoundError:
                with open('skincare.html', 'rb') as file:
                    self.wfile.write(file.read())
        else:
            super().do_GET()

    def do_POST(self):
        parsed_path = urlparse(self.path)
        
        if parsed_path.path == '/api/comprar':
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            data = json.loads(post_data.decode('utf-8'))

            email_cliente = data.get('email')
            producto = data.get('producto')
            monto_ingresado = float(data.get('montoIngresado', 0))
            precio_total = float(data.get('precioTotal', 0))

            if not email_cliente or monto_ingresado < precio_total:
                self.send_response(400)
                self.send_header('Content-Type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(json.dumps({'success': False, 'message': 'Datos inválidos'}).encode('utf-8'))
                return

            try:
                # Guardar en base de datos SQLite
                conn = sqlite3.connect(DB_NAME)
                cursor = conn.cursor()
                cursor.execute(
                    "INSERT INTO ventas (producto, email, monto_ingresado, precio_total) VALUES (?, ?, ?, ?)",
                    (producto, email_cliente, monto_ingresado, precio_total)
                )
                conn.commit()
                conn.close()

                # Enviar correo electrónico
                enviar_correo_factura(email_cliente, producto, monto_ingresado, precio_total)

                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(json.dumps({'success': True, 'message': 'Factura enviada'}).encode('utf-8'))

            except Exception as e:
                print("Error:", e)
                self.send_response(500)
                self.send_header('Content-Type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(json.dumps({'success': False, 'message': str(e)}).encode('utf-8'))

if __name__ == '__main__':
    init_db()
    with socketserver.TCPServer(("", PORT), BeautywebHandler) as httpd:
        print(f"Servidor ejecutándose en http://localhost:{PORT}")
        httpd.serve_forever()