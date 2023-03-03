# ConnectionRegistry
**Inherits:**
[PermissionedContract](/contracts/PermissionedContract#35)


## State Variables
### CONNECTION_TYPE_LINK

```solidity
uint8 public constant CONNECTION_TYPE_LINK = 1;
```


### CONNECTION_TYPE_PARENT

```solidity
uint8 public constant CONNECTION_TYPE_PARENT = 2;
```


### CONNECTION_TYPE_CHILD

```solidity
uint8 public constant CONNECTION_TYPE_CHILD = 3;
```


### CONNECTION_TYPE_ALIAS

```solidity
uint8 public constant CONNECTION_TYPE_ALIAS = 4;
```


### entities

```solidity
EntityRegistry public entities;
```


### definitions

```solidity
EntityDefinitionRegistry public definitions;
```


### definitionConnections

```solidity
mapping(uint256 => DefinitionConnections) public definitionConnections;
```


### connections

```solidity
mapping(uint256 => Connection) public connections;
```


### counter

```solidity
uint256 public counter = 0;
```


## Functions
### constructor


```solidity
constructor(string memory _permissionPrefix, address _permissionAddr, address _definitionsAddr, address _entitiesAddr)
    PermissionedContract(msg.sender, _permissionPrefix, _permissionAddr);
```

### exists


```solidity
function exists(uint256 _id) public view returns (bool);
```

### exists


```solidity
function exists(uint256 _fromId, uint256 _toId, uint8 _type) public view returns (bool);
```

### exists


```solidity
function exists(uint256 _fromId, uint256 _toId) public view returns (bool);
```

### getConnectionCount


```solidity
function getConnectionCount(uint256 _fromId) public view returns (uint256);
```

### getConnections


```solidity
function getConnections(uint256 _fromId) public view returns (uint256[] memory);
```

### getConnectionId


```solidity
function getConnectionId(uint256 _fromId, uint256 _toId) public view returns (uint256);
```

### getConnectionId


```solidity
function getConnectionId(uint256 _fromId, uint256 _toId, uint8 _type) public view returns (uint256);
```

### getConnection


```solidity
function getConnection(uint256 _fromId, uint256 _toId) public view returns (Connection memory);
```

### getConnection


```solidity
function getConnection(uint256 _fromId, uint256 _toId, uint8 _type) public view returns (Connection memory);
```

### connect


```solidity
function connect(uint256 _fromId, uint256 _toId, uint8 _type) public returns (uint256);
```

### disconnect


```solidity
function disconnect(uint256 _fromId, uint256 _toId, uint8 _type) public;
```

### disconnect


```solidity
function disconnect(uint256 _fromId, uint256 _toId) public;
```

### getEntityConnectionIds


```solidity
function getEntityConnectionIds(uint256 _entityId) public view returns (uint256[] memory);
```

### getEntityConnections


```solidity
function getEntityConnections(uint256 _entityId) public view returns (Connection[] memory);
```

### getEntityConnectionIds


```solidity
function getEntityConnectionIds(uint256 _fromEntityId, uint256 _toEntityId) public view returns (uint256[] memory);
```

### getEntityConnections


```solidity
function getEntityConnections(uint256 _fromEntityId, uint256 _toEntityId) public view returns (Connection[] memory);
```

## Events
### ConnectionCreated

```solidity
event ConnectionCreated(uint256 id, uint256 fromId, uint256 toId, uint8 connectionType, uint256 contributorId);
```

### ConnectionDeleted

```solidity
event ConnectionDeleted(uint256 id, uint256 fromId, uint256 toId, uint8 connectionType, uint256 contributorId);
```

## Structs
### Connection

```solidity
struct Connection {
    uint256 id;
    uint256 fromId;
    uint256 toId;
    uint8 connectionType;
    uint256 contributorId;
}
```

### DefinitionConnections

```solidity
struct DefinitionConnections {
    uint256 id;
    uint256[] connectionIds;
}
```

