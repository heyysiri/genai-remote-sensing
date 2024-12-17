from cmath import sqrt
import sys
from flask import Flask, Response, request, jsonify, send_file
from PIL import Image
# import torch
# import torch.nn as nn
# from torchvision import transforms, models
import io
from flask_cors import CORS
import base64
import os
import numpy as np
import cv2
from flask import Flask, request, jsonify
import onnxruntime
# import tensorflow as tf
# from tensorflow.keras.models import load_model
from patchify import patchify
import onnxruntime as ort

onnx_model_path = os.path.join(os.path.dirname(__file__), 'vgg16.onnx')
ort_session = onnxruntime.InferenceSession(onnx_model_path)

class_names = {
    0: "Jute",
    1: "Maize",
    2: "Rice",
    3: "Sugarcane",
    4: "Wheat",
}

def preprocess_image(image_bytes):
    
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    
    image = image.resize((224, 224))
    image = np.array(image).astype(np.float32) / 255.0  
    image = (image - [0.485, 0.456, 0.406]) / [0.229, 0.224, 0.225]  
    image = np.transpose(image, (2, 0, 1))  
    return image.astype(np.float32) 


app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})


@app.route('/')
def home():
    return "Welcome to the Flask App!"

@app.route('/favicon.ico')
def favicon():
    return '', 204

@app.route('/predict', methods=['GET', 'POST'])
def classify_image():
    if request.method == 'POST':
        data = request.json  
        image_base64 = data.get('image')  
        
        if not image_base64:
            return jsonify({"error": "No image provided"}), 400
        
      
        print("Image received")
        image_bytes = base64.b64decode(image_base64)
        
    
        input_tensor = preprocess_image(image_bytes)
        input_tensor = np.expand_dims(input_tensor, axis=0) 
        print("Image preprocessed")
        
      
        ort_inputs = {ort_session.get_inputs()[0].name: input_tensor}
        ort_outs = ort_session.run(None, ort_inputs)
        print("Inference completed")
        
      
        predictions = ort_outs[0] 
        predicted_class_index = np.argmax(predictions, axis=1) 
        predicted_class_name = class_names[int(predicted_class_index[0])] 
        print("Prediction:", predicted_class_name)

        return jsonify({
            "predicted_class_index": int(predicted_class_index[0]),
            "predicted_class_name": predicted_class_name
        })
    else:
        return "This endpoint is for POST requests to classify images."    
    
# def tversky_loss(y_true, y_pred, alpha=0.7, beta=0.3):
#     smooth = 1e-6
#     y_true_flat = tf.keras.backend.flatten(y_true)
#     y_pred_flat = tf.keras.backend.flatten(y_pred)
#     true_pos = tf.reduce_sum(y_true_flat * y_pred_flat)
#     false_neg = tf.reduce_sum(y_true_flat * (1 - y_pred_flat))
#     false_pos = tf.reduce_sum((1 - y_true_flat) * y_pred_flat)
#     tversky = (true_pos + smooth) / (true_pos + alpha * false_neg + beta * false_pos + smooth)
#     return 1 - tversky

# def dice_coef(y_true, y_pred):
#     smooth = 1e-15
#     y_true = tf.keras.layers.Flatten()(y_true)
#     y_pred = tf.keras.layers.Flatten()(y_pred)
#     intersection = tf.reduce_sum(y_true * y_pred)
#     return (2. * intersection + smooth) / (tf.reduce_sum(y_true) + tf.reduce_sum(y_pred) + smooth)

# def iou(y_true, y_pred):
#     smooth = 1e-15
#     intersection = tf.reduce_sum(y_true * y_pred)
#     sum_ = tf.reduce_sum(y_true + y_pred)
#     jac = (intersection + smooth) / (sum_ - intersection + smooth)
#     return jac

# def sensitivity(y_true, y_pred):
#     true_positives = tf.reduce_sum(tf.round(y_true * y_pred))
#     possible_positives = tf.reduce_sum(tf.round(y_true))
#     return true_positives / (possible_positives + tf.keras.backend.epsilon())

# def precision(y_true, y_pred):
#     true_positives = tf.reduce_sum(tf.round(y_true * y_pred))
#     predicted_positives = tf.reduce_sum(tf.round(y_pred))
#     return true_positives / (predicted_positives + tf.keras.backend.epsilon())

# def specificity(y_true, y_pred):
#     true_negatives = tf.reduce_sum(tf.round((1 - y_true) * (1 - y_pred)))
#     possible_negatives = tf.reduce_sum(tf.round(1 - y_true))
#     return true_negatives / (possible_negatives + tf.keras.backend.epsilon())

# flood_model = load_model("modell.keras", custom_objects={
#     'tversky_loss': tversky_loss,
#     'dice_coef': dice_coef,
#     'iou': iou,
#     'sensitivity': sensitivity,
#     'precision': precision,
#     'specificity': specificity
# })

cf = {
    "image_size": 256,
    "patch_size": 16,
    "num_channels": 3,
    "flat_patches_shape": (
        (256**2) // (16**2),
        16 * 16 * 3,
    )
}

def preprocess_image_for_flood_detection(image):
    
    image = np.array(image).astype(np.float32)
 
    image = cv2.resize(image, (cf["image_size"], cf["image_size"]))
   
    image = image / 255.0

    patch_shape = (cf["patch_size"], cf["patch_size"], cf["num_channels"])
    patches = patchify(image, patch_shape, cf["patch_size"])
    patches = np.reshape(patches, cf["flat_patches_shape"])
    patches = np.expand_dims(patches, axis=0) 
    
    return patches
# Load the SAR Colorization ONNX Model
flood_model_path = "flood.onnx"
flood_session = ort.InferenceSession(flood_model_path)

@app.route('/detect', methods=['POST'])
def detect_flood():
    print("Received a request for flood detection")
    
    try:
        
        if 'image' in request.files:
            file = request.files['image']
            original_image = Image.open(file).convert('RGB')
            print("Image received from file")
        else:
            return jsonify({'error': 'No image file provided'}), 400
        
        
        image = original_image.resize((cf["image_size"], cf["image_size"]))
        
        
        ground_truth_path = 'gim.png' 
        if os.path.exists(ground_truth_path):
            ground_truth_original = Image.open(ground_truth_path).convert('RGB')
            
            ground_truth_original = ground_truth_original.resize((cf["image_size"], cf["image_size"]))
            print("Ground truth image loaded")
        else:
            print(f"Ground truth image not found at {ground_truth_path}")
            
            ground_truth_original = Image.new('RGB', (cf["image_size"], cf["image_size"]))
        
        processed_image = preprocess_image_for_flood_detection(image)
        print("Image preprocessed for flood detection")
        

        ort_inputs = {flood_session.get_inputs()[0].name: processed_image}
        ort_outs = flood_session.run(None, ort_inputs)
        # prediction = flood_model.predict(processed_image)
        print("Prediction made by the model")
        prediction = np.squeeze(ort_outs[0])  
        prediction = (prediction > 0.5).astype(np.uint8) 

        predicted_mask_image = (prediction * 255).astype(np.uint8)
        predicted_mask_pil = Image.fromarray(predicted_mask_image, mode='L')  
     
        ground_truth_array = np.array(ground_truth_original)
        ground_truth_gray = cv2.cvtColor(ground_truth_array, cv2.COLOR_RGB2GRAY)
        _, ground_truth_binary = cv2.threshold(ground_truth_gray, 127, 255, cv2.THRESH_BINARY)
        ground_truth_pil = Image.fromarray(ground_truth_binary, mode='L')
        
        result_image = np.array(original_image).copy()
        result_image = cv2.resize(result_image, (cf["image_size"], cf["image_size"]))
        mask_overlay = np.stack([predicted_mask_image] * 3, axis=-1) 
        result_image[mask_overlay[:, :, 0] > 0] = [255, 0, 0]
        result_image_pil = Image.fromarray(result_image)
    
        ground_truth_buf = io.BytesIO()
        ground_truth_pil.save(ground_truth_buf, format='PNG')
        ground_truth_buf.seek(0)
        
        predicted_mask_buf = io.BytesIO()
        predicted_mask_pil.save(predicted_mask_buf, format='PNG')
        predicted_mask_buf.seek(0)
        
        result_image_buf = io.BytesIO()
        result_image_pil.save(result_image_buf, format='PNG')
        result_image_buf.seek(0)
    
        ground_truth_base64 = base64.b64encode(ground_truth_buf.getvalue()).decode('utf-8')
        predicted_mask_base64 = base64.b64encode(predicted_mask_buf.getvalue()).decode('utf-8')
        result_image_base64 = base64.b64encode(result_image_buf.getvalue()).decode('utf-8')
       
        return jsonify({
            'ground_truth': ground_truth_base64,
            'predicted_mask': predicted_mask_base64,
            'result_image': result_image_base64,
            'flood_detected': bool(np.max(prediction) > 0)
        })
    
    except Exception as e:
        print(f"Error during flood detection: {str(e)}")
        return jsonify({'error': str(e)}), 500



# Load the SAR Colorization ONNX Model
sar_model_path = "sar2rgb.onnx"
sar_session = ort.InferenceSession(sar_model_path)

def preprocess_sar_image(image_buffer):
    try:
        # Open the image and resize to 256x256
        img = Image.open(io.BytesIO(image_buffer))
        img = img.resize((256, 256))
        img = img.convert("RGB")  # Ensure it's RGB

        # Convert to NumPy array and normalize
        img_array = np.array(img, dtype=np.float32) / 255.0
        mean = np.array([0.5, 0.5, 0.5], dtype=np.float32)
        std = np.array([0.5, 0.5, 0.5], dtype=np.float32)
        img_normalized = (img_array - mean) / std

        # Convert to CHW format and add batch dimension
        img_chw = np.transpose(img_normalized, (2, 0, 1))
        img_chw = np.expand_dims(img_chw, axis=0)

        return img_chw
    except Exception as e:
        raise ValueError(f"Error in preprocessing image: {e}")

def postprocess_sar_image(output_tensor):
    try:
        # Output tensor: [1, 3, H, W]
        output_array = output_tensor[0]  # Remove batch dimension
        output_array = np.clip((output_array * 0.5 + 0.5) * 255, 0, 255).astype(np.uint8)
        output_array = np.transpose(output_array, (1, 2, 0))  # Convert CHW to HWC

        # Convert to a PIL image
        img = Image.fromarray(output_array, "RGB")

        # Save the image to an in-memory buffer
        buffer = io.BytesIO()
        img.save(buffer, format="PNG")
        buffer.seek(0)  # Reset the buffer position to the beginning
        return buffer
    except Exception as e:
        raise ValueError(f"Error in postprocessing image: {e}")


@app.route("/colorize", methods=["POST"])
def colorize():
    if "image" not in request.files:
        return {"error": "No image file provided"}, 400

    file = request.files["image"]

    if not file:
        return {"error": "Empty file"}, 400

    try:
        # Read and preprocess the image
        image_buffer = file.read()
        image_tensor = preprocess_sar_image(image_buffer)

        # Perform inference
        feeds = {sar_session.get_inputs()[0].name: image_tensor}
        outputs = sar_session.run(None, feeds)
        output_tensor = outputs[0]

        # Postprocess and return colorized image as PNG
        colorized_image_buffer = postprocess_sar_image(output_tensor)
        return send_file(
            colorized_image_buffer,
            mimetype="image/png",
            as_attachment=True,
            download_name="colorized_image.png"
        )
    except Exception as e:
        return {"error": str(e)}, 500




vit_model_path = os.path.join(os.path.dirname(__file__), 'vit.onnx')
ort_session_vit = onnxruntime.InferenceSession(vit_model_path)


def preprocess_image_vit(image_bytes):
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    image = image.resize((224, 224))
    image = np.array(image).astype(np.float32) / 255.0
    image = (image - [0.485, 0.456, 0.406]) / [0.229, 0.224, 0.225]
    image = np.transpose(image, (2, 0, 1))
    return image.astype(np.float32)


@app.route('/classifyVit', methods=['POST'])
def classify_vit_image():
    if request.method == 'POST':
        if 'image' not in request.files:
            return jsonify({"error": "No image provided"}), 400

        image_file = request.files['image']
        image_bytes = image_file.read()
        input_tensor = preprocess_image_vit(image_bytes)
        input_tensor = np.expand_dims(input_tensor, axis=0)

        ort_inputs = {ort_session_vit.get_inputs()[0].name: input_tensor}
        ort_outs = ort_session_vit.run(None, ort_inputs)

        predictions = ort_outs[0]
        predicted_class_index = np.argmax(predictions, axis=1)
        predicted_class_name = class_names[int(predicted_class_index[0])]

        return jsonify({
            "predicted_class_index": int(predicted_class_index[0]),
            "predicted_class_name": predicted_class_name
        })
    else:
        return "This endpoint is for POST requests to classify images using ViT."




if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
