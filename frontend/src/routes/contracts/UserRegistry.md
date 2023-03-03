# UserRegistry

## State Variables
### owner

```solidity
address owner;
```


### counter

```solidity
uint256 public counter = 0;
```


### users

```solidity
mapping(uint256 => User) public users;
```


### userAddresses

```solidity
mapping(address => uint256) public userAddresses;
```


### userIds

```solidity
mapping(string => uint256) public userIds;
```


## Functions
### constructor


```solidity
constructor();
```

### register


```solidity
function register(string memory _name, string memory _did, address _user) public returns (uint256);
```

### register


```solidity
function register(string memory _name, string memory _did) public returns (uint256);
```

### exists


```solidity
function exists(string memory _name) public view returns (bool);
```

### exists


```solidity
function exists(uint256 _id) public view returns (bool);
```

### exists


```solidity
function exists(address _address) public view returns (bool);
```

### exists


```solidity
function exists() public view returns (bool);
```

### getId


```solidity
function getId(string memory _name) public view returns (uint256);
```

### getId


```solidity
function getId() public view returns (uint256);
```

### getId


```solidity
function getId(address _address) public view returns (uint256);
```

### getUser


```solidity
function getUser(uint256 _id) public view returns (User memory);
```

### getUser


```solidity
function getUser(string memory _name) public view returns (User memory);
```

### getUser


```solidity
function getUser() public view returns (User memory);
```

### getdid


```solidity
function getdid(uint256 _id) public view returns (string memory);
```

### getdid


```solidity
function getdid(string memory _name) public view returns (string memory);
```

### getName


```solidity
function getName(uint256 _id) public view returns (string memory);
```

### getOwner


```solidity
function getOwner(uint256 _id) public view returns (address);
```

### updateName


```solidity
function updateName(uint256 _id, string memory _name) public;
```

### updatedid


```solidity
function updatedid(uint256 _id, string memory _did) public;
```

### updateOwner


```solidity
function updateOwner(uint256 _id, address _owner) public;
```

### update


```solidity
function update(uint256 _id, string memory _name, string memory _did, address _owner) public;
```

### update


```solidity
function update(uint256 _id, string memory _name, string memory _did) public;
```

## Structs
### User

```solidity
struct User {
    uint256 id;
    string did;
    string name;
    address owner;
}
```

