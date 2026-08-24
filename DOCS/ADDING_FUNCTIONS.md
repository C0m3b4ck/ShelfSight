# How to Add New Functions to ShelfSight

## Architecture Overview

```
┌─────────────────────────────────────────────────┐
│  GUI Layer (mainwindow.h / mainwindow.cpp)      │
│  - Qt widgets, user interaction                 │
│  - Calls BusinessLogicFacade methods            │
│  - NEVER includes sqlite_dataaccess.h           │
├─────────────────────────────────────────────────┤
│  Business Logic Layer                           │
│  - businesslogic.h  → interfaces + validation   │
│  - services.h/cpp   → concrete implementations  │
│  - Facade singleton wires everything together   │
├─────────────────────────────────────────────────┤
│  Data Access Layer                              │
│  - dataaccess.h        → IDataAccess interface  │
│  - sqlite_dataaccess.h/cpp → SQLite impl        │
├─────────────────────────────────────────────────┤
│  Domain Layer (domain.h)                        │
│  - Domain structs (Book, Reader, Loan, etc.)    │
│  - DTO structs with toDomain() converters       │
└─────────────────────────────────────────────────┘
```

**Dependency rule:** Each layer only includes the layer directly below it.
- GUI → Business Logic
- Business Logic → Data Access
- Data Access → Domain
- Never go sideways or skip layers.

---

## Adding a New CRUD Feature (e.g. "Publisher")

### Step 1: Domain struct + DTO (`domain.h`)

Add a domain struct in `Domain` namespace and a DTO in `DTO` namespace:

```cpp
// In namespace Domain
struct Publisher {
    std::string id;
    std::string name;
    std::string country;
    DateTime createdAt;
    DateTime updatedAt;

    bool isValid() const {
        return !name.empty() && isValidId(id);
    }
};

// In namespace DTO
struct PublisherDTO {
    std::string id;
    std::string name;
    std::string country;

    Domain::Publisher toDomain() const {
        Domain::Publisher p;
        p.id = id;
        p.name = name;
        p.country = country;
        p.createdAt = Domain::now();
        p.updatedAt = Domain::now();
        return p;
    }
};
```

### Step 2: Data access interface (`dataaccess.h`)

Add pure virtual methods to `IDataAccess`:

```cpp
virtual std::vector<Domain::Publisher> getAllPublishers() = 0;
virtual bool addPublisher(const Domain::Publisher& publisher) = 0;
virtual bool updatePublisher(const Domain::Publisher& publisher) = 0;
virtual bool removePublisher(const std::string& id) = 0;
```

### Step 3: SQLite implementation (`sqlite_dataaccess.cpp`)

Implement the methods. Use `m_booksDb` (or whichever DB holds the table):

```cpp
bool SQLiteDataAccess::addPublisher(const Domain::Publisher& publisher)
{
    std::lock_guard<std::mutex> lock(m_mutex);
    try {
        SQLite::Statement query(*m_booksDb,
            "INSERT INTO publishers (id, name, country, createdAt, updatedAt) VALUES (?, ?, ?, ?, ?)");
        query.bind(1, publisher.id);
        query.bind(2, publisher.name);
        query.bind(3, publisher.country);
        query.bind(4, dateTimeToString(publisher.createdAt));
        query.bind(5, dateTimeToString(publisher.updatedAt));
        query.exec();
        return true;
    }
    catch (const std::exception&) {
        return false;
    }
}
```

Also add the table to `createTables()` with a null guard:
```cpp
if (m_booksDb) {
    m_booksDb->exec(
        "CREATE TABLE IF NOT EXISTS publishers ("
        "id TEXT PRIMARY KEY, name TEXT NOT NULL, country TEXT NOT NULL,"
        "createdAt TEXT NOT NULL, updatedAt TEXT NOT NULL);"
    );
}
```

Declare in `sqlite_dataaccess.h` as well.

### Step 4: Business logic interface (`businesslogic.h`)

Add a service interface:

```cpp
class IPublisherService {
public:
    virtual ~IPublisherService() = default;
    virtual std::vector<Domain::Publisher> getAllPublishers() = 0;
    virtual bool addPublisher(const Domain::Publisher& publisher) = 0;
    virtual bool updatePublisher(const Domain::Publisher& publisher) = 0;
    virtual bool removePublisher(const std::string& id) = 0;
};
```

### Step 5: Concrete service (`services.h`)

Implement the interface. Services take `std::shared_ptr<DataAccess::IDataAccess>`:

```cpp
class PublisherService : public IPublisherService {
public:
    explicit PublisherService(std::shared_ptr<DataAccess::IDataAccess> dataAccess)
        : m_dataAccess(std::move(dataAccess)) {}

    std::vector<Domain::Publisher> getAllPublishers() override {
        return m_dataAccess->getAllPublishers();
    }

    bool addPublisher(const Domain::Publisher& publisher) override {
        return m_dataAccess->addPublisher(publisher);
    }
    // ... other methods ...

private:
    std::shared_ptr<DataAccess::IDataAccess> m_dataAccess;
};
```

### Step 6: Validation (`businesslogic.cpp`)

Add validation and a validate+add helper:

```cpp
ValidationResult validatePublisherDTO(const DTO::PublisherDTO& pub) {
    if (trim(pub.name).empty()) {
        return ValidationResult::failure("Publisher name cannot be empty");
    }
    return ValidationResult::success();
}

ValidationResult addPublisher(IPublisherService& service, const DTO::PublisherDTO& pub) {
    auto validation = validatePublisherDTO(pub);
    if (!validation.isValid) return validation;

    Domain::Publisher domain = pub.toDomain();
    if (service.addPublisher(domain)) {
        return ValidationResult::success();
    }
    return ValidationResult::failure("Failed to add publisher");
}
```

Declare these in `businesslogic.h` as well.

### Step 7: Wire into facade (`businesslogic.h` + `services.cpp`)

Add to `BusinessLogicFacade`:
```cpp
std::unique_ptr<IPublisherService> publishers;
```

In `BusinessLogicFacade::initialize()` (`services.cpp`), create the service:
```cpp
publishers = std::make_unique<PublisherService>(dataAccess);
```

### Step 8: GUI (`mainwindow.h` + `mainwindow.cpp`)

Add a slot in `mainwindow.h`:
```cpp
private slots:
    void on_btnAddPublisher_clicked();
```

Implement in `mainwindow.cpp`:
```cpp
void MainWindow::on_btnAddPublisher_clicked()
{
    auto& facade = BusinessLogic::BusinessLogicFacade::instance();
    if (!facade.publishers) {
        QMessageBox::critical(this, tr("ERROR"), tr("Publisher service not available"));
        return;
    }

    DTO::PublisherDTO pubDTO;
    pubDTO.name = toStd(ui->txtPublisherName->text());

    auto result = BusinessLogic::addPublisher(*facade.publishers, pubDTO);
    if (!result.isValid) {
        QMessageBox::critical(this, tr("ERROR"), QString::fromStdString(result.errorMessage));
        return;
    }

    QMessageBox::information(this, tr("SUCCESS"), tr("Publisher added successfully"));
}
```

---

## Key Rules

1. **GUI never includes data access headers.** Only `businesslogic.h` and `domain.h`.
2. **main.cpp only includes businesslogic.h and mainwindow.h.** No data access.
3. **Services take `IDataAccess` (interface), never `SQLiteDataAccess` (concrete).**
4. **All database table creation must null-guard** each `m_*Db` pointer (tables may not all be connected).
5. **Slot names must match Qt's `on_<objectName>_<signal>` convention** and be declared in `mainwindow.h`.
6. **Use `toStd()` helper** to convert `QString` to `std::string`.
7. **Use the `facade` singleton** to access services: `BusinessLogic::BusinessLogicFacade::instance()`.
8. **Return `ValidationResult`** from business logic functions. Never throw from business logic.
