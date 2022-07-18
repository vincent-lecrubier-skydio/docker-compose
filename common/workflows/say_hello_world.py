
from datetime import timedelta
from temporalio import workflow
from common.activities.greet import greet, GreetingInfo


@workflow.defn
class SayHelloWorld:

    @workflow.run
    async def run(self, name: str) -> str:
        return await workflow.execute_activity(
            greet,
            GreetingInfo(name=name),
            schedule_to_close_timeout=timedelta(seconds=5)
        )
