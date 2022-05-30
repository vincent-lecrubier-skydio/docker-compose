import asyncio

from datetime import timedelta
from temporalio import workflow
from activities.greet import create_greeting_activity, GreetingInfo


@workflow.defn
class GreetingWorkflow:
    def __init__(self) -> None:
        self._current_greeting = "<unset>"
        self._greeting_info = GreetingInfo()
        self._greeting_info_update = asyncio.Event()
        self._complete = asyncio.Event()

    @workflow.run
    async def run(self, name: str) -> str:
        self._greeting_info.name = name
        while True:
            # Store greeting
            self._current_greeting = await workflow.execute_activity(
                create_greeting_activity,
                self._greeting_info,
                start_to_close_timeout=timedelta(seconds=5),
            )
            workflow.logger.debug("Greeting set to %s", self._current_greeting)
            
            # Wait for salutation update or complete signal (this can be
            # cancelled)
            await asyncio.wait(
                [self._greeting_info_update.wait(), self._complete.wait()],
                return_when=asyncio.FIRST_COMPLETED,
            )
            if self._complete.is_set():
                return self._current_greeting
            self._greeting_info_update.clear()

    @workflow.signal
    async def update_salutation(self, salutation: str) -> None:
        self._greeting_info.salutation = salutation
        self._greeting_info_update.set()

    @workflow.signal
    async def complete_with_greeting(self) -> None:
        self._complete.set()

    @workflow.query
    async def current_greeting(self) -> str:
        return self._current_greeting

