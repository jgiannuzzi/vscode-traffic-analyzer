import json
from mitmproxy import http

async def response(flow: http.HTTPFlow):
    if flow.request.pretty_host == "api.github.com" and flow.request.path == "/copilot_internal/v2/token":
        resp = flow.response.json()
        resp["token"] = "ssc=1;" + resp["token"]
        flow.response.text = json.dumps(resp)

async def request(flow: http.HTTPFlow):
    if flow.request.pretty_host == "copilot-proxy.githubusercontent.com":
        flow.request.headers["authorization"] = flow.request.headers["authorization"].replace("ssc=1;", "")
