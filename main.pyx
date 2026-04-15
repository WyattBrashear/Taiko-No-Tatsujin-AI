#AI/Algorithm thing that plays the mobile game: Taiko No Tatsujin: Pop Tap Beat
import os
import pyautogui
from PIL import Image
from ultralytics import YOLO
import argparse
import json
import cv2


parser = argparse.ArgumentParser()
parser.add_argument("model", help="Path to model")
parser.add_argument("video", help="Camera number of the virtual camera (OBS Reccomended)")
args = parser.parse_args()

cap = cv2.VideoCapture(args.video)


#Calibration
calibration_model = YOLO(args.model)
if os.path.exists("calibration.json"):
    with open("calibration.json", "r") as f:
        calibration = json.load(f)
        drum_window_x = calibration["drum_window_x"]
        drum_window_y = calibration["drum_window_y"]
        drum_window_corner_x = calibration["drum_corner_x"]
        drum_window_corner_y = calibration["drum_corner_y"]
        drum_size = calibration["drum_window_size"]
        f.close()
    calibrated = True
    print("Program is calibrated!")
else:
    calibrated = False
    print("Calibrating... (This may take a moment)")
while not calibrated:
    #Yes i know this is slow, its fine for calibration
    pyautogui.screenshot().save("calibration-tmp.png")
    results = calibration_model("calibration-tmp.png")
    for result in results:
        corners = result.boxes.xyxy
        centers = result.boxes.xywh
        box_count = len([result.names[cls.item()] for cls in result.boxes.cls.int()]) #Stole this little bit from YOLO docs
        confs = result.boxes.conf
    if box_count == 1:
        #Sometimes false-positive drum window detections are low confidence, so check for those to prevent false positives
        if confs[0] > 0.65:
            json_data = {
                "drum_window_x": int(centers[0][0]),
                "drum_window_y": int(centers[0][1]),
                "drum_corner_x": int(corners[0][0]),
                "drum_corner_y": int(corners[0][1]),
                "drum_window_size": int(corners[0][2] - corners[0][3]),
            }
            drum_size = (corners[0][2] - corners[0][3])
            with open("calibration.json", "w") as f:
                json.dump(json_data, f)
                f.close()
            calibrated = True
            print("Calibration complete!")

probe_1 = (int(centers[0][0])-drum_size, int(centers[0][1]))
probe_2 = (int(centers[0][0]), int(centers[0][1]))
probe_3 = (int(centers[0][0])+drum_size, int(centers[0][1]))
while calibrated:
    ret, frame = cap.read()
    probe_1_data = frame[probe_1[0], probe_1[1]]
    probe_2_data = frame[probe_2[0], probe_2[1]]
    probe_3_data = frame[probe_3[0], probe_3[1]]
    b1, g1, r1 = probe_1_data[0], probe_1_data[1], probe_1_data[2]
    b2, g2, r2 = probe_2_data[0], probe_2_data[1], probe_2_data[2]
    b3, g3, r3 = probe_3_data[0], probe_3_data[1], probe_3_data[2]
    print(f"1: Red: {r1}, Green: {g1}, Blue: {b1}")
    print(f"2: Red: {r2}, Green: {g2}, Blue: {b2}")
    print(f"3: Red: {r3}, Green: {g3}, Blue: {b3}")
