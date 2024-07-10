from rest_framework import status
from rest_framework.decorators import api_view, parser_classes
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.response import Response
from .models import UploadedImage
from .serializers import UploadedImageSerializer
from tensorflow.keras.applications.vgg16 import VGG16, preprocess_input, decode_predictions
from drf_yasg.utils import swagger_auto_schema
import numpy as np
import cv2
import requests

def get_wikipedia_facts(keyword, num_facts=10):
    url = "https://en.wikipedia.org/w/api.php"
    
    # Replace underscores with spaces
    search_keyword = keyword.replace('_', ' ')
    
    # First, search for the keyword
    search_params = {
        "action": "query",
        "format": "json",
        "list": "search",
        "srsearch": search_keyword
    }

    search_response = requests.get(url, params=search_params)
    search_data = search_response.json()

    if 'query' in search_data and 'search' in search_data['query']:
        search_results = search_data['query']['search']
        if search_results:
            page_title = search_results[0]['title']
            
            # Now, get the extract for the top search result
            extract_params = {
                "action": "query",
                "format": "json",
                "prop": "extracts",
                "exintro": True,
                "explaintext": True,
                "titles": page_title
            }

            extract_response = requests.get(url, params=extract_params)
            extract_data = extract_response.json()

            pages = extract_data.get("query", {}).get("pages", {})
            facts = []

            for page_id, page in pages.items():
                if "extract" in page:
                    sentences = page["extract"].split('. ')
                    for sentence in sentences[:num_facts]:
                        facts.append(sentence.strip())

            return facts[:num_facts] if facts else ["No relevant facts found on Wikipedia."]

    return ["No relevant facts found on Wikipedia."]

model = None  

@swagger_auto_schema(
    methods=['POST'],
    request_body=UploadedImageSerializer,
    responses={200: 'OK'})
@api_view(['POST'])
@parser_classes([MultiPartParser, FormParser])
def classify_image(request):
    global model  
    if model is None:
        model = VGG16(weights='imagenet')  

    serializer = UploadedImageSerializer(data=request.data)
    if serializer.is_valid():
        uploaded_image = serializer.save()
        try:
            image_path = uploaded_image.image.path
            image = cv2.imread(image_path)
            image = cv2.resize(image, (224, 224)) 
            image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
            image = preprocess_input(image)
            image = np.expand_dims(image, axis=0) 
            prediction = model.predict(image)
            decoded_predictions = decode_predictions(prediction, top=1)[0]
            predicted_class = decoded_predictions[0][1]
            facts = get_wikipedia_facts(predicted_class)

            return Response({
                'prediction': predicted_class,
                'facts': facts
            }, status=status.HTTP_200_OK)

        except Exception as e:
            return Response({'error': f"Prediction failed: {str(e)}"}, status=status.HTTP_400_BAD_REQUEST)

    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
