import requests
import json
import os
import argparse
from datetime import datetime

# Configuration - Ensure these match your actual folder structure
# If this script runs from the root, 'data' will be created in the root.
BASE_DATA_DIR = "airealestate/data" 

DATA_DIRS = {
    "planning": ["rezonings", "charlotte_2040_plan", "opportunity_zones", "current_zoning"],
    "infrastructure": ["transit_projects", "cip_projects", "transit_stations"],
    "risk": ["cmpd_incidents", "flood_zones"],
    "development": ["building_permits", "school_districts"],
    "lifestyle": ["walkability"]
}

# Mapping filenames back to their categories for easy lookup
FILE_TO_CAT = {filename: cat for cat, files in DATA_DIRS.items() for filename in files}

PROTECTED_LAYERS = ["flood_zones", "charlotte_2040_plan", "transit_stations", "walkability", "building_permits", "opportunity_zones", "current_zoning"]

ROTATION = {
    0: ["rezonings"],
    1: ["transit_projects", "cip_projects"],
    2: ["cmpd_incidents"],
    3: ["school_districts"],
    4: [], 5: [], 6: []
}

ENDPOINTS = {
    "rezonings": "https://gis.charlottenc.gov/arcgis/rest/services/PLN/Rezonings/MapServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=geojson",
    "transit_projects": "https://gis.charlottenc.gov/arcgis/rest/services/CATS/TransitStationDevelopmentPublic/MapServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=geojson",
    "cip_projects": "https://gis.charlottenc.gov/arcgis/rest/services/PLN/Planning_ThingsNearMe/MapServer/6/query?where=1%3D1&outFields=*&outSR=4326&f=geojson",
    "cmpd_incidents": "https://gis.charlottenc.gov/arcgis/rest/services/CMPD/CMPDIncidents/MapServer/0/query?where=YEAR+%3E%3D+%272024%27&outFields=INCIDENT_REPORT_ID,LATITUDE_PUBLIC,LONGITUDE_PUBLIC,HIGHEST_NIBRS_DESCRIPTION,DATE_REPORTED,LOCATION&outSR=4326&f=geojson",
    "school_districts": "https://gis.charlottenc.gov/arcgis/rest/services/CMS/SchoolDistricts/MapServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=geojson"
}

def fetch_data(name, url):
    print(f"Fetching {name}...")
    try:
        response = requests.get(url, timeout=60)
        response.raise_for_status()
        data = response.json()
        if "features" in data and len(data["features"]) > 0:
            return data
    except Exception as e:
        print(f"Error fetching {name}: {e}")
    return None

def save_data(data, category, filename):
    # This creates paths like: airealestate/data/planning/rezonings.json
    target_dir = os.path.join(BASE_DATA_DIR, category)
    os.makedirs(target_dir, exist_ok=True)
    filepath = os.path.join(target_dir, f"{filename}.json")
    with open(filepath, "w") as f:
        json.dump(data, f, indent=2)
    print(f"Saved: {filepath}")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--day", type=int)
    parser.add_argument("--all", action="store_true")
    args = parser.parse_args()

    current_day = datetime.now().weekday() if args.day is None else args.day
    
    if args.all:
        targets = [item for sublist in ROTATION.values() for item in sublist]
    else:
        targets = ROTATION.get(current_day, [])

    if not targets:
        print("Nothing to update today.")
        return

    for filename in targets:
        if filename in PROTECTED_LAYERS:
            print(f"Skipping {filename} (Protected)")
            continue
            
        category = FILE_TO_CAT.get(filename)
        url = ENDPOINTS.get(filename)
        
        if category and url:
            data = fetch_data(filename, url)
            if data:
                save_data(data, category, filename)

if __name__ == "__main__":
    main()
