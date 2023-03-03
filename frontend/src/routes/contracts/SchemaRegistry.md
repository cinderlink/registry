# SchemaRegistry
**Inherits:**
[PermissionedContract](/contracts/PermissionedContract#31)


## State Variables
### schemas

```solidity
mapping(uint256 => Schema) public schemas;
```


### schemaIds

```solidity
mapping(string => uint256) public schemaIds;
```


### counter

```solidity
uint256 public counter = 0;
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
function register(string memory _name, string memory _cid) public returns (uint256);
```

### updateName


```solidity
function updateName(uint256 _id, string memory _name) public;
```

### updateCid


```solidity
function updateCid(uint256 _id, string memory _cid) public;
```

### update


```solidity
function update(uint256 _id, string memory _name, string memory _cid) public;
```

### remove


```solidity
function remove(uint256 _id) public;
```

### getSchema


```solidity
function getSchema(uint256 _id) public view returns (uint256, uint256, string memory);
```

### getId


```solidity
function getId(string memory _name) public view returns (uint256);
```

### getCid


```solidity
function getCid(uint256 _id) public view returns (string memory);
```

### getCid


```solidity
function getCid(string memory _name) public view returns (string memory);
```

### getContributorId


```solidity
function getContributorId(uint256 _id) public view returns (uint256);
```

### getContributorId


```solidity
function getContributorId(string memory _name) public view returns (uint256);
```

### getContributorAddress


```solidity
function getContributorAddress(uint256 _id) public view returns (address);
```

### getContributorAddress


```solidity
function getContributorAddress(string memory _name) public view returns (address);
```

### getName


```solidity
function getName(uint256 _id) public view returns (string memory);
```

## Structs
### Schema

```solidity
struct Schema {
    uint256 id;
    uint256 contributorId;
    string name;
    string cid;
}
```

