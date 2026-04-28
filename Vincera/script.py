import json


result = {}

with open("./exercises.json", "r") as f:
    exercises = json.loads("".join(f.readlines()))
    for key in exercises:
        value = exercises[key]
        result[key] = value
        result[key]['image'] = "-".join(value['name'].split(" ")).lower()

with open("./exercises.json", "w") as f:
    f.write(json.dumps(result))
