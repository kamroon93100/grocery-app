\# Backend Integration



The Flutter app communicates with the live NestJS backend using REST APIs.



\## Base API



https://kohli-store-api-4zh4.onrender.com/api



\## Main API Usage



\- Products: used for home, search, product detail

\- Categories: used for category browsing

\- Cart: used for add/remove/update cart

\- Orders: used for checkout and order history

\- Auth: used for login and profile flows



\## Data Flow



```text

Flutter Screen

&#x20;  ↓

Provider

&#x20;  ↓

Service

&#x20;  ↓

HTTP Request

&#x20;  ↓

NestJS API

