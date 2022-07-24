## Simple Insert

SQL:

```sql
INSERT INTO films VALUES (?1, ?2, ?3, ?4, ?5, ?6)
```

Args:

* `"UA502"`
* `"Bananas"`
* `105`
* `"1971-07-13"`
* `"Comedy"`
* `"82 mins"`

Code:

```go
sqlite.Insert(
  qm.Into("films"),
  qm.Values(qm.Arg("UA502", "Bananas", 105, "1971-07-13", "Comedy", "82 mins")),
)
```

## Bulk Insert

SQL:

```sql
INSERT INTO films VALUES
(?1, ?2, ?3, ?4, ?5, ?6),
(?7, ?8, ?9, ?10, ?11, ?12)
```

Args:

* `"UA502"`
* `"Bananas"`
* `105`
* `"1971-07-13"`
* `"Comedy"`
* `"82 mins"`
* `"UA502"`
* `"Bananas"`
* `105`
* `"1971-07-13"`
* `"Comedy"`
* `"82 mins"`

Code:

```go
sqlite.Insert(
  qm.Into("films"),
  qm.Values(qm.Arg("UA502", "Bananas", 105, "1971-07-13", "Comedy", "82 mins")),
  qm.Values(qm.Arg("UA502", "Bananas", 105, "1971-07-13", "Comedy", "82 mins")),
)
```

## On Conflict Do Nothing

SQL:

```sql
INSERT INTO films VALUES (?1, ?2, ?3, ?4, ?5, ?6) ON CONFLICT DO NOTHING
```

Args:

* `"UA502"`
* `"Bananas"`
* `105`
* `"1971-07-13"`
* `"Comedy"`
* `"82 mins"`

Code:

```go
sqlite.Insert(
  qm.Into("films"),
  qm.Values(qm.Arg("UA502", "Bananas", 105, "1971-07-13", "Comedy", "82 mins")),
  qm.OnConflict(nil).DoNothing(),
)
```

## Upsert

SQL:

```sql
INSERT INTO distributors AS "d" ("did", "dname")
VALUES (?1, ?2), (?3, ?4)
ON CONFLICT (did) DO UPDATE
SET dname = (EXCLUDED.dname || ' (formerly ' || d.dname || ')')
WHERE (d.zipcode <> '21201')
```

Args:

* `8`
* `"Anvil Distribution"`
* `9`
* `"Sentry Distribution"`

Code:

```go
sqlite.Insert(
  qm.IntoAs("distributors", "d", "did", "dname"),
  qm.Values(qm.Arg(8, "Anvil Distribution")),
  qm.Values(qm.Arg(9, "Sentry Distribution")),
  qm.OnConflict("did").DoUpdate().Set(
    "dname",
    qm.CONCAT(
      "EXCLUDED.dname", qm.S(" (formerly "), "d.dname", qm.S(")"),
    ),
  ).Where(qm.X("d.zipcode").NE(qm.S("21201"))),
)
```

## Or Replace

SQL:

```sql
INSERT OR REPLACE INTO distributors ("did", "dname")
VALUES (?1, ?2), (?3, ?4)
```

Args:

* `8`
* `"Anvil Distribution"`
* `9`
* `"Sentry Distribution"`

Code:

```go
sqlite.Insert(
  qm.OrReplace(),
  qm.Into("distributors", "did", "dname"),
  qm.Values(qm.Arg(8, "Anvil Distribution")),
  qm.Values(qm.Arg(9, "Sentry Distribution")),
)
```