import asyncio
import os

from temporalio.client import Client
from temporalio.worker import Worker

from common.workflows import SayHelloWorld
from common.activities import greet

async def run_worker():

    # Create client connected to server at the given address
    client = await Client.connect(os.environ.get('TEMPORAL_ENDPOINT'))

    # Define the worker, with workflows and activities that it can run
    worker = Worker(
        client,
        task_queue="hello-task-queue",
        workflows=[
            SayHelloWorld,
        ],
        activities=[
            greet
        ]
    )

    # Run the worker
    try:
        await worker.run()
    except:
        await worker.shutdown()


if __name__ == "__main__":
    asyncio.run(run_worker())
