```mermaid
flowchart TD
    START(["Class exists"]) --> CHOICE{"Who starts enrollment?"}

    CHOICE -->|"Instructor during creation"| P1["Path 1: Direct enrolment"]
    CHOICE -->|"Instructor after creation"| P2["Path 2: Direct enrolment"]
    CHOICE -->|"Student via share link"| P3["Path 3: Request funnel"]

    P1 --> FREEPAID1{"Free or paid?"}
    P2 --> FREEPAID1
    P3 --> S1["Step 1: Requested / waitlisted"]

    FREEPAID1 -->|"Free"| ROSTER_FREE["Active + on roster"]
    FREEPAID1 -->|"Paid"| JUMP["Jump to payment_plan_created"]

    S1 --> S2["Step 2: Approved"]
    S2 --> JOIN["payment_plan_created"]

    JUMP --> JOIN
    JOIN --> SHARED["Shared paid ladder"]
    SHARED --> ROSTER_PAID["PCI / active = on roster"]

    ROSTER_FREE --> DONE(["Enrolled"])
    ROSTER_PAID --> DONE
