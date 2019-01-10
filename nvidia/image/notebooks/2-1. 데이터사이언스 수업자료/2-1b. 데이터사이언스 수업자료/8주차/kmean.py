import math
import random
import numpy as np

def calc_distance(x, y):
    return math.sqrt(math.pow((y[0] - x[0]), 2) + math.pow((y[1] - x[1]), 2) + math.pow((y[2] - x[2]), 2))

def find_nearest(array, value):
    idx = np.sum((np.abs(array - value)), axis=1).argmin()
    return idx

p = np.ones((100, 3))

for i in range(len(p)):
    # p[i] = [random.randrange(0, 100), random.randrange(0, 100), random.randrange(0, 100)]
    p[i] = random.sample(range(0, 100), 3)

print(p)

k = 5
print("cluster num : %d" % k)

rep = random.sample(range(0, 100), k)
print("random rep index : ", rep)

for num in range(10):
    dist_avg = np.zeros((k))
    dis = np.zeros((len(p), k))
    for i in range(len(p)):
        if rep is i:
            continue
        for j in range(k):
            dis[i][j] = calc_distance(p[rep[j]], p[i])
    cls = np.zeros((len(p), k))
    for h in range(len(p)):
        cls[h][np.argmin(dis[h])] = 1

    for y in range(k):
        avg = []
        tmp_avg_dist = []

        for x in range(len(p)):
            if cls[x][y] == 1:
                avg.append(p[x])
                tmp_avg_dist.append(dis[x][y])

        avg_val = np.mean(avg, axis=0)
        idx = find_nearest(p, avg_val)
        rep[y] = idx
        dist_avg[y] = np.sum(tmp_avg_dist, axis=0)

    print("[%d]-----CLUSTER REP POINT------" % num)
    print(rep)
    print("[%d]-----SUM DISTANCE------" % num)
    print(dist_avg)