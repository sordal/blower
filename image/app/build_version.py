import uuid
import time
from flask import json
import argparse

version = uuid.uuid4().urn[9:].replace('-', '')
parser = argparse.ArgumentParser(description='Usage: build_version.py [options]')
parser.add_argument('--version', default=version,
                    help="Version for this build, if none given then a random UUID will be generated.")
args = parser.parse_args()
build_date_time = time.strftime('%Y-%m-%d_%H:%M:%S')
response = {'version': args.version, 'build_time': build_date_time}
file = open('build_version.json', 'w')
file.write(json.dumps(response, ensure_ascii=False))
file.close()
