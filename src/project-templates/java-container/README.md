# fsapps-${PROJECT_ID}-java-backend

Java Spring Boot backend application for project ${PROJECT_ID_UPPER}.

## Prerequisites

- Java 17 or higher
- Maven 3.6+
- PostgreSQL 14+

## Getting Started

1. Install dependencies:
```bash
mvn clean install
```

2. Run the application:
```bash
mvn spring-boot:run
```

The application will start on `http://localhost:8080/api`

## Configuration

Update `src/main/resources/application.yml` with your database credentials or set environment variables:

- `DB_HOST` - Database host (default: localhost)
- `DB_PORT` - Database port (default: 5432)
- `DB_NAME` - Database name (default: fsapps_${PROJECT_ID})
- `DB_USER` - Database username
- `DB_PASSWORD` - Database password

## Project Structure

```
src/
├── main/
│   ├── java/com/firesargeapps/
│   │   └── Application.java
│   └── resources/
│       └── application.yml
└── test/
```

## Project ID

This project uses the identifier: **${PROJECT_ID_UPPER}**
