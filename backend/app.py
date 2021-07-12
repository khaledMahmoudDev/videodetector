from flask import Flask, request, jsonify
from werkzeug.utils import secure_filename
from humanGaintPredict import get_avg_preds
import os 

app = Flask(__name__)
video_path = './saved_videos'

## For local testing
@app.route('/local', methods = ['GET'])
def local_processing():
    label = get_avg_preds('./videos_to_test/data_user_0_com.quantum.videodetector_cache_REC3188554085984091205.mp4')
    result = {'prediction': label}

    return jsonify(results=result)

# recieving video and return predictions
@app.route('/upload', methods = ['GET', 'POST'])
def file_uploader():
    if request.method == 'POST':
        if 'file' not in request.files:
            print("can't upload this file")
            return josnify(response="can't upload this file")

        file = request.files['file']
    
        file_name = secure_filename(file.filename)
        file_path = os.path.join(video_path, file_name)
        file.save(file_path)
        print(f"---- The {file_path} File uploaded successfully")

        # Predicting 
        label = get_avg_preds(file_path)

        remove_files()
        return jsonify(response='Uploaded successfully',
                        prediction=label)

    else:
        return jsonify(response='unknown Request')

def remove_files():
    for file_name in os.listdir(video_path):
        try:
            file_path = os.path.join(video_path, file_name)
            os.remove(file_path)
            print(f"---- The {file_path} have been removed succefully -----")

        except Exception as e:
            print(f"There isn't any files to delete {e}")



if __name__ == '__main__':
    app.run(debug = True, port=5500)
