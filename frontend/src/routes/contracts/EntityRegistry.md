# EntityRegistry
**Inherits:**
[PermissionedContract](/contracts/PermissionedContract#31)


## State Variables
### types

```solidity
EntityTypeRegistry public types;
```


### entities

```solidity
mapping(uint256 => Entity) public entities;
```


### entityIds

```solidity
mapping(string => uint256) public entityIds;
```


### entityTypeIds

```solidity
mapping(uint256 => uint256[]) public entityTypeIds;
```


### counter

```solidity
uint256 public counter = 0;
```


## Functions
### constructor


```solidity
constructor(string memory _namespace, address _permissionAddr, address _typesAddr)
    PermissionedContract(msg.sender, _namespace, _permissionAddr);
```

### exists


```solidity
function exists(uint256 _id) public view returns (bool);
```

### exists


```solidity
function exists(string memory _name) public view returns (bool);
```

### register


```solidity
function register(string memory _name, uint256 _typeId) public returns (uint256);
```

### update


```solidity
function update(uint256 _id, string memory _name) public;
```

### remove


```solidity
function remove(uint256 _id) public;
```

### getEntity


```solidity
function getEntity(uint256 _id) public view returns (uint256, uint256, string memory);
```

### getEntityType


```solidity
function getEntityType(uint256 _id) public view returns (uint256, string memory);
```

### getEntities


```solidity
function getEntities(uint256 _offset, uint256 _limit) public view returns (uint256[] memory);
```

### getEntitiesByType


```solidity
function getEntitiesByType(uint256 _typeId, uint256 _offset, uint256 _limit) public view returns (uint256[] memory);
```

## Structs
### Entity

```solidity
struct Entity {
    uint256 id;
    uint256 typeId;
    uint256 contributorId;
    string name;
}
```

