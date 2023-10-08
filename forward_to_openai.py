import logging
import os
import json
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
    logger.info(event)
    # bodyに文字列としてjsonが入っていることを期待している
    body = json.loads(event["body"])
    data = {
        "prompt": body["prompt"],
        "max_tokens": body["max_tokens"]
    }

    logger.info(data)
    response = requests.post(OPENAI_ENDPOINT, headers=HEADERS, json=data)
    result = {
        "statusCode": response.status_code,
        "body": json.dumps(response.json())
    }
    logger.info(result)
    return result
