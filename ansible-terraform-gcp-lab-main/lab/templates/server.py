import subprocess
from flask import Flask, render_template
app = Flask(__name__)

@app.route('/')
def index():
  runprocs = subprocess.run(['/usr/games/fortune'], stdout=subprocess.PIPE)
  return render_template('index.html', my_string=runprocs.stdout.decode('utf-8'))

if __name__ == '__main__':
  app.run(debug=False, host='0.0.0.0', port=80)
