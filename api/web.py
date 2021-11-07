import os
from flask import Flask, request, render_template, redirect, url_for, session, jsonify
from main import *
import time
import datetime
import logging
import json
import logging.handlers
from collections import OrderedDict
app = Flask(__name__)
app.secret_key = b'_5#y9L"F4M0z\n\xec]/'
logging.basicConfig(filename = "logs/project.log", level = logging.DEBUG)
myLogger = logging.getLogger('myLogger') # 로거 이름: myLogger
myLogger.setLevel(logging.DEBUG) # 로깅 수준: DEBUG
myLogger.propagate = 0
file_handler = logging.handlers.TimedRotatingFileHandler(
  filename='logs/project.log', when='midnight', interval=1,  encoding='utf-8'
  ) # 자정마다 한 번씩 로테이션
file_handler.suffix = 'log-%Y%m%d' # 로그 파일명 날짜 기록 부분 포맷 지정 
myLogger.addHandler(file_handler) # 로거에 핸들러 추가
formatter = logging.Formatter(
  '%(asctime)s - %(levelname)s - [%(filename)s:%(lineno)d] %(message)s'
  )
file_handler.setFormatter(formatter) # 핸들러에 로깅 포맷 할당
@app.route('/', methods = ['GET'])
def main():
    tmp = request.args.get('k')
    try:
        k = int(tmp)
    except:
        k = tmp

    a = makeEquation(k)
    a.optimize()
    buffer = visualize(a)
    tmp = ''
    for i in buffer: tmp += i
    jsonFile = OrderedDict()
    jsonFile['tex'] = tmp
    return jsonify(jsonFile)

@app.route('/getVal', methods=['GET'])
def getvalNK():
    n = int(request.args.get('n'))
    k = int(request.args.get('k'))
    jsonFile = OrderedDict()
    jsonFile['val'] = getValNaive(k, n)
    return jsonify(jsonFile)

if __name__ == '__main__':
    app.run('0.0.0.0', port=80, debug=False)
    myLogger.debug("server start!")
