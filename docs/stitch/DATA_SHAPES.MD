# Data Shapes

## Login Response

{
  "token": "jwt",
  "user": {
    "_id": "string",
    "email": "string",
    "firstName": "string",
    "lastName": "string",
    "company": "string",
    "role": "string",
    "accessLevel": { "name": "string", "level": 0, "actions": ["string"] }
  }
}

## Policy List Item

{
  "_id": "string",
  "title": "string",
  "status": "draft|review|approved|archived",
  "updatedAt": "iso-date",
  "department": "string",
  "tags": ["string"]
}

## Policy Detail

{
  "_id": "string",
  "title": "string",
  "status": "string",
  "updatedAt": "iso-date",
  "owner": "string",
  "content": "markdown-or-rich-text",
  "meta": { "department": "string", "version": "string" }
}

## Comment Item

{
  "_id": "string",
  "policyId": "string",
  "author": { "_id": "string", "name": "string" },
  "message": "string",
  "createdAt": "iso-date",
  "syncState": "synced|pending|failed"
}