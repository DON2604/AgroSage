import requests

def get_coordinates(location):
    """Get latitude and longitude for a location using OpenStreetMap Nominatim."""
    try:
        geo_url = f"https://nominatim.openstreetmap.org/search?format=json&q={location}"
        res = requests.get(geo_url, headers={"User-Agent": "Mozilla/5.0"}, timeout=5)
        data = res.json()
        if not data:
            return None, None
        return float(data[0]["lat"]), float(data[0]["lon"])
    except Exception as e:
        return None, None

def fetcher(location="New York"):
    """Fetch 7-day weather forecast using Open-Meteo."""
    lat, lon = get_coordinates(location)
    if lat is None or lon is None:
        return {"error": "Unable to get coordinates for the location."}

    weather_url = (
        f"https://api.open-meteo.com/v1/forecast?"
        f"latitude={lat}&longitude={lon}&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,"
        f"weathercode&timezone=auto"
    )

    try:
        res = requests.get(weather_url, timeout=5)
        data = res.json()
        days = data["daily"]
        
        forecast = []
        for i in range(len(days["time"])):
            forecast.append({
                "date": days["time"][i],
                "max_temp": f"{days['temperature_2m_max'][i]}°C",
                "min_temp": f"{days['temperature_2m_min'][i]}°C",
                "precipitation": f"{days['precipitation_sum'][i]}mm",
                "weather_code": days['weathercode'][i]  # You can map this to text if needed
            })
        
        return {"location": location, "forecast": forecast}

    except Exception as e:
        return {"error": str(e)}


