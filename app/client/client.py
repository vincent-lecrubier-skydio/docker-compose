# import asyncio
# import os

# from temporalio.client import Client

# from workflows import GreetingWorkflow, SayHelloWorkflow
# from activities import create_greeting_activity, say_hello_activity


# async def run_client():
#     # Create client connected to server at the given address
#     client = await Client.connect(os.environ.get('TEMPORAL_ENDPOINT')
#                                   # , namespace="hello-namespace"
#                                   )

#     # Execute a workflow
#     result = await client.execute_workflow(SayHelloWorkflow.run, "my name", id="hello-workflow-0", task_queue="hello-task-queue")

#     print(f"Result: {result}")

# if __name__ == "__main__":
#     asyncio.run(run_client())


import asyncio
import os
import streamlit as st
from temporalio.client import Client
from workflows import GreetingWorkflow, SayHelloWorkflow
from activities import create_greeting_activity, say_hello_activity


async def main():
    # Create client connected to server at the given address
    client = await Client.connect(os.environ.get('TEMPORAL_ENDPOINT')
                                  # , namespace="hello-namespace"
                                  )
    st.set_page_config(page_title="Example App", page_icon="🤖")

    person_name = st.text_input('Person name', 'World')
    result = await client.execute_workflow(SayHelloWorkflow.run, person_name, id="hello-workflow-0", task_queue="hello-task-queue")
    print(f"Result: {result}")
    st.write(f"Result: {result}")


if __name__ == '__main__':
    loop = asyncio.new_event_loop()
    loop.run_until_complete(main())
