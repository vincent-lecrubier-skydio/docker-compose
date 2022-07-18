from dataclasses import dataclass
from temporalio import activity

@dataclass
class GreetingInfo:
    salutation: str = "Hello"
    name: str = "<unknown>"

@activity.defn
async def greet(info: GreetingInfo) -> str:
    return f"{info.salutation}, {info.name}!"