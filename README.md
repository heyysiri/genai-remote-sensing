# GenAI Remote Sensing

GenAI Remote Sensing is an innovative AI-powered solution designed to address critical challenges in environmental monitoring, disaster management, agriculture, defense, and more. By leveraging cutting-edge deep learning models and synthetic aperture radar (SAR) imaging techniques, this project aims to simplify SAR image interpretation and provide actionable insights.

---

## 🌟 Description

Synthetic aperture radar (SAR) images are widely used in remote sensing. However, interpreting SAR images can be challenging due to their intrinsic speckle noise and grayscale nature. Colorization of SAR images significantly enhances their interpretability, providing valuable insights for a wide range of applications.

This mobile app uses **GenAI techniques** to perform:
- **SAR Image Colorization**: Enhances image visual quality for better analysis.
- **Flood Area Detection**: Identifies and maps flood-prone regions.
- **Crop Mapping**: Maps SAR crop images to ground crop images for agricultural insights.

By integrating these features, the app contributes to advancements in environmental monitoring, disaster management, agriculture, and more.

---
# Demo


https://github.com/user-attachments/assets/700ac2ec-1bce-4d88-87e8-a53315c4dc14


## 🚀 Features

### 1. **Crop Classification**
- **What it does:** Predicts crop types across 5 classes with exceptional precision.
- **Models used:**
  - **VGG16:** Achieved an accuracy of **90%**.
  - **Vision Transformer (ViT):** Enhanced accuracy to **97%**.

### 2. **Flood Area Detection**
- **What it does:** Identifies flood-prone regions with spatial precision.
- **Model used:**
  - **UNETR:** Delivered a stellar accuracy of **96%** for spatial segmentation.

### 3. **SAR Image Colorization**
- **What it does:** Generates realistic colorized SAR images, improving their visual interpretability for analysis.
- **Model used:**
  - **Pix2Pix:** Achieved an FID score of **320**, highlighting realistic image synthesis.

### 4. **Backend Dockerization**
- Simplified deployment by containerizing all deep learning models using **Docker**.

---

## 🛠️ Tech Stack

### Frontend
- **Flutter**: For a responsive and intuitive user interface.

### Backend
- **Flask**: API development and integration.
- **Docker**: Ensuring seamless deployment and scalability.

### Deep Learning Models
- **VGG16**
- **Vision Transformer (ViT)**
- **UNETR**
- **Pix2Pix**

---

## 🗂️ How to Get Started

### Step 1: Set Up the Environment
1. Clone the repository:
   ```bash
   git clone https://github.com/heyysiri/genai-remote-sensing.git
   cd genai-remote-sensing
### Step 2: Set Up the Backend
1. Navigate to the backend folder and build the Docker image:
  ```bash
  docker build -t backend ./backend
  ```
2. After building the image, run a Docker container from it:
  ```bash
  docker run -d -p 8080:8080 --name backend-container backend
  ```

### Step 3: Run the Application
Start the frontend using Flutter:
   ```bash
   flutter run
   ```
### Step 4: Explore the Features
1. Use the Crop Classification tool to identify crop types with high precision.
2. Analyze flood-prone regions with the Flood Area Detection feature.
3. Transform grayscale SAR images with the Colorization Tool for better interpretability.
