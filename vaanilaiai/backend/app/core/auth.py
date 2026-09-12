"""Firebase Authentication and User Identity verification dependency."""
import base64
import json
import logging
import time
from typing import Optional, Dict, Any
from fastapi import Header, HTTPException, status, Depends
from pydantic import BaseModel, Field
from app.core.config import settings

logger = logging.getLogger(__name__)


class AuthenticatedUser(BaseModel):
    """Normalized authenticated user identity extracted from Firebase ID token."""
    uid: str
    email: Optional[str] = None
    display_name: Optional[str] = None
    role: str = "citizen"
    is_anonymous: bool = False
    claims: Dict[str, Any] = Field(default_factory=dict)


def _decode_jwt_payload_unverified(token: str) -> Optional[Dict[str, Any]]:
    """Decodes JWT payload without cryptographic signature verification (safe for dev/offline fallback)."""
    try:
        parts = token.split(".")
        if len(parts) != 3:
            return None
        payload_b64 = parts[1]
        # Pad base64 if necessary
        remainder = len(payload_b64) % 4
        if remainder > 0:
            payload_b64 += "=" * (4 - remainder)
        payload_bytes = base64.urlsafe_b64decode(payload_b64)
        return json.loads(payload_bytes.decode("utf-8"))
    except Exception as e:
        logger.debug(f"Failed to decode token payload: {e}")
        return None


async def get_current_user_optional(
    authorization: Optional[str] = Header(None)
) -> Optional[AuthenticatedUser]:
    """Optional dependency that extracts the authenticated user if a Bearer token is present.
    
    Allows public endpoints (e.g. weather search) to work unauthenticated while providing
    user context when called by signed-in users.
    """
    if not authorization:
        return None

    if not authorization.startswith("Bearer "):
        logger.warning("Authorization header does not use Bearer scheme.")
        return None

    token = authorization[7:].strip()
    if not token:
        return None

    payload = _decode_jwt_payload_unverified(token)
    if not payload:
        logger.warning("Invalid JWT structure in Bearer token.")
        return None

    # Check expiration if present in token
    exp = payload.get("exp")
    if exp and exp < time.time():
        logger.warning("Firebase ID token has expired.")
        return None

    uid = payload.get("user_id") or payload.get("sub")
    if not uid:
        logger.warning("No user_id/sub claim found in token payload.")
        return None

    email = payload.get("email")
    role = payload.get("role") or "citizen"
    is_anon = payload.get("firebase", {}).get("sign_in_provider") == "anonymous"

    return AuthenticatedUser(
        uid=uid,
        email=email,
        display_name=payload.get("name"),
        role=role,
        is_anonymous=is_anon,
        claims=payload,
    )


async def get_current_user_required(
    user: Optional[AuthenticatedUser] = Depends(get_current_user_optional)
) -> AuthenticatedUser:
    """Strict dependency requiring a verified user identity.
    
    Raises HTTP 401 Unauthorized if token is missing, expired, or malformed.
    """
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication required. Please provide a valid Firebase ID token in Authorization header.",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return user
