import logging
import os
import json
import boto3
import requests

OPENAI_API_KEY = os.environ['OPENAI_API_KEY']
OPENAI_ENDPOINT = "https://api.openai.com/v1/engines/davinci/completions"
HEADERS = {
    "Authorization": f"Bearer {os.environ['OPENAI_API_KEY']}",
    "Content-Type": "application/json"
}

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    return forward(event)


def forward(event):
    # API Gatewayのプロキシ統合から本文を取得
    body = json.loads(event["body"])

    # OpenAI APIに転送するためのペイロードを作成
    data = {
        "prompt": body["prompt"],
        "max_tokens": body["max_tokens"]
    }

    logger.info(event)
    logger.info(data)
    response = requests.post(OPENAI_ENDPOINT, headers=HEADERS, json=data)
    logger.info(response)
    result = response.json()
    logger.info(result)

    return {
        "statusCode": response.status_code,
        "body": json.dumps(result)
    }


# for local debugging
if __name__ == '__main__':
    event = {"prompt": "Translate the following English text to Japanese: Hello World", "max_tokens": 50}
    print(forward(event))
