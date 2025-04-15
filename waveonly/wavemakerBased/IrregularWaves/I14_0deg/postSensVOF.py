#!/usr/bin/env python3

import os

pathname = os.path.abspath('.')
savePath = os.path.join(pathname, 'gaugesVOF')
if not os.path.isdir(savePath):
    os.makedirs(savePath)

postPath = os.path.join(pathname, 'postProcessing/sets')
if not os.path.isdir(postPath):
    postPath = 'postProcessing/gaugesVOF'

# List of time dirs in order
a = os.listdir('./' + postPath)
a.sort(key=lambda x: float(x))  # Python 3 sort using key instead of cmp

# Get number of sensors
dir1 = os.path.join(pathname, postPath, a[int(len(a) / 2.0)])
b = os.listdir(dir1)
nSens = 0
index = []

for i in range(len(b)):
    test1 = 'VOF' in b[i]
    test2 = 'alpha' in b[i]
    if test1 and test2:
        index.append(i)
        nSens += 1

first = True

for i in range(nSens):
    try:
        # Create files to write
        fileName = b[index[i]][0:b[index[i]].find('_')]
        filePath = os.path.join(savePath, fileName)

        with open(filePath, 'w') as fileW:
            print(f'Sensor {i + 1} of {nSens}.')

            for j in range(len(a)):
                directory = os.path.join(pathname, postPath, a[j])
                fileToRead = os.path.join(directory, b[index[i]])
                try:
                    with open(fileToRead, 'r') as fileR:
                        data = fileR.read()
                except FileNotFoundError:
                    print(f'WARNING - File not present: {fileToRead}')
                    continue

                data = data.split('\n')

                if first:  # First time step
                    coord = j
                    first = False

                z = []
                alpha = []

                for k in range(len(data) - 1):
                    line = data[k].split('\t')

                    if len(line) < 4:
                        print(f'WARNING - Malformed line in file {fileToRead}: {line}')
                        continue

                    try:
                        z.append(float(line[2]))
                        alpha.append(float(line[3]))
                    except ValueError:
                        print(f'WARNING - Could not convert line to floats: {line}')
                        continue

                    if j == coord:
                        # Create coordinate files
                        with open(os.path.join(savePath, fileName + '.xy'), 'w') as fileWXYZ:
                            fileWXYZ.write(line[0] + line[1])

                if z:
                    wLevel = z[0]
                    for k in range(len(z) - 1):
                        wLevel += alpha[k] * (z[k + 1] - z[k])

                    time = a[j]
                    fileW.write(time + ' ' + f'{wLevel:.6f}\n')
                else:
                    print(f'WARNING - No valid data in file {fileToRead}')

    except IndexError as e:
        print(f'IndexError for sensor {i + 1}: {e}. Skipping this sensor.')

print('Done')
