from http.server import HTTPServer, SimpleHTTPRequestHandler
from pathlib import Path
ROOT=Path(__file__).resolve().parent/'organic-finish'
ROOT.mkdir(exist_ok=True)
class Handler(SimpleHTTPRequestHandler):
    def __init__(self,*a,**kw):super().__init__(*a,directory=str(ROOT),**kw)
    def do_POST(self):
        name=self.path.split('/')[-1]
        if name not in {'color.rgba','rough.rgba','metal.rgba','mesh.json'}:
            self.send_error(400);return
        data=self.rfile.read(int(self.headers['Content-Length']))
        (ROOT/name).write_bytes(data)
        self.send_response(200);self.end_headers();self.wfile.write(b'saved')
HTTPServer(('127.0.0.1',8774),Handler).serve_forever()
