import asyncio
import os
import streamlit as st
from temporalio.client import Client

from common.workflows import SayHelloWorld


async def main():
    # Create client connected to server at the given address
    client = await Client.connect(os.environ.get('TEMPORAL_ENDPOINT'))

    # Small Streamlit input to input name
    st.set_page_config(page_title="Example App", page_icon="🤖")
    person_name = st.text_input('Person name', 'World')

    # Run the workflow
    result = await client.execute_workflow(SayHelloWorld.run, person_name, id="hello-workflow-0", task_queue="hello-task-queue")

    # Display the result
    print(f"Result: {result}")
    st.write(f"Result: {result}")


if __name__ == '__main__':
    loop = asyncio.new_event_loop()
    loop.run_until_complete(main())
