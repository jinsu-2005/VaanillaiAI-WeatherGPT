"""Tests for Firebase Authentication & User Identity verification."""
import base64
import json
import time
import pytest
from fastapi import HTTPException
from app.core.auth import (
    AuthenticatedUser,
    get_current_user_optional,
    get_current_user_required,
)


def _make_dummy_jwt(payload: dict) -> str:
    header = {"alg": "none", "typ": "JWT"}
    h_b64 = base64.urlsafe_b64encode(json.dumps(header).encode()).decode().rstrip("=")
    p_b64 = base64.urlsafe_b64encode(json.dumps(payload).encode()).decode().rstrip("=")
    return f"{h_b64}.{p_b64}."


@pytest.mark.asyncio
async def test_auth_optional_no_header():
    user = await get_current_user_optional(authorization=None)
    assert user is None


@pytest.mark.asyncio
async def test_auth_optional_valid_token():
    token = _make_dummy_jwt({
        "user_id": "usr_test_123",
        "email": "farmer@vaanilai.ai",
        "name": "Arun Farmer",
        "role": "farmer",
        "exp": time.time() + 3600,
    })
    user = await get_current_user_optional(authorization=f"Bearer {token}")
    assert user is not None
    assert user.uid == "usr_test_123"
    assert user.email == "farmer@vaanilai.ai"
    assert user.role == "farmer"
    assert user.is_anonymous is False


@pytest.mark.asyncio
async def test_auth_optional_expired_token():
    token = _make_dummy_jwt({
        "user_id": "usr_expired",
        "exp": time.time() - 3600,
    })
    user = await get_current_user_optional(authorization=f"Bearer {token}")
    assert user is None


@pytest.mark.asyncio
async def test_auth_required_raises_401_on_none():
    with pytest.raises(HTTPException) as exc_info:
        await get_current_user_required(user=None)
    assert exc_info.value.status_code == 401


@pytest.mark.asyncio
async def test_auth_required_passes_valid_user():
    mock_user = AuthenticatedUser(uid="usr_456", email="test@vaanilai.ai")
    res = await get_current_user_required(user=mock_user)
    assert res.uid == "usr_456"
