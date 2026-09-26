# Assumptions log

Every agent appends a row whenever it chooses a default instead of asking. Each hard gate
comment shows the delta since the previous gate. A human can convert a row into a question
with `challenge A-NNN`. Low-confidence AND expensive-to-reverse rows are escalated automatically.

| id | phase | assumption | confidence | reversibility | status | raised by |
|---|---|---|---|---|---|---|
| A-001 | ideate | Single workspace per user for v1 | medium | expensive | open | ideate |
