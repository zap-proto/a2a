# zap-a2a — Google Agent2Agent over ZAP.
#
# A2A's task/artifact/agent-card model wrapped in ZAP frames. Every
# message is signed by the originating agent; every artifact carries
# its own provenance chain so cross-agent delegation is auditable.
#
# Ref: https://google.github.io/A2A — public spec, brand-neutral
# implementation.

# AgentCard is the registered identity of an agent. Published into
# zap-rns; resolution returns this card plus its KEM/sig keys.
struct AgentCard
  name        Text
  description Text
  url         Text
  version     Text
  capabilities List(Capability)
  publicKey   Data       # KEM public key
  signingKey  Data       # ML-DSA-65 public key

struct Capability
  id     Text
  name   Text
  schema Data       # JSON schema describing inputs/outputs

# Task is one unit of agent work. tasks compose into chains; each
# state transition is signed.
struct Task
  id          Text
  capability  Text         # which Capability id this exercises
  initiator   Text         # AgentCard.name of the requester
  worker      Text         # AgentCard.name of the executor
  state       TaskState
  input       Data
  output      Data
  error       Text
  createdAt   UInt64
  updatedAt   UInt64
  artifacts   List(Artifact)
  signatures  List(Signature)

enum TaskState
  submitted
  working
  inputRequired
  completed
  canceled
  failed

# Artifact is a typed output produced during task execution.
struct Artifact
  id       Text
  taskId   Text
  mimeType Text
  body     Data
  signedBy Text       # AgentCard.name that signed this artifact
  sig      Data

# Signature attaches a state-transition signature to a task.
struct Signature
  fromState TaskState
  toState   TaskState
  at        UInt64
  by        Text
  sig       Data
