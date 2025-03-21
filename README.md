# Animal_calsification_Django_ML

This project is a Django-based application that allows users to upload images and classify them using a pre-trained VGG16 model. It also retrieves relevant facts about the predicted class from Wikipedia.

## Requirements

- Python 3.x
- Django 5.x
- Django REST Framework
- TensorFlow (for VGG16 model)
- OpenCV (for image processing)
- requests (for making HTTP requests)

## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/kumarsatish23/Animal_calsification_Django_ML.git
   cd Animal_calsification_Django_ML
   ```

2. Create a virtual environment (optional but recommended):

   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows use `venv\Scripts\activate`
   ```

3. Install dependencies:

   ```bash
   pip install -r requirements.txt
   ```

## Django Setup

1. Apply migrations to create the database (SQLite by default):

   ```bash
    python manage.py flush
    python manage.py makemigrations
    python manage.py makemigrations classifier
    python manage.py migrate
   ```

2. Create a superuser for accessing the admin interface:

   ```bash
   python manage.py createsuperuser
   ```

3. Run the development server:

   ```bash
   python manage.py runserver
   ```

   The server will start at `http://127.0.0.1:8000/`.

## Usage

- Access the Django admin interface at `http://127.0.0.1:8000/admin/` to manage uploaded images.
- Use the API endpoint for image classification:
  - Endpoint: `http://127.0.0.1:8000/api/classify/`
  - Method: POST
  - Request Body: Form-data or URL-encoded with `image` field containing the image file.

## API Documentation

- Swagger UI is available for API documentation:
  - Endpoint: `http://127.0.0.1:8000/swagger/`

## Contributing

Contributions are welcome! Fork the repository, make your changes, and submit a pull request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.