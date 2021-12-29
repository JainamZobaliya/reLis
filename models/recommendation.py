import sys
print('Hello from ReLis',str(sys.argv[1]))
# data = sys.stdin.readlines()
print('Hello from ReLis',str(sys.argv[2]))
data = 0
data2 = sys.argv[2].split(',')
for x in data2:
    data = data + int(x)
print(data)