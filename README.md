# Python docker compose temporal

## How to use

1. Run the stack
```bash
docker compose up --detach --build --force-recreate
```
2. Navigate to Streamlit http://localhost:8501/
3. Change the name
4. Navigate to the Temporal dashboard http://localhost:8080/

## Example video

https://youtu.be/jReeA55u0tI

## Architecture

There are a couple folders here:

- `common`: Contains business logic
  - `activities`: Contains the activities (building blocks, small actions)
  - `workflows`: Contains the workflows (big multi steps, composed of activities)
- `client`: An example Streamlit app that uses the temporal client to trigger a workflow
- `worker`: A worker which runs the workflows and activities
  