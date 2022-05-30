
from datetime import timedelta
from temporalio import workflow
from activities.hello import say_hello_activity


@workflow.defn
class SayHelloWorkflow:
    @workflow.run
    async def run(self, name: str) -> str:
        return await workflow.execute_activity(
            say_hello_activity, name, schedule_to_close_timeout=timedelta(
                seconds=5)
        )
