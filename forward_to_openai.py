import os
import json
import boto3
import requests

OPENAI_API_KEY = os.environ['OPENAI_API_KEY']
OPENAI_ENDPOINT = "https://api.openai.com/v1/engines/davinci/completions"


def lambda_handler(event, context):
    headers = {
        "Authorization": f"Bearer {OPENAI_API_KEY}",
        "Content-Type": "application/json",
    }

    response = requests.post(OPENAI_ENDPOINT, headers=headers, data=json.dumps(event))

    return response.json()
