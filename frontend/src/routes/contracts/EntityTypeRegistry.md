# EntityTypeRegistry
**Inherits:**
[PermissionedContract](/contracts/PermissionedContract#35)


## State Variables
### counter

```solidity
uint256 public counter = 0;
```


### entityTypes

```solidity
mapping(uint256 => EntityType) public entityTypes;
```


### entityTypeIds

```solidity
mapping(string => uint256) public entityTypeIds;
```


## Functions
### constructor


```solidity
constructor(string memory _namespace, address _permissionAddr)
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
function register(string memory _name) public returns (uint256);
```

### update


```solidity
function update(uint256 _id, string memory _name) public;
```

### remove


```solidity
function remove(uint256 _id) public;
```

### getId


```solidity
function getId(string memory _name) public view returns (uint256);
```

### getName


```solidity
function getName(uint256 _id) public view returns (string memory);
```

### getContributor


```solidity
function getContributor(uint256 _id) public view returns (address);
```

## Structs
### EntityType

```solidity
struct EntityType {
    uint256 id;
    string name;
    address contributor;
}
```

