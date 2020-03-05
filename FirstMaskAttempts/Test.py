import cv2
import numpy as np
import matplotlib.pyplot as plt

img = cv2.imread('corr.png', cv2.IMREAD_COLOR)
hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

lower_red = np.array([0, 70, 50])
upper_red = np.array([21, 255, 200])
mask = cv2.inRange(hsv, lower_red, upper_red)
res = cv2.bitwise_and(img, img, mask = mask) 
res2 = res
#returns 3 values, only need one (contours)
contours, _ = cv2.findContours(mask, cv2.RETR_TREE, cv2.CHAIN_APPROX_NONE)
edges = cv2.Canny(mask, 50, 300)
#window, contours, numDrawn, BGR, thickness
#cv2.drawContours(img, contours, -1, (200, 80, 80), 1) 
#-1 draws all
cv2.imshow('res2', res2)
cv2.drawContours(res, contours, -1, (100, 255, 100), 1) 
cv2.imshow("edges", edges)
cv2.imshow('image', img)
cv2.imshow('mask', mask)
cv2.imshow('res', res)

cv2.waitKey(0)

cv2.destroyAllWindows();