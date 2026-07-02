\# System Architecture



```text

&#x20;                   User

&#x20;                     │

&#x20;       ┌─────────────┴─────────────┐

&#x20;       │                           │

&#x20;Android App                 Flutter Web

&#x20;       │                           │

&#x20;       └─────────────┬─────────────┘

&#x20;                     │

&#x20;             Flutter Application

&#x20;                     │

&#x20;                Provider State

&#x20;                     │

&#x20;               REST API Service

&#x20;                     │

&#x20;         NestJS Backend (Render)

&#x20;                     │

&#x20;                  Prisma ORM

&#x20;                     │

&#x20;              PostgreSQL Database

&#x20;                     │

&#x20;           Product \& Order Storage

```



\## Architecture Overview



The application follows a layered architecture.



\- Presentation Layer (Flutter UI)

\- State Management (Provider)

\- Service Layer (REST API)

\- Backend (NestJS)

\- ORM (Prisma)

\- Database (PostgreSQL)



This separation improves scalability, maintainability, and testing.

