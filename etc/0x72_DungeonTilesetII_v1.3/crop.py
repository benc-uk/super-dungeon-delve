#!/usr/bin/env python3

import os
from PIL import Image

IMG_PATH = '0x72_DungeonTilesetII_v1.3.png'
TILES_PATH = 'tiles_list_v1.3'

def getBox(arr, frameIndex = 0):
    w, h = int(arr[3]), int(arr[4])
    x, y = int(arr[1]) + w*frameIndex, int(arr[2])
    return (x, y, x+w, y+h)

def saveCrop(img, title, box):
    path = os.path.join('./frames/' + title + '.png')
    try:
        croppedImg = img.crop(box)
        croppedImg.save(path)
        print('ok: ' + title)
    except Exception as e:
        print('fail: ' + title + ' -- ' + str(e))

img = Image.open(IMG_PATH)
w, h = img.size

f = open(TILES_PATH, 'r')
for line in f.readlines():
    arr = line.split()
    if len(arr) == 0:
        pass
    if len(arr) == 5:
        saveCrop(img, arr[0], getBox(arr))
    if len(arr) == 6:
        numOfFrames = int(arr[5])
        for frameIndex in range(0, numOfFrames):
            saveCrop(img, arr[0] + '_f' + str(frameIndex), getBox(arr, frameIndex))

print('')
