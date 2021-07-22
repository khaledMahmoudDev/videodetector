import tensorflow as tf 
from tensorflow.keras.models import load_model
import cv2
import numpy as np
import skimage
from skimage.transform import resize
import imutils
from imutils.object_detection import non_max_suppression

model = load_model('./saved_model')

hog = cv2.HOGDescriptor()
hog.setSVMDetector(cv2.HOGDescriptor_getDefaultPeopleDetector())

## Image preprocessing
def preprocess(img):
    ret_img=None
    candidates=[]
    x=np.zeros([650,500,3], np.uint8)
    kernal=np.ones((3,3),np.uint8)
    image = imutils.resize(img, width=min(400, img.shape[1]))
                            #  ,height=min(174, img.shape[0]))
    ## Image shape is 174 * 400 * 3
    # print(f"---------The shape of the images is {image.shape}")
    x[50:(50+image.shape[0]),50:(50+image.shape[1])]=image
    image=x
    (rects, weights) = hog.detectMultiScale(image, winStride=(4,4),padding=(64,64), scale=1.05)
    rects = np.array([[x, y, x + w, y + h] for (x, y, w, h) in rects])
    pick = non_max_suppression(rects, probs=None, overlapThresh=0.95)
    for (xA, yA, xB, yB) in pick:

        #cv2.imwrite("output/image{}.png".format(couter),image[yA:yB,xA:xB])
        img=image[yA:yB,xA:xB]
        img=cv2.cvtColor(img,cv2.COLOR_RGB2GRAY)
        img=cv2.adaptiveThreshold(img,255,cv2.ADAPTIVE_THRESH_GAUSSIAN_C,cv2.THRESH_BINARY,57,20)
        #_,img=cv2.threshold(img,80,255,cv2.THRESH_BINARY)
        img=cv2.bitwise_not(img)
        img=cv2.dilate(img,kernal,iterations=1)
        candidates.append(img)
    biggest_size=0
    for img in candidates:
        size=img.shape[0]*img.shape[1]
        if size> biggest_size:
            ret_img=img
            biggest_size=size
    return ret_img

# Getting predictions on every frame and avg them
def get_avg_preds(vid_path):
    cap = cv2.VideoCapture(vid_path) # input the test video path here
    total_preds = []
    
    print('--------- PREDICTING -----------')
    while cap.isOpened():
        ret, image = cap.read()
        
        if not ret:
            print("Can't receive frame (stream end?). Exiting ...")
            break
            
        person = preprocess(image)
        
        if type(person) == type(None):
            continue
            
        image_to_pred = skimage.transform.resize(person, (1,75, 75, 3))
        img_arr = np.asarray(image_to_pred)
        
        y_pred = model.predict(img_arr)
        Y_pred_classes = np.argmax(y_pred,axis = 1)
        
        if Y_pred_classes[0] == 1:
            # Abnormal is labeled as 1
            total_preds.append(1)
        else:
            total_preds.append(0)

    cap.release()
    cv2.destroyAllWindows()

    print("----- END OF PREDICTIONS -----")

    label = get_label(total_preds)
    print(f"------ predicted label is: {label} ------")
    return label
    

## Getting a label of 'normal | abnormal' based on the avg
## predicted frames
def get_label(total_preds):
    count = 0
    if len(total_preds) == 0:
        print("can't detect persons in this video")
        return "can't find persons images in this video"

    for i in total_preds:
        if i == 1:
            count += 1

    print(f"the number of abnormal images is {count} from total of {len(total_preds)}")
    abnormality_thrshold = int(len(total_preds) * 0.1)
    if count >= abnormality_thrshold:
        return 'Abnormal'
    else:
        return 'Noraml'