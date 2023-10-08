import logging
import os
import openai

logger = logging.getLogger()
logger.setLevel(logging.INFO)
openai.api_key = os.environ['OPENAI_API_KEY']


def lambda_handler(event, context):
    logger.info(event)
    messages = event["body"]
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=messages
    )
    logger.info(response)
    return response

