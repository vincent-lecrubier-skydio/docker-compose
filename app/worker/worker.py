import asyncio
import os

from temporalio.client import Client
from temporalio.worker import Worker

from workflows import GreetingWorkflow, SayHelloWorkflow
from activities import create_greeting_activity, say_hello_activity


async def run_worker(
    # stop_event: asyncio.Event
):
    # Create client connected to server at the given address
    client = await Client.connect(os.environ.get('TEMPORAL_ENDPOINT')
                                  # , namespace="hello-namespace"
                                  )

    # Run the worker until the event is set
    worker = Worker(client, task_queue="hello-task-queue", workflows=[
        GreetingWorkflow,
        SayHelloWorkflow,
    ], activities=[
        create_greeting_activity,
        say_hello_activity,
    ])
    try:
        await worker.run()
    except:
        await worker.shutdown()
    # if stop_event is not None:
    #     async with worker:
    #         await stop_event.wait()

if __name__ == "__main__":
    asyncio.run(run_worker())
