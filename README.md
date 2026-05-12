# Midas Core

Midas Core is a Spring Boot backend that processes financial transactions asynchronously using Kafka, validates and persists them with JPA/H2, calls an external Incentive API, and exposes REST APIs for health and balance queries.

## Tech Stack

- Java 17
- Spring Boot 3
- Maven
- Apache Kafka + Spring Kafka
- Spring Data JPA + Hibernate
- H2 Database
- REST APIs + RestTemplate
- JUnit 5 + Embedded Kafka + MockMvc

## Features

- Asynchronous transaction intake from Kafka topic `trader-updates`
- Validation for sender/recipient/amount/balance checks
- Incentive enrichment via external REST API
- Correct financial update rule:
  - `sender -= amount`
  - `recipient += amount + incentive`
- Transaction persistence with sender/recipient relationships
- Balance query endpoint:
  - `GET /api/v1/balance?userId=<id>`
  - returns `{"balance": ...}`
  - returns `0` for unknown users

## Architecture

```text
Producer -> Kafka(trader-updates) -> @KafkaListener -> TransactionService
                                                    |-> Validation
                                                    |-> IncentiveApiClient (REST)
                                                    |-> JPA Repositories (H2)
                                                    \-> Persist TransactionRecord + update UserRecord balances

REST Clients -> BalanceController -> BalanceService -> UserRecordRepository
```

## Project Structure

```text
com.midascore
 ├── controller
 ├── component
 ├── entity
 ├── repository
 ├── foundation
 ├── service
 └── config
```

## APIs

- Health:
  - `GET /api/v1/health`
- Incentive:
  - `POST /api/v1/incentive`
- Balance:
  - `GET /api/v1/balance?userId=1`

## Running

1. Ensure Java 17 and Maven are installed.
2. Start Kafka locally on `localhost:9092`.
3. Run:
   - `mvn spring-boot:run`
4. Application runs on port `33400`.

## H2 Console

- URL: `http://localhost:33400/h2-console`
- JDBC: `jdbc:h2:mem:midasdb`
- User: `sa`
- Password: *(empty)*

## Testing

- Run all tests:
  - `mvn test`
- Included tests:
  - Kafka integration test with embedded broker
  - Balance REST endpoint tests with MockMvc

## Production Improvements (Next Steps)

- Add retries/circuit breaker for Incentive API
- Add idempotency keys for duplicate Kafka messages
- Add dead-letter topic and error handlers
- Add observability (OpenTelemetry, metrics, dashboards)
- Replace H2 with PostgreSQL in production
- Add authN/authZ and API rate limiting
