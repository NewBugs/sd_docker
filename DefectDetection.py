import cv2
import numpy as np
import matplotlib.pyplot as plt
from scipy.spatial import distance as dist
from imutils import perspective
from imutils import contours
import argparse
import imutils
import re
import glob

ap = argparse.ArgumentParser()
ap.add_argument("-cl", "--CannyLower", required = True, help = "Canny edge detection's lower threshold")
ap.add_argument("-cr", "--CannyRange", required = True, help = "Canny edge detection's range of possible edges")
ap.add_argument("-hsvl", "--HSVLower", required = True, help = "Corrosion Mask's lower HueValueSaturation levels [h,v,s] format")
ap.add_argument("-hsvu", "--HSVUpper", required = True, help = "Corrosion Mask's upper HueValueSaturation levels [h,v,s] format")
args = vars(ap.parse_args())

#Set up user values for detection
CL = int(args["CannyLower"])
CR = int(args["CannyRange"])
#split array into 3 segments
tokensL = args["HSVLower"].split(',')
tokensU = args["HSVUpper"].split(',')
HL = int(tokensL[0])
SL = int(tokensL[1])
VL = int(tokensL[2])
HU = int(tokensU[0])
SU = int(tokensU[1])
VU = int(tokensU[2])

# Helps determine size of defect for our parameter checks
def midpoint(ptA, ptB): #Finds the midpoint between two pixel (x,y) locations
	return ((ptA[0] + ptB[0]) * 0.5, (ptA[1] + ptB[1]) * 0.5)

def detectWear(imgName, numW):
	#Set image
	img = cv2.imread(imgName, cv2.IMREAD_COLOR)
	gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
	gray = cv2.bilateralFilter(gray,7,40,80)
	
	#gray = cv2.medianBlur(gray,5)
	#gray = cv2.GaussianBlur(gray, (7, 7), 0)
	lower_gray = np.array([40])
	upper_gray = np.array([200])
	mask = cv2.inRange(gray, lower_gray, upper_gray)
	#cv2.imshow('Mask', mask)
	
	#cv2.imshow('Gray', gray)
	
	canny = cv2.Canny(gray, CL, CR, apertureSize = 3)
	
	#cv2.imshow('img', img)
	#cv2.imshow('Canny', canny)
	
	#Find contours
	j, fray = contoursEdges(canny, img, numW)
	
	
	#cv2.destroyAllWindows();

	return j, fray

def detectCorrosion(imgName):
	#Set image
	img = cv2.imread(imgName, cv2.IMREAD_COLOR)
	hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
	# set hsv range for corrosion
	lower_red = np.array([HL, SL, VL])
	upper_red = np.array([HU, SU, VU])
	#binary mask is created from range
	mask = cv2.inRange(hsv, lower_red, upper_red)
	
	#apply mask to original image to show only the corrosion
	res = cv2.bitwise_and(img, img, mask = mask) 
	res2 = res
	#cv2.imshow('mask', mask)
	#cv2.imshow('img', img)
	
	#Find contours
	j = contoursMask(mask, img)
	
	return j

def contoursMask(mask, img):
	cList = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)
	cList = imutils.grab_contours(cList)

	#sort contours left to right
	(cList, _) = contours.sort_contours(cList)
	
	j = 0 # num of defects found
	
	# loop over the contours individually
	for c in cList:
		# ingore contours that are too small or too big
		if cv2.contourArea(c) < 10:
			continue
		
		# compute the rotated bounding box of the contour
		orig = img.copy()
		box = cv2.minAreaRect(c)
		box = cv2.cv.BoxPoints(box) if imutils.is_cv2() else cv2.boxPoints(box)
		box = np.array(box, dtype="int")
		
		# order the points in the contour
		box = perspective.order_points(box)
		cv2.drawContours(orig, [box.astype("int")], -1, (0, 0, 255), 2)
		
		# draw contours
		for (x, y) in box:
			cv2.circle(orig, (int(x), int(y)), 5, (0, 0, 255), -1)
			
		# calculate midpoint of top left and top right points
		# and bottom left and bottom right
		(tl, tr, br, bl) = box
		(tltrX, tltrY) = midpoint(tl, tr)
		(blbrX, blbrY) = midpoint(bl, br)
		
		# calculate midpoint of top left and bottom left points
		# and top right and bottom right
		(tlblX, tlblY) = midpoint(tl, bl)
		(trbrX, trbrY) = midpoint(tr, br)
		

		# compute the Euclidean distance between the midpoints
		dA = dist.euclidean((tltrX, tltrY), (blbrX, blbrY))
		dB = dist.euclidean((tlblX, tlblY), (trbrX, trbrY))
		dY = dist.euclidean(tl,bl) #Y
		dX = dist.euclidean(bl, br) #X
		dC = dist.euclidean(bl, tr) #aCross
		#print (dC)
		
		
		#Only within possible wire y values
		if bl[1] < 400 or tl[1] > 800 or br[1] < 400 or tr[1] > 800:
			continue
		
		#Only within possible wire x values
		if bl[0] < 150 or br[0] > 1820 or br[0] < 150 or bl[0] > 1820:
			continue
		
		#Only reasonable damage possibilities
		if dY < 20 or dX < 20:
			continue
		
		
		# show the output image
		#cv2.imshow("Image", orig)
		#cv2.waitKey(0)
		
		j+=1
	
	return j;
	
def contoursEdges(canny, img, numW):
	kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(5,5))
	dilated = cv2.dilate(canny, kernel)
	fray = False
	
	cList= cv2.findContours(canny, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
	cList = imutils.grab_contours(cList)
	
	#sort contours from left to right
	(cList, _) = contours.sort_contours(cList)
	
	# loop over the contours individually
	i = 0
	for c in cList:
		# if the contour is too large, ignore it
		if cv2.contourArea(c) > 200:
			continue
		
		# compute the rotated bounding box of the contour
		orig = img.copy()
		box = cv2.minAreaRect(c)
		box = cv2.cv.BoxPoints(box) if imutils.is_cv2() else cv2.boxPoints(box)
		box = np.array(box, dtype="int")
		
		# order the points in the contour
		box = perspective.order_points(box)
		cv2.drawContours(orig, [box.astype("int")], -1, (0, 255, 0), 2)
		
		# Draw the points
		for (x, y) in box:
			cv2.circle(orig, (int(x), int(y)), 5, (255, 255, 0), -1)
			
		# compute the midpoints with the box's corners
		(tl, tr, br, bl) = box
		(tltrX, tltrY) = midpoint(tl, tr)
		(blbrX, blbrY) = midpoint(bl, br)
		
		(tlblX, tlblY) = midpoint(tl, bl)
		(trbrX, trbrY) = midpoint(tr, br)
		

		# compute the distance between the midpoints
		dA = dist.euclidean((tltrX, tltrY), (blbrX, blbrY))
		dB = dist.euclidean((tlblX, tlblY), (trbrX, trbrY))
		dY = dist.euclidean(tl,bl) #Y
		dX = dist.euclidean(bl, br) #X
		dC = dist.euclidean(bl, tr) #aCross
		#print (dC)
		#print (cv2.contourArea(c), " X:", dB, " Y:", dA)
		#print (bl, ", ", br) 
		
		#Only within possible wire y values
		if bl[1] < 400 or tl[1] > 800 or br[1] < 400 or tr[1] > 800:
			continue
		
		#Only within possible wire x values
		if bl[0] < 150 or br[0] > 1820 or br[0] < 150 or bl[0] > 1820:
			continue
		
		#Only reasonable damage possibilities
		if dA < 15:
			continue
			
		if (dB/dA) > dA or (dA * dB) < 150:
			continue
		
		#Remove most horizontal edges
		if (dB/3) > dA:
			continue
		
		#print(dA)
		#print(dB)
		#print(dA * dB)
		
		# show the output image
		#cv2.imshow("Image", orig)
		#cv2.waitKey(0)
		i+=1
		
		#Check for frays, if within range but if br/bl below wire or tr/tl above wire
		if br[1] > 800 or bl[1] > 800 or tl[1] < 400 or tr[1] < 400 :
			fray = True #set fray to true, fray overtakes wear
			continue;
			
	numW += i;
	return numW, fray

def pullAllImages(f):
	wirePhotos = []
	for i in range (0,4):
		wirePhotos.append([])
		for photo in glob.glob(f[i]+'\*.jpg'):
			wirePhotos[i].append(photo)
			#print(wirePhotos[i])
	
	return wirePhotos


# set up basic file stuff
output = "defects.txt"
with open(output, 'w+') as filetowrite:
	filetowrite.write("");
folders = ["cam0", "cam1", "cam2", "cam3"];
#print(len(folders))
# Pull files and store the names in an array
wirePhotos = pullAllImages(folders)


i = 0 # Keeps index

for curr in wirePhotos[0]:
	numW = 0 # number of wear defects
	numR = 0 # number of corrosion defects
	fray = [False for x in range(4)] # array of bools
	#print(curr[5:])
	#Wear
	numW, fray[0] = detectWear(curr, numW)
	#cv2.waitKey(0)
	numW, fray[1] = detectWear(wirePhotos[1][i], numW)
	#cv2.waitKey(0)
	numW, fray[2] = detectWear(wirePhotos[2][i], numW)
	#cv2.waitKey(0)
	numW, fray[3] = detectWear(wirePhotos[3][i], numW)
	#cv2.waitKey(0)
	#Corrosion
	numR = detectCorrosion(curr)
	#cv2.waitKey(0)
	numR += detectCorrosion(wirePhotos[1][i])
	#cv2.waitKey(0)
	numR += detectCorrosion(wirePhotos[2][i])
	#cv2.waitKey(0)
	numR += detectCorrosion(wirePhotos[3][i])
	with open("defects.txt", 'a') as filetowrite:
			filetowrite.write(str(i))
	if numW != 0 :
		with open("defects.txt", 'a') as filetowrite:
			if fray[0] == True or fray[1] == True or fray[2] == True or fray[3] == True:
				filetowrite.write(" fray")
			else: 
				filetowrite.write(" wear")
				#print(numW)
	
	if numR != 0 :
		with open("defects.txt", 'a') as filetowrite:
			filetowrite.write(" corrosion")
	
	if numR == 0 and numW == 0:
		with open("defects.txt", 'a') as filetowrite:
			filetowrite.write(" none")
	with open("defects.txt", 'a') as filetowrite:
		filetowrite.write("\n")
	i+=1





#cv2.waitKey(0)

cv2.destroyAllWindows();