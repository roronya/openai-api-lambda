import logging
import os
import json
import boto3
import requests

OPENAI_API_KEY = os.environ['OPENAI_API_KEY']
OPENAI_ENDPOINT = "https://api.openai.com/v1/engines/davinci/completions"

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    forward(event)


def forward(event):
    headers = {
        "Authorization": f"Bearer {OPENAI_API_KEY}",
        "Content-Type": "application/json",
    }

    req = json.dumps(event)
    logger.info(req)
    response = requests.post(OPENAI_ENDPOINT, headers=headers, data=req)
    result = response.json()
    logger.info(result)

    return result


# for local debugging
if __name__ == '__main__':
    event = {"prompt": "Translate the following English text to Japanese: Hello World", "max_tokens": 50}
    print(forward(event))
