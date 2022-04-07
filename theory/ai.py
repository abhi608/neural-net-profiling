from audioop import avg
import torch
from torchvision.models import resnet18, resnet34, resnet50


models = [resnet18, resnet34, resnet50]
for model in models:
    with torch.no_grad():
        model(torch.ones(1,3,224,224))
    total_ai = 0
    queue = [m for m in model.modules()]
    n = 0
    while queue:
        cur = queue.pop(0)
        if len(list(cur.children())) > 0:
            for k in list(cur.children()):
                queue.append(k)
        else:
            total_ai += cur.ai
            n += 1
    avg_ai = total_ai/n
    print(model, avg_ai)

