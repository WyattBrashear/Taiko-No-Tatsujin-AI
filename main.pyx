#AI/Algorithm thing that plays the mobile game: Taiko No Tatsujin: Pop Tap Beat
import os
import pyautogui
from PIL import Image
from ultralytics import YOLO
import argparse
import json

parser = argparse.ArgumentParser()
parser.add_argument("model", help="Path to model")
parser.add_argument("video", help="Camera number of the virtual camera (OBS Reccomended)")
args = parser.parse_args()
#Calibration
calibration_model = YOLO(args.model)
if os.path.exists("calibration.json"):
    with open("calibration.json", "r") as f:
        calibration = json.load(f)
        drum_window_x = calibration["drum_window_x"]
        drum_window_y = calibration["drum_window_y"]
        drum_window_corner_x = calibration["drum_corner_x"]
        drum_window_corner_y = calibration["drum_corner_y"]
        drum_window_size_x = calibration["drum_window_size"]
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
                "drum_window_size": int(corners[0][3] - corners[0][2]),
            }
            with open("calibration.json", "w") as f:
                json.dump(json_data, f)
                f.close()
            calibrated = True
            print("Calibration complete!")

