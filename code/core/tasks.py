import logging
import time

from config import celery_app


@celery_app.task()
def web_task() -> None:
    logging.info("Starting web task...")
    time.sleep(10)
    logging.info("Done web task.")


@celery_app.task()
def beat_task() -> None:
    logging.info("Starting beat task...")
    time.sleep(10)
    logging.info("Done beat task.")
