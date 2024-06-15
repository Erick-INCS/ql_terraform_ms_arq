from fastapi import FastAPI
from os import getenv
from requests import get
from re import compile as gen

app = FastAPI()
TOKEN = getenv('BANXICO_TOKEN')
BASE_URL = 'https://www.banxico.org.mx/SieAPIRest/service/v1/series/SF343410/datos'
DATE_REGX = gen(r'^\d{4}-\d{2}-\d{2}')


@app.get("/")
def read_root():
    return {"API tipo de cambio, favor de indicar una fecha"}

@app.get("/healthcheck")
def healthcheck():
    return ":)"


@app.get("/{date}")
def read_item(date: str):
    if not DATE_REGX.match(date):
        return {'error': 'INVALID DATE.'}

    uri = f'{BASE_URL}/{date[:-2]}01/{date}'
    response = get(uri, headers={'Bmx-Token': TOKEN}).json()
    if 'bmx' not in response:
        return {'error': 'INVALID RESPONSE', 'response': response}

    response = {
        f"{e.get('fecha').split('/')[-1]}-{e.get('fecha').split('/')[-2]}-{e.get('fecha').split('/')[0]}":e.get('dato') for e in
        response['bmx']['series'][0]['datos']
    }
    return response