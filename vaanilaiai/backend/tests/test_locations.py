"""Test location search and favorites management."""
import pytest


@pytest.mark.asyncio
async def test_search_locations(client):
    response = await client.get("/api/v1/locations/search?q=Nagercoil")
    assert response.status_code == 200
    results = response.json()
    assert isinstance(results, list)
    assert len(results) > 0
    top = results[0]
    assert "Nagercoil" in top["name"]
    assert top["latitude"] is not None
    assert top["longitude"] is not None


@pytest.mark.asyncio
async def test_saved_location_crud(client):
    payload = {
        "name": "Nagercoil Village",
        "district": "Kanyakumari",
        "state": "Tamil Nadu",
        "country": "India",
        "latitude": 8.1833,
        "longitude": 77.4119,
        "is_village": True,
        "is_favorite": True
    }
    create_resp = await client.post("/api/v1/locations/favorites", json=payload)
    assert create_resp.status_code == 201
    created_data = create_resp.json()
    assert created_data["name"] == "Nagercoil Village"
    assert created_data["is_village"] is True

    get_resp = await client.get("/api/v1/locations/favorites")
    assert get_resp.status_code == 200
    favorites = get_resp.json()
    assert len(favorites) == 1
    assert favorites[0]["district"] == "Kanyakumari"
