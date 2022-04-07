from audioop import avg
import torch
from torchvision.models import resnet18, resnet34, resnet50

def conv_fn(layer, x, y):
    if type(layer) == torch.nn.modules.conv.Conv2d:
        M = layer.in_channels
        N = layer.out_channels
        K = layer.kernel_size[0]
        G = layer.groups
        H = y.size()[2]
        F = y.size()[3]
        B = y.size()[0]
        numerator = (B*F*H*M*N*K*K)/G
        weights = (M*N*K*K)
        memory_access_in = B*M*F*H/G
        memory_access_out = B*N*F*H/G
        memory_access = ((B*(M+N)*F*H)/G)
        denominator = weights + memory_access
        macs = B*M*N*K*K*F*H/G
        layer.ai += (numerator/denominator)
        layer.macs += macs
        layer.weights += weights
        layer.memory_access += memory_access
        layer.memory_access_in += memory_access_in
        layer.memory_access_out += memory_access_out

handler_collection = []
def add_hook(layer):
    if len(list(layer.children())) > 0:
        return

    layer.register_buffer('ai', torch.zeros(1))
    layer.register_buffer('macs', torch.zeros(1))
    layer.register_buffer('weights', torch.zeros(1))
    layer.register_buffer('memory_access', torch.zeros(1))
    layer.register_buffer('memory_access_in', torch.zeros(1))
    layer.register_buffer('memory_access_out', torch.zeros(1))
    handler = layer.register_forward_hook(conv_fn)
    handler_collection.append(handler)
    # print("Registered %s" % str(layer))

models = [resnet18(), resnet34(), resnet50()]
for model in models:
    model.apply(add_hook)
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
    print(model(), avg_ai)


