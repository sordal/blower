# **********************************************************************
#    Copyright (c) 2017 Samuel Kelly
#
#    Permission is hereby granted, free of charge, to any person
#    obtaining a copy of this software and associated documentation
#    files (the "Software"), to deal in the Software without
#    restriction, including without limitation the rights to use,
#    copy, modify, merge, publish, distribute, sublicense, and/or sell
#    copies of the Software, and to permit persons to whom the
#    Software is furnished to do so, subject to the following
#    conditions:
#
#    The above copyright notice and this permission notice shall be
#    included in all copies or substantial portions of the Software.
#
#    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
#    OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
#    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
#    HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
#    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
#    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
#    OTHER DEALINGS IN THE SOFTWARE.
#
# **********************************************************************

import os
import _thread
import time
from flask import json
from flask import Flask
from flask_sslify import SSLify
import yaml
import datetime
import random
running_on_pi = True
try:
    import RPi.GPIO as GPIO
except ImportError:
    running_on_pi = False


app = Flask(__name__)
sslify = SSLify(app)


def application_directory():
    return os.path.dirname(os.path.realpath(__file__))


def is_raspberry_pi():
    return os.uname()[4][:3] == 'arm'


@app.route('/active')
def get_is_active():
    return 'ACTIVE'


@app.route('/health')
def get_health():
    # TODO: Check to see you can see all of your downstream connections.
    return json.dumps({'status': 'UP'}, ensure_ascii=False)


def build_version():
    return application_directory() + '/build_version.json'


@app.route('/version')
def get_build_info():
    if os.path.isfile(build_version()):
        with open(build_version(), 'r') as content_file:
            content = content_file.read()
        if len(content) > 0:
            return content
    return '', 404


@app.route('/')
def get_response():
    response = {'hello': 'blower'}
    http_code = 200
    return json.dumps(response, ensure_ascii=False), http_code


def get_config(config_file):
    with open(config_file, 'r') as f:
        doc = yaml.load(f)
    return doc


def check_time(start_time,end_time):
    current_time = datetime.datetime.now()
    if start_time <= current_time.hour <= end_time:
        return True
    else:
        return False


def random_next_time(sleep_default):
    random_int = random.randint(0, 60)
    return random_int+sleep_default


def second_converter(time_minutes):
    final = time_minutes*60
    return final


def set_blower(pin, value):
    if running_on_pi:
        GPIO.output(pin, value)
    else:
        print('Blower is %s', value)


def background(config):
    # TODO: put background task code here, if you don't need it then delete it. Add back second converter and GPIO
    if is_raspberry_pi():
        GPIO.setmode(GPIO.BOARD)
        GPIO.setup(config['timer']['pin'], GPIO.OUT)
    while True:
        if check_time(config['timer']['start_time'], config['timer']['end_time']):
            set_blower(config['timer']['pin'], True)
            time.sleep(second_converter(config['timer']['run_minutes']))
            set_blower(config['timer']['pin'], False)
        time.sleep(second_converter(random_next_time(config['timer']['sleep_minutes'])))

if __name__ == '__main__':
    if os.path.isfile('/.dockerenv'):
        print('Blue Pill: We are running in the matrix.')
        host = '0.0.0.0'
        port = 443
    else:
        print('Red Pill: We are running in real world')
        host = 'localhost'
        port = 4567
    cert_key = '{}/cert/2829-applegate-wildcard.key'.format(application_directory())
    cert_crt = '{}/cert/2829-applegate-wildcard.crt'.format(application_directory())
    context = (cert_crt, cert_key)

    # TODO: launch the background thread, if you don't need this then delete it along with the background() method
    config_file = get_config('config/config.yaml')
    _thread.start_new_thread(background, (config_file, ))

    app.run(host=host, port=port,
            debug=False / True, ssl_context=context)
