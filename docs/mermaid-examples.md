# Mermaid Diagram Examples

This file demonstrates the `/mermaid-diagram` skill usage.

## Example 1: User Authentication Flow

**Description:** Show the flow when a user logs into the system, validates credentials, generates a JWT token, and redirects to dashboard.

```mermaid
sequenceDiagram
    actor User
    participant Frontend
    participant AuthAPI
    participant Database
    
    User->>Frontend: Enter credentials
    Frontend->>AuthAPI: POST /auth/login
    AuthAPI->>Database: Query user
    Database-->>AuthAPI: User data
    AuthAPI->>AuthAPI: Validate password
    AuthAPI->>AuthAPI: Generate JWT
    AuthAPI-->>Frontend: 200 OK + Token
    Frontend-->>User: Redirect to Dashboard
```

## Example 2: E-commerce Order Process

**Description:** Process flow from adding items to cart through payment and delivery.

```mermaid
graph TD
    Start[Browse Products] --> AddCart[Add to Cart]
    AddCart --> ViewCart{View Cart}
    ViewCart -->|Continue Shopping| Start
    ViewCart -->|Checkout| Login{Logged In?}
    Login -->|No| Register[Login/Register]
    Register --> Checkout
    Login -->|Yes| Checkout[Enter Shipping Info]
    Checkout --> Payment[Process Payment]
    Payment --> Validate{Payment Valid?}
    Validate -->|No| PaymentError[Show Error]
    PaymentError --> Payment
    Validate -->|Yes| Confirm[Order Confirmed]
    Confirm --> Ship[Ship Order]
    Ship --> Deliver[Delivered]
    Deliver --> End[Complete]
```

## Example 3: Database Schema for Blog System

**Description:** Database relationships for a blog with users, posts, comments, and tags.

```mermaid
erDiagram
    USER ||--o{ POST : writes
    USER ||--o{ COMMENT : writes
    POST ||--o{ COMMENT : has
    POST }o--o{ TAG : tagged_with
    
    USER {
        int id PK
        string email UK
        string username
        string password_hash
        datetime created_at
    }
    
    POST {
        int id PK
        int user_id FK
        string title
        text content
        string slug UK
        datetime published_at
        datetime updated_at
    }
    
    COMMENT {
        int id PK
        int post_id FK
        int user_id FK
        text content
        datetime created_at
    }
    
    TAG {
        int id PK
        string name UK
        string slug UK
    }
    
    POST_TAG {
        int post_id FK
        int tag_id FK
    }
```

## Example 4: Git Branching Strategy

**Description:** Feature branch workflow with main, develop, and feature branches.

```mermaid
gitGraph
    commit id: "Initial commit"
    commit id: "Setup project"
    branch develop
    checkout develop
    commit id: "Add base structure"
    branch feature/auth
    checkout feature/auth
    commit id: "Add login"
    commit id: "Add registration"
    checkout develop
    merge feature/auth
    branch feature/posts
    checkout feature/posts
    commit id: "Create post model"
    commit id: "Add CRUD endpoints"
    checkout develop
    merge feature/posts
    checkout main
    merge develop tag: "v1.0.0"
    checkout develop
    commit id: "Bug fixes"
```

## Example 5: Microservices Architecture

**Description:** Microservices setup with API gateway, services, databases, and message queue.

```mermaid
graph TB
    Client[Web Client] --> Gateway[API Gateway]
    Mobile[Mobile App] --> Gateway
    
    Gateway --> Auth[Auth Service]
    Gateway --> User[User Service]
    Gateway --> Product[Product Service]
    Gateway --> Order[Order Service]
    
    Auth --> AuthDB[(Auth DB)]
    User --> UserDB[(User DB)]
    Product --> ProductDB[(Product DB)]
    Order --> OrderDB[(Order DB)]
    
    Order --> Queue[Message Queue]
    Queue --> Email[Email Service]
    Queue --> Notification[Notification Service]
    
    Email --> SMTP[SMTP Server]
    Notification --> Push[Push Service]
    
    style Gateway fill:#69f
    style Queue fill:#f96
    style AuthDB fill:#9f6
    style UserDB fill:#9f6
    style ProductDB fill:#9f6
    style OrderDB fill:#9f6
```

## Example 6: Order State Machine

**Description:** Order lifecycle from pending to delivered or cancelled.

```mermaid
stateDiagram-v2
    [*] --> Pending
    Pending --> Processing : Payment Confirmed
    Pending --> Cancelled : Payment Failed
    
    Processing --> Packed : Items Ready
    Processing --> Cancelled : Out of Stock
    
    Packed --> Shipped : Courier Pickup
    Shipped --> InTransit : In Delivery
    InTransit --> Delivered : Customer Received
    
    Delivered --> Returned : Return Requested
    Returned --> Refunded : Return Approved
    
    Cancelled --> [*]
    Refunded --> [*]
    Delivered --> [*]
```

## Example 7: Project Timeline

**Description:** Software development project schedule with phases.

```mermaid
gantt
    title Software Development Timeline
    dateFormat YYYY-MM-DD
    section Planning
    Requirements Gathering    :a1, 2026-05-16, 7d
    System Design            :a2, after a1, 5d
    section Development
    Backend API              :b1, after a2, 14d
    Frontend UI              :b2, after a2, 14d
    Database Setup           :b3, after a2, 7d
    section Testing
    Unit Testing             :c1, after b1, 5d
    Integration Testing      :c2, after c1, 5d
    UAT                      :c3, after c2, 3d
    section Deployment
    Staging Deploy           :d1, after c3, 2d
    Production Deploy        :d2, after d1, 1d
```

## How to Use the Skill

1. Type `/mermaid-diagram` in Claude Code
2. Describe what you want to visualize
3. Claude will generate the appropriate Mermaid diagram
4. Copy the markdown code block into your GitHub README or documentation

## Supported Diagram Types

- **Flowchart**: Process flows, decision trees
- **Sequence**: API interactions, message flows
- **Class**: OOP structure, UML diagrams
- **ER Diagram**: Database schemas
- **State**: State machines, lifecycles
- **Gantt**: Project timelines
- **Pie**: Data distributions
- **Git Graph**: Branch strategies
