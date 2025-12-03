import os, uuid
from flask import Flask, request, redirect, make_response

SECRET = os.environ.get('FLASK_SECRET', 'dev')
app = Flask(__name__)

USERS = {'operator': 'otlab123'}
PENDING = {}
SESSIONS = {}
USER_SESSIONS = {}

HTML_LOGIN = '''<!doctype html><title>IHM Login</title>
<h1>IHM – Login</h1>
<form method=post action="/login">
  Username: <input name=u> Password: <input name=p type=password>
  <button type=submit>Login</button>
</form>'''

HTML_MFA = '''<!doctype html><title>MFA</title>
<h1>MFA</h1>
<p>A token was sent (simulated). Please enter <b>000111</b>.</p>
<form method=post action="/mfa">
  <input type=hidden name=u value="{u}">
  Token: <input name=code>
  <button type=submit>Validate</button>
</form>'''

def html_home(u):
    return (
        '<!doctype html><title>Home</title>'
        '<h1>IHM – Logged In</h1>'
        f'<p>Welcome, {u}.</p>'
        '<p><a href="/whoami">Who am I?</a> | <a href="/logout">Log out</a> | <a href="/headers">Headers</a></p>'
    )

@app.route('/')
def index():
    return redirect('/home')

@app.route('/login', methods=['GET','POST'])
def login():
    if request.method == 'GET':
        return HTML_LOGIN
    u = (request.form.get('u') or '').strip()
    p = (request.form.get('p') or '').strip()
    if USERS.get(u) == p:
        token = '000111'
        PENDING[u] = token
        return HTML_MFA.format(u=u)
    return 'Invalid credentials', 401

@app.route('/mfa', methods=['POST'])
def mfa():
    u = (request.form.get('u') or '').strip()
    code = (request.form.get('code') or '').strip()
    if PENDING.get(u) == code:
        for s in list(USER_SESSIONS.get(u, set())):
            SESSIONS.pop(s, None)
        USER_SESSIONS[u] = set()
        
        sess = str(uuid.uuid4())
        SESSIONS[sess] = u
        USER_SESSIONS.setdefault(u, set()).add(sess)
        
        resp = make_response(html_home(u))
        resp.set_cookie(
            'ihm_session', sess,
            httponly=True,
            secure=False,
            samesite='Lax',
            path='/',
            domain='phishing.test'
        )
        PENDING.pop(u, None)
        return resp
    return 'Invalid MFA token', 401

@app.route('/home')
def home():
    sess = request.cookies.get('ihm_session', '')
    u = SESSIONS.get(sess)
    if u:
        return html_home(u)
    return redirect('/login')

@app.route('/logout')
def logout():
    sess = request.cookies.get('ihm_session', '')
    u = SESSIONS.pop(sess, None)
    if u:
        for s in list(USER_SESSIONS.get(u, set())):
            SESSIONS.pop(s, None)
        USER_SESSIONS[u] = set()
    resp = make_response(redirect('/login'))
    resp.delete_cookie('ihm_session', path='/', domain='phishing.test')
    return resp

@app.route('/whoami')
def whoami():
    sess = request.cookies.get('ihm_session', '')
    u = SESSIONS.get(sess)
    return (f"session={sess} user={u}", 200) if u else ("no session", 200)

@app.route('/headers')
def headers():
    return '<pre>' + '\n'.join([f'{k}: {v}' for k, v in request.headers]) + '</pre>'