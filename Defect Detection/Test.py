import cv2
import numpy as np
import matplotlib.pyplot as plt
from scipy.spatial import distance as dist
from imutils import perspective
from imutils import contours
import argparse
import imutils
import re


def midpoint(ptA, ptB):
	return ((ptA[0] + ptB[0]) * 0.5, (ptA[1] + ptB[1]) * 0.5)

def detectWear(imgName):
	#Set image
	img = cv2.imread(imgName, cv2.IMREAD_COLOR)
	gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
	#gray = cv2.medianBlur(gray,5)
	#gray = cv2.GaussianBlur(gray, (7, 7), 0)
	gray = cv2.bilateralFilter(gray,7,40,80)
	lower_gray = np.array([40])
	upper_gray = np.array([200])
	mask = cv2.inRange(gray, lower_gray, upper_gray)
	cv2.imshow('Mask', mask)
	
	cv2.imshow('Gray', gray)
	canny = cv2.Canny(gray, 400, 50)
	cv2.imshow('img', img)
	cv2.imshow('Canny', canny)
	
	#Find contours
	j = contoursEdges(canny, img)
	#Every issue will be marked for now
	with open("defects.txt", 'a') as filetowrite:
		filetowrite.write(" Wear")
	
	#cv2.destroyAllWindows();

	return j



def detectRust(imgName):
	#Set image
	img = cv2.imread(imgName, cv2.IMREAD_COLOR)
	hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
	lower_red = np.array([0, 70, 100])
	upper_red = np.array([21, 125, 255])
	mask = cv2.inRange(hsv, lower_red, upper_red)
	res = cv2.bitwise_and(img, img, mask = mask) 
	res2 = res
	cv2.imshow('mask', mask)
	cv2.imshow('img', img)
	
	#Find contours
	j = contoursMask(mask, img)
	
	with open("defects.txt", 'a') as filetowrite:
		filetowrite.write(" Rust\n")

def contoursMask(mask, img):
	cnts = cv2.findContours(mask, cv2.RETR_TREE, cv2.CHAIN_APPROX_NONE)
	cnts = imutils.grab_contours(cnts)
	
	#returns 3 values, only need one (contours)
	#contours, _ = cv2.findContours(mask, cv2.RETR_TREE, cv2.CHAIN_APPROX_NONE)
	cnts = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)
	cnts = imutils.grab_contours(cnts)

	#sort contours
	(cnts, _) = contours.sort_contours(cnts)
	pixelsPerMetric = None

	#Here is where I will create a loop for the 4 photos

	# loop counter 
	j = 0
	# loop over the contours individually
	for c in cnts:
		# if the contour is not sufficiently large, ignore it
		if cv2.contourArea(c) < 10 and cv2.contourArea(c) > 100:
			continue
		
		# compute the rotated bounding box of the contour
		orig = img.copy()
		box = cv2.minAreaRect(c)
		box = cv2.cv.BoxPoints(box) if imutils.is_cv2() else cv2.boxPoints(box)
		box = np.array(box, dtype="int")
		
		# order the points in the contour such that they appear
		# in top-left, top-right, bottom-right, and bottom-left
		# order, then draw the outline of the rotated bounding
		# box
		box = perspective.order_points(box)
		cv2.drawContours(orig, [box.astype("int")], -1, (0, 255, 0), 2)
		
		# loop over the original points and draw them
		for (x, y) in box:
			cv2.circle(orig, (int(x), int(y)), 5, (0, 0, 255), -1)
			
		# unpack the ordered bounding box, then compute the midpoint
		# between the top-left and top-right coordinates, followed by
		# the midpoint between bottom-left and bottom-right coordinates
		(tl, tr, br, bl) = box
		(tltrX, tltrY) = midpoint(tl, tr)
		(blbrX, blbrY) = midpoint(bl, br)
		
		# compute the midpoint between the top-left and top-right points,
		# followed by the midpoint between the top-righ and bottom-right
		(tlblX, tlblY) = midpoint(tl, bl)
		(trbrX, trbrY) = midpoint(tr, br)
		
		# draw the midpoints on the image
		cv2.circle(orig, (int(tltrX), int(tltrY)), 5, (255, 0, 0), -1)
		cv2.circle(orig, (int(blbrX), int(blbrY)), 5, (255, 0, 0), -1)
		cv2.circle(orig, (int(tlblX), int(tlblY)), 5, (255, 0, 0), -1)
		cv2.circle(orig, (int(trbrX), int(trbrY)), 5, (255, 0, 0), -1)
		
		# draw lines between the midpoints
		cv2.line(orig, (int(tltrX), int(tltrY)), (int(blbrX), int(blbrY)),
			(255, 0, 255), 2)
		cv2.line(orig, (int(tlblX), int(tlblY)), (int(trbrX), int(trbrY)),
			(255, 0, 255), 2)

		# compute the Euclidean distance between the midpoints
		dA = dist.euclidean((tltrX, tltrY), (blbrX, blbrY))
		dB = dist.euclidean((tlblX, tlblY), (trbrX, trbrY))
		dY = dist.euclidean(tl,bl) #Y
		dX = dist.euclidean(bl, br) #X
		dC = dist.euclidean(bl, tr) #aCross
		#print (dC)
		
		#Only within possible wire y values
		#if bl[1] < 400 or bl[1] > 800 or br[1] < 400 or br[1] > 800:
		#	continue
		
		#Only within possible wire x values
		#if bl[0] < 150 or br[0] > 1820 or br[0] < 150 or bl[0] > 1820:
			#continue
		
		#Only reasonable damage possibilities
		if dY < 10 or dX < 10:
			continue
		
		
		# show the output image
		cv2.imshow("Image", orig)
		cv2.waitKey(0)
		
		j+=1
	
	return j;

	
def contoursEdges(canny, img):
	kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(5,5))
	dilated = cv2.dilate(canny, kernel)
	cnts= cv2.findContours(canny, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
	cnts = imutils.grab_contours(cnts)

	#sort contours
	(cnts, _) = contours.sort_contours(cnts)
	pixelsPerMetric = None
	
	# loop over the contours individually
	i = 0
	for c in cnts:
		# if the contour is not sufficiently large, ignore it
		if cv2.contourArea(c) < 10 or cv2.contourArea(c) > 200:
			continue
		
		# compute the rotated bounding box of the contour
		orig = img.copy()
		box = cv2.minAreaRect(c)
		box = cv2.cv.BoxPoints(box) if imutils.is_cv2() else cv2.boxPoints(box)
		box = np.array(box, dtype="int")
		
		# order the points in the contour such that they appear
		# in top-left, top-right, bottom-right, and bottom-left
		# order, then draw the outline of the rotated bounding
		# box
		box = perspective.order_points(box)
		cv2.drawContours(orig, [box.astype("int")], -1, (0, 255, 0), 2)
		
		# loop over the original points and draw them
		for (x, y) in box:
			cv2.circle(orig, (int(x), int(y)), 5, (0, 0, 255), -1)
			
		# unpack the ordered bounding box, then compute the midpoint
		# between the top-left and top-right coordinates, followed by
		# the midpoint between bottom-left and bottom-right coordinates
		(tl, tr, br, bl) = box
		(tltrX, tltrY) = midpoint(tl, tr)
		(blbrX, blbrY) = midpoint(bl, br)
		
		# compute the midpoint between the top-left and top-right points,
		# followed by the midpoint between the top-righ and bottom-right
		(tlblX, tlblY) = midpoint(tl, bl)
		(trbrX, trbrY) = midpoint(tr, br)
		
		# draw the midpoints on the image
		cv2.circle(orig, (int(tltrX), int(tltrY)), 5, (255, 0, 0), -1)
		cv2.circle(orig, (int(blbrX), int(blbrY)), 5, (255, 0, 0), -1)
		cv2.circle(orig, (int(tlblX), int(tlblY)), 5, (255, 0, 0), -1)
		cv2.circle(orig, (int(trbrX), int(trbrY)), 5, (255, 0, 0), -1)
		
		# draw lines between the midpoints
		cv2.line(orig, (int(tltrX), int(tltrY)), (int(blbrX), int(blbrY)),
			(255, 0, 255), 2)
		cv2.line(orig, (int(tlblX), int(tlblY)), (int(trbrX), int(trbrY)),
			(255, 0, 255), 2)

		# compute the Euclidean distance between the midpoints
		dA = dist.euclidean((tltrX, tltrY), (blbrX, blbrY))
		dB = dist.euclidean((tlblX, tlblY), (trbrX, trbrY))
		dY = dist.euclidean(tl,bl) #Y
		dX = dist.euclidean(bl, br) #X
		dC = dist.euclidean(bl, tr) #aCross
		#print (dC)
		print (cv2.contourArea(c), " X:", dB, " Y:", dA)
		print (bl, ", ", br) 
		#Only within possible wire y values
		if bl[1] < 400 or bl[1] > 800 or br[1] < 400 or br[1] > 800:
			continue
		
		#Only within possible wire x values
		if bl[0] < 150 or br[0] > 1820 or br[0] < 150 or bl[0] > 1820:
			continue
		
		#Only reasonable damage possibilities
		if dA < 10 or dB < 10:
			continue
		
		#Remove most horizontal edges
		if (dB/3) > dA:
			continue
		
		
		# show the output image
		cv2.imshow("Image", orig)
		cv2.waitKey(0)
		
		i+=1
	return(i)



imgName1 = "corr.png"
imgName2 = "smallGrind.jpg"
imgName3 = "Undamaged.jpg"
imgName4 = "Grind.jpg"

curName = imgName2;
# set up basic file stuff
output = "defects.txt"
with open(output, 'w+') as filetowrite:
	filetowrite.write(curName);

detectWear(curName)

detectRust(imgName1)







mat = cv2.imread(imgName3, cv2.IMREAD_COLOR)
umat = cv2.UMat(mat)
#laplacian = cv2.Laplacian(umat, cv2.CV_64F)
#cv2.imshow('laplacian', laplacian)


cv2.waitKey(0)

cv2.destroyAllWindows();