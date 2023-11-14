import requests
#import spacy
import json

#nlp = spacy.load("en_core_web_sm")

API_KEY = open('apikey').read()

baltimore_harbor = {
    "circle": {
        "center": {
            "latitude": 39.2820552,
            "longitude": -76.6051076
        },
        "radius": 500
    }
}

def nearby_places(locationRestriction, url="https://places.googleapis.com/v1/places:searchNearby"):
    body = {
        "maxResultCount": 10,
        "locationRestriction": locationRestriction
    }

    headers = {
        "X-Goog-Api-Key": API_KEY,
        "X-Goog-FieldMask": "places.displayName,places.reviews"
    }
    
    r = requests.post(url, headers=headers, json=body)
    return r.json()

places = nearby_places(baltimore_harbor)
open("places", "w").write(json.dumps(places))
