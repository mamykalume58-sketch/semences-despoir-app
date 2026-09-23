import json
import os
import sys
import time
import base64
import requests

def base64url(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b'=').decode()

def get_access_token(sa: dict) -> str:
    import jwt  # PyJWT
    now = int(time.time())
    claims = {
        "iss": sa["client_email"],
        "scope": "https://www.googleapis.com/auth/datastore",
        "aud": "https://oauth2.googleapis.com/token",
        "exp": now + 3600,
        "iat": now,
    }
    signed_jwt = jwt.encode(claims, sa["private_key"], algorithm="RS256")
    resp = requests.post(
        "https://oauth2.googleapis.com/token",
        data={
            "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
            "assertion": signed_jwt,
        },
    )
    resp.raise_for_status()
    return resp.json()["access_token"]

def to_firestore_value(v):
    if isinstance(v, bool):
        return {"booleanValue": v}
    if isinstance(v, int):
        return {"integerValue": str(v)}
    if isinstance(v, float):
        return {"doubleValue": v}
    if v is None:
        return {"nullValue": None}
    return {"stringValue": str(v)}

def main():
    sa_json = os.environ["FIREBASE_SERVICE_ACCOUNT_SEMENCES"]
    sa = json.loads(sa_json)
    project_id = sa["project_id"]
    package_name = os.environ["PACKAGE_NAME"]

    fields = {
        "latestVersionCode": int(os.environ["VERSION_CODE"]),
        "latestVersionName": os.environ["VERSION_NAME"],
        "downloadUrl": os.environ["DOWNLOAD_URL"],
        "sizeBytes": int(os.environ["SIZE_BYTES"]),
        "forceUpdate": os.environ.get("FORCE_UPDATE", "false").lower() == "true",
    }
    message = os.environ.get("UPDATE_MESSAGE", "")
    if message:
        fields["message"] = message

    token = get_access_token(sa)
    doc_fields = {k: to_firestore_value(v) for k, v in fields.items()}

    field_paths = "&".join(f"updateMask.fieldPaths={k}" for k in fields.keys())
    url = (
        f"https://firestore.googleapis.com/v1/projects/{project_id}"
        f"/databases/(default)/documents/app_versions/{package_name}?{field_paths}"
    )
    resp = requests.patch(
        url,
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
        },
        json={"fields": doc_fields},
    )
    if not resp.ok:
        print("ÉCHEC —", resp.status_code, resp.text)
        sys.exit(1)
    print("OK — app_versions mis à jour :", fields)

if __name__ == "__main__":
    main()
